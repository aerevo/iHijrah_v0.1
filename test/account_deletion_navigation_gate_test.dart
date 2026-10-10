import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  String read(String path) => File(path).readAsStringSync();

  test('Splash reconciles an outstanding marker before normal navigation', () {
    final String source = read('lib/screens/splash_screen.dart');
    expect(source, contains('user.hasOutstandingDeletionMarker'));
    expect(source, contains('user.reconcileAccountDeletion()'));
    expect(source, contains('AccountDeletionRecoveryScreen('));
    expect(source, contains('deletionGateAction('));
  });

  test('Login reconciles deletion before pulling cloud profile', () {
    final String source = read('lib/screens/auth_screen.dart');
    expect(source, contains('user.reconcileAccountDeletion()'));
    expect(source, contains('AccountDeletionRecoveryScreen('));
    expect(
      source.indexOf('reconcileAccountDeletion()'),
      lessThan(source.indexOf('await user.pullFromCloud();')),
    );
  });

  test('Email verification reconciles before onboarding or Home', () {
    final String source = read('lib/screens/email_verification_screen.dart');
    expect(source, contains('userModel.reconcileAccountDeletion()'));
    expect(source, contains('AccountDeletionRecoveryScreen('));
    expect(
      source.indexOf('reconcileAccountDeletion()'),
      lessThan(source.indexOf('final bool needsOnboarding')),
    );
  });

  test('Recovery screen retries without deleting its own marker', () {
    final String source =
        read('lib/screens/account_deletion_recovery_screen.dart');
    expect(source, contains('model.reconcileAccountDeletion()'));
    expect(source, contains('.signOutAndReset()'));
    expect(source, contains('Akaun kekal dibekukan'));
    expect(source, isNot(contains('_clearDeletionIncompleteMarker')));
    expect(source, isNot(contains('deleteAccount(')));
  });
}
