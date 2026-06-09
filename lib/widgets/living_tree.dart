// lib/widgets/living_tree.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../utils/constants.dart';

class LivingTree extends StatefulWidget {
  final String assetPath;
  final double height;
  final VoidCallback? onTap;

  const LivingTree({
    Key? key,
    required this.assetPath,
    this.height = 320,
    this.onTap,
  }) : super(key: key);

  @override
  State<LivingTree> createState() => _LivingTreeState();
}

class _LivingTreeState extends State<LivingTree> {
  VideoPlayerController? _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void didUpdateWidget(LivingTree old) {
    super.didUpdateWidget(old);
    if (old.assetPath != widget.assetPath) {
      _dispose();
      _init();
    }
  }

  Future<void> _init() async {
    _ctrl = VideoPlayerController.asset(widget.assetPath);
    try {
      await _ctrl!.initialize();
      await _ctrl!.setLooping(true);
      await _ctrl!.setVolume(0.0);
      await _ctrl!.play();
      if (mounted) setState(() => _ready = true);
    } catch (e) {
      debugPrint('LivingTree: gagal memuatkan ${widget.assetPath}');
    }
  }

  void _dispose() {
    _ctrl?.pause();
    _ctrl?.dispose();
    _ctrl = null;
    _ready = false;
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resume bila widget dilukis semula
    if (_ready && _ctrl != null && !_ctrl!.value.isPlaying) {
      _ctrl!.play();
    }

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Aura emas belakang
          if (_ready)
            Container(
              margin: EdgeInsets.only(bottom: widget.height * 0.1),
              width:  widget.height * 0.7,
              height: widget.height * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kPrimaryGold.withOpacity(0.15),
                    Colors.transparent,
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),

          // Video / loading
          SizedBox(
            height: widget.height,
            child: _ready
                ? AspectRatio(
                    aspectRatio: _ctrl!.value.aspectRatio,
                    child: VideoPlayer(_ctrl!),
                  )
                : const Center(
                    child: SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: kPrimaryGold),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
