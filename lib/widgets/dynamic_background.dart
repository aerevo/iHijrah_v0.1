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
        // 2. Logik Pemilihan Gambar & Menu State
        String targetImage;
        bool isMenuOpen = false; // Variable untuk detect menu buka/tutup

        // PRIORITI 1: Jika Sidebar/Menu sedang aktif (Expand)
        // Kita anggap jika ada activeMenuId, maksudnya user sedang 'klik' sidebar
        if (sidebarState.activeMenuId != null && sidebarState.activeMenuId!.isNotEmpty) {
          targetImage = AppAssets.bgPattern; // Gambar Corak bila menu buka
          isMenuOpen = true; // Tandakan menu sedang dibuka
        } 
        // PRIORITI 2: Jika Siang
        else if (isDaytime) {
          targetImage = AppAssets.bgDay; // Masjid Nabawi
        } 
        // PRIORITI 3: Jika Malam
        else {
          targetImage = AppAssets.bgNight; // Mekah/Kaabah
        }

        // 3. Paparan Layer (Stack)
        return Stack(
          children: [
            // LAPISAN 1: GAMBAR LATAR (Animated Switcher)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1000), // Fade perlahan (1 saat)
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: Container(
                key: ValueKey<String>(targetImage), // Key penting untuk detect perubahan
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(targetImage),
                    fit: BoxFit.cover, // Penuhkan skrin
                  ),
                ),
              ),
            ),

            // LAPISAN 2: GELAP (DIMMING OVERLAY)
            // Kita gelapkan sikit gambar supaya tulisan putih/emas nampak jelas
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              color: isMenuOpen 
                  ? Colors.black.withOpacity(0.85) // Gelap sangat bila buka menu (Fokus Menu)
                  : Colors.black.withOpacity(0.6), // Gelap sikit bila biasa (Supaya Feed nampak)
            ),
          ],
        );
      },
    );
  }
}
