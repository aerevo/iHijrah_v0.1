// lib/widgets/metallic_gold.dart (OPTIMIZED: SHUTTERSTOCK LUXURY PALETTE)
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Premium Static Gold Effect
///
/// Features:
/// - Zero GPU Animation Load (Battery Friendly)
/// - Luxury "Gold Bar" Gradient Style
/// - Uses specific Hex Palette from Shutterstock "100 Gradient Styles"
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
            Color(0xFF996900), // Dark Olive Gold (Bayang Atas)
            Color(0xFFFFDE62), // Bright Gold (Emas Terang)
            Color(0xFFFFF5C2), // HIGHLIGHT (Putih Mutiara - Kilauan Utama)
            Color(0xFF8A500E), // Deep Rich Gold (Emas Pekat)
            Color(0xFF521D00), // Dark Brown (Bayang Bawah - 3D Depth)
          ],
          stops: [
            0.0,  // Gelap di hujung atas
            0.25, // Mula terang
            0.5,  // KILAUAN DI TENGAH (Titik Fokus)
            0.75, // Kembali pekat
            1.0,  // Gelap di hujung bawah
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
