// lib/widgets/dummy_feed_panel.dart
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DummyFeedPanel extends StatelessWidget {
  const DummyFeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // Padding Feed
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        left: AppSpacing.screenH, // Guna screenH dari constants
        right: AppSpacing.screenH,
        bottom: 100, // Ruang bawah untuk scroll selesa
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Welcome Message
          const Text(
            'Komuniti Hijrah',
            style: TextStyle(
              color: kPrimaryGold,
              fontSize: AppFontSizes.xxl,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Lihat perkembangan sahabat-sahabat seperjuangan Tuan.',
            style: TextStyle(
              color: kTextSecondary,
              fontSize: AppFontSizes.md,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // --- POST 1: STATUS PENGGUNA (ALA FB) ---
          const _SocialPostCard(
            userName: 'Syafiq Aiman',
            timeAgo: '2 jam lepas',
            content: 'Alhamdulillah, hari ni genap 30 hari istiqamah solat Subuh berjemaah. Rasa tenang sangat hati ni. Doakan saya terus kuat ya sahabat semua!',
            initialLikes: 42,
            initialComments: 5,
            userColor: Colors.blueAccent, // Warna avatar dummy
          ),

          const SizedBox(height: AppSpacing.md),

          // --- POST 2: PERKONGSIAN ILMU ---
          const _SocialPostCard(
            userName: 'Ustaz Azhar (Admin)',
            timeAgo: '4 jam lepas',
            content: 'Tips hari ini: Jangan pandang remeh pada dosa kecil, kerana gunung yang tinggi itu pun terbina dari butir pasir. Teruskan istighfar.',
            initialLikes: 156,
            initialComments: 23,
            userColor: kPrimaryGold, // Admin warna emas
          ),

          const SizedBox(height: AppSpacing.md),

          // --- POST 3: SOALAN KOMUNITI ---
          const _SocialPostCard(
            userName: 'Sarah Liyana',
            timeAgo: 'Semalam',
            content: 'Ada sesiapa tahu kat mana nak cari kelas tajwid asas area Seremban yang sesuai untuk wanita bekerja? Terima kasih.',
            initialLikes: 12,
            initialComments: 8,
            userColor: Colors.purpleAccent,
          ),
          
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

// --- PRIVATE WIDGET: SOCIAL POST CARD (LOCAL) ---
// Widget ini direka khas di sini untuk meniru gaya FB tanpa perlu fail luar.
class _SocialPostCard extends StatelessWidget {
  final String userName;
  final String timeAgo;
  final String content;
  final int initialLikes;
  final int initialComments;
  final Color userColor;

  const _SocialPostCard({
    Key? key,
    required this.userName,
    required this.timeAgo,
    required this.content,
    required this.initialLikes,
    required this.initialComments,
    required this.userColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Warna kad yang sedikit cerah dari background gelap
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10), // Border halus
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Avatar + Nama + Masa
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: userColor.withOpacity(0.2),
                child: Text(
                  userName[0], // Ambil huruf pertama nama
                  style: TextStyle(
                    color: userColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: AppFontSizes.md,
                    ),
                  ),
                  Text(
                    timeAgo,
                    style: TextStyle(
                      color: kTextSecondary.withOpacity(0.7),
                      fontSize: AppFontSizes.xs,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.more_horiz, color: kTextSecondary),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 2. Content Body
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFFE0E0E0), // Putih sedikit kelabu untuk bacaan selesa
              fontSize: AppFontSizes.md,
              height: 1.4, // Jarak baris untuk keselesaan membaca
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          const Divider(color: Colors.white10),
          const SizedBox(height: AppSpacing.xs),

          // 3. Footer: Action Buttons (Like, Comment, Share)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildActionButton(Icons.thumb_up_alt_outlined, '$initialLikes Likes'),
              _buildActionButton(Icons.chat_bubble_outline, '$initialComments Komen'),
              _buildActionButton(Icons.share_outlined, 'Share'),
            ],
          ),
        ],
      ),
    );
  }

  // Helper untuk butang interaksi
  Widget _buildActionButton(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 18, color: kTextSecondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: kTextSecondary,
            fontSize: AppFontSizes.sm,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
