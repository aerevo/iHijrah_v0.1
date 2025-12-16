// lib/widgets/dynamic_background.dart (MENU: CRYSTAL CLEAR)
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
        bool isMenuOpen = false;

        // PRIORITI 1: Jika Sidebar/Menu sedang aktif (Expand)
        if (sidebarState.activeMenuId != null && sidebarState.activeMenuId!.isNotEmpty) {
          targetImage = AppAssets.bgPattern; // Gambar Corak
          isMenuOpen = true; // Menu Buka
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
              duration: const Duration(milliseconds: 800), // Fade perlahan
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: Container(
                key: ValueKey<String>(targetImage), 
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(targetImage),
                    fit: BoxFit.cover, // Penuhkan skrin
                  ),
                ),
                // Fallback
                child: Container(color: Colors.transparent), 
              ),
            ),

            // LAPISAN 2: GELAP (DIMMING OVERLAY)
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              color: isMenuOpen 
                  ? Colors.transparent // ✅ 0% GELAP: Corak terpampang jelas, suci bersih!
                  : Colors.black.withOpacity(0.6), // 60% GELAP: Hanya untuk Feed (Siang/Malam) supaya teks boleh baca
            ),
          ],
        );
      },
    );
  }
}
