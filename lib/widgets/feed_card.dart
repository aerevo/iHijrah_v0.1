// lib/widgets/feed_card.dart
// ═══════════════════════════════════════════════════════════════
// PREMIUM UPGRADES APPLIED:
//   [U1] isCenter param — dipakai untuk shadow glow
//   [U2] Glassmorphism lighting — gradient + top highlight strip
//   [U3] Typography hierarchy — Playfair bold title, thin body
//   [U4] Dual-layer colored shadow glow bila kad snap ke center
// ═══════════════════════════════════════════════════════════════

import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FeedCard extends StatelessWidget {
  final PostModel post;
  final bool isCenter; // [U1][U4] — ganti nama dari isActive ke isCenter (lebih semantik)
  final VoidCallback? onTap;

  const FeedCard({
    Key? key,
    required this.post,
    this.isCenter = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasImage = post.assetPath != null && post.assetPath!.isNotEmpty;
    final Color typeColor = _typeColor();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          // ╔══════════════════════════════════════════════════════╗
          // ║  [U4] DUAL-LAYER COLORED SHADOW GLOW               ║
          // ║  Layer 1: tight, bright glow (rasa neon rim light) ║
          // ║  Layer 2: wide, soft ambient (rasa floating)       ║
          // ║  Bila bukan center — shadow hilang sepenuhnya      ║
          // ╚══════════════════════════════════════════════════════╝
          boxShadow: isCenter
              ? [
                  // Rim glow — tight & punchy
                  BoxShadow(
                    color: typeColor.withOpacity(0.45),
                    blurRadius: 20,
                    spreadRadius: -2,
                    offset: const Offset(0, 6),
                  ),
                  // Ambient glow — lebar & lembut
                  BoxShadow(
                    color: typeColor.withOpacity(0.15),
                    blurRadius: 50,
                    spreadRadius: 4,
                    offset: const Offset(0, 12),
                  ),
                ]
              : [
                  // Off-center: shadow gelap neutral sahaja
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              // ╔════════════════════════════════════════════════════╗
              // ║  [U2] GLASSMORPHISM LIGHTING UPGRADE              ║
              // ║  Buang flat `color: white.withOpacity(0.05)`      ║
              // ║  Ganti dengan gradient directional:               ║
              // ║    topLeft = 0.13 (cahaya masuk dari kiri atas)  ║
              // ║    bottomRight = 0.03 (dalam bayangan)           ║
              // ║  Ini simulate real-world frosted glass di bawah  ║
              // ║  sumber cahaya atas.                             ║
              // ╚════════════════════════════════════════════════════╝
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.13),
                    Colors.white.withOpacity(0.03),
                  ],
                ),
                border: Border.all(
                  // Border terang bila center, samar bila tepi
                  color: isCenter
                      ? typeColor.withOpacity(0.55)
                      : Colors.white.withOpacity(0.08),
                  width: isCenter ? 1.5 : 1.0,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── [U2] TOP HIGHLIGHT STRIP ─────────────────────
                  // Simulate cahaya dari atas — ciri khas Apple glass UI
                  Container(
                    height: 1,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withOpacity(0.35),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),

                  // ── MAIN CARD CONTENT ────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        // ── KIRI: TEKS & PROFIL ──────────────────
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Author row
                              Row(
                                children: [
                                  // ── [U3] TYPE BADGE — ganti CircleAvatar plain ──
                                  // Pill badge jauh lebih premium dari icon dalam circle
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: typeColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: typeColor.withOpacity(0.5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_typeIcon(), color: typeColor, size: 9),
                                        const SizedBox(width: 4),
                                        Text(
                                          post.type.toUpperCase(),
                                          style: TextStyle(
                                            color: typeColor,
                                            fontSize: 8,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${post.author} • ${post.time}",
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.55),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // ╔════════════════════════════════════════╗
                              // ║  [U3] TYPOGRAPHY HIERARCHY            ║
                              // ║  Title: Playfair, 15px, letterSpacing ║
                              // ║   -0.3 (tighter = lebih premium)      ║
                              // ║  Body: w300 (thin) supaya contrast    ║
                              // ║   dengan bold title lebih ketara      ║
                              // ╚════════════════════════════════════════╝
                              Text(
                                post.title,
                                style: const TextStyle(
                                  color: kPrimaryGold,
                                  fontSize: 15,           // naik dari 14
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Playfair',
                                  letterSpacing: -0.3,    // tighter = premium
                                  height: 1.25,
                                ),
                                maxLines: 2,              // naik dari 1 — title boleh wrap
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 5),

                              Text(
                                post.content,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w300, // thin untuk contrast
                                  height: 1.45,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const SizedBox(height: 12),

                              // Footer
                              Row(
                                children: [
                                  Icon(Icons.favorite, color: kWarningRed.withOpacity(0.85), size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${post.likes}",
                                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                  const Spacer(),
                                  // ── [U3] BACA LANJUT — lebih visible bila center ──
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 300),
                                    style: TextStyle(
                                      color: isCenter ? kPrimaryGold : Colors.white38,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0,
                                    ),
                                    child: const Text("BACA LANJUT"),
                                  ),
                                  AnimatedOpacity(
                                    opacity: isCenter ? 1.0 : 0.3,
                                    duration: const Duration(milliseconds: 300),
                                    child: const Icon(Icons.chevron_right, color: kPrimaryGold, size: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // ── KANAN: MEDIA ─────────────────────────
                        if (hasImage) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    post.assetPath!,
                                    fit: BoxFit.cover,
                                    height: double.infinity,
                                    width: double.infinity,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.white10,
                                      child: const Icon(Icons.image_not_supported, color: Colors.white24, size: 20),
                                    ),
                                  ),
                                  // ── [U2] Vignette atas image supaya nampak lebih cinematic ──
                                  Positioned.fill(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.black.withOpacity(0.0),
                                            Colors.black.withOpacity(0.3),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (post.type == 'video')
                                    Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.55),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white54, width: 1.5),
                                        ),
                                        child: const Icon(Icons.play_arrow, color: Colors.white, size: 18),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor() {
    switch (post.type) {
      case 'video':   return const Color(0xFFE53935);
      case 'quote':   return const Color(0xFF8E24AA);
      case 'event':   return const Color(0xFF43A047);
      default:        return kPrimaryGold;
    }
  }

  IconData _typeIcon() {
    switch (post.type) {
      case 'video':   return Icons.play_arrow;
      case 'quote':   return Icons.format_quote;
      case 'event':   return Icons.calendar_month;
      default:        return Icons.article;
    }
  }
}
