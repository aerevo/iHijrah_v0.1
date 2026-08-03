// lib/widgets/anim_helpers.dart
// Kumpulan widget animasi kecil & guna semula — supaya feed card/panel/
// daily card tak nampak "kaku": entrance stagger, tap feedback, shimmer
// loading, pop-in badge/hati. Semua tanpa pakej luar (pure Flutter).

import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Fade + slide-up masuk skrin, dengan lengah ikut [index] supaya kad
/// muncul berturut-turut (stagger) bukan serentak. Sesuai untuk item dalam
/// ListView/GridView.builder — jalan sekali bila item kali pertama scroll
/// masuk viewport (natural stagger bila di-scroll, dan juga bila skrin
/// pertama kali buka sebab initState dipanggil ikut tertib binaan).
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration duration;
  final double slideOffset;
  const FadeSlideIn({
    Key? key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 420),
    this.slideOffset = 0.08,
  }) : super(key: key);

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));

    final int step = widget.index % 14; // reset lengah lepas 14 item supaya
    Future.delayed(Duration(milliseconds: 45 * step), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child),
      );
}

/// Skala masuk dari 0 -> 1 dengan lantunan halus (elasticOut) — sesuai
/// untuk badge/ikon kecil yang nak nampak "pop" bila muncul.
class PopScaleIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  const PopScaleIn({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 480),
  }) : super(key: key);

  @override
  State<PopScaleIn> createState() => _PopScaleInState();
}

class _PopScaleInState extends State<PopScaleIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ScaleTransition(scale: _scale, child: widget.child);
}

/// Bungkus mana-mana widget supaya ada maklum balas ketik: skala turun
/// halus (0.97x) bila ditekan, lantun balik bila lepas.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  const PressableScale({
    Key? key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
  }) : super(key: key);

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedScale(
          scale: _pressed ? widget.pressedScale : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      );
}

/// Kotak shimmer — placeholder sementara gambar loading, sapuan cahaya
/// bergerak berulang secara halus (guna semasa Image punya frameBuilder
/// masih null / belum decode).
class ShimmerBox extends StatefulWidget {
  final BorderRadius? borderRadius;
  const ShimmerBox({Key? key, this.borderRadius}) : super(key: key);

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final double t = _c.value;
          return ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.zero,
            child: Container(
              color: kBorderSubtle.withOpacity(0.35),
              child: ShaderMask(
                blendMode: BlendMode.srcATop,
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment(-1.6 + 3.2 * t, -0.4),
                  end: Alignment(-0.6 + 3.2 * t, 0.4),
                  colors: [
                    Colors.white.withOpacity(0.0),
                    kPrimaryGold.withOpacity(0.22),
                    Colors.white.withOpacity(0.0),
                  ],
                ).createShader(rect),
                child: Container(color: Colors.white.withOpacity(0.06)),
              ),
            ),
          );
        },
      );
}

/// Ikon hati yang "pop" (skala lantun + tukar warna) bila ditekan.
class PopLikeButton extends StatefulWidget {
  final bool initiallyLiked;
  final int baseCount;
  final double iconSize;
  final Color mutedColor;
  final Color likedColor;
  final TextStyle countStyle;
  const PopLikeButton({
    Key? key,
    this.initiallyLiked = false,
    required this.baseCount,
    required this.iconSize,
    required this.mutedColor,
    required this.likedColor,
    required this.countStyle,
  }) : super(key: key);

  @override
  State<PopLikeButton> createState() => _PopLikeButtonState();
}

class _PopLikeButtonState extends State<PopLikeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late bool _liked;

  @override
  void initState() {
    super.initState();
    _liked = widget.initiallyLiked;
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.45, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _liked = !_liked);
    _c.forward(from: 0);
  }

  String _fmtCount(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}k' : '$n';

  @override
  Widget build(BuildContext context) {
    final int count = widget.baseCount + (_liked ? 1 : 0);
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _scale,
            child: Icon(
              _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: widget.iconSize,
              color: _liked ? widget.likedColor : widget.mutedColor,
            ),
          ),
          const SizedBox(width: 2),
          Text(_fmtCount(count), style: widget.countStyle),
        ],
      ),
    );
  }
}

/// Ikon bookmark yang "pop" (skala lantun) bila ditekan — simpanan
/// PERIBADI (bukan kiraan awam macam like), jadi tiada Text count di
/// sisi, ikon sahaja. Pattern animasi sama macam PopLikeButton supaya
/// bahasa gerak (motion language) kekal konsisten seluruh app.
class PopBookmarkButton extends StatefulWidget {
  final bool initiallySaved;
  final double iconSize;
  final Color mutedColor;
  final Color savedColor;
  final VoidCallback? onToggle;
  const PopBookmarkButton({
    Key? key,
    this.initiallySaved = false,
    required this.iconSize,
    required this.mutedColor,
    required this.savedColor,
    this.onToggle,
  }) : super(key: key);

  @override
  State<PopBookmarkButton> createState() => _PopBookmarkButtonState();
}

class _PopBookmarkButtonState extends State<PopBookmarkButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late bool _saved;

  @override
  void initState() {
    super.initState();
    _saved = widget.initiallySaved;
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _saved = !_saved);
    _c.forward(from: 0);
    widget.onToggle?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scale,
        child: Icon(
          _saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
          size: widget.iconSize,
          color: _saved ? widget.savedColor : widget.mutedColor,
        ),
      ),
    );
  }
}
