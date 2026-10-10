import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ihijrah_app/utils/bounded_timeout.dart';

// F3-B. Dua jenis ujian:
//  1. boundedOpTimeout — fungsi tulen (tingkah laku sebenar).
//  2. Pengawal STATIK sumber — membaca fail .dart dan memastikan laluan
//     padam akaun tidak kembali kepada bacaan cache / tunggu tanpa had.
//     Ini BUKAN ujian tingkah laku Firestore (tiada fake Firestore dalam
//     projek); ia mengesan regresi teks. Ruang putih dinormalkan.

// Ruang putih dikecilkan kepada satu ruang; ruang sebelum '.' dibuang
// supaya rantaian method yang dipecah baris sama dengan satu baris.
String _norm(String s) =>
    s.replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r' (?=\.)'), '');

String _region(String file, String from, [String? to]) {
  final String src = File(file).readAsStringSync();
  final int a = src.indexOf(from);
  expect(a, greaterThanOrEqualTo(0), reason: 'penanda "$from" hilang');
  final int b = to == null ? src.length : src.indexOf(to, a);
  expect(b, greaterThan(a), reason: 'penanda "$to" hilang');
  return _norm(src.substring(a, b));
}

int _count(String hay, String needle) =>
    needle.allMatches(hay).length;

void main() {
  group('static guard — F3-C persistent deletion marker (F01/D2)', () {
    late String userModel;
    late String body;

    setUpAll(() {
      userModel = File('lib/models/user_model.dart').readAsStringSync();
      body = _region(
        'lib/models/user_model.dart',
        'Future<void> deleteAccount({required String password}) async {',
        'static Future<UserModel> load() async',
      );
    });

    test('defines a UID-scoped persistent deletion marker', () {
      expect(
        userModel.contains(
          "static const String _deletionIncompleteUidKey =",
        ),
        isTrue,
      );
      expect(
        userModel.contains("'deletion_incomplete_uid'"),
        isTrue,
      );
    });

    test(
      'persists marker after re-authentication and freeze, before the request',
      () {
        final int reauth = body.indexOf(
          'await currentUser.reauthenticateWithCredential(credential);',
        );
        final int freeze = body.indexOf('_writesBlocked = true;', reauth);
        final int persist = body.indexOf(
          'await _persistDeletionIncompleteMarker(uid);',
          freeze,
        );
        final int request = body.indexOf(
          ".collection('accountDeletionRequests')",
          persist,
        );

        expect(reauth, greaterThanOrEqualTo(0));
        expect(freeze, greaterThan(reauth));
        expect(persist, greaterThan(freeze));
        expect(request, greaterThan(persist));
      },
    );

    test('restores marker into memory and enforces it only for matching UID', () {
      expect(
        userModel.contains(
          'final String? markerUid = prefs.getString(_deletionIncompleteUidKey);',
        ),
        isTrue,
      );
      expect(userModel.contains('_deletionMarkerUid = markerUid;'), isTrue);
      expect(
        userModel.contains('final String? currentUid = _uidOrNull();'),
        isTrue,
      );
      expect(userModel.contains('_enforceDeletionMarker(currentUid);'), isTrue);
      // pelaksanaan enforce: hanya UID yang sama dengan marker
      expect(
        userModel.contains('if (uid != null && uid == _deletionMarkerUid) {'),
        isTrue,
      );
    });

    test('local-session reset never removes the persisted marker', () {
      final String reset = _region(
        'lib/models/user_model.dart',
        'Future<void> resetLocalSession({bool preserveDeletionMarker = false}) async {',
        '// PADAM AKAUN — F01',
      );
      expect(reset.contains('prefs.remove(_deletionIncompleteUidKey)'), isFalse);
      expect(reset.contains('prefs.remove(_deletionSubmittedUidKey)'), isFalse);
    });

    test('deleteAccount never clears the marker (fail-closed)', () {
      expect(body.contains('_clearDeletionIncompleteMarker'), isFalse);
    });

    test('load restores the marker before reading cached user data', () {
      final int load = userModel.indexOf(
        'static Future<UserModel> load() async',
      );
      final int restore = userModel.indexOf(
        'await m._restoreDeletionIncompleteMarker();',
        load,
      );
      final int cachedData = userModel.indexOf(
        "final String? raw = prefs.getString('user_data');",
        load,
      );

      expect(load, greaterThanOrEqualTo(0));
      expect(restore, greaterThan(load));
      expect(cachedData, greaterThan(restore));
    });
  });

  group('boundedOpTimeout', () {
    const Duration cap = Duration(seconds: 30);

    test('is the cap when plenty of budget remains', () {
      expect(
        boundedOpTimeout(remaining: const Duration(seconds: 120), cap: cap),
        cap,
      );
    });

    test('never exceeds the remaining budget', () {
      expect(
        boundedOpTimeout(remaining: const Duration(seconds: 7), cap: cap),
        const Duration(seconds: 7),
      );
    });

    test('equal remaining and cap', () {
      expect(boundedOpTimeout(remaining: cap, cap: cap), cap);
    });

    test('zero when the budget is exhausted', () {
      expect(
        boundedOpTimeout(remaining: Duration.zero, cap: cap),
        Duration.zero,
      );
    });

    test('zero (not negative) when the budget is overdrawn', () {
      expect(
        boundedOpTimeout(remaining: const Duration(seconds: -5), cap: cap),
        Duration.zero,
      );
    });
  });

  group('static guard — SocialService purge path', () {
    late String purge;
    setUpAll(() {
      purge = _region(
        'lib/services/social_service.dart',
        'PADAM AKAUN: BERSIHKAN KANDUNGAN SOSIAL SAYA',
      );
    });

    test('uses server-only reads and never the default (cache) source', () {
      expect(purge.contains('GetOptions(source: Source.server)'), isTrue);
      expect(purge.contains('Source.serverAndCache'), isFalse);
      expect(purge.contains('Source.cache'), isFalse);
      expect(purge.contains('.get()'), isFalse);
      expect(
        _count(purge, '.get(_serverOnly)'),
        _count(purge, '.get('),
        reason: 'setiap .get( dalam purge mesti .get(_serverOnly)',
      );
    });

    test('every destructive wait goes through _purgeOp (bounded)', () {
      expect(purge.contains('await batch.commit()'), isFalse);
      expect(purge.contains('await c.reference.delete()'), isFalse);
      expect(purge.contains('await setLiked('), isFalse);
      expect(purge.contains('_purgeOp(t, () => batch.commit())'), isTrue);
      expect(purge.contains('_purgeOp(t, () => c.reference.delete())'), isTrue);
      expect(
        purge.contains('_purgeOp(t, () => setLiked(postId, like: false))'),
        isTrue,
      );
      expect(purge.contains('_purgeOp(tally, () => query.get(_serverOnly))'),
          isTrue);
    });

    test('the per-operation timeout is capped by the remaining budget', () {
      expect(purge.contains('t.opTimeout(_purgeOpTimeout)'), isTrue);
      expect(purge.contains('Duration _purgeTimeBudget = Duration(seconds: 120)'),
          isTrue,
          reason: 'bajet 120s mesti kekal');
    });

    test('timeout / budget exhaustion marks the scan incomplete', () {
      expect(purge.contains('t.scanComplete = false; t.stopped = true; throw TimeoutException'),
          isTrue);
    });

    test('the per-operation cap stays 30s', () {
      expect(purge.contains('Duration _purgeOpTimeout = Duration(seconds: 30)'),
          isTrue,
          reason: 'had operasi 30s mesti kekal');
    });

    test('per-operation timeout marks incomplete AND stopped BEFORE throwing',
        () {
      final String op = _region(
        'lib/services/social_service.dart',
        'Future<R> _purgeOp<R>(',
        '/// Padam like / komen / reply milik pengguna',
      );
      // Dua laluan: bajet habis sebelum mula, dan had operasi tamat.
      expect(_count(op, 't.scanComplete = false;'), 2);
      expect(_count(op, 't.stopped = true;'), 2);
      expect(_count(op, 'throw TimeoutException('), 2);
      // Tiada .timeout(limit) kosong yang melempar tanpa menanda tally.
      expect(op.contains('op().timeout(limit)'), isFalse);

      final int timeoutAt = op.indexOf('op().timeout(');
      expect(timeoutAt, greaterThanOrEqualTo(0));
      final String path = op.substring(timeoutAt);
      final int cb = path.indexOf('onTimeout:');
      final int sc = path.indexOf('t.scanComplete = false;');
      final int st = path.indexOf('t.stopped = true;');
      final int th = path.indexOf('throw TimeoutException(');
      expect(cb, greaterThanOrEqualTo(0), reason: 'onTimeout hilang');
      expect(sc, greaterThan(cb), reason: 'scanComplete mesti dalam onTimeout');
      expect(st, greaterThan(sc), reason: 'stopped mesti selepas scanComplete');
      expect(th, greaterThan(st),
          reason: 'TimeoutException mesti dilempar SELEPAS kedua-dua bendera');
    });

    test('removed counters are incremented only AFTER the awaited success', () {
      final int del = purge.indexOf('_purgeOp(t, () => c.reference.delete())');
      final int cInc = purge.indexOf('t.commentsRemoved++');
      expect(del, greaterThanOrEqualTo(0));
      expect(cInc, greaterThan(del));

      final int commit = purge.indexOf('_purgeOp(t, () => batch.commit())');
      final int rInc = purge.indexOf('t.repliesRemoved += fresh.length');
      expect(commit, greaterThanOrEqualTo(0));
      expect(rInc, greaterThan(commit));

      final int like = purge.indexOf('_purgeOp(t, () => setLiked(postId, like: false))');
      final int lInc = purge.indexOf('t.likesRemoved++');
      expect(like, greaterThanOrEqualTo(0));
      expect(lInc, greaterThan(like));
      // Hanya dikira jika keputusan setLiked ialah kejayaan.
      expect(purge.contains('if (r.isSuccess) { t.likesRemoved++;'), isTrue);
    });

    test('a timed-out first page is a failure, not an empty scan', () {
      expect(purge.contains('pageError is TimeoutException ? SocialFailure.network'),
          isTrue);
    });
  });

  group('static guard — setLiked() is unchanged for normal use', () {
    test('the like transaction itself has no timeout / server-only option', () {
      final String body = _region(
        'lib/services/social_service.dart',
        'Future<Result<bool, SocialFailure>> setLiked(',
        '// ── COMMENT',
      );
      expect(body.contains('runTransaction<void>('), isTrue);
      expect(body.contains('.timeout('), isFalse);
      expect(body.contains('Source.server'), isFalse);
    });
  });

  group('static guard — ProfileService.deleteMyProfileAndEdges', () {
    late String body;
    setUpAll(() {
      body = _region(
        'lib/services/profile_service.dart',
        'deleteMyProfileAndEdges() async {',
      );
    });

    test('reads are server-only and bounded', () {
      expect(body.contains('.get()'), isFalse);
      expect(_count(body, '.get(_serverOnly).timeout(_destructiveOpTimeout)'), 2);
    });

    test('writes are bounded', () {
      expect(body.contains('batch.commit().timeout(_destructiveOpTimeout)'), isTrue);
      expect(body.contains('_profile(me).delete().timeout(_destructiveOpTimeout)'),
          isTrue);
      expect(body.contains('await batch.commit();'), isFalse);
    });

    test('edge failure is still recorded, not swallowed as success', () {
      expect(body.contains('failedEdgeIds.add(doc.id)'), isTrue);
      expect(body.contains('edgesProcessed: seen.length'), isTrue);
    });
  });

  group('static guard — UserModel.deleteAccount request-only path (F01)', () {
    late String body;
    setUpAll(() {
      body = _region(
        'lib/models/user_model.dart',
        'Future<void> deleteAccount({required String password}) async {',
        'static Future<UserModel> load() async',
      );
    });

    test('the single Firestore write is bounded', () {
      expect(body.contains('.timeout(_destructiveOpTimeout)'), isTrue);
      expect(_count(body, '.timeout(_destructiveOpTimeout)'), 1);
    });

    test('no Firestore read and no cache-source usage', () {
      expect(body.contains('.get('), isFalse);
      expect(body.contains('Source.'), isFalse);
    });

    test('only bounded atomic request/status creation remains', () {
      expect(body.contains('WriteBatch'), isTrue);
      expect(body.contains("collection('accountDeletionRequests')"), isTrue);
      expect(body.contains("collection('accountDeletionStatus')"), isTrue);
      expect(_count(body, 'deletionBatch.set('), 2);
      expect(
        body.contains('await deletionBatch.commit().timeout(_destructiveOpTimeout);'),
        isTrue,
      );
      expect(body.contains('batch.delete('), isFalse);
      expect(body.contains('.delete('), isFalse);
      expect(body.contains('currentUser.delete'), isFalse);
      expect(body.contains('purgeMySocialContent'), isFalse);
      expect(body.contains('deleteMyProfileAndEdges'), isFalse);
      expect(body.contains("collection('users')"), isFalse);
      expect(body.contains("collection('posts')"), isFalse);
      expect(body.contains("collection('profiles')"), isFalse);
    });
  });
}
