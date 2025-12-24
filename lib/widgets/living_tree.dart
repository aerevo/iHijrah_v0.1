import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../utils/constants.dart';

// ==========================================================
// 🎥 ENJIN VIDEO POKOK (EDISI KHAS KAPTEN AER)
// ==========================================================

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
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void didUpdateWidget(LivingTree oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika pokok bertukar level, tukar video
    if (oldWidget.assetPath != widget.assetPath) {
      _disposeVideo();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset(widget.assetPath);

    try {
      await _controller!.initialize();
      await _controller!.setLooping(true); // Ulang tanpa henti
      await _controller!.setVolume(0.0);   // Bisu
      await _controller!.play();           // Terus main

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("❌ Ralat Francois: Gagal memuatkan video ${widget.assetPath}: $e");
    }
  }

  void _disposeVideo() {
    _controller?.pause();
    _controller?.dispose();
    _controller = null;
    _isInitialized = false;
  }

  @override
  void dispose() {
    _disposeVideo();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // 1. AURA BELAKANG
          if (_isInitialized)
            Container(
              margin: EdgeInsets.only(bottom: widget.height * 0.1),
              width: widget.height * 0.7,
              height: widget.height * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    kPrimaryGold.withOpacity(0.15),
                    Colors.transparent
                  ],
                  stops: const [0.2, 1.0],
                ),
              ),
            ),

          // 2. PAPARAN VIDEO
          SizedBox(
            height: widget.height,
            child: _isInitialized
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : const Center(
                    child: SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(strokeWidth: 2, color: kPrimaryGold)
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
