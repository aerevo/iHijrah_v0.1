// test/reports.rules.test.js
// Ujian firestore.rules untuk laporan kandungan (reports/{reportId}), R1-9.
//
// Prinsip yang diuji:
// → Hanya pengguna yang e-mel disahkan dan tidak dibekukan boleh mencipta.
// → ID dokumen = pelapor_jenis_sasaran: laporan berganda ditolak.
// → Tiada laporan terhadap diri sendiri; tiada medan lain; sebab dan jenis
//   daripada senarai tetap; createdAt mesti masa pelayan.
// → Tiada klien boleh membaca, mengubah atau memadam laporan.
const fs = require('fs');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const { serverTimestamp } = require('firebase/firestore');

const PROJECT_ID = 'ihijrah-178fc';
const REPORTER = 'reporter';
const AUTHOR = 'author';

let testEnv;

const verifiedDb = (uid = REPORTER) =>
  testEnv
    .authenticatedContext(uid, { email: `${uid}@example.com`, email_verified: true })
    .firestore();

const unverifiedDb = (uid = REPORTER) =>
  testEnv
    .authenticatedContext(uid, { email: `${uid}@example.com`, email_verified: false })
    .firestore();

const reportId = (type, targetId, uid = REPORTER) => `${uid}_${type}_${targetId}`;

const reportDoc = (overrides = {}) => ({
  reporterId: REPORTER,
  targetType: 'post',
  targetId: 'post1',
  targetAuthorId: AUTHOR,
  reason: 'spam',
  createdAt: serverTimestamp(),
  ...overrides,
});

describe('iHijrah Firestore Rules — reports (laporan kandungan)', function () {
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

  it('pengguna disahkan BOLEH melapor post', async function () {
    await assertSucceeds(
      verifiedDb().doc(`reports/${reportId('post', 'post1')}`).set(reportDoc())
    );
  });

  it('pengguna disahkan BOLEH melapor komen (id guna ":")', async function () {
    const targetId = 'post1:comment1';
    await assertSucceeds(
      verifiedDb()
        .doc(`reports/${reportId('comment', targetId)}`)
        .set(reportDoc({ targetType: 'comment', targetId }))
    );
  });

  it('laporan sama kali kedua ditolak (create-only, id deterministik)', async function () {
    const ref = verifiedDb().doc(`reports/${reportId('post', 'post1')}`);
    await assertSucceeds(ref.set(reportDoc()));
    await assertFails(ref.set(reportDoc({ reason: 'palsu' })));
  });

  it('pengguna belum disahkan e-mel ditolak', async function () {
    await assertFails(
      unverifiedDb().doc(`reports/${reportId('post', 'post1')}`).set(reportDoc())
    );
  });

  it('tanpa log masuk ditolak', async function () {
    await assertFails(
      testEnv
        .unauthenticatedContext()
        .firestore()
        .doc(`reports/${reportId('post', 'post1')}`)
        .set(reportDoc())
    );
  });

  it('akaun yang sedang dipadam (dibekukan) ditolak', async function () {
    await testEnv.withSecurityRulesDisabled(async (ctx) => {
      await ctx.firestore().doc(`accountDeletionRequests/${REPORTER}`).set({
        uid: REPORTER,
        status: 'pending',
      });
    });
    await assertFails(
      verifiedDb().doc(`reports/${reportId('post', 'post1')}`).set(reportDoc())
    );
  });

  it('melapor diri sendiri ditolak', async function () {
    await assertFails(
      verifiedDb()
        .doc(`reports/${reportId('post', 'post1')}`)
        .set(reportDoc({ targetAuthorId: REPORTER }))
    );
  });

  it('reporterId yang bukan pengguna semasa ditolak', async function () {
    await assertFails(
      verifiedDb()
        .doc(`reports/${reportId('post', 'post1')}`)
        .set(reportDoc({ reporterId: 'orang-lain' }))
    );
  });

  it('ID dokumen yang tidak mengikut format ditolak', async function () {
    await assertFails(
      verifiedDb().doc('reports/rawak-id').set(reportDoc())
    );
  });

  it('sebab di luar senarai ditolak', async function () {
    await assertFails(
      verifiedDb()
        .doc(`reports/${reportId('post', 'post1')}`)
        .set(reportDoc({ reason: 'suka-suka' }))
    );
  });

  it('jenis sasaran di luar senarai ditolak', async function () {
    await assertFails(
      verifiedDb()
        .doc(`reports/${reportId('video', 'post1')}`)
        .set(reportDoc({ targetType: 'video' }))
    );
  });

  it('medan tambahan ditolak', async function () {
    await assertFails(
      verifiedDb()
        .doc(`reports/${reportId('post', 'post1')}`)
        .set(reportDoc({ catatan: 'teks bebas' }))
    );
  });

  it('medan wajib tertinggal ditolak', async function () {
    const doc = reportDoc();
    delete doc.reason;
    await assertFails(
      verifiedDb().doc(`reports/${reportId('post', 'post1')}`).set(doc)
    );
  });

  it('createdAt daripada jam klien (bukan masa pelayan) ditolak', async function () {
    await assertFails(
      verifiedDb()
        .doc(`reports/${reportId('post', 'post1')}`)
        .set(reportDoc({ createdAt: new Date('2020-01-01T00:00:00Z') }))
    );
  });

  it('tiada klien boleh membaca laporan, termasuk pelapor sendiri', async function () {
    const id = reportId('post', 'post1');
    await assertSucceeds(verifiedDb().doc(`reports/${id}`).set(reportDoc()));
    await assertFails(verifiedDb().doc(`reports/${id}`).get());
    await assertFails(verifiedDb(AUTHOR).doc(`reports/${id}`).get());
  });

  it('tiada klien boleh mengubah atau memadam laporan', async function () {
    const id = reportId('post', 'post1');
    await assertSucceeds(verifiedDb().doc(`reports/${id}`).set(reportDoc()));
    await assertFails(verifiedDb().doc(`reports/${id}`).update({ reason: 'palsu' }));
    await assertFails(verifiedDb().doc(`reports/${id}`).delete());
  });
});
