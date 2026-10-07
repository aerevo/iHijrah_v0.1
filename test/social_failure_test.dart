import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ihijrah_app/services/social_failure.dart';

FirebaseException _fe(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

void main() {
  group('socialFailureFromError', () {
    test('maps permission-denied', () {
      expect(socialFailureFromError(_fe('permission-denied')),
          SocialFailure.permissionDenied);
    });

    test('maps unauthenticated', () {
      expect(socialFailureFromError(_fe('unauthenticated')),
          SocialFailure.unauthenticated);
    });

    test('maps network-type errors', () {
      for (final code in ['unavailable', 'deadline-exceeded', 'cancelled']) {
        expect(socialFailureFromError(_fe(code)), SocialFailure.network,
            reason: code);
      }
    });

    test('maps conflict-type errors', () {
      for (final code in ['already-exists', 'aborted', 'failed-precondition']) {
        expect(socialFailureFromError(_fe(code)), SocialFailure.conflict,
            reason: code);
      }
    });

    test('maps not-found', () {
      expect(socialFailureFromError(_fe('not-found')), SocialFailure.notFound);
    });

    test('unknown / non-Firebase errors fall back to unknown', () {
      expect(socialFailureFromError(_fe('something-else')),
          SocialFailure.unknown);
      expect(socialFailureFromError(StateError('x')), SocialFailure.unknown);
    });

    test('messages never leak raw Firebase details', () {
      for (final f in SocialFailure.values) {
        expect(f.message.toLowerCase().contains('firebase'), isFalse);
        expect(f.message.contains('['), isFalse);
      }
    });
  });
}
