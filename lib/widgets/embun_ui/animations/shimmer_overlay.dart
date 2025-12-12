// lib/widgets/embun_ui/animations/shimmer_overlay.dart

import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

/// Shimmer Overlay - Cahaya bergerak
class ShimmerOverlay extends StatefulWidget {
  final Widget child;
  final Duration duration;
  
  const ShimmerOverlay({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
  }) : super(key: key);
  
  @override
  State<ShimmerOverlay> createState() => _ShimmerOverlayState();
}

class _ShimmerOverlayState extends State<ShimmerOverlay> 
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
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Colors.transparent,
                Colors.white24,
                Colors.white54,
                Colors.white24,
                Colors.transparent,
              ],
              stops: [
                0.0,
                0.45 + (_controller.value * 0.1),
                0.5 + (_controller.value * 0.1),
                0.55 + (_controller.value * 0.1),
                1.0,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}