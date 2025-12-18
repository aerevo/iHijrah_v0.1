// lib/widgets/metallic_gold.dart - PREMIUM LUXURY GOLD
import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Premium Metallic Gold Effect dengan Multiple Variations
/// 
/// Features:
/// - Static gold (battery friendly)
/// - Animated shimmer (for special elements)
/// - Multiple intensity levels
/// - Luxury gradient from Shutterstock palette
class MetallicGold extends StatelessWidget {
  final Widget child;
  final bool isLightMode;
  final bool animate;
  final double intensity;
  
  const MetallicGold({
    Key? key,
    required this.child,
    this.isLightMode = false,
    this.animate = false,
    this.intensity = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (animate) {
      return _AnimatedMetallicGold(
        intensity: intensity,
        child: child,
      );
    }
    
    return ShaderMask(
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: _getGoldColors(intensity),
          stops: const [
            0.0,
            0.25,
            0.5,
            0.75,
            1.0,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.srcIn,
      child: child,
    );
  }
  
  List<Color> _getGoldColors(double intensity) {
    if (intensity >= 1.0) {
      // Full intensity - Pure luxury gold
      return const [
        Color(0xFF996900), // Dark olive gold
        Color(0xFFFFDE62), // Bright gold
        Color(0xFFFFF5C2), // White pearl highlight
        Color(0xFF8A500E), // Deep rich gold
        Color(0xFF521D00), // Dark brown shadow
      ];
    } else if (intensity >= 0.7) {
      // Medium intensity - Softer gold
      return const [
        Color(0xFFB8860B), // Softer dark gold
        Color(0xFFFFD700), // Pure gold
        Color(0xFFFFE55C), // Light gold
        Color(0xFFC5A059), // Medium gold
        Color(0xFF8B7355), // Softer shadow
      ];
    } else {
      // Low intensity - Subtle gold
      return const [
        Color(0xFFC5A059),
        Color(0xFFD4AF37),
        Color(0xFFFFE55C),
        Color(0xFFD4AF37),
        Color(0xFFC5A059),
      ];
    }
  }
}

/// Animated version untuk special elements
class _AnimatedMetallicGold extends StatefulWidget {
  final Widget child;
  final double intensity;
  
  const _AnimatedMetallicGold({
    required this.child,
    required this.intensity,
  });

  @override
  State<_AnimatedMetallicGold> createState() => _AnimatedMetallicGoldState();
}

class _AnimatedMetallicGoldState extends State<_AnimatedMetallicGold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF996900),
                Color(0xFFFFDE62),
                Color(0xFFFFF5C2),
                Color(0xFFFFDE62),
                Color(0xFF996900),
              ],
              stops: [
                0.0,
                0.4 + (_controller.value * 0.2),
                0.5 + (_controller.value * 0.2),
                0.6 + (_controller.value * 0.2),
                1.0,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: widget.child,
        );
      },
    );
  }
}

/// Static version (backward compatibility)
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

/// Extension untuk easy usage
extension MetallicGoldExtension on Widget {
  Widget withMetallicGold({
    bool animate = false,
    double intensity = 1.0,
  }) {
    return MetallicGold(
      animate: animate,
      intensity: intensity,
      child: this,
    );
  }
}
