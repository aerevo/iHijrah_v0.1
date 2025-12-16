// lib/widgets/dummy_feed_panel.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart'; // Import efek emas luxury tadi

class DummyFeedPanel extends StatelessWidget {
  const DummyFeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Padding Feed - Top dikurangkan sebab header dah buang
      padding: const EdgeInsets.only(
        top: AppSpacing.md, 
        left: AppSpacing.screenH,
        right: AppSpacing.screenH,
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- POST 1: STATUS BIASA ---
          const _SocialPostCard(
            userName: 'Syafiq Aiman',
            timeAgo: '2j',
            content: 'Alhamdulillah, hari ni genap 30 hari istiqamah solat Subuh berjemaah. Rasa tenang sangat hati ni. Doakan saya terus kuat ya sahabat semua!',
            initialLikes: 42,
            initialComments: 5,
            userColor: Colors.blueAccent,
            isAdmin: false,
          ),

          const SizedBox(height: AppSpacing.md),

          // --- POST 2: ADMIN (LUXURY STYLE) ---
          const _SocialPostCard(
            userName: 'Ustaz Azhar',
            timeAgo: '4j',
            content: 'Tips hari ini: Jangan pandang remeh pada dosa kecil, kerana gunung yang tinggi itu pun terbina dari butir pasir. Teruskan istighfar.',
            initialLikes: 156,
            initialComments: 23,
            userColor: kPrimaryGold,
            isAdmin: true, // Special flag untuk effect emas
          ),

          const SizedBox(height: AppSpacing.md),

          // --- POST 3: SOALAN ---
          const _SocialPostCard(
            userName: 'Sarah Liyana',
            timeAgo: 'Semalam',
            content: 'Ada sesiapa tahu kat mana nak cari kelas tajwid asas area Seremban yang sesuai untuk wanita bekerja? Terima kasih.',
            initialLikes: 12,
            initialComments: 8,
            userColor: Colors.purpleAccent,
            isAdmin: false,
          ),
          
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// --- PRIVATE WIDGET: STYLISH POST CARD ---
class _SocialPostCard extends StatelessWidget {
  final String userName;
  final String timeAgo;
  final String content;
  final int initialLikes;
  final int initialComments;
  final Color userColor;
  final bool isAdmin;

  const _SocialPostCard({
    Key? key,
    required this.userName,
    required this.timeAgo,
    required this.content,
    required this.initialLikes,
    required this.initialComments,
    required this.userColor,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222222), // Dark grey yang lebih elegan
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        // Border halus sekadar hiasan
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
              // Avatar dengan Cincin Emas (Luxury Touch)
              MetallicGold(
                child: Container(
                  padding: const EdgeInsets.all(2), // Ketebalan cincin emas
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white, // Dummy color utk shader mask
                  ),
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF121212), // Background dalam cincin
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: userColor.withOpacity(0.2),
                      child: Text(
                        userName[0],
                        style: TextStyle(
                          color: userColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Nama & Masa
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Nama User (Kalau Admin, kita Emaskan)
                        isAdmin
                            ? MetallicGold(
                                child: Text(
                                  userName,
                                  style: const TextStyle(
                                    color: Colors.white, // Ditutup oleh shader emas
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppFontSizes.md,
                                  ),
                                ),
                              )
                            : Text(
                                userName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppFontSizes.md,
                                ),
                              ),
                        
                        // Verified Badge untuk Admin
                        if (isAdmin) ...[
                          const SizedBox(width: 4),
                          const MetallicGold(
                            child: Icon(
                              Icons.verified,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ],
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
              
              // Menu Icon
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
          
          // Garis Halus
          Divider(color: Colors.white.withOpacity(0.05), height: 1),
          const SizedBox(height: 12),

          // 3. Footer Actions (Minimalist)
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
