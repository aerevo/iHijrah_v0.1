import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('F3-F social cleanup mesti lengkap sebelum langkah akhir', () {
    final String src =
        File('lib/models/user_model.dart').readAsStringSync();

    final int socialReport = src.indexOf(
      'lastSocialCleanupReport = socialReport;',
    );
    final int socialGate = src.indexOf(
      'if (socialReport == null || !socialReport.isClean)',
      socialReport,
    );
    final int reauth = src.indexOf(
      'await currentUser.reauthenticateWithCredential(credential);',
      socialGate,
    );

    expect(socialReport, greaterThanOrEqualTo(0));
    expect(socialGate, greaterThan(socialReport));
    expect(reauth, greaterThan(socialGate));
  });

  test('F3-F follow cleanup mesti lengkap sebelum langkah akhir', () {
    final String src =
        File('lib/models/user_model.dart').readAsStringSync();

    final int profileReport = src.indexOf(
      'lastDeletionCleanupReport = profileReport;',
    );
    final int profileGate = src.indexOf(
      'if (profileReport == null || profileReport.edgesFailed != 0)',
      profileReport,
    );
    final int reauth = src.indexOf(
      'await currentUser.reauthenticateWithCredential(credential);',
      profileGate,
    );

    expect(profileReport, greaterThanOrEqualTo(0));
    expect(profileGate, greaterThan(profileReport));
    expect(reauth, greaterThan(profileGate));
  });

  test('F3-F kedua-dua gate mesti sebelum users/Auth delete', () {
    final String src =
        File('lib/models/user_model.dart').readAsStringSync();

    final int socialGate = src.indexOf(
      'if (socialReport == null || !socialReport.isClean)',
    );
    final int profileGate = src.indexOf(
      'if (profileReport == null || profileReport.edgesFailed != 0)',
    );
    final int usersDelete = src.indexOf(
      "collection('users')",
      profileGate,
    );
    final int authDelete = src.indexOf(
      'await currentUser.delete();',
      usersDelete,
    );

    expect(socialGate, greaterThanOrEqualTo(0));
    expect(profileGate, greaterThan(socialGate));
    expect(usersDelete, greaterThan(profileGate));
    expect(authDelete, greaterThan(usersDelete));
  });
}
