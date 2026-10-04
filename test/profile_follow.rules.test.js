// test/profile_follow.rules.test.js
// Ujian firestore.rules untuk profil awam (profiles/{uid}) dan follow
// (follows/{followerId}_{followeeId}).
//
// Jalankan bersama suite sedia ada:  npm test
//
// Prinsip yang diuji:
// → profiles: hanya nama/bio/kaunter; tiada medan peribadi; tiada list.
// → followersCount hanya boleh berubah TEPAT ±1 dalam batch yang sama
//   dgn create/delete edge follows/{saya}_{target} (corak sama seperti likes).
// → Follow satu arah; senarai follow hanya boleh dibaca pihak terlibat.
const fs = require('fs');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const { serverTimestamp } = require('firebase/firestore');

const PROJECT_ID = 'ihijrah-178fc';

let testEnv;

describe('iHijrah Firestore Rules — profiles & follow', function () {
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

  const seedProfile = async (uid, opts = {}) => {
    const { followersCount = 0, name = `User ${uid}`, bio = '' } = opts;
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc(`profiles/${uid}`).set({
        name,
        bio,
        followersCount,
        createdAt: new Date(),
      });
    });
  };

  const seedEdge = async (follower, followee) => {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc(`follows/${follower}_${followee}`).set({
        followerId: follower,
        followeeId: followee,
        createdAt: new Date(),
      });
    });
  };

  const readCount = async (uid) => {
    let value;
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const snap = await context.firestore().doc(`profiles/${uid}`).get();
      value = snap.data().followersCount;
    });
    return value;
  };

  const edgeExists = async (follower, followee) => {
    let exists;
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const snap = await context
        .firestore()
        .doc(`follows/${follower}_${followee}`)
        .get();
      exists = snap.exists;
    });
    return exists;
  };

  // Batch "follow": create edge + followersCount(target) -> newCount.
  // newCount === null → tiada update kaunter (edge sahaja).
  const followBatch = (db, me, target, newCount, opts = {}) => {
    const batch = db.batch();
    batch.set(
      db.doc(`follows/${opts.edgeId || `${me}_${target}`}`),
      opts.edgeData || {
        followerId: me,
        followeeId: target,
        createdAt: serverTimestamp(),
      }
    );
    if (newCount !== null) {
      batch.update(db.doc(`profiles/${opts.counterOn || target}`), {
        followersCount: newCount,
      });
    }
    return batch.commit();
  };

  // Batch "unfollow": delete edge + followersCount(target) -> newCount.
  const unfollowBatch = (db, me, target, newCount) => {
    const batch = db.batch();
    batch.delete(db.doc(`follows/${me}_${target}`));
    if (newCount !== null) {
      batch.update(db.doc(`profiles/${target}`), { followersCount: newCount });
    }
    return batch.commit();
  };

  const validProfile = () => ({
    name: 'Ahmad',
    bio: 'Hamba Allah yang mencari redha-Nya.',
    followersCount: 0,
    createdAt: serverTimestamp(),
  });

  // ══════════════════════════════════════════════════════════════
  // PROFILES — create
  // ══════════════════════════════════════════════════════════════
  describe('profiles: create', function () {
    it('verified owner CAN create own profile', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(db.doc('profiles/user-a').set(validProfile()));
    });

    it('unverified user CANNOT create profile', async function () {
      const db = testEnv
        .authenticatedContext('user-a', { email_verified: false })
        .firestore();
      await assertFails(db.doc('profiles/user-a').set(validProfile()));
    });

    it('unauthenticated user CANNOT create profile', async function () {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.doc('profiles/user-a').set(validProfile()));
    });

    it('user CANNOT create profile for another uid', async function () {
      const db = verifiedCtx('attacker').firestore();
      await assertFails(db.doc('profiles/victim').set(validProfile()));
    });

    it('profile with followersCount != 0 is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.doc('profiles/user-a').set({ ...validProfile(), followersCount: 500 })
      );
    });

    it('profile with private/extra fields is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.doc('profiles/user-a').set({
          ...validProfile(),
          email: 'user-a@example.com',
        })
      );
      await assertFails(
        db.doc('profiles/user-a').set({
          ...validProfile(),
          birthdate: '1990-01-01',
        })
      );
    });

    it('profile missing a required field is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      const { bio, ...withoutBio } = validProfile();
      await assertFails(db.doc('profiles/user-a').set(withoutBio));
    });

    it('profile with empty name is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.doc('profiles/user-a').set({ ...validProfile(), name: '' })
      );
    });

    it('profile with name > 120 chars is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.doc('profiles/user-a').set({
          ...validProfile(),
          name: 'a'.repeat(121),
        })
      );
    });

    it('profile with bio > 300 chars is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.doc('profiles/user-a').set({
          ...validProfile(),
          bio: 'b'.repeat(301),
        })
      );
    });

    it('profile with client-supplied createdAt is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.doc('profiles/user-a').set({
          ...validProfile(),
          createdAt: new Date('2020-01-01'),
        })
      );
    });
  });

  // ══════════════════════════════════════════════════════════════
  // PROFILES — read
  // ══════════════════════════════════════════════════════════════
  describe('profiles: read', function () {
    it('verified user CAN get another user\'s profile', async function () {
      await seedProfile('user-b');
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(db.doc('profiles/user-b').get());
    });

    it('verified user CAN get a profile that does not exist yet', async function () {
      // Perlu supaya ensureMyProfile() boleh semak dulu sebelum create.
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(db.doc('profiles/user-a').get());
    });

    it('unverified user CANNOT get a profile', async function () {
      await seedProfile('user-b');
      const db = testEnv
        .authenticatedContext('user-a', { email_verified: false })
        .firestore();
      await assertFails(db.doc('profiles/user-b').get());
    });

    it('unauthenticated user CANNOT get a profile', async function () {
      await seedProfile('user-b');
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.doc('profiles/user-b').get());
    });

    it('nobody CAN list all profiles (no enumeration)', async function () {
      await seedProfile('user-b');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.collection('profiles').get());
    });
  });

  // ══════════════════════════════════════════════════════════════
  // PROFILES — update / delete
  // ══════════════════════════════════════════════════════════════
  describe('profiles: update & delete', function () {
    it('owner CAN update own name and bio', async function () {
      await seedProfile('user-a');
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(
        db.doc('profiles/user-a').update({ name: 'Nama Baru', bio: 'Bio baru' })
      );
    });

    it('owner update with empty name is denied', async function () {
      await seedProfile('user-a');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('profiles/user-a').update({ name: '' }));
    });

    it('owner CANNOT change own followersCount', async function () {
      await seedProfile('user-a', { followersCount: 3 });
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('profiles/user-a').update({ followersCount: 4 }));
      await assertFails(
        db.doc('profiles/user-a').update({ followersCount: 1000000 })
      );
    });

    it('owner CANNOT change createdAt or add fields', async function () {
      await seedProfile('user-a');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.doc('profiles/user-a').update({ createdAt: new Date() })
      );
      await assertFails(
        db.doc('profiles/user-a').update({ email: 'a@example.com' })
      );
    });

    it('another user CANNOT change name or bio', async function () {
      await seedProfile('user-b');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('profiles/user-b').update({ name: 'Hacked' }));
      await assertFails(db.doc('profiles/user-b').update({ bio: 'Hacked' }));
    });

    it('another user CANNOT bump followersCount WITHOUT a follow edge', async function () {
      await seedProfile('user-b');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('profiles/user-b').update({ followersCount: 1 }));
    });

    it('another user CANNOT decrement followersCount WITHOUT deleting own edge', async function () {
      await seedProfile('user-b', { followersCount: 1 });
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('profiles/user-b').update({ followersCount: 0 }));
    });

    it('owner CAN delete own profile with recent auth_time', async function () {
      await seedProfile('user-a');
      const db = verifiedCtx('user-a', { auth_time: nowSeconds() }).firestore();
      await assertSucceeds(db.doc('profiles/user-a').delete());
    });

    it('owner CANNOT delete own profile with stale auth_time', async function () {
      await seedProfile('user-a');
      const db = verifiedCtx('user-a', {
        auth_time: nowSeconds() - 600,
      }).firestore();
      await assertFails(db.doc('profiles/user-a').delete());
    });

    it('another user CANNOT delete a profile', async function () {
      await seedProfile('user-a');
      const db = verifiedCtx('user-b', { auth_time: nowSeconds() }).firestore();
      await assertFails(db.doc('profiles/user-a').delete());
    });
  });

  // ══════════════════════════════════════════════════════════════
  // FOLLOW — create
  // ══════════════════════════════════════════════════════════════
  describe('follow: create', function () {
    beforeEach(async function () {
      await seedProfile('user-a');
      await seedProfile('user-b');
    });

    it('verified user CAN follow (edge + followersCount +1 in one batch)', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(followBatch(db, 'user-a', 'user-b', 1));

      if ((await readCount('user-b')) !== 1) {
        throw new Error('expected followersCount == 1');
      }
      if (!(await edgeExists('user-a', 'user-b'))) {
        throw new Error('expected follow edge to exist');
      }
    });

    it('follow is one-way (Follow != Friend): B is NOT auto-following A', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(followBatch(db, 'user-a', 'user-b', 1));

      if (await edgeExists('user-b', 'user-a')) {
        throw new Error('reverse edge must not exist');
      }
      if ((await readCount('user-a')) !== 0) {
        throw new Error('follower count of A must stay 0');
      }
    });

    it('unauthenticated user CANNOT follow', async function () {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(followBatch(db, 'user-a', 'user-b', 1));
    });

    it('unverified user CANNOT follow', async function () {
      const db = testEnv
        .authenticatedContext('user-a', { email_verified: false })
        .firestore();
      await assertFails(followBatch(db, 'user-a', 'user-b', 1));
    });

    it('user CANNOT follow as another user (spoofed followerId)', async function () {
      const db = verifiedCtx('attacker').firestore();
      await assertFails(followBatch(db, 'user-a', 'user-b', 1));
    });

    it('user CANNOT follow self', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(followBatch(db, 'user-a', 'user-a', 1));
      await assertFails(
        db.doc('follows/user-a_user-a').set({
          followerId: 'user-a',
          followeeId: 'user-a',
          createdAt: serverTimestamp(),
        })
      );
    });

    it('user CANNOT follow a profile that does not exist', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.doc('follows/user-a_ghost').set({
          followerId: 'user-a',
          followeeId: 'ghost',
          createdAt: serverTimestamp(),
        })
      );
    });

    it('user WITHOUT own public profile CANNOT follow', async function () {
      const db = verifiedCtx('user-noprofile').firestore();
      await assertFails(followBatch(db, 'user-noprofile', 'user-b', 1));
    });

    it('edge WITHOUT followersCount +1 is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(followBatch(db, 'user-a', 'user-b', null));
    });

    it('followersCount +1 WITHOUT an edge is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('profiles/user-b').update({ followersCount: 1 }));
    });

    it('follow with counter jump of +2 is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(followBatch(db, 'user-a', 'user-b', 2));
    });

    it('follow that bumps ANOTHER profile\'s counter is denied', async function () {
      await seedProfile('user-c');
      const db = verifiedCtx('user-a').firestore();
      // Edge menuju B, tetapi kaunter C yang dinaikkan.
      await assertFails(
        followBatch(db, 'user-a', 'user-b', 1, { counterOn: 'user-c' })
      );
    });

    it('edge with wrong document id is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        followBatch(db, 'user-a', 'user-b', 1, { edgeId: 'user-a_user-x' })
      );
    });

    it('edge with extra fields is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        followBatch(db, 'user-a', 'user-b', 1, {
          edgeData: {
            followerId: 'user-a',
            followeeId: 'user-b',
            createdAt: serverTimestamp(),
            note: 'x',
          },
        })
      );
    });

    it('edge with client-supplied createdAt is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        followBatch(db, 'user-a', 'user-b', 1, {
          edgeData: {
            followerId: 'user-a',
            followeeId: 'user-b',
            createdAt: new Date('2020-01-01'),
          },
        })
      );
    });

    it('DUPLICATE follow is denied and count stays correct', async function () {
      await seedProfile('user-b', { followersCount: 1 });
      await seedEdge('user-a', 'user-b');
      const db = verifiedCtx('user-a').firestore();

      await assertFails(followBatch(db, 'user-a', 'user-b', 2));

      if ((await readCount('user-b')) !== 1) {
        throw new Error('followersCount must stay 1');
      }
    });

    it('two different users CAN each follow (counts 1 then 2)', async function () {
      await seedProfile('user-c');

      await assertSucceeds(
        followBatch(verifiedCtx('user-a').firestore(), 'user-a', 'user-b', 1)
      );
      await assertSucceeds(
        followBatch(verifiedCtx('user-c').firestore(), 'user-c', 'user-b', 2)
      );

      if ((await readCount('user-b')) !== 2) {
        throw new Error('expected followersCount == 2');
      }
    });

    it('target CANNOT bump their own followersCount', async function () {
      const db = verifiedCtx('user-b').firestore();
      await assertFails(db.doc('profiles/user-b').update({ followersCount: 5 }));
    });
  });

  // ══════════════════════════════════════════════════════════════
  // FOLLOW — delete (unfollow)
  // ══════════════════════════════════════════════════════════════
  describe('follow: delete (unfollow)', function () {
    beforeEach(async function () {
      await seedProfile('user-a');
      await seedProfile('user-b', { followersCount: 1 });
      await seedEdge('user-a', 'user-b');
    });

    it('follower CAN unfollow (edge delete + followersCount -1 in one batch)', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(unfollowBatch(db, 'user-a', 'user-b', 0));

      if ((await readCount('user-b')) !== 0) {
        throw new Error('expected followersCount == 0');
      }
      if (await edgeExists('user-a', 'user-b')) {
        throw new Error('edge must be deleted');
      }
    });

    it('unfollow WITHOUT decrementing the counter is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(unfollowBatch(db, 'user-a', 'user-b', null));
    });

    it('decrement WITHOUT deleting the edge is denied', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('profiles/user-b').update({ followersCount: 0 }));
    });

    it('unfollow that would push the counter below 0 is denied', async function () {
      await seedProfile('user-b', { followersCount: 0 }); // drift simulasi
      const db = verifiedCtx('user-a').firestore();
      await assertFails(unfollowBatch(db, 'user-a', 'user-b', -1));
    });

    it('another user CANNOT delete someone else\'s edge', async function () {
      await seedProfile('user-c');
      const db = verifiedCtx('user-c').firestore();
      await assertFails(unfollowBatch(db, 'user-a', 'user-b', 0));
    });

    it('the followee CANNOT remove a follower\'s edge', async function () {
      const db = verifiedCtx('user-b').firestore();
      await assertFails(unfollowBatch(db, 'user-a', 'user-b', 0));
    });

    it('unauthenticated user CANNOT unfollow', async function () {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(unfollowBatch(db, 'user-a', 'user-b', 0));
    });

    it('orphan edge (followee profile deleted) CAN be cleaned up alone', async function () {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().doc('profiles/user-b').delete();
      });
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(db.doc('follows/user-a_user-b').delete());
    });

    it('one of two followers unfollows (2 -> 1)', async function () {
      await seedProfile('user-c');
      await seedProfile('user-b', { followersCount: 2 });
      await seedEdge('user-c', 'user-b');

      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(unfollowBatch(db, 'user-a', 'user-b', 1));

      if ((await readCount('user-b')) !== 1) {
        throw new Error('expected followersCount == 1');
      }
      if (!(await edgeExists('user-c', 'user-b'))) {
        throw new Error('other follower edge must remain');
      }
    });
  });

  // ══════════════════════════════════════════════════════════════
  // FOLLOW — read / list
  // ══════════════════════════════════════════════════════════════
  describe('follow: read & list', function () {
    beforeEach(async function () {
      // a → b, c → a, x → y
      await seedEdge('user-a', 'user-b');
      await seedEdge('user-c', 'user-a');
      await seedEdge('user-x', 'user-y');
    });

    it('user CAN list who THEY follow', async function () {
      const db = verifiedCtx('user-a').firestore();
      const snap = await db
        .collection('follows')
        .where('followerId', '==', 'user-a')
        .get();
      if (snap.size !== 1) throw new Error('expected 1 edge, got ' + snap.size);
    });

    it('user CAN list who follows THEM', async function () {
      const db = verifiedCtx('user-a').firestore();
      const snap = await db
        .collection('follows')
        .where('followeeId', '==', 'user-a')
        .get();
      if (snap.size !== 1) throw new Error('expected 1 edge, got ' + snap.size);
    });

    it('user CAN check if they follow a specific user (isFollowing query)', async function () {
      const db = verifiedCtx('user-a').firestore();
      const snap = await db
        .collection('follows')
        .where('followerId', '==', 'user-a')
        .where('followeeId', '==', 'user-b')
        .limit(1)
        .get();
      if (snap.size !== 1) throw new Error('expected isFollowing == true');

      const none = await db
        .collection('follows')
        .where('followerId', '==', 'user-a')
        .where('followeeId', '==', 'user-zzz')
        .limit(1)
        .get();
      if (none.size !== 0) throw new Error('expected isFollowing == false');
    });

    it('user CANNOT list another user\'s followers', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection('follows').where('followeeId', '==', 'user-y').get()
      );
    });

    it('user CANNOT list who another user follows', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection('follows').where('followerId', '==', 'user-x').get()
      );
    });

    it('user CANNOT list the whole follows collection', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.collection('follows').get());
    });

    it('unverified user CANNOT list even own edges', async function () {
      const db = testEnv
        .authenticatedContext('user-a', { email_verified: false })
        .firestore();
      await assertFails(
        db.collection('follows').where('followerId', '==', 'user-a').get()
      );
    });

    it('unauthenticated user CANNOT list edges', async function () {
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(
        db.collection('follows').where('followerId', '==', 'user-a').get()
      );
    });

    it('direct get of a single edge is denied (use the query)', async function () {
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('follows/user-a_user-b').get());
    });
  });
});
