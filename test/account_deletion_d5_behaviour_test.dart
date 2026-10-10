import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ihijrah_app/models/user_model.dart';
import 'package:ihijrah_app/utils/deletion_gate.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// D5 — ujian BEHAVIOUR (tanpa Firebase). Auth/Firestore diganti melalui
/// seam @visibleForTesting; SharedPreferences ialah mock sebenar.
void main() {
  const String markerKey = 'deletion_incomplete_uid';
  const String submittedKey = 'deletion_request_submitted_uid';
  const String evidenceKey = 'deletion_auth_gone_confirmed_uid';
  const String ownerKey = 'user_data_owner_uid';

  String? activeUid;
  int signOutCalls = 0;
  int statusFetches = 0;

  Map<String, Object> markerA({bool evidence = false}) => <String, Object>{
        markerKey: 'A',
        submittedKey: 'A',
        if (evidence) evidenceKey: 'A',
      };

  String profileJson(String name) => '{"name":"$name","bio":"b"}';

  Future<UserModel> loadWith(Map<String, Object> prefs, String? uid) async {
    SharedPreferences.setMockInitialValues(Map<String, Object>.from(prefs));
    activeUid = uid;
    return UserModel.load();
  }

  void installSeams({
    Map<String, dynamic>? status,
    bool statusThrows = false,
    Object? reloadThrows,
  }) {
    UserModel.debugStatusFetcher = (String uid) async {
      statusFetches++;
      if (statusThrows) throw Exception('network');
      return status;
    };
    UserModel.debugAuthReload = () async {
      if (reloadThrows != null) throw reloadThrows;
    };
    UserModel.debugAuthSignOut = () async {
      signOutCalls++;
      activeUid = null;
    };
  }

  FirebaseAuthException notFound() =>
      FirebaseAuthException(code: 'user-not-found');

  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  setUp(() {
    activeUid = null;
    signOutCalls = 0;
    statusFetches = 0;
    UserModel.debugUidOverride = () => activeUid;
  });

  tearDown(() {
    UserModel.debugUidOverride = null;
    UserModel.debugStatusFetcher = null;
    UserModel.debugAuthReload = null;
    UserModel.debugAuthSignOut = null;
    UserModel.debugBeforeAuthGoneCleanup = null;
  });

  group('load(): marker A + evidence A + UID B active', () {
    test('A cache (no owner) is NOT applied to B; nothing deleted', () async {
      final UserModel m = await loadWith(<String, Object>{
        ...markerA(evidence: true),
        'user_data': profileJson('Ali'),
      }, 'B');
      expect(m.name, '');
      expect(signOutCalls, 0);
      expect(m.debugDeletionMarkerUid, 'A');
      expect(m.debugWritesBlocked, isFalse); // B tidak dibekukan
      expect(m.hasOutstandingDeletionMarker, isFalse);
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), 'A');
      expect(p.getString(evidenceKey), 'A');
      // data mentah tidak dipadam (mungkin milik B)
      expect(p.getString('user_data'), isNotNull);
    });

    test('cache stamped as A is NOT applied to B', () async {
      final UserModel m = await loadWith(<String, Object>{
        ...markerA(evidence: true),
        'user_data': profileJson('Ali'),
        ownerKey: 'A',
      }, 'B');
      expect(m.name, '');
    });

    test('cache proven to belong to B IS applied to B', () async {
      final UserModel m = await loadWith(<String, Object>{
        ...markerA(evidence: true),
        'user_data': profileJson('Budi'),
        ownerKey: 'B',
      }, 'B');
      expect(m.name, 'Budi');
      expect(m.debugDeletionMarkerUid, 'A'); // marker A tidak dilonggarkan
      expect(m.debugWritesBlocked, isFalse);
    });
  });

  group('load(): restart while Auth-gone evidence exists', () {
    test('no active user: cleanup resumes, marker+evidence cleared', () async {
      final UserModel m = await loadWith(<String, Object>{
        ...markerA(evidence: true),
        'user_data': profileJson('Ali'),
        ownerKey: 'A',
      }, null);
      expect(m.name, '');
      expect(m.debugDeletionMarkerUid, isNull);
      expect(m.debugWritesBlocked, isFalse);
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), isNull);
      expect(p.getString(submittedKey), isNull);
      expect(p.getString(evidenceKey), isNull);
      expect(p.getString('user_data'), isNull);
      expect(p.getString(ownerKey), isNull);
    });

    test('evidence for a DIFFERENT uid than the marker does nothing', () async {
      final UserModel m = await loadWith(<String, Object>{
        markerKey: 'A',
        evidenceKey: 'X',
        'user_data': profileJson('Ali'),
      }, null);
      expect(m.debugDeletionMarkerUid, 'A');
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), 'A');
    });

    test('marker without evidence is never cleared by load()', () async {
      final UserModel m = await loadWith(markerA(), null);
      expect(m.debugDeletionMarkerUid, 'A');
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), 'A');
    });
  });

  group('load(): local cleanup failure', () {
    test('marker + evidence stay, A stays frozen, cache not applied', () async {
      UserModel.debugBeforeAuthGoneCleanup =
          () async => throw Exception('disk');
      final UserModel m = await loadWith(<String, Object>{
        ...markerA(evidence: true),
        'user_data': profileJson('Ali'),
      }, 'A');
      expect(m.debugWritesBlocked, isTrue);
      expect(m.isDeletionIncomplete, isTrue);
      expect(m.debugDeletionMarkerUid, 'A');
      expect(m.name, '');
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), 'A');
      expect(p.getString(evidenceKey), 'A');
    });
  });

  group('reconcileAccountDeletion()', () {
    test('no marker for active uid → none, no network', () async {
      installSeams();
      final UserModel m = await loadWith(markerA(), 'B');
      expect(await m.reconcileAccountDeletion(),
          AccountDeletionReconciliationResult.none);
      expect(statusFetches, 0);
      expect(signOutCalls, 0);
      expect(m.debugDeletionMarkerUid, 'A');
    });

    test('Auth user-not-found for A: cleans up, marker cleared', () async {
      installSeams(reloadThrows: notFound());
      final UserModel m = await loadWith(<String, Object>{
        ...markerA(),
        'user_data': profileJson('Ali'),
      }, 'A');
      m.name = 'Ali';
      expect(await m.reconcileAccountDeletion(),
          AccountDeletionReconciliationResult.authDeleted);
      expect(signOutCalls, 1);
      expect(m.name, '');
      expect(m.debugDeletionMarkerUid, isNull);
      expect(m.debugWritesBlocked, isFalse);
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), isNull);
      expect(p.getString(evidenceKey), isNull);
    });

    test('Auth-gone but UID B took over mid-flight: B untouched', () async {
      installSeams(reloadThrows: notFound());
      UserModel.debugAuthReload = () async {
        activeUid = 'B'; // Auth bertukar semasa semakan
        throw notFound();
      };
      final UserModel m = await loadWith(<String, Object>{
        ...markerA(),
        'user_data': profileJson('Budi'),
        ownerKey: 'B',
      }, 'A');
      final AccountDeletionReconciliationResult r =
          await m.reconcileAccountDeletion();
      expect(r, AccountDeletionReconciliationResult.unverifiable);
      expect(signOutCalls, 0);
      expect(activeUid, 'B');
      expect(m.debugDeletionMarkerUid, 'A'); // marker kekal
      expect(m.debugWritesBlocked, isFalse); // B tidak dibekukan
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString('user_data'), isNotNull); // data B tidak dipadam
      expect(p.getString(markerKey), 'A');
    });

    test('local cleanup failure ≠ success: unverifiable, marker kept', () async {
      installSeams(reloadThrows: notFound());
      UserModel.debugBeforeAuthGoneCleanup =
          () async => throw Exception('disk');
      final UserModel m = await loadWith(markerA(), 'A');
      final AccountDeletionReconciliationResult r =
          await m.reconcileAccountDeletion();
      expect(r, AccountDeletionReconciliationResult.unverifiable);
      expect(m.debugDeletionMarkerUid, 'A');
      expect(m.debugWritesBlocked, isTrue);
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), 'A');
      expect(p.getString(evidenceKey), 'A'); // bukti kekal utk sambung
    });

    test('server status unavailable + Auth present → statusMissing, frozen',
        () async {
      installSeams(statusThrows: true);
      final UserModel m = await loadWith(markerA(), 'A');
      expect(await m.reconcileAccountDeletion(),
          AccountDeletionReconciliationResult.statusMissing);
      expect(m.debugWritesBlocked, isTrue);
      expect(m.debugDeletionMarkerUid, 'A');
      expect(signOutCalls, 0);
    });

    test('status unavailable + Auth check fails (offline) → still frozen',
        () async {
      installSeams(
        statusThrows: true,
        reloadThrows: FirebaseAuthException(code: 'network-request-failed'),
      );
      final UserModel m = await loadWith(markerA(), 'A');
      expect(await m.reconcileAccountDeletion(),
          AccountDeletionReconciliationResult.statusMissing);
      expect(m.debugDeletionMarkerUid, 'A');
      expect(m.debugWritesBlocked, isTrue);
    });

    test('status completed but Auth still exists → never unfreezes', () async {
      installSeams(status: <String, dynamic>{'uid': 'A', 'status': 'completed'});
      final UserModel m = await loadWith(markerA(), 'A');
      expect(await m.reconcileAccountDeletion(),
          AccountDeletionReconciliationResult.completedButAuthStillExists);
      expect(m.debugWritesBlocked, isTrue);
      expect(m.debugDeletionMarkerUid, 'A');
      expect(signOutCalls, 0);
    });

    test('status completed + Auth unconfirmed (offline) → unverifiable',
        () async {
      installSeams(
        status: <String, dynamic>{'uid': 'A', 'status': 'completed'},
        reloadThrows: FirebaseAuthException(code: 'network-request-failed'),
      );
      final UserModel m = await loadWith(markerA(), 'A');
      expect(await m.reconcileAccountDeletion(),
          AccountDeletionReconciliationResult.unverifiable);
      expect(m.debugWritesBlocked, isTrue);
    });

    for (final MapEntry<String, AccountDeletionReconciliationResult> e
        in <String, AccountDeletionReconciliationResult>{
      'pending': AccountDeletionReconciliationResult.pending,
      'processing': AccountDeletionReconciliationResult.processing,
      'failed': AccountDeletionReconciliationResult.failed,
    }.entries) {
      test('status ${e.key} keeps marker + freeze, no clear', () async {
        installSeams(status: <String, dynamic>{'uid': 'A', 'status': e.key});
        final UserModel m = await loadWith(markerA(), 'A');
        expect(await m.reconcileAccountDeletion(), e.value);
        expect(m.debugWritesBlocked, isTrue);
        expect(m.debugDeletionMarkerUid, 'A');
        final SharedPreferences p = await SharedPreferences.getInstance();
        expect(p.getString(markerKey), 'A');
      });
    }

    test('unknown status / wrong uid / non-string → unverifiable', () async {
      for (final Map<String, dynamic> bad in <Map<String, dynamic>>[
        <String, dynamic>{'uid': 'A', 'status': 'weird'},
        <String, dynamic>{'uid': 'B', 'status': 'completed'},
        <String, dynamic>{'uid': 'A', 'status': 7},
        <String, dynamic>{'uid': 'A'},
      ]) {
        installSeams(status: bad);
        final UserModel m = await loadWith(markerA(), 'A');
        expect(await m.reconcileAccountDeletion(),
            AccountDeletionReconciliationResult.unverifiable);
        expect(m.debugWritesBlocked, isTrue);
      }
    });

    test('unexpected internal error never throws; marker kept', () async {
      installSeams();
      UserModel.debugStatusFetcher = (String uid) =>
          throw StateError('sync throw'); // bukan Future gagal
      final UserModel m = await loadWith(markerA(), 'A');
      final AccountDeletionReconciliationResult r =
          await m.reconcileAccountDeletion();
      expect(r, isNot(AccountDeletionReconciliationResult.authDeleted));
      expect(m.debugDeletionMarkerUid, 'A');
      expect(m.debugWritesBlocked, isTrue);
    });

    test('retry is safe: repeated reconcile makes no deletion request',
        () async {
      installSeams(status: <String, dynamic>{'uid': 'A', 'status': 'pending'});
      final UserModel m = await loadWith(markerA(), 'A');
      for (int i = 0; i < 3; i++) {
        expect(await m.reconcileAccountDeletion(),
            AccountDeletionReconciliationResult.pending);
      }
      expect(m.debugWritesBlocked, isTrue);
      expect(m.debugDeletionSubmittedUid, 'A');
      expect(statusFetches, 3); // hanya baca
    });
  });

  group('sign-out from recovery path keeps the marker', () {
    test('resetLocalSession(preserve) after outstanding marker', () async {
      installSeams(status: <String, dynamic>{'uid': 'A', 'status': 'pending'});
      final UserModel m = await loadWith(<String, Object>{
        ...markerA(),
        'user_data': profileJson('Ali'),
      }, 'A');
      await m.reconcileAccountDeletion();
      final bool outstanding = m.hasOutstandingDeletionMarker;
      expect(outstanding, isTrue);
      activeUid = null;
      await m.resetLocalSession(preserveDeletionMarker: outstanding);
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), 'A');
      expect(p.getString(submittedKey), 'A');
      expect(m.debugWritesBlocked, isTrue);
      // login semula sebagai A → masih beku; B → tidak
      m.debugHandleAuthUid('A');
      expect(m.debugWritesBlocked, isTrue);
      m.debugHandleAuthUid('B');
      expect(m.debugWritesBlocked, isFalse);
      expect(m.debugDeletionMarkerUid, 'A');
    });
  });

  group('navigation gate — every reconciliation result', () {
    test('only none-without-marker proceeds', () {
      for (final AccountDeletionReconciliationResult r
          in AccountDeletionReconciliationResult.values) {
        final DeletionGateAction noMarker =
            deletionGateAction(r, markerOutstanding: false);
        final DeletionGateAction withMarker =
            deletionGateAction(r, markerOutstanding: true);
        // marker tertunggak TIDAK PERNAH membenarkan navigasi biasa
        expect(withMarker, DeletionGateAction.showRecovery, reason: '$r');
        if (r == AccountDeletionReconciliationResult.none) {
          expect(noMarker, DeletionGateAction.proceed);
        } else if (r == AccountDeletionReconciliationResult.authDeleted) {
          expect(noMarker, DeletionGateAction.showAuth);
        } else {
          // pending/processing/failed/statusMissing/
          // completedButAuthStillExists/unverifiable
          expect(noMarker, DeletionGateAction.showRecovery, reason: '$r');
        }
      }
    });

    test('screens route through the gate before pull/onboarding/Home', () {
      String read(String p) => File(p).readAsStringSync();
      final String auth = read('lib/screens/auth_screen.dart');
      expect(auth.indexOf('deletionGateAction('),
          lessThan(auth.indexOf('await user.pullFromCloud();')));
      final String email = read('lib/screens/email_verification_screen.dart');
      expect(email.indexOf('deletionGateAction('),
          lessThan(email.indexOf('final bool needsOnboarding')));
      final String splash = read('lib/screens/splash_screen.dart');
      expect(splash, contains('deletionGateAction('));
      expect(splash.indexOf('deletionGateAction('),
          lessThan(splash.indexOf('const HomePage()')));
    });
  });

  group('pull is blocked while marker outstanding', () {
    test('pullFromCloudDetailed returns blocked for frozen A', () async {
      installSeams();
      final UserModel m = await loadWith(markerA(), 'A');
      expect(await m.pullFromCloudDetailed(), CloudPullResult.blocked);
    });
  });
}
