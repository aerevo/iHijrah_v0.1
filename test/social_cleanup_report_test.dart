import 'package:flutter_test/flutter_test.dart';
import 'package:ihijrah_app/services/social_service.dart';

SocialCleanupReport _report({
  int likes = 0,
  int comments = 0,
  int replies = 0,
  int failed = 0,
  bool scanComplete = true,
}) =>
    SocialCleanupReport(
      postsScanned: 3,
      likesRemoved: likes,
      commentsRemoved: comments,
      repliesRemoved: replies,
      failedCount: failed,
      failedPaths: List<String>.generate(failed, (i) => 'posts/p$i'),
      scanComplete: scanComplete,
    );

void main() {
  group('SocialCleanupReport.isClean', () {
    test('clean when the scan completed and nothing failed', () {
      expect(_report(likes: 2, comments: 1, replies: 3).isClean, isTrue);
    });

    test('NOT clean when any item failed', () {
      expect(_report(likes: 2, failed: 1).isClean, isFalse);
    });

    test('NOT clean when the scan stopped early (limit / budget / read error)',
        () {
      expect(_report(scanComplete: false).isClean, isFalse);
    });

    test('NOT clean when both happen', () {
      expect(_report(failed: 2, scanComplete: false).isClean, isFalse);
    });
  });

  group('SocialCleanupReport.itemsRemoved', () {
    test('sums likes, comments and replies', () {
      expect(_report(likes: 2, comments: 3, replies: 4).itemsRemoved, 9);
    });

    test('is zero when nothing was removed', () {
      expect(_report().itemsRemoved, 0);
    });
  });
}
