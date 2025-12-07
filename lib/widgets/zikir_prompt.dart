// lib/widgets/zikir_prompt.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../utils/audio_service.dart';
import '../models/animation_controller_model.dart';

class ZikirPrompt extends StatefulWidget {
  final bool zikirDone;
  final VoidCallback onDone;

  const ZikirPrompt({Key? key, required this.zikirDone, required this.onDone}) : super(key: key);

  @override
  State<ZikirPrompt> createState() => _ZikirPromptState();
}

class _ZikirPromptState extends State<ZikirPrompt> with SingleTickerProviderStateMixin {
  bool _isDismissed = false;
  late AnimationController _enterController;

  @override
  void initState() {
    super.initState();
    // Animasi Masuk: SlideUp + FadeIn
    _enterController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    
    if (!widget.zikirDone) {
      // Mainkan audio prompt jika belum zikir
      WidgetsBinding.instance.addPostFrameCallback((_) {
         Provider.of<AudioService>(context, listen: false).playZikirPrompt();
      });
      _enterController.forward();
    }
  }

  @override
  void dispose() {
    _enterController.dispose();
    super.dispose();
  }

  void _handleDone() {
    HapticFeedback.mediumImpact();
    Provider.of<AudioService>(context, listen: false).playAlhamdulillah();
    Provider.of<AnimationControllerModel>(context, listen: false).triggerParticleSpray();
    widget.onDone();
  }

  void _handleBelum() {
    HapticFeedback.selectionClick();
    Provider.of<AudioService>(context, listen: false).playInsyaallah();
    setState(() => _isDismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.zikirDone || _isDismissed) return const SizedBox.shrink();

    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic)
      ),
      child: FadeTransition(
        opacity: _enterController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH, vertical: AppSpacing.screenV),
          child: Container(
            decoration: BoxDecoration(
              color: kCardDark, 
              borderRadius: BorderRadius.circular(AppSizes.cardRadiusXl),
              border: Border.all(color: kPrimaryGold.withOpacity(0.15)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Assalamualaikum,\nDah zikir pagi/petang hari ni?',
                  style: TextStyle(
                    color: kTextPrimary, 
                    fontSize: AppFontSizes.lg, 
                    height: 1.5, 
                    fontFamily: 'Playfair'
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _handleBelum,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14)
                        ),
                        child: const Text('Nanti Sekejap', style: TextStyle(color: kTextSecondary)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleDone,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGold,
                          foregroundColor: kBackgroundDark,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                        ),
                        child: const Text('SUDAH', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
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