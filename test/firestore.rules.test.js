const fs = require('fs');
const assert = require('assert');
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
  // POSTS — kontrak create / edit / delete (Post bundle audit)
  // Rules sengaja TIDAK membenarkan edit post (hanya `likes` ±1 yang
  // berpasangan dgn like doc). Ujian edit di sini mengunci kontrak itu:
  // pemilik pun tak boleh ubah authorId / createdAt / likes /
  // commentsCount / kandungan, dan orang lain lagi tak boleh.
  // ══════════════════════════════════════════════════════════════
  describe('posts: create / edit / delete contract', function () {
    const { serverTimestamp } = require('firebase/firestore');

    const seedUsers = async (creatorName = 'Test User') => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        const db = context.firestore();
        await db.doc('users/creator').set({ name: creatorName });
        await db.doc('users/other').set({ name: 'Other User' });
      });
    };

    const seedPost = async () => {
      await testEnv.withSecurityRulesDisabled(async (context) => {
        await context.firestore().doc('posts/p1').set({
          type: 'article',
          title: 'Tajuk asal',
          content: 'Kandungan asal post ini.',
          author: 'Test User',
          authorId: 'creator',
          likes: 3,
          commentsCount: 0,
          assetPath: null,
          category: null,
          createdAt: new Date('2026-01-01T00:00:00Z'),
        });
      });
    };

    const verifiedCtx = (uid) =>
      testEnv.authenticatedContext(uid, { email_verified: true });

    const validPost = (over = {}) => ({
      type: 'article',
      title: 'Tajuk ringkas',
      content: 'Kandungan post yang sah.',
      author: 'Test User',
      authorId: 'creator',
      likes: 0,
      commentsCount: 0,
      assetPath: null,
      category: null,
      createdAt: serverTimestamp(),
      ...over,
    });

    const createPost = (ctx, data) =>
      ctx.firestore().collection('posts').add(data);

    // Buang satu medan daripada payload sah.
    const without = (key) => {
      const d = validPost();
      delete d[key];
      return d;
    };

    // ── CREATE ──────────────────────────────────────────────────
    it('verified user CAN create an article post with a title', async function () {
      await seedUsers();
      await assertSucceeds(createPost(verifiedCtx('creator'), validPost()));
    });

    it("empty profile name CAN post as 'Hamba Allah'", async function () {
      await seedUsers('');
      await assertSucceeds(
        createPost(verifiedCtx('creator'), validPost({ author: 'Hamba Allah' }))
      );
    });

    it('create with a type outside article/quote is denied', async function () {
      await seedUsers();
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ type: 'video' }))
      );
    });

    it('title: exactly 80 chars is allowed, 81 is denied', async function () {
      await seedUsers();
      await assertSucceeds(
        createPost(verifiedCtx('creator'), validPost({ title: 'a'.repeat(80) }))
      );
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ title: 'a'.repeat(81) }))
      );
    });

    it('content: 10 and 1000 chars are allowed, 1001 is denied', async function () {
      await seedUsers();
      await assertSucceeds(
        createPost(verifiedCtx('creator'), validPost({ content: 'x'.repeat(10) }))
      );
      await assertSucceeds(
        createPost(verifiedCtx('creator'), validPost({ content: 'x'.repeat(1000) }))
      );
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ content: 'x'.repeat(1001) }))
      );
    });

    it('create with non-string title / content is denied', async function () {
      await seedUsers();
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ title: 123 }))
      );
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ content: 1234567890123 }))
      );
    });

    it('create with a missing required field is denied (title, createdAt)', async function () {
      await seedUsers();
      await assertFails(createPost(verifiedCtx('creator'), without('title')));
      await assertFails(createPost(verifiedCtx('creator'), without('createdAt')));
    });

    it('create with client-supplied createdAt (not server time) is denied', async function () {
      await seedUsers();
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ createdAt: new Date() }))
      );
    });

    it('create with a spoofed author display name is denied', async function () {
      await seedUsers();
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ author: 'Other User' }))
      );
    });

    it('create with commentsCount != 0 or non-int likes is denied', async function () {
      await seedUsers();
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ commentsCount: 1 }))
      );
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ likes: '0' }))
      );
    });

    it('create with non-string assetPath / category is denied', async function () {
      await seedUsers();
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ assetPath: 123 }))
      );
      await assertFails(
        createPost(verifiedCtx('creator'), validPost({ category: 123 }))
      );
    });

    // ── EDIT (semua ditolak: kontrak semasa) ────────────────────
    it('owner CANNOT edit title or content of own post', async function () {
      await seedUsers();
      await seedPost();
      const db = verifiedCtx('creator').firestore();
      await assertFails(db.doc('posts/p1').update({ title: 'Tajuk baharu' }));
      await assertFails(db.doc('posts/p1').update({ content: 'Kandungan baharu.' }));
    });

    it('owner CANNOT change authorId (ownership transfer)', async function () {
      await seedUsers();
      await seedPost();
      const db = verifiedCtx('creator').firestore();
      await assertFails(db.doc('posts/p1').update({ authorId: 'other' }));
    });

    it('owner CANNOT change createdAt', async function () {
      await seedUsers();
      await seedPost();
      const db = verifiedCtx('creator').firestore();
      await assertFails(db.doc('posts/p1').update({ createdAt: new Date() }));
    });

    it('owner CANNOT set likes or commentsCount directly', async function () {
      await seedUsers();
      await seedPost();
      const db = verifiedCtx('creator').firestore();
      await assertFails(db.doc('posts/p1').update({ likes: 999 }));
      await assertFails(db.doc('posts/p1').update({ commentsCount: 5 }));
    });

    it('owner CANNOT add an updatedAt or other unknown field', async function () {
      await seedUsers();
      await seedPost();
      const db = verifiedCtx('creator').firestore();
      await assertFails(db.doc('posts/p1').update({ updatedAt: serverTimestamp() }));
      await assertFails(db.doc('posts/p1').update({ isAdmin: true }));
    });

    it("another user CANNOT edit someone else's post", async function () {
      await seedUsers();
      await seedPost();
      const db = verifiedCtx('other').firestore();
      await assertFails(db.doc('posts/p1').update({ content: 'Dirampas.' }));
    });

    it("another user CANNOT take over a post by setting authorId to themselves", async function () {
      await seedUsers();
      await seedPost();
      const db = verifiedCtx('other').firestore();
      await assertFails(db.doc('posts/p1').update({ authorId: 'other' }));
    });

    it('unauthenticated user CANNOT edit a post', async function () {
      await seedUsers();
      await seedPost();
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.doc('posts/p1').update({ content: 'Tanpa login.' }));
    });

    // ── DELETE (owner CAN / another CANNOT sudah dilindungi di atas:
    //    'owner CAN delete own post' & 'user CANNOT delete another users post') ──
    it('unauthenticated user CANNOT delete a post', async function () {
      await seedUsers();
      await seedPost();
      const db = testEnv.unauthenticatedContext().firestore();
      await assertFails(db.doc('posts/p1').delete());
    });

    it('owner with an UNVERIFIED email CANNOT delete own post', async function () {
      await seedUsers();
      await seedPost();
      const db = testEnv
        .authenticatedContext('creator', { email_verified: false })
        .firestore();
      await assertFails(db.doc('posts/p1').delete());
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

    // ── Laluan SERVICE: transaction ala SocialService.setLiked ────
    // Ujian di atas guna batch dgn kiraan eksplisit. Blok ini menjalankan
    // runTransaction + FieldValue.increment (bentuk sebenar setLiked) dan
    // operasi serentak, supaya race betul-betul diuji terhadap rules.
    describe('service-shaped transactions (mirror of SocialService.setLiked)', function () {
      this.timeout(30000);
      const { increment } = require('firebase/firestore');

      // Cermin setLiked() dalam lib/services/social_service.dart.
      // Ujian "mirror matches" di bawah menjaga ia tak tersasar.
      const setLikedTx = (db, uid, like) =>
        db.runTransaction(async (tx) => {
          const postRef = db.doc('posts/p1');
          const likeRef = db.doc(`posts/p1/likes/${uid}`);
          const snap = await tx.get(likeRef);
          if (like) {
            if (snap.exists) return;
            tx.set(likeRef, { createdAt: serverTimestamp() });
            tx.update(postRef, { likes: increment(1) });
          } else {
            if (!snap.exists) return;
            tx.delete(likeRef);
            tx.update(postRef, { likes: increment(-1) });
          }
        });

      // withSecurityRulesDisabled() (rules-unit-testing 5.x) memulangkan
      // Promise<void> dan MEMBUANG nilai pulangan callback, jadi keadaan
      // ditangkap dalam pembolehubah luar dan dipulangkan selepas await.
      const readState = async (uids) => {
        let state;
        await testEnv.withSecurityRulesDisabled(async (context) => {
          const db = context.firestore();
          const post = await db.doc('posts/p1').get();
          const docs = {};
          for (const uid of uids) {
            docs[uid] = (await db.doc(`posts/p1/likes/${uid}`).get()).exists;
          }
          state = {
            postExists: post.exists,
            likes: post.exists ? post.data().likes : undefined,
            docs,
            likeDocCount: Object.values(docs).filter(Boolean).length,
          };
        });
        return state;
      };

      // Post dengan medan `likes` mentah (rosak / tiada) — tak boleh
      // dicipta melalui rules, jadi di-seed dgn rules dimatikan.
      const seedRawPost = async (likesField) => {
        await testEnv.withSecurityRulesDisabled(async (context) => {
          const data = {
            type: 'quote',
            title: '',
            content: 'Post untuk ujian like.',
            author: 'Author',
            authorId: 'author',
            commentsCount: 0,
            assetPath: null,
            category: null,
            createdAt: new Date(),
          };
          if (likesField.present) data.likes = likesField.value;
          await context.firestore().doc('posts/p1').set(data);
        });
      };

      it('mirror matches lib/services/social_service.dart setLiked()', function () {
        const src = fs.readFileSync('lib/services/social_service.dart', 'utf8');
        const start = src.indexOf('Future<Result<bool, SocialFailure>> setLiked(');
        const end = src.indexOf('// ── COMMENT', start);
        assert.ok(start > -1);
        assert.ok(end > start);
        const body = src.slice(start, end).replace(/\s+/g, ' ');
        for (const needle of [
          'runTransaction<void>',
          'await tx.get(likeRef)',
          'if (snap.exists) return;',
          'if (!snap.exists) return;',
          'tx.set(likeRef',
          'FieldValue.increment(1)',
          'tx.delete(likeRef)',
          'FieldValue.increment(-1)',
        ]) {
          assert.ok(body.includes(needle), `hilang: ${needle}`);
        }
        // Tiada tulis di luar transaction.
        assert.ok(!body.includes('likeRef.set('));
        assert.ok(!body.includes('likeRef.delete('));
        assert.ok(!body.includes('postRef.update('));
      });

      it('single like via transaction: like doc created and likes +1', async function () {
        await seedPost(0);
        const db = verifiedCtx('user-a').firestore();
        await assertSucceeds(setLikedTx(db, 'user-a', true));
        const st = await readState(['user-a']);
        assert.strictEqual(st.docs['user-a'], true);
        assert.strictEqual(st.likes, 1);
      });

      it('single unlike via transaction: like doc deleted and likes -1', async function () {
        await seedPost(1);
        await seedLike('user-a');
        const db = verifiedCtx('user-a').firestore();
        await assertSucceeds(setLikedTx(db, 'user-a', false));
        const st = await readState(['user-a']);
        assert.strictEqual(st.docs['user-a'], false);
        assert.strictEqual(st.likes, 0);
      });

      it('unlike WITHOUT a like doc is a no-op (likes stays 0, never -1)', async function () {
        await seedPost(0);
        const db = verifiedCtx('user-a').firestore();
        await assertSucceeds(setLikedTx(db, 'user-a', false));
        const st = await readState(['user-a']);
        assert.strictEqual(st.docs['user-a'], false);
        assert.strictEqual(st.likes, 0);
      });

      it('like on an already-liked post is a no-op (no double increment)', async function () {
        await seedPost(1);
        await seedLike('user-a');
        const db = verifiedCtx('user-a').firestore();
        await assertSucceeds(setLikedTx(db, 'user-a', true));
        const st = await readState(['user-a']);
        assert.strictEqual(st.docs['user-a'], true);
        assert.strictEqual(st.likes, 1);
      });

      // Pada ujian serentak, yang dikunci ialah INTEGRITI keadaan akhir
      // (kiraan == bilangan like doc). Sama ada transaction kalah-perlumbaan
      // diulang senyap atau ditolak bergantung pada pelayan, jadi hasil
      // setiap janji tidak dikunci; sekurang-kurangnya satu mesti berjaya.
      const settle = async (promises) => {
        const results = await Promise.allSettled(promises);
        assert.ok(results.some((r) => r.status === 'fulfilled'));
        return results;
      };

      it('CONCURRENT like × like (same user): one like doc, likes = 1', async function () {
        await seedPost(0);
        const db = verifiedCtx('user-a').firestore();
        await settle([
          setLikedTx(db, 'user-a', true),
          setLikedTx(db, 'user-a', true),
        ]);
        const st = await readState(['user-a']);
        assert.strictEqual(st.docs['user-a'], true);
        assert.strictEqual(st.likes, 1);
      });

      it('CONCURRENT unlike × unlike (same user): no like doc, likes = 0 (never negative)', async function () {
        await seedPost(1);
        await seedLike('user-a');
        const db = verifiedCtx('user-a').firestore();
        await settle([
          setLikedTx(db, 'user-a', false),
          setLikedTx(db, 'user-a', false),
        ]);
        const st = await readState(['user-a']);
        assert.strictEqual(st.docs['user-a'], false);
        assert.strictEqual(st.likes, 0);
      });

      it('CONCURRENT like × unlike (same user, starting liked): likes == number of like docs', async function () {
        await seedPost(1);
        await seedLike('user-a');
        const db = verifiedCtx('user-a').firestore();
        await settle([
          setLikedTx(db, 'user-a', true),
          setLikedTx(db, 'user-a', false),
        ]);
        const st = await readState(['user-a']);
        assert.strictEqual(st.likes, st.likeDocCount);
        assert.ok([0, 1].includes(st.likes));
      });

      it('CONCURRENT like by user A × like by user B: two like docs, likes = 2', async function () {
        await seedPost(0);
        const dbA = verifiedCtx('user-a').firestore();
        const dbB = verifiedCtx('user-b').firestore();
        await settle([
          setLikedTx(dbA, 'user-a', true),
          setLikedTx(dbB, 'user-b', true),
        ]);
        const st = await readState(['user-a', 'user-b']);
        assert.strictEqual(st.likes, st.likeDocCount);
        assert.strictEqual(st.likes, 2);
      });

      // ── Post tiada / orphan ──────────────────────────────────
      it('like on a MISSING post fails atomically (no orphan like doc)', async function () {
        const db = verifiedCtx('user-a').firestore();
        await assertFails(
          db.runTransaction(async (tx) => {
            const postRef = db.doc('posts/ghost');
            const likeRef = db.doc('posts/ghost/likes/user-a');
            const snap = await tx.get(likeRef);
            if (!snap.exists) {
              tx.set(likeRef, { createdAt: serverTimestamp() });
              tx.update(postRef, { likes: increment(1) });
            }
          })
        );
        await testEnv.withSecurityRulesDisabled(async (context) => {
          const snap = await context.firestore().doc('posts/ghost/likes/user-a').get();
          assert.strictEqual(snap.exists, false);
        });
      });

      it('unlike of an orphan like via the transaction fails ATOMICALLY; direct cleanup still works', async function () {
        // Post sudah dipadam tetapi like doc yatim masih ada.
        await testEnv.withSecurityRulesDisabled(async (context) => {
          await context.firestore().doc('posts/p1/likes/user-a').set({
            createdAt: new Date(),
          });
        });
        const db = verifiedCtx('user-a').firestore();

        // Laluan setLiked(false): tx.update(post) pada post tiada → gagal,
        // jadi padam like turut digulung balik (tiada separuh-tulis).
        await assertFails(setLikedTx(db, 'user-a', false));
        let st = await readState(['user-a']);
        assert.strictEqual(st.postExists, false);
        assert.strictEqual(st.docs['user-a'], true);

        // Rules sengaja benarkan pembersihan like yatim sendiri.
        await assertSucceeds(db.doc('posts/p1/likes/user-a').delete());
        st = await readState(['user-a']);
        assert.strictEqual(st.docs['user-a'], false);
      });

      // ── Kaunter rosak (tak boleh dicipta melalui rules) ─────
      it('like is denied when posts.likes is a string (no like doc created)', async function () {
        await seedRawPost({ present: true, value: 'abc' });
        const db = verifiedCtx('user-a').firestore();
        await assertFails(setLikedTx(db, 'user-a', true));
        const st = await readState(['user-a']);
        assert.strictEqual(st.docs['user-a'], false);
        assert.strictEqual(st.likes, 'abc');
      });

      it('like is denied when posts.likes is missing (no like doc created)', async function () {
        await seedRawPost({ present: false });
        const db = verifiedCtx('user-a').firestore();
        await assertFails(setLikedTx(db, 'user-a', true));
        const st = await readState(['user-a']);
        assert.strictEqual(st.docs['user-a'], false);
        assert.strictEqual(st.likes, undefined);
      });

      it('DRIFT: unlike is denied when a like doc exists but likes == 0 (state unchanged)', async function () {
        // Didokumenkan sebagai risiko data-rosak: kaunter tak boleh jadi -1,
        // jadi unlike tak boleh diselesaikan sehingga data dibetulkan.
        await seedPost(0);
        await seedLike('user-a');
        const db = verifiedCtx('user-a').firestore();
        await assertFails(setLikedTx(db, 'user-a', false));
        const st = await readState(['user-a']);
        assert.strictEqual(st.docs['user-a'], true);
        assert.strictEqual(st.likes, 0);
      });
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

    // ── count() — aggregate yang digunakan UI (SocialService.commentCount) ──
    // UI TIDAK membaca posts.commentsCount (kekal 0); ia memanggil
    // collection('posts/{p}/comments').count().get(). Compat SDK tiada
    // count(), jadi guna getCountFromServer (modular) pada instance yang sama.
    // Kebenaran dijangka mengikut `allow read: if verified()` — ujian ini
    // merekod behavior sebenar rules, bukan mengubahnya.
    describe('count() aggregate (as used by the UI)', function () {
      const { collection, getCountFromServer } = require('firebase/firestore');

      const countComments = (db) =>
        getCountFromServer(collection(db, 'posts/p1/comments'));

      const seedReply = async (commentId, replyId) => {
        await testEnv.withSecurityRulesDisabled(async (context) => {
          await context
            .firestore()
            .doc(`posts/p1/comments/${commentId}/replies/${replyId}`)
            .set({
              authorId: 'someone', author: 'Seed',
              content: 'Reply sedia ada.', createdAt: new Date(),
            });
        });
      };

      it('verified user CAN count() comments; result = comment docs, ignoring posts.commentsCount', async function () {
        await seedPostAndUsers(); // posts/p1.commentsCount == 0
        await seedComment('c1', 'someone');
        await seedComment('c2', 'someone-else');
        const snap = await assertSucceeds(
          countComments(verifiedCtx('user-a').firestore())
        );
        assert.strictEqual(snap.data().count, 2);
      });

      it('count() on a post with no comments returns 0', async function () {
        await seedPostAndUsers();
        const snap = await assertSucceeds(
          countComments(verifiedCtx('user-a').firestore())
        );
        assert.strictEqual(snap.data().count, 0);
      });

      it('count() does NOT include replies (they live in a subcollection)', async function () {
        await seedPostAndUsers();
        await seedComment('c1', 'someone');
        await seedReply('c1', 'r1');
        await seedReply('c1', 'r2');
        const snap = await assertSucceeds(
          countComments(verifiedCtx('user-a').firestore())
        );
        assert.strictEqual(snap.data().count, 1);
      });

      it('count() reflects a deletion (server-computed, cannot drift)', async function () {
        await seedPostAndUsers();
        await seedComment('c1', 'user-a');
        await seedComment('c2', 'someone');
        const db = verifiedCtx('user-a').firestore();
        await assertSucceeds(db.doc('posts/p1/comments/c1').delete());
        const snap = await assertSucceeds(countComments(db));
        assert.strictEqual(snap.data().count, 1);
      });

      it('unverified user CANNOT count() comments', async function () {
        await seedPostAndUsers();
        await seedComment('c1', 'someone');
        await assertFails(
          countComments(
            testEnv
              .authenticatedContext('user-x', { email_verified: false })
              .firestore()
          )
        );
      });

      it('unauthenticated user CANNOT count() comments', async function () {
        await seedPostAndUsers();
        await seedComment('c1', 'someone');
        await assertFails(
          countComments(testEnv.unauthenticatedContext().firestore())
        );
      });
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

    // ── comment yang parent post-nya sudah tiada ──
    // Firestore tak cascade subcollection: padam post meninggalkan
    // posts/{p}/comments/* . Rules delete comment hanya menyemak verified +
    // pemilik (resource.data.authorId), bukan kewujudan post. Ujian merekod
    // keputusan sebenar; jika emulator memberi keputusan lain, itu dapatan
    // untuk dilaporkan, bukan untuk "dibetulkan" dalam bundle ini.
    describe('delete comment after the parent post is gone', function () {
      const assertPostGone = () =>
        testEnv.withSecurityRulesDisabled(async (context) => {
          const snap = await context.firestore().doc('posts/p1').get();
          assert.strictEqual(snap.exists, false, 'post sepatutnya sudah tiada');
          const c = await context.firestore().doc('posts/p1/comments/c1').get();
          assert.strictEqual(c.exists, true, 'comment sepatutnya masih ada');
        });

      it('owner CAN delete own comment after the post was removed (backend/admin path)', async function () {
        await seedPostAndUsers();
        await seedComment('c1', 'user-a');
        await testEnv.withSecurityRulesDisabled(async (context) => {
          await context.firestore().doc('posts/p1').delete();
        });
        await assertPostGone();

        const db = verifiedCtx('user-a').firestore();
        await assertSucceeds(db.doc('posts/p1/comments/c1').delete());
        await testEnv.withSecurityRulesDisabled(async (context) => {
          const c = await context.firestore().doc('posts/p1/comments/c1').get();
          assert.strictEqual(c.exists, false);
        });
      });

      it('owner CAN delete own comment after the POST OWNER removed the post via rules', async function () {
        await seedPostAndUsers(); // posts/p1.authorId == 'author'
        await seedComment('c1', 'user-a');
        await assertSucceeds(
          verifiedCtx('author').firestore().doc('posts/p1').delete()
        );
        await assertPostGone();

        const db = verifiedCtx('user-a').firestore();
        await assertSucceeds(db.doc('posts/p1/comments/c1').delete());
      });

      it("another user CANNOT delete someone else's comment after the post is gone", async function () {
        await seedPostAndUsers();
        await seedComment('c1', 'user-a');
        await testEnv.withSecurityRulesDisabled(async (context) => {
          await context.firestore().doc('posts/p1').delete();
        });
        await assertPostGone();

        await assertFails(
          verifiedCtx('attacker').firestore().doc('posts/p1/comments/c1').delete()
        );
        // Bekas post yang sudah dipadam juga tak memberi kuasa kepada pemilik post lama.
        await assertFails(
          verifiedCtx('author').firestore().doc('posts/p1/comments/c1').delete()
        );
      });
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

    // ── parent hilang: post / comment ─────────────────────────────
    // Firestore tak cascade subcollection. Rules reply hanya menyemak
    // `exists(comment)` untuk create, dan verified + pemilik untuk delete;
    // tiada semakan kewujudan post. Ujian merekod behavior rules SEKARANG
    // (bukan behavior yang dikehendaki). "Unauthenticated CANNOT delete"
    // sudah dilindungi ujian sedia ada di atas, jadi tidak diulang.
    describe('missing parent: orphan behaviour (current rules)', function () {
      const removeDoc = (path) =>
        testEnv.withSecurityRulesDisabled(async (context) => {
          await context.firestore().doc(path).delete();
        });

      // withSecurityRulesDisabled() (rules-unit-testing 5.x) memulangkan
      // Promise<void> dan membuang nilai pulangan callback; keadaan
      // ditangkap ke pembolehubah luar.
      const existsMap = async (paths) => {
        const out = {};
        await testEnv.withSecurityRulesDisabled(async (context) => {
          for (const path of paths) {
            out[path] = (await context.firestore().doc(path).get()).exists;
          }
        });
        return out;
      };

      const POST = 'posts/p1';
      const COMMENT = 'posts/p1/comments/c1';

      it('W1: reply CAN be created under an orphaned comment whose POST was deleted (records current behaviour)', async function () {
        await seed();
        await removeDoc(POST); // komen kekal: tiada cascade
        const before = await existsMap([POST, COMMENT]);
        assert.strictEqual(before[POST], false);
        assert.strictEqual(before[COMMENT], true);

        // Rule create reply hanya semak exists(comment), bukan post →
        // dijangka DIBENARKAN. Ini mengesahkan W1 (orphan-tree); jika rules
        // kelak menyemak post, tukar kepada assertFails.
        const db = verifiedCtx('user-a').firestore();
        await assertSucceeds(db.collection(REPLIES).add(validReply()));

        let size;
        await testEnv.withSecurityRulesDisabled(async (context) => {
          size = (await context.firestore().collection(REPLIES).get()).size;
        });
        assert.strictEqual(size, 1);
      });

      it('owner CAN delete own reply after the parent COMMENT was deleted', async function () {
        await seed();
        await seedReply('r1', 'user-a');
        await removeDoc(COMMENT); // reply kekal sebagai yatim
        const before = await existsMap([COMMENT, `${REPLIES}/r1`]);
        assert.strictEqual(before[COMMENT], false);
        assert.strictEqual(before[`${REPLIES}/r1`], true);

        const db = verifiedCtx('user-a').firestore();
        await assertSucceeds(db.doc(`${REPLIES}/r1`).delete());

        const after = await existsMap([`${REPLIES}/r1`]);
        assert.strictEqual(after[`${REPLIES}/r1`], false);
      });

      it("another user CANNOT delete someone else's reply after the parent COMMENT was deleted", async function () {
        await seed();
        await seedReply('r1', 'user-a');
        await removeDoc(COMMENT);

        await assertFails(
          verifiedCtx('attacker').firestore().doc(`${REPLIES}/r1`).delete()
        );
        // Penulis komen induk (dahulu) pun tak mewarisi kuasa ke atas reply.
        await assertFails(
          verifiedCtx('someone').firestore().doc(`${REPLIES}/r1`).delete()
        );
        const after = await existsMap([`${REPLIES}/r1`]);
        assert.strictEqual(after[`${REPLIES}/r1`], true);
      });

      it('owner CAN delete own reply when BOTH the post and the parent comment are gone', async function () {
        await seed();
        await seedReply('r1', 'user-a');
        await removeDoc(COMMENT);
        await removeDoc(POST);
        const before = await existsMap([POST, COMMENT, `${REPLIES}/r1`]);
        assert.strictEqual(before[POST], false);
        assert.strictEqual(before[COMMENT], false);
        assert.strictEqual(before[`${REPLIES}/r1`], true);

        const db = verifiedCtx('user-a').firestore();
        await assertSucceeds(db.doc(`${REPLIES}/r1`).delete());
      });
    });

    it('unverified user CANNOT delete own reply', async function () {
      await seed();
      await seedReply('r1', 'user-a');
      const db = testEnv
        .authenticatedContext('user-a', { email_verified: false })
        .firestore();
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
