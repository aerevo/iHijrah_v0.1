// lib/widgets/metallic_gold.dart (OPTIMIZED: STATIC LUXURY)
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Premium Static Gold Effect
///
/// Features:
/// - Zero GPU Animation Load (Battery Friendly)
/// - Luxury "Gold Bar" Gradient Style
/// - Mimics vertical light reflection (Adobe Stock Style)
class MetallicGold extends StatelessWidget {
  final Widget child;
  final bool isLightMode; // Opsyen jika nak tone lebih cerah

  const MetallicGold({
    Key? key,
    required this.child,
    this.isLightMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          // Arah gradient dari Atas ke Bawah (Vertical Sheen)
          // Meniru pantulan cahaya pada permukaan emas fizikal
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFC6A664), // 0% - Emas Standard (Atas)
            Color(0xFFFDF6D5), // 45% - Highlight Putih (Pantulan Cahaya)
            Color(0xFFFDF6D5), // 55% - Kekal Putih sekejap
            Color(0xFF8E793E), // 100% - Emas Gelap/Bronze (Bawah/Bayang)
          ],
          stops: [
            0.0,
            0.45,
            0.55,
            1.0,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn, // Pastikan ia 'paint' di atas text/icon sahaja
      child: child,
    );
  }
}

/// Backward Compatibility Wrapper
/// (Disimpan supaya kod lama yang panggil kelas ini tidak crash)
class MetallicGoldStatic extends StatelessWidget {
  final Widget child;

  const MetallicGoldStatic({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Redirect terus ke MetallicGold utama yang kini sudah optimum
    return MetallicGold(child: child);
  }
}
