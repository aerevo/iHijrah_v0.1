// lib/widgets/dynamic_background.dart (CRYSTAL CLEAR NATURE)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/sidebar_state_model.dart';
import '../utils/constants.dart';

class DynamicBackground extends StatelessWidget {
  const DynamicBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<SidebarStateModel>(
      builder: (context, sidebarState, child) {
        String targetImage;
        double overlayOpacity;

        // PRIORITI 1: MENU BUKA (Guna Corak)
        if (sidebarState.activeMenuId != null && sidebarState.activeMenuId!.isNotEmpty) {
          targetImage = AppAssets.bgPattern;
          // Overlay 0% (Jelas)
          overlayOpacity = 0.0; 
        } 
        // PRIORITI 2: MODE BIASA (Guna Alam.png)
        else {
          targetImage = AppAssets.bgDay; 
          // ✅ FIX: Overlay 0% (Tiada lagi gelap/dimming. Terang benderang!)
          overlayOpacity = 0.0; 
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
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
            // Layer Hitam (Sekarang transparent sepenuhnya)
            child: Container(
              color: Colors.black.withOpacity(overlayOpacity),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        );
      },
    );
  }
}
