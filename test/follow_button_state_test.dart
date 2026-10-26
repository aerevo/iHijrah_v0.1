import 'package:flutter_test/flutter_test.dart';
import 'package:ihijrah_app/screens/user_profile_screen.dart';

/// Logik tulen butang Ikuti/Mengikuti (tanpa Firebase).
void main() {
  group('followButtonState', () {
    test('belum mengikuti: label Ikuti dan hantar follow=true', () {
      final FollowButtonState s =
          followButtonState(following: false, loading: false, busy: false);
      expect(s.label, 'Ikuti');
      expect(s.targetFollow, isTrue);
      expect(s.enabled, isTrue);
    });

    test('sedang mengikuti: label Mengikuti dan hantar follow=false', () {
      final FollowButtonState s =
          followButtonState(following: true, loading: false, busy: false);
      expect(s.label, 'Mengikuti');
      expect(s.targetFollow, isFalse);
      expect(s.enabled, isTrue);
    });

    test('status masih dimuat: butang dinyahaktif', () {
      final FollowButtonState s =
          followButtonState(following: false, loading: true, busy: false);
      expect(s.enabled, isFalse);
    });

    test('operasi sedang berjalan: butang dinyahaktif (elak ketik berganda)', () {
      final FollowButtonState s =
          followButtonState(following: true, loading: false, busy: true);
      expect(s.enabled, isFalse);
    });

    test('label tidak lagi dalam bahasa Inggeris', () {
      for (final bool following in <bool>[false, true]) {
        final String label = followButtonState(
          following: following,
          loading: false,
          busy: false,
        ).label;
        expect(label, isNot('Follow'));
        expect(label, isNot('Following'));
      }
    });
  });
}
