// lib/widgets/feed_card.dart
// GLASSMORPHISM PREMIUM — dark blue-purple, cyan/amber accent, glow aktif

import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

// ── FRASA ISLAMIK ─────────────────────────────────────────────
class IslamicPhrase {
  final String arabic;
  final String latin;
  final String symbol;
  final Color color;
  final Color bg;
  const IslamicPhrase({
    required this.arabic,
    required this.latin,
    required this.symbol,
    required this.color,
    required this.bg,
  });
}

const List<IslamicPhrase> kIslamicPhrases = [
  IslamicPhrase(arabic: 'بِسْمِ اللَّهِ',     latin: 'Bismillah',     symbol: '﷽',  color: Color(0xFFFFC107), bg: Color(0x22FFC107)),
  IslamicPhrase(arabic: 'الْحَمْدُ لِلَّهِ',  latin: 'Alhamdulillah', symbol: 'ﷲ',  color: Color(0xFF26D0A0), bg: Color(0x2226D0A0)),
  IslamicPhrase(arabic: 'سُبْحَانَ اللَّهِ',  latin: 'Subhanallah',   symbol: 'سُبْ', color: Color(0xFF40C4FF), bg: Color(0x2240C4FF)),
  IslamicPhrase(arabic: 'إِنْ شَاءَ اللَّهُ', latin: 'InsyaAllah',    symbol: 'إِنْ', color: Color(0xFFCE93D8), bg: Color(0x22CE93D8)),
  IslamicPhrase(arabic: 'اللَّهُ أَكْبَرُ',   latin: 'Allahuakbar',  symbol: 'أَكْ', color: Color(0xFFFF7043), bg: Color(0x22FF7043)),
  IslamicPhrase(arabic: 'مَا شَاءَ اللَّهُ',  latin: 'MashaAllah',   symbol: 'مَا',  color: Color(0xFF80DEEA), bg: Color(0x2280DEEA)),
];

// ── WARNA TEMA ────────────────────────────────────────────────
// Kad center — kaca terang lebih
const Color _glassCenterBg   = Color(0x28FFFFFF); // putih 16% opacity
// Kad lain — lebih gelap
const Color _glassDimBg      = Color(0x14FFFFFF); // putih 8% opacity

// Border
const Color _borderCenter    = Color(0xFF40C4FF); // cyan
const Color _borderDim       = Color(0x30FFFFFF); // putih 19%

// Teks
const Color _textTitle       = Color(0xFFF0F8FF); // putih kebiruan
const Color _textTitleDim    = Color(0xFFB0C4DE); // steel blue pudar
const Color _textBody        = Color(0xFFCDD5E0); // slate cerah
const Color _textBodyDim     = Color(0xFF7A8FA6); // slate pudar
const Color _textMeta        = Color(0xFF6A85A0); // biru kelabu

// Glow
const Color _glowCyan        = Color(0xFF00B4D8);
const Color _glowAmber       = Color(0xFFFFC107);

// ── FEED CARD ─────────────────────────────────────────────────
class FeedCard extends StatefulWidget {
  final PostModel post;
  final bool isCenter;
  final VoidCallback? onTap;

  const FeedCard({
    Key? key,
    required this.post,
    this.isCenter = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  bool _liked = false;

  Color get _typeColor {
    switch (widget.post.type) {
      case 'video':  return const Color(0xFFFF7043);
      case 'quote':  return const Color(0xFFCE93D8);
      case 'event':  return const Color(0xFF26D0A0);
      default:       return const Color(0xFFFFC107);
    }
  }

  IconData get _typeIcon {
    switch (widget.post.type) {
      case 'video':  return Icons.play_arrow_rounded;
      case 'quote':  return Icons.format_quote_rounded;
      case 'event':  return Icons.event_rounded;
      default:       return Icons.article_rounded;
    }
  }

  IslamicPhrase get _phrase =>
      kIslamicPhrases[widget.post.id.hashCode % kIslamicPhrases.length];

  // Infer gender dari nama author — dalam production ganti dengan user.gender
  bool get _isFemaleAuthor {
    final String name = widget.post.author.toLowerCase();
    return name.contains('ustazah') ||
        name.contains('puan') ||
        name.contains('cik') ||
        name.contains('dr. nor') ||
        name.contains('noor') ||
        name.contains('siti') ||
        name.contains('wanita');
  }

  @override
  Widget build(BuildContext context) {
    final bool hasImage = widget.post.assetPath != null &&
        widget.post.assetPath!.isNotEmpty;
    final phrase = _phrase;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            // Glow ambient — hanya center card
            boxShadow: widget.isCenter
                ? [
                    // Cyan outer glow
                    BoxShadow(
                      color: _glowCyan.withOpacity(0.22),
                      blurRadius: 20,
                      spreadRadius: -2,
                      offset: const Offset(0, 4),
                    ),
                    // Amber bottom accent glow
                    BoxShadow(
                      color: _glowAmber.withOpacity(0.10),
                      blurRadius: 30,
                      spreadRadius: -4,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              // Blur HANYA pada center card — non-center guna solid
              filter: widget.isCenter
                  ? ImageFilter.blur(sigmaX: 12, sigmaY: 12)
                  : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  // Gradient kaca — lebih terang atas, gelap bawah
                  gradient: widget.isCenter
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.18),
                            Colors.white.withOpacity(0.06),
                            const Color(0xFF0D1B2A).withOpacity(0.40),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withOpacity(0.07),
                            Colors.white.withOpacity(0.03),
                          ],
                        ),
                  border: Border.all(
                    color: widget.isCenter
                        ? _borderCenter.withOpacity(0.55)
                        : _borderDim,
                    width: widget.isCenter ? 1.2 : 0.7,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [

                    // ─── ACCENT LINE KIRI ─────────────────
                    Container(
                      width: 3,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: widget.isCenter
                              ? [
                                  _typeColor,
                                  _typeColor.withOpacity(0.3),
                                ]
                              : [
                                  _typeColor.withOpacity(0.4),
                                  _typeColor.withOpacity(0.1),
                                ],
                        ),
                      ),
                    ),

                    // ─── KONTEN UTAMA ──────────────────────
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10, 9, 6, 9),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            // ISLAMIC PHRASE BADGE
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // ── Logo bulat khat Arab ──
                                Container(
                                  width: 30, height: 30,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: phrase.bg,
                                    border: Border.all(
                                      color: phrase.color.withOpacity(0.50),
                                      width: 1.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: phrase.color.withOpacity(0.22),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      phrase.symbol,
                                      style: TextStyle(
                                        fontSize: phrase.symbol.length > 2 ? 8 : 12,
                                        color: phrase.color,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Scheherazade', // fallback ke system Arab
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 7),

                                // ── Arabic + Username + Umur ──
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Arabic phrase
                                      Text(
                                        phrase.arabic,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          color: phrase.color,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      // Username — silver gradient
                                      ShaderMask(
                                        blendMode: BlendMode.srcIn,
                                        shaderCallback: (bounds) =>
                                            const LinearGradient(
                                          colors: [
                                            Color(0xFFE8E8E8),
                                            Color(0xFFFFFFFF),
                                            Color(0xFFB0B0B0),
                                          ],
                                          stops: [0.0, 0.5, 1.0],
                                        ).createShader(bounds),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              widget.post.author,
                                              style: const TextStyle(
                                                fontSize: 8.5,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 3),
                                            Icon(
                                              _isFemaleAuthor
                                                  ? Icons.female_rounded
                                                  : Icons.male_rounded,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Umur Hijriah — silver pudar
                                      if (widget.post.authorAge.isNotEmpty)
                                        ShaderMask(
                                          blendMode: BlendMode.srcIn,
                                          shaderCallback: (bounds) =>
                                              const LinearGradient(
                                            colors: [
                                              Color(0xFF909090),
                                              Color(0xFFBBBBBB),
                                            ],
                                          ).createShader(bounds),
                                          child: Text(
                                            '${widget.post.authorAge} thn H',
                                            style: const TextStyle(
                                              fontSize: 7.5,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                                // ── Avatar profil gender kanan ──
                                Container(
                                  width: 28, height: 28,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: _isFemaleAuthor
                                          ? [
                                              const Color(0xFFCE93D8),
                                              const Color(0xFF8E24AA),
                                            ]
                                          : [
                                              const Color(0xFF40C4FF),
                                              const Color(0xFF0288D1),
                                            ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Icon(
                                    _isFemaleAuthor
                                        ? Icons.person_rounded
                                        : Icons.person_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),

                            // TAJUK — Emas bersih
                            Text(
                              widget.post.title,
                              style: TextStyle(
                                color: const Color(0xFFFFD700),
                                fontSize: widget.isCenter ? 14 : 12.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                                height: 1.2,
                              ),
                              maxLines: widget.isCenter ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // KANDUNGAN
                            Text(
                              widget.post.content,
                              style: TextStyle(
                                color: widget.isCenter
                                    ? _textBody
                                    : _textBodyDim,
                                fontSize: widget.isCenter ? 11 : 10,
                                height: 1.4,
                                fontWeight: FontWeight.w300,
                              ),
                              maxLines: widget.isCenter ? 3 : 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // FOOTER
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 7,
                                  backgroundColor:
                                      _typeColor.withOpacity(0.18),
                                  child: Icon(_typeIcon,
                                      color: _typeColor, size: 8),
                                ),
                                const SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    '${widget.post.author} • ${widget.post.time}',
                                    style: const TextStyle(
                                      color: _textMeta,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (widget.isCenter)
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 9, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _glowCyan.withOpacity(0.12),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        border: Border.all(
                                          color:
                                              _glowCyan.withOpacity(0.45),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: Text(
                                        'Lihat',
                                        style: TextStyle(
                                          color: _glowCyan
                                              .withOpacity(0.9),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ─── GAMBAR THUMBNAIL ──────────────────
                    if (hasImage) ...[
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: SizedBox(
                            width: 70,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.asset(
                                  widget.post.assetPath!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: _typeColor.withOpacity(0.10),
                                    child: Icon(_typeIcon,
                                        color: _typeColor.withOpacity(0.5),
                                        size: 22),
                                  ),
                                ),
                                // Overlay gelap bawah gambar
                                Positioned(
                                  bottom: 0, left: 0, right: 0,
                                  height: 28,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.5),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                if (widget.post.type == 'video')
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withOpacity(0.50),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white60,
                                            width: 1),
                                      ),
                                      child: const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 14),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // ─── DIVIDER ───────────────────────────
                    const SizedBox(width: 5),
                    Container(
                        width: 0.6,
                        color: Colors.white.withOpacity(0.08)),
                    const SizedBox(width: 3),

                    // ─── ACTION BUTTONS ────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _ActionBtn(
                            icon: _liked
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            label: _formatCount(widget.post.likes),
                            color: _liked
                                ? const Color(0xFFFF5252)
                                : _textMeta,
                            onTap: () =>
                                setState(() => _liked = !_liked),
                          ),
                          _ActionBtn(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: _formatCount(
                                (widget.post.likes / 12).floor()),
                            color: _textMeta,
                          ),
                          _ActionBtn(
                            icon: Icons.share_rounded,
                            label: 'Kongsi',
                            color: _textMeta,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

// ── ACTION BUTTON ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.5,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
