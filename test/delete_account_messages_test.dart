import 'package:flutter_test/flutter_test.dart';
import 'package:ihijrah_app/utils/delete_account_messages.dart';

void main() {
  group('deleteAccountErrorMessage — nothing deleted yet', () {
    test('wrong-password', () {
      expect(
        deleteAccountErrorMessage(
          deletionIncomplete: false,
          authErrorCode: 'wrong-password',
        ),
        'Kata laluan salah. Akaun TIDAK dipadam.',
      );
    });

    test('invalid-credential', () {
      expect(
        deleteAccountErrorMessage(
          deletionIncomplete: false,
          authErrorCode: 'invalid-credential',
        ),
        'Kata laluan salah. Akaun TIDAK dipadam.',
      );
    });

    test('too-many-requests', () {
      expect(
        deleteAccountErrorMessage(
          deletionIncomplete: false,
          authErrorCode: 'too-many-requests',
        ),
        'Terlalu banyak percubaan. Cuba lagi sebentar.',
      );
    });

    test('other auth error', () {
      expect(
        deleteAccountErrorMessage(
          deletionIncomplete: false,
          authErrorCode: 'network-request-failed',
        ),
        'Pengesahan gagal. Akaun TIDAK dipadam.',
      );
    });

    test('non-auth error', () {
      expect(
        deleteAccountErrorMessage(deletionIncomplete: false),
        'Ralat semasa memadam akaun. Sila cuba lagi atau hubungi sokongan.',
      );
    });
  });

  group('deleteAccountSubmittedMessage — F01', () {
    test('says the request was submitted and does not claim completion', () {
      expect(deleteAccountSubmittedMessage.contains('dihantar'), isTrue);
      expect(deleteAccountSubmittedMessage.contains('sedang diproses'), isTrue);
      expect(deleteAccountSubmittedMessage.contains('telah dipadam'), isFalse);
      expect(deleteAccountSubmittedMessage.contains('berjaya dipadam'), isFalse);
    });
  });

  group('deleteAccountErrorMessage — deletion already started', () {
    test('never says "TIDAK dipadam", whatever the error type', () {
      final List<String?> codes = <String?>[
        null,
        'requires-recent-login',
        'network-request-failed',
        'wrong-password',
        'invalid-credential',
        'too-many-requests',
        'user-token-expired',
      ];
      for (final String? code in codes) {
        final String msg = deleteAccountErrorMessage(
          deletionIncomplete: true,
          authErrorCode: code,
        );
        expect(msg.contains('TIDAK dipadam'), isFalse, reason: 'code=$code');
        expect(msg.contains('sekali lagi'), isTrue, reason: 'code=$code');
      }
    });
  });
}
