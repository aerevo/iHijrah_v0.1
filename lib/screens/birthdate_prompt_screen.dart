// lib/screens/birthdate_prompt_screen.dart (BETUL)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import '../widgets/metallic_gold.dart';
import 'tracker_screen.dart';
import '../utils/premium_route.dart';

class BirthdatePrompt extends StatefulWidget {
  const BirthdatePrompt({Key? key}) : super(key: key);

  @override
  State<BirthdatePrompt> createState() => _BirthdatePromptState();
}

class _BirthdatePromptState extends State<BirthdatePrompt> {
  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kPrimaryGold,
              onPrimary: kBackgroundDark,
              surface: kCardDark,
              onSurface: kTextPrimary,
            ),
            dialogBackgroundColor: kCardDark,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submit() async {
    if (_selectedDate == null) return;

    setState(() => _isLoading = true);

    // 1. Simpan Tarikh Lahir (Masihi)
    final user = Provider.of<UserModel>(context, listen: false);
    user.setBirthDate(_selectedDate!);
    
    // Simulasikan loading sekejap untuk UX
    await Future.delayed(const Duration(milliseconds: 800));

    if (mounted) {
      Navigator.of(context).pushReplacement(PremiumRoute.createRoute(const TrackerScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MetallicGold(
              child: Icon(Icons.calendar_month_outlined, size: 60, color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.xl),
            
            const Text(
              "Bilakah Tarikh Lahir Anda?",
              style: TextStyle(
                color: kTextPrimary,
                fontSize: AppFontSizes.xl,
                fontWeight: FontWeight.bold,
                fontFamily: 'Playfair'
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              "Kami gunakan tarikh ini untuk mengira umur Hijrah dan membandingkan fasa hidup anda dengan Sirah Nabi SAW.",
              style: TextStyle(color: kTextSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // INPUT DISPLAY
            InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                decoration: BoxDecoration(
                  border: Border.all(color: kPrimaryGold),
                  borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                  color: kPrimaryGold.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedDate == null 
                          ? "Pilih Tarikh (Masihi)" 
                          : "${_selectedDate!.day} / ${_selectedDate!.month} / ${_selectedDate!.year}",
                      style: TextStyle(
                        color: _selectedDate == null ? kTextSecondary : kPrimaryGold,
                        fontSize: AppFontSizes.lg,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.edit, size: 16, color: kTextSecondary),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: AppSpacing.xxl),

            // BUTTON SUBMIT
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeightLg,
              child: ElevatedButton(
                onPressed: _selectedDate == null || _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGold,
                  foregroundColor: kBackgroundDark,
                  disabledBackgroundColor: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardRadius)),
                ),
                child: _isLoading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: kBackgroundDark, strokeWidth: 2))
                    : const Text("MULAKAN PERJALANAN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
