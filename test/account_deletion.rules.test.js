// test/account_deletion.rules.test.js
// Ujian firestore.rules untuk pembersihan kandungan semasa PADAM AKAUN.
//
// Fail ini menguji apa yang RULES benarkan / tolak untuk operasi yang
// dilakukan oleh SocialService.purgeMySocialContent() + deleteAccount()
// (lib/services/social_service.dart, lib/models/user_model.dart).
// `purgeAsUser()` di bawah ialah cermin algoritma Dart yang sama
// (imbas posts → like sendiri berpasangan dgn kaunter → reply sendiri →
// komen sendiri → padam post sendiri). Ia MEMBUKTIKAN rules menyokong
// algoritma itu — ia BUKAN ujian kod Dart itu sendiri.
//
// Had yang dikunci oleh ujian (jika rules dilonggarkan kelak, ujian ini
// akan gagal dan keputusan itu mesti disengajakan):
// → tiada carian collection-group / senarai like → penemuan kandungan
//   pengguna hanya melalui imbasan berhalaman;
// → pemilik post TIDAK boleh memadam like/komen/reply orang lain;
// → pengikut sahaja boleh memadam edge follow (edge masuk kekal yatim).
//
// Jalankan bersama suite lain:  npm test
const fs = require('fs');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const PROJECT_ID = 'ihijrah-178fc';

let testEnv;

describe('iHijrah Firestore Rules — account deletion cleanup', function () {
  this.timeout(30000);

  before(async function () {
    testEnv = await initializeTestEnvironment({
      projectId: PROJECT_ID,
      firestore: {
        rules: fs.readFileSync('firestore.rules', 'utf8'),
        host: '127.0.0.1',
        port: 8080,
      },
    });
  });

  after(async function () {
    if (testEnv) {
      await testEnv.cleanup();
    }
  });

  beforeEach(async function () {
    await testEnv.clearFirestore();
  });

  // ── Helper ─────────────────────────────────────────────────────
  const nowSeconds = () => Math.floor(Date.now() / 1000);

  const verifiedCtx = (uid, extra = {}) =>
    testEnv.authenticatedContext(uid, { email_verified: true, ...extra });

  // Pengguna yang sedang memadam akaun: verified + reauth baru sahaja.
  const deletingCtx = (uid) =>
    verifiedCtx(uid, { auth_time: nowSeconds() });

  const admin = async (fn) => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await fn(context.firestore());
    });
  };

  const seedPost = (id, authorId, likes = 0) =>
    admin((db) =>
      db.doc(`posts/${id}`).set({
        type: 'quote',
        title: '',
        content: 'Kandungan ujian padam akaun.',
        author: `Author ${authorId}`,
        authorId,
        likes,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: new Date(),
      })
    );

  const seedLike = (postId, uid) =>
    admin((db) =>
      db.doc(`posts/${postId}/likes/${uid}`).set({ createdAt: new Date() })
    );

  const seedComment = (postId, commentId, authorId) =>
    admin((db) =>
      db.doc(`posts/${postId}/comments/${commentId}`).set({
        authorId,
        author: `Author ${authorId}`,
        content: 'Komen ujian.',
        createdAt: new Date(),
      })
    );

  const seedReply = (postId, commentId, replyId, authorId) =>
    admin((db) =>
      db.doc(`posts/${postId}/comments/${commentId}/replies/${replyId}`).set({
        authorId,
        author: `Author ${authorId}`,
        content: 'Reply ujian.',
        createdAt: new Date(),
      })
    );

  const seedProfile = (uid, followersCount = 0) =>
    admin((db) =>
      db.doc(`profiles/${uid}`).set({
        name: `User ${uid}`,
        bio: '',
        followersCount,
        createdAt: new Date(),
      })
    );

  const seedEdge = (follower, followee) =>
    admin((db) =>
      db.doc(`follows/${follower}_${followee}`).set({
        followerId: follower,
        followeeId: followee,
        createdAt: new Date(),
      })
    );

  const exists = async (path) => {
    let value;
    await admin(async (db) => {
      value = (await db.doc(path).get()).exists;
    });
    return value;
  };

  const field = async (path, name) => {
    let value;
    await admin(async (db) => {
      value = (await db.doc(path).get()).data()[name];
    });
    return value;
  };

  const expect = (cond, message) => {
    if (!cond) {
      throw new Error(message);
    }
  };

  // Cermin SocialService.purgeMySocialContent() + langkah 3b deleteAccount().
  const purgeAsUser = async (db, uid) => {
    const posts = await db.collection('posts').get();
    for (const post of posts.docs) {
      const postId = post.id;

      // Like sendiri: delete like + likes -1 dalam satu batch (setLiked).
      const likeRef = db.doc(`posts/${postId}/likes/${uid}`);
      if ((await likeRef.get()).exists) {
        const current = (await db.doc(`posts/${postId}`).get()).data().likes;
        const batch = db.batch();
        batch.delete(likeRef);
        batch.update(db.doc(`posts/${postId}`), { likes: current - 1 });
        await batch.commit();
      }

      // Semua komen: reply sendiri dulu, kemudian komen sendiri.
      const comments = await db.collection(`posts/${postId}/comments`).get();
      for (const c of comments.docs) {
        const mine = await db
          .collection(`posts/${postId}/comments/${c.id}/replies`)
          .where('authorId', '==', uid)
          .get();
        if (!mine.empty) {
          const batch = db.batch();
          mine.docs.forEach((d) => batch.delete(d.ref));
          await batch.commit();
        }
        if (c.data().authorId === uid) {
          await c.ref.delete();
        }
      }
    }

    // Langkah 3b sedia ada: padam post sendiri.
    const own = await db.collection('posts').where('authorId', '==', uid).get();
    if (!own.empty) {
      const batch = db.batch();
      own.docs.forEach((d) => batch.delete(d.ref));
      await batch.commit();
    }
  };

  // Data: 'me' ialah pengguna yang memadam akaun.
  //   mine    (milik me,    likes 2: me + other)
  //   theirs1 (milik other, likes 2: me + third)
  //   theirs2 (milik other, likes 0, tiada kandungan me)
  const seedScenario = async () => {
    await seedPost('mine', 'me', 2);
    await seedPost('theirs1', 'other', 2);
    await seedPost('theirs2', 'other', 0);

    await seedLike('mine', 'me');
    await seedLike('mine', 'other');
    await seedLike('theirs1', 'me');
    await seedLike('theirs1', 'third');

    await seedComment('theirs1', 'c1', 'me');
    await seedReply('theirs1', 'c1', 'r1', 'other');
    await seedReply('theirs1', 'c1', 'r2', 'me');
    await seedComment('theirs1', 'c2', 'other');
    await seedReply('theirs1', 'c2', 'r3', 'me');
    await seedReply('theirs1', 'c2', 'r4', 'other');

    await seedComment('mine', 'c3', 'me');
    await seedReply('mine', 'c3', 'r5', 'me');
    await seedComment('mine', 'c4', 'other');
    await seedReply('mine', 'c4', 'r6', 'me');
    await seedReply('mine', 'c4', 'r7', 'other');
  };

  // ══════════════════════════════════════════════════════════════
  // Algoritma pembersihan di bawah rules semasa
  // ══════════════════════════════════════════════════════════════
  describe('cleanup algorithm as the deleting user', function () {
    it('removes MY likes/comments/replies everywhere and keeps counters correct', async function () {
      await seedScenario();
      await assertSucceeds(purgeAsUser(deletingCtx('me').firestore(), 'me'));

      // Milik saya — dipadam
      expect(!(await exists('posts/theirs1/likes/me')), 'my like on theirs1 must be gone');
      expect(!(await exists('posts/mine/likes/me')), 'my like on my own post must be gone');
      expect(!(await exists('posts/theirs1/comments/c1')), 'my comment c1 must be gone');
      expect(!(await exists('posts/theirs1/comments/c1/replies/r2')), 'my reply r2 must be gone');
      expect(!(await exists('posts/theirs1/comments/c2/replies/r3')), 'my reply r3 (under others comment) must be gone');
      expect(!(await exists('posts/mine/comments/c3')), 'my comment c3 must be gone');
      expect(!(await exists('posts/mine/comments/c3/replies/r5')), 'my reply r5 must be gone');
      expect(!(await exists('posts/mine/comments/c4/replies/r6')), 'my reply r6 (under others comment) must be gone');
      expect(!(await exists('posts/mine')), 'my own post must be gone');

      // Kaunter selari dgn like yang tinggal
      expect((await field('posts/theirs1', 'likes')) === 1, 'theirs1.likes must be 1 (third user still likes it)');
      expect((await field('posts/theirs2', 'likes')) === 0, 'theirs2 must be untouched');
    });

    it('does NOT touch other users content (documented orphans / untouched data)', async function () {
      await seedScenario();
      await assertSucceeds(purgeAsUser(deletingCtx('me').firestore(), 'me'));

      expect(await exists('posts/theirs1/likes/third'), "third user's like must remain");
      expect(await exists('posts/theirs1/comments/c2'), "other's comment c2 must remain");
      expect(await exists('posts/theirs1/comments/c2/replies/r4'), "other's reply r4 must remain");
      expect(await exists('posts/theirs2'), "other's untouched post must remain");
      // Yatim (BACKEND-REQUIRED): milik orang lain di bawah item saya yang dipadam
      expect(await exists('posts/theirs1/comments/c1/replies/r1'), "other's reply under my deleted comment stays orphaned");
      expect(await exists('posts/mine/likes/other'), "other's like under my deleted post stays orphaned");
      expect(await exists('posts/mine/comments/c4'), "other's comment under my deleted post stays orphaned");
      expect(await exists('posts/mine/comments/c4/replies/r7'), "other's reply under my deleted post stays orphaned");
    });

    it('is idempotent — running it again on already-clean data succeeds', async function () {
      await seedScenario();
      const db = deletingCtx('me').firestore();
      await assertSucceeds(purgeAsUser(db, 'me'));
      await assertSucceeds(purgeAsUser(db, 'me'));
    });

    it('a like whose counter is already 0 cannot be removed (drift) — must surface as a failure, not be forced', async function () {
      await seedPost('drift', 'other', 0);
      await seedLike('drift', 'me'); // like ada tetapi kaunter 0
      const db = deletingCtx('me').firestore();
      const batch = db.batch();
      batch.delete(db.doc('posts/drift/likes/me'));
      batch.update(db.doc('posts/drift'), { likes: -1 });
      await assertFails(batch.commit());
      expect(await exists('posts/drift/likes/me'), 'like must remain when it cannot be removed safely');
    });
  });

  // ══════════════════════════════════════════════════════════════
  // Pengesanan kandungan — had yang dikunci
  // ══════════════════════════════════════════════════════════════
  describe('discovery limits (locked)', function () {
    beforeEach(async function () {
      await seedScenario();
    });

    it('collection-group query on comments is DENIED', async function () {
      const db = deletingCtx('me').firestore();
      await assertFails(db.collectionGroup('comments').where('authorId', '==', 'me').get());
    });

    it('collection-group query on replies is DENIED', async function () {
      const db = deletingCtx('me').firestore();
      await assertFails(db.collectionGroup('replies').where('authorId', '==', 'me').get());
    });

    it('collection-group query on likes is DENIED', async function () {
      const db = deletingCtx('me').firestore();
      await assertFails(db.collectionGroup('likes').get());
    });

    it('listing the likes of a post is DENIED', async function () {
      const db = deletingCtx('me').firestore();
      await assertFails(db.collection('posts/theirs1/likes').get());
    });

    it("reading ANOTHER user's like doc is DENIED", async function () {
      const db = deletingCtx('me').firestore();
      await assertFails(db.doc('posts/theirs1/likes/third').get());
    });

    it('the queries the cleanup relies on ARE allowed', async function () {
      const db = deletingCtx('me').firestore();
      await assertSucceeds(db.collection('posts').get());
      await assertSucceeds(db.doc('posts/theirs1/likes/me').get());
      await assertSucceeds(db.collection('posts/theirs1/comments').get());
      await assertSucceeds(
        db.collection('posts/theirs1/comments/c2/replies').where('authorId', '==', 'me').get()
      );
    });

    it('an UNVERIFIED user cannot scan posts (cleanup cannot start)', async function () {
      const db = testEnv.authenticatedContext('me', { email_verified: false }).firestore();
      await assertFails(db.collection('posts').get());
    });
  });

  // ══════════════════════════════════════════════════════════════
  // Keselamatan tidak dilemahkan
  // ══════════════════════════════════════════════════════════════
  describe('security is not weakened', function () {
    beforeEach(async function () {
      await seedScenario();
    });

    it("post owner CANNOT delete another user's comment under own post", async function () {
      await assertFails(deletingCtx('me').firestore().doc('posts/mine/comments/c4').delete());
    });

    it("post owner CANNOT delete another user's reply under own post", async function () {
      await assertFails(deletingCtx('me').firestore().doc('posts/mine/comments/c4/replies/r7').delete());
    });

    it("post owner CANNOT delete another user's like under own post (even after the post is gone)", async function () {
      const db = deletingCtx('me').firestore();
      await assertFails(db.doc('posts/mine/likes/other').delete());
      await assertSucceeds(db.doc('posts/mine').delete());
      await assertFails(db.doc('posts/mine/likes/other').delete());
    });

    it('after the owner deletes the post, the other user CAN still clean up their own orphans', async function () {
      await assertSucceeds(deletingCtx('me').firestore().doc('posts/mine').delete());
      const other = verifiedCtx('other').firestore();
      await assertSucceeds(other.doc('posts/mine/comments/c4/replies/r7').delete());
      await assertSucceeds(other.doc('posts/mine/comments/c4').delete());
      await assertSucceeds(other.doc('posts/mine/likes/other').delete());
    });

    it('unlike with a counter jump of -2 is denied', async function () {
      const db = deletingCtx('me').firestore();
      const batch = db.batch();
      batch.delete(db.doc('posts/theirs1/likes/me'));
      batch.update(db.doc('posts/theirs1'), { likes: 0 });
      await assertFails(batch.commit());
    });

    it("cannot decrement likes while deleting someone else's like", async function () {
      const db = deletingCtx('me').firestore();
      const batch = db.batch();
      batch.delete(db.doc('posts/theirs1/likes/third'));
      batch.update(db.doc('posts/theirs1'), { likes: 1 });
      await assertFails(batch.commit());
      expect(await exists('posts/theirs1/likes/third'), "third user's like must remain");
    });

    it('likes counter cannot be set directly', async function () {
      const db = deletingCtx('me').firestore();
      await assertFails(db.doc('posts/theirs2').update({ likes: 5 }));
    });

    it("a user CANNOT delete another user's post", async function () {
      await assertFails(deletingCtx('me').firestore().doc('posts/theirs1').delete());
    });
  });

  // ══════════════════════════════════════════════════════════════
  // Follow — keluar (boleh) vs masuk (tidak boleh dari client)
  // ══════════════════════════════════════════════════════════════
  describe('follows during account deletion', function () {
    it('OUTGOING: deleting user unfollows with the paired counter decrement', async function () {
      await seedProfile('me');
      await seedProfile('target', 1);
      await seedEdge('me', 'target');

      const db = deletingCtx('me').firestore();
      const batch = db.batch();
      batch.delete(db.doc('follows/me_target'));
      batch.update(db.doc('profiles/target'), { followersCount: 0 });
      await assertSucceeds(batch.commit());

      expect((await field('profiles/target', 'followersCount')) === 0, 'followee counter must be 0');
      expect(!(await exists('follows/me_target')), 'outgoing edge must be gone');
    });

    it('OUTGOING: edge delete without the counter decrement is denied', async function () {
      await seedProfile('me');
      await seedProfile('target', 1);
      await seedEdge('me', 'target');
      await assertFails(deletingCtx('me').firestore().doc('follows/me_target').delete());
    });

    it('INCOMING: the deleting user CANNOT remove a follower edge (needs backend)', async function () {
      await seedProfile('me');
      await seedProfile('fan');
      await seedEdge('fan', 'me');

      const db = deletingCtx('me').firestore();
      await assertSucceeds(db.doc('profiles/me').delete());
      await assertFails(db.doc('follows/fan_me').delete());
      expect(await exists('follows/fan_me'), 'incoming edge remains (documented orphan)');
    });

    it('INCOMING: the follower CAN still remove the orphan edge later, alone', async function () {
      await seedProfile('fan');
      await seedEdge('fan', 'me'); // profil 'me' sudah tiada
      await assertSucceeds(verifiedCtx('fan').firestore().doc('follows/fan_me').delete());
    });
  });
});
