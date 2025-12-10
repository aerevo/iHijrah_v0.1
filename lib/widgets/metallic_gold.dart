// lib/widgets/metallic_gold.dart (HIGH-GLOSS LUXURY)
import 'package:flutter/material.dart';

class MetallicGold extends StatelessWidget {
  final Widget child;
  final bool isSheer; // TRUE = Separa Lutsinar (Glassy), FALSE = Solid Gold

  const MetallicGold({
    Key? key, 
    required this.child,
    this.isSheer = false, // Default: Solid Gold (Macam Screenshot)
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isSheer) {
      // MODE 2: SEPARA LUTSINAR (GLASS GOLD)
      // Nampak macam kaca emas nipis
      return ShaderMask(
        shaderCallback: (bounds) {
          return LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFFE5B4).withOpacity(0.9), // Putih Emas (Atas)
              const Color(0xFFD4AF37).withOpacity(0.3), // Tengah Lutsinar
              const Color(0xFFAA771C).withOpacity(0.9), // Bawah Emas Gelap
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcATop,
        child: child,
      );
    } else {
      // MODE 1: SOLID LUXURY (HIGH CONTRAST)
      // Ini teknik 'Horizon Line'. Ada garis pantulan tajam.
      return ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFBF953F), // 1. Emas Medium
              Color(0xFFFCF6BA), // 2. HIGHLIGHT PUTIH (Kilat Tajam)
              Color(0xFFB38728), // 3. Emas Pekat
              Color(0xFFFBF5B7), // 4. Pantulan Bawah (Glow)
              Color(0xFFAA771C), // 5. Emas Gelap Dasar
            ],
            // STOPS ini penting! Ia buat garis kilat tu tajam, bukan kabur.
            stops: [0.0, 0.45, 0.5, 0.55, 1.0], 
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: Container(
          // Tambah shadow sikit supaya teks timbul 3D
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          child: child,
        ),
      );
    }
  }
}