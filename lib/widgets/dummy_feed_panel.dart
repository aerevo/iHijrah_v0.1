// lib/widgets/dummy_feed_panel.dart (GLASSMORPHISM STYLE)
import 'dart:ui'; // Wajib untuk efek Blur
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart'; 

class DummyFeedPanel extends StatelessWidget {
  const DummyFeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Padding Feed: Edge-to-Edge
      padding: const EdgeInsets.only(
        top: AppSpacing.md, 
        left: 12, 
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

// --- PRIVATE WIDGET: GLASS POST CARD ---
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
    // 1. ClipRRect untuk potong blur ikut bucu bulat
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        // 2. Kuasa Blur (Semakin tinggi, semakin kabur latar belakang)
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            // 3. Warna Kaca (Hitam Pudar)
            color: Colors.black.withOpacity(0.4), 
            // 4. Border Kaca Halus
            border: Border.all(
              color: Colors.white.withOpacity(0.1), // Putih pudar di tepi
              width: 1,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER ROW
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
                            shadows: [Shadow(color: Colors.black, blurRadius: 2)], // Shadow supaya teks timbul
                          ),
                        ),
                        Text(
                          timeAgo,
                          style: TextStyle(
                            color: Colors.grey[400], // Terang sikit dari grey[600]
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Icon(Icons.more_horiz, color: Colors.grey[400], size: 20),
                ],
              ),

              const SizedBox(height: 12),

              // CONTENT
              Text(
                content,
                style: const TextStyle(
                  color: Color(0xFFEEEEEE), // Putih susu
                  fontSize: 14,
                  height: 1.5,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                ),
              ),

              const SizedBox(height: 16),
              
              // Garis Halus
              Divider(color: Colors.white.withOpacity(0.1), height: 1),
              const SizedBox(height: 12),

              // FOOTER ACTIONS
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
    );
  }

  Widget _buildAction(IconData icon, String label, {bool isIconOnly = false}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        if (!isIconOnly) ...[
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
