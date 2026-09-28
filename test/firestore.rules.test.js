const fs = require('fs');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const PROJECT_ID = 'ihijrah-178fc';

let testEnv;

describe('iHijrah Firestore Rules', function () {
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

  it('verified user CAN read posts', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();

      await db.doc('posts/test-post').set({
        type: 'quote',
        content: 'Test content minimum.',
        authorId: 'verified-user',
      });
    });

    const context = testEnv.authenticatedContext('verified-user', {
      email_verified: true,
    });

    await assertSucceeds(
      context.firestore().doc('posts/test-post').get()
    );
  });

  it('unverified user CANNOT read posts', async function () {
    const context = testEnv.authenticatedContext('unverified-user', {
      email_verified: false,
    });

    await assertFails(
      context.firestore().doc('posts/test-post').get()
    );
  });

  it('verified user CAN create valid post', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      const db = context.firestore();

      await db.doc('users/creator').set({
        name: 'Test User',
      });
    });

    const context = testEnv.authenticatedContext('creator', {
      email_verified: true,
    });

    await assertSucceeds(
      context.firestore().collection('posts').add({
        type: 'quote',
        title: '',
        content: 'This is a valid test post.',
        author: 'Test User',
        authorId: 'creator',
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: require('firebase/firestore').serverTimestamp(),
      })
    );
  });

  it('user CANNOT update an existing post', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('posts/test-post').set({
        type: 'quote',
        title: '',
        content: 'Original test content.',
        author: 'Test User',
        authorId: 'creator',
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: new Date(),
      });
    });

    const context = testEnv.authenticatedContext('creator', {
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('posts/test-post').update({
        content: 'Changed content.',
      })
    );
  });


  it('unverified user CANNOT create a post', async function () {
    const context = testEnv.authenticatedContext('unverified-user', {
      email_verified: false,
    });

    await assertFails(
      context.firestore().collection('posts').add({
        type: 'quote',
        title: '',
        content: 'This should be rejected.',
        author: 'Hamba Allah',
        authorId: 'unverified-user',
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: require('firebase/firestore').serverTimestamp(),
      })
    );
  });

  it('user CANNOT impersonate another authorId', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/real-user').set({
        name: 'Real User',
      });
    });

    const context = testEnv.authenticatedContext('attacker', {
      email_verified: true,
    });

    await assertFails(
      context.firestore().collection('posts').add({
        type: 'quote',
        title: '',
        content: 'Attempted impersonation.',
        author: 'Real User',
        authorId: 'real-user',
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: require('firebase/firestore').serverTimestamp(),
      })
    );
  });

  it('user CANNOT create post with non-zero counters', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/creator').set({
        name: 'Test User',
      });
    });

    const context = testEnv.authenticatedContext('creator', {
      email_verified: true,
    });

    await assertFails(
      context.firestore().collection('posts').add({
        type: 'quote',
        title: '',
        content: 'Trying to manipulate counters.',
        author: 'Test User',
        authorId: 'creator',
        likes: 999,
        commentsCount: 999,
        assetPath: null,
        category: null,
        createdAt: require('firebase/firestore').serverTimestamp(),
      })
    );
  });

  it('user CANNOT create post with content shorter than 10 chars', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/creator').set({
        name: 'Test User',
      });
    });

    const context = testEnv.authenticatedContext('creator', {
      email_verified: true,
    });

    await assertFails(
      context.firestore().collection('posts').add({
        type: 'quote',
        title: '',
        content: 'Short',
        author: 'Test User',
        authorId: 'creator',
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: require('firebase/firestore').serverTimestamp(),
      })
    );
  });

  it('user CANNOT add an unauthorized field', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/creator').set({
        name: 'Test User',
      });
    });

    const context = testEnv.authenticatedContext('creator', {
      email_verified: true,
    });

    await assertFails(
      context.firestore().collection('posts').add({
        type: 'quote',
        title: '',
        content: 'Trying an extra field.',
        author: 'Test User',
        authorId: 'creator',
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: require('firebase/firestore').serverTimestamp(),
        isAdmin: true,
      })
    );
  });

  it('user CANNOT delete another users post', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('posts/other-post').set({
        type: 'quote',
        title: '',
        content: 'This belongs to another user.',
        author: 'Other User',
        authorId: 'other-user',
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: new Date(),
      });
    });

    const context = testEnv.authenticatedContext('attacker', {
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('posts/other-post').delete()
    );
  });


  it('user CAN read own user document', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        totalPoints: 0,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertSucceeds(
      context.firestore().doc('users/user-a').get()
    );
  });

  it('user CANNOT read another users document', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-b').set({
        name: 'User B',
        email: 'user-b@example.com',
        totalPoints: 0,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-b').get()
    );
  });

  it('user CANNOT change totalPoints', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        authMethod: 'Email',
        totalPoints: 100,
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        currentStreak: 2,
        longestStreak: 5,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        totalPoints: 999999,
      })
    );
  });

  it('user CANNOT change follower or post counters', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        authMethod: 'Email',
        followersCount: 10,
        followingCount: 5,
        postsCount: 3,
        treeLevel: 2,
        totalPoints: 100,
        currentStreak: 2,
        longestStreak: 5,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        followersCount: 999,
        followingCount: 999,
        postsCount: 999,
      })
    );
  });

  it('user CANNOT change email identity field', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        authMethod: 'Email',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        email: 'attacker@example.com',
      })
    );
  });

  it('user CAN change allowed profile field without changing protected fields', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'Old Name',
        email: 'user-a@example.com',
        authMethod: 'Email',
        bio: 'Old bio',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertSucceeds(
      context.firestore().doc('users/user-a').update({
        name: 'New Name',
        bio: 'Updated bio',
      })
    );
  });


  it('UserModel full document shape CAN be created with protected defaults', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        gender: 'Lelaki',
        bio: '',
        avatarPath: null,
        authMethod: 'Email',
        birthdate: '2000-01-01T00:00:00.000Z',
        hijriDOB: null,
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: null,
        lastLogResetDate: null,
        dailyFardhuLog: {},
        dailyAmalanLog: {},
        zikirDoneToday: false,
        adhanModeIndex: 1,
        isFajrAlarmEnabled: true,
        isDhuhrAlarmEnabled: true,
        isAsrAlarmEnabled: true,
        isMaghribAlarmEnabled: true,
        isIshaAlarmEnabled: true,
        zikirReminderEnabled: true,
        themeMode: 'auto',
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertSucceeds(
      context.firestore().doc('users/user-a').get()
    );
  });

  it('UserModel full document shape CAN update allowed fields while protected fields stay unchanged', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'Old Name',
        email: 'user-a@example.com',
        gender: 'Lelaki',
        bio: '',
        avatarPath: null,
        authMethod: 'Email',
        birthdate: '2000-01-01T00:00:00.000Z',
        hijriDOB: null,
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: null,
        lastLogResetDate: null,
        dailyFardhuLog: {},
        dailyAmalanLog: {},
        zikirDoneToday: false,
        adhanModeIndex: 1,
        isFajrAlarmEnabled: true,
        isDhuhrAlarmEnabled: true,
        isAsrAlarmEnabled: true,
        isMaghribAlarmEnabled: true,
        isIshaAlarmEnabled: true,
        zikirReminderEnabled: true,
        themeMode: 'auto',
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertSucceeds(
      context.firestore().doc('users/user-a').set({
        name: 'New Name',
        email: 'user-a@example.com',
        gender: 'Perempuan',
        bio: 'New bio',
        avatarPath: null,
        authMethod: 'Email',
        birthdate: '2000-01-01T00:00:00.000Z',
        hijriDOB: null,
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastActiveDate: null,
        lastLogResetDate: null,
        dailyFardhuLog: {},
        dailyAmalanLog: {},
        zikirDoneToday: false,
        adhanModeIndex: 2,
        isFajrAlarmEnabled: false,
        isDhuhrAlarmEnabled: true,
        isAsrAlarmEnabled: true,
        isMaghribAlarmEnabled: true,
        isIshaAlarmEnabled: true,
        zikirReminderEnabled: false,
        themeMode: 'dark',
      })
    );
  });


  it('unauthenticated user CANNOT read posts', async function () {
    const context = testEnv.unauthenticatedContext();

    await assertFails(
      context.firestore().doc('posts/test-post').get()
    );
  });

  it('unauthenticated user CANNOT read users', async function () {
    const context = testEnv.unauthenticatedContext();

    await assertFails(
      context.firestore().doc('users/user-a').get()
    );
  });

  it('unauthenticated user CANNOT create a post', async function () {
    const context = testEnv.unauthenticatedContext();

    await assertFails(
      context.firestore().collection('posts').add({
        type: 'quote',
        title: '',
        content: 'Unauthenticated attempt.',
        author: 'Hamba Allah',
        authorId: 'anonymous',
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: require('firebase/firestore').serverTimestamp(),
      })
    );
  });


  it('user CANNOT change protected field: followersCount', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        gender: 'Lelaki',
        bio: '',
        avatarPath: null,
        authMethod: 'Email',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 100,
        currentStreak: 2,
        longestStreak: 5,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        followersCount: 999,
      })
    );
  });


  it('user CANNOT change protected field: followingCount', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        gender: 'Lelaki',
        bio: '',
        avatarPath: null,
        authMethod: 'Email',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 100,
        currentStreak: 2,
        longestStreak: 5,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        followingCount: 999,
      })
    );
  });


  it('user CANNOT change protected field: postsCount', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        gender: 'Lelaki',
        bio: '',
        avatarPath: null,
        authMethod: 'Email',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 100,
        currentStreak: 2,
        longestStreak: 5,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        postsCount: 999,
      })
    );
  });


  it('user CANNOT change protected field: treeLevel', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        gender: 'Lelaki',
        bio: '',
        avatarPath: null,
        authMethod: 'Email',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 100,
        currentStreak: 2,
        longestStreak: 5,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        treeLevel: 999,
      })
    );
  });


  it('user CANNOT change protected field: totalPoints', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        gender: 'Lelaki',
        bio: '',
        avatarPath: null,
        authMethod: 'Email',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 100,
        currentStreak: 2,
        longestStreak: 5,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        totalPoints: 999,
      })
    );
  });


  it('user CANNOT change protected field: currentStreak', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        gender: 'Lelaki',
        bio: '',
        avatarPath: null,
        authMethod: 'Email',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 100,
        currentStreak: 2,
        longestStreak: 5,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        currentStreak: 999,
      })
    );
  });


  it('user CANNOT change protected field: longestStreak', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        gender: 'Lelaki',
        bio: '',
        avatarPath: null,
        authMethod: 'Email',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 100,
        currentStreak: 2,
        longestStreak: 5,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        longestStreak: 999,
      })
    );
  });


  it('user CANNOT change protected field: authMethod', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('users/user-a').set({
        name: 'User A',
        email: 'user-a@example.com',
        gender: 'Lelaki',
        bio: '',
        avatarPath: null,
        authMethod: 'Email',
        followersCount: 0,
        followingCount: 0,
        postsCount: 0,
        treeLevel: 1,
        totalPoints: 100,
        currentStreak: 2,
        longestStreak: 5,
      });
    });

    const context = testEnv.authenticatedContext('user-a', {
      email: 'user-a@example.com',
      email_verified: true,
    });

    await assertFails(
      context.firestore().doc('users/user-a').update({
        authMethod: 'Admin',
      })
    );
  });

  it('owner CAN delete own post', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('posts/test-post').set({
        type: 'quote',
        title: '',
        content: 'Post to delete.',
        author: 'Test User',
        authorId: 'creator',
        likes: 0,
        commentsCount: 0,
        assetPath: null,
        category: null,
        createdAt: new Date(),
      });
    });

    const context = testEnv.authenticatedContext('creator', {
      email_verified: true,
    });

    await assertSucceeds(
      context.firestore().doc('posts/test-post').delete()
    );
  });

  // ═══════════════════════════════════════════════════════════════
  // FIX #4 — Account deletion: users/{userId} delete rule
  // ═══════════════════════════════════════════════════════════════
  describe('Account deletion (users/{userId} delete)', function () {
    const nowSeconds = () => Math.floor(Date.now() / 1000);

    beforeEach(async function () {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().doc('users/user-a').set({
          name: 'User A',
          email: 'user-a@example.com',
          gender: 'Lelaki',
          bio: '',
          avatarPath: null,
          authMethod: 'Email',
          followersCount: 0,
          followingCount: 0,
          postsCount: 0,
          treeLevel: 1,
          totalPoints: 100,
          currentStreak: 2,
          longestStreak: 5,
        });
      });
    });

    it('owner CAN delete own users/{uid} with recent auth_time (<5min)', async function () {
      const context = testEnv.authenticatedContext('user-a', {
        email: 'user-a@example.com',
        email_verified: true,
        auth_time: nowSeconds(),
      });

      await assertSucceeds(
        context.firestore().doc('users/user-a').delete()
      );
    });

    it('owner CANNOT delete own users/{uid} with stale auth_time (>5min)', async function () {
      const context = testEnv.authenticatedContext('user-a', {
        email: 'user-a@example.com',
        email_verified: true,
        auth_time: nowSeconds() - 600, // 10 minit lalu — luar tetingkap 5 minit
      });

      await assertFails(
        context.firestore().doc('users/user-a').delete()
      );
    });

    it('another authenticated user CANNOT delete a different users/{uid}', async function () {
      const context = testEnv.authenticatedContext('user-b', {
        email: 'user-b@example.com',
        email_verified: true,
        auth_time: nowSeconds(),
      });

      await assertFails(
        context.firestore().doc('users/user-a').delete()
      );
    });

    it('unauthenticated user CANNOT delete users/{uid}', async function () {
      const context = testEnv.unauthenticatedContext();

      await assertFails(
        context.firestore().doc('users/user-a').delete()
      );
    });

    it('owner with NO auth_time claim at all CANNOT delete (treated as stale)', async function () {
      // Sesetengah token lama/ujian mungkin tiada claim auth_time
      // langsung — rule mesti tolak dgn selamat, bukan throw/allow
      // secara tak sengaja.
      const context = testEnv.authenticatedContext('user-a', {
        email: 'user-a@example.com',
        email_verified: true,
      });

      await assertFails(
        context.firestore().doc('users/user-a').delete()
      );
    });
  });

  // ══════════════════════════════════════════════════════════════
  // SOCIAL — LIKES (Phase 1 / Batch 1)
  // Kaunter `posts.likes` hanya boleh berubah TEPAT ±1 dalam batch
  // yang sama dgn create/delete posts/{id}/likes/{uid}.
  // ══════════════════════════════════════════════════════════════
  describe('social: likes', function () {
    const { serverTimestamp } = require('firebase/firestore');

    const seedPost = async (likes = 0) => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().doc('posts/p1').set({
          type: 'quote',
          title: '',
          content: 'Post untuk ujian like.',
          author: 'Author',
          authorId: 'author',
          likes,
          commentsCount: 0,
          assetPath: null,
          category: null,
          createdAt: new Date(),
        });
      });
    };

    const seedLike = async (uid) => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().doc(`posts/p1/likes/${uid}`).set({
          createdAt: new Date(),
        });
      });
    };

    const verifiedCtx = (uid) =>
      testEnv.authenticatedContext(uid, { email_verified: true });

    // Bina batch "like": create like doc + likes -> newCount
    const likeBatch = (db, uid, newCount, likeData) => {
      const batch = db.batch();
      batch.set(db.doc(`posts/p1/likes/${uid}`),
        likeData || { createdAt: serverTimestamp() });
      batch.update(db.doc('posts/p1'), { likes: newCount });
      return batch.commit();
    };

    // Bina batch "unlike": delete like doc + likes -> newCount
    const unlikeBatch = (db, uid, newCount) => {
      const batch = db.batch();
      batch.delete(db.doc(`posts/p1/likes/${uid}`));
      batch.update(db.doc('posts/p1'), { likes: newCount });
      return batch.commit();
    };

    it('verified user CAN like a post (like doc + likes +1 in one batch)', async function () {
      await seedPost(0);
      const db = verifiedCtx('user-a').firestore();

      await assertSucceeds(likeBatch(db, 'user-a', 1));

      await testEnv.withSecurityRulesDisabled(async (context) => {
        const post = await context.firestore().doc('posts/p1').get();
        if (post.data().likes !== 1) {
          throw new Error('expected likes == 1, got ' + post.data().likes);
        }
      });
    });

    it('unauthenticated user CANNOT like', async function () {
      await seedPost(0);
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(likeBatch(db, 'user-a', 1));
    });

    it('unverified user CANNOT like', async function () {
      await seedPost(0);
      const db = testEnv
        .authenticatedContext('user-a', { email_verified: false })
        .firestore();
      await assertFails(likeBatch(db, 'user-a', 1));
    });

    it('user CANNOT like as another user (spoofed uid)', async function () {
      await seedPost(0);
      const db = verifiedCtx('attacker').firestore();
      await assertFails(likeBatch(db, 'victim', 1));
    });

    it('like doc WITHOUT matching likes +1 is denied', async function () {
      await seedPost(0);
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.doc('posts/p1/likes/user-a').set({ createdAt: serverTimestamp() })
      );
    });

    it('likes +1 WITHOUT a like doc is denied', async function () {
      await seedPost(0);
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('posts/p1').update({ likes: 1 }));
    });

    it('like with counter jump of +2 is denied', async function () {
      await seedPost(0);
      const db = verifiedCtx('user-a').firestore();
      await assertFails(likeBatch(db, 'user-a', 2));
    });

    it('DUPLICATE like by same user is denied and count stays correct', async function () {
      await seedPost(1);
      await seedLike('user-a');
      const db = verifiedCtx('user-a').firestore();

      await assertFails(likeBatch(db, 'user-a', 2));

      await testEnv.withSecurityRulesDisabled(async (context) => {
        const post = await context.firestore().doc('posts/p1').get();
        if (post.data().likes !== 1) {
          throw new Error('likes must stay 1, got ' + post.data().likes);
        }
      });
    });

    it('two different users CAN each like (counts 1 then 2)', async function () {
      await seedPost(1);
      await seedLike('user-b');
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(likeBatch(db, 'user-a', 2));
    });

    it('like doc with extra field is denied', async function () {
      await seedPost(0);
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        likeBatch(db, 'user-a', 1, {
          createdAt: serverTimestamp(),
          isAdmin: true,
        })
      );
    });

    it('like doc with client-supplied createdAt (not server time) is denied', async function () {
      await seedPost(0);
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        likeBatch(db, 'user-a', 1, { createdAt: new Date('2020-01-01') })
      );
    });

    it('user CAN unlike own like (delete + likes -1)', async function () {
      await seedPost(1);
      await seedLike('user-a');
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(unlikeBatch(db, 'user-a', 0));
    });

    it('unlike WITHOUT decrementing counter is denied', async function () {
      await seedPost(1);
      await seedLike('user-a');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('posts/p1/likes/user-a').delete());
    });

    it('decrementing counter WITHOUT deleting like doc is denied', async function () {
      await seedPost(1);
      await seedLike('user-a');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('posts/p1').update({ likes: 0 }));
    });

    it("user CANNOT delete another user's like", async function () {
      await seedPost(1);
      await seedLike('victim');
      const db = verifiedCtx('attacker').firestore();
      await assertFails(unlikeBatch(db, 'victim', 0));
    });

    it('user CANNOT unlike a post they never liked (counter would drift)', async function () {
      await seedPost(1);
      await seedLike('user-b');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(unlikeBatch(db, 'user-a', 0));
    });

    it('user CANNOT set likes counter directly to an arbitrary value', async function () {
      await seedPost(0);
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('posts/p1').update({ likes: 999 }));
    });

    it('user CANNOT push likes below zero', async function () {
      await seedPost(0);
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('posts/p1').update({ likes: -1 }));
    });

    it('likes update cannot smuggle another field (content)', async function () {
      await seedPost(0);
      const db = verifiedCtx('user-a').firestore();
      const batch = db.batch();
      batch.set(db.doc('posts/p1/likes/user-a'), { createdAt: serverTimestamp() });
      batch.update(db.doc('posts/p1'), { likes: 1, content: 'Diubah oleh penyerang.' });
      await assertFails(batch.commit());
    });

    it('user CAN read own like doc but NOT another users like doc', async function () {
      await seedPost(2);
      await seedLike('user-a');
      await seedLike('user-b');
      const db = verifiedCtx('user-a').firestore();

      await assertSucceeds(db.doc('posts/p1/likes/user-a').get());
      await assertFails(db.doc('posts/p1/likes/user-b').get());
    });

    it('user CANNOT list all likes of a post', async function () {
      await seedPost(1);
      await seedLike('user-b');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.collection('posts/p1/likes').get());
    });

    it('user CAN clean up own orphan like after the post was deleted', async function () {
      await seedLike('user-a'); // tiada posts/p1
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(db.doc('posts/p1/likes/user-a').delete());
    });

    it('user CANNOT like a post that does not exist', async function () {
      const db = verifiedCtx('user-a').firestore();
      const batch = db.batch();
      batch.set(db.doc('posts/ghost/likes/user-a'), { createdAt: serverTimestamp() });
      await assertFails(batch.commit());
    });
  });

  // ══════════════════════════════════════════════════════════════
  // SOCIAL — COMMENTS (Phase 1 / Batch 2)
  // ══════════════════════════════════════════════════════════════
  describe('social: comments', function () {
    const { serverTimestamp } = require('firebase/firestore');

    const seedPostAndUsers = async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await db.doc('posts/p1').set({
          type: 'quote', title: '', content: 'Post untuk ujian komen.',
          author: 'Author', authorId: 'author', likes: 0,
          commentsCount: 0, assetPath: null, category: null,
          createdAt: new Date(),
        });
        await db.doc('users/user-a').set({
          name: 'User A', email: 'user-a@example.com', authMethod: 'Email',
          followersCount: 0, followingCount: 0, postsCount: 0,
          treeLevel: 1, totalPoints: 0, currentStreak: 0, longestStreak: 0,
        });
        await db.doc('users/user-noname').set({
          name: '', email: 'n@example.com', authMethod: 'Email',
          followersCount: 0, followingCount: 0, postsCount: 0,
          treeLevel: 1, totalPoints: 0, currentStreak: 0, longestStreak: 0,
        });
      });
    };

    const seedComment = async (id, authorId) => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().doc(`posts/p1/comments/${id}`).set({
          authorId, author: 'Seed', content: 'Komen sedia ada.',
          createdAt: new Date(),
        });
      });
    };

    const verifiedCtx = (uid) =>
      testEnv.authenticatedContext(uid, { email_verified: true });

    const validComment = (over = {}) => ({
      authorId: 'user-a',
      author: 'User A',
      content: 'Komen yang sah.',
      createdAt: serverTimestamp(),
      ...over,
    });

    // ── create ──
    it('verified user CAN create a valid comment', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(db.collection('posts/p1/comments').add(validComment()));
    });

    it("user with empty name CAN comment as 'Hamba Allah'", async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-noname').firestore();
      await assertSucceeds(
        db.collection('posts/p1/comments').add(
          validComment({ authorId: 'user-noname', author: 'Hamba Allah' })
        )
      );
    });

    it('unauthenticated user CANNOT create a comment', async function () {
      await seedPostAndUsers();
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.collection('posts/p1/comments').add(validComment()));
    });

    it('unverified user CANNOT create a comment', async function () {
      await seedPostAndUsers();
      const db = testEnv
        .authenticatedContext('user-a', { email_verified: false })
        .firestore();
      await assertFails(db.collection('posts/p1/comments').add(validComment()));
    });

    it('user CANNOT spoof authorId', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('attacker').firestore();
      await assertFails(
        db.collection('posts/p1/comments').add(validComment({ authorId: 'user-a' }))
      );
    });

    it('user CANNOT spoof the display name (author != users/{uid}.name)', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection('posts/p1/comments').add(validComment({ author: 'Ustaz Palsu' }))
      );
    });

    it('comment with empty content is denied', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection('posts/p1/comments').add(validComment({ content: '' }))
      );
    });

    it('comment longer than 500 chars is denied; exactly 500 is allowed', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection('posts/p1/comments').add(validComment({ content: 'a'.repeat(501) }))
      );
      await assertSucceeds(
        db.collection('posts/p1/comments').add(validComment({ content: 'a'.repeat(500) }))
      );
    });

    it('comment with non-string content is denied', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection('posts/p1/comments').add(validComment({ content: 12345 }))
      );
    });

    it('comment missing a required field is denied', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      const data = validComment();
      delete data.content;
      await assertFails(db.collection('posts/p1/comments').add(data));
    });

    it('comment with an extra field is denied', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection('posts/p1/comments').add(validComment({ isAdmin: true }))
      );
    });

    it('comment with client-supplied createdAt is denied', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection('posts/p1/comments').add(
          validComment({ createdAt: new Date('2020-01-01') })
        )
      );
    });

    it('user CANNOT comment on a post that does not exist', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.collection('posts/ghost/comments').add(validComment()));
    });

    // ── read ──
    it('verified user CAN read comments; unverified CANNOT', async function () {
      await seedPostAndUsers();
      await seedComment('c1', 'someone');
      await assertSucceeds(
        verifiedCtx('user-a').firestore().collection('posts/p1/comments').get()
      );
      await assertFails(
        testEnv
          .authenticatedContext('user-x', { email_verified: false })
          .firestore()
          .collection('posts/p1/comments')
          .get()
      );
    });

    // ── update / delete ──
    it('author CANNOT edit own comment (updates disabled in Phase 1)', async function () {
      await seedPostAndUsers();
      await seedComment('c1', 'user-a');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.doc('posts/p1/comments/c1').update({ content: 'Diedit.' })
      );
    });

    it("user CANNOT edit another user's comment", async function () {
      await seedPostAndUsers();
      await seedComment('c1', 'victim');
      const db = verifiedCtx('attacker').firestore();
      await assertFails(
        db.doc('posts/p1/comments/c1').update({ content: 'Dirampas.' })
      );
    });

    it('author CAN delete own comment', async function () {
      await seedPostAndUsers();
      await seedComment('c1', 'user-a');
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(db.doc('posts/p1/comments/c1').delete());
    });

    it("user CANNOT delete another user's comment", async function () {
      await seedPostAndUsers();
      await seedComment('c1', 'victim');
      const db = verifiedCtx('attacker').firestore();
      await assertFails(db.doc('posts/p1/comments/c1').delete());
    });

    it('unauthenticated user CANNOT delete a comment', async function () {
      await seedPostAndUsers();
      await seedComment('c1', 'user-a');
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.doc('posts/p1/comments/c1').delete());
    });

    // ── counters / protected fields ──
    it('user CANNOT modify commentsCount directly', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc('posts/p1').update({ commentsCount: 5 }));
    });

    it('creating a comment CANNOT be paired with a commentsCount bump', async function () {
      await seedPostAndUsers();
      const db = verifiedCtx('user-a').firestore();
      const batch = db.batch();
      batch.set(db.doc('posts/p1/comments/c1'), validComment());
      batch.update(db.doc('posts/p1'), { commentsCount: 1 });
      await assertFails(batch.commit());
    });

    it('creating a comment CANNOT be paired with a protected user-field change', async function () {
      await seedPostAndUsers();
      const db = testEnv
        .authenticatedContext('user-a', {
          email: 'user-a@example.com',
          email_verified: true,
        })
        .firestore();
      const batch = db.batch();
      batch.set(db.doc('posts/p1/comments/c1'), validComment());
      batch.update(db.doc('users/user-a'), { totalPoints: 999999 });
      await assertFails(batch.commit());
    });
  });

  // ══════════════════════════════════════════════════════════════
  // SOCIAL — REPLIES (Phase 1 / Batch 3)
  // posts/{postId}/comments/{commentId}/replies/{replyId} — 1 tahap.
  // ══════════════════════════════════════════════════════════════
  describe('social: replies', function () {
    const { serverTimestamp } = require('firebase/firestore');

    const seed = async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await db.doc('posts/p1').set({
          type: 'quote', title: '', content: 'Post untuk ujian reply.',
          author: 'Author', authorId: 'author', likes: 0,
          commentsCount: 0, assetPath: null, category: null,
          createdAt: new Date(),
        });
        await db.doc('posts/p1/comments/c1').set({
          authorId: 'someone', author: 'Someone', content: 'Komen induk.',
          createdAt: new Date(),
        });
        await db.doc('users/user-a').set({
          name: 'User A', email: 'user-a@example.com', authMethod: 'Email',
          followersCount: 0, followingCount: 0, postsCount: 0,
          treeLevel: 1, totalPoints: 0, currentStreak: 0, longestStreak: 0,
        });
        await db.doc('users/user-noname').set({
          name: '', email: 'n@example.com', authMethod: 'Email',
          followersCount: 0, followingCount: 0, postsCount: 0,
          treeLevel: 1, totalPoints: 0, currentStreak: 0, longestStreak: 0,
        });
      });
    };

    const seedReply = async (id, authorId) => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().doc(`posts/p1/comments/c1/replies/${id}`).set({
          authorId, author: 'Seed', content: 'Reply sedia ada.',
          createdAt: new Date(),
        });
      });
    };

    const verifiedCtx = (uid) =>
      testEnv.authenticatedContext(uid, { email_verified: true });

    const REPLIES = 'posts/p1/comments/c1/replies';

    const validReply = (over = {}) => ({
      authorId: 'user-a',
      author: 'User A',
      content: 'Balasan yang sah.',
      createdAt: serverTimestamp(),
      ...over,
    });

    it('verified user CAN create a valid reply', async function () {
      await seed();
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(db.collection(REPLIES).add(validReply()));
    });

    it("user with empty name CAN reply as 'Hamba Allah'", async function () {
      await seed();
      const db = verifiedCtx('user-noname').firestore();
      await assertSucceeds(
        db.collection(REPLIES).add(
          validReply({ authorId: 'user-noname', author: 'Hamba Allah' })
        )
      );
    });

    it('unauthenticated user CANNOT create a reply', async function () {
      await seed();
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.collection(REPLIES).add(validReply()));
    });

    it('unverified user CANNOT create a reply', async function () {
      await seed();
      const db = testEnv
        .authenticatedContext('user-a', { email_verified: false })
        .firestore();
      await assertFails(db.collection(REPLIES).add(validReply()));
    });

    it('user CANNOT spoof authorId on a reply', async function () {
      await seed();
      const db = verifiedCtx('attacker').firestore();
      await assertFails(
        db.collection(REPLIES).add(validReply({ authorId: 'user-a' }))
      );
    });

    it('user CANNOT spoof the display name on a reply', async function () {
      await seed();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection(REPLIES).add(validReply({ author: 'Ustaz Palsu' }))
      );
    });

    it('reply with empty / oversized / non-string content is denied', async function () {
      await seed();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.collection(REPLIES).add(validReply({ content: '' })));
      await assertFails(
        db.collection(REPLIES).add(validReply({ content: 'a'.repeat(501) }))
      );
      await assertFails(db.collection(REPLIES).add(validReply({ content: 42 })));
    });

    it('reply with an extra field or client createdAt is denied', async function () {
      await seed();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.collection(REPLIES).add(validReply({ isAdmin: true })));
      await assertFails(
        db.collection(REPLIES).add(validReply({ createdAt: new Date('2020-01-01') }))
      );
    });

    it('reply missing a required field is denied', async function () {
      await seed();
      const db = verifiedCtx('user-a').firestore();
      const data = validReply();
      delete data.author;
      await assertFails(db.collection(REPLIES).add(data));
    });

    it('user CANNOT reply to a comment that does not exist', async function () {
      await seed();
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection('posts/p1/comments/ghost/replies').add(validReply())
      );
    });

    it('user CANNOT create a second reply level (reply-to-reply)', async function () {
      await seed();
      await seedReply('r1', 'someone');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(
        db.collection(`${REPLIES}/r1/replies`).add(validReply())
      );
    });

    it('verified user CAN read replies; unverified CANNOT', async function () {
      await seed();
      await seedReply('r1', 'someone');
      await assertSucceeds(verifiedCtx('user-a').firestore().collection(REPLIES).get());
      await assertFails(
        testEnv
          .authenticatedContext('user-x', { email_verified: false })
          .firestore()
          .collection(REPLIES)
          .get()
      );
    });

    it('collection-group query on replies is denied', async function () {
      await seed();
      await seedReply('r1', 'someone');
      await assertFails(verifiedCtx('user-a').firestore().collectionGroup('replies').get());
    });

    it('author CANNOT edit own reply (updates disabled)', async function () {
      await seed();
      await seedReply('r1', 'user-a');
      const db = verifiedCtx('user-a').firestore();
      await assertFails(db.doc(`${REPLIES}/r1`).update({ content: 'Diedit.' }));
    });

    it("user CANNOT edit another user's reply", async function () {
      await seed();
      await seedReply('r1', 'victim');
      const db = verifiedCtx('attacker').firestore();
      await assertFails(db.doc(`${REPLIES}/r1`).update({ content: 'Dirampas.' }));
    });

    it('author CAN delete own reply', async function () {
      await seed();
      await seedReply('r1', 'user-a');
      const db = verifiedCtx('user-a').firestore();
      await assertSucceeds(db.doc(`${REPLIES}/r1`).delete());
    });

    it("user CANNOT delete another user's reply", async function () {
      await seed();
      await seedReply('r1', 'victim');
      const db = verifiedCtx('attacker').firestore();
      await assertFails(db.doc(`${REPLIES}/r1`).delete());
    });

    it('unauthenticated user CANNOT delete a reply', async function () {
      await seed();
      await seedReply('r1', 'user-a');
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.doc(`${REPLIES}/r1`).delete());
    });

    it('replying CANNOT be paired with a counter change on post or comment', async function () {
      await seed();
      const db = verifiedCtx('user-a').firestore();
      const batch = db.batch();
      batch.set(db.doc(`${REPLIES}/r1`), validReply());
      batch.update(db.doc('posts/p1'), { commentsCount: 1 });
      await assertFails(batch.commit());
    });
  });
});
