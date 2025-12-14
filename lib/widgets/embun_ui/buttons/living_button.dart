// lib/widgets/embun_ui/buttons/living_button.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../utils/constants.dart';

/// Living Button - Button dengan personality
class LivingButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final bool enabled;
  
  const LivingButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
    this.padding,
    this.enabled = true,
  }) : super(key: key);
  
  @override
  State<LivingButton> createState() => _LivingButtonState();
}

class _LivingButtonState extends State<LivingButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    final bgColor = widget.backgroundColor ?? kPrimaryGold;
    final fgColor = widget.foregroundColor ?? kBackgroundDark;
    
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _isPressed = true) : null,
      onTapUp: widget.enabled ? (_) {
        setState(() => _isPressed = false);
        HapticFeedback.mediumImpact();
        widget.onPressed();
      } : null,
      onTapCancel: () => setState(() => _isPressed = false),
      
      child: AnimatedContainer(
        duration: AppDurations.buttonPress,
        curve: Curves.easeOut,
        
        transform: Matrix4.identity()..scale(_isPressed ? 0.95 : 1.0),
        
        width: widget.width,
        height: widget.height,
        padding: widget.padding ?? const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        
        decoration: BoxDecoration(
          color: widget.enabled ? bgColor : Colors.grey.shade700,
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
          boxShadow: widget.enabled ? [
            BoxShadow(
              color: bgColor.withOpacity(_isPressed ? 0.3 : 0.6),
              blurRadius: _isPressed ? 10 : 20,
              spreadRadius: _isPressed ? 2 : 5,
              offset: Offset(0, _isPressed ? 2 : 4),
            ),
          ] : [],
        ),
        
        child: DefaultTextStyle(
          style: TextStyle(
            color: fgColor,
            fontWeight: FontWeight.bold,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

/// Living Icon Button
class LivingIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  
  const LivingIconButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    this.iconColor,
    this.backgroundColor,
    this.size = 48,
  }) : super(key: key);
  
  @override
  State<LivingIconButton> createState() => _LivingIconButtonState();
}

class _LivingIconButtonState extends State<LivingIconButton> {
  bool _isPressed = false;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        HapticFeedback.lightImpact();
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      
      child: AnimatedContainer(
        duration: AppDurations.buttonPress,
        transform: Matrix4.identity()..scale(_isPressed ? 0.9 : 1.0),
        
        width: widget.size,
        height: widget.size,
        
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? kPrimaryGold.withOpacity(0.1),
          shape: BoxShape.circle,
          boxShadow: _isPressed ? [] : [
            BoxShadow(
              color: (widget.iconColor ?? kPrimaryGold).withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        
        child: Icon(
          widget.icon,
          color: widget.iconColor ?? kPrimaryGold,
          size: widget.size * 0.5,
        ),
      ),
    );
  }
}