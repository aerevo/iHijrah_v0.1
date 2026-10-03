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
