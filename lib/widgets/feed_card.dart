// lib/widgets/feed_card.dart  (V2)
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'anim_helpers.dart';

// ── TYPE MAPPING (kekal) ─────────────────────────────────────
Color _typeColor(String t) {
  switch (t) {
    case 'video':   return kTypeVideo;
    case 'article': return kTypeArticle;
    case 'event':   return kTypeEvent;
    default:        return kPrimaryGold;
  }
}

IconData _typeIcon(String t) {
  switch (t) {
    case 'video':   return Icons.play_arrow_rounded;
    case 'article': return Icons.article_rounded;
    case 'event':   return Icons.event_rounded;
    default:        return Icons.circle;
  }
}

String _typeLabel(String t) {
  switch (t) {
    case 'video':   return 'VIDEO';
    case 'article': return 'ARTIKEL';
    case 'event':   return 'ACARA';
    default:        return t.toUpperCase();
  }
}

// Fallback imej kosong
const List<List<Color>> _palettes = [
  [Color(0xFF2C3E50), Color(0xFF1A252F)],
  [Color(0xFF3E362E), Color(0xFF231E19)],
  [Color(0xFF1E3932), Color(0xFF0F1D19)],
  [Color(0xFF2A2833), Color(0xFF151419)],
  [Color(0xFF1A3641), Color(0xFF0D1E24)],
  [Color(0xFF382229), Color(0xFF1C1114)],
];

// ── GAYA PETIKAN — warna berani mcm skrin 1 ─────────────────
class _QuoteStyle {
  final List<Color> bg;
  final Color text;
  final Color accent;
  const _QuoteStyle(this.bg, this.text, this.accent);
}

const List<_QuoteStyle> _quoteStyles = [
  _QuoteStyle([Color(0xFFFFC53D), Color(0xFFFF9500)], Color(0xFF2B1D00), Color(0xFF2B1D00)), // kuning
  _QuoteStyle([Color(0xFF00C6D7), Color(0xFF0891B2)], Color(0xFF002E38), Color(0xFF002E38)), // teal
  _QuoteStyle([Color(0xFF8B5CF6), Color(0xFF6D28D9)], Colors.white, Color(0xFFFFD84D)),      // ungu
  _QuoteStyle([Color(0xFFFF6B6B), Color(0xFFE8433F)], Colors.white, Color(0xFFFFD6A9)),      // coral
  _QuoteStyle([Color(0xFFF9A8C9), Color(0xFFEE7FB2)], Color(0xFF40102A), Color(0xFF40102A)), // pink
  _QuoteStyle([Color(0xFF34D399), Color(0xFF059669)], Color(0xFF022A1C), Color(0xFF022A1C)), // emerald
];

_QuoteStyle _quoteStyleFor(PostModel p) =>
    _quoteStyles[p.id.hashCode.abs() % _quoteStyles.length];

// ── Avatar (kekal) ───────────────────────────────────────────
Widget _authorAvatar(String author, Color accent, {double size = 18}) {
  final String initial =
      author.trim().isNotEmpty ? author.trim()[0].toUpperCase() : '?';
  return Container(
    width: size, height: size, alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accent.withOpacity(0.18),
      border: Border.all(color: accent.withOpacity(0.4), width: 0.8),
    ),
    child: Text(initial,
      style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w800,
        color: accent, height: 1)),
  );
}

// ── Tag kaca & bookmark (kekal) ──────────────────────────────
Widget _glassTag(String type) {
  final Color accent = _typeColor(type);
  return PopScaleIn(
    delay: const Duration(milliseconds: 180),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.6),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_typeIcon(type), size: 10, color: accent),
        const SizedBox(width: 4),
        Text(_typeLabel(type),
          style: const TextStyle(color: Colors.white, fontSize: 8.5,
            fontWeight: FontWeight.w700, letterSpacing: 0.3)),
      ]),
    ),
  );
}

Widget _floatingBookmark() {
  return PopScaleIn(
    delay: const Duration(milliseconds: 220),
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.25), width: 0.6),
      ),
      child: PopBookmarkButton(
        iconSize: 13,
        mutedColor: Colors.white.withOpacity(0.9),
        savedColor: kGoldLight,
      ),
    ),
  );
}

// ── KAD UTAMA ────────────────────────────────────────────────
class FeedCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final double imageAspectRatio;

  const FeedCard({
    Key? key,
    required this.post,
    this.onTap,
    this.imageAspectRatio = 1.45,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isQuote = post.type == 'quote';
    // GLOW BERWARNA (vibe skrin 2) — ikut warna jenis / palet petikan
    final Color glow =
        isQuote ? _quoteStyleFor(post).bg[1] : _typeColor(post.type);

    return RepaintBoundary(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isQuote ? null : const Color(0xFF151A21), // panel gelap (skrin 3)
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: glow.withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: isQuote ? _buildQuoteLayout() : _buildMediaLayout(),
        ),
      ),
    );
  }

  // ── KAD MEDIA: imej atas + panel gelap (skrin 2 + 3) ───────
  Widget _buildMediaLayout() {
    final Color accent = _typeColor(post.type);
    final int pi = post.id.hashCode.abs() % _palettes.length;
    final bool hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;
    final bool isVideo = post.type == 'video';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: imageAspectRatio,
          child: Stack(
            fit: StackFit.expand,
            children: [
              hasImg
                  ? Image.asset(post.assetPath!, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _gradBg(_palettes[pi], post.type),
                      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                        if (wasSynchronouslyLoaded) return child;
                        return AnimatedSwitcher(
                          duration: AppDurations.fast,
                          child: frame == null
                              ? const ShimmerBox(key: ValueKey('shimmer'))
                              : KeyedSubtree(key: const ValueKey('img'), child: child),
                        );
                      })
                  : _gradBg(_palettes[pi], post.type),

              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0x33000000)],
                      stops: [0.7, 1.0],
                    ),
                  ),
                ),
              ),

              if (isVideo)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.45),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
                    ),
                    child: const Icon(Icons.play_arrow_rounded, size: 28, color: Colors.white),
                  ),
                ),

              Positioned(top: 10, left: 10, child: _glassTag(post.type)),
              Positioned(top: 10, right: 10, child: _floatingBookmark()),
            ],
          ),
        ),

        // Garisan aksen nipis — sentuhan vivid skrin 2
        Container(
          height: 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [accent.withOpacity(0.1), accent, accent.withOpacity(0.1)],
            ),
          ),
        ),

        // PANEL GELAP berstruktur — skrin 3
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(post.title,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800,
                  letterSpacing: -0.2, color: Colors.white, height: 1.3)),
              const SizedBox(height: 9),
              Row(children: [
                _authorAvatar(post.author, accent, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${post.author} · ${post.time}',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 9.5, color: Color(0xFF98A2B3))),
                ),
                const SizedBox(width: 4),
                PopLikeButton(
                  baseCount: post.likes, iconSize: 11.5,
                  mutedColor: const Color(0xFF8B93A1),
                  likedColor: accent,
                  countStyle: const TextStyle(fontSize: 9.5, color: Color(0xFF8B93A1)),
                ),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  // ── KAD PETIKAN: blok warna berani — skrin 1 ───────────────
  Widget _buildQuoteLayout() {
    final _QuoteStyle s = _quoteStyleFor(post);
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 13),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: s.bg,
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Bulatan hiasan — playful mcm kad promo skrin 1
          Positioned(right: -28, top: -28,
            child: Container(width: 96, height: 96,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.14)))),
          Positioned(right: 22, top: 34,
            child: Container(width: 26, height: 26,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.10)))),

          Positioned(top: 0, right: 0, child: _floatingBookmark()),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.format_quote_rounded, size: 26, color: s.accent),
              const SizedBox(height: 6),
              Text(post.content,
                maxLines: 6, overflow: TextOverflow.ellipsis,
                style: TextStyle(color: s.text, fontSize: 14,
                  fontWeight: FontWeight.w800, height: 1.38, letterSpacing: -0.15)),
              const SizedBox(height: 14),
              Row(children: [
                // Chip penulis (vibe label kad promo)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('— ${post.author}',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: s.text)),
                  ),
                ),
                const SizedBox(width: 6),
                PopLikeButton(
                  baseCount: post.likes, iconSize: 11.5,
                  mutedColor: s.text.withOpacity(0.55),
                  likedColor: s.text,
                  countStyle: TextStyle(fontSize: 9.5, color: s.text.withOpacity(0.75)),
                ),
              ]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _gradBg(List<Color> colors, String type) => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors,
        begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    child: Stack(children: [
      Positioned(right: -10, bottom: -10,
        child: Icon(_typeIcon(type), size: 78, color: Colors.white.withOpacity(0.04))),
    ]),
  );
}
