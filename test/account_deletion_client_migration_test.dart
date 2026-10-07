import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ihijrah_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// F01 + D2.
//  • Kumpulan 'static guard' membaca sumber .dart (tiada fake Firebase dalam
//    projek) — ia mengesan regresi teks, BUKAN tingkah laku runtime Firebase.
//  • Kumpulan 'behaviour' menguji marker/sesi sebenar UserModel dengan
//    SharedPreferences tiruan dan penggantian UID ujian (tanpa Firebase).
//    deleteAccount() sendiri TIDAK dijalankan di sini (perlukan Firebase).

String _norm(String s) =>
    s.replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r' (?=\.)'), '');

String _between(String file, String from, String to) {
  final String src = File(file).readAsStringSync();
  final int a = src.indexOf(from);
  expect(a, greaterThanOrEqualTo(0), reason: 'penanda "$from" hilang');
  final int b = src.indexOf(to, a);
  expect(b, greaterThan(a), reason: 'penanda "$to" hilang');
  return _norm(src.substring(a, b));
}

String _deleteAccountBody() => _between(
      'lib/models/user_model.dart',
      'Future<void> deleteAccount({required String password}) async {',
      'static Future<UserModel> load() async',
    );

void main() {
  group('static guard — F01 deleteAccount() request-only contract', () {
    late String body;
    setUpAll(() => body = _deleteAccountBody());

    test('request path is accountDeletionRequests/{uid} with EXACT payload', () {
      expect(
        body.contains(
          ".collection('accountDeletionRequests').doc(uid)"
          ".set(<String, dynamic>{ 'uid': uid, 'status': 'pending', "
          "'createdAt': FieldValue.serverTimestamp(), })"
          '.timeout(_destructiveOpTimeout);',
        ),
        isTrue,
      );
      // tepat tiga kunci
      final int open = body.indexOf('.set(<String, dynamic>{');
      final int close = body.indexOf('})', open);
      final String map = body.substring(open, close);
      expect(RegExp(r"'[A-Za-z]+':").allMatches(map).length, 3);
    });

    test('order: reauth → freeze → invalidate → marker → drain → request → submitted',
        () {
      final int reauth = body
          .indexOf('await currentUser.reauthenticateWithCredential(credential);');
      final int freeze = body.indexOf('_writesBlocked = true;', reauth);
      final int invalidate = body.indexOf('_invalidateSession();', freeze);
      final int marker =
          body.indexOf('await _persistDeletionIncompleteMarker(uid);', invalidate);
      final int drain =
          body.indexOf('await _drainPushChain(', marker);
      final int request =
          body.indexOf(".collection('accountDeletionRequests')", drain);
      final int submitted = body
          .indexOf('await _persistDeletionSubmittedMarker(uid);', request);
      expect(reauth, greaterThanOrEqualTo(0));
      expect(freeze, greaterThan(reauth));
      expect(invalidate, greaterThan(freeze));
      expect(marker, greaterThan(invalidate));
      expect(drain, greaterThan(marker));
      expect(request, greaterThan(drain));
      expect(submitted, greaterThan(request));
    });

    test('fail-closed: no unblock / marker clear / permission-denied branch after marker',
        () {
      final int marker =
          body.indexOf('await _persistDeletionIncompleteMarker(uid);');
      final int drain = body.indexOf('await _drainPushChain(', marker);
      // Satu-satunya pembukaan beku ialah rollback bila marker GAGAL ditulis
      // (di antara persist dan drain).
      expect(RegExp('_writesBlocked = false;').allMatches(body).length, 1);
      final int rollback = body.indexOf('_writesBlocked = false;');
      expect(rollback, greaterThan(marker));
      expect(rollback, lessThan(drain));
      final String afterDrain = body.substring(drain);
      expect(afterDrain.contains('_writesBlocked = false'), isFalse);
      expect(afterDrain.contains('_deletionIncomplete = false'), isFalse);
      expect(afterDrain.contains('_clearDeletionIncompleteMarker'), isFalse);
      expect(afterDrain.contains('catch'), isFalse,
          reason: 'ralat request mesti dilempar apa adanya (finally sahaja)');
      expect(body.contains('permission-denied'), isFalse);
    });

    test('already-submitted UID returns without reauth or a second request', () {
      final int guard = body
          .indexOf('_deletionMarkerUid == uid && _deletionSubmittedUid == uid');
      final int ret = body.indexOf('return;', guard);
      final int reauth =
          body.indexOf('await currentUser.reauthenticateWithCredential(');
      final int request = body.indexOf(".collection('accountDeletionRequests')");
      expect(guard, greaterThanOrEqualTo(0));
      expect(ret, greaterThan(guard));
      expect(ret, lessThan(reauth));
      expect(ret, lessThan(request));
    });

    test('submitted marker is cached BEFORE the prefs write', () {
      final String s = _between(
        'lib/models/user_model.dart',
        'Future<void> _persistDeletionSubmittedMarker(String uid) async {',
        'Future<void> _clearDeletionIncompleteMarker()',
      );
      final int cache = s.indexOf('_deletionSubmittedUid = uid;');
      final int write =
          s.indexOf('await prefs.setString(_deletionSubmittedUidKey, uid);');
      expect(cache, greaterThanOrEqualTo(0));
      expect(write, greaterThan(cache));
    });
  });

  group('static guard — D2 logout preserves outstanding marker', () {
    test('signOutAndReset: determine → invalidate → signOut → preserving reset',
        () {
      final String s = _between(
        'lib/models/user_model.dart',
        'Future<void> signOutAndReset() async {',
        'Future<void> _persistDeletionIncompleteMarker',
      );
      final int det = s.indexOf('hasOutstandingDeletionMarker');
      final int inv = s.indexOf('_invalidateSession();', det);
      final int out = s.indexOf('await FirebaseAuth.instance.signOut();', inv);
      final int reset = s.indexOf(
          'await resetLocalSession(preserveDeletionMarker: deletionOutstanding);',
          out);
      expect(det, greaterThanOrEqualTo(0));
      expect(inv, greaterThan(det));
      expect(out, greaterThan(inv));
      expect(reset, greaterThan(out));
    });

    for (final String file in <String>[
      'lib/widgets/settings_view.dart',
      'lib/screens/email_verification_screen.dart',
    ]) {
      test('$file: determine BEFORE signOut, reset with preserve flag', () {
        final String src = _norm(File(file).readAsStringSync());
        final int det = src.indexOf('hasOutstandingDeletionMarker');
        final int out =
            src.indexOf('await FirebaseAuth.instance.signOut();', det);
        final int reset = src.indexOf(
            'resetLocalSession( preserveDeletionMarker: deletionOutstanding,', out);
        expect(det, greaterThanOrEqualTo(0));
        expect(out, greaterThan(det));
        expect(reset, greaterThan(out));
        expect(src.contains('resetLocalSession();'), isFalse,
            reason: 'reset tanpa preservasi dilarang');
      });
    }

    test('resetLocalSession never removes the persisted marker', () {
      final String s = _between(
        'lib/models/user_model.dart',
        'Future<void> resetLocalSession({bool preserveDeletionMarker = false}) async {',
        '// PADAM AKAUN — F01',
      );
      expect(s.contains('_deletionIncompleteUidKey'), isFalse);
      expect(s.contains('_deletionSubmittedUidKey'), isFalse);
      expect(s.contains('if (!preserveDeletionMarker) {'), isTrue);
    });

    test('marker enforced BEFORE every early return', () {
      final String adopt = _between(
        'lib/models/user_model.dart',
        'void _adoptSessionIdentity(String? uid) {',
        'void _enforceDeletionMarker(',
      );
      final int enforce = adopt.indexOf('_enforceDeletionMarker(uid);');
      final int early = adopt.indexOf('return;');
      expect(enforce, greaterThanOrEqualTo(0));
      expect(enforce, lessThan(early));

      final String event = _between(
        'lib/models/user_model.dart',
        'void _handleAuthUid(String? uid) {',
        '@override',
      );
      final int e1 = event.indexOf('_enforceDeletionMarker(uid);');
      final int r1 = event.indexOf('return;');
      expect(e1, greaterThanOrEqualTo(0));
      expect(e1, lessThan(r1));
    });

    test('restore caches the marker and enforces for current AND adopted UID', () {
      final String s = _between(
        'lib/models/user_model.dart',
        'Future<void> _restoreDeletionIncompleteMarker() async {',
        '/// F3-E: Bersihkan fail avatar local',
      );
      expect(s.contains('_deletionMarkerUid = markerUid;'), isTrue);
      expect(s.contains('_enforceDeletionMarker(currentUid);'), isTrue);
      expect(s.contains('_enforceDeletionMarker(_sessionUid);'), isTrue);
    });
  });

  group('static guard — UI success is "submitted", not "deleted"', () {
    test('settings success path shows submitted message, no AuthScreen', () {
      final String s = _between(
        'lib/widgets/settings_view.dart',
        'await user.deleteAccount(password: password);',
        'on FirebaseAuthException',
      );
      expect(s.contains('deleteAccountSubmittedMessage'), isTrue);
      expect(s.contains('AuthScreen'), isFalse);
    });
  });

  group('behaviour — D2 marker / session (no Firebase)', () {
    const String markerKey = 'deletion_incomplete_uid';
    const String submittedKey = 'deletion_request_submitted_uid';

    Future<UserModel> loadWith({
      Map<String, Object> prefs = const <String, Object>{},
      String? uid,
    }) async {
      SharedPreferences.setMockInitialValues(Map<String, Object>.from(prefs));
      UserModel.debugUidOverride = () => uid;
      return UserModel.load();
    }

    setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());
    tearDown(() => UserModel.debugUidOverride = null);

    const Map<String, Object> markerA = <String, Object>{
      markerKey: 'A',
      submittedKey: 'A',
    };

    test('restart + same UID restores the freeze', () async {
      final UserModel m = await loadWith(prefs: markerA, uid: 'A');
      expect(m.isDeletionIncomplete, isTrue);
      expect(m.debugWritesBlocked, isTrue);
      expect(m.hasOutstandingDeletionMarker, isTrue);
    });

    test('restart + different UID does NOT inherit the freeze', () async {
      final UserModel m = await loadWith(prefs: markerA, uid: 'B');
      expect(m.isDeletionIncomplete, isFalse);
      expect(m.debugWritesBlocked, isFalse);
      expect(m.hasOutstandingDeletionMarker, isFalse);
      expect(m.debugDeletionMarkerUid, 'A'); // marker kekal
    });

    test('Auth not yet resolved at load keeps the marker; later event freezes',
        () async {
      final UserModel m = await loadWith(prefs: markerA, uid: null);
      expect(m.debugWritesBlocked, isFalse);
      expect(m.debugDeletionMarkerUid, 'A');
      m.debugHandleAuthUid('A'); // event baseline
      expect(m.debugWritesBlocked, isTrue);
      expect(m.isDeletionIncomplete, isTrue);
    });

    test('same-UID relogin restores freeze; other UID does not', () async {
      final UserModel m = await loadWith(prefs: markerA, uid: 'A');
      m.debugHandleAuthUid('A'); // baseline
      m.debugHandleAuthUid(null); // logout
      expect(m.debugWritesBlocked, isFalse);
      expect(m.debugDeletionMarkerUid, 'A');
      m.debugHandleAuthUid('A'); // relogin
      expect(m.debugWritesBlocked, isTrue);
      m.debugHandleAuthUid('B');
      expect(m.debugWritesBlocked, isFalse);
      m.debugHandleAuthUid('A');
      expect(m.debugWritesBlocked, isTrue);
    });

    test('same-UID early-return path still enforces the marker', () async {
      final UserModel m = await loadWith(prefs: markerA, uid: 'A');
      await m.resetLocalSession(); // _sessionUid = 'A', sekatan dilepas
      expect(m.debugWritesBlocked, isFalse);
      m.debugHandleAuthUid('A'); // uid == _sessionUid
      expect(m.debugWritesBlocked, isTrue);
    });

    test('preserve reset clears profile data but keeps marker + freeze', () async {
      final UserModel m = await loadWith(prefs: markerA, uid: 'A');
      m.name = 'Ali';
      m.bio = 'bio';
      m.totalPoints = 42;
      await m.resetLocalSession(preserveDeletionMarker: true);
      expect(m.name, '');
      expect(m.bio, '');
      expect(m.totalPoints, 0);
      expect(m.debugWritesBlocked, isTrue);
      expect(m.isDeletionIncomplete, isTrue);
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), 'A');
      expect(p.getString(submittedKey), 'A');
    });

    test('normal logout without marker is unchanged', () async {
      final UserModel m = await loadWith(uid: 'A');
      m.name = 'Ali';
      await m.resetLocalSession();
      expect(m.name, '');
      expect(m.debugWritesBlocked, isFalse);
      expect(m.isDeletionIncomplete, isFalse);
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.containsKey(markerKey), isFalse);
      expect(p.containsKey(submittedKey), isFalse);
    });

    test('another account logging out does not erase a persisted marker',
        () async {
      final UserModel m = await loadWith(prefs: markerA, uid: 'B');
      await m.resetLocalSession();
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), 'A');
      expect(m.debugDeletionMarkerUid, 'A');
    });
  });
}
