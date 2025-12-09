// lib/widgets/embun_mascot.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import 'package:provider/provider.dart';

enum EmbunMood {
  happy,      // User active today
  sleeping,   // User inactive
  excited,    // Level up / achievement
  worried,    // Missed prayers
  celebrating // Streak milestone
}

class EmbunMascot extends StatefulWidget {
  final double size;
  
  const EmbunMascot({Key? key, this.size = 120}) : super(key: key);

  @override
  State<EmbunMascot> createState() => _EmbunMascotState();
}

class _EmbunMascotState extends State<EmbunMascot> with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    
    // Floating animation (breathing effect)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  EmbunMood _getMood(UserModel user) {
    // Logic untuk tentukan mood
    if (user.totalPoints > user.nextLevelPoints * 0.8) {
      return EmbunMood.excited;
    }
    if (user.fardhuCompletedToday >= 3) {
      return EmbunMood.happy;
    }
    if (user.fardhuCompletedToday == 0) {
      return EmbunMood.worried;
    }
    return EmbunMood.happy;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, user, _) {
        final mood = _getMood(user);
        
        return GestureDetector(
          onTap: () => _showMascotDialog(context, mood, user),
          child: AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: widget.size,
              height: widget.size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  Container(
                    width: widget.size * 0.8,
                    height: widget.size * 0.8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: kPrimaryGold.withOpacity(mood == EmbunMood.excited ? 0.6 : 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  
                  // Body (simplified - guna CustomPaint untuk real mascot)
                  _buildMascotBody(mood),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMascotBody(EmbunMood mood) {
    return CustomPaint(
      size: Size(widget.size, widget.size),
      painter: EmbunPainter(mood: mood),
    );
  }

  void _showMascotDialog(BuildContext context, EmbunMood mood, UserModel user) {
    String message = _getMascotMessage(mood, user);
    
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: kCardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kPrimaryGold.withOpacity(0.3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Small mascot
              EmbunMascot(size: 80),
              const SizedBox(height: 16),
              
              // Speech bubble
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: kPrimaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: kTextPrimary,
                    fontSize: 16,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Close button
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Terima kasih, Embun!',
                  style: TextStyle(color: kPrimaryGold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMascotMessage(EmbunMood mood, UserModel user) {
    switch (mood) {
      case EmbunMood.happy:
        return "Alhamdulillah! Hari ni ${user.name} dah buat ${user.fardhuCompletedToday} solat. Teruskan! 💚";
      
      case EmbunMood.excited:
        return "MasyaAllah! Dah nak level up ni! Sikit je lagi, ${user.nextLevelPoints - user.totalPoints} XP! 🌟";
      
      case EmbunMood.worried:
        return "Assalamualaikum ${user.name}... Jom kita solat sama-sama? Embun tunggu ni... 🥺";
      
      case EmbunMood.celebrating:
        return "YEAY! ${user.name} LEVEL UP! Pokok makin cantik dah! 🎉";
      
      case EmbunMood.sleeping:
        return "Zzz... Embun rindu ${user.name} la... Mari kembali? 💤";
      
      default:
        return "Salam! Jom mulakan hari dengan penuh barakah! ✨";
    }
  }
}

// Simple painter (guna basic shapes dulu, later boleh guna assets)
class EmbunPainter extends CustomPainter {
  final EmbunMood mood;
  
  EmbunPainter({required this.mood});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4DD0E1), Color(0xFF00ACC1)], // Cyan water droplet
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Body (water droplet shape)
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    
    // Simple droplet (boleh polish later)
    path.moveTo(center.dx, size.height * 0.2);
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.4,
      size.width * 0.7, size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.8,
      center.dx, size.height * 0.85,
    );
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.8,
      size.width * 0.3, size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.3, size.height * 0.4,
      center.dx, size.height * 0.2,
    );
    
    canvas.drawPath(path, paint);

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black87;
    
    // Adjust eyes based on mood
    double eyeY = size.height * 0.45;
    if (mood == EmbunMood.sleeping) {
      // Closed eyes (lines)
      final linePaint = Paint()
        ..color = Colors.black87
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(
        Offset(size.width * 0.4, eyeY),
        Offset(size.width * 0.45, eyeY),
        linePaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.55, eyeY),
        Offset(size.width * 0.6, eyeY),
        linePaint,
      );
    } else {
      // Open eyes
      canvas.drawCircle(Offset(size.width * 0.42, eyeY), 8, eyePaint);
      canvas.drawCircle(Offset(size.width * 0.58, eyeY), 8, eyePaint);
      
      canvas.drawCircle(Offset(size.width * 0.42, eyeY), 4, pupilPaint);
      canvas.drawCircle(Offset(size.width * 0.58, eyeY), 4, pupilPaint);
    }

    // Mouth (varies by mood)
    final mouthPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final mouthPath = Path();
    double mouthY = size.height * 0.6;
    
    if (mood == EmbunMood.happy || mood == EmbunMood.excited || mood == EmbunMood.celebrating) {
      // Smile
      mouthPath.moveTo(size.width * 0.4, mouthY);
      mouthPath.quadraticBezierTo(
        center.dx, mouthY + 8,
        size.width * 0.6, mouthY,
      );
    } else if (mood == EmbunMood.worried) {
      // Worried mouth
      mouthPath.moveTo(size.width * 0.4, mouthY + 5);
      mouthPath.quadraticBezierTo(
        center.dx, mouthY - 3,
        size.width * 0.6, mouthY + 5,
      );
    }
    
    canvas.drawPath(mouthPath, mouthPaint);

    // Special effects for celebrating
    if (mood == EmbunMood.celebrating) {
      // Add sparkles
      final sparklePaint = Paint()..color = kPrimaryGold;
      canvas.drawCircle(Offset(size.width * 0.25, size.height * 0.3), 3, sparklePaint);
      canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.35), 3, sparklePaint);
      canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.6), 3, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}