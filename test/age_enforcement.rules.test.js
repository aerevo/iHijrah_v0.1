// test/age_enforcement.rules.test.js
// Penguatkuasaan umur minimum (13) di Firestore Rules untuk users/{uid}.birthdate
// dan users/{uid}.hijriDOB. UI (onboarding + skrin edit DOB) hanyalah UX —
// ujian ini membuktikan klien yang menulis Firestore terus tidak boleh
// memintasnya.
//
// Tarikh sempadan dikira daripada jam semasa dalam UTC (request.time dalam
// rules ialah UTC) — tiada tarikh tetap yang akan "luput" bila umur berubah.
// Tarikh tetap digunakan hanya untuk kes yang tidak bergantung pada jam
// (dewasa jelas, format rosak, 29 Feb, tahun masa depan).
const fs = require('fs');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');

const PROJECT_ID = 'ihijrah-178fc';
const UID = 'age-user';
const EMAIL = 'age-user@example.com';

let testEnv;

// ── Tarikh dinamik (UTC) ───────────────────────────────────────
const pad = (n, w = 2) => String(n).padStart(w, '0');
const iso = (d) => `${pad(d.getUTCFullYear(), 4)}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
const isoDateTime = (d) => `${iso(d)}T00:00:00.000`;

// DOB yang genap 13 tahun HARI INI (UTC). Jika hari ini 29 Feb, tahun lahir
// (tahun-13) bukan lompat → guna 28 Feb (konvensyen age_helper.dart).
const exactly13Today = () => {
  const t = new Date();
  const day = t.getUTCMonth() === 1 && t.getUTCDate() === 29 ? 28 : t.getUTCDate();
  return new Date(Date.UTC(t.getUTCFullYear() - 13, t.getUTCMonth(), day));
};
// Genap 13 tahun ESOK → sehari kurang daripada 13 hari ini.
const oneDayUnder13 = () => {
  const d = exactly13Today();
  const t = new Date();
  // Jika hari ini 29 Feb, exactly13Today() ialah 28 Feb; +1 hari = 1 Mac,
  // yang masih lebih muda daripada ambang hari ini → ditolak.
  return new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate() + 1));
};
const yearsAgo = (n) => {
  const t = new Date();
  return new Date(Date.UTC(t.getUTCFullYear() - n, 5, 15)); // 15 Jun
};

describe('iHijrah Firestore Rules — minimum age enforcement (users.birthdate / hijriDOB)', function () {
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

  // ── Helper ───────────────────────────────────────────────────
  const client = () =>
    testEnv
      .authenticatedContext(UID, { email: EMAIL, email_verified: true })
      .firestore();

  // Bentuk dokumen penuh seperti UserModel (lihat ujian sedia ada).
  const fullDoc = (overrides = {}) => ({
    name: 'Age User',
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

  const seed = (overrides = {}) =>
    testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc(`users/${UID}`).set(fullDoc(overrides));
    });

  const read = async () => {
    let data;
    await testEnv.withSecurityRulesDisabled(async (context) => {
      data = (await context.firestore().doc(`users/${UID}`).get()).data();
    });
    return data;
  };

  const doc = () => client().doc(`users/${UID}`);

  // ══════════════════════════════════════════════════════════════
  // CREATE — dibenarkan
  // ══════════════════════════════════════════════════════════════
  describe('create: allowed', function () {
    it('user exactly 13 years old today CAN create the document', async function () {
      const dob = isoDateTime(exactly13Today());
      await assertSucceeds(doc().set(fullDoc({ birthdate: dob, hijriDOB: dob })));
    });

    it('adult user CAN create the document', async function () {
      await assertSucceeds(doc().set(fullDoc()));
    });

    it('adult with hijriDOB null (older client shape) CAN create', async function () {
      await assertSucceeds(doc().set(fullDoc({ hijriDOB: null })));
    });

    it('date-only and UTC (Z) representations of an adult DOB CAN be created', async function () {
      await assertSucceeds(doc().set(fullDoc({ birthdate: '1990-05-17', hijriDOB: '1990-05-17' })));
      await testEnv.clearFirestore();
      await assertSucceeds(
        doc().set(fullDoc({ birthdate: '1990-05-17T00:00:00.000Z', hijriDOB: '1990-05-17T00:00:00.000Z' }))
      );
    });

    it('leap-day DOB in a real leap year (2000-02-29) CAN be created', async function () {
      await assertSucceeds(doc().set(fullDoc({ birthdate: '2000-02-29', hijriDOB: '2000-02-29' })));
    });

    it('pre-onboarding document (no DOB yet) CAN be created', async function () {
      await assertSucceeds(doc().set(fullDoc({ birthdate: null, hijriDOB: null })));
    });
  });

  // ══════════════════════════════════════════════════════════════
  // CREATE — ditolak
  // ══════════════════════════════════════════════════════════════
  describe('create: denied', function () {
    it('user ONE DAY below 13 (turns 13 tomorrow) CANNOT create', async function () {
      const dob = isoDateTime(oneDayUnder13());
      await assertFails(doc().set(fullDoc({ birthdate: dob, hijriDOB: dob })));
    });

    it('clearly under-13 (5 years old) CANNOT create', async function () {
      const dob = isoDateTime(yearsAgo(5));
      await assertFails(doc().set(fullDoc({ birthdate: dob, hijriDOB: dob })));
    });

    it('born today CANNOT create', async function () {
      const dob = isoDateTime(new Date());
      await assertFails(doc().set(fullDoc({ birthdate: dob, hijriDOB: dob })));
    });

    it('future birthdate CANNOT create', async function () {
      await assertFails(doc().set(fullDoc({ birthdate: '2099-01-01T00:00:00.000', hijriDOB: '2099-01-01T00:00:00.000' })));
    });

    it('adult birthdate with an under-13 hijriDOB CANNOT create', async function () {
      const young = isoDateTime(yearsAgo(5));
      await assertFails(doc().set(fullDoc({ birthdate: '2000-01-01T00:00:00.000', hijriDOB: young })));
    });

    it('hijriDOB without birthdate CANNOT create (alternative DOB source)', async function () {
      const young = isoDateTime(yearsAgo(5));
      await assertFails(doc().set(fullDoc({ birthdate: null, hijriDOB: young })));
      await assertFails(doc().set(fullDoc({ birthdate: null, hijriDOB: '2000-01-01T00:00:00.000' })));
    });

    it('adult birthdate with a DIFFERENT adult hijriDOB CANNOT create (inconsistent)', async function () {
      await assertFails(doc().set(fullDoc({ birthdate: '2000-01-01T00:00:00.000', hijriDOB: '1990-01-01T00:00:00.000' })));
    });

    const malformed = [
      ['free text', 'not-a-date'],
      ['empty string', ''],
      ['number', 20000101],
      ['no separators', '20000101'],
      ['month 13', '2000-13-01'],
      ['month 00', '2000-00-10'],
      ['day 31 in a 30-day month', '2000-04-31'],
      ['29 Feb in a non-leap year', '2001-02-29'],
      ['29 Feb in 1900 (not a leap year)', '1900-02-29'],
      ['space instead of T', '2000-01-01 00:00:00'],
      ['non-padded fields', '2000-1-1'],
      ['timezone offset suffix', '2000-01-01T00:00:00+08:00'],
      ['year before 1900', '1899-12-31'],
      ['year after 2099', '2100-01-01'],
      ['boolean', true],
      ['map', { y: 2000 }],
    ];
    malformed.forEach(([label, value]) => {
      it(`malformed birthdate (${label}) CANNOT create`, async function () {
        await assertFails(doc().set(fullDoc({ birthdate: value, hijriDOB: null })));
      });
    });
  });

  // ══════════════════════════════════════════════════════════════
  // UPDATE — tingkah laku sah yang mesti kekal
  // ══════════════════════════════════════════════════════════════
  describe('update: legitimate behaviour preserved', function () {
    beforeEach(async function () {
      await seed();
    });

    it('unrelated field update CAN resend the unchanged valid DOB (UserModel pushes the whole map)', async function () {
      await assertSucceeds(
        doc().update({
          name: 'New Name',
          bio: 'Updated bio',
          birthdate: '2000-01-01T00:00:00.000',
          hijriDOB: '2000-01-01T00:00:00.000',
          themeMode: 'dark',
        })
      );
      const after = await read();
      if (after.birthdate !== '2000-01-01T00:00:00.000') {
        throw new Error('birthdate must remain unchanged');
      }
    });

    it('unrelated field update WITHOUT touching DOB CAN succeed', async function () {
      await assertSucceeds(doc().update({ themeMode: 'dark' }));
    });

    it('editing DOB to another adult date (both fields) CAN succeed — existing edit-DOB screen', async function () {
      await assertSucceeds(
        doc().update({ birthdate: '1995-03-10T00:00:00.000', hijriDOB: '1995-03-10T00:00:00.000' })
      );
    });

    it('editing DOB to exactly 13 today CAN succeed', async function () {
      const dob = isoDateTime(exactly13Today());
      await assertSucceeds(doc().update({ birthdate: dob, hijriDOB: dob }));
    });

    it('onboarding sequence CAN set DOB on a pre-onboarding document', async function () {
      await testEnv.clearFirestore();
      await seed({ birthdate: null, hijriDOB: null });
      await assertSucceeds(
        doc().update({ birthdate: '2001-07-07T00:00:00.000', hijriDOB: '2001-07-07T00:00:00.000' })
      );
    });

    it('legacy hijriDOB format on an unchanged document does NOT block unrelated updates', async function () {
      await testEnv.clearFirestore();
      await seed({ birthdate: '1990-01-01T00:00:00.000', hijriDOB: '1410/09/12' });
      await assertSucceeds(
        doc().update({
          themeMode: 'dark',
          birthdate: '1990-01-01T00:00:00.000',
          hijriDOB: '1410/09/12',
        })
      );
    });
  });

  // ══════════════════════════════════════════════════════════════
  // UPDATE — pintasan yang mesti ditolak
  // ══════════════════════════════════════════════════════════════
  describe('update: bypass attempts denied', function () {
    beforeEach(async function () {
      await seed();
    });

    const expectUnchanged = async () => {
      const after = await read();
      if (after.birthdate !== '2000-01-01T00:00:00.000' || after.hijriDOB !== '2000-01-01T00:00:00.000') {
        throw new Error('DOB must be unchanged after a denied write');
      }
    };

    it('existing adult CANNOT change DOB to under 13 (both fields)', async function () {
      const young = isoDateTime(yearsAgo(5));
      await assertFails(doc().update({ birthdate: young, hijriDOB: young }));
      await expectUnchanged();
    });

    it('existing adult CANNOT change DOB to ONE DAY below 13', async function () {
      const young = isoDateTime(oneDayUnder13());
      await assertFails(doc().update({ birthdate: young, hijriDOB: young }));
      await expectUnchanged();
    });

    it('existing adult CANNOT change ONLY birthdate to under 13', async function () {
      await assertFails(doc().update({ birthdate: isoDateTime(yearsAgo(5)) }));
      await expectUnchanged();
    });

    it('existing adult CANNOT change ONLY hijriDOB to under 13 (anti-bypass)', async function () {
      await assertFails(doc().update({ hijriDOB: isoDateTime(yearsAgo(5)) }));
      await expectUnchanged();
    });

    it('existing adult CANNOT change ONLY hijriDOB to a different adult value (inconsistent)', async function () {
      await assertFails(doc().update({ hijriDOB: '1990-01-01T00:00:00.000' }));
      await expectUnchanged();
    });

    it('existing adult CANNOT null the birthdate while leaving hijriDOB set', async function () {
      await assertFails(doc().update({ birthdate: null }));
      await expectUnchanged();
    });

    it('existing adult CANNOT null birthdate and put an under-13 value in hijriDOB', async function () {
      await assertFails(doc().update({ birthdate: null, hijriDOB: isoDateTime(yearsAgo(5)) }));
      await expectUnchanged();
    });

    it('existing adult CANNOT set a future birthdate', async function () {
      await assertFails(doc().update({ birthdate: '2099-01-01T00:00:00.000', hijriDOB: '2099-01-01T00:00:00.000' }));
      await expectUnchanged();
    });

    it('invalid DOB CANNOT be smuggled in alongside otherwise valid profile changes', async function () {
      const young = isoDateTime(yearsAgo(5));
      await assertFails(
        doc().update({
          name: 'Smuggler',
          bio: 'Valid bio',
          gender: 'Perempuan',
          themeMode: 'dark',
          birthdate: young,
          hijriDOB: young,
        })
      );
      const after = await read();
      if (after.name !== 'Age User') {
        throw new Error('no part of the rejected write may be applied');
      }
      await expectUnchanged();
    });

    it('invalid DOB CANNOT be smuggled inside a batch with otherwise valid changes', async function () {
      const db = client();
      const batch = db.batch();
      batch.update(db.doc(`users/${UID}`), { name: 'Batch Valid Name', themeMode: 'dark' });
      batch.update(db.doc(`users/${UID}`), { birthdate: isoDateTime(yearsAgo(5)), hijriDOB: isoDateTime(yearsAgo(5)) });
      await assertFails(batch.commit());
      const after = await read();
      if (after.name !== 'Age User') {
        throw new Error('batch must be atomic — nothing applied');
      }
      await expectUnchanged();
    });

    it('the same valid changes WITHOUT the invalid DOB succeed (control)', async function () {
      await assertSucceeds(doc().update({ name: 'Control Name', bio: 'Valid bio', themeMode: 'dark' }));
    });

    it('malformed replacement birthdate CANNOT be written', async function () {
      await assertFails(doc().update({ birthdate: 'not-a-date', hijriDOB: 'not-a-date' }));
      await assertFails(doc().update({ birthdate: 20000101, hijriDOB: null }));
      await assertFails(doc().update({ birthdate: '2001-02-29', hijriDOB: '2001-02-29' }));
      await expectUnchanged();
    });

    it('existing protections remain: counters and email still cannot be changed with a valid DOB', async function () {
      await assertFails(doc().update({ birthdate: '1995-03-10T00:00:00.000', hijriDOB: '1995-03-10T00:00:00.000', totalPoints: 999 }));
      await assertFails(doc().update({ birthdate: '1995-03-10T00:00:00.000', hijriDOB: '1995-03-10T00:00:00.000', email: 'other@example.com' }));
    });

    it("another user CANNOT edit this user's DOB", async function () {
      const other = testEnv
        .authenticatedContext('someone-else', { email: 'x@example.com', email_verified: true })
        .firestore();
      await assertFails(other.doc(`users/${UID}`).update({ birthdate: '1995-03-10T00:00:00.000', hijriDOB: '1995-03-10T00:00:00.000' }));
    });
  });
});
