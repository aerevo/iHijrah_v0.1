// lib/widgets/embun_spirit_aaa.dart (AAA PREMIUM - SOPHISTICATED)

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

enum SpiritState {
  serene,      // Calm, peaceful (default)
  radiant,     // Glowing, happy (good progress)
  concerned,   // Dimmed, worried (missed prayers)
  euphoric,    // Brilliant (level up)
}

class EmbunSpiritAAA extends StatefulWidget {
  const EmbunSpiritAAA({Key? key}) : super(key: key);

  @override
  State<EmbunSpiritAAA> createState() => _EmbunSpiritAAAState();
}

class _EmbunSpiritAAAState extends State<EmbunSpiritAAA> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;

  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;

  bool _isInteracting = false;

  @override
  void initState() {
    super.initState();

    // Float animation (up/down)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Pulse animation (size)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Rotation (slow)
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_rotateController);
  }

  @override
  void dispose() {
    _floatController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  SpiritState _getSpiritState(UserModel user) {
    final progress = user.progressPercentage;
    final fardhuDone = user.fardhuCompletedToday;

    if (progress > 0.9) return SpiritState.euphoric;
    if (fardhuDone >= 3) return SpiritState.radiant;
    if (fardhuDone == 0) return SpiritState.concerned;
    return SpiritState.serene;
  }

  Color _getStateColor(SpiritState state) {
    switch (state) {
      case SpiritState.serene:
        return const Color(0xFF4DD0E1); // Cyan
      case SpiritState.radiant:
        return kPrimaryGold;
      case SpiritState.concerned:
        return const Color(0xFF7986CB); // Muted blue
      case SpiritState.euphoric:
        return const Color(0xFFFFD700); // Bright gold
    }
  }

  void _handleInteraction() {
    if (_isInteracting) return;

    setState(() => _isInteracting = true);
    HapticFeedback.lightImpact();

    final user = Provider.of<UserModel>(context, listen: false);
    final state = _getSpiritState(user);

    _showSpiritMessage(state, user);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _isInteracting = false);
    });
  }

  void _showSpiritMessage(SpiritState state, UserModel user) {
    String message = _getMessage(state, user);
    String title = _getTitle(state);

    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getStateColor(state).withOpacity(0.15),
                kCardDark.withOpacity(0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _getStateColor(state).withOpacity(0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _getStateColor(state).withOpacity(0.3),
                blurRadius: 40,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spirit orb (mini)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white,
                      _getStateColor(state),
                      _getStateColor(state).withOpacity(0.3),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getStateColor(state).withOpacity(0.6),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Title
              Text(
                title,
                style: TextStyle(
                  color: _getStateColor(state),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Playfair',
                ),
              ),

              const SizedBox(height: 16),

              // Message
              Text(
                message,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 15,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    backgroundColor: _getStateColor(state).withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _getStateColor(state).withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: Text(
                    'Terima kasih',
                    style: TextStyle(
                      color: _getStateColor(state),
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTitle(SpiritState state) {
    switch (state) {
      case SpiritState.serene:
        return 'Assalamualaikum';
      case SpiritState.radiant:
        return 'MasyaAllah';
      case SpiritState.concerned:
        return 'Peringatan Lembut';
      case SpiritState.euphoric:
        return 'Alhamdulillah!';
    }
  }

  String _getMessage(SpiritState state, UserModel user) {
    switch (state) {
      case SpiritState.serene:
        return 'Perjalanan hijrah adalah marathon, bukan sprint. Teruskan dengan tenang dan penuh barakah.';

      case SpiritState.radiant:
        return 'Anda telah melaksanakan ${user.fardhuCompletedToday} solat hari ini. Cahaya iman anda bersinar terang!';

      case SpiritState.concerned:
        return 'Waktu solat menanti. Jangan biarkan dunia memadam cahaya roh anda. Mari kembali ke jalan yang terang.';

      case SpiritState.euphoric:
        return 'SubhanaAllah! Anda hampir mencapai level baharu! ${user.nextLevelPoints - user.totalPoints} XP lagi. Istiqamah anda sungguh membanggakan!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, _) {
        final state = _getSpiritState(user);
        final stateColor = _getStateColor(state);

        return GestureDetector(
          onTap: _handleInteraction,
          child: AnimatedBuilder(
            animation: Listenable.merge([
              _floatController,
              _pulseController,
              _rotateController,
            ]),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Transform.scale(
                  scale: _pulseAnimation.value * (_isInteracting ? 1.1 : 1.0),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer glow rings (rotating)
                        Transform.rotate(
                          angle: _rotateAnimation.value,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: stateColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                        ),

                        Transform.rotate(
                          angle: -_rotateAnimation.value * 0.7,
                          child: Container(
                            width: 75,
                            height: 75,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: stateColor.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                          ),
                        ),

                        // Core orb
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.white,
                                stateColor.withOpacity(0.9),
                                stateColor.withOpacity(0.6),
                                stateColor.withOpacity(0.3),
                              ],
                              stops: const [0.0, 0.3, 0.6, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: stateColor.withOpacity(0.6),
                                blurRadius: 25,
                                spreadRadius: 5,
                              ),
                              BoxShadow(
                                color: stateColor.withOpacity(0.3),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        // Inner shimmer (rotating slowly)
                        Transform.rotate(
                          angle: _rotateAnimation.value * 0.5,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.6),
                                  Colors.transparent,
                                  stateColor.withOpacity(0.3),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Tap hint (subtle)
                        Positioned(
                          bottom: -20,
                          child: Opacity(
                            opacity: 0.4,
                            child: Text(
                              'Tap',
                              style: TextStyle(
                                color: stateColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
