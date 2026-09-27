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
});
