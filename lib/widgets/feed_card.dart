// lib/widgets/feed_card.dart

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
  const IslamicPhrase({required this.arabic, required this.latin, required this.symbol, required this.color, required this.bg});
}

const List<IslamicPhrase> kIslamicPhrases = [
  IslamicPhrase(arabic: 'بِسْمِ اللَّهِ',     latin: 'Bismillah',     symbol: '﷽', color: Color(0xFFC9A84C), bg: Color(0x22C9A84C)),
  IslamicPhrase(arabic: 'الْحَمْدُ لِلَّهِ',  latin: 'Alhamdulillah', symbol: '☘', color: Color(0xFF43A047), bg: Color(0x2243A047)),
  IslamicPhrase(arabic: 'سُبْحَانَ اللَّهِ',  latin: 'Subhanallah',   symbol: '✦', color: Color(0xFF1E88E5), bg: Color(0x221E88E5)),
  IslamicPhrase(arabic: 'إِنْ شَاءَ اللَّهُ', latin: 'InsyaAllah',    symbol: '◈', color: Color(0xFF8E24AA), bg: Color(0x228E24AA)),
  IslamicPhrase(arabic: 'اللَّهُ أَكْبَرُ',   latin: 'Allahuakbar',  symbol: '☪', color: Color(0xFFE53935), bg: Color(0x22E53935)),
  IslamicPhrase(arabic: 'مَا شَاءَ اللَّهُ',  latin: 'MashaAllah',   symbol: '❋', color: Color(0xFF00897B), bg: Color(0x2200897B)),
];

// ── FEED CARD ─────────────────────────────────────────────────
class FeedCard extends StatefulWidget {
  final PostModel post;
  final bool isCenter;
  final VoidCallback? onTap;

  const FeedCard({Key? key, required this.post, this.isCenter = false, this.onTap}) : super(key: key);

  @override
  State<FeedCard> createState() => _FeedCardState();
}

class _FeedCardState extends State<FeedCard> {
  bool _liked = false;

  IslamicPhrase get _phrase => kIslamicPhrases[widget.post.id.hashCode % kIslamicPhrases.length];

  Color get _typeColor {
    switch (widget.post.type) {
      case 'video':  return const Color(0xFFE53935);
      case 'quote':  return const Color(0xFF8E24AA);
      case 'event':  return const Color(0xFF43A047);
      default:       return kPrimaryGold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasMedia = widget.post.assetPath != null && widget.post.assetPath!.isNotEmpty;
    final bool isQuote  = widget.post.type == 'quote';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          // Floating — tiada border langsung, hanya shadow berlapis
          boxShadow: widget.isCenter
              ? [
                  BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 6)),
                  BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 50, spreadRadius: 2, offset: const Offset(0, 18)),
                  BoxShadow(color: kPrimaryGold.withOpacity(0.08), blurRadius: 40, offset: const Offset(0, 10)),
                ]
              : [
                  BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 5)),
                  BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 30, offset: const Offset(0, 10)),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.02)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHighlightStrip(),
                  _buildPhraseBadge(),
                  if (hasMedia) _buildMedia(),
                  if (isQuote) _buildQuoteBody() else _buildHeading(),
                  if (!isQuote) _buildSnippet(),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Top highlight strip — simulate glass lighting ──────────
  Widget _buildHighlightStrip() {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.white.withOpacity(0.4), kPrimaryGold.withOpacity(0.3), Colors.transparent],
          stops: const [0.0, 0.35, 0.65, 1.0],
        ),
      ),
    );
  }

  // ── 1. Islamic Phrase Badge ────────────────────────────────
  Widget _buildPhraseBadge() {
    final p = _phrase;
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 12, 7),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, color: p.bg),
            child: Center(child: Text(p.symbol, style: TextStyle(fontSize: 13, color: p.color, fontWeight: FontWeight.w900))),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(p.arabic, style: TextStyle(fontSize: 12, color: p.color, fontWeight: FontWeight.w700)),
              Text(p.latin,  style: TextStyle(fontSize: 9,  color: Colors.white.withOpacity(0.4))),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('١٠ رمضان ١٤٤٦', style: TextStyle(fontSize: 10, color: kPrimaryGold.withOpacity(0.65))),
              Text('10 Ramadan 1446H', style: TextStyle(fontSize: 8, color: kPrimaryGold.withOpacity(0.38), letterSpacing: 0.3)),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. Media ──────────────────────────────────────────────
  Widget _buildMedia() {
    return SizedBox(
      width: double.infinity,
      height: 108,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            widget.post.assetPath!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_typeColor.withOpacity(0.25), Colors.black.withOpacity(0.6)],
                ),
              ),
              child: Text(widget.post.type == 'video' ? '🎬' : '📖', style: const TextStyle(fontSize: 36)),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 8, left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: _typeColor.withOpacity(0.88), borderRadius: BorderRadius.circular(5)),
              child: Text(widget.post.type.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.8)),
            ),
          ),
          if (widget.post.type == 'video')
            Center(
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.55), width: 1.5),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  // ── 3a. Heading (non-quote) ───────────────────────────────
  Widget _buildHeading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 10,
                backgroundColor: _typeColor.withOpacity(0.22),
                child: Text(
                  widget.post.author.isNotEmpty ? widget.post.author[0] : '?',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: _typeColor),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(widget.post.author, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withOpacity(0.6)), maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
              Text(widget.post.time, style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.28))),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.post.title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: kPrimaryGold, fontFamily: 'Playfair', letterSpacing: -0.3, height: 1.25),
            maxLines: 2, overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── 3b. Quote Body ────────────────────────────────────────
  Widget _buildQuoteBody() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('\u201C', style: TextStyle(fontSize: 40, height: 0.85, color: const Color(0xFF8E24AA).withOpacity(0.45), fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(widget.post.content, style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.88), height: 1.65, letterSpacing: 0.15), maxLines: 4, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 6),
          Text('— ${widget.post.author}', style: TextStyle(fontSize: 10, color: kPrimaryGold.withOpacity(0.7), fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ── 4. Snippet ────────────────────────────────────────────
  Widget _buildSnippet() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Text(widget.post.content, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.45), height: 1.55, fontWeight: FontWeight.w300), maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }

  // ── 5. Footer — Baca Lanjut + Actions (dalam kad) ─────────
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 10, 11),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.white.withOpacity(0.04)))),
      child: Row(
        children: [
          // Baca Lanjut
          Row(
            children: [
              Text(
                'BACA LANJUT',
                style: TextStyle(
                  fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.2,
                  color: widget.isCenter ? kPrimaryGold : kPrimaryGold.withOpacity(0.4),
                ),
              ),
              Icon(Icons.chevron_right, size: 12, color: widget.isCenter ? kPrimaryGold : kPrimaryGold.withOpacity(0.4)),
            ],
          ),
          const Spacer(),
          // Action buttons — transparent, dalam kad
          Row(
            children: [
              _ActionBtn(
                icon: _liked ? Icons.favorite : Icons.favorite_border,
                label: '${widget.post.likes}',
                color: _liked ? kWarningRed : Colors.white.withOpacity(0.28),
                onTap: () => setState(() => _liked = !_liked),
              ),
              const SizedBox(width: 16),
              _ActionBtn(icon: Icons.chat_bubble_outline, label: '${(widget.post.likes / 12).floor()}', color: Colors.white.withOpacity(0.28)),
              const SizedBox(width: 16),
              _ActionBtn(icon: Icons.reply, label: 'Kongsi', color: Colors.white.withOpacity(0.28)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── ACTION BUTTON ─────────────────────────────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionBtn({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
