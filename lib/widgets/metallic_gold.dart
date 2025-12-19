// lib/widgets/metallic_gold.dart (THE FAMOUS LUXURY GOLD GRADIENT)
import 'package:flutter/material.dart';

/// Premium Static Gold Effect (LUXURY TEXTURE EDITION)
///
/// Features:
/// - Menggunakan palet "Luxury Gold" yang terkenal dalam design premium.
/// - Mencipta efek "Gold Foil" atau tekstur logam sebenar.
class MetallicGold extends StatelessWidget {
  final Widget child;
  final bool isLightMode; 

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
          // Diagonal halus untuk efek pantulan semulajadi
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFBF953F), // 1. Classic Gold (Base)
            Color(0xFFFCF6BA), // 2. Ultra Light Gold (Highlight/Silau)
            Color(0xFFB38728), // 3. Dark Metallic Gold (Shadow/Depth)
            Color(0xFFFBF5B7), // 4. Light Sand Gold (Pantulan Kedua)
            Color(0xFFAA771C), // 5. Rich Gold (Finishing)
          ],
          stops: [
            0.0,
            0.25, // Highlight di bahagian atas
            0.5,  // Shadow di tengah (memberi bentuk 3D)
            0.75, // Highlight kedua
            1.0,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn, 
      child: child,
    );
  }
}

/// Backward Compatibility Wrapper
class MetallicGoldStatic extends StatelessWidget {
  final Widget child;

  const MetallicGoldStatic({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MetallicGold(child: child);
  }
}
