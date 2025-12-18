// lib/widgets/dummy_feed_panel.dart (EDGE-TO-EDGE WIDE)
import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart'; 

class DummyFeedPanel extends StatelessWidget {
  const DummyFeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Padding Feed: ZERO Left/Right untuk maksimalkan lebar
      padding: const EdgeInsets.only(
        top: AppSpacing.md, 
        left: 0, // Rapat ke tepi Sidebar
        right: 0, // Rapat ke tepi Skrin Kanan
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post 1
          const _SocialPostCard(
            userName: 'Syafiq Aiman',
            timeAgo: '2j',
            content: 'Alhamdulillah, hari ni genap 30 hari istiqamah solat Subuh berjemaah. Rasa tenang sangat hati ni. Doakan saya terus kuat ya sahabat semua!',
            initialLikes: 42,
            initialComments: 5,
          ),

          const SizedBox(height: AppSpacing.md),

          // Post 2
          const _SocialPostCard(
            userName: 'Sarah Liyana',
            timeAgo: 'Semalam',
            content: 'Ada sesiapa tahu kat mana nak cari kelas tajwid asas area Seremban yang sesuai untuk wanita bekerja? Terima kasih.',
            initialLikes: 12,
            initialComments: 8,
          ),
          
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// --- PRIVATE WIDGET: WIDE GLASS CARD ---
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
      // Margin kecil di tepi supaya tak rapat sangat ke dinding (pilihan: 4-8px)
      margin: const EdgeInsets.symmetric(horizontal: 4), 
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4), 
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
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
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: Icon(Icons.person, color: Colors.grey[400], size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: AppFontSizes.md, shadows: [Shadow(color: Colors.black, blurRadius: 2)])),
                          Text(timeAgo, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
                        ],
                      ),
                    ),
                    Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
                  ],
                ),
                const SizedBox(height: 12),
                // Content
                Text(content, style: const TextStyle(color: Color(0xFFEEEEEE), fontSize: 14, height: 1.5, shadows: [Shadow(color: Colors.black45, blurRadius: 2)])),
                const SizedBox(height: 16),
                Divider(color: Colors.white.withOpacity(0.1), height: 1),
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
    );
  }

  Widget _buildAction(IconData icon, String label, {bool isIconOnly = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        if (!isIconOnly) ...[
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ],
    );
  }
}
