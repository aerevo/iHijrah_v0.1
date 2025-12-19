// lib/widgets/dummy_feed_panel.dart (PREMIUM: GRADIENT BORDER & SHADER TEXT)
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DummyFeedPanel extends StatelessWidget {
  const DummyFeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: AppSpacing.md, 
        left: 0, 
        right: 0,
        bottom: 120, 
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Suapan Komuniti",
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
                letterSpacing: 1.5,
                fontWeight: FontWeight.bold
              ),
            ),
          ),

          ...List.generate(20, (index) {
            return _SocialPostCard(
              userName: index % 2 == 0 ? 'Syafiq Aiman' : 'Sarah Liyana',
              timeAgo: '${index + 1}j yang lalu',
              content: index % 2 == 0
                ? 'Post ke-#${index + 1}: Alhamdulillah, hari ni genap 30 hari istiqamah solat Subuh berjemaah. Rasa tenang sangat hati ni. Doakan saya terus kuat ya sahabat semua!'
                : 'Post ke-#${index + 1}: Ada sesiapa tahu kat mana nak cari kelas tajwid asas area Seremban yang sesuai untuk wanita bekerja? Terima kasih.',
              initialLikes: (index * 5) + 12,
              initialComments: index + 2,
            );
          }),
        ],
      ),
    );
  }
}

class _SocialPostCard extends StatelessWidget {
  final String userName;
  final String timeAgo;
  final String content;
  final int initialLikes;
  final int initialComments;

  const _SocialPostCard({
    Key? key,
    required this.userName,
    required this.timeAgo,
    required this.content,
    required this.initialLikes,
    required this.initialComments,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // Jarak lebih luas sikit
      child: Stack(
        children: [
          // 1. GLOW EFFECT (Belakang Kad)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryGold.withOpacity(0.05), // Glow emas sangat halus
                    blurRadius: 20,
                    spreadRadius: -5,
                  )
                ],
              ),
            ),
          ),

          // 2. GRADIENT BORDER CONTAINER
          // Trik: Container Gradient di belakang, Container Hitam di depan (margin 1px)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kPrimaryGold.withOpacity(0.6), // Atas Kiri: Emas Terang
                  Colors.white.withOpacity(0.1), // Tengah: Pudar
                  kPrimaryGold.withOpacity(0.3), // Bawah Kanan: Emas Gelap
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(17), // 1px lebih besar dari content
            ),
            padding: const EdgeInsets.all(1.0), // Ini yang jadi "Border" 1px
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0), // Blur sederhana
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4), // Latar Gelap
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient( // Avatar Ring Gradient
                                colors: [kPrimaryGold, kGoldDark],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle
                            ),
                            padding: const EdgeInsets.all(1.5), // Border tebal sikit
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black, // Inner circle
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.person, color: Colors.white.withOpacity(0.9), size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ SHADER MASK: TEKS EMAS BERKILAU (METALLIC)
                                ShaderMask(
                                  shaderCallback: (bounds) => kShimmerGoldGradient.createShader(
                                    Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                  ),
                                  child: Text(
                                    userName, 
                                    style: const TextStyle(
                                      color: Colors.white, // Wajib putih untuk shader nampak
                                      fontWeight: FontWeight.bold, 
                                      fontSize: AppFontSizes.md + 1,
                                    )
                                  ),
                                ),
                                Text(timeAgo, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
                              ],
                            ),
                          ),
                          Icon(Icons.more_horiz, color: kPrimaryGold.withOpacity(0.5), size: 20),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Content
                      Text(
                        content, 
                        style: const TextStyle(
                          color: Colors.white, 
                          fontSize: 14, 
                          height: 1.5,
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)] // Shadow teks supaya timbul
                        )
                      ),
                      
                      const SizedBox(height: 16),
                      Divider(color: kPrimaryGold.withOpacity(0.2), height: 1), // Garis pemisah emas pudar
                      const SizedBox(height: 12),
                      
                      // Footer
                      Row(
                        children: [
                          _buildAction(Icons.favorite_border, '$initialLikes'),
                          const SizedBox(width: 24),
                          _buildAction(Icons.chat_bubble_outline, '$initialComments'),
                          const Spacer(),
                          _buildAction(Icons.share_outlined, '', isIconOnly: true),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, {bool isIconOnly = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: kPrimaryGold), // Ikon Emas Penuh
        if (!isIconOnly) ...[
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }
}
