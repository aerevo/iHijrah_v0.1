// test/post_create_contract_test.dart
// Kontrak payload create post (CreatePostScreen) vs firestore.rules.
// Ujian statik (gaya sama dgn deletion_network_hardening_test.dart):
// gagal jika payload klien dan rules terpisah, atau jika laluan tulis
// kaunter post muncul di luar tempat yang dibenarkan.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String path) => File(path).readAsStringSync();

String _norm(String s) => s.replaceAll(RegExp(r'\s+'), ' ');

Set<String> _quoted(String s) =>
    RegExp(r"'(\w+)'").allMatches(s).map((m) => m.group(1)!).toSet();

void main() {
  final String rules = _read('firestore.rules');
  final String screen = _read('lib/screens/create_post_screen.dart');

  // Blok `allow create:` untuk match /posts/{postId} (hingga `allow update:`).
  final int blockStart = rules.indexOf('match /posts/{postId} {');
  final int createStart = rules.indexOf('allow create:', blockStart);
  final int updateStart = rules.indexOf('allow update:', createStart);
  final String createRule = rules.substring(createStart, updateStart);
  final String createRuleN = _norm(createRule);

  // Payload `.add({ ... })` dalam CreatePostScreen.
  final int addStart = screen.indexOf("collection('posts').add({");
  final int addEnd = screen.indexOf('});', addStart);
  final String payload = screen.substring(addStart, addEnd);
  final String payloadN = _norm(payload);

  group('CreatePostScreen payload vs firestore.rules (posts create)', () {
    test('rules block and payload were located', () {
      expect(blockStart, greaterThanOrEqualTo(0));
      expect(createStart, greaterThan(blockStart));
      expect(updateStart, greaterThan(createStart));
      expect(addStart, greaterThanOrEqualTo(0));
      expect(addEnd, greaterThan(addStart));
    });

    test('payload keys are EXACTLY the keys rules allow (hasOnly)', () {
      final Match? m =
          RegExp(r'hasOnly\(\[(.*?)\]\)', dotAll: true).firstMatch(createRule);
      expect(m, isNotNull, reason: 'hasOnly([...]) tidak ditemui dalam rules');
      final Set<String> ruleKeys = _quoted(m!.group(1)!);

      final Set<String> payloadKeys = RegExp(r"^\s*'(\w+)'\s*:", multiLine: true)
          .allMatches(payload)
          .map((x) => x.group(1)!)
          .toSet();

      expect(payloadKeys, ruleKeys);
      // Medan keselamatan/agregat tak boleh hilang daripada payload.
      for (final String k in <String>[
        'authorId', 'author', 'likes', 'commentsCount', 'createdAt',
      ]) {
        expect(payloadKeys.contains(k), isTrue, reason: '$k hilang');
      }
    });

    test('counters start at 0, createdAt is server time, owner is auth uid', () {
      expect(payloadN.contains("'likes': 0,"), isTrue);
      expect(payloadN.contains("'commentsCount': 0,"), isTrue);
      expect(payloadN.contains("'createdAt': FieldValue.serverTimestamp(),"),
          isTrue);
      expect(payloadN.contains("'authorId': uid,"), isTrue);
      expect(
          screen.contains('FirebaseAuth.instance.currentUser?.uid'), isTrue);
      // Rules menuntut nilai sepadan.
      expect(createRuleN.contains('request.resource.data.likes == 0'), isTrue);
      expect(createRuleN.contains('request.resource.data.commentsCount == 0'),
          isTrue);
      expect(createRuleN.contains('createdAt == request.time'), isTrue);
      expect(createRuleN.contains('authorId == request.auth.uid'), isTrue);
    });

    test('post types offered by the UI are all accepted by rules', () {
      final Match? m =
          RegExp(r'type in \[(.*?)\]', dotAll: true).firstMatch(createRule);
      expect(m, isNotNull);
      final Set<String> ruleTypes = _quoted(m!.group(1)!);

      final Set<String> uiTypes = RegExp(r"_typeChip\('(\w+)'")
          .allMatches(screen)
          .map((x) => x.group(1)!)
          .toSet();
      final Match? def =
          RegExp(r"String _postType = '(\w+)'").firstMatch(screen);
      expect(def, isNotNull);
      uiTypes.add(def!.group(1)!);

      expect(uiTypes, isNotEmpty);
      expect(ruleTypes.containsAll(uiTypes), isTrue,
          reason: 'UI tawarkan jenis yg rules tolak: ${uiTypes.difference(ruleTypes)}');
    });

    test('UI length limits match rules (title 80, content 10..1000)', () {
      expect(createRuleN.contains('title.size() <= 80'), isTrue);
      expect(screen.contains('maxLength: 80'), isTrue);

      expect(createRuleN.contains('content.size() >= 10'), isTrue);
      expect(createRuleN.contains('content.size() <= 1000'), isTrue);
      expect(screen.contains('_contentMin = 10'), isTrue);
      expect(screen.contains('_contentMax = 1000'), isTrue);
    });

    test('submit is guarded against re-entry BEFORE the write', () {
      final int guard = screen.indexOf('if (_posting) return;');
      expect(guard, greaterThanOrEqualTo(0));
      expect(guard, lessThan(addStart));
    });

    test('a failed publish is logged, not silently swallowed', () {
      final int catchAt = screen.indexOf('} catch (e) {', addStart);
      expect(catchAt, greaterThan(addStart));
      expect(screen.indexOf('debugPrint(', catchAt), greaterThan(catchAt));
    });
  });

  group('post aggregate counters are not written by arbitrary client code', () {
    test("only CreatePostScreen writes a 'commentsCount' key (initial 0)", () {
      final List<String> writers = <String>[];
      for (final FileSystemEntity e
          in Directory('lib').listSync(recursive: true)) {
        if (e is! File || !e.path.endsWith('.dart')) continue;
        if (RegExp(r"'commentsCount'\s*:").hasMatch(e.readAsStringSync())) {
          writers.add(e.path.replaceAll('\\', '/'));
        }
      }
      expect(writers, <String>['lib/screens/create_post_screen.dart']);
    });

    test("'likes' is only written via SocialService.setLiked (transaction)", () {
      final List<String> writers = <String>[];
      for (final FileSystemEntity e
          in Directory('lib').listSync(recursive: true)) {
        if (e is! File || !e.path.endsWith('.dart')) continue;
        if (RegExp(r"'likes'\s*:").hasMatch(e.readAsStringSync())) {
          writers.add(e.path.replaceAll('\\', '/'));
        }
      }
      writers.sort();
      expect(writers, <String>[
        'lib/screens/create_post_screen.dart',
        'lib/services/social_service.dart',
      ]);
      final String svc = _read('lib/services/social_service.dart');
      expect(svc.contains('runTransaction'), isTrue);
    });
  });
}
