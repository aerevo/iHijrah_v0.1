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
// Nota reka bentuk: kad ini kini SAIZ SENDIRI ikut kandungan (tiada lagi
// `Expanded` yang perlukan tinggi tetap dari ibu bapa). Ini sengaja —
// supaya boleh diletak dalam grid masonry (TwoColumnMasonry) yang bagi
// setiap kad tinggi berbeza ikut kandungan sebenar, bukan kotak seragam.
class FeedCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;

  /// Nisbah aspek gambar thumbnail. Berbeza ikut kad (ditetapkan oleh
  /// FeedPanel) supaya grid nampak organik, bukan gred seragam sebaris.
  final double imageAspectRatio;

  const FeedCard({
    Key? key,
    required this.post,
    this.onTap,
    this.imageAspectRatio = 1.45,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          child: post.type == 'quote' ? _buildQuoteLayout() : _buildMediaLayout(),
        ),
      ),
    );
  }

  // ── LAYOUT: PETIKAN ─────────────────────────────────────────
  // Tiada blok gambar langsung — kad teks tulen, tinggi ikut panjang
  // petikan sebenar. Ini yang paling banyak sumbang kepada rupa
  // masonry organik (berbanding kad bergambar yang lebih seragam).
  Widget _buildQuoteLayout() {
    final int pi = post.id.hashCode.abs() % _palettes.length;
    final Color accent = _typeColor(post.type);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _palettes[pi],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          PopScaleIn(
            delay: const Duration(milliseconds: 140),
            child: Icon(Icons.format_quote_rounded, size: 26, color: accent),
          ),
          const SizedBox(height: 8),
          Text(
            post.content,
            maxLines: 6,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              height: 1.42,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  '— ${post.author}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              PopLikeButton(
                baseCount: post.likes,
                iconSize: 11.5,
                mutedColor: Colors.white.withOpacity(0.55),
                likedColor: kTypeVideo,
                countStyle: TextStyle(fontSize: 9.5, color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── LAYOUT: VIDEO / ARTIKEL / ACARA ─────────────────────────
  Widget _buildMediaLayout() {
    final Color accent = _typeColor(post.type);
    final int   pi     = post.id.hashCode.abs() % _palettes.length;
    final bool  hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        // ── THUMBNAIL ──────────────────────────────────
        AspectRatio(
          aspectRatio: imageAspectRatio,
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
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              const SizedBox(height: 8),
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
      ],
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
