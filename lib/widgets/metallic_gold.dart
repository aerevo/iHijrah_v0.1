// lib/widgets/metallic_gold.dart (HIGH-GLOSS LUXURY)
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MetallicGold extends StatelessWidget {
  final Widget child;

  const MetallicGold({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MODE: SOLID LUXURY (HIGH CONTRAST)
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFBF953F), // 1. Emas Medium (Atas)
            Color(0xFFFCF6BA), // 2. HIGHLIGHT PUTIH (Kilat Tajam) - Ini rahsia kilat dia
            Color(0xFFB38728), // 3. Emas Pekat
            Color(0xFFFBF5B7), // 4. Pantulan Bawah (Glow sikit)
            Color(0xFFAA771C), // 5. Emas Gelap Dasar
          ],
          // 'Stops' ini penting! Ia buat garis kilat tu tajam (Sharp), nampak macam besi
          stops: [0.0, 0.45, 0.5, 0.55, 1.0], 
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: Container(
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