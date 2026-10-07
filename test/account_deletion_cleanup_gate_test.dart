import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// F01: gate lama (urutan cleanup client sebelum users/Auth delete) sudah
// digantikan. Kontrak baharu: UserModel.deleteAccount() HANYA menghantar
// request ke backend F3-G. Ini pengawal STATIK sumber (tiada fake Firebase
// dalam projek) — ia mengesan regresi teks, BUKAN tingkah laku runtime.

String _norm(String s) =>
    s.replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r' (?=\.)'), '');

String _deleteAccountBody() {
  final String src = File('lib/models/user_model.dart').readAsStringSync();
  final int a = src.indexOf(
    'Future<void> deleteAccount({required String password}) async {',
  );
  final int b = src.indexOf('static Future<UserModel> load() async', a);
  expect(a, greaterThanOrEqualTo(0), reason: 'deleteAccount() hilang');
  expect(b, greaterThan(a), reason: 'penanda hujung deleteAccount() hilang');
  return _norm(src.substring(a, b));
}

void main() {
  test('F01 deleteAccount() tidak melakukan kerja destruktif client', () {
    final String body = _deleteAccountBody();
    const List<String> forbidden = <String>[
      'purgeMySocialContent',
      'deleteMyProfileAndEdges',
      'currentUser.delete',
      '.delete(',
      "collection('users')",
      "collection('posts')",
      "collection('profiles')",
      'WriteBatch',
      'batch',
      'SocialService',
      'ProfileService',
    ];
    for (final String token in forbidden) {
      expect(body.contains(token), isFalse, reason: 'dilarang: $token');
    }
  });

  test('F01 deleteAccount() tidak membersih/reset sesi tempatan sebagai siap',
      () {
    final String body = _deleteAccountBody();
    expect(body.contains('_cleanupLocalAvatarFiles'), isFalse);
    expect(body.contains('resetLocalSession'), isFalse);
    expect(body.contains('_clearDeletionIncompleteMarker'), isFalse);
    expect(body.contains('signOut'), isFalse);
  });

  test('F01 deleteAccount() tidak membaca request / tiada polling', () {
    final String body = _deleteAccountBody();
    expect(body.contains('.get('), isFalse);
    expect(body.contains('.snapshots('), isFalse);
    expect(body.contains('reload()'), isFalse);
    expect(body.contains('Timer'), isFalse);
    expect(body.contains('while ('), isFalse);
  });

  test('F01 tiada kod lib/ lain memanggil laluan destruktif client', () {
    final List<File> dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList();
    expect(dartFiles, isNotEmpty);
    for (final File f in dartFiles) {
      final String src = f.readAsStringSync();
      expect(src.contains('currentUser.delete()'), isFalse,
          reason: '${f.path} memanggil currentUser.delete()');
      final bool isDef = f.path.endsWith('services/social_service.dart') ||
          f.path.endsWith('services/profile_service.dart');
      if (!isDef) {
        expect(src.contains('purgeMySocialContent('), isFalse,
            reason: '${f.path} memanggil purgeMySocialContent');
        expect(src.contains('deleteMyProfileAndEdges('), isFalse,
            reason: '${f.path} memanggil deleteMyProfileAndEdges');
      }
    }
  });

  test('F01 hanya UserModel menyentuh accountDeletionRequests', () {
    final List<File> dartFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((File f) => f.path.endsWith('.dart'))
        .toList();
    final List<String> users = dartFiles
        .where((File f) =>
            f.readAsStringSync().contains('accountDeletionRequests'))
        .map((File f) => f.path)
        .toList();
    expect(users, <String>['lib/models/user_model.dart']);
  });
}
