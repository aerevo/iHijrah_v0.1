import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'feed_card.dart';

class DummyFeedPanel extends StatelessWidget {
  const DummyFeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: AppSpacing.xl,
        left: AppSpacing.screenH,
        right: AppSpacing.screenH,
        bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Text(
            'Selamat Kembali, Kapten Aer!',
            style: TextStyle(
              color: kPrimaryGold,
              fontSize: AppFontSizes.xxl,
              fontWeight: FontWeight.bold,
              fontFamily: 'Playfair',
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Feed utama Tuan sudah bersih. Sedia untuk integrasi Firebase.',
            style: TextStyle(
              color: kTextSecondary,
              fontSize: AppFontSizes.md,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // DUMMY POST 1: FIREBASE
          const FeedCard(
            title: 'Firebase Docks Sedia!',
            subtitle:
                'Konten utama app akan dimuatkan di sini. Tuan boleh mulakan fetching data dari Firebase dan masukkan ke dalam FeedCard ini.',
            leadingIcon: Icons.cloud_done,
          ),
          const SizedBox(height: AppSpacing.md),

          // DUMMY POST 2: SIRAH
          const FeedCard(
            title: 'Sirah Hari Ini (Placeholder)',
            subtitle:
                'Data Sirah harian akan dipaparkan secara automatik di slot ini. Ia akan menjadi "Sticky Post" utama.',
            leadingIcon: Icons.history_edu,
          ),
          const SizedBox(height: AppSpacing.md),

          // DUMMY POST 3: NOTIFIKASI
          const FeedCard(
            title: 'Notifikasi & Kemaskini',
            subtitle:
                'Pemberitahuan am tentang pencapaian pengguna dan kemaskini app akan muncul di sini. (Contoh: "Anda telah capai Level 2 Pokok Hijrah!")',
            leadingIcon: Icons.notifications_active,
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
