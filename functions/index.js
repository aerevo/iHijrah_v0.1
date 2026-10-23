'use strict';

const crypto = require('crypto');

const {
  onDocumentCreated,
} = require('firebase-functions/v2/firestore');

const {
  onSchedule,
} = require('firebase-functions/v2/scheduler');

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
  FieldPath,
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

function deletionStatusRef(uid) {
  return db.collection('accountDeletionStatus').doc(uid);
}

/*
 * Atomically claim the request. Resolves to:
 *
 *   { worker: <id>,  reason: 'claimed' }
 *   { worker: null,  reason: 'missing' }       no such request
 *   { worker: null,  reason: 'completed' }     nothing left to do
 *   { worker: null,  reason: 'lease-active' }  another worker owns an
 *                                              unexpired lease
 *
 * An expired lease (leaseUntil <= now) is reclaimable.
 */
async function claimRequest(uid) {
  const ref = deletionRef(uid);
  const id = workerId();

  // W6 (observability only): facts about the transaction outcome,
  // captured here and logged AFTER the transaction. They are never read
  // by any claim/reclaim decision.
  let claimedFrom = null;
  let leaseHolder = null;

  const outcome = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);

    if (!snap.exists) {
      return 'missing';
    }

    const data = snap.data() || {};

    if (data.uid !== uid) {
      throw new Error(
        `F3-G request UID mismatch for ${uid}.`,
      );
    }

    if (data.status === 'completed') {
      return 'completed';
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
      leaseHolder = {
        holderWorkerId: data.workerId,
        holderPhase: phaseIsKnown(data.phase) ? data.phase : null,
        leaseUntilMs: currentLeaseUntil,
      };

      return 'lease-active';
    }

    const phase = phaseIsKnown(data.phase)
      ? data.phase
      : 'posts';

    claimedFrom = {
      phase,
      previousStatus: status,
      previousWorkerId: data.workerId || null,
      previousLeaseUntilMs: currentLeaseUntil,
    };

    const updatedAt = new Date(nowMs() + 0);

    tx.set(
      ref,
      {
        status: 'processing',
        phase,
        workerId: id,
        leaseUntil: new Date(nowMs() + LEASE_MS),
        updatedAt,
        lastError: null,
      },
      { merge: true },
    );

    tx.set(
      deletionStatusRef(uid),
      {
        uid,
        status: 'processing',
        phase,
        updatedAt,
      },
      { merge: true },
    );

    return 'claimed';
  });

  // W6: lifecycle events. 'processing' that got past the lease check
  // above can only be an expired (or ownerless) lease => reclaim.
  if (outcome === 'claimed' && claimedFrom) {
    const reclaimed = claimedFrom.previousStatus === 'processing';

    logger.info(
      reclaimed
        ? 'F3-G: expired lease reclaimed.'
        : 'F3-G: request claimed.',
      {
        event: reclaimed ? 'reclaim' : 'claim',
        uid,
        workerId: id,
        phase: claimedFrom.phase,
        previousStatus: claimedFrom.previousStatus,
        ...(reclaimed
          ? {
              previousWorkerId: claimedFrom.previousWorkerId,
              previousLeaseUntilMs: claimedFrom.previousLeaseUntilMs,
            }
          : {}),
        leaseMs: LEASE_MS,
      },
    );

    // Anything other than a first claim continues from the persisted
    // phase (failed -> retry/resume, or an expired processing lease).
    if (claimedFrom.previousStatus !== 'pending') {
      logger.info(
        'F3-G: resuming from persisted phase.',
        {
          event: 'resume',
          uid,
          workerId: id,
          phase: claimedFrom.phase,
          previousStatus: claimedFrom.previousStatus,
        },
      );
    }
  } else if (outcome === 'lease-active' && leaseHolder) {
    logger.info(
      'F3-G: lease held by another worker.',
      {
        event: 'lease-active',
        uid,
        ...leaseHolder,
      },
    );
  }

  return {
    worker: outcome === 'claimed' ? id : null,
    reason: outcome,
  };
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

      // Only the active processing owner may transition the request to failed.
      // A stale/inconsistent workerId on a terminal document must not resurrect it.
      if (data.status !== 'processing' || data.workerId !== id) {
        return;
      }

      const updatedAt = new Date();

      tx.update(ref, {
        status: 'failed',
        phase,
        workerId: null,
        leaseUntil: null,
        updatedAt,
        lastError: String(error?.message || error),
      });

      tx.set(
        deletionStatusRef(uid),
        {
          uid,
          status: 'failed',
          phase,
          updatedAt,
        },
        { merge: true },
      );
    });
  } catch (markError) {
    logger.error(
      'F3-G: failed to persist failure state.',
      {
        event: 'failure-persist-failed',
        uid,
        workerId: id,
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

    const completedAt = new Date();

    tx.update(ref, {
      status: 'completed',
      phase: 'completed',
      workerId: null,
      leaseUntil: null,
      completedAt,
      updatedAt: completedAt,
      lastError: null,
    });

    tx.set(
      deletionStatusRef(uid),
      {
        uid,
        status: 'completed',
        phase: 'completed',
        completedAt,
        updatedAt: completedAt,
      },
      { merge: true },
    );
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
  const claim = await claimRequest(uid);
  const worker = claim.worker;

  if (!worker) {
    return {
      processed: false,
      uid,
      reason: claim.reason,
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

        logger.info(
          'F3-G: phase completed.',
          {
            event: 'phase-complete',
            uid,
            workerId: worker,
            phase,
            nextPhase: followingPhase,
          },
        );
      }
    }

    await markCompleted(uid, worker);

    logger.info(
      'F3-G: account deletion completed.',
      {
        event: 'completion',
        uid,
        workerId: worker,
      },
    );

    return {
      processed: true,
      uid,
      status: 'completed',
    };
  } catch (error) {
    const retryPhase = phase === 'verify' ? 'posts' : phase;

    if (error instanceof LeaseLostError) {
      logger.warn(
        'F3-G: worker lease lost.',
        {
          event: 'lease-lost',
          uid,
          workerId: worker,
          phase,
        },
      );
    }

    await markFailed(
      uid,
      worker,
      retryPhase,
      error,
    );

    logger.error(
      'F3-G: account deletion failed.',
      {
        event: 'failure',
        uid,
        workerId: worker,
        phase,
        retryPhase,
        error: String(error),
      },
    );

    throw error;
  }
}

/*
 * Trigger entry point (W5).
 *
 * processDeletion() resolves { processed: false } when another worker
 * holds an UNEXPIRED lease. If the handler simply returned in that
 * case, the event would count as successful and Cloud Functions would
 * stop retrying: a worker that crashed or hit the 540s timeout while
 * its lease was still active (LEASE_MS is 10 minutes, renewed during
 * work) would leave the request 'processing' forever, because this
 * trigger only fires on create.
 *
 * Throwing instead makes Cloud Functions retry (retry: true, backoff
 * 10-600s, 24h window) until the lease expires and a retry can reclaim
 * the request, or the owner finishes ('completed' => no error).
 *
 * Only 'lease-active' is retried; 'completed' and 'missing' are final.
 */
async function processDeletionOrRetry(uid) {
  const result = await processDeletion(uid);

  if (
    result.processed === false &&
    result.reason === 'lease-active'
  ) {
    logger.warn(
      'F3-G: deletion lease held by another worker; retrying.',
      {
        event: 'lease-retry',
        uid,
      },
    );

    throw new Error(
      `F3-G deletion lease for ${uid} is held by another worker.`,
    );
  }

  return result;
}

/*
 * D3 scheduled recovery.
 *
 * Each group is bounded by RECOVERY_BATCH_LIMIT and ordered oldest-first
 * so a handful of permanently failing requests cannot occupy the whole
 * window forever (starvation):
 *
 *   pending            createdAt  ASC  (rules guarantee createdAt)
 *   failed             updatedAt  ASC  (claim/markFailed always set
 *                                       updatedAt, so a request that was
 *                                       just retried moves to the back)
 *   expired processing leaseUntil ASC  (inequality field must be the
 *                                       first orderBy)
 *
 * Every ordered group needs a composite index (see
 * firestore.indexes.json). Indexes MUST exist before this code is
 * deployed, otherwise the affected group fails with FAILED_PRECONDITION
 * (isolated and reported below, but not recovered).
 *
 * COMPLETENESS: Firestore silently EXCLUDES documents that lack the
 * orderBy field. A pending request without createdAt, a failed request
 * without updatedAt, or a processing request without leaseUntil (Admin-written,
 * legacy or manually seeded) would never be recovered by the ordered queries.
 * Each status therefore has a fallback that does not depend on those fields:
 * it pages through ALL requests of that status in
 * document-id order, RECOVERY_FALLBACK_LIMIT per run, using a persisted
 * cursor (accountDeletionRecoveryState/cursors, Admin-only: the
 * catch-all rule denies clients).
 *
 * Cursor semantics. Each point below says what is and is NOT guaranteed;
 * the tests in functions/test/deletion_recovery_lease.unit.test.js are
 * labelled by evidence level: [unit/fake] = in-memory Firestore fake,
 * [sdk-offline/scripted] = real SDK with a scripted RPC layer. NONE of
 * them is evidence from a real Firestore server.
 *
 *  - Position, not completion. The cursor is the id of the last fallback
 *    request this algorithm CHECKPOINTED, and it is moved by a
 *    compare-and-set transaction immediately BEFORE that request's
 *    process() call. Merely "discovered" (returned by a query) never moves
 *    it, so nothing AFTER the cursor is ever skipped because a run died.
 *
 *  - NOT guaranteed: that a checkpointed request was attempted. If the
 *    instance is killed, times out or crashes after the checkpoint commits
 *    and before process() runs, the cursor sits at that request although
 *    it was never attempted. It is skipped for the rest of the cycle and is
 *    attempted again only when the cursor next reaches it, about one full
 *    cycle later. The last request of a short page is the same case with
 *    the cursor already wrapped to the start. (The ordered lanes are
 *    unaffected: they do not use the cursor.)
 *
 *  - Poison requests. Because the checkpoint precedes the attempt, a
 *    request that repeatedly kills the run is skipped on the next run
 *    instead of pinning the cursor forever.
 *
 *  - Attempted is not succeeded. A failed attempt leaves the request
 *    failed/pending, so it is found again on the next cycle.
 *
 *  - Overlapping runs. Every move is a compare-and-set (expected previous
 *    value -> new value) inside a Firestore transaction. A run holding a
 *    stale value cannot overwrite a cursor that differs from the value it
 *    read: its CAS fails and it abandons the rest of its fallback page.
 *    This relies on Firestore transactions being serializable (documented
 *    by Google; not verified here). The cursor does NOT prevent two runs
 *    from attempting the same request through the ORDERED lanes, and no
 *    proof excludes it in the fallback lane either; claimRequest()'s lease
 *    is what makes a duplicate attempt safe.
 *
 *  - Coverage bound. Only when there are no crashes, lost CAS races or
 *    cursor read/write failures: every request of a status that exists for
 *    a whole cycle is attempted within ceil(N / RECOVERY_FALLBACK_LIMIT) + 1
 *    consecutive runs (a short or empty page wraps the cursor). Each
 *    crash, lost CAS or cursor failure can delay particular requests by up
 *    to one further cycle. There is no bound while the cursor document is
 *    unreadable or unwritable; that state is reported as degraded.
 *    A request created behind the cursor is reached after the next wrap.
 *
 *  - Lanes are processed round-robin, so a run that is cut short has still
 *    given every lane some turns.
 *
 * Results are de-duplicated by uid. Equality on status plus __name__ ASC
 * is ASSUMED, from Google's index documentation, to be served by the
 * built-in single-field index; this is unverified and must be confirmed on
 * a real Firestore project.
 * (An expired-processing request without a leaseUntil timestamp is
 * likewise invisible to the lease query; that gap predates this change.)
 */
const RECOVERY_BATCH_LIMIT = 50;
const RECOVERY_FALLBACK_LIMIT = 20;
// Bound work so one scheduler invocation cannot spend its full timeout
// processing a large backlog. Cursor checkpoints preserve forward progress.
const RECOVERY_MAX_ATTEMPTS_PER_RUN = 80;
const RECOVERY_RUN_BUDGET_MS = 7 * 60 * 1000;

// A cursor is a plain document id. Anything else (wrong type, empty, or
// containing '/', which the SDK rejects when building the query) is
// treated as "start from the beginning" so a corrupt value self-heals.
const normalizeCursor = (value) =>
  typeof value === 'string' && value.length > 0 && !value.includes('/')
    ? value
    : null;

function fallbackQuery(requests, status, after, documentId = FieldPath.documentId()) {
  let query = requests
    .where('status', '==', status)
    .orderBy(documentId);

  const cursor = normalizeCursor(after);

  if (cursor !== null) {
    query = query.startAfter(cursor);
  }

  return query.limit(RECOVERY_FALLBACK_LIMIT);
}

function recoveryQueryGroups(
  now,
  cursors = {},
  requests = () => db.collection('accountDeletionRequests'),
) {

  return [
    {
      name: 'pending',
      build: () =>
        requests()
          .where('status', '==', 'pending')
          .orderBy('createdAt', 'asc')
          .limit(RECOVERY_BATCH_LIMIT),
    },
    {
      name: 'failed',
      build: () =>
        requests()
          .where('status', '==', 'failed')
          .orderBy('updatedAt', 'asc')
          .limit(RECOVERY_BATCH_LIMIT),
    },
    {
      name: 'expired-processing',
      build: () =>
        requests()
          .where('status', '==', 'processing')
          .where('leaseUntil', '<=', now)
          .orderBy('leaseUntil', 'asc')
          .limit(RECOVERY_BATCH_LIMIT),
    },
    {
      name: 'pending-fallback',
      rotating: true,
      cursorField: 'pendingFallback',
      build: () =>
        fallbackQuery(requests(), 'pending', cursors.pendingFallback),
    },
    {
      name: 'failed-fallback',
      rotating: true,
      cursorField: 'failedFallback',
      build: () =>
        fallbackQuery(requests(), 'failed', cursors.failedFallback),
    },
    {
      name: 'processing-fallback',
      rotating: true,
      cursorField: 'processingFallback',
      build: () =>
        fallbackQuery(requests(), 'processing', cursors.processingFallback),
    },
  ];
}

/*
 * Compare-and-set of one cursor field. Returns true only if the stored
 * value still equals `expected` and was replaced by `next`.
 */
async function advanceRecoveryCursor(
  cursorRef,
  field,
  expected,
  next,
  database = db,
) {
  return database.runTransaction(async (tx) => {
    const snap = await tx.get(cursorRef);
    const stored = snap.exists ? (snap.data() || {})[field] : null;

    if (normalizeCursor(stored) !== normalizeCursor(expected)) {
      return false;
    }

    tx.set(
      cursorRef,
      { [field]: next, updatedAt: new Date() },
      { merge: true },
    );

    return true;
  });
}

/*
 * `process` is injectable for tests only; production always uses
 * processDeletionOrRetry.
 */
async function runScheduledDeletionRecovery({
  process = processDeletionOrRetry,
} = {}) {
  const now = new Date();
  const queryFailures = [];
  const cursorRef = db
    .collection('accountDeletionRecoveryState')
    .doc('cursors');

  // null = unreadable: the rotating fallback lanes are skipped this run
  // (we cannot compare-and-set against an unknown value) and the run is
  // reported as degraded. Ordered lanes still run.
  let cursors = null;

  try {
    const cursorSnap = await cursorRef.get();
    cursors = cursorSnap.exists ? cursorSnap.data() || {} : {};
  } catch (error) {
    queryFailures.push('cursor-read');
    logger.error(
      'D3: scheduled recovery cursor read failed.',
      {
        event: 'scheduled-recovery-cursor-read-failed',
        error: String(error),
      },
    );
  }

  const groups = recoveryQueryGroups(now, cursors || {});
  const active = groups.filter((group) => !(group.rotating && cursors === null));

  // allSettled: one failing query must not discard the others. The
  // async wrapper also turns a synchronous throw while building a query
  // into a rejection of that group only.
  const settled = await Promise.allSettled(
    active.map(async (group) => group.build().get()),
  );

  const lanes = [];

  settled.forEach((result, index) => {
    const group = active[index];

    if (result.status === 'rejected') {
      queryFailures.push(group.name);

      logger.error(
        'D3: scheduled recovery query failed.',
        {
          event: 'scheduled-recovery-query-failure',
          query: group.name,
          error: String(result.reason),
        },
      );

      return;
    }

    const docs = result.value.docs;
    // The processing fallback must include documents with no leaseUntil,
    // but it also sees processing documents whose lease is still active.
    // Keep those ids in the lane so the cursor can advance past them, while
    // preventing them from becoming recovery attempts in this run.
    const skipUids = new Set(
      group.name === 'processing-fallback'
        ? docs
            .filter((doc) => {
              const leaseUntil = (doc.data() || {}).leaseUntil;
              const leaseUntilMs = leaseUntil instanceof Date
                ? leaseUntil.getTime()
                : timestampMs(leaseUntil);
              return leaseUntilMs > now.getTime();
            })
            .map((doc) => doc.id)
        : [],
    );

    lanes.push({
      name: group.name,
      cursorField: group.cursorField,
      rotating: Boolean(group.rotating),
      uids: docs.map((doc) => doc.id),
      skipUids,
      pageFull: docs.length >= RECOVERY_FALLBACK_LIMIT,
      previous: group.rotating
        ? normalizeCursor((cursors || {})[group.cursorField])
        : null,
      abandoned: false,
    });
  });

  let cursorWriteFailed = false;

  // Returns true if this run still owns the lane's cursor after the move.
  async function moveCursor(lane, next) {
    try {
      const moved = await advanceRecoveryCursor(
        cursorRef,
        lane.cursorField,
        lane.previous,
        next,
      );

      if (moved) {
        lane.previous = next;
        return true;
      }

      logger.info(
        'D3: scheduled recovery cursor moved by another run; abandoning page.',
        { event: 'scheduled-recovery-cursor-lost', lane: lane.name },
      );
    } catch (error) {
      if (!cursorWriteFailed) {
        cursorWriteFailed = true;
        queryFailures.push('cursor-write');
      }
      logger.error(
        'D3: scheduled recovery cursor move failed.',
        {
          event: 'scheduled-recovery-cursor-write-failed',
          lane: lane.name,
          error: String(error),
        },
      );
    }

    lane.abandoned = true;
    return false;
  }

  // An empty page after a non-empty cursor means the end was reached.
  for (const lane of lanes) {
    if (lane.rotating && lane.uids.length === 0 && lane.previous !== null) {
      await moveCursor(lane, null);
    }
  }

  const discovered = new Set();
  for (const lane of lanes) {
    for (const uid of lane.uids) {
      if (!lane.skipUids.has(uid)) discovered.add(uid);
    }
  }

  logger.info(
    'D3: scheduled account deletion recovery scan.',
    {
      event: 'scheduled-recovery-scan',
      candidateCount: discovered.size,
      queryFailureCount: queryFailures.length,
    },
  );

  const attempted = new Set();
  let processErrors = 0;
  let leaseConflicts = 0;
  const startedAt = Date.now();
  const position = lanes.map(() => 0);
  let remaining = true;

  // Round-robin across lanes so no lane (notably the rotating fallback
  // lanes) is starved if a run is cut short.
  while (remaining) {
    if (attempted.size >= RECOVERY_MAX_ATTEMPTS_PER_RUN ||
        Date.now() - startedAt >= RECOVERY_RUN_BUDGET_MS) {
      logger.warn(
        'D3: scheduled recovery reached its per-run work budget.',
        { event: 'scheduled-recovery-budget-reached', attempted: attempted.size },
      );
      break;
    }
    remaining = false;

    for (let i = 0; i < lanes.length; i += 1) {
      if (attempted.size >= RECOVERY_MAX_ATTEMPTS_PER_RUN ||
          Date.now() - startedAt >= RECOVERY_RUN_BUDGET_MS) {
        break;
      }
      const lane = lanes[i];

      if (lane.abandoned || position[i] >= lane.uids.length) {
        continue;
      }

      remaining = true;

      const uid = lane.uids[position[i]];
      position[i] += 1;
      const isLast = position[i] === lane.uids.length;

      if (lane.rotating) {
        // Checkpoint BEFORE the attempt (see "Cursor semantics": a crash
        // between this commit and process() skips this request until the
        // next cycle).
        const next = isLast && !lane.pageFull ? null : uid;

        if (!(await moveCursor(lane, next))) {
          continue;
        }
      }

      // Still checkpoint active-lease ids in a rotating fallback lane, but
      // never call process() for them. The ordered lease query only returns
      // expired leases; this fallback exists to catch missing leaseUntil.
      if (lane.skipUids.has(uid) || attempted.has(uid)) {
        continue;
      }

      attempted.add(uid);

      try {
        await process(uid);
      } catch (error) {
        // A live lease conflict is expected when trigger/scheduler runs overlap.
        // Do not treat it as a failed deletion attempt for scheduler health.
        if (String(error?.message || error).includes(`deletion lease for ${uid} is held by another worker`)) {
          leaseConflicts += 1;
          logger.info('D3: recovery skipped request with active lease.', {
            event: 'scheduled-recovery-lease-active', uid,
          });
          continue;
        }

        processErrors += 1;

        logger.error(
          'D3: scheduled account deletion recovery failed.',
          {
            event: 'scheduled-recovery-failure',
            uid,
            error: String(error),
          },
        );
      }
    }
  }

  if (queryFailures.length > 0) {
    // Distinct, alertable event for log-based monitoring.
    logger.error(
      'D3: scheduled recovery finished with query failures.',
      {
        event: 'scheduled-recovery-degraded',
        failedQueries: queryFailures,
        totalQueries: groups.length,
        scanned: discovered.size,
        processErrors,
        leaseConflicts,
      },
    );
  }

  return {
    scanned: discovered.size,
    queryFailures,
    processErrors,
    leaseConflicts,
  };
}

/*
 * Scheduler entry point. Candidates from healthy queries are processed
 * first (above); only then does a degraded run fail, so the failure is
 * visible in Cloud Scheduler / function error metrics without losing
 * recoverable work.
 */
async function recoveryHandler(options = {}) {
  const result = await runScheduledDeletionRecovery(options);

  if (result.queryFailures.length > 0) {
    throw new Error(
      `D3: ${result.queryFailures.length} recovery query(ies) failed: ` +
        result.queryFailures.join(', '),
    );
  }

  if (result.processErrors > 0) {
    throw new Error(
      `D3: ${result.processErrors} recovery processing attempt(s) failed.`,
    );
  }
}

exports.recoverAccountDeletions = onSchedule(
  {
    schedule: "every 5 minutes",
    timeZone: "Asia/Kuala_Lumpur",
    region: "asia-southeast1",
    timeoutSeconds: 540,
    memory: "512MiB",
    retryCount: 3,
  },
  async () => {
    await recoveryHandler();
  },
);

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

    await processDeletionOrRetry(uid);
  },
);

/*
 * Exported only for emulator/unit tests.
 * This is not a client callable endpoint.
 */
exports.__test = {
  claimRequest,
  renewLease,
  markPhase,
  markFailed,
  markCompleted,
  recoveryHandler,
  recoveryQueryGroups,
  fallbackQuery,
  advanceRecoveryCursor,
  runScheduledDeletionRecovery,
  processDeletion,
  processDeletionOrRetry,
  phasePosts,
  phaseFollows,
  phaseProfile,
  phaseVerify,
  phaseAuth,
};

exports.__db = db;
