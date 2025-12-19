// lib/widgets/dummy_feed_panel.dart (FORCE BRIGHT GOLD MODE)
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart'; // ✅ WAJIB IMPORT INI

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
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Stack(
        children: [
          // 1. GLOW FRAME (Belakang Kad)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: kPrimaryGold.withOpacity(0.08), // Glow emas sekeliling kad
                    blurRadius: 15,
                    spreadRadius: -2,
                  )
                ],
              ),
            ),
          ),

          // 2. MAIN CARD CONTENT
          Container(
            decoration: BoxDecoration(
              // Border Gradient Emas yang SANGAT NIPIS & TAJAM
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFFD740), // Emas Terang
                  Colors.white.withOpacity(0.1), 
                  Color(0xFFFFA000), // Emas Pekat
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(17), 
            ),
            padding: const EdgeInsets.all(1.0), // Border 1px
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5), // Latar Gelap Sikit supaya Emas naik
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // AVATAR RING (Emas)
                          Container(
                            width: 40, height: 40,
                            decoration: const BoxDecoration(shape: BoxShape.circle),
                            // Guna MetallicGold pada Avatar Ring
                            child: MetallicGold(
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white, width: 2), // White jadi Emas sbb MetallicGold
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person, color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 12),
                          
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ✅ NAMA PENGGUNA (MENYALA!)
                                // Kita bungkus dalam MetallicGold Widget yang Kapten baru update
                                MetallicGold(
                                  child: Text(
                                    userName, 
                                    style: TextStyle(
                                      color: Colors.white, // Base mesti putih
                                      fontWeight: FontWeight.w900, // Lebih tebal supaya nampak kilau
                                      fontSize: AppFontSizes.md + 1,
                                      shadows: [
                                        // RAHSIANYA DI SINI: Shadow Emas (Glow)
                                        BoxShadow(
                                          color: Color(0xFFFFD740).withOpacity(0.6),
                                          blurRadius: 8,
                                          offset: Offset(0, 0),
                                        )
                                      ]
                                    )
                                  ),
                                ),
                                const SizedBox(height: 2),
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
                          shadows: [Shadow(color: Colors.black, blurRadius: 4)]
                        )
                      ),
                      
                      const SizedBox(height: 16),
                      Divider(color: kPrimaryGold.withOpacity(0.3), height: 1), 
                      const SizedBox(height: 12),
                      
                      // Footer Actions (Icons pun Emas Menyala)
                      Row(
                        children: [
                          _buildGoldIconAction(Icons.favorite_border, '$initialLikes'),
                          const SizedBox(width: 24),
                          _buildGoldIconAction(Icons.chat_bubble_outline, '$initialComments'),
                          const Spacer(),
                          _buildGoldIconAction(Icons.share_outlined, '', isIconOnly: true),
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

  // Widget Khas untuk Icon Emas
  Widget _buildGoldIconAction(IconData icon, String label, {bool isIconOnly = false}) {
    return Row(
      children: [
        MetallicGold(
          child: Icon(icon, size: 22, color: Colors.white),
        ),
        if (!isIconOnly) ...[
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }
}
