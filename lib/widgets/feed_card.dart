// lib/widgets/feed_card.dart
// Kad grid bersih — gaya FB (kad putih, bayang lembut), saiz kompak untuk
// susunan 2-lajur ala CapCut. Ketik kad untuk buka butiran penuh (masa depan).

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

// ── TYPE ──────────────────────────────────────────────────────
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

// ── GRADIENT PALETTES (fallback bila tiada imej) ──────────────
const List<List<Color>> _palettes = [
  [Color(0xFF1B2A5E), Color(0xFF3D5FC4)],  // biru
  [Color(0xFF7A3B12), Color(0xFFC97A2E)],  // jingga
  [Color(0xFF0B5C3E), Color(0xFF229464)],  // hijau
  [Color(0xFF4A2470), Color(0xFF7D52B8)],  // ungu
  [Color(0xFF0D5468), Color(0xFF1E8FA8)],  // teal
  [Color(0xFF7A1F42), Color(0xFFC24A72)],  // magenta
];

String _fmtCount(int n) =>
    n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

// ── FEED CARD (kompak, untuk grid) ────────────────────────────
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
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: kSurfaceCard,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── THUMBNAIL ──────────────────────────────────
              AspectRatio(
                aspectRatio: 1.35,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    hasImg
                        ? Image.asset(
                            post.assetPath!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _gradBg(_palettes[pi], post.type),
                          )
                        : _gradBg(_palettes[pi], post.type),

                    // Badge jenis — kiri atas
                    Positioned(
                      top: 8, left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.34),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_typeIcon(post.type),
                                size: 10, color: accent),
                            const SizedBox(width: 3),
                            Text(
                              _typeLabel(post.type),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 7.8,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── MAKLUMAT ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                        height: 1.28,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${post.author} · ${post.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 9.3,
                              color: kTextSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.favorite_rounded,
                            size: 10.5, color: kTextMuted),
                        const SizedBox(width: 2),
                        Text(
                          _fmtCount(post.likes),
                          style: const TextStyle(
                              fontSize: 9.3, color: kTextMuted),
                        ),
                      ],
                    ),
                  ],
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
              right: -14, bottom: -14,
              child: Icon(
                _typeIcon(type),
                size: 84,
                color: Colors.white.withOpacity(0.14),
              ),
            ),
          ],
        ),
      );
}
