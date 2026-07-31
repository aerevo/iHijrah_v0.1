// lib/widgets/tree_of_life_logo.dart
// Lambang "Pokok Hayat" v3 — guna artwork sebenar (assets/images/pokok_intro.png)
// dijana oleh AI image generator, bukan lagi dilukis procedural guna math.
// Kod di sini HANYA uruskan animasi/gerakan di atas gambar statik tu:
//
//   0.00–0.15  glow lembut muncul di belakang
//   0.05–0.85  gambar "tumbuh" — reveal dari bawah (akar) ke atas (kanopi),
//              tepi lembut (soft-edge wipe), bukan garis potong tajam
//   0.75–0.95  satu kilauan emas menyapu (shimmer) melintasi pokok
// Selepas siap (animated:true) — goyangan angin lembut berterusan +
// kilauan berulang setiap ~6 saat, macam idle premium.
//
// animated:false -> versi pantas (600ms fade, tiada wipe/loop), sesuai utk
// rel/tempat kekal (sidebar) supaya tak ganggu & tak berat.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/constants.dart';

class TreeOfLifeLogo extends StatefulWidget {
  final double size;
  final bool animated;
  const TreeOfLifeLogo({Key? key, this.size = 84, this.animated = true})
      : super(key: key);

  @override
  State<TreeOfLifeLogo> createState() => _TreeOfLifeLogoState();
}

class _TreeOfLifeLogoState extends State<TreeOfLifeLogo>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;
  AnimationController? _loop;

  static const String _asset = 'assets/images/pokok_intro.png';

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: widget.animated
          ? const Duration(milliseconds: 2600)
          : const Duration(milliseconds: 600),
    )..forward();

    if (widget.animated) {
      _loop = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 6),
      );
      _entrance.addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _loop?.repeat();
        }
      });
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _loop?.dispose();
    super.dispose();
  }

  static double _win(double t, double a, double b) {
    if (b <= a) return t >= a ? 1.0 : 0.0;
    return ((t - a) / (b - a)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final Listenable merged =
        _loop != null ? Listenable.merge([_entrance, _loop]) : _entrance;

    return AnimatedBuilder(
      animation: merged,
      builder: (context, _) {
        final double introT = _entrance.value;
        final double loopT = _loop?.value ?? 0.0;
        final double swayPhase = loopT * 2 * math.pi;

        final double glowT = _win(introT, 0.0, 0.20);
        final double revealT = _win(introT, 0.05, 0.85);
        final double fadeT = _win(introT, 0.0, 0.10);

        // Kilauan: sekali semasa intro, kemudian berulang tiap kitaran loop
        double shimmerT = -1;
        if (introT < 1.0) {
          if (introT >= 0.78) shimmerT = ((introT - 0.78) / 0.20).clamp(0.0, 1.0);
        } else if (_loop != null) {
          final double lp = loopT % 1.0;
          if (lp < 0.15) shimmerT = lp / 0.15;
        }

        // Goyangan angin lembut selepas intro siap
        final double swayGate = _win(introT, 0.85, 1.0);
        final double swayAngle =
            (_loop != null ? math.sin(swayPhase) : 0.0) * 0.028 * swayGate;

        return Opacity(
          opacity: fadeT,
          child: SizedBox(
            width: widget.size,
            height: widget.size,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // ── Glow lembut di belakang ──
                Container(
                  width: widget.size * 1.25,
                  height: widget.size * 1.25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        kPrimaryGold.withOpacity(0.20 * glowT),
                        kPrimaryGold.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),

                // ── Pokok (goyang dari pangkal) ──
                Transform.rotate(
                  angle: swayAngle,
                  alignment: const Alignment(0, 0.92),
                  child: _RevealingTree(
                    asset: _asset,
                    revealT: revealT,
                    shimmerT: shimmerT,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Melukis gambar pokok dgn 2 lapisan:
///  1. gambar asal, di-"reveal" dari bawah ke atas (tepi lembut)
///  2. kilauan putih yang mengikut bentuk siluet pokok sahaja (bukan segi
///     empat penuh) — guna gambar sama sbg mask supaya kilauan tak terkeluar
///     dari bentuk pokok.
class _RevealingTree extends StatelessWidget {
  final String asset;
  final double revealT; // 0..1
  final double shimmerT; // -1..1, -1 = jangan lukis

  const _RevealingTree({
    required this.asset,
    required this.revealT,
    required this.shimmerT,
  });

  @override
  Widget build(BuildContext context) {
    final Widget base = Image.asset(asset, fit: BoxFit.contain);

    // Reveal bawah->atas dgn tepi lembut (bukan garis potong tajam)
    final double edge = 1.0 - revealT;
    final Widget revealed = ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Colors.transparent,
          Colors.transparent,
          Colors.white,
          Colors.white,
        ],
        stops: [
          0.0,
          edge.clamp(0.0, 1.0),
          (edge + 0.14).clamp(0.0, 1.0),
          1.0,
        ],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: base,
    );

    if (shimmerT < 0) return revealed;

    // Jalur kilauan diagonal, dibentuk ikut siluet pokok (guna gambar yg
    // sama sbg silhouette putih, kemudian ditapis ikut jalur sweep)
    final double sweep = -0.3 + shimmerT * 1.6; // -0.3..1.3 merentasi bounds
    final double fade = (1 - (shimmerT - 0.5).abs() * 2).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.passthrough,
      children: [
        revealed,
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.85 * fade),
              Colors.white.withOpacity(0.0),
            ],
            stops: [
              (sweep - 0.16).clamp(0.0, 1.0),
              sweep.clamp(0.0, 1.0),
              (sweep + 0.16).clamp(0.0, 1.0),
            ],
          ).createShader(bounds),
          blendMode: BlendMode.dstIn,
          child: ColorFiltered(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            child: base,
          ),
        ),
      ],
    );
  }
}
