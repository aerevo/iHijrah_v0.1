const test = require('node:test');
const assert = require('node:assert/strict');

process.env.FIRESTORE_EMULATOR_HOST =
  process.env.FIRESTORE_EMULATOR_HOST || '127.0.0.1:8080';

process.env.FIREBASE_AUTH_EMULATOR_HOST =
  process.env.FIREBASE_AUTH_EMULATOR_HOST || '127.0.0.1:9099';

process.env.GCLOUD_PROJECT =
  process.env.GCLOUD_PROJECT || 'ihijrah-178fc';

const {
  __db: db,
  __test,
} = require('../index');

const {
  processDeletion,
} = __test;

const {
  getAuth,
} = require('firebase-admin/auth');

const auth = getAuth();

async function deleteDocTree(ref) {
  const snap = await ref.get();

  if (!snap.exists) {
    return;
  }

  for (const collection of ['likes', 'comments']) {
    const childSnap = await ref.collection(collection).get();

    for (const child of childSnap.docs) {
      if (collection === 'comments') {
        const replies = await child.ref.collection('replies').get();

        for (const reply of replies.docs) {
          await reply.ref.delete();
        }
      }

      await child.ref.delete();
    }
  }

  await ref.delete();
}

async function assertMissing(path) {
  const snap = await db.doc(path).get();
  assert.equal(
    snap.exists,
    false,
    `Expected ${path} to be deleted`,
  );
}

test(
  'F3-G: complete account deletion removes all owned social data and Auth user',
  async () => {
    const uid = 'f3g-user';
    const otherUid = 'f3g-other';
    const thirdUid = 'f3g-third';

    /*
     * Clean up possible leftovers from an interrupted local run.
     */
    for (const id of [uid, otherUid, thirdUid]) {
      try {
        await auth.deleteUser(id);
      } catch (error) {
        if (error?.code !== 'auth/user-not-found') {
          throw error;
        }
      }
    }

    /*
     * Auth users.
     */
    await auth.createUser({
      uid,
      email: 'f3g-user@example.com',
      password: 'Password123!',
    });

    await auth.createUser({
      uid: otherUid,
      email: 'f3g-other@example.com',
      password: 'Password123!',
    });

    await auth.createUser({
      uid: thirdUid,
      email: 'f3g-third@example.com',
      password: 'Password123!',
    });

    /*
     * User/profile documents.
     */
    await db.collection('users').doc(uid).set({
      uid,
      displayName: 'F3G User',
      followingCount: 1,
    });

    await db.collection('users').doc(otherUid).set({
      uid: otherUid,
      displayName: 'F3G Other',
      followingCount: 1,
    });

    await db.collection('users').doc(thirdUid).set({
      uid: thirdUid,
      displayName: 'F3G Third',
      followingCount: 0,
    });

    await db.collection('profiles').doc(uid).set({
      uid,
      followersCount: 1,
    });

    await db.collection('profiles').doc(otherUid).set({
      uid: otherUid,
      followersCount: 0,
    });

    /*
     * Own post with nested comment, reply and like.
     */
    const ownPost = db.collection('posts').doc('f3g-own-post');

    await ownPost.set({
      type: 'text',
      title: 'Own post',
      content: 'This belongs to the deleting user.',
      author: 'F3G User',
      authorId: uid,
      likes: 1,
      commentsCount: 1,
      category: 'general',
      createdAt: new Date(),
    });

    const ownComment = ownPost.collection('comments').doc('own-comment');

    await ownComment.set({
      authorId: otherUid,
      author: 'F3G Other',
      content: 'Comment on own post',
      createdAt: new Date(),
    });

    await ownComment.collection('replies').doc('own-reply').set({
      authorId: uid,
      author: 'F3G User',
      content: 'Own reply',
      createdAt: new Date(),
    });

    await ownPost.collection('likes').doc(uid).set({
      createdAt: new Date(),
    });

    /*
     * Other user's post.
     */
    const otherPost = db.collection('posts').doc('f3g-other-post');

    await otherPost.set({
      type: 'text',
      title: 'Other post',
      content: 'This belongs to another user.',
      author: 'F3G Other',
      authorId: otherUid,
      likes: 1,
      commentsCount: 1,
      category: 'general',
      createdAt: new Date(),
    });

    /*
     * User's own comment on somebody else's post.
     */
    const userComment = otherPost
      .collection('comments')
      .doc('user-comment');

    await userComment.set({
      authorId: uid,
      author: 'F3G User',
      content: 'Own comment on other post',
      createdAt: new Date(),
    });

    /*
     * User's own reply on somebody else's comment.
     */
    await userComment.collection('replies').doc('user-reply').set({
      authorId: uid,
      author: 'F3G User',
      content: 'Own reply',
      createdAt: new Date(),
    });

    /*
     * User's own like on somebody else's post.
     */
    await otherPost.collection('likes').doc(uid).set({
      createdAt: new Date(),
    });

    /*
     * Follow relationships.
     *
     * uid -> otherUid
     * thirdUid -> uid
     */
    await db
      .collection('follows')
      .doc(`${uid}_${otherUid}`)
      .set({
        followerId: uid,
        followeeId: otherUid,
        createdAt: new Date(),
      });

    await db
      .collection('follows')
      .doc(`${thirdUid}_${uid}`)
      .set({
        followerId: thirdUid,
        followeeId: uid,
        createdAt: new Date(),
      });

    /*
     * Correct aggregate counters before deletion.
     */
    await db.collection('profiles').doc(otherUid).update({
      followersCount: 1,
    });

    await db.collection('users').doc(thirdUid).update({
      followingCount: 1,
    });

    /*
     * Durable deletion request.
     */
    await db
      .collection('accountDeletionRequests')
      .doc(uid)
      .set({
        uid,
        status: 'pending',
        createdAt: new Date(),
      });

    /*
     * Execute the actual backend worker.
     */
    await processDeletion(uid);

    /*
     * Request must finish completed.
     */
    const request = await db
      .collection('accountDeletionRequests')
      .doc(uid)
      .get();

    assert.equal(request.exists, true);
    assert.equal(request.data().status, 'completed');
    assert.equal(request.data().phase, 'completed');

    /*
     * Own post and its complete nested tree are gone.
     */
    await assertMissing('posts/f3g-own-post');
    await assertMissing(
      'posts/f3g-own-post/comments/own-comment',
    );
    await assertMissing(
      'posts/f3g-own-post/comments/own-comment/replies/own-reply',
    );
    await assertMissing(
      'posts/f3g-own-post/likes/f3g-user',
    );

    /*
     * Own comment/reply on another user's post are gone.
     */
    await assertMissing(
      'posts/f3g-other-post/comments/user-comment',
    );
    await assertMissing(
      'posts/f3g-other-post/comments/user-comment/replies/user-reply',
    );

    /*
     * Own like on another user's post is gone and counter decremented.
     */
    await assertMissing(
      'posts/f3g-other-post/likes/f3g-user',
    );

    const remainingPost = await otherPost.get();

    assert.equal(remainingPost.exists, true);
    assert.equal(remainingPost.data().likes, 0);
    assert.equal(remainingPost.data().commentsCount, 0);

    /*
     * Other user's content remains intact.
     */
    assert.equal(
      remainingPost.data().authorId,
      otherUid,
    );

    const otherComment = await otherPost
      .collection('comments')
      .doc('f3g-comment-does-not-exist')
      .get();

    assert.equal(otherComment.exists, false);

    /*
     * Outgoing and incoming follows are gone.
     */
    await assertMissing(
      `follows/${uid}_${otherUid}`,
    );

    await assertMissing(
      `follows/${thirdUid}_${uid}`,
    );

    /*
     * Aggregate counters updated.
     */
    const otherProfile = await db
      .collection('profiles')
      .doc(otherUid)
      .get();

    assert.equal(
      otherProfile.data().followersCount,
      0,
    );

    const thirdUser = await db
      .collection('users')
      .doc(thirdUid)
      .get();

    assert.equal(
      thirdUser.data().followingCount,
      0,
    );

    /*
     * User/profile documents removed.
     */
    await assertMissing(`users/${uid}`);
    await assertMissing(`profiles/${uid}`);

    /*
     * Auth account removed.
     */
    await assert.rejects(
      () => auth.getUser(uid),
      (error) => error?.code === 'auth/user-not-found',
    );

    /*
     * Other users remain.
     */
    const otherAuth = await auth.getUser(otherUid);
    assert.equal(otherAuth.uid, otherUid);

    const thirdAuth = await auth.getUser(thirdUid);
    assert.equal(thirdAuth.uid, thirdUid);
  },
);

/*
 * ---------------------------------------------------------------------
 * commentsCount semantics during account deletion
 *
 * firestore.rules keep posts.commentsCount at 0 (clients never bump it),
 * so real posts can have comments while commentsCount === 0. Account
 * deletion must still delete those comments:
 *
 *   commentsCount integer >= 1 -> decrement + delete comment
 *   commentsCount === 0        -> delete comment, counter stays 0
 *   anything else              -> throw (corrupt data is not repaired)
 * ---------------------------------------------------------------------
 */

async function ensureAuthUser(uid) {
  try {
    await auth.deleteUser(uid);
  } catch (error) {
    if (error?.code !== 'auth/user-not-found') {
      throw error;
    }
  }

  await auth.createUser({
    uid,
    email: `${uid}@example.com`,
    password: 'Password123!',
  });
}

async function cleanupCountScenario({ uids, postIds }) {
  for (const postId of postIds) {
    await deleteDocTree(db.collection('posts').doc(postId));
  }

  for (const uid of uids) {
    await db.collection('accountDeletionRequests').doc(uid).delete();
    await db.collection('users').doc(uid).delete();
    await db.collection('profiles').doc(uid).delete();

    try {
      await auth.deleteUser(uid);
    } catch (error) {
      if (error?.code !== 'auth/user-not-found') {
        throw error;
      }
    }
  }
}

async function seedUserDocs(uid) {
  await db.collection('users').doc(uid).set({
    uid,
    displayName: uid,
    followingCount: 0,
  });

  await db.collection('profiles').doc(uid).set({
    uid,
    followersCount: 0,
  });
}

async function requestDeletion(uid) {
  await db
    .collection('accountDeletionRequests')
    .doc(uid)
    .set({
      uid,
      status: 'pending',
      createdAt: new Date(),
    });
}

test(
  'F3-G: account deletion succeeds when posts have commentsCount 0 but real comments',
  async () => {
    const uid = 'f3g-zero-user';
    const otherUid = 'f3g-zero-other';
    const scenario = {
      uids: [uid, otherUid],
      postIds: ['f3g-zero-own-post', 'f3g-zero-other-post'],
    };

    await cleanupCountScenario(scenario);

    try {
      await ensureAuthUser(uid);
      await ensureAuthUser(otherUid);
      await seedUserDocs(uid);
      await seedUserDocs(otherUid);

      /*
       * Other user's post: commentsCount is 0 (what rules enforce) yet it
       * holds the deleting user's comment + reply and another user's comment.
       */
      const otherPost = db.collection('posts').doc('f3g-zero-other-post');

      await otherPost.set({
        type: 'article',
        title: 'Other post',
        content: 'Post by another user, commentsCount 0.',
        author: 'Other',
        authorId: otherUid,
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: new Date(),
      });

      const userComment = otherPost
        .collection('comments')
        .doc('zero-user-comment');

      await userComment.set({
        authorId: uid,
        author: uid,
        content: 'Comment by the deleting user',
        createdAt: new Date(),
      });

      await userComment.collection('replies').doc('zero-user-reply').set({
        authorId: uid,
        author: uid,
        content: 'Reply by the deleting user',
        createdAt: new Date(),
      });

      await otherPost.collection('comments').doc('zero-other-comment').set({
        authorId: otherUid,
        author: otherUid,
        content: 'Comment by someone else',
        createdAt: new Date(),
      });

      /*
       * Deleting user's own post: commentsCount 0 with another user's
       * comment underneath (deleteNestedPost path).
       */
      const ownPost = db.collection('posts').doc('f3g-zero-own-post');

      await ownPost.set({
        type: 'article',
        title: 'Own post',
        content: 'Post by the deleting user, commentsCount 0.',
        author: uid,
        authorId: uid,
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: new Date(),
      });

      await ownPost.collection('comments').doc('zero-own-comment').set({
        authorId: otherUid,
        author: otherUid,
        content: 'Someone else commented on the deleting user post',
        createdAt: new Date(),
      });

      await requestDeletion(uid);

      /*
       * Must NOT throw "Invalid commentsCount".
       */
      await processDeletion(uid);

      const request = await db
        .collection('accountDeletionRequests')
        .doc(uid)
        .get();

      assert.equal(request.data().status, 'completed');
      assert.equal(request.data().phase, 'completed');

      /*
       * The deleting user's comment + reply are gone.
       */
      await assertMissing(
        'posts/f3g-zero-other-post/comments/zero-user-comment',
      );
      await assertMissing(
        'posts/f3g-zero-other-post/comments/zero-user-comment/replies/zero-user-reply',
      );

      /*
       * Deleting user's own post and its nested comment are gone.
       */
      await assertMissing('posts/f3g-zero-own-post');
      await assertMissing(
        'posts/f3g-zero-own-post/comments/zero-own-comment',
      );

      /*
       * Other user's post remains, counter stays exactly 0 (not -1).
       */
      const remaining = await otherPost.get();

      assert.equal(remaining.exists, true);
      assert.strictEqual(remaining.data().commentsCount, 0);
      assert.equal(remaining.data().authorId, otherUid);

      const otherComment = await otherPost
        .collection('comments')
        .doc('zero-other-comment')
        .get();

      assert.equal(otherComment.exists, true);

      /*
       * Account fully removed; other user untouched.
       */
      await assertMissing(`users/${uid}`);
      await assertMissing(`profiles/${uid}`);

      await assert.rejects(
        () => auth.getUser(uid),
        (error) => error?.code === 'auth/user-not-found',
      );

      assert.equal((await auth.getUser(otherUid)).uid, otherUid);
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);

test(
  'F3-G: commentsCount >= 1 is still decremented when the comment is deleted',
  async () => {
    const uid = 'f3g-pos-user';
    const otherUid = 'f3g-pos-other';
    const scenario = {
      uids: [uid, otherUid],
      postIds: ['f3g-pos-other-post'],
    };

    await cleanupCountScenario(scenario);

    try {
      await ensureAuthUser(uid);
      await ensureAuthUser(otherUid);
      await seedUserDocs(uid);
      await seedUserDocs(otherUid);

      const otherPost = db.collection('posts').doc('f3g-pos-other-post');

      await otherPost.set({
        type: 'article',
        title: 'Other post',
        content: 'Post by another user, commentsCount 2.',
        author: 'Other',
        authorId: otherUid,
        likes: 0,
        commentsCount: 2,
        assetPath: null,
        category: null,
        createdAt: new Date(),
      });

      await otherPost.collection('comments').doc('pos-user-comment').set({
        authorId: uid,
        author: uid,
        content: 'Comment by the deleting user',
        createdAt: new Date(),
      });

      await otherPost.collection('comments').doc('pos-other-comment').set({
        authorId: otherUid,
        author: otherUid,
        content: 'Comment by someone else',
        createdAt: new Date(),
      });

      await requestDeletion(uid);
      await processDeletion(uid);

      await assertMissing('posts/f3g-pos-other-post/comments/pos-user-comment');

      const remaining = await otherPost.get();

      assert.strictEqual(remaining.data().commentsCount, 1);
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);

const MISSING = Symbol('missing');

for (const [label, badValue] of [
  ['negative integer', -1],
  ['string', '1'],
  ['null', null],
  ['missing field', MISSING],
]) {
  test(
    `F3-G: invalid commentsCount (${label}) fails deletion and is NOT repaired`,
    async () => {
      const key = label.replace(/\W+/g, '-');
      const uid = `f3g-bad-${key}-user`;
      const otherUid = `f3g-bad-${key}-other`;
      const postId = `f3g-bad-${key}-post`;
      const scenario = { uids: [uid, otherUid], postIds: [postId] };

      await cleanupCountScenario(scenario);

      try {
        await ensureAuthUser(uid);
        await ensureAuthUser(otherUid);
        await seedUserDocs(uid);
        await seedUserDocs(otherUid);

        const post = {
          type: 'article',
          title: 'Corrupt counter post',
          content: 'Post with an invalid commentsCount.',
          author: 'Other',
          authorId: otherUid,
          likes: 0,
          assetPath: null,
          category: null,
          createdAt: new Date(),
        };

        if (badValue !== MISSING) {
          post.commentsCount = badValue;
        }

        const postRef = db.collection('posts').doc(postId);

        await postRef.set(post);

        await postRef.collection('comments').doc('bad-user-comment').set({
          authorId: uid,
          author: uid,
          content: 'Comment by the deleting user',
          createdAt: new Date(),
        });

        await requestDeletion(uid);

        await assert.rejects(
          () => processDeletion(uid),
          /Invalid commentsCount/,
        );

        const request = await db
          .collection('accountDeletionRequests')
          .doc(uid)
          .get();

        assert.equal(request.data().status, 'failed');
        assert.match(request.data().lastError, /Invalid commentsCount/);

        /*
         * Nothing was deleted or silently repaired.
         */
        assert.equal(
          (await postRef.collection('comments').doc('bad-user-comment').get())
            .exists,
          true,
        );

        const after = (await postRef.get()).data();

        if (badValue === MISSING) {
          assert.equal('commentsCount' in after, false);
        } else {
          assert.deepStrictEqual(after.commentsCount, badValue);
        }

        assert.equal((await auth.getUser(uid)).uid, uid);
      } finally {
        await cleanupCountScenario(scenario);
      }
    },
  );
}

/*
 * ---------------------------------------------------------------------
 * users.followingCount semantics for INCOMING follows during deletion
 *
 * The production follow flow never maintains users.followingCount
 * (setFollowing only changes profiles.followersCount; rules keep the
 * field at 0 and clients cannot change it), so a follower's counter is
 * normally 0. The first F3-G test above seeds followingCount: 1 on the
 * follower (kept: it still covers the decrement path). These tests use
 * the production-realistic value.
 *
 *   integer >= 1 -> decrement + delete edge   (first F3-G test)
 *   integer === 0 -> delete edge, counter stays 0
 *   anything else -> throw; corrupt data is neither repaired nor hidden
 * ---------------------------------------------------------------------
 */

test(
  'F3-G: incoming follow with follower followingCount 0 (production-realistic) is removed and deletion completes',
  async () => {
    const uid = 'f3g-fol0-target';
    const followerUid = 'f3g-fol0-follower';
    const followeeUid = 'f3g-fol0-followee';
    const scenario = {
      uids: [uid, followerUid, followeeUid],
      postIds: [],
    };

    await cleanupCountScenario(scenario);
    await db.collection('follows').doc(`${followerUid}_${uid}`).delete();
    await db.collection('follows').doc(`${uid}_${followeeUid}`).delete();

    try {
      await ensureAuthUser(uid);
      await ensureAuthUser(followerUid);
      await ensureAuthUser(followeeUid);

      // followingCount = 0 on EVERY user: what production actually stores.
      await seedUserDocs(uid);
      await seedUserDocs(followerUid);
      await seedUserDocs(followeeUid);

      /*
       * followerUid -> uid  (INCOMING for the deleting user)
       * uid -> followeeUid  (OUTGOING; followersCount logic is unchanged)
       */
      await db.collection('follows').doc(`${followerUid}_${uid}`).set({
        followerId: followerUid,
        followeeId: uid,
        createdAt: new Date(),
      });

      await db.collection('follows').doc(`${uid}_${followeeUid}`).set({
        followerId: uid,
        followeeId: followeeUid,
        createdAt: new Date(),
      });

      await db.collection('profiles').doc(uid).update({ followersCount: 1 });
      await db
        .collection('profiles')
        .doc(followeeUid)
        .update({ followersCount: 1 });

      await requestDeletion(uid);

      /*
       * Must NOT throw "Invalid followingCount".
       */
      await processDeletion(uid);

      const request = await db
        .collection('accountDeletionRequests')
        .doc(uid)
        .get();

      assert.equal(request.data().status, 'completed');
      assert.equal(request.data().phase, 'completed');

      // Incoming edge removed.
      await assertMissing(`follows/${followerUid}_${uid}`);

      // Follower untouched: still exists, counter exactly 0 (not -1).
      const follower = await db.collection('users').doc(followerUid).get();

      assert.equal(follower.exists, true);
      assert.strictEqual(follower.data().followingCount, 0);

      // Outgoing logic unchanged: edge removed, followee counter 1 -> 0.
      await assertMissing(`follows/${uid}_${followeeUid}`);

      const followeeProfile = await db
        .collection('profiles')
        .doc(followeeUid)
        .get();

      assert.strictEqual(followeeProfile.data().followersCount, 0);

      // Deleting user is gone; the others' Auth accounts are not.
      await assertMissing(`profiles/${uid}`);

      await assert.rejects(
        () => auth.getUser(uid),
        (error) => error?.code === 'auth/user-not-found',
      );

      assert.equal((await auth.getUser(followerUid)).uid, followerUid);
    } finally {
      await db.collection('follows').doc(`${followerUid}_${uid}`).delete();
      await db.collection('follows').doc(`${uid}_${followeeUid}`).delete();
      await cleanupCountScenario(scenario);
    }
  },
);


test(
  'F3-G: verify failure retries from posts and completes deletion',
  async () => {
    const uid = 'f3g-retry-user';
    const postId = 'f3g-retry-own-post';
    const scenario = {
      uids: [uid],
      postIds: [postId],
    };

    await cleanupCountScenario(scenario);

    try {
      await ensureAuthUser(uid);
      await seedUserDocs(uid);

      /*
       * Deliberate residue:
       * the deleting user's own post remains when the worker starts
       * at verify, so phaseVerify() must genuinely fail.
       */
      await db.collection('posts').doc(postId).set({
        authorId: uid,
        createdAt: new Date(),
      });

      /*
       * Start directly at verify to reproduce the retry bug.
       */
      await db
        .collection('accountDeletionRequests')
        .doc(uid)
        .set({
          uid,
          status: 'pending',
          phase: 'verify',
          createdAt: new Date(),
        });

      await assert.rejects(
        () => processDeletion(uid),
        /F3-G verification failed: residual user data exists/,
      );

      /*
       * W1 target:
       * a verify failure must retry from posts, not verify.
       */
      const failedRequest = await db
        .collection('accountDeletionRequests')
        .doc(uid)
        .get();

      assert.equal(failedRequest.exists, true);
      assert.equal(failedRequest.data().status, 'failed');
      assert.equal(failedRequest.data().phase, 'posts');

      /*
       * Second invocation must resume from posts, remove the residue,
       * complete verification, then delete Auth last.
       */
      await processDeletion(uid);

      const completedRequest = await db
        .collection('accountDeletionRequests')
        .doc(uid)
        .get();

      assert.equal(completedRequest.exists, true);
      assert.equal(completedRequest.data().status, 'completed');
      assert.equal(completedRequest.data().phase, 'completed');

      await assertMissing(`posts/${postId}`);
      await assertMissing(`profiles/${uid}`);
      await assertMissing(`users/${uid}`);

      await assert.rejects(
        () => auth.getUser(uid),
        (error) => error?.code === 'auth/user-not-found',
      );
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);

const FOLLOWING_MISSING = Symbol('missing');

for (const [label, badValue] of [
  ['negative integer', -1],
  ['non-integer number', 0.5],
  ['string', '0'],
  ['null', null],
  ['missing field', FOLLOWING_MISSING],
]) {
  test(
    `F3-G: invalid follower followingCount (${label}) fails deletion and is NOT repaired`,
    async () => {
      const key = label.replace(/\W+/g, '-');
      const uid = `f3g-folbad-${key}-target`;
      const followerUid = `f3g-folbad-${key}-follower`;
      const scenario = { uids: [uid, followerUid], postIds: [] };
      const edgeId = `${followerUid}_${uid}`;

      await cleanupCountScenario(scenario);
      await db.collection('follows').doc(edgeId).delete();

      try {
        await ensureAuthUser(uid);
        await ensureAuthUser(followerUid);
        await seedUserDocs(uid);

        const follower = {
          uid: followerUid,
          displayName: followerUid,
        };

        if (badValue !== FOLLOWING_MISSING) {
          follower.followingCount = badValue;
        }

        await db.collection('users').doc(followerUid).set(follower);
        await db
          .collection('profiles')
          .doc(followerUid)
          .set({ uid: followerUid, followersCount: 0 });

        await db.collection('follows').doc(edgeId).set({
          followerId: followerUid,
          followeeId: uid,
          createdAt: new Date(),
        });

        await db.collection('profiles').doc(uid).update({ followersCount: 1 });

        await requestDeletion(uid);

        await assert.rejects(
          () => processDeletion(uid),
          /Invalid followingCount/,
        );

        const request = await db
          .collection('accountDeletionRequests')
          .doc(uid)
          .get();

        assert.equal(request.data().status, 'failed');
        assert.match(request.data().lastError, /Invalid followingCount/);

        // Corrupt data is surfaced: edge NOT deleted, value NOT repaired.
        assert.equal((await db.collection('follows').doc(edgeId).get()).exists, true);

        const after = (await db.collection('users').doc(followerUid).get()).data();

        if (badValue === FOLLOWING_MISSING) {
          assert.equal('followingCount' in after, false);
        } else {
          assert.deepStrictEqual(after.followingCount, badValue);
        }

        // Deletion did not proceed to remove the Auth user.
        assert.equal((await auth.getUser(uid)).uid, uid);
      } finally {
        await db.collection('follows').doc(edgeId).delete();
        await cleanupCountScenario(scenario);
      }
    },
  );
}

/*
 * ---------------------------------------------------------------------
 * W5 — lease recovery
 *
 * claimRequest() is atomic. An UNEXPIRED lease owned by another worker
 * blocks the claim; an EXPIRED lease (leaseUntil <= now) is reclaimable
 * and the persisted phase is preserved. The trigger entry point
 * (processDeletionOrRetry) must not report success while another
 * worker holds an active lease, otherwise Cloud Functions stops
 * retrying and a crashed worker's request stays 'processing' forever.
 *
 * These use the real claimRequest()/processDeletion() against the
 * emulators; nothing in the deletion pipeline is mocked.
 * ---------------------------------------------------------------------
 */

const { claimRequest, processDeletionOrRetry } = __test;

const w5Future = () => new Date(Date.now() + 5 * 60 * 1000);
const w5Past = () => new Date(Date.now() - 60 * 1000);

async function w5Seed(uid, fields) {
  await db
    .collection('accountDeletionRequests')
    .doc(uid)
    .set({ uid, createdAt: new Date(), ...fields });
}

async function w5Read(uid) {
  return (
    await db.collection('accountDeletionRequests').doc(uid).get()
  ).data();
}

test(
  'D1/D5: account deletion status follows processing -> completed lifecycle',
  async () => {
    const uid = 'status-lifecycle-user';
    const scenario = { uids: [uid], postIds: [] };

    await cleanupCountScenario(scenario);

    try {
      await ensureAuthUser(uid);
      await seedUserDocs(uid);
      await requestDeletion(uid);

      const claimed = await claimRequest(uid);
      assert.equal(claimed.reason, 'claimed');
      assert.equal(typeof claimed.worker, 'string');
      assert.ok(claimed.worker.length > 0);

      const processingStatus = await db.collection('accountDeletionStatus').doc(uid).get();
      assert.equal(processingStatus.exists, true);
      assert.equal(processingStatus.data().uid, uid);
      assert.equal(processingStatus.data().status, 'processing');
      assert.equal(processingStatus.data().phase, 'posts');
      assert.ok(processingStatus.data().updatedAt);

      await db.collection("accountDeletionRequests").doc(uid).update({
        leaseUntil: new Date(Date.now() - 1000),
      });

      const result = await processDeletion(uid);
      assert.equal(result.processed, true);

      const completedStatus = await db.collection('accountDeletionStatus').doc(uid).get();
      assert.equal(completedStatus.exists, true);
      assert.equal(completedStatus.data().uid, uid);
      assert.equal(completedStatus.data().status, 'completed');
      assert.equal(completedStatus.data().phase, 'completed');
      assert.ok(completedStatus.data().updatedAt);
      assert.ok(completedStatus.data().completedAt);

      const request = await w5Read(uid);
      assert.equal(request.status, 'completed');
      assert.equal(request.phase, 'completed');

      await assert.rejects(
        () => auth.getUser(uid),
        (error) => error?.code === 'auth/user-not-found',
      );
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);

test(
  'W5: an ACTIVE lease blocks a second worker; the owner keeps the request, and the trigger does not swallow it',
  async () => {
    const uid = 'w5-active';
    const scenario = { uids: [uid], postIds: [] };

    await cleanupCountScenario(scenario);

    try {
      const leaseUntil = w5Future();

      await w5Seed(uid, {
        status: 'processing',
        phase: 'follows',
        workerId: 'worker-A',
        leaseUntil,
      });

      const claim = await claimRequest(uid);

      assert.deepEqual(claim, { worker: null, reason: 'lease-active' });

      const after = await w5Read(uid);

      assert.equal(after.status, 'processing');
      assert.equal(after.phase, 'follows');
      assert.equal(after.workerId, 'worker-A');
      assert.equal(after.leaseUntil.toMillis(), leaseUntil.getTime());

      // processDeletion() refuses without touching the request.
      assert.deepEqual(await processDeletion(uid), {
        processed: false,
        uid,
        reason: 'lease-active',
      });

      // The trigger entry point must NOT report success: it throws so
      // Cloud Functions retries until the lease expires.
      await assert.rejects(
        () => processDeletionOrRetry(uid),
        /held by another worker/,
      );

      const stillOwned = await w5Read(uid);

      assert.equal(stillOwned.workerId, 'worker-A');
      assert.equal(stillOwned.status, 'processing');
      assert.equal(stillOwned.phase, 'follows');
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);

test(
  'W5: an EXPIRED lease is reclaimable atomically and the persisted phase is preserved',
  async () => {
    const uid = 'w5-expired';
    const uidNoLease = 'w5-expired-nolease';
    const scenario = { uids: [uid, uidNoLease], postIds: [] };

    await cleanupCountScenario(scenario);

    try {
      await w5Seed(uid, {
        status: 'processing',
        phase: 'profile',
        workerId: 'worker-A',
        leaseUntil: w5Past(),
        lastError: 'previous worker timed out',
      });

      const claim = await claimRequest(uid);

      assert.equal(claim.reason, 'claimed');
      assert.ok(claim.worker);
      assert.notEqual(claim.worker, 'worker-A');

      const after = await w5Read(uid);

      assert.equal(after.status, 'processing');
      assert.equal(after.phase, 'profile', 'phase must not be reset');
      assert.equal(after.workerId, claim.worker);
      assert.ok(after.leaseUntil.toMillis() > Date.now());
      assert.equal(after.lastError, null);

      // 'processing' with no usable lease is also reclaimable.
      await w5Seed(uidNoLease, {
        status: 'processing',
        phase: 'verify',
        workerId: 'worker-A',
      });

      const claim2 = await claimRequest(uidNoLease);

      assert.equal(claim2.reason, 'claimed');
      assert.equal((await w5Read(uidNoLease)).phase, 'verify');
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);

test(
  'W5: two workers racing for the same request: exactly one owner',
  async () => {
    const uid = 'w5-race';
    const scenario = { uids: [uid], postIds: [] };

    await cleanupCountScenario(scenario);

    try {
      for (const seed of [
        { status: 'pending' },
        {
          status: 'processing',
          phase: 'follows',
          workerId: 'worker-A',
          leaseUntil: w5Past(),
        },
        { status: 'failed', phase: 'profile', workerId: null, leaseUntil: null },
      ]) {
        for (let round = 0; round < 5; round += 1) {
          await w5Seed(uid, seed);

          const claims = await Promise.all([
            claimRequest(uid),
            claimRequest(uid),
          ]);

          const winners = claims.filter((claim) => claim.worker);
          const losers = claims.filter((claim) => !claim.worker);

          assert.equal(
            winners.length,
            1,
            `exactly one winner (${seed.status}, round ${round})`,
          );
          assert.equal(losers[0].reason, 'lease-active');

          // The persisted owner is the winner.
          assert.equal((await w5Read(uid)).workerId, winners[0].worker);
        }
      }
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);

test(
  'W5: two real processDeletion() runs racing: exactly one processes, request completes, Auth deleted once',
  async () => {
    const uid = 'w5-race-full';
    const scenario = { uids: [uid], postIds: [] };

    await cleanupCountScenario(scenario);

    try {
      await ensureAuthUser(uid);
      await seedUserDocs(uid);
      await requestDeletion(uid);

      const results = await Promise.all([
        processDeletion(uid),
        processDeletion(uid),
      ]);

      assert.equal(
        results.filter((result) => result.processed === true).length,
        1,
      );

      const loser = results.find((result) => result.processed === false);

      assert.ok(['lease-active', 'completed'].includes(loser.reason));

      const request = await w5Read(uid);

      assert.equal(request.status, 'completed');
      assert.equal(request.phase, 'completed');

      await assertMissing(`users/${uid}`);
      await assertMissing(`profiles/${uid}`);

      await assert.rejects(
        () => auth.getUser(uid),
        (error) => error?.code === 'auth/user-not-found',
      );
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);

test(
  'W5: after the lease expires a new worker RESUMES from the persisted phase (does not restart at posts) and completes',
  async () => {
    const uid = 'w5-resume';
    const followeeUid = 'w5-resume-followee';
    const edgeId = `${uid}_${followeeUid}`;
    const scenario = { uids: [uid, followeeUid], postIds: [] };
    const requestRef = db.collection('accountDeletionRequests').doc(uid);
    const seen = [];
    let unsubscribe = null;

    await cleanupCountScenario(scenario);
    await db.collection('follows').doc(edgeId).delete();

    try {
      await ensureAuthUser(uid);
      await ensureAuthUser(followeeUid);
      await seedUserDocs(uid);
      await seedUserDocs(followeeUid);

      // 'posts' already done by the previous worker; 'follows' was in
      // progress when it died: the outgoing edge is still present.
      await db.collection('follows').doc(edgeId).set({
        followerId: uid,
        followeeId: followeeUid,
        createdAt: new Date(),
      });

      await db
        .collection('profiles')
        .doc(followeeUid)
        .update({ followersCount: 1 });

      await w5Seed(uid, {
        status: 'processing',
        phase: 'follows',
        workerId: 'worker-A',
        leaseUntil: w5Past(),
      });

      // Observe every persisted state transition (read-only).
      unsubscribe = requestRef.onSnapshot((snapshot) => {
        const data = snapshot.data();

        if (!data) {
          return;
        }

        const key = `${data.status}:${data.phase}`;

        if (seen[seen.length - 1] !== key) {
          seen.push(key);
        }
      });

      const startedAt = Date.now();

      while (seen.length === 0) {
        assert.ok(Date.now() - startedAt < 10000, 'listener did not start');
        await new Promise((resolve) => setTimeout(resolve, 25));
      }

      const result = await processDeletionOrRetry(uid);

      assert.equal(result.processed, true);
      assert.equal(result.status, 'completed');

      const waitStarted = Date.now();

      while (!seen.includes('completed:completed')) {
        assert.ok(
          Date.now() - waitStarted < 10000,
          `completed state not observed: ${JSON.stringify(seen)}`,
        );
        await new Promise((resolve) => setTimeout(resolve, 25));
      }

      // Started at the seeded phase, never went back to 'posts'.
      assert.equal(seen[0], 'processing:follows');
      assert.ok(
        !seen.some((key) => key.endsWith(':posts')),
        `must not restart at posts: ${JSON.stringify(seen)}`,
      );

      // The interrupted 'follows' phase genuinely ran to completion.
      await assertMissing(`follows/${edgeId}`);

      assert.strictEqual(
        (await db.collection('profiles').doc(followeeUid).get()).data()
          .followersCount,
        0,
      );

      const request = await w5Read(uid);

      assert.equal(request.status, 'completed');
      assert.equal(request.phase, 'completed');

      await assertMissing(`profiles/${uid}`);
      await assertMissing(`users/${uid}`);

      await assert.rejects(
        () => auth.getUser(uid),
        (error) => error?.code === 'auth/user-not-found',
      );

      assert.equal((await auth.getUser(followeeUid)).uid, followeeUid);
    } finally {
      if (unsubscribe) {
        unsubscribe();
      }

      await db.collection('follows').doc(edgeId).delete();
      await cleanupCountScenario(scenario);
    }
  },
);

test(
  'W5: failed requests are still claimable and keep their phase (failed -> retry/resume unchanged)',
  async () => {
    const uid = 'w5-failed';
    const uidStale = 'w5-failed-stale';
    const scenario = { uids: [uid, uidStale], postIds: [] };

    await cleanupCountScenario(scenario);

    try {
      await w5Seed(uid, {
        status: 'failed',
        phase: 'profile',
        workerId: null,
        leaseUntil: null,
        lastError: 'boom',
      });

      const claim = await claimRequest(uid);

      assert.equal(claim.reason, 'claimed');

      const after = await w5Read(uid);

      assert.equal(after.status, 'processing');
      assert.equal(after.phase, 'profile');
      assert.equal(after.workerId, claim.worker);
      assert.equal(after.lastError, null);

      // A 'failed' request is never lease-gated, even with a leftover lease.
      await w5Seed(uidStale, {
        status: 'failed',
        phase: 'follows',
        workerId: 'worker-A',
        leaseUntil: w5Future(),
      });

      const claim2 = await claimRequest(uidStale);

      assert.equal(claim2.reason, 'claimed');
      assert.equal((await w5Read(uidStale)).phase, 'follows');
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);

test(
  'W5: the trigger entry point does not retry FINAL outcomes (completed, missing)',
  async () => {
    const uid = 'w5-final';
    const missingUid = 'w5-final-missing';
    const scenario = { uids: [uid, missingUid], postIds: [] };

    await cleanupCountScenario(scenario);

    try {
      await w5Seed(uid, {
        status: 'completed',
        phase: 'completed',
        workerId: null,
        leaseUntil: null,
      });

      assert.deepEqual(await processDeletionOrRetry(uid), {
        processed: false,
        uid,
        reason: 'completed',
      });

      assert.deepEqual(await processDeletionOrRetry(missingUid), {
        processed: false,
        uid: missingUid,
        reason: 'missing',
      });
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);

/*
 * ---------------------------------------------------------------------
 * W6 — observability only.
 *
 * The lifecycle events added to functions/index.js must carry uid,
 * workerId and phase, and claim / reclaim / resume / lease-active must be
 * distinguishable. These use the real claimRequest() against the emulators;
 * logger output is captured by temporarily replacing the logger methods.
 * No deletion behaviour is asserted differently from W5.
 * ---------------------------------------------------------------------
 */

const { logger: w6Logger } = require('firebase-functions');

async function w6Capture(fn) {
  const events = [];
  const originals = {};

  for (const level of ['info', 'warn', 'error']) {
    originals[level] = w6Logger[level];
    w6Logger[level] = (message, fields) => {
      events.push({ level, message, ...(fields || {}) });
    };
  }

  try {
    await fn();
  } finally {
    for (const level of ['info', 'warn', 'error']) {
      w6Logger[level] = originals[level];
    }
  }

  return events;
}

test(
  'W6: claim, reclaim, resume and lease-active are logged with uid, workerId and phase',
  async () => {
    const uids = ['w6-pending', 'w6-expired', 'w6-failed', 'w6-active'];
    const scenario = { uids, postIds: [] };

    await cleanupCountScenario(scenario);

    try {
      await w5Seed('w6-pending', { status: 'pending' });
      await w5Seed('w6-expired', {
        status: 'processing',
        phase: 'follows',
        workerId: 'worker-A',
        leaseUntil: w5Past(),
      });
      await w5Seed('w6-failed', {
        status: 'failed',
        phase: 'profile',
        workerId: null,
        leaseUntil: null,
      });
      await w5Seed('w6-active', {
        status: 'processing',
        phase: 'follows',
        workerId: 'worker-B',
        leaseUntil: w5Future(),
      });

      const claims = {};
      const events = await w6Capture(async () => {
        for (const uid of uids) {
          claims[uid] = await claimRequest(uid);
        }
      });

      const of = (uid, name) =>
        events.filter((e) => e.uid === uid && e.event === name);

      // Fresh request: claim only.
      assert.equal(of('w6-pending', 'claim').length, 1);
      assert.equal(of('w6-pending', 'claim')[0].workerId, claims['w6-pending'].worker);
      assert.equal(of('w6-pending', 'claim')[0].phase, 'posts');
      assert.equal(of('w6-pending', 'reclaim').length, 0);
      assert.equal(of('w6-pending', 'resume').length, 0);

      // Expired lease: reclaim (distinguishable from claim) + resume.
      assert.equal(of('w6-expired', 'claim').length, 0);
      assert.equal(of('w6-expired', 'reclaim').length, 1);
      assert.equal(of('w6-expired', 'reclaim')[0].previousWorkerId, 'worker-A');
      assert.equal(of('w6-expired', 'reclaim')[0].phase, 'follows');
      assert.equal(of('w6-expired', 'resume')[0].phase, 'follows');
      assert.equal(of('w6-expired', 'resume')[0].workerId, claims['w6-expired'].worker);

      // Failed request: claim + resume from the persisted phase.
      assert.equal(of('w6-failed', 'claim')[0].previousStatus, 'failed');
      assert.equal(of('w6-failed', 'resume')[0].phase, 'profile');

      // Active lease: not claimed; the holder is identified.
      assert.equal(claims['w6-active'].reason, 'lease-active');
      assert.equal(of('w6-active', 'lease-active')[0].holderWorkerId, 'worker-B');
      assert.equal(of('w6-active', 'claim').length, 0);
      assert.equal(of('w6-active', 'reclaim').length, 0);
      assert.equal(of('w6-active', 'resume').length, 0);
    } finally {
      await cleanupCountScenario(scenario);
    }
  },
);
