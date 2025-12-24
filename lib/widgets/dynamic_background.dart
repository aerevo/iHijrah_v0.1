// lib/widgets/dynamic_background.dart (CHANGED TO LANGIT.PNG)

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
        
        return Stack(
          children: [
            // 1. GAMBAR LATAR BARU (LANGIT.PNG)
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  // ✅ Pastikan fail ini wujud: assets/images/langit.png
                  image: AssetImage('assets/images/langit.png'), 
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // 2. DARK OVERLAY (PENTING UNTUK READABILITY)
            // Kita gelapkan sedikit supaya teks putih di kad feed tak tenggelam
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2), // Atas cair sikit nampak langit
                    Colors.black.withOpacity(0.5), // Tengah
                    Colors.black.withOpacity(0.8), // Bawah gelap untuk anchor feed
                  ],
                ),
              ),
            ),

            // 3. CORAK ISLAMIK (Hanya bila Sidebar Buka)
            AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: sidebarState.isVisible ? 0.4 : 0.0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(AppAssets.bgPattern),
                      fit: BoxFit.cover,
                      repeat: ImageRepeat.repeat,
                      opacity: 0.1,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
