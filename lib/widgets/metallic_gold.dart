// lib/widgets/metallic_gold.dart
import 'package:flutter/material.dart';

class MetallicGold extends StatelessWidget {
  final Widget child;
  const MetallicGold({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topLeft,
        end:   Alignment.bottomRight,
        colors: [
          Color(0xFFBF953F),
          Color(0xFFFCF6BA),
          Color(0xFFB38728),
          Color(0xFFFBF5B7),
          Color(0xFFAA771C),
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: child,
    );
  }
}

// Alias untuk backward compatibility
typedef MetallicGoldStatic = MetallicGold;
