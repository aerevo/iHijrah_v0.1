// lib/widgets/feed_card.dart
// Full-width Glassmorphic card — direka untuk ListWheelScrollView

import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FeedCard extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onTap;

  const FeedCard({
    Key? key,
    required this.post,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasImage = post.assetPath != null && post.assetPath!.isNotEmpty;
    final Color typeColor = _typeColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Margin kiri-kanan untuk nampak efek 3D wheel di tepi
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          // Shadow berwarna ikut jenis post
          boxShadow: [
            BoxShadow(
              color: typeColor.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                // Glassmorphism base
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── 1. AUTHOR HEADER (Facebook style) ──────────────
                  _buildHeader(typeColor),

                  // ── 2. TITLE & CONTENT ─────────────────────────────
                  _buildBody(),

                  // ── 3. MEDIA (jika ada) ────────────────────────────
                  if (hasImage) _buildMedia(),

                  // ── 4. FOOTER — Likes & Reactions ──────────────────
                  _buildFooter(typeColor),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── HEADER ────────────────────────────────────────────────
  Widget _buildHeader(Color typeColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [typeColor, typeColor.withOpacity(0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white24, width: 1.5),
            ),
            child: Center(
              child: Text(
                post.author.isNotEmpty ? post.author[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Nama + masa
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.author,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (post.authorAge.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: kPrimaryGold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: kPrimaryGold.withOpacity(0.4)),
                        ),
                        child: Text(
                          '${post.authorAge} H',
                          style: const TextStyle(color: kPrimaryGold, fontSize: 9, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      post.time,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.public, color: Colors.white.withOpacity(0.4), size: 11),
                  ],
                ),
              ],
            ),
          ),

          // Type badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.85),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              post.type.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  // ─── BODY ──────────────────────────────────────────────────
  Widget _buildBody() {
    final bool isQuote = post.type == 'quote';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: isQuote
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u201C',
                  style: TextStyle(
                    fontSize: 48,
                    height: 0.8,
                    color: kPrimaryGold.withOpacity(0.6),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  post.content,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  post.content,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.75),
                    fontSize: 13,
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
    );
  }

  // ─── MEDIA ─────────────────────────────────────────────────
  Widget _buildMedia() {
    return Stack(
      children: [
        ClipRRect(
          child: Image.asset(
            post.assetPath!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 200,
              color: Colors.white.withOpacity(0.05),
              child: Center(
                child: Icon(Icons.image_not_supported, color: Colors.white.withOpacity(0.2), size: 40),
              ),
            ),
          ),
        ),
        if (post.type == 'video')
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white54, width: 2),
                ),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
              ),
            ),
          ),
      ],
    );
  }

  // ─── FOOTER ────────────────────────────────────────────────
  Widget _buildFooter(Color typeColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        children: [
          // Likes
          _footerAction(Icons.favorite_rounded, '${post.likes}', kWarningRed),
          const SizedBox(width: 20),
          // Comment
          _footerAction(Icons.chat_bubble_outline_rounded, 'Komen', Colors.white54),
          const SizedBox(width: 20),
          // Share
          _footerAction(Icons.share_outlined, 'Kongsi', Colors.white54),
          const Spacer(),
          // Bookmark
          Icon(Icons.bookmark_border_rounded, color: typeColor.withOpacity(0.7), size: 18),
        ],
      ),
    );
  }

  Widget _footerAction(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  // ─── HELPER ────────────────────────────────────────────────
  Color _typeColor() {
    switch (post.type) {
      case 'video':   return const Color(0xFFC62828);
      case 'quote':   return const Color(0xFF6A1B9A);
      case 'event':   return const Color(0xFF2E7D32);
      default:        return const Color(0xFF1565C0);
    }
  }
}
