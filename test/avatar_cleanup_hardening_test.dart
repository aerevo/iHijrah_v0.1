import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('F3-E Edit Profile hanya padam avatar lama selepas cloud success path', () {
    final String src =
        File('lib/screens/edit_profile_screen.dart').readAsStringSync();

    final int submit = src.indexOf('Future<void> _submit() async');
    final int failure = src.indexOf('if (result.isFailure)', submit);
    final int successCleanup = src.indexOf(
      'F3-E: cloud save berjaya. Hanya sekarang avatar asal',
      submit,
    );
    final int oldDelete = src.indexOf('await oldFile.delete();', successCleanup);

    expect(submit, greaterThanOrEqualTo(0));
    expect(failure, greaterThan(submit));
    expect(successCleanup, greaterThan(failure));
    expect(oldDelete, greaterThan(successCleanup));

    // Jangan benarkan cleanup avatar baru berlaku dalam failure branch.
    final String failureBlock = src.substring(
      failure,
      successCleanup,
    );

    expect(failureBlock.contains('failedAvatar'), isFalse);
    expect(failureBlock.contains('await file.delete();'), isFalse);
    expect(failureBlock.contains('await oldFile.delete();'), isFalse);
  });

  test('F3-E Onboarding tidak memadam avatar apabila save gagal', () {
    final String src =
        File('lib/screens/onboarding_screen.dart').readAsStringSync();

    expect(src.contains('orphanAvatar'), isFalse);
    expect(src.contains('previousSelectedAvatar'), isFalse);

    final int saveMarker = src.indexOf('saveAndWaitForCloud()');
    expect(saveMarker, greaterThanOrEqualTo(0));

    final int catchIndex = src.indexOf('catch (e)', saveMarker);
    expect(catchIndex, greaterThan(saveMarker));

    // Pastikan catch onboarding selepas save tidak mengandungi
    // avatar file deletion.
    final int nextMethod = src.indexOf(
      '\n  @override',
      catchIndex,
    );

    final String catchBlock = src.substring(
      catchIndex,
      nextMethod == -1 ? src.length : nextMethod,
    );

    expect(catchBlock.contains('await file.delete();'), isFalse);
    expect(catchBlock.contains('orphanAvatar'), isFalse);
  });

  test('F3-E account deletion menjalankan local avatar cleanup selepas Auth delete',
      () {
    final String src =
        File('lib/models/user_model.dart').readAsStringSync();

    final int authDelete = src.indexOf('await currentUser.delete();');
    final int avatarCleanup = src.indexOf(
      'await _cleanupLocalAvatarFiles();',
      authDelete,
    );
    final int resetSession = src.indexOf(
      'await resetLocalSession();',
      avatarCleanup,
    );

    expect(authDelete, greaterThanOrEqualTo(0));
    expect(avatarCleanup, greaterThan(authDelete));
    expect(resetSession, greaterThan(avatarCleanup));
  });

  test('F3-E avatar cleanup hanya menyasar format avatar_<timestamp>.<ext>',
      () {
    final String src =
        File('lib/models/user_model.dart').readAsStringSync();

    expect(
      src.contains(r"r'^avatar_[0-9]+\.[A-Za-z0-9]+$'"),
      isTrue,
    );

    // Cleanup tidak boleh delete semua fail dalam Documents directory.
    final int helper = src.indexOf('_cleanupLocalAvatarFiles()');
    final int reset = src.indexOf('resetLocalSession()', helper);

    expect(helper, greaterThanOrEqualTo(0));
    expect(reset, greaterThan(helper));
  });
}
