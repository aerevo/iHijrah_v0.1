'use strict';

const crypto = require('crypto');

const {
  onDocumentCreated,
} = require('firebase-functions/v2/firestore');

const {
  logger,
} = require('firebase-functions');

const {
  initializeApp,
} = require('firebase-admin/app');

const {
  getAuth,
} = require('firebase-admin/auth');

const {
  getFirestore,
} = require('firebase-admin/firestore');

initializeApp();

const db = getFirestore();
const auth = getAuth();

const PAGE_SIZE = 200;
const WRITE_BATCH_SIZE = 400;

const LEASE_MS = 10 * 60 * 1000;

const PHASES = [
  'posts',
  'follows',
  'profile',
  'verify',
  'auth',
];

class LeaseLostError extends Error {
  constructor() {
    super('F3-G worker lease lost.');
    this.name = 'LeaseLostError';
  }
}

function workerId() {
  return crypto.randomUUID();
}

function nowMs() {
  return Date.now();
}

function timestampMs(timestamp) {
  if (!timestamp || typeof timestamp.toMillis !== 'function') {
    return 0;
  }

  return timestamp.toMillis();
}

function nextPhase(phase) {
  const index = PHASES.indexOf(phase);

  if (index < 0 || index === PHASES.length - 1) {
    return null;
  }

  return PHASES[index + 1];
}

function phaseIsKnown(phase) {
  return PHASES.includes(phase);
}

function deletionRef(uid) {
  return db.collection('accountDeletionRequests').doc(uid);
}

async function claimRequest(uid) {
  const ref = deletionRef(uid);
  const id = workerId();

  const claimed = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);

    if (!snap.exists) {
      return false;
    }

    const data = snap.data() || {};

    if (data.uid !== uid) {
      throw new Error(
        `F3-G request UID mismatch for ${uid}.`,
      );
    }

    if (data.status === 'completed') {
      return false;
    }

    const status = data.status;

    if (
      status !== 'pending' &&
      status !== 'failed' &&
      status !== 'processing'
    ) {
      throw new Error(
        `F3-G invalid deletion status "${status}".`,
      );
    }

    const currentLeaseUntil = timestampMs(data.leaseUntil);

    if (
      status === 'processing' &&
      data.workerId &&
      data.workerId !== id &&
      currentLeaseUntil > nowMs()
    ) {
      return false;
    }

    const phase = phaseIsKnown(data.phase)
      ? data.phase
      : 'posts';

    tx.set(
      ref,
      {
        status: 'processing',
        phase,
        workerId: id,
        leaseUntil: new Date(nowMs() + LEASE_MS),
        updatedAt: new Date(),
        lastError: null,
      },
      { merge: true },
    );

    return true;
  });

  return claimed ? id : null;
}

async function renewLease(uid, id) {
  const ref = deletionRef(uid);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);

    if (!snap.exists) {
      throw new LeaseLostError();
    }

    const data = snap.data() || {};

    if (
      data.status !== 'processing' ||
      data.workerId !== id
    ) {
      throw new LeaseLostError();
    }

    tx.update(ref, {
      leaseUntil: new Date(nowMs() + LEASE_MS),
      updatedAt: new Date(),
    });
  });
}

async function markPhase(uid, id, phase) {
  const ref = deletionRef(uid);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);

    if (!snap.exists) {
      throw new LeaseLostError();
    }

    const data = snap.data() || {};

    if (
      data.status !== 'processing' ||
      data.workerId !== id
    ) {
      throw new LeaseLostError();
    }

    tx.update(ref, {
      phase,
      updatedAt: new Date(),
    });
  });
}

async function markFailed(uid, id, phase, error) {
  const ref = deletionRef(uid);

  try {
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(ref);

      if (!snap.exists) {
        return;
      }

      const data = snap.data() || {};

      if (data.workerId !== id) {
        return;
      }

      tx.update(ref, {
        status: 'failed',
        phase,
        workerId: null,
        leaseUntil: null,
        updatedAt: new Date(),
        lastError: String(error?.message || error),
      });
    });
  } catch (markError) {
    logger.error(
      'F3-G: failed to persist failure state.',
      {
        uid,
        phase,
        error: String(markError),
      },
    );
  }
}

async function markCompleted(uid, id) {
  const ref = deletionRef(uid);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);

    if (!snap.exists) {
      throw new Error(
        'Deletion request disappeared before completion.',
      );
    }

    const data = snap.data() || {};

    if (
      data.status !== 'processing' ||
      data.workerId !== id
    ) {
      throw new LeaseLostError();
    }

    tx.update(ref, {
      status: 'completed',
      phase: 'completed',
      workerId: null,
      leaseUntil: null,
      completedAt: new Date(),
      updatedAt: new Date(),
      lastError: null,
    });
  });
}

async function commitDeletes(refs) {
  for (
    let start = 0;
    start < refs.length;
    start += WRITE_BATCH_SIZE
  ) {
    const chunk = refs.slice(
      start,
      start + WRITE_BATCH_SIZE,
    );

    const batch = db.batch();

    for (const ref of chunk) {
      batch.delete(ref);
    }

    await batch.commit();
  }
}

async function deleteCollectionPage(
  collectionRef,
  onPage,
) {
  let lastDoc = null;

  while (true) {
    let query = collectionRef
      .orderBy('__name__')
      .limit(PAGE_SIZE);

    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }

    const snap = await query.get();

    if (snap.empty) {
      break;
    }

    await onPage(snap);

    lastDoc = snap.docs[snap.docs.length - 1];

    if (snap.size < PAGE_SIZE) {
      break;
    }
  }
}

async function deleteRepliesForComment(
  commentRef,
  uid,
  worker,
) {
  await deleteCollectionPage(
    commentRef.collection('replies'),
    async (snap) => {
      await renewLease(uid, worker);

      const refs = snap.docs.map((doc) => doc.ref);

      await commitDeletes(refs);
    },
  );
}

/*
 * posts.commentsCount is not maintained by clients (firestore.rules keep it
 * at 0), so a post may legitimately have comments while commentsCount is 0.
 *
 *   integer >= 1       -> true  (caller decrements, then deletes the comment)
 *   integer === 0      -> false (caller deletes the comment, no decrement)
 *   anything else      -> throws (negative, non-integer, missing: corrupt
 *                         data is surfaced, never silently repaired)
 */
function shouldDecrementCommentsCount(commentsCount, postPath) {
  if (!Number.isInteger(commentsCount) || commentsCount < 0) {
    throw new Error(
      `Invalid commentsCount on ${postPath}.`,
    );
  }

  return commentsCount >= 1;
}

async function deleteNestedPost(
  postRef,
  uid,
  worker,
) {
  const commentsRef = postRef.collection('comments');
  const likesRef = postRef.collection('likes');

  await deleteCollectionPage(
    commentsRef,
    async (commentSnap) => {
      await renewLease(uid, worker);

      for (const comment of commentSnap.docs) {
        await deleteRepliesForComment(
          comment.ref,
          uid,
          worker,
        );

        const postRef = comment.ref.parent.parent;

        await db.runTransaction(async (tx) => {
          const currentComment = await tx.get(comment.ref);

          if (!currentComment.exists) {
            return;
          }

          const postSnap = await tx.get(postRef);

          if (!postSnap.exists) {
            tx.delete(comment.ref);
            return;
          }

          const data = postSnap.data() || {};
          const commentsCount = data.commentsCount;

          if (
            shouldDecrementCommentsCount(
              commentsCount,
              postRef.path,
            )
          ) {
            tx.update(postRef, {
              commentsCount: commentsCount - 1,
            });
          }

          tx.delete(comment.ref);
        });
      }
    },
  );

  await deleteCollectionPage(
    likesRef,
    async (likeSnap) => {
      await renewLease(uid, worker);

      await commitDeletes(
        likeSnap.docs.map((doc) => doc.ref),
      );
    },
  );

  await renewLease(uid, worker);

  await postRef.delete();
}

async function removeOwnPosts(uid, worker) {
  const postsRef = db.collection('posts');

  await deleteCollectionPage(
    postsRef
      .where('authorId', '==', uid),
    async (snap) => {
      for (const post of snap.docs) {
        await renewLease(uid, worker);
        await deleteNestedPost(
          post.ref,
          uid,
          worker,
        );
      }
    },
  );
}

async function removeOwnComments(uid, worker) {
  const commentsQuery = db
    .collectionGroup('comments')
    .where('authorId', '==', uid);

  await deleteCollectionPage(
    commentsQuery,
    async (snap) => {
      for (const comment of snap.docs) {
        await renewLease(uid, worker);

        await deleteRepliesForComment(
          comment.ref,
          uid,
          worker,
        );

        const postRef = comment.ref.parent.parent;

        await db.runTransaction(async (tx) => {
          const currentComment = await tx.get(comment.ref);

          if (!currentComment.exists) {
            return;
          }

          const postSnap = await tx.get(postRef);

          if (!postSnap.exists) {
            tx.delete(comment.ref);
            return;
          }

          const data = postSnap.data() || {};
          const commentsCount = data.commentsCount;

          if (
            shouldDecrementCommentsCount(
              commentsCount,
              postRef.path,
            )
          ) {
            tx.update(postRef, {
              commentsCount: commentsCount - 1,
            });
          }

          tx.delete(comment.ref);
        });
      }
    },
  );
}

async function removeOwnReplies(uid, worker) {
  const repliesQuery = db
    .collectionGroup('replies')
    .where('authorId', '==', uid);

  await deleteCollectionPage(
    repliesQuery,
    async (snap) => {
      await renewLease(uid, worker);

      await commitDeletes(
        snap.docs.map((doc) => doc.ref),
      );
    },
  );
}

async function removeOwnLikes(uid, worker) {
  /*
   * Current schema uses:
   *
   * posts/{postId}/likes/{uid}
   *
   * without a uid field.
   *
   * Therefore collectionGroup(likes) cannot safely search
   * by uid field. We scan posts and inspect likes/{uid}.
   *
   * This is intentionally kept compatible with the existing
   * production-like schema instead of introducing a migration.
   */
  await deleteCollectionPage(
    db.collection('posts'),
    async (postSnap) => {
      for (const post of postSnap.docs) {
        if (post.get('authorId') === uid) {
          continue;
        }

        await renewLease(uid, worker);

        const likeRef = post.ref
          .collection('likes')
          .doc(uid);

        const likeSnap = await likeRef.get();

        if (!likeSnap.exists) {
          continue;
        }

        await db.runTransaction(async (tx) => {
          const currentLike = await tx.get(likeRef);
          const currentPost = await tx.get(post.ref);

          if (!currentLike.exists) {
            return;
          }

          if (!currentPost.exists) {
            tx.delete(likeRef);
            return;
          }

          const data = currentPost.data() || {};
          const likes = data.likes;

          if (
            !Number.isInteger(likes) ||
            likes < 1
          ) {
            throw new Error(
              `Invalid likes counter on ${post.ref.path}.`,
            );
          }

          tx.update(post.ref, {
            likes: likes - 1,
          });

          tx.delete(likeRef);
        });
      }
    },
  );
}

async function phasePosts(uid, worker) {
  /*
   * Own posts first. Their entire nested tree belongs
   * to the post and must disappear with the post.
   */
  await removeOwnPosts(uid, worker);

  /*
   * Comments/replies on somebody else's content.
   */
  await removeOwnComments(uid, worker);
  await removeOwnReplies(uid, worker);

  /*
   * Likes on somebody else's posts.
   * Counter is updated transactionally with like deletion.
   */
  await removeOwnLikes(uid, worker);
}

function followRef(followerId, followeeId) {
  return db
    .collection('follows')
    .doc(`${followerId}_${followeeId}`);
}

async function removeOutgoingFollows(uid, worker) {
  const query = db
    .collection('follows')
    .where('followerId', '==', uid);

  await deleteCollectionPage(
    query,
    async (snap) => {
      for (const edge of snap.docs) {
        await renewLease(uid, worker);

        const data = edge.data() || {};
        const followeeId = data.followeeId;

        if (
          typeof followeeId !== 'string' ||
          followeeId.length === 0
        ) {
          throw new Error(
            `Invalid outgoing follow edge: ${edge.ref.path}`,
          );
        }

        const profileRef = db
          .collection('profiles')
          .doc(followeeId);

        await db.runTransaction(async (tx) => {
          const currentEdge = await tx.get(edge.ref);

          if (!currentEdge.exists) {
            return;
          }

          const profileSnap = await tx.get(profileRef);

          if (!profileSnap.exists) {
            tx.delete(edge.ref);
            return;
          }

          const profile = profileSnap.data() || {};
          const count = profile.followersCount;

          if (
            !Number.isInteger(count) ||
            count < 1
          ) {
            throw new Error(
              `Invalid followersCount on ${profileRef.path}.`,
            );
          }

          tx.update(profileRef, {
            followersCount: count - 1,
          });

          tx.delete(edge.ref);
        });
      }
    },
  );
}

/*
 * users.followingCount is NOT maintained by the production follow flow:
 * setFollowing() only changes profiles.followersCount, firestore.rules
 * create users/{uid} with followingCount == 0 and do not let clients
 * change it. So a follower's counter is normally 0 and must not block
 * deleting the edge.
 *
 *   integer >= 1       -> true  (caller decrements, then deletes the edge)
 *   integer === 0      -> false (caller deletes the edge, no decrement)
 *   anything else      -> throws (negative, non-integer, missing, null,
 *                         string: corrupt data is surfaced, never repaired)
 */
function shouldDecrementFollowingCount(followingCount, userPath) {
  if (!Number.isInteger(followingCount) || followingCount < 0) {
    throw new Error(
      `Invalid followingCount on ${userPath}.`,
    );
  }

  return followingCount >= 1;
}

async function removeIncomingFollows(uid, worker) {
  const query = db
    .collection('follows')
    .where('followeeId', '==', uid);

  await deleteCollectionPage(
    query,
    async (snap) => {
      for (const edge of snap.docs) {
        await renewLease(uid, worker);

        const data = edge.data() || {};
        const followerId = data.followerId;

        if (
          typeof followerId !== 'string' ||
          followerId.length === 0
        ) {
          throw new Error(
            `Invalid incoming follow edge: ${edge.ref.path}`,
          );
        }

        const userRef = db
          .collection('users')
          .doc(followerId);

        await db.runTransaction(async (tx) => {
          const currentEdge = await tx.get(edge.ref);

          if (!currentEdge.exists) {
            return;
          }

          const followerSnap = await tx.get(userRef);

          if (followerSnap.exists) {
            const user = followerSnap.data() || {};
            const count = user.followingCount;

            if (
              shouldDecrementFollowingCount(
                count,
                userRef.path,
              )
            ) {
              tx.update(userRef, {
                followingCount: count - 1,
              });
            }
          }

          tx.delete(edge.ref);
        });
      }
    },
  );
}

async function phaseFollows(uid, worker) {
  await removeOutgoingFollows(uid, worker);
  await removeIncomingFollows(uid, worker);
}

async function phaseProfile(uid, worker) {
  await renewLease(uid, worker);

  /*
   * Social edges have already been removed.
   * User/profile documents are now safe to remove.
   */
  const profileRef = db
    .collection('profiles')
    .doc(uid);

  const userRef = db
    .collection('users')
    .doc(uid);

  const batch = db.batch();

  batch.delete(profileRef);
  batch.delete(userRef);

  await batch.commit();
}

async function verifyNoOwnPosts(uid) {
  const snap = await db
    .collection('posts')
    .where('authorId', '==', uid)
    .limit(1)
    .get();

  return snap.empty;
}

async function verifyNoOwnComments(uid) {
  const snap = await db
    .collectionGroup('comments')
    .where('authorId', '==', uid)
    .limit(1)
    .get();

  return snap.empty;
}

async function verifyNoOwnReplies(uid) {
  const snap = await db
    .collectionGroup('replies')
    .where('authorId', '==', uid)
    .limit(1)
    .get();

  return snap.empty;
}

async function verifyNoOwnLikes(uid) {
  let found = false;

  await deleteCollectionPage(
    db.collection('posts'),
    async (postSnap) => {
      if (found) {
        return;
      }

      for (const post of postSnap.docs) {
        if (post.get('authorId') === uid) {
          continue;
        }

        const likeSnap = await post.ref
          .collection('likes')
          .doc(uid)
          .get();

        if (likeSnap.exists) {
          found = true;
          return;
        }
      }
    },
  );

  return !found;
}

async function verifyNoFollows(uid) {
  const outgoing = await db
    .collection('follows')
    .where('followerId', '==', uid)
    .limit(1)
    .get();

  if (!outgoing.empty) {
    return false;
  }

  const incoming = await db
    .collection('follows')
    .where('followeeId', '==', uid)
    .limit(1)
    .get();

  return incoming.empty;
}

async function verifyProfileGone(uid) {
  const profileSnap = await db
    .collection('profiles')
    .doc(uid)
    .get();

  const userSnap = await db
    .collection('users')
    .doc(uid)
    .get();

  return !profileSnap.exists && !userSnap.exists;
}

async function phaseVerify(uid, worker) {
  await renewLease(uid, worker);

  const [
    postsClean,
    commentsClean,
    repliesClean,
    likesClean,
    followsClean,
    profileClean,
  ] = await Promise.all([
    verifyNoOwnPosts(uid),
    verifyNoOwnComments(uid),
    verifyNoOwnReplies(uid),
    verifyNoOwnLikes(uid),
    verifyNoFollows(uid),
    verifyProfileGone(uid),
  ]);

  if (
    !postsClean ||
    !commentsClean ||
    !repliesClean ||
    !likesClean ||
    !followsClean ||
    !profileClean
  ) {
    throw new Error(
      'F3-G verification failed: residual user data exists.',
    );
  }
}

async function deleteAuthUserIfPresent(uid) {
  try {
    await auth.deleteUser(uid);
  } catch (error) {
    if (error?.code === 'auth/user-not-found') {
      return;
    }

    throw error;
  }
}

async function phaseAuth(uid, worker) {
  await renewLease(uid, worker);

  /*
   * Auth deletion is intentionally LAST.
   * If this succeeds but the process crashes before marking
   * completed, a retry safely treats user-not-found as success.
   */
  await deleteAuthUserIfPresent(uid);
}

async function processDeletion(uid) {
  const worker = await claimRequest(uid);

  if (!worker) {
    return {
      processed: false,
      uid,
    };
  }

  let phase = 'posts';

  try {
    const initial = await deletionRef(uid).get();
    const initialData = initial.data() || {};

    phase = phaseIsKnown(initialData.phase)
      ? initialData.phase
      : 'posts';

    for (
      let index = PHASES.indexOf(phase);
      index < PHASES.length;
      index += 1
    ) {
      phase = PHASES[index];

      await renewLease(uid, worker);

      switch (phase) {
        case 'posts':
          await phasePosts(uid, worker);
          break;

        case 'follows':
          await phaseFollows(uid, worker);
          break;

        case 'profile':
          await phaseProfile(uid, worker);
          break;

        case 'verify':
          await phaseVerify(uid, worker);
          break;

        case 'auth':
          await phaseAuth(uid, worker);
          break;

        default:
          throw new Error(
            `Unknown F3-G phase: ${phase}`,
          );
      }

      const followingPhase = nextPhase(phase);

      if (followingPhase) {
        await markPhase(
          uid,
          worker,
          followingPhase,
        );
      }
    }

    await markCompleted(uid, worker);

    logger.info(
      'F3-G: account deletion completed.',
      { uid },
    );

    return {
      processed: true,
      uid,
      status: 'completed',
    };
  } catch (error) {
    const retryPhase = phase === 'verify' ? 'posts' : phase;

    await markFailed(
      uid,
      worker,
      retryPhase,
      error,
    );

    logger.error(
      'F3-G: account deletion failed.',
      {
        uid,
        phase,
        error: String(error),
      },
    );

    throw error;
  }
}

exports.processAccountDeletion = onDocumentCreated(
  {
    document: 'accountDeletionRequests/{uid}',
    region: 'asia-southeast1',
    timeoutSeconds: 540,
    memory: '512MiB',
    retry: true,
  },
  async (event) => {
    const uid = event.params.uid;
    const snapshot = event.data;

    if (!snapshot) {
      logger.warn(
        'F3-G: deletion request has no snapshot.',
        { uid },
      );
      return;
    }

    const data = snapshot.data() || {};

    if (data.uid !== uid) {
      throw new Error(
        `F3-G request UID mismatch: ${uid}`,
      );
    }

    if (
      data.status !== 'pending' &&
      data.status !== 'failed' &&
      data.status !== 'processing'
    ) {
      logger.warn(
        'F3-G: unsupported initial deletion status.',
        {
          uid,
          status: data.status,
        },
      );
      return;
    }

    await processDeletion(uid);
  },
);

/*
 * Exported only for emulator/unit tests.
 * This is not a client callable endpoint.
 */
exports.__test = {
  processDeletion,
  phasePosts,
  phaseFollows,
  phaseProfile,
  phaseVerify,
  phaseAuth,
};

exports.__db = db;
