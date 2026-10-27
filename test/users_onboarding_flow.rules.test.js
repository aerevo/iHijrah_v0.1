// test/users_onboarding_flow.rules.test.js
// Aliran onboarding: akaun BARU, dokumen users/{uid} belum wujud.
// Mengesahkan tingkah laku rules yang menjadi asas pembetulan UserModel
// (_doPushToCloud): update() pada dokumen tiada ditolak (permission-denied),
// manakala read dan create oleh pemilik dibenarkan.
const fs = require('fs');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const PROJECT_ID = 'ihijrah-178fc';
const UID = 'new-user';
const EMAIL = 'new-user@example.com';

let testEnv;

const fullDoc = (overrides = {}) => ({
  name: 'Hamba Allah',
  email: EMAIL,
  gender: 'Lelaki',
  bio: '',
  avatarPath: null,
  authMethod: 'Email',
  birthdate: '2000-01-01T00:00:00.000',
  hijriDOB: '2000-01-01T00:00:00.000',
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
  ...overrides,
});

describe('iHijrah Firestore Rules — users onboarding flow (dokumen belum wujud)', function () {
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

  // Token e-mel BELUM disahkan: rules users tidak mensyaratkan email_verified.
  const client = () =>
    testEnv
      .authenticatedContext(UID, { email: EMAIL, email_verified: false })
      .firestore();

  it('pemilik BOLEH baca dokumen sendiri yang belum wujud (get)', async function () {
    await assertSucceeds(client().doc(`users/${UID}`).get());
  });

  it('update() pada dokumen yang belum wujud DITOLAK (permission-denied, bukan not-found)', async function () {
    await assertFails(
      client().doc(`users/${UID}`).update({ name: 'Hamba Allah', bio: '' })
    );
  });

  it('pemilik BOLEH cipta dokumen dengan payload bentuk UserModel (set)', async function () {
    await assertSucceeds(client().doc(`users/${UID}`).set(fullDoc()));
  });

  it('cipta dengan e-mel tidak sepadan token DITOLAK', async function () {
    await assertFails(
      client().doc(`users/${UID}`).set(fullDoc({ email: 'lain@example.com' }))
    );
  });

  it('cipta dengan hijriDOB berbeza daripada birthdate DITOLAK', async function () {
    await assertFails(
      client()
        .doc(`users/${UID}`)
        .set(fullDoc({ hijriDOB: '1999-12-31T00:00:00.000' }))
    );
  });
});
