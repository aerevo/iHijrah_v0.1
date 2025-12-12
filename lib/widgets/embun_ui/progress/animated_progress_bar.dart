// lib/widgets/embun_ui/progress/animated_progress_bar.dart

import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

/// Animated Progress Bar dengan shimmer
class AnimatedProgressBar extends StatefulWidget {
  final double progress; // 0.0 to 1.0
  final double height;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showShimmer;
  
  const AnimatedProgressBar({
    Key? key,
    required this.progress,
    this.height = 12,
    this.backgroundColor,
    this.foregroundColor,
    this.showShimmer = true,
  }) : super(key: key);
  
  @override
  State<AnimatedProgressBar> createState() => _AnimatedProgressBarState();
}

class _AnimatedProgressBarState extends State<AnimatedProgressBar> 
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  
  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }
  
  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? kCardDark,
        borderRadius: BorderRadius.circular(widget.height / 2),
        border: Border.all(color: Colors.white10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.height / 2),
        child: Stack(
          children: [
            // Progress fill
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: widget.progress.clamp(0.0, 1.0)),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.foregroundColor ?? kPrimaryGold,
                          (widget.foregroundColor ?? kPrimaryGold).withOpacity(0.7),
                        ],
                      ),
                      boxShadow: value > 0.8 ? [
                        BoxShadow(
                          color: (widget.foregroundColor ?? kPrimaryGold).withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ] : [],
                    ),
                  ),
                );
              },
            ),
            
            // Shimmer overlay
            if (widget.showShimmer && widget.progress > 0)
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: widget.progress,
                    child: ShaderMask(
                      shaderCallback: (bounds) {
                        return LinearGradient(
                          colors: const [
                            Colors.transparent,
                            Colors.white38,
                            Colors.transparent,
                          ],
                          stops: [
                            _shimmerController.value - 0.3,
                            _shimmerController.value,
                            _shimmerController.value + 0.3,
                          ],
                        ).createShader(bounds);
                      },
                      child: Container(color: Colors.white),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}