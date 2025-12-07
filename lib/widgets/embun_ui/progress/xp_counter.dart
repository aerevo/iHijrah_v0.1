
// lib/widgets/embun_ui/progress/xp_counter.dart

import 'package:flutter/material.dart';
import '../../../utils/constants.dart';

/// XP Counter - Angka XP yang terbang naik
class XPCounter extends StatefulWidget {
  final int value;
  final String prefix;
  
  const XPCounter({
    Key? key,
    required this.value,
    this.prefix = '+',
  }) : super(key: key);
  
  @override
  State<XPCounter> createState() => _XPCounterState();
}

class _XPCounterState extends State<XPCounter> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, -3),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _fadeAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.3, curve: Curves.elasticOut),
      ),
    );
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [kPrimaryGold, kGoldDark],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: kPrimaryGold.withOpacity(0.5),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              '${widget.prefix}${widget.value} XP',
              style: const TextStyle(
                color: kBackgroundDark,
                fontWeight: FontWeight.bold,
                fontSize: AppFontSizes.lg,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
