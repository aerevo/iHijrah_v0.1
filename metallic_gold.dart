import 'package:flutter/material.dart';
import '../utils/constants.dart';

class MetallicGold extends StatefulWidget {
  final Widget child;
  final bool isShimmering;

  const MetallicGold({
    Key? key,
    required this.child,
    this.isShimmering = true,
  }) : super(key: key);

  @override
  State<MetallicGold> createState() => _MetallicGoldState();
}

class _MetallicGoldState extends State<MetallicGold> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4), // Slow luxury shimmer
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isShimmering) {
      return ShaderMask(
        shaderCallback: (bounds) => kGoldLinear.createShader(bounds),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: const [
                Color(0xFFBF953F),
                Color(0xFFFCF6BA),
                Color(0xFFBF953F),
                Color(0xFFAA771C),
                Color(0xFFFCF6BA),
              ],
              stops: [
                0.0,
                0.3 + (0.4 * _controller.value) - 0.2,
                0.5 + (0.4 * _controller.value) - 0.2,
                0.7 + (0.4 * _controller.value) - 0.2,
                1.0,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              tileMode: TileMode.mirror,
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}