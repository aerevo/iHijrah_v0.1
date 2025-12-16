// lib/widgets/dummy_feed_panel.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart'; 

class DummyFeedPanel extends StatelessWidget {
  const DummyFeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Padding Feed: Dikurangkan untuk efek "Wide Screen"
      padding: const EdgeInsets.only(
        top: AppSpacing.md, 
        left: 12, // Kurangkan dari screenH (biasanya 20+) ke 12px
        right: 12,
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- POST 1: STATUS BIASA (SYAFIQ) ---
          const _SocialPostCard(
            userName: 'Syafiq Aiman',
            timeAgo: '2j',
            content: 'Alhamdulillah, hari ni genap 30 hari istiqamah solat Subuh berjemaah. Rasa tenang sangat hati ni. Doakan saya terus kuat ya sahabat semua!',
            initialLikes: 42,
            initialComments: 5,
          ),

          const SizedBox(height: AppSpacing.md),

          // --- POST 2: SOALAN (SARAH) ---
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

// --- PRIVATE WIDGET: STYLISH POST CARD (CLEAN AVATAR) ---
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222), // Dark grey yang elegan
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar WhatsApp Style
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white, 
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person, 
                  color: Colors.grey[400], 
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Nama & Masa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: AppFontSizes.md,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(Icons.more_horiz, color: Colors.grey[700], size: 20),
            ],
          ),

          const SizedBox(height: 12),

          // 2. Content
          Text(
            content,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),
          
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 12),

          // 3. Footer Actions
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
    );
  }

  Widget _buildAction(IconData icon, String label, {bool isIconOnly = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        if (!isIconOnly) ...[
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
