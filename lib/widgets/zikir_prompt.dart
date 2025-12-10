import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/constants.dart';
import '../utils/audio_service.dart';
import 'metallic_gold.dart'; 
import 'embun_ui/embun_ui.dart'; 

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

class _ZikirPromptState extends State<ZikirPrompt> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _isProcessing = false;
  
  // Variable untuk simpan teks soalan
  late String _dailyQuestion;
  late String _dailyDeedName;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    
    // TENTUKAN SOALAN BERDASARKAN HARI
    _determineDailyQuestion();

    // Animate Masuk
    _controller.forward();

    // Audio Trigger
    if (!widget.zikirDone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<AudioService>(context, listen: false).playZikirPrompt();
      });
    }
  }

  void _determineDailyQuestion() {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Isnin, 7 = Ahad

    if (weekday == DateTime.friday) {
      _dailyQuestion = "Salam Jumaat Kapten,\nDah baca Al-Kahfi hari ini?";
      _dailyDeedName = "Al-Kahfi";
    } else if (weekday == DateTime.monday || weekday == DateTime.thursday) {
      _dailyQuestion = "Hari Sunnah ni Kapten,\nAda puasa sunat tak hari ni?";
      _dailyDeedName = "Puasa Sunat";
    } else {
      _dailyQuestion = "Assalamualaikum Kapten,\nDah selawat ke belum hari ni?";
      _dailyDeedName = "Selawat";
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleBelum() {
    if (_isProcessing) return;
    Provider.of<AudioService>(context, listen: false).playInsyaallah();
  }

  Future<void> _handleSudah() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final audioService = Provider.of<AudioService>(context, listen: false);

    // 1. Audio Alhamdulillah
    await audioService.playAlhamdulillah();

    // 2. Jeda
    await Future.delayed(const Duration(milliseconds: 1500));

    // 3. Audio Siraman & Visual
    audioService.playSiraman();
    widget.onDone(); // Hantar signal selesai
  }

  @override
  Widget build(BuildContext context) {
    if (widget.zikirDone) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kSuccessGreen.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: kSuccessGreen),
            const SizedBox(width: 10),
            Text(
              "Misi $_dailyDeedName Selesai. Alhamdulillah!",
              style: const TextStyle(color: kSuccessGreen, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ScaleTransition(
      scale: _scaleAnim,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kCardDark.withOpacity(0.8),
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg),
          border: Border.all(color: kPrimaryGold.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: kPrimaryGold.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 1,
            )
          ],
        ),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.black,
              backgroundImage: AssetImage('assets/images/logo.png'), 
            ),
            const SizedBox(height: 15),

            // SOALAN DINAMIK
            MetallicGold(
              child: Text(
                _dailyQuestion, // Teks berubah ikut hari
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: CelebrationButton(
                    onPressed: _handleBelum,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    child: const Text("Belum..", style: TextStyle(color: Colors.white70)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: CelebrationButton(
                    onPressed: _handleSudah,
                    backgroundColor: kPrimaryGold,
                    child: _isProcessing 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                      : const Text("Sudah!", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}