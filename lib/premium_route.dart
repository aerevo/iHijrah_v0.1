// lib/utils/premium_route.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';

// Kelas helper untuk navigasi smooth
class PremiumRoute {
  static Route createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0); // Masuk dari kanan
        const end = Offset.zero;
        const curve = Curves.easeOutQuart; // Curve premium

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}