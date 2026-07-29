// lib/widgets/feed_card.dart
// Kad komuniti diselaraskan mengikutconstants.dart baharu.

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'anim_helpers.dart';

// ── TYPE COLOR MAPPING ────────────────────────────────────────
Color _typeColor(String t) {
  switch (t) {
    case 'video':   return kTypeVideo;
    case 'article': return kTypeArticle;
    case 'event':   return kTypeEvent;
    case 'quote':   return kTypeQuote;
    default:        return kPrimaryGold;
  }
}

IconData _typeIcon(String t) {
  switch (t) {
    case 'video':   return Icons.play_arrow_rounded;
    case 'article': return Icons.article_rounded;
    case 'event':   return Icons.event_rounded;
    case 'quote':   return Icons.format_quote_rounded;
    default:        return Icons.circle;
  }
}

String _typeLabel(String t) {
  switch (t) {
    case 'video':   return 'VIDEO';
    case 'article': return 'ARTIKEL';
    case 'event':   return 'ACARA';
    case 'quote':   return 'PETIKAN';
    default:        return t.toUpperCase();
  }
}

// ── GRADIENT PALETTES (Muted & Premium Fallback) ──────────────
const List<List<Color>> _palettes = [
  [Color(0xFF2C3E50), Color(0xFF1A252F)],
  [Color(0xFF3E362E), Color(0xFF231E19)],
  [Color(0xFF1E3932), Color(0xFF0F1D19)],
  [Color(0xFF2A2833), Color(0xFF151419)],
  [Color(0xFF1A3641), Color(0xFF0D1E24)],
  [Color(0xFF382229), Color(0xFF1C1114)],
];

// ── FEED CARD ─────────────────────────────────────────────────
class FeedCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;

  const FeedCard({Key? key, required this.post, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color accent = _typeColor(post.type);
    final int   pi     = post.id.hashCode.abs() % _palettes.length;
    final bool  hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;

    return RepaintBoundary(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: kSurfaceCard,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              kCardShadow(opacity: 0.05), // Menggunakan helper kCardShadow dari constants.dart
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── THUMBNAIL ──────────────────────────────────
              AspectRatio(
                aspectRatio: 1.45,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    hasImg
                        ? Image.asset(
                            post.assetPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _gradBg(_palettes[pi], post.type),
                            frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                              if (wasSynchronouslyLoaded) return child;
                              return AnimatedSwitcher(
                                duration: AppDurations.fast,
                                child: frame == null
                                    ? const ShimmerBox(key: ValueKey('shimmer'))
                                    : KeyedSubtree(key: const ValueKey('img'), child: child),
                              );
                            },
                          )
                        : _gradBg(_palettes[pi], post.type),

                    // Badge Jenis
                    Positioned(
                      bottom: 8, left: 8,
                      child: PopScaleIn(
                        delay: const Duration(milliseconds: 180),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_typeIcon(post.type), size: 9.5, color: accent),
                              const SizedBox(width: 4),
                              Text(
                                _typeLabel(post.type),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.0,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── MAKLUMAT ───────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: kTextPrimary,
                          height: 1.4, 
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${post.author} · ${post.time}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9.5,
                                color: kTextSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          PopLikeButton(
                            baseCount: post.likes,
                            iconSize: 11.5,
                            mutedColor: kTextMuted,
                            likedColor: kTypeVideo,
                            countStyle: const TextStyle(
                                fontSize: 9.5, color: kTextMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradBg(List<Color> colors, String type) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10, bottom: -10,
              child: Icon(
                _typeIcon(type),
                size: 78,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ],
        ),
      );
}
