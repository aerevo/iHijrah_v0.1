
// lib/widgets/embun_ui/buttons/celebration_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/constants.dart';

/// Celebration Button - Auto-trigger particles bila tekan
class CelebrationButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  
  const CelebrationButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);
  
  @override
  State<CelebrationButton> createState() => _CelebrationButtonState();
}

class _CelebrationButtonState extends State<CelebrationButton> 
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _celebrationController;
  
  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }
  
  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }
  
  void _handlePress() {
    setState(() => _isPressed = true);
    
    HapticFeedback.heavyImpact();
    _celebrationController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isPressed = false);
    });
    
    widget.onPressed();
  }
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Particles
        if (_celebrationController.isAnimating)
          ..._buildParticles(),
        
        // Button
        GestureDetector(
          onTap: _handlePress,
          child: AnimatedContainer(
            duration: AppDurations.buttonPress,
            transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
            
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  widget.backgroundColor ?? kPrimaryGold,
                  (widget.backgroundColor ?? kPrimaryGold).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: (widget.backgroundColor ?? kPrimaryGold).withOpacity(0.5),
                  blurRadius: _isPressed ? 10 : 20,
                  spreadRadius: _isPressed ? 2 : 5,
                ),
              ],
            ),
            
            child: DefaultTextStyle(
              style: const TextStyle(
                color: kBackgroundDark,
                fontWeight: FontWeight.bold,
              ),
              child: Center(child: widget.child),
            ),
          ),
        ),
      ],
    );
  }
  
  List<Widget> _buildParticles() {
    return List.generate(8, (index) {
      final angle = (index * 45) * 3.14159 / 180;
      
      return AnimatedBuilder(
        animation: _celebrationController,
        builder: (context, child) {
          return Positioned(
            left: _celebrationController.value * 60 * (index % 2 == 0 ? 1 : -1),
            top: _celebrationController.value * 60 * (index < 4 ? -1 : 1),
            child: Opacity(
              opacity: 1 - _celebrationController.value,
              child: Icon(
                Icons.star,
                color: kPrimaryGold,
                size: 20 * (1 - _celebrationController.value * 0.5),
              ),
            ),
          );
        },
      );
    });
  }
}
