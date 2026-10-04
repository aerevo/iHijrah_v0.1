const fs = require('fs');
const {
  initializeTestEnvironment,
  assertSucceeds,
  assertFails,
} = require('@firebase/rules-unit-testing');
const { serverTimestamp } = require('firebase/firestore');

const PROJECT_ID = 'ihijrah-178fc';

let testEnv;

describe('iHijrah Firestore Rules — account deletion request F3-G', function () {
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

  const nowSeconds = () => Math.floor(Date.now() / 1000);

  const verifiedCtx = (uid, extra = {}) =>
    testEnv.authenticatedContext(uid, {
      email_verified: true,
      auth_time: nowSeconds(),
      ...extra,
    });

  const requestData = () => ({
    uid: 'user-a',
    status: 'pending',
    createdAt: serverTimestamp(),
  });

  it('verified owner with recent auth CAN create deletion request', async function () {
    const db = verifiedCtx('user-a').firestore();

    await assertSucceeds(
      db.doc('accountDeletionRequests/user-a').set(requestData())
    );
  });

  it('unauthenticated user CANNOT create deletion request', async function () {
    const db = testEnv.unauthenticatedContext().firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-a').set(requestData())
    );
  });

  it('unverified user CANNOT create deletion request', async function () {
    const db = testEnv.authenticatedContext('user-a', {
      email_verified: false,
      auth_time: nowSeconds(),
    }).firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-a').set(requestData())
    );
  });

  it('owner with stale auth_time CANNOT create deletion request', async function () {
    const db = testEnv.authenticatedContext('user-a', {
      email_verified: true,
      auth_time: nowSeconds() - 600,
    }).firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-a').set(requestData())
    );
  });

  it('user CANNOT create request for another UID', async function () {
    const db = verifiedCtx('user-a').firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-b').set({
        uid: 'user-b',
        status: 'pending',
        createdAt: serverTimestamp(),
      })
    );
  });

  it('request UID field CANNOT spoof authenticated UID', async function () {
    const db = verifiedCtx('user-a').firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-a').set({
        uid: 'user-b',
        status: 'pending',
        createdAt: serverTimestamp(),
      })
    );
  });

  it('non-pending status CANNOT be submitted by client', async function () {
    const db = verifiedCtx('user-a').firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-a').set({
        uid: 'user-a',
        status: 'processing',
        createdAt: serverTimestamp(),
      })
    );
  });

  it('client CANNOT add privileged/extra fields', async function () {
    const db = verifiedCtx('user-a').firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-a').set({
        uid: 'user-a',
        status: 'pending',
        createdAt: serverTimestamp(),
        phase: 'delete-auth',
        attempts: 1,
      })
    );
  });

  it('client CANNOT supply its own createdAt value', async function () {
    const db = verifiedCtx('user-a').firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-a').set({
        uid: 'user-a',
        status: 'pending',
        createdAt: new Date('2020-01-01T00:00:00.000Z'),
      })
    );
  });

  it('client CANNOT read deletion request lifecycle', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('accountDeletionRequests/user-a').set({
        uid: 'user-a',
        status: 'pending',
        createdAt: new Date(),
      });
    });

    const db = verifiedCtx('user-a').firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-a').get()
    );
  });

  it('client CANNOT update deletion request lifecycle', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('accountDeletionRequests/user-a').set({
        uid: 'user-a',
        status: 'pending',
        createdAt: new Date(),
      });
    });

    const db = verifiedCtx('user-a').firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-a').update({
        status: 'processing',
      })
    );
  });

  it('client CANNOT delete deletion request', async function () {
    await testEnv.withSecurityRulesDisabled(async (context) => {
      await context.firestore().doc('accountDeletionRequests/user-a').set({
        uid: 'user-a',
        status: 'pending',
        createdAt: new Date(),
      });
    });

    const db = verifiedCtx('user-a').firestore();

    await assertFails(
      db.doc('accountDeletionRequests/user-a').delete()
    );
  });

  it('duplicate deletion request CANNOT be created over existing request', async function () {
    const db = verifiedCtx('user-a').firestore();

    await assertSucceeds(
      db.doc('accountDeletionRequests/user-a').set(requestData())
    );

    await assertFails(
      db.doc('accountDeletionRequests/user-a').set(
        requestData(),
        { merge: false }
      )
    );
  });
});
