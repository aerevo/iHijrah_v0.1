import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ihijrah_app/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// D5-A — ujian BEHAVIOUR untuk resendDeletionRequest (tanpa Firebase).
/// Auth/Firestore diganti melalui seam @visibleForTesting; SharedPreferences
/// ialah mock sebenar.
void main() {
  const String markerKey = 'deletion_incomplete_uid';
  const String submittedKey = 'deletion_request_submitted_uid';

  String? activeUid;
  int signOutCalls = 0;
  int statusFetches = 0;
  int submitCalls = 0;

  Future<UserModel> loadWith(Map<String, Object> prefs, String? uid) async {
    SharedPreferences.setMockInitialValues(Map<String, Object>.from(prefs));
    activeUid = uid;
    return UserModel.load();
  }

  /// [statuses] diberi satu demi satu pada setiap bacaan status server;
  /// nilai terakhir diulang. `null` = dokumen tiada.
  void installSeams({
    List<Map<String, dynamic>?> statuses = const <Map<String, dynamic>?>[null],
    bool statusThrows = false,
    Object? reloadThrows,
    Object? submitThrows,
    Object? pendingWritesThrows,
  }) {
    UserModel.debugStatusFetcher = (String uid) async {
      final int i = statusFetches < statuses.length
          ? statusFetches
          : statuses.length - 1;
      statusFetches++;
      if (statusThrows) throw Exception('network');
      return statuses[i];
    };
    UserModel.debugAuthReload = () async {
      if (reloadThrows != null) throw reloadThrows;
    };
    UserModel.debugAuthSignOut = () async {
      signOutCalls++;
      activeUid = null;
    };
    UserModel.debugWaitForPendingWrites = () async {
      if (pendingWritesThrows != null) throw pendingWritesThrows;
    };
    UserModel.debugSubmitDeletion = (String password) async {
      submitCalls++;
      if (submitThrows != null) throw submitThrows;
    };
  }

  // Marker niat ada, penanda "dihantar" TIADA (request tidak sampai server).
  Map<String, Object> unsubmittedA() => <String, Object>{markerKey: 'A'};

  // Marker niat dan penanda "dihantar" kedua-duanya ada.
  Map<String, Object> submittedA() =>
      <String, Object>{markerKey: 'A', submittedKey: 'A'};

  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  setUp(() {
    activeUid = null;
    signOutCalls = 0;
    statusFetches = 0;
    submitCalls = 0;
    UserModel.debugUidOverride = () => activeUid;
  });

  tearDown(() {
    UserModel.debugUidOverride = null;
    UserModel.debugStatusFetcher = null;
    UserModel.debugAuthReload = null;
    UserModel.debugAuthSignOut = null;
    UserModel.debugBeforeAuthGoneCleanup = null;
    UserModel.debugWaitForPendingWrites = null;
    UserModel.debugSubmitDeletion = null;
  });

  group('F2-2: hantar semula hanya apabila semua bukti ada', () {
    test('marker ada, "dihantar" tiada, server sahkan status tiada → hantar SEKALI',
        () async {
      installSeams();
      final UserModel m = await loadWith(unsubmittedA(), 'A');

      expect(m.hasUnsubmittedDeletionMarker, isTrue);
      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.resent);

      expect(submitCalls, 1);
      expect(statusFetches, 1);
      expect(m.debugWritesBlocked, isTrue);
      expect(m.debugDeletionMarkerUid, 'A');
    });

    test('tiada marker → tidak dibenarkan, tiada request', () async {
      installSeams();
      final UserModel m = await loadWith(<String, Object>{}, 'A');

      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.notAllowed);
      expect(submitCalls, 0);
      expect(statusFetches, 0);
    });

    test('tiada pengguna aktif → tidak dibenarkan, tiada request', () async {
      installSeams();
      final UserModel m = await loadWith(unsubmittedA(), null);

      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.notAllowed);
      expect(submitCalls, 0);
    });

    test('bacaan status server gagal → tidak dihantar, kekal beku', () async {
      installSeams(statusThrows: true);
      final UserModel m = await loadWith(unsubmittedA(), 'A');

      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.notAllowed);
      expect(submitCalls, 0);
      expect(m.debugWritesBlocked, isTrue);
      expect(m.debugDeletionMarkerUid, 'A');
    });

    test('penulisan tertangguh belum selesai → tidak dihantar', () async {
      installSeams(pendingWritesThrows: TimeoutException('pending'));
      final UserModel m = await loadWith(unsubmittedA(), 'A');

      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.notAllowed);
      expect(submitCalls, 0);
      expect(statusFetches, 0);
      expect(m.debugWritesBlocked, isTrue);
    });

    test('Auth tidak dapat disahkan (offline) → tidak dihantar', () async {
      installSeams(
        reloadThrows: FirebaseAuthException(code: 'network-request-failed'),
      );
      final UserModel m = await loadWith(unsubmittedA(), 'A');

      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.notAllowed);
      expect(submitCalls, 0);
      expect(m.debugDeletionMarkerUid, 'A');
    });

    test('Auth disahkan tiada (user-not-found) → accountDeleted, tiada request',
        () async {
      installSeams(reloadThrows: FirebaseAuthException(code: 'user-not-found'));
      final UserModel m = await loadWith(unsubmittedA(), 'A');

      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.accountDeleted);
      expect(submitCalls, 0);
      expect(signOutCalls, 1);
      final SharedPreferences p = await SharedPreferences.getInstance();
      expect(p.getString(markerKey), isNull);
    });

    test('status completed tetapi Auth masih wujud → tidak dihantar', () async {
      installSeams(statuses: <Map<String, dynamic>?>[
        <String, dynamic>{'uid': 'A', 'status': 'completed'},
      ]);
      final UserModel m = await loadWith(unsubmittedA(), 'A');

      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.notAllowed);
      expect(submitCalls, 0);
      expect(m.debugWritesBlocked, isTrue);
    });
  });

  group('F2-3: status wujud / permission-denied → baca semula, tiada gelung',
      () {
    for (final String s in <String>['pending', 'processing', 'failed']) {
      test('status $s sudah wujud → tandakan dihantar, TIADA request kedua',
          () async {
        installSeams(statuses: <Map<String, dynamic>?>[
          <String, dynamic>{'uid': 'A', 'status': s},
        ]);
        final UserModel m = await loadWith(unsubmittedA(), 'A');

        expect(await m.resendDeletionRequest(password: 'pw'),
            DeletionResendResult.alreadySubmitted);
        expect(submitCalls, 0);
        expect(m.debugDeletionSubmittedUid, 'A');
        final SharedPreferences p = await SharedPreferences.getInstance();
        expect(p.getString(submittedKey), 'A');
        expect(m.debugWritesBlocked, isTrue);
      });
    }

    test('permission-denied lalu status wujud → alreadySubmitted tanpa ralat',
        () async {
      installSeams(
        statuses: <Map<String, dynamic>?>[
          null,
          <String, dynamic>{'uid': 'A', 'status': 'pending'},
        ],
        submitThrows:
            FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );
      final UserModel m = await loadWith(unsubmittedA(), 'A');

      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.alreadySubmitted);
      expect(submitCalls, 1);
      expect(statusFetches, 2);
      expect(m.debugDeletionSubmittedUid, 'A');
    });

    test('permission-denied dan status masih tiada → failed, tiada percubaan kedua',
        () async {
      installSeams(
        statuses: <Map<String, dynamic>?>[null],
        submitThrows:
            FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );
      final UserModel m = await loadWith(unsubmittedA(), 'A');

      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.failed);
      expect(submitCalls, 1);
      expect(statusFetches, 2);
      expect(m.debugWritesBlocked, isTrue);
      expect(m.debugDeletionMarkerUid, 'A');
      expect(m.debugDeletionSubmittedUid, isNull);
    });

    test('ralat lain semasa hantar → failed, kekal beku, penanda tidak ditulis',
        () async {
      installSeams(submitThrows: Exception('timeout'));
      final UserModel m = await loadWith(unsubmittedA(), 'A');

      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.failed);
      expect(submitCalls, 1);
      expect(m.debugWritesBlocked, isTrue);
      expect(m.debugDeletionSubmittedUid, isNull);
    });
  });

  group('F2-4: penanda "dihantar" ada tetapi status tiada → kekal beku', () {
    test('tidak dihantar semula, tiada bacaan, tiada request', () async {
      installSeams();
      final UserModel m = await loadWith(submittedA(), 'A');

      expect(m.hasUnsubmittedDeletionMarker, isFalse);
      expect(await m.resendDeletionRequest(password: 'pw'),
          DeletionResendResult.notAllowed);
      expect(submitCalls, 0);
      expect(statusFetches, 0);
      expect(m.debugWritesBlocked, isTrue);
      expect(m.debugDeletionMarkerUid, 'A');
      expect(m.debugDeletionSubmittedUid, 'A');
    });
  });

  group('F2-6: kata laluan (reauth)', () {
    test('kata laluan salah → FirebaseAuthException; tiada penanda dihantar',
        () async {
      installSeams(
        submitThrows: FirebaseAuthException(code: 'wrong-password'),
      );
      final UserModel m = await loadWith(unsubmittedA(), 'A');

      await expectLater(
        m.resendDeletionRequest(password: 'salah'),
        throwsA(isA<FirebaseAuthException>()),
      );
      expect(submitCalls, 1);
      expect(m.debugDeletionSubmittedUid, isNull);
      expect(m.debugDeletionMarkerUid, 'A');
      expect(m.debugWritesBlocked, isTrue);
    });
  });
}
