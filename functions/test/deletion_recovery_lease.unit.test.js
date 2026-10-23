'use strict';

/*
 * EVIDENCE LEVELS (every test title carries one tag):
 *   [unit/fake]            in-memory Firestore fake below. Proves our LOGIC
 *                          under the fake's rules only.
 *   [sdk-offline/scripted] the real @google-cloud/firestore SDK, with the
 *                          network/RPC layer scripted. Proves request shapes
 *                          and SDK behaviour (e.g. retry after ABORTED), not
 *                          server behaviour.
 *   (none are [real-firestore]: no test here ran against a Firestore server
 *    or the official emulator.)
 *
 * What the fake does NOT model: server-side lock waits and lock-wait
 * timeouts, ABORTED after repeated contention, locking of non-existent
 * documents, per-document write-rate limits, UTF-8 byte ordering of ids, and
 * index requirements. Concurrency tests run under two stand-in semantics
 * ([tx=optimistic] abort+retry, [tx=serialized] one transaction at a time);
 * passing both shows the logic needs serializability only, not a specific
 * conflict mechanism, but neither is Firestore.
 *
 * D3 hermetic unit tests: lease ownership, markFailed() and scheduled
 * recovery.
 *
 * These tests need NO emulator. firebase-admin is replaced by a small
 * in-memory Firestore fake (transactions are atomic, queries honour
 * where/orderBy/limit and the "inequality field must be the first
 * orderBy" rule). They verify application LOGIC only. They do NOT prove
 * that the composite indexes exist or work in a real Firestore project;
 * that still needs verification on Firebase staging.
 */

const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const Module = require('node:module');

/* ------------------------------ fake Firestore ----------------------- */

const NAME_FIELD = '__name__';

class FakeTimestamp {
  constructor(ms) {
    this.ms = ms;
  }

  toMillis() {
    return this.ms;
  }
}

const toStored = (value) =>
  value instanceof Date ? new FakeTimestamp(value.getTime()) : value;

const comparable = (value) =>
  value && typeof value.toMillis === 'function'
    ? value.toMillis()
    : value instanceof Date
      ? value.getTime()
      : value;

function clone(data) {
  const out = {};
  for (const [key, value] of Object.entries(data)) {
    out[key] = toStored(value);
  }
  return out;
}

class FakeDb {
  constructor() {
    this.reset();
  }

  reset() {
    this.docs = new Map();
    this.queries = [];
    this.queryFailure = null; // (desc) => Error | null, thrown from get()
    this.orderByThrows = null; // field name -> synchronous throw
    this.failWrite = null; // (path) => bool, aborts the whole commit
    this.failRead = null; // (path) => bool, doc get() throws
    this.queryGate = null; // async (desc) => void, awaited before a query runs
    this.versions = new Map(); // path -> commit counter (optimistic concurrency)
    this.commitLog = []; // [{path, data}] every committed transactional write
    this.afterCommit = null; // async (path) => void, awaited AFTER a tx commit applied (crash injection)
    this.txMode = 'optimistic'; // 'optimistic' (abort+retry on conflict) | 'serialized' (one tx at a time)
    this.txChain = Promise.resolve();
  }

  seed(collection, id, data) {
    this.docs.set(`${collection}/${id}`, clone(data));
    this.bump(`${collection}/${id}`);
  }

  read(collection, id) {
    const data = this.docs.get(`${collection}/${id}`);
    return data ? { ...data } : undefined;
  }

  collection(name) {
    return new FakeCollection(this, name);
  }

  bump(docPath) {
    this.versions.set(docPath, (this.versions.get(docPath) || 0) + 1);
  }

  /*
   * Optimistic concurrency like the real server SDK: if a document read in
   * the transaction changed before commit, the attempt is aborted and the
   * callback re-run against fresh data (max 5 attempts).
   */
  async runTransaction(fn) {
    if (this.txMode === 'serialized') {
      // Strongest simple semantic: transactions never overlap. NOTE: a
      // never-settling afterCommit would block every later transaction.
      const run = this.txChain.then(() => this.runTransactionOptimistic(fn));
      this.txChain = run.catch(() => {});
      return run;
    }
    return this.runTransactionOptimistic(fn);
  }

  async runTransactionOptimistic(fn) {
    for (let attempt = 1; attempt <= 5; attempt += 1) {
      const writes = [];
      const reads = new Map();
      const tx = {
        get: async (ref) => {
          const snap = await ref.get();
          reads.set(ref.path, this.versions.get(ref.path) || 0);
          return snap;
        },
        set: (ref, data, options) => writes.push({ op: 'set', ref, data, options }),
        update: (ref, data) => writes.push({ op: 'update', ref, data }),
      };

      const result = await fn(tx);

      const conflict = [...reads].some(
        ([docPath, seen]) => (this.versions.get(docPath) || 0) !== seen,
      );
      if (conflict) {
        if (attempt === 5) throw new Error('transaction aborted: contention');
        continue;
      }

      for (const write of writes) {
        if (this.failWrite && this.failWrite(write.ref.path)) {
          throw new Error(`injected write failure for ${write.ref.path}`);
        }
        if (write.op === 'update' && !this.docs.has(write.ref.path)) {
          throw new Error(`update of missing doc ${write.ref.path}`);
        }
      }

      for (const write of writes) {
        const existing = this.docs.get(write.ref.path) || {};
        const incoming = clone(write.data);
        const merged =
          write.op === 'update' || (write.options && write.options.merge)
            ? { ...existing, ...incoming }
            : incoming;
        this.docs.set(write.ref.path, merged);
        this.commitLog.push({ path: write.ref.path, data: { ...incoming } });
        this.bump(write.ref.path);
      }

      if (this.afterCommit) {
        for (const write of writes) {
          await this.afterCommit(write.ref.path);
        }
      }

      return result;
    }
    throw new Error('unreachable');
  }
}

class FakeCollection {
  constructor(db, name) {
    this.db = db;
    this.name = name;
  }

  doc(id) {
    return new FakeDocRef(this.db, this.name, id);
  }

  query() {
    return new FakeQuery(this.db, this.name, [], [], null);
  }

  where(...args) {
    return this.query().where(...args);
  }
}

class FakeDocRef {
  constructor(db, collection, id) {
    this.db = db;
    this.collection = collection;
    this.id = id;
    this.path = `${collection}/${id}`;
  }

  async set(data, options) {
    if (this.db.failWrite && this.db.failWrite(this.path)) {
      throw new Error(`injected write failure for ${this.path}`);
    }
    const existing = this.db.docs.get(this.path) || {};
    const incoming = clone(data);
    this.db.docs.set(
      this.path,
      options && options.merge ? { ...existing, ...incoming } : incoming,
    );
    this.db.bump(this.path);
  }

  async get() {
    if (this.db.failRead && this.db.failRead(this.path)) {
      throw new Error(`injected read failure for ${this.path}`);
    }
    const data = this.db.docs.get(this.path);
    return {
      exists: data !== undefined,
      id: this.id,
      ref: this,
      data: () => (data ? { ...data } : undefined),
    };
  }
}

class FakeQuery {
  constructor(db, collection, filters, orders, limitN, cursorAfter = null) {
    this.db = db;
    this.collection = collection;
    this.filters = filters;
    this.orders = orders;
    this.limitN = limitN;
    this.cursorAfter = cursorAfter;
  }

  where(field, op, value) {
    return new FakeQuery(
      this.db,
      this.collection,
      [...this.filters, { field, op, value }],
      this.orders,
      this.limitN,
      this.cursorAfter,
    );
  }

  orderBy(field, direction = 'asc') {
    if (this.db.orderByThrows === field) {
      throw new Error(`injected synchronous failure on orderBy(${field})`);
    }
    return new FakeQuery(
      this.db,
      this.collection,
      this.filters,
      [...this.orders, { field, direction }],
      this.limitN,
      this.cursorAfter,
    );
  }

  limit(n) {
    return new FakeQuery(
      this.db, this.collection, this.filters, this.orders, n, this.cursorAfter,
    );
  }

  startAfter(value) {
    if (typeof value === 'string' && value.includes('/')) {
      throw new Error('FieldPath.documentId() cursor must be a plain id (slash)');
    }
    if (!this.orders.length) {
      throw new Error('startAfter requires an orderBy');
    }
    return new FakeQuery(
      this.db, this.collection, this.filters, this.orders, this.limitN, value,
    );
  }

  describe() {
    return {
      collection: this.collection,
      filters: this.filters.map((f) => ({ ...f, value: comparable(f.value) })),
      orders: this.orders.map((o) => ({ ...o })),
      limit: this.limitN,
      cursorAfter: this.cursorAfter,
    };
  }

  async get() {
    const desc = this.describe();
    this.db.queries.push(desc);

    if (this.db.queryGate) {
      await this.db.queryGate(desc);
    }

    const inequality = this.filters.find((f) => f.op !== '==');
    if (inequality && (!this.orders[0] || this.orders[0].field !== inequality.field)) {
      throw new Error('inequality field must be the first orderBy');
    }

    if (this.db.queryFailure) {
      const failure = this.db.queryFailure(desc);
      if (failure) {
        throw failure;
      }
    }

    let rows = [];
    for (const [docPath, data] of this.db.docs) {
      const [collection, id] = docPath.split('/');
      if (collection !== this.collection) continue;
      rows.push({ id, data });
    }

    rows = rows.filter(({ data }) =>
      this.filters.every((f) => {
        if (!(f.field in data)) return false;
        const left = comparable(data[f.field]);
        const right = comparable(f.value);
        return f.op === '==' ? left === right : left <= right;
      }),
    );

    // Firestore excludes documents that lack an orderBy field.
    rows = rows.filter(({ data }) =>
      this.orders.every((o) => o.field === NAME_FIELD || o.field in data),
    );

    if (this.cursorAfter !== null) {
      rows = rows.filter(({ id }) => id > this.cursorAfter);
    }

    rows.sort((a, b) => {
      for (const o of this.orders) {
        const x = o.field === NAME_FIELD ? a.id : comparable(a.data[o.field]);
        const y = o.field === NAME_FIELD ? b.id : comparable(b.data[o.field]);
        if (x !== y) return (x < y ? -1 : 1) * (o.direction === 'desc' ? -1 : 1);
      }
      return a.id < b.id ? -1 : a.id > b.id ? 1 : 0;
    });

    if (this.limitN != null) rows = rows.slice(0, this.limitN);

    const docs = rows.map(({ id, data }) => ({
      id,
      exists: true,
      data: () => ({ ...data }),
    }));

    return { docs, empty: docs.length === 0, size: docs.length };
  }
}

/* ------------------------------ load module under test --------------- */

const fakeDb = new FakeDb();

const originalLoad = Module._load;
Module._load = function patched(request, ...rest) {
  if (request === 'firebase-admin/app') {
    return { initializeApp() {} };
  }
  if (request === 'firebase-admin/auth') {
    return {
      getAuth: () => ({
        deleteUser: async () => {
          throw new Error('Auth must not be touched by these unit tests');
        },
      }),
    };
  }
  if (request === 'firebase-admin/firestore') {
    return {
      getFirestore: () => fakeDb,
      FieldPath: { documentId: () => NAME_FIELD },
    };
  }
  return originalLoad.call(this, request, ...rest);
};

const functionsModule = require('../index');
Module._load = originalLoad;

const {
  claimRequest,
  renewLease,
  markPhase,
  markFailed,
  markCompleted,
  recoveryHandler,
  runScheduledDeletionRecovery,
  advanceRecoveryCursor,
} = functionsModule.__test;

const { logger } = require('firebase-functions');

/* ------------------------------ helpers ------------------------------ */

const REQ = 'accountDeletionRequests';
const STATUS = 'accountDeletionStatus';
const past = (ms = 60_000) => new Date(Date.now() - ms);
const future = (ms = 60_000) => new Date(Date.now() + ms);

async function capture(fn) {
  const events = [];
  const originals = {};
  for (const level of ['info', 'warn', 'error']) {
    originals[level] = logger[level];
    logger[level] = (message, fields) =>
      events.push({ level, message, ...(fields || {}) });
  }
  try {
    const value = await fn();
    return { value, events };
  } catch (error) {
    error.capturedEvents = events;
    throw error;
  } finally {
    for (const level of ['info', 'warn', 'error']) {
      logger[level] = originals[level];
    }
  }
}

// Silence the logger for a whole test (needed when a run is killed and so
// cannot be wrapped by capture()).
function muteLogger() {
  const originals = {};
  for (const level of ['info', 'warn', 'error']) {
    originals[level] = logger[level];
    logger[level] = () => {};
  }
  return {
    restore() {
      for (const level of ['info', 'warn', 'error']) logger[level] = originals[level];
    },
  };
}

function processingDoc(uid, workerId, leaseUntil, extra = {}) {
  return {
    uid,
    status: 'processing',
    phase: 'follows',
    workerId,
    leaseUntil,
    updatedAt: past(5_000),
    ...extra,
  };
}

function snapshotState(uid) {
  return JSON.stringify({
    req: fakeDb.read(REQ, uid),
    status: fakeDb.read(STATUS, uid),
  });
}

test.beforeEach(() => fakeDb.reset());

/* ------------------------------ markFailed / lease ------------------- */

test('[unit/fake] markFailed: current owner persists failure on request and mirror', async () => {
  fakeDb.seed(REQ, 'u1', processingDoc('u1', 'A', future()));

  await markFailed('u1', 'A', 'profile', new Error('boom'));

  const req = fakeDb.read(REQ, 'u1');
  assert.equal(req.status, 'failed');
  assert.equal(req.phase, 'profile');
  assert.equal(req.workerId, null);
  assert.equal(req.leaseUntil, null);
  assert.equal(req.lastError, 'boom');

  const mirror = fakeDb.read(STATUS, 'u1');
  assert.equal(mirror.status, 'failed');
  assert.equal(mirror.phase, 'profile');
});

test('[unit/fake] markFailed: stale worker cannot overwrite a request owned by a new worker', async () => {
  fakeDb.seed(REQ, 'u1', processingDoc('u1', 'B', future(), { phase: 'profile' }));
  fakeDb.seed(STATUS, 'u1', { uid: 'u1', status: 'processing', phase: 'profile' });
  const before = snapshotState('u1');

  const { events } = await capture(() =>
    markFailed('u1', 'A', 'posts', new Error('stale failure')),
  );

  assert.equal(snapshotState('u1'), before, 'request and mirror untouched');
  assert.equal(events.filter((e) => e.level === 'error').length, 0);
});

test('[unit/fake] markFailed: worker id mismatch on an already failed/completed request is a no-op', async () => {
  for (const status of ['failed', 'completed']) {
    fakeDb.reset();
    fakeDb.seed(REQ, 'u1', {
      uid: 'u1',
      status,
      phase: status === 'completed' ? 'completed' : 'profile',
      workerId: null,
      leaseUntil: null,
      updatedAt: past(),
    });
    const before = snapshotState('u1');

    await markFailed('u1', 'A', 'posts', new Error('late'));

    assert.equal(snapshotState('u1'), before, `${status} stays untouched`);
  }
});

test('[unit/fake] markFailed: missing request neither throws nor creates documents', async () => {
  await markFailed('ghost', 'A', 'posts', new Error('x'));

  assert.equal(fakeDb.read(REQ, 'ghost'), undefined);
  assert.equal(fakeDb.read(STATUS, 'ghost'), undefined);
});

test('[unit/fake] markFailed: failure to persist is logged, swallowed and leaves ownership intact', async () => {
  fakeDb.seed(REQ, 'u1', processingDoc('u1', 'A', future()));
  fakeDb.failWrite = (p) => p === `${REQ}/u1`;
  const before = snapshotState('u1');

  const { events } = await capture(() =>
    markFailed('u1', 'A', 'posts', new Error('boom')),
  );

  assert.equal(snapshotState('u1'), before);
  const logged = events.find((e) => e.event === 'failure-persist-failed');
  assert.ok(logged, 'failure-persist-failed is logged');
  assert.equal(logged.uid, 'u1');
  assert.equal(logged.workerId, 'A');
});

test('[unit/fake] markFailed: mirror write failure aborts atomically and the request is recovered after lease expiry', async () => {
  fakeDb.seed(REQ, 'u1', processingDoc('u1', 'A', future()));
  fakeDb.failWrite = (p) => p === `${STATUS}/u1`;

  const { events } = await capture(() =>
    markFailed('u1', 'A', 'posts', new Error('boom')),
  );

  // Transaction is atomic: request must NOT be half-updated to 'failed'.
  const req = fakeDb.read(REQ, 'u1');
  assert.equal(req.status, 'processing');
  assert.equal(req.workerId, 'A');
  assert.ok(events.some((e) => e.event === 'failure-persist-failed'));

  // While the lease is live nobody may take over...
  fakeDb.failWrite = null;
  assert.equal((await claimRequest('u1')).reason, 'lease-active');

  // ...once it expires, scheduled recovery finds and reclaims it.
  fakeDb.seed(REQ, 'u1', { ...req, leaseUntil: past() });
  const claimed = [];
  const result = await runScheduledDeletionRecovery({
    process: async (uid) => {
      claimed.push((await claimRequest(uid)).reason);
    },
  });

  assert.deepEqual(result.queryFailures, []);
  assert.deepEqual(claimed, ['claimed']);
  assert.notEqual(fakeDb.read(REQ, 'u1').workerId, 'A');
});

test('[unit/fake] markFailed: terminal request cannot be resurrected by stale matching workerId', async () => {
  for (const status of ['failed', 'completed']) {
    fakeDb.reset();
    fakeDb.seed(REQ, 'u-terminal', {
      uid: 'u-terminal', status, phase: status === 'completed' ? 'completed' : 'profile',
      workerId: 'A', leaseUntil: null, updatedAt: past(),
    });
    fakeDb.seed(STATUS, 'u-terminal', { uid: 'u-terminal', status });
    const before = snapshotState('u-terminal');
    await markFailed('u-terminal', 'A', 'posts', new Error('late failure'));
    assert.equal(snapshotState('u-terminal'), before, `${status} remains unchanged`);
  }
});

test('[unit/fake] lease ownership: stale worker A cannot renew, advance, complete or fail after B reclaimed', async () => {
  fakeDb.seed(REQ, 'u1', { uid: 'u1', status: 'pending', updatedAt: past() });

  const a = (await claimRequest('u1')).worker;
  assert.ok(a);

  // A's lease expires; B reclaims.
  fakeDb.seed(REQ, 'u1', { ...fakeDb.read(REQ, 'u1'), leaseUntil: past() });
  const b = (await claimRequest('u1')).worker;
  assert.ok(b && b !== a);

  const before = snapshotState('u1');

  await assert.rejects(() => renewLease('u1', a), { name: 'LeaseLostError' });
  await assert.rejects(() => markPhase('u1', a, 'profile'), { name: 'LeaseLostError' });
  await assert.rejects(() => markCompleted('u1', a), { name: 'LeaseLostError' });
  await markFailed('u1', a, 'posts', new Error('stale'));

  assert.equal(snapshotState('u1'), before, 'stale worker changed nothing');
  assert.equal(fakeDb.read(REQ, 'u1').workerId, b);

  // The legitimate owner is unaffected and can finish.
  await markCompleted('u1', b);
  assert.equal(fakeDb.read(REQ, 'u1').status, 'completed');

  // A late stale failure must not resurrect a completed request.
  await markFailed('u1', a, 'posts', new Error('very late'));
  assert.equal(fakeDb.read(REQ, 'u1').status, 'completed');
});

/* ------------------------------ scheduled recovery ------------------- */

function seedRecoveryFixture() {
  fakeDb.seed(REQ, 'p1', { uid: 'p1', status: 'pending', createdAt: past(3000) });
  fakeDb.seed(REQ, 'f1', {
    uid: 'f1', status: 'failed', phase: 'profile',
    workerId: null, leaseUntil: null, updatedAt: past(2000),
  });
  fakeDb.seed(REQ, 'e1', processingDoc('e1', 'A', past()));
  fakeDb.seed(REQ, 'live', processingDoc('live', 'B', future()));
  fakeDb.seed(REQ, 'done', {
    uid: 'done', status: 'completed', phase: 'completed',
    workerId: null, leaseUntil: null, updatedAt: past(),
  });
}

const recorder = () => {
  const seen = [];
  return { seen, process: async (uid) => { seen.push(uid); } };
};

test('[unit/fake] recovery: healthy run processes pending, failed and expired-processing only', async () => {
  seedRecoveryFixture();
  const { seen, process } = recorder();

  const { value: result, events } = await capture(() =>
    runScheduledDeletionRecovery({ process }),
  );

  assert.deepEqual([...seen].sort(), ['e1', 'f1', 'p1']);
  assert.deepEqual(result, { scanned: 3, queryFailures: [], processErrors: 0, leaseConflicts: 0 });
  assert.equal(events.filter((e) => e.event === 'scheduled-recovery-degraded').length, 0);
});

// Failing every query of one status also fails that status' fallback.
for (const [failing, groupCount] of [
  ['pending', 2],
  ['failed', 2],
  ['processing', 2],
]) {
  test(`[unit/fake] recovery: failing every "${failing}" query does not stop the other statuses`, async () => {
    seedRecoveryFixture();
    fakeDb.queryFailure = (desc) =>
      desc.filters.some((f) => f.field === 'status' && f.value === failing)
        ? new Error(`injected ${failing} failure`)
        : null;
    const { seen, process } = recorder();

    const { value: result, events } = await capture(() =>
      runScheduledDeletionRecovery({ process }),
    );

    const expected = { pending: 'p1', failed: 'f1', processing: 'e1' };
    const survivors = Object.entries(expected)
      .filter(([status]) => status !== failing)
      .map(([, uid]) => uid)
      .sort();

    assert.deepEqual([...seen].sort(), survivors);
    assert.equal(result.queryFailures.length, groupCount);

    const errors = events.filter((e) => e.event === 'scheduled-recovery-query-failure');
    assert.equal(errors.length, groupCount, 'one error log per failed query');
    assert.match(errors[0].error, new RegExp(`injected ${failing} failure`));

    const degraded = events.find((e) => e.event === 'scheduled-recovery-degraded');
    assert.ok(degraded, 'aggregate degraded event is logged');
    assert.equal(degraded.totalQueries, 6);
    assert.equal(degraded.failedQueries.length, groupCount);
  });
}

test('[unit/fake] recovery: ordered query failing alone (e.g. missing index) is still covered by its fallback', async () => {
  seedRecoveryFixture();
  fakeDb.queryFailure = (desc) =>
    desc.orders.length > 0 &&
    ['createdAt', 'updatedAt'].includes(desc.orders[0].field)
      ? new Error('FAILED_PRECONDITION: index required')
      : null;
  const { seen, process } = recorder();

  const { value: result } = await capture(() =>
    runScheduledDeletionRecovery({ process }),
  );

  assert.deepEqual([...seen].sort(), ['e1', 'f1', 'p1']);
  assert.deepEqual(result.queryFailures, ['pending', 'failed']);
});

test('[unit/fake] recovery completeness: requests missing createdAt/updatedAt are not invisible; no uid is processed twice', async () => {
  // Firestore excludes docs lacking the orderBy field. These two would be
  // lost by the ordered queries alone.
  fakeDb.seed(REQ, 'p-nocreated', { uid: 'p-nocreated', status: 'pending' });
  fakeDb.seed(REQ, 'f-noupdated', {
    uid: 'f-noupdated', status: 'failed', phase: 'profile',
    workerId: null, leaseUntil: null,
  });
  // Normal docs appear in BOTH the ordered query and its fallback.
  fakeDb.seed(REQ, 'p-ok', { uid: 'p-ok', status: 'pending', createdAt: past(1000) });
  fakeDb.seed(REQ, 'f-ok', {
    uid: 'f-ok', status: 'failed', phase: 'profile',
    workerId: null, leaseUntil: null, updatedAt: past(1000),
  });
  const { seen, process } = recorder();

  await capture(() => runScheduledDeletionRecovery({ process }));

  assert.deepEqual([...seen].sort(), ['f-noupdated', 'f-ok', 'p-nocreated', 'p-ok']);
  assert.equal(seen.length, new Set(seen).size, 'de-duplicated');
});

test('[unit/fake] recovery: a synchronous throw while building one query is isolated too', async () => {
  seedRecoveryFixture();
  fakeDb.orderByThrows = 'updatedAt'; // the "failed" group
  const { seen, process } = recorder();

  const { value: result } = await capture(() =>
    runScheduledDeletionRecovery({ process }),
  );

  // The ordered "failed" group throws; its fallback still finds f1.
  assert.deepEqual([...seen].sort(), ['e1', 'f1', 'p1']);
  assert.deepEqual(result.queryFailures, ['failed']);
});

test('[unit/fake] recovery: all queries failing reports degraded run and the scheduler handler fails', async () => {
  seedRecoveryFixture();
  fakeDb.queryFailure = () => new Error('firestore down');
  const { seen, process } = recorder();

  const { value: result } = await capture(() =>
    runScheduledDeletionRecovery({ process }),
  );
  assert.equal(result.scanned, 0);
  assert.equal(result.queryFailures.length, 6);
  assert.deepEqual(seen, []);

  const { events } = await capture(async () => {
    await assert.rejects(() => recoveryHandler(), /6 recovery query/);
  });
  assert.ok(events.some((e) => e.event === 'scheduled-recovery-degraded'));
});

test('[unit/fake] recovery: scheduler handler resolves on a clean run', async () => {
  await capture(() => recoveryHandler());
});

test('[unit/fake] recovery: one failing deletion does not stop the rest and is counted', async () => {
  seedRecoveryFixture();
  const seen = [];

  const { value: result, events } = await capture(() =>
    runScheduledDeletionRecovery({
      process: async (uid) => {
        seen.push(uid);
        if (uid === 'p1') throw new Error('permanent');
      },
    }),
  );

  assert.deepEqual([...seen].sort(), ['e1', 'f1', 'p1']);
  assert.equal(result.processErrors, 1);
  const failure = events.find((e) => e.event === 'scheduled-recovery-failure');
  assert.equal(failure.uid, 'p1');
});

test('[unit/fake] recovery: handler rejects unexpected processing failures', async () => {
  seedRecoveryFixture();
  await assert.rejects(
    () => recoveryHandler({ process: async (uid) => { if (uid === 'p1') throw new Error('unexpected failure'); } }),
    /recovery processing attempt\(s\) failed/,
  );
});

test('[unit/fake] recovery: processing fallback discovers processing request without leaseUntil', async () => {
  fakeDb.seed(REQ, 'processing-no-lease', {
    uid: 'processing-no-lease', status: 'processing', phase: 'posts', workerId: 'old-worker',
  });
  const seen = [];
  const { value: result } = await capture(() => runScheduledDeletionRecovery({
    process: async (uid) => { seen.push(uid); },
  }));
  assert.ok(seen.includes('processing-no-lease'));
  assert.deepEqual(result.queryFailures, []);
});

test('[unit/fake] recovery: active lease conflict is not counted as processing failure', async () => {
  seedRecoveryFixture();
  const { value: result } = await capture(() => runScheduledDeletionRecovery({
    process: async (uid) => { if (uid === 'p1') throw new Error(`F3-G deletion lease for ${uid} is held by another worker.`); },
  }));
  assert.equal(result.processErrors, 0);
  assert.equal(result.leaseConflicts, 1);
});

test('[unit/fake] recovery: per-run work budget caps attempts and the run stays healthy', async () => {
  for (let i = 0; i < 50; i += 1) {
    const uid = `bp-${i}`;
    fakeDb.seed(REQ, uid, { uid, status: 'pending', createdAt: past(500_000 - i) });
  }
  for (let i = 0; i < 50; i += 1) {
    const uid = `bf-${i}`;
    fakeDb.seed(REQ, uid, {
      uid, status: 'failed', phase: 'profile',
      workerId: null, leaseUntil: null, updatedAt: past(500_000 - i),
    });
  }
  const seen = [];
  const { value: result, events } = await capture(() => runScheduledDeletionRecovery({
    process: async (uid) => { seen.push(uid); },
  }));

  // 100 distinct candidates exist; the run stops at its attempt budget (80).
  assert.equal(seen.length, 80);
  assert.equal(new Set(seen).size, 80);
  assert.equal(result.processErrors, 0);
  assert.deepEqual(result.queryFailures, []);
  assert.ok(events.some((e) => e.event === 'scheduled-recovery-budget-reached'));
});

test('[unit/fake] recovery: queries are bounded, ordered oldest-first and lease query orders by its inequality field', async () => {
  await capture(() => runScheduledDeletionRecovery({ process: async () => {} }));

  const byStatus = (status) =>
    fakeDb.queries.find((q) =>
      q.filters.some((f) => f.field === 'status' && f.value === status),
    );

  const pending = byStatus('pending');
  assert.deepEqual(pending.orders, [{ field: 'createdAt', direction: 'asc' }]);
  assert.equal(pending.limit, 50);

  const failed = byStatus('failed');
  assert.deepEqual(failed.orders, [{ field: 'updatedAt', direction: 'asc' }]);
  assert.equal(failed.limit, 50);

  const processing = byStatus('processing');
  assert.ok(processing.filters.some((f) => f.field === 'leaseUntil' && f.op === '<='));
  assert.deepEqual(processing.orders, [{ field: 'leaseUntil', direction: 'asc' }]);
  assert.equal(processing.limit, 50);

  // Fallbacks: id-ordered pages with a cursor, no composite index.
  for (const status of ['pending', 'failed']) {
    const fallback = fakeDb.queries.find(
      (q) =>
        q.orders.length === 1 &&
        q.orders[0].field === '__name__' &&
        q.filters.length === 1 &&
        q.filters[0].value === status,
    );
    assert.ok(fallback, `${status} fallback query exists`);
    assert.equal(fallback.limit, 20);
    assert.equal(fallback.cursorAfter, null, 'first run starts at the beginning');
  }
});

test('[unit/fake] recovery fairness: permanently failing requests rotate instead of starving newer ones', async () => {
  const total = 60;
  const base = Date.now() - 10 * 60_000;
  for (let i = 0; i < total; i += 1) {
    const id = `f${String(i).padStart(2, '0')}`;
    fakeDb.seed(REQ, id, {
      uid: id, status: 'failed', phase: 'profile',
      workerId: null, leaseUntil: null, updatedAt: new Date(base + i * 1000),
    });
  }

  const attempted = new Set();
  let clock = Date.now();
  // Models markFailed(): every failed attempt bumps updatedAt.
  const failingProcess = async (uid) => {
    attempted.add(uid);
    clock += 1;
    fakeDb.seed(REQ, uid, { ...fakeDb.read(REQ, uid), updatedAt: new Date(clock) });
    throw new Error('permanent failure');
  };

  await capture(() => runScheduledDeletionRecovery({ process: failingProcess }));
  assert.equal(attempted.size, 50);
  assert.ok(attempted.has('f00') && !attempted.has('f59'), 'oldest first');

  await capture(() => runScheduledDeletionRecovery({ process: failingProcess }));
  assert.equal(attempted.size, total, 'second run reaches the requests the first one could not');
});

/* ------------------------------ fallback rotation -------------------- */

const CURSORS = 'accountDeletionRecoveryState/cursors'.split('/');
const readCursors = () => fakeDb.read(CURSORS[0], CURSORS[1]) || {};

function seedOrphans(prefix, count, status) {
  for (let i = 0; i < count; i += 1) {
    const id = `${prefix}${String(i).padStart(2, '0')}`;
    // No createdAt/updatedAt: invisible to the ordered queries.
    fakeDb.seed(REQ, id, { uid: id, status });
  }
}

test('[unit/fake] fallback rotation: more than 20 orphan requests behind well-formed ones are all reached', async () => {
  // 30 well-formed failed requests sort BEFORE 30 orphans by id and keep
  // failing; a fixed first-20 fallback would never reach the orphans.
  for (let i = 0; i < 30; i += 1) {
    const id = `a${String(i).padStart(2, '0')}`;
    fakeDb.seed(REQ, id, {
      uid: id, status: 'failed', phase: 'profile',
      workerId: null, leaseUntil: null, updatedAt: past(1000 + i),
    });
  }
  seedOrphans('z', 30, 'failed');
  seedOrphans('y', 25, 'pending');

  const attempted = new Set();
  const process = async (uid) => { attempted.add(uid); };

  const orphans = [...fakeDb.docs.keys()]
    .map((k) => k.split('/')[1])
    .filter((id) => id.startsWith('z') || id.startsWith('y'));
  assert.equal(orphans.length, 55);

  // ceil(30/20)+1 = 3 runs is the documented bound for the larger group.
  for (let run = 1; run <= 3; run += 1) {
    await capture(() => runScheduledDeletionRecovery({ process }));
  }

  for (const id of orphans) {
    assert.ok(attempted.has(id), `${id} was never recovered`);
  }
});

test('[unit/fake] fallback rotation: cursor advances, wraps on a short page and restarts', async () => {
  seedOrphans('p', 25, 'pending');
  const seenPerRun = [];
  const cursorPerRun = [];

  for (let run = 0; run < 3; run += 1) {
    const seen = [];
    await capture(() =>
      runScheduledDeletionRecovery({ process: async (uid) => { seen.push(uid); } }),
    );
    seenPerRun.push(seen);
    cursorPerRun.push(readCursors()['pendingFallback']);
  }

  assert.equal(seenPerRun[0].length, 20);                    // p00..p19
  assert.equal(cursorPerRun[0], 'p19', 'full page advances the cursor');
  assert.deepEqual(seenPerRun[1], ['p20', 'p21', 'p22', 'p23', 'p24']);
  assert.equal(cursorPerRun[1], null, 'short page wraps the cursor');
  assert.equal(seenPerRun[2].length, 20, 'restarts from the beginning');
  assert.equal(seenPerRun[2][0], 'p00');
});

test('[unit/fake] fallback rotation: cursor is persisted before processing (a failing/slow run still advances)', async () => {
  seedOrphans('p', 25, 'pending');

  await capture(() =>
    runScheduledDeletionRecovery({
      process: async () => { throw new Error('every deletion fails'); },
    }),
  );

  assert.equal(readCursors()['pendingFallback'], 'p19');
});

test('[unit/fake] fallback rotation: unreadable cursor skips the rotating lanes (cannot CAS), keeps ordered lanes, reports degraded', async () => {
  seedRecoveryFixture();
  seedOrphans('o', 3, 'pending'); // reachable only through the fallback lane
  fakeDb.seed('accountDeletionRecoveryState', 'cursors', { 'pendingFallback': 'o01' });
  fakeDb.failRead = (p) => p === 'accountDeletionRecoveryState/cursors';
  const { seen, process } = recorder();

  const { value: result, events } = await capture(() =>
    runScheduledDeletionRecovery({ process }),
  );

  assert.deepEqual([...seen].sort(), ['e1', 'f1', 'p1']);
  assert.ok(result.queryFailures.includes('cursor-read'));
  assert.ok(events.some((e) => e.event === 'scheduled-recovery-cursor-read-failed'));
  assert.ok(events.some((e) => e.event === 'scheduled-recovery-degraded'));
  assert.equal(readCursors()['pendingFallback'], 'o01', 'cursor untouched');
});

test('[unit/fake] fallback rotation: cursor write failure is isolated, reported and does not stop processing', async () => {
  seedRecoveryFixture();
  fakeDb.failWrite = (p) => p === 'accountDeletionRecoveryState/cursors';
  const { seen, process } = recorder();

  const { value: result, events } = await capture(() =>
    runScheduledDeletionRecovery({ process }),
  );

  assert.deepEqual([...seen].sort(), ['e1', 'f1', 'p1']);
  assert.deepEqual(result.queryFailures, ['cursor-write']);
  assert.ok(events.some((e) => e.event === 'scheduled-recovery-cursor-write-failed'));
});

test('[unit/fake] fallback rotation: malformed or stale cursor values are ignored', async () => {
  seedOrphans('p', 3, 'pending');
  fakeDb.seed('accountDeletionRecoveryState', 'cursors', {
    'pendingFallback': 12345,
    'failedFallback': 'zzzz-beyond-every-id',
  });
  const { seen, process } = recorder();

  await capture(() => runScheduledDeletionRecovery({ process }));

  assert.deepEqual([...seen].sort(), ['p00', 'p01', 'p02']);
});

test('[unit/fake] fallback rotation: a last page of exactly 20 is followed by an empty page that wraps the cursor', async () => {
  seedOrphans('p', 20, 'pending');
  const runs = [];

  for (let i = 0; i < 3; i += 1) {
    const seen = [];
    await capture(() =>
      runScheduledDeletionRecovery({ process: async (uid) => { seen.push(uid); } }),
    );
    runs.push({ seen, cursor: readCursors().pendingFallback });
  }

  assert.equal(runs[0].seen.length, 20);
  assert.equal(runs[0].cursor, 'p19');
  assert.deepEqual(runs[1].seen, [], 'empty page');
  assert.equal(runs[1].cursor, null, 'wrapped');
  assert.equal(runs[2].seen.length, 20, 'new cycle starts again at p00');
});

/* ------------------------------ adversarial: concurrency ------------- */

const ids = (prefix, from, to) =>
  Array.from({ length: to - from + 1 }, (_, i) => `${prefix}${String(from + i).padStart(2, '0')}`);

const tick = () => new Promise((resolve) => setImmediate(resolve));

function eachTxMode(title, fn) {
  for (const mode of ['optimistic', 'serialized']) {
    test(`[unit/fake] ${title} [tx=${mode}]`, async () => {
      fakeDb.txMode = mode;
      await fn();
    });
  }
}

eachTxMode('[unit/fake] ADVERSARIAL race: a stale run released after newer runs cannot move the cursor backwards or lose pages', async () => {
  seedOrphans('p', 60, 'pending');

  // Run A reads cursor (null) and is then frozen before its first query.
  let release;
  const held = new Promise((resolve) => { release = resolve; });
  let armed = true;
  fakeDb.queryGate = async () => {
    if (armed) { armed = false; await held; }
  };

  const attemptsA = [];
  const runA = capture(() =>
    runScheduledDeletionRecovery({ process: async (uid) => { attemptsA.push(uid); } }),
  );
  await tick();
  fakeDb.queryGate = null;

  // Newer runs B and C complete while A is frozen.
  const attemptsBC = [];
  for (let i = 0; i < 2; i += 1) {
    await capture(() =>
      runScheduledDeletionRecovery({ process: async (uid) => { attemptsBC.push(uid); } }),
    );
  }
  assert.equal(readCursors()['pendingFallback'], 'p39');

  // A resumes holding a STALE view (cursor null, page p00..p19).
  release();
  await runA;

  assert.equal(readCursors()['pendingFallback'], 'p39', 'cursor must not move backwards');
  assert.deepEqual(attemptsA, [], 'stale run abandons a page another run owns');

  // The sweep still completes: nothing is lost.
  const later = [];
  for (let i = 0; i < 2; i += 1) {
    await capture(() =>
      runScheduledDeletionRecovery({ process: async (uid) => { later.push(uid); } }),
    );
  }
  const covered = new Set([...attemptsBC, ...later]);
  for (const id of ids('p', 0, 59)) {
    assert.ok(covered.has(id), `${id} was never attempted`);
  }
});

// SCOPE OF THIS CLAIM: only for requests reachable through the fallback lane
// alone (orphans). Ordered lanes are NOT coordinated between runs: two
// overlapping runs may both attempt a well-formed request. That is by design
// and is made safe by the claimRequest lease (see the concurrent-claim test).
eachTxMode('[unit/fake] ADVERSARIAL race: for fallback-only (orphan) requests, two simultaneously started runs attempt each one exactly once', async () => {
  seedOrphans('p', 20, 'pending');
  const attempts = [];
  const process = async (uid) => { attempts.push(uid); await tick(); };

  await Promise.all([
    capture(() => runScheduledDeletionRecovery({ process })),
    capture(() => runScheduledDeletionRecovery({ process })),
  ]);

  assert.equal(attempts.length, new Set(attempts).size, 'no duplicate attempts');
  assert.equal(new Set(attempts).size, 20, 'and none lost');
});

test('[unit/fake] ADVERSARIAL race: compare-and-set refuses a stale expected value', async () => {
  fakeDb.seed('accountDeletionRecoveryState', 'cursors', { 'pendingFallback': 'p39' });
  const ref = fakeDb.collection('accountDeletionRecoveryState').doc('cursors');

  assert.equal(await advanceRecoveryCursor(ref, 'pendingFallback', 'p19', 'p29'), false);
  assert.equal(readCursors()['pendingFallback'], 'p39');
  assert.equal(await advanceRecoveryCursor(ref, 'pendingFallback', 'p39', 'p40'), true);
  assert.equal(readCursors()['pendingFallback'], 'p40');
});

eachTxMode('[unit/fake] ADVERSARIAL overlap: run B starts while run A is stuck INSIDE a deletion; A cannot rewind or duplicate B\'s page', async () => {
  // Closest model of production: A is a long run (deletions take time),
  // the next scheduled run B starts mid-way.
  seedOrphans('p', 40, 'pending');
  const attemptsA = [];
  const attemptsB = [];
  let holdA;
  const held = new Promise((resolve) => { holdA = resolve; });
  let reachedP05;
  const atP05 = new Promise((resolve) => { reachedP05 = resolve; });

  const runA = capture(() =>
    runScheduledDeletionRecovery({
      process: async (uid) => {
        attemptsA.push(uid);
        if (uid === 'p05') { reachedP05(); await held; }
      },
    }),
  );
  await atP05;
  assert.equal(readCursors().pendingFallback, 'p05');

  await capture(() =>
    runScheduledDeletionRecovery({ process: async (uid) => { attemptsB.push(uid); } }),
  );
  assert.equal(readCursors().pendingFallback, 'p25');

  holdA();
  await runA;

  assert.deepEqual(attemptsA, ids('p', 0, 5), 'A stops at the page boundary it lost');
  assert.deepEqual(attemptsB, ids('p', 6, 25));
  assert.equal(
    new Set([...attemptsA, ...attemptsB]).size,
    attemptsA.length + attemptsB.length,
    'no request attempted twice',
  );

  // Every committed cursor value is strictly increasing (no rewind).
  const values = fakeDb.commitLog
    .filter((w) => w.path === 'accountDeletionRecoveryState/cursors')
    .map((w) => w.data.pendingFallback);
  assert.deepEqual(values, [...values].sort(), 'cursor never moved backwards');
  assert.equal(readCursors().pendingFallback, 'p25');
});

eachTxMode('[unit/fake] lease protects duplicates the cursor does not: two concurrent claims of one request yield exactly one worker', async () => {
  fakeDb.seed(REQ, 'u1', { uid: 'u1', status: 'failed', phase: 'profile', updatedAt: past() });

  const [a, b] = await Promise.all([claimRequest('u1'), claimRequest('u1')]);

  assert.deepEqual([a.reason, b.reason].sort(), ['claimed', 'lease-active']);
  assert.equal([a, b].filter((r) => r.worker).length, 1);
});

/* ------------------------------ adversarial: crash / failure ---------- */

test('[unit/fake] ADVERSARIAL crash: run killed mid-page loses nothing that was not yet attempted', async () => {
  seedOrphans('p', 45, 'pending');
  const attempts = [];

  // Run 1 hangs forever on p10 (function killed / timeout).
  let killed;
  const kill = new Promise((resolve) => { killed = resolve; });
  const run1 = runScheduledDeletionRecovery({
    process: async (uid) => {
      attempts.push(uid);
      if (uid === 'p10') {
        killed();
        await new Promise(() => {}); // never settles
      }
    },
  });
  void run1;
  await kill;
  await tick();

  // Discovered (page p00..p19) is NOT the same as attempted (p00..p10).
  assert.deepEqual(attempts, ids('p', 0, 10));
  assert.equal(readCursors()['pendingFallback'], 'p10');

  // Following runs continue right after the poison request; p11..p19 were
  // discovered by run 1 but never attempted, and must not be skipped.
  const later = [];
  for (let i = 0; i < 4; i += 1) {
    await capture(() =>
      runScheduledDeletionRecovery({ process: async (uid) => { later.push(uid); } }),
    );
  }
  for (const id of ids('p', 11, 19)) {
    assert.ok(later.includes(id), `${id} (discovered but unattempted) was skipped`);
  }
  assert.ok(later.indexOf('p11') < later.indexOf('p20'), 'resumes in order, no livelock on p10');
  for (const id of ids('p', 0, 44)) {
    assert.ok(attempts.includes(id) || later.includes(id), `${id} never attempted`);
  }
});

/*
 * Kill the instance right AFTER the cursor checkpoint for the `crashAt`-th
 * request committed and BEFORE its process() call. The killed run never
 * resumes. Then run normal runs and record exactly what gets attempted.
 */
async function crashAfterCheckpoint(total, crashAt) {
  fakeDb.reset();
  seedOrphans('p', total, 'pending');

  let commits = 0;
  let kill;
  const killed = new Promise((resolve) => { kill = resolve; });
  let isKilled = false;
  void killed.then(() => { isKilled = true; });

  fakeDb.afterCommit = async (docPath) => {
    if (docPath !== 'accountDeletionRecoveryState/cursors') return;
    commits += 1;
    if (commits === crashAt) {
      fakeDb.afterCommit = null;
      kill();
      await new Promise(() => {}); // instance killed: never resumes
    }
  };

  const attempts = [];
  const process = async (uid) => { attempts.push(uid); };

  while (!isKilled) {
    await Promise.race([runScheduledDeletionRecovery({ process }), killed]);
  }

  const cursorAtCrash = readCursors().pendingFallback;
  const beforeCrash = [...attempts];

  const afterCrash = [];
  for (let run = 0; run < 12; run += 1) {
    await runScheduledDeletionRecovery({ process: async (uid) => { afterCrash.push(uid); } });
  }

  return { cursorAtCrash, beforeCrash, afterCrash };
}

for (const total of [45, 40]) {
  // 45 = pages of 20,20,5 (short last page wraps the cursor to null);
  // 40 = pages of 20,20 then an EMPTY page that wraps it.
  test(`[unit/fake] ADVERSARIAL crash after checkpoint, before process(): a skipped request is found again exactly one cycle later (every position, ${total} requests)`, async () => {
    const all = ids('p', 0, total - 1);
    const logs = muteLogger();

    try {
      for (let crashAt = 1; crashAt <= total; crashAt += 1) {
        const c = crashAt - 1;
        const crashed = all[c];
        const { cursorAtCrash, beforeCrash, afterCrash } = await crashAfterCheckpoint(total, crashAt);
        const where = `crash at ${crashed}`;

        // The documented gap: the checkpointed request was never attempted.
        assert.ok(!beforeCrash.includes(crashed), `${where}: never attempted before the kill`);
        assert.deepEqual(beforeCrash.slice(-Math.min(c, 5)), all.slice(Math.max(0, c - 5), c).slice(-Math.min(c, 5)));

        // Cursor state at the kill: at the request, or null when the checkpoint was the wrap.
        const wrapped = c === total - 1 && total % 20 !== 0;
        assert.equal(cursorAtCrash, wrapped ? null : crashed, `${where}: cursor`);

        // Exact recovery order: the rest of the cycle first (nothing after the
        // cursor is skipped), then the next cycle up to and INCLUDING the
        // skipped request.
        const expected = [...all.slice(c + 1), ...all.slice(0, c + 1)];
        assert.deepEqual(afterCrash.slice(0, total), expected, `${where}: recovery order`);

        // Union of everything attempted covers every request.
        const covered = new Set([...beforeCrash, ...afterCrash]);
        assert.equal(covered.size, total, `${where}: coverage`);

        // And it is NOT attempted earlier than one cycle later.
        assert.equal(afterCrash.indexOf(crashed), total - 1, `${where}: skipped request waits one cycle`);
      }
    } finally {
      logs.restore();
    }
  });
}

test('[unit/fake] ADVERSARIAL crash on the wrap checkpoint: last request of a short page, cursor already null', async () => {
  const { cursorAtCrash, beforeCrash, afterCrash } = await crashAfterCheckpoint(25, 25);

  assert.equal(cursorAtCrash, null, 'wrap was committed before the kill');
  assert.ok(!beforeCrash.includes('p24'), 'last request was never attempted');
  assert.deepEqual(beforeCrash.slice(-4), ['p20', 'p21', 'p22', 'p23']);
  // Next cycle restarts at the beginning and reaches p24 last.
  assert.deepEqual(afterCrash.slice(0, 25), ids('p', 0, 24));
});

test('[unit/fake] ADVERSARIAL failure: attempted != succeeded; failing requests are retried every cycle, none dropped', async () => {
  seedOrphans('p', 45, 'pending'); // pages of 20, 20, 5 => one cycle = 3 runs
  const counts = new Map();
  const failing = async (uid) => {
    counts.set(uid, (counts.get(uid) || 0) + 1);
    throw new Error('every deletion fails');
  };

  for (let i = 0; i < 6; i += 1) {
    await capture(() => runScheduledDeletionRecovery({ process: failing }));
  }

  for (const id of ids('p', 0, 44)) {
    assert.equal(counts.get(id), 2, `${id} should be attempted once per cycle (2 cycles)`);
  }
});

test('[unit/fake] ADVERSARIAL concurrent inserts: ahead of the cursor is reached this cycle, behind it after the wrap', async () => {
  seedOrphans('p', 45, 'pending');
  const order = [];
  const process = async (uid) => { order.push(uid); };

  await capture(() => runScheduledDeletionRecovery({ process }));   // p00..p19
  fakeDb.seed(REQ, 'a-new', { uid: 'a-new', status: 'pending' });   // behind cursor
  fakeDb.seed(REQ, 'z-new', { uid: 'z-new', status: 'pending' });   // ahead of cursor
  await capture(() => runScheduledDeletionRecovery({ process }));   // p20..p39
  await capture(() => runScheduledDeletionRecovery({ process }));   // p40..p44, z-new, wrap

  assert.ok(order.includes('z-new'), 'ahead of cursor: same cycle');
  assert.ok(!order.includes('a-new'), 'behind cursor: not before the wrap');

  await capture(() => runScheduledDeletionRecovery({ process }));   // new cycle
  assert.ok(order.includes('a-new'), 'behind cursor: reached after the wrap');
});

test('[unit/fake] ADVERSARIAL corrupt cursor: a malformed stored value self-heals instead of wedging the lane', async () => {
  seedOrphans('p', 3, 'pending');
  fakeDb.seed('accountDeletionRecoveryState', 'cursors', { 'pendingFallback': 'a/b' });
  const { seen, process } = recorder();

  const { value: result } = await capture(() =>
    runScheduledDeletionRecovery({ process }),
  );

  assert.deepEqual([...seen].sort(), ['p00', 'p01', 'p02']);
  assert.deepEqual(result.queryFailures, []);
  assert.equal(readCursors()['pendingFallback'], null);
});

test('[unit/fake] ADVERSARIAL starvation: a run cut short still reaches the fallback lane (lanes are interleaved, not drained one by one)', async () => {
  for (let i = 0; i < 50; i += 1) {
    const id = `f${String(i).padStart(2, '0')}`;
    fakeDb.seed(REQ, id, {
      uid: id, status: 'failed', phase: 'profile',
      workerId: null, leaseUntil: null, updatedAt: past(1000 + i),
    });
  }
  seedOrphans('o', 3, 'pending'); // only the fallback lane can see these

  const attempts = [];
  let killed;
  const kill = new Promise((resolve) => { killed = resolve; });
  void runScheduledDeletionRecovery({
    process: async (uid) => {
      attempts.push(uid);
      if (attempts.length === 8) { killed(); await new Promise(() => {}); }
    },
  });
  await kill;

  assert.ok(attempts.includes('o00'), 'orphan reached within the first few attempts');
});

/* ------------------------------ real SDK query shape ------------------ */

test('[unit/fake] real @google-cloud/firestore accepts the fallback query and serialises the intended wire query (no server involved)', () => {
  const { Firestore, FieldPath } = require('@google-cloud/firestore');
  const collection = new Firestore({ projectId: 'demo-audit' }).collection(REQ);
  const { fallbackQuery } = functionsModule.__test;

  const first = fallbackQuery(collection, 'failed', null, FieldPath.documentId()).toProto().structuredQuery;
  assert.deepEqual(first.where.fieldFilter.field, { fieldPath: 'status' });
  assert.equal(first.where.fieldFilter.op, 'EQUAL');
  assert.deepEqual(first.orderBy, [{ field: { fieldPath: '__name__' }, direction: 'ASCENDING' }]);
  assert.equal(first.startAt, undefined);
  assert.equal(first.limit.value, 20);

  const next = fallbackQuery(collection, 'failed', 'uidABC', FieldPath.documentId()).toProto().structuredQuery;
  assert.equal(next.startAt.values.length, 1);
  assert.match(next.startAt.values[0].referenceValue, /\/documents\/accountDeletionRequests\/uidABC$/);
  assert.ok(!next.startAt.before, 'startAfter => cursor is exclusive (before=false)');

  // The SDK itself rejects what normalizeCursor must never pass on.
  assert.throws(() => collection.where('status', '==', 'failed').startAfter('uidABC'), /orderBy/);
  assert.throws(
    () => collection.where('status', '==', 'failed').orderBy(FieldPath.documentId()).startAfter('a/b'),
    /slash/,
  );
});

/* ------------------------------ index coverage ----------------------- */

test('[sdk-offline/scripted] firestore.indexes.json matches EXACTLY the composite indexes implied by the real SDK wire queries', () => {
  // Derived from what the real @google-cloud/firestore would send for the
  // production query groups (not from the fake). This proves the file matches
  // our reading of Firestore's index rules; it cannot prove the server agrees.
  const { Firestore, FieldPath } = require('@google-cloud/firestore');
  const collection = new Firestore({ projectId: 'demo-audit' }).collection(REQ);
  const { recoveryQueryGroups } = functionsModule.__test;

  const groups = recoveryQueryGroups(new Date(), {}, () => collection);
  assert.deepEqual(
    groups.map((g) => g.name),
    ['pending', 'failed', 'expired-processing', 'pending-fallback', 'failed-fallback', 'processing-fallback'],
  );

  const needed = [];
  for (const group of groups) {
    // Fallback queries use the real FieldPath.documentId().
    const query = group.name.endsWith('fallback')
      ? functionsModule.__test.fallbackQuery(
          collection,
          group.name.startsWith('pending') ? 'pending' :
            group.name.startsWith('failed') ? 'failed' : 'processing',
          null,
          FieldPath.documentId(),
        )
      : group.build();
    const q = query.toProto().structuredQuery;

    const filters = q.where.compositeFilter
      ? q.where.compositeFilter.filters.map((f) => f.fieldFilter)
      : [q.where.fieldFilter];
    const fields = filters.filter((f) => f.op === 'EQUAL').map((f) => f.field.fieldPath);
    for (const f of filters.filter((x) => x.op !== 'EQUAL')) {
      if (!fields.includes(f.field.fieldPath)) fields.push(f.field.fieldPath);
    }
    for (const o of q.orderBy || []) {
      assert.equal(o.direction, 'ASCENDING');
      if (o.field.fieldPath !== '__name__' && !fields.includes(o.field.fieldPath)) {
        fields.push(o.field.fieldPath);
      }
    }
    if (fields.length > 1) needed.push(fields);
  }

  const file = JSON.parse(
    fs.readFileSync(path.join(__dirname, '..', '..', 'firestore.indexes.json'), 'utf8'),
  );
  const declared = file.indexes
    .filter((i) => i.collectionGroup === REQ)
    .map((i) => {
      assert.equal(i.queryScope, 'COLLECTION');
      assert.ok(i.fields.every((f) => f.order === 'ASCENDING'));
      return i.fields.map((f) => f.fieldPath);
    });

  const norm = (list) => list.map((f) => f.join('>')).sort();
  assert.deepEqual(norm(declared), norm(needed), 'no missing and no unnecessary index');
  assert.deepEqual(norm(needed), ['status>createdAt', 'status>leaseUntil', 'status>updatedAt']);

  const overrides = file.fieldOverrides.map((o) => `${o.collectionGroup}.${o.fieldPath}`);
  assert.ok(overrides.includes('comments.authorId'));
  assert.ok(overrides.includes('replies.authorId'));
});

/* ------------------------------ real SDK transaction wire ------------- */

// The REAL Admin/Firestore SDK runs the CAS callback; only the RPC layer is
// scripted. This verifies request shapes and the SDK's own retry-on-ABORTED
// behaviour. It does NOT verify server-side locking or contention handling.
function scriptedSdk({ stored, abortFirstCommit = false, storedAfterAbort = stored }) {
  const { Firestore } = require('@google-cloud/firestore');
  const { Readable } = require('node:stream');
  const firestore = new Firestore({ projectId: 'demo-audit' });
  const calls = [];
  const name = 'projects/demo-audit/databases/(default)/documents/accountDeletionRecoveryState/cursors';
  let commits = 0;
  let reads = 0;
  const ts = { seconds: 1, nanos: 0 };

  firestore.request = async (method, request) => {
    calls.push({ method, request });
    if (method === 'beginTransaction') return { transaction: Buffer.from('tx') };
    if (method === 'rollback') return {};
    if (method === 'commit') {
      commits += 1;
      if (abortFirstCommit && commits === 1) {
        throw Object.assign(new Error('ABORTED: too much contention'), { code: 10 });
      }
      return { writeResults: (request.writes || []).map(() => ({ updateTime: ts })), commitTime: ts };
    }
    throw new Error(`unexpected unary RPC ${method}`);
  };

  firestore.requestStream = async (method, _mode, request) => {
    calls.push({ method, request });
    reads += 1;
    const value = reads === 1 ? stored : storedAfterAbort;
    const response =
      value === undefined
        ? { missing: name, readTime: ts, transaction: Buffer.from('tx') }
        : {
            found: {
              name,
              fields: { pendingFallback: { stringValue: value } },
              createTime: ts,
              updateTime: ts,
            },
            readTime: ts,
            transaction: Buffer.from('tx'),
          };
    return Readable.from([response]);
  };

  return { firestore, calls, ref: firestore.collection('accountDeletionRecoveryState').doc('cursors') };
}

test('[sdk-offline/scripted] real SDK wire: CAS on a missing cursor doc sends read(newTransaction) -> one merge write with plain field names', async () => {
  const { firestore, calls, ref } = scriptedSdk({ stored: undefined });

  const moved = await advanceRecoveryCursor(ref, 'pendingFallback', null, 'p19', firestore);

  assert.equal(moved, true);
  // The 7.x SDK opens the transaction lazily on the first read.
  assert.deepEqual(calls.map((c) => c.method), ['batchGetDocuments', 'commit']);
  assert.ok(calls[0].request.newTransaction, 'first read opens the transaction');
  const write = calls[1].request.writes[0];
  assert.equal(write.update.fields.pendingFallback.stringValue, 'p19');
  assert.deepEqual(write.updateMask.fieldPaths, ['pendingFallback', 'updatedAt']);
  assert.equal(calls[1].request.transaction.toString(), 'tx');
});

test('[sdk-offline/scripted] real SDK wire: CAS against a different stored value writes nothing', async () => {
  const { firestore, calls, ref } = scriptedSdk({ stored: 'p39' });

  const moved = await advanceRecoveryCursor(ref, 'pendingFallback', 'p19', 'p29', firestore);

  assert.equal(moved, false);
  const writes = calls.filter((c) => c.method === 'commit').flatMap((c) => c.request.writes || []);
  assert.deepEqual(writes, []);
});

test('[sdk-offline/scripted] real SDK wire: after ABORTED the SDK re-runs the callback on fresh data and CAS then refuses the stale move', async () => {
  const { firestore, calls, ref } = scriptedSdk({
    stored: 'p19',               // first attempt sees what the stale run expected...
    abortFirstCommit: true,      // ...but another run commits first (server aborts us)
    storedAfterAbort: 'p39',     // retry reads the new value
  });

  const moved = await advanceRecoveryCursor(ref, 'pendingFallback', 'p19', 'p29', firestore);

  assert.equal(moved, false, 'stale writer must lose after the retry');
  const methods = calls.map((c) => c.method);
  assert.ok(methods.includes('rollback'), 'SDK rolled the aborted attempt back');
  assert.equal(methods.filter((m) => m === 'batchGetDocuments').length, 2, 'callback re-ran');
});
