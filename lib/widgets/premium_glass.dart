// lib/widgets/premium_glass.dart
//
// Reusable glass surface. Every "glass" element in the app
// (badges, bookmark buttons, menus, drawers, bottom sheets)
// must go through this widget instead of a hand-rolled
// Container(color: Colors.black.withOpacity(...)) — that is
// an opacity hack, not real glass.
//
// Radius reuses AppSizes.cardRadius / cardRadiusLg / cardRadiusXl
// (already in constants.dart) so there's one radius scale for the
// whole app, not a separate one just for glass.

import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/constants.dart';

enum GlassLevel { badge, panel, sheet }

class PremiumGlass extends StatelessWidget {
  final Widget child;
  final GlassLevel level;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  /// Base tint. White for a neutral/light glass; pass Colors.black
  /// for the dark overlay look used over photos (current feed style).
  final Color tint;

  /// Override the level's default opacity. Use sparingly — e.g. a
  /// small bookmark chip on a light background needs to read closer
  /// to solid (0.8+) to stay legible, unlike a badge floating on a
  /// busy photo which wants to stay subtle (0.18).
  final double? opacity;

  const PremiumGlass({
    Key? key,
    required this.child,
    this.level = GlassLevel.panel,
    this.borderRadius,
    this.padding,
    this.tint = Colors.black,
    this.opacity,
  }) : super(key: key);

  double get _blur {
    switch (level) {
      case GlassLevel.badge: return AppBlur.level1;
      case GlassLevel.panel: return AppBlur.level2;
      case GlassLevel.sheet: return AppBlur.level3;
    }
  }

  double get _opacity {
    if (opacity != null) return opacity!;
    switch (level) {
      case GlassLevel.badge: return 0.18;
      case GlassLevel.panel: return 0.25;
      case GlassLevel.sheet: return 0.30;
    }
  }

  BorderRadius get _radius {
    if (borderRadius != null) return borderRadius!;
    switch (level) {
      case GlassLevel.badge:
        return BorderRadius.circular(AppSizes.cardRadius);
      case GlassLevel.panel:
        return BorderRadius.circular(AppSizes.cardRadiusLg);
      case GlassLevel.sheet:
        return BorderRadius.only(
          topLeft: Radius.circular(AppSizes.cardRadiusXl),
          topRight: Radius.circular(AppSizes.cardRadiusXl),
        );
    }
  }

  List<BoxShadow> get _shadow => level == GlassLevel.sheet
      ? [BoxShadow(color: Colors.black.withOpacity(0.28), blurRadius: 24, offset: const Offset(0, 12))]
      : kFeedCardShadows();

  @override
  Widget build(BuildContext context) {
    // RepaintBoundary isolates the expensive BackdropFilter so it
    // doesn't force repaints on unrelated parts of the feed.
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(borderRadius: _radius, boxShadow: _shadow),
        child: ClipRRect(
          borderRadius: _radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: tint.withOpacity(_opacity),
                borderRadius: _radius,
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: AppStroke.hairline,
                ),
              ),
              child: Stack(
                children: [
                  // Top highlight — simulates light catching the glass edge.
                  Positioned(
                    top: 0, left: 0, right: 0, height: 1,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.white.withOpacity(0.5), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  // Inner glow — soft lift near the top-left corner.
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: _radius,
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 1.2,
                          colors: [Colors.white.withOpacity(0.08), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
