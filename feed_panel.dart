// lib/widgets/feed_panel.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/constants.dart';
import 'metallic_gold.dart';

class FeedPanel extends StatelessWidget {
  const FeedPanel({Key? key}) : super(key: key);

  // Data Dummy (Boleh diganti dengan Firebase nanti)
  final List<Map<String, dynamic>> posts = const [
    {
      'author': 'Ustaz Don Daniyal',
      'time': '2 jam lepas',
      'avatar': 'assets/images/profile_default.png', // Pastikan aset ini wujud atau guna Icon
      'content': 'Jom hayati sirah Nabi SAW. Banyak pengajaran untuk kita yang sedang berhijrah. Tonton video penuh di sini:',
      'link': 'https://www.youtube.com/watch?v=Hu1U1rD0oPE',
      'likes': 120,
      'comments': 45
    },
    {
      'author': 'Bonda Zyamina',
      'time': '5 jam lepas',
      'avatar': 'assets/images/profile_default.png',
      'content': 'Ingatlah, setiap kali kita jatuh, Allah sentiasa ada untuk sambut kita. Jangan putus asa. #iHijrah',
      'link': '',
      'likes': 850,
      'comments': 102
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // TAJUK EMAS BERKILAU
        const MetallicGold(
          child: Text(
            "Taman Komuniti",
            style: TextStyle(
              color: Colors.white,
              fontSize: AppFontSizes.xl,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair'
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Senarai Posts
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: kCardDark.withOpacity(0.7),
            borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
            border: Border.all(color: Colors.white10),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            separatorBuilder: (ctx, i) => Divider(color: Colors.white.withOpacity(0.1)),
            itemBuilder: (context, index) {
              return _buildPostCard(context, posts[index]);
            },
          ),
        )
      ],
    );
  }

  Widget _buildPostCard(BuildContext context, Map<String, dynamic> post) {
    bool hasLink = post['link'] != null && post['link'].isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header (Avatar, Nama, Masa)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: kPrimaryGold,
                // Fallback icon jika image gagal
                child: const Icon(Icons.person, color: kBackgroundDark, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['author'],
                      style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      post['time'],
                      style: const TextStyle(color: kTextSecondary, fontSize: AppFontSizes.xs),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // 2. Isi Kandungan (Teks)
          Text(
            post['content'],
            style: const TextStyle(color: kTextPrimary, height: 1.5, fontSize: AppFontSizes.sm + 1),
          ),

          // 3. Pautan (Jika ada)
          if (hasLink)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: InkWell(
                onTap: () async {
                  final uri = Uri.parse(post['link']);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Row(
                  children: const [
                    Icon(Icons.link, size: 16, color: kAccentOlive),
                    SizedBox(width: 5),
                    Text("Tonton Sekarang", style: TextStyle(color: kAccentOlive, decoration: TextDecoration.underline, fontSize: AppFontSizes.sm)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.md),

          // 4. Footer (Like & Comment)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInteractionButton(Icons.favorite_border, "${post['likes']} Suka"),
              _buildInteractionButton(Icons.chat_bubble_outline, "${post['comments']} Komen"),
              _buildInteractionButton(Icons.share, "Kongsi"),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInteractionButton(IconData icon, String text) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: kTextSecondary),
            const SizedBox(width: 6),
            Text(text, style: const TextStyle(color: kTextSecondary, fontSize: AppFontSizes.xs)),
          ],
        ),
      ),
    );
  }
}