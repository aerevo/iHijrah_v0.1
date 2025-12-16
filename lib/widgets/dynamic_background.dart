import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';

class DynamicBackground extends StatelessWidget {
  const DynamicBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Dapatkan Jam Semasa
    final hour = DateTime.now().hour;
    // Siang: 7 pagi - 7 malam (19:00)
    final bool isDaytime = hour >= 7 && hour < 19;

    return Consumer<SidebarStateModel>(
      builder: (context, sidebarState, child) {
        // 2. Logik Pemilihan Gambar
        String targetImage;

        // PRIORITI 1: Jika Sidebar/Menu sedang aktif (Expand)
        // Kita anggap jika ada activeMenuId, maksudnya user sedang 'klik' sidebar
        if (sidebarState.activeMenuId != null && sidebarState.activeMenuId!.isNotEmpty) {
          targetImage = AppAssets.bgPattern;
        } 
        // PRIORITI 2: Jika Siang
        else if (isDaytime) {
          targetImage = AppAssets.bgDay;
        } 
        // PRIORITI 3: Jika Malam
        else {
          targetImage = AppAssets.bgNight;
        }

        // 3. Paparan dengan Animasi Fade (Expand Fade)
        return Container(
          color: kBackgroundDark, // Fallback color kalau gambar gagal load
          width: double.infinity,
          height: double.infinity,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 800), // Tempoh 'Fade'
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: Image.asset(
              targetImage,
              key: ValueKey<String>(targetImage), // Key penting untuk detect perubahan
              fit: BoxFit.cover, // Penuhkan skrin
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                // Jika gambar tak jumpa, guna gradient gelap asal
                return Container(
                  decoration: const BoxDecoration(
                    gradient: kBackgroundGradient,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}