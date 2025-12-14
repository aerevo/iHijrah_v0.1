// lib/widgets/metallic_gold.dart (UPGRADED 7.8/10)

import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Premium metallic gold shader effect widget
///
/// Features:
/// - Animated shimmer effect (gold bergerak)
/// - Smooth 3-second loop
/// - Auto-dispose controller
/// - Optimized performance
class MetallicGold extends StatefulWidget {
  final Widget child;

  const MetallicGold({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MetallicGold> createState() => _MetallicGoldState();
}

class _MetallicGoldState extends State<MetallicGold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // 3-second shimmer loop
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Calculate gradient offset (-1 to 1)
        final offset = _controller.value * 2 - 1;

        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFF8E793E), // Dark bronze
                Color(0xFFAD9C72), // Matte gold
                Color(0xFFFDF6D5), // Pearl white (highlight)
                Color(0xFFC6A664), // Standard gold
                Color(0xFF8E793E), // Dark bronze
              ],
              stops: [
                (0.0 + offset * 0.5).clamp(0.0, 1.0),
                (0.3 + offset * 0.5).clamp(0.0, 1.0),
                (0.5 + offset * 0.5).clamp(0.0, 1.0), // Center highlight
                (0.7 + offset * 0.5).clamp(0.0, 1.0),
                (1.0 + offset * 0.5).clamp(0.0, 1.0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Static version (no animation) untuk performance critical areas
class MetallicGoldStatic extends StatelessWidget {
  final Widget child;

  const MetallicGoldStatic({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) {
        return const LinearGradient(
          colors: [
            Color(0xFF8E793E),
            Color(0xFFAD9C72),
            Color(0xFFFDF6D5),
            Color(0xFFC6A664),
            Color(0xFF8E793E),
          ],
          stops: [0.0, 0.3, 0.5, 0.7, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds);
      },
      child: child,
    );
  }
}