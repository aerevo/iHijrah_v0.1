import 'package:flutter_test/flutter_test.dart';
import 'package:ihijrah_app/models/user_model.dart';

// Primitif yang digunakan oleh SETIAP laluan tulis UserModel (termasuk
// pull dan syncPublicProfile yang dipanggil oleh bootstrap Home) untuk
// menolak kerja async daripada sesi lama. Ujian ini tidak memerlukan
// Firebase.
void main() {
  group('UserModel.isStaleSession', () {
    test('same UID and same generation is NOT stale', () {
      expect(
        UserModel.isStaleSession(
          'uidA',
          'uidA',
          capturedGeneration: 3,
          currentGeneration: 3,
        ),
        isFalse,
      );
    });

    test('different UID is stale', () {
      expect(
        UserModel.isStaleSession(
          'uidA',
          'uidB',
          capturedGeneration: 3,
          currentGeneration: 3,
        ),
        isTrue,
      );
    });

    test('logged out (null current UID) is stale', () {
      expect(
        UserModel.isStaleSession(
          'uidA',
          null,
          capturedGeneration: 3,
          currentGeneration: 3,
        ),
        isTrue,
      );
    });

    test('same UID but newer generation (re-login) is stale', () {
      expect(
        UserModel.isStaleSession(
          'uidA',
          'uidA',
          capturedGeneration: 3,
          currentGeneration: 5,
        ),
        isTrue,
      );
    });

    test('without generations, only the UID decides', () {
      expect(UserModel.isStaleSession('uidA', 'uidA'), isFalse);
      expect(UserModel.isStaleSession('uidA', 'uidB'), isTrue);
    });
  });
}
