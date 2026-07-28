// lib/widgets/zikir_prompt.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/audio_service.dart';
import '../models/animation_controller_model.dart';

class ZikirPrompt extends StatefulWidget {
  final bool zikirDone;
  final VoidCallback onDone;

  const ZikirPrompt({
    Key? key,
    required this.zikirDone,
    required this.onDone,
  }) : super(key: key);

  @override
  State<ZikirPrompt> createState() => _ZikirPromptState();
}

class _ZikirPromptState extends State<ZikirPrompt>
    with SingleTickerProviderStateMixin {

  late AnimationController _ctrl;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    if (!widget.zikirDone) {
      _ctrl.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Provider.of<AudioService>(context, listen: false)
              .playZikirPrompt();
        }
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _done() {
    HapticFeedback.mediumImpact();
    Provider.of<AudioService>(context, listen: false).playAlhamdulillah();
    Provider.of<AnimationControllerModel>(context, listen: false)
        .triggerParticleSpray();
    widget.onDone();
  }

  void _later() {
    HapticFeedback.selectionClick();
    Provider.of<AudioService>(context, listen: false).playInsyaallah();
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.zikirDone || _dismissed) return const SizedBox.shrink();

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.25),
        end:   Offset.zero,
      ).animate(CurvedAnimation(
          parent: _ctrl, curve: Curves.easeOutCubic)),
      child: FadeTransition(
        opacity: _ctrl,
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenH,
              vertical:   AppSpacing.screenV),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: kCardDark,
              borderRadius:
                  BorderRadius.circular(AppSizes.cardRadiusXl),
              border: Border.all(
                  color: kPrimaryGold.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // Ikon embun
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kPrimaryGold.withOpacity(0.08),
                    border: Border.all(
                        color: kPrimaryGold.withOpacity(0.3),
                        width: 1.2),
                  ),
                  child: const Center(
                    child: Icon(Icons.water_drop_rounded,
                        color: kPrimaryGold, size: 26),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Assalamualaikum,',
                  style: TextStyle(
                    color: kPrimaryGold,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Dah zikir pagi/petang hari ni?',
                  style: GoogleFonts.playfairDisplay(
                    color: kTextPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const Text(
                  'Setiap zikir = +10 XP untuk pokok hijrah kamu',
                  style: TextStyle(
                    color: kTextSecondary,
                    fontSize: 11,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [

                    // Nanti
                    Expanded(
                      child: TextButton(
                        onPressed: _later,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSizes.cardRadius),
                            side: BorderSide(
                                color: kBorderSubtle),
                          ),
                        ),
                        child: const Text(
                          'InsyaAllah nanti',
                          style: TextStyle(
                              color: kTextSecondary, fontSize: 12),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Sudah
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _done,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGold,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                AppSizes.cardRadius),
                          ),
                        ),
                        child: const Text(
                          'ALHAMDULILLAH',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
