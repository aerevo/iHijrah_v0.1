// lib/widgets/shimmer_effect.dart (UPGRADED 7.8/10)

import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Shimmer loading effect untuk skeleton screens
/// 
/// Guna untuk loading states, locked features, etc
class ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const ShimmerEffect({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
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
        // Move gradient from left to right (-1.0 to 2.0)
        final value = _controller.value * 3 - 1.0;

        return ShaderMask(
          shaderCallback: (bounds) {
            return kShimmerGoldGradient.createShader(
              Rect.fromLTWH(
                bounds.width * value,
                0,
                bounds.width,
                bounds.height,
              ),
            );
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}