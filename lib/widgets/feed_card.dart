// lib/widgets/feed_card.dart
// Kad komuniti — sistem 3 GAYA ikut jenis kandungan (bukan satu template
// seragam untuk semua lagi):
//   - HERO   (video)          — imej besar, tajuk ATAS gambar + scrim
//                                gradient, gaya sinematik (Spotify/Apple
//                                News), bukan panel putih di bawah gambar.
//   - STANDARD (artikel/acara) — imej + panel maklumat di bawah, aksen
//                                warna ikut kategori (bukan semua sama).
//   - QUOTE  (petikan)         — tiada gambar langsung. Latar emas-gelap
//                                konsisten (bukan warna random per-post),
//                                pattern geometri halus, tipografi jadi
//                                hero (bukan kotak kosong).

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'anim_helpers.dart';

// ── TYPE COLOR MAPPING ────────────────────────────────────────
// Warna sendiri kini datang dari constants.dart (dipetakan ikut jenama:
// video=emerald, artikel=emas, acara=navy, petikan=emas gelap).
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

// ── GRADIENT PALETTES (fallback bila tiada gambar — video/artikel/acara) ──
const List<List<Color>> _palettes = [
  [Color(0xFF2C3E50), Color(0xFF1A252F)],
  [Color(0xFF3E362E), Color(0xFF231E19)],
  [Color(0xFF1E3932), Color(0xFF0F1D19)],
  [Color(0xFF2A2833), Color(0xFF151419)],
  [Color(0xFF1A3641), Color(0xFF0D1E24)],
  [Color(0xFF382229), Color(0xFF1C1114)],
];

// Pool warna kad PETIKAN — jewel-tone gelap TERKURASI (bukan pelangi
// rawak). Tiap pasang berakar pada hue jenama sedia ada (emerald=amalan,
// navy=acara, emas=hikmah asal, teal=ilmu, gangsa=sirah, maroon=sejarah/
// pengorbanan) supaya variasi kekal terasa "iHijrah", bukan warna templat
// generik. Dipilih DETERMINISTIC ikut hash id post — idiom sama macam
// _palettes/pi kad media — supaya kad yang sama sentiasa dapat warna
// sama tiap kali dibina semula/scroll balik (bukan random tiap rebuild).
// Ikon petik & nama author kekal kGoldLight merentasi SEMUA warna ni —
// benang emas itu yang jadi penanda jenama, bukan warna latar sendiri.
const List<List<Color>> _quotePalettes = [
  [Color(0xFF241C0C), Color(0xFF120D05)], // emas gelap — hikmah (asal)
  [Color(0xFF163A2E), Color(0xFF0A1D17)], // emerald gelap — amalan
  [Color(0xFF17253F), Color(0xFF0B1220)], // navy-indigo — malam/tahajjud
  [Color(0xFF3A1620), Color(0xFF1D0A10)], // maroon — sirah/pengorbanan
  [Color(0xFF3E2A1C), Color(0xFF1F150E)], // gangsa-terracotta — sejarah
  [Color(0xFF123A3E), Color(0xFF091E20)], // teal gelap — ilmu/dhuha
];

List<Color> _quoteGradientFor(PostModel post) =>
    _quotePalettes[post.id.hashCode.abs() % _quotePalettes.length];

// ── Avatar bulat kecil (huruf pertama nama) — asset-free, konsisten
// dengan cara avatar profil sendiri dilayan di sidebar ──
Widget _authorAvatar(String author, Color accent, {double size = 18}) {
  final String initial =
      author.trim().isNotEmpty ? author.trim()[0].toUpperCase() : '?';
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: accent.withOpacity(0.18),
      border: Border.all(color: accent.withOpacity(0.4), width: 0.8),
    ),
    child: Text(
      initial,
      style: TextStyle(
        fontSize: size * 0.42,
        fontWeight: FontWeight.w800,
        color: accent,
        height: 1,
      ),
    ),
  );
}

// ── Tag jenis — kapsul kaca (bukan lagi badge segi-empat tampal) ──
Widget _glassTag(String type, {bool dark = true}) {
  final Color accent = _typeColor(type);
  return PopScaleIn(
    delay: const Duration(milliseconds: 180),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? Colors.black.withOpacity(0.38) : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark ? Colors.white.withOpacity(0.22) : accent.withOpacity(0.3),
          width: 0.6,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_typeIcon(type), size: 10, color: accent),
          const SizedBox(width: 4),
          Text(
            _typeLabel(type),
            style: TextStyle(
              color: dark ? Colors.white : kTextPrimary,
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    ),
  );
}

// ── Ikon simpan (bookmark) terapung — sudut kad, kaca gelap konsisten
// dengan _glassTag. Guna atas SEMUA jenis kad (video/artikel/acara atas
// gambar, petikan atas gradient) sebab latar kad kita sentiasa gelap di
// titik ni, jadi satu gaya kaca sudah cukup kontras merata-rata. ──
Widget _floatingBookmark() {
  return PopScaleIn(
    delay: const Duration(milliseconds: 220),
    child: Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.38),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 0.6),
      ),
      child: PopBookmarkButton(
        iconSize: 13,
        mutedColor: Colors.white.withOpacity(0.9),
        savedColor: kGoldLight,
      ),
    ),
  );
}

// ── Pattern geometri halus — lattice diamond, generik/abstrak (bukan
// simbol/kaligrafi tertentu), sekadar isyarat "geometri Islamik" tanpa
// cuba tiru corak sebenar. Opacity amat rendah, dilukis sekali sahaja. ──
class _GeoLatticePainter extends CustomPainter {
  final Color color;
  const _GeoLatticePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    const double spacing = 25;
    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        final Path path = Path()
          ..moveTo(x, y - spacing / 2)
          ..lineTo(x + spacing / 2, y)
          ..lineTo(x, y + spacing / 2)
          ..lineTo(x - spacing / 2, y)
          ..close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GeoLatticePainter oldDelegate) => false;
}

// ── FEED CARD ─────────────────────────────────────────────────
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
    final bool isArticle = post.type == 'article';

    return RepaintBoundary(
      child: PressableScale(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: kFeedCardSurface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: kFeedCardShadows(),
            // Artikel: bingkai emas nipis — satu2nya jenis yg dapat
            // rawatan "border", supaya tak jadi corak berulang membosankan
            border: isArticle
                ? Border.all(color: kTypeArticle.withOpacity(0.35), width: 1)
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: post.type == 'quote'
              ? _buildQuoteLayout()
              : (post.type == 'video'
                  ? _buildHeroLayout()
                  : _buildStandardLayout()),
        ),
      ),
    );
  }

  // ── LAYOUT: PETIKAN (QUOTE — dinaik taraf) ──────────────────
  Widget _buildQuoteLayout() {
    // Dinamik ikut post (hash-deterministic) — BUKAN const lagi, sbb
    // warna kini bergantung pada post.id. Jangan bungkus BoxDecoration/
    // LinearGradient dgn `const` di sini (punca ralat "const legality"
    // yg pernah jadi sebelum ni bila tukar dr nilai tetap ke nilai
    // runtime — rujuk nota pengalaman lalu).
    final List<Color> quoteColors = _quoteGradientFor(post);
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: quoteColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _GeoLatticePainter(color: Colors.white.withOpacity(0.035)),
            ),
          ),
          Positioned(top: 4, right: 4, child: _floatingBookmark()),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              PopScaleIn(
                delay: const Duration(milliseconds: 140),
                child: Icon(Icons.format_quote_rounded, size: 28, color: kGoldLight),
              ),
              const SizedBox(height: 10),
              // Tipografi JADI hero — lebih besar/tebal drpd sebelum ni
              Text(
                post.content,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                  height: 1.42,
                  letterSpacing: -0.15,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '— ${post.author}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: kGoldLight,
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
        ],
      ),
    );
  }

  // ── LAYOUT: HERO (VIDEO — sinematik, tajuk atas gambar) ─────
  Widget _buildHeroLayout() {
    final int  pi     = post.id.hashCode.abs() % _palettes.length;
    final bool hasImg = post.assetPath != null && post.assetPath!.isNotEmpty;

    return AspectRatio(
      // Sedikit lebih "tegak" drpd standard — kesan poster/sinematik
      aspectRatio: imageAspectRatio * 0.84,
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

          // Scrim gradient bawah — supaya teks putih atas gambar sentiasa
          // terbaca tak kira seterang/segelap mana gambar asal
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE6000000)],
                  stops: [0.35, 1.0],
                ),
              ),
            ),
          ),

          // Glyph main tengah — isyarat "video" tanpa perlu teks
          Center(
            child: Icon(Icons.play_circle_fill_rounded,
                size: 42, color: Colors.white.withOpacity(0.92)),
          ),

          Positioned(top: 10, left: 10, child: _glassTag(post.type)),
          Positioned(top: 10, right: 10, child: _floatingBookmark()),

          Positioned(
            left: 13, right: 13, bottom: 11,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    _authorAvatar(post.author, Colors.white),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${post.author} · ${post.time}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    PopLikeButton(
                      baseCount: post.likes,
                      iconSize: 11.5,
                      mutedColor: Colors.white.withOpacity(0.8),
                      likedColor: kTypeVideo,
                      countStyle: TextStyle(fontSize: 9.5, color: Colors.white.withOpacity(0.85)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── LAYOUT: STANDARD (ARTIKEL / ACARA) ──────────────────────
  Widget _buildStandardLayout() {
    final Color accent   = _typeColor(post.type);
    final int   pi       = post.id.hashCode.abs() % _palettes.length;
    final bool  hasImg   = post.assetPath != null && post.assetPath!.isNotEmpty;
    final bool  isEvent  = post.type == 'event';

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

              // Vignette halus bawah gambar — kesan lebih premium drpd
              // petak gambar rata, walau tajuk masih di panel bawah (bukan
              // atas gambar) utk jenis Standard ni
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0x33000000)],
                      stops: [0.7, 1.0],
                    ),
                  ),
                ),
              ),

              Positioned(bottom: 8, left: 8, child: _glassTag(post.type)),
              Positioned(top: 8, right: 8, child: _floatingBookmark()),
            ],
          ),
        ),

        // ── MAKLUMAT ───────────────────────────────────
        Padding(
          padding: EdgeInsets.fromLTRB(isEvent ? 0 : 14, 12, 14, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Acara: jalur aksen navy di kiri panel — beza drpd rawatan
              // border artikel, supaya tak jadi corak berulang
              if (isEvent) ...[
                Container(width: 3, height: 52, color: kTypeEvent.withOpacity(0.55)),
                const SizedBox(width: 11),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        color: kTextPrimary,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _authorAvatar(post.author, accent, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${post.author} · ${post.time}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: kTextSecondary),
                          ),
                        ),
                        const SizedBox(width: 6),
                        PopLikeButton(
                          baseCount: post.likes,
                          iconSize: 11.5,
                          mutedColor: kTextMuted,
                          likedColor: kTypeVideo,
                          countStyle: const TextStyle(fontSize: 9.5, color: kTextMuted),
                        ),
                      ],
                    ),
                  ],
                ),
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
