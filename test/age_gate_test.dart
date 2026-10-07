import 'package:flutter_test/flutter_test.dart';
import 'package:ihijrah_app/utils/age_helper.dart';
import 'package:ihijrah_app/utils/constants.dart';

// Menguji keputusan yang digunakan oleh onboarding DAN skrin edit tarikh
// lahir: isAtLeastAge(tarikh, kMinimumAccountAge). `now` ditetapkan supaya
// keputusan tidak bergantung pada tarikh larian.
void main() {
  final DateTime now = DateTime(2026, 9, 30);
  bool allowed(DateTime dob, [DateTime? at]) =>
      isAtLeastAge(dob, kMinimumAccountAge, at ?? now);

  test('minimum age product setting is 13', () {
    expect(kMinimumAccountAge, 13);
  });

  group('accepted (age 13+)', () {
    test('turns 13 exactly today', () {
      expect(allowed(DateTime(2013, 9, 30)), isTrue);
    });
    test('clearly older', () {
      expect(allowed(DateTime(1995, 1, 1)), isTrue);
    });
    test('time-of-day on the input is ignored', () {
      expect(allowed(DateTime(2013, 9, 30, 23, 59)), isTrue);
    });
  });

  group('rejected (under 13)', () {
    test('one day before the 13th birthday', () {
      expect(allowed(DateTime(2013, 10, 1)), isFalse);
    });
    test('young child', () {
      expect(allowed(DateTime(2021, 1, 1)), isFalse);
    });
    test('born today', () {
      expect(allowed(DateTime(2026, 9, 30)), isFalse);
    });
    test('future date is never allowed', () {
      expect(allowed(DateTime(2027, 1, 1)), isFalse);
    });
  });

  group('29 February convention (observed on 28 Feb in non-leap years)', () {
    final DateTime dob = DateTime(2012, 2, 29);
    test('day before the observed 13th birthday', () {
      expect(allowed(dob, DateTime(2025, 2, 27)), isFalse);
    });
    test('on the observed 13th birthday', () {
      expect(allowed(dob, DateTime(2025, 2, 28)), isTrue);
    });
  });
}
