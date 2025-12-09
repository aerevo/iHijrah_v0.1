// lib/screens/birthdate_prompt_screen.dart (FIXED + CANTIK CALENDAR)
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // ✅ UNTUK CUPERTINO CALENDAR
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import '../widgets/metallic_gold.dart';
import '../home.dart';
import '../utils/premium_route.dart';

class BirthdatePromptScreen extends StatefulWidget {
  const BirthdatePromptScreen({Key? key}) : super(key: key);

  @override
  State<BirthdatePromptScreen> createState() => _BirthdatePromptScreenState();
}

class _BirthdatePromptScreenState extends State<BirthdatePromptScreen> {
  DateTime? _selectedDate;
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = _selectedDate ?? DateTime(1995);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext builder) {
        return Container(
          height: 350,
          decoration: const BoxDecoration(
            color: kCardDark,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header dengan button Done
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal', style: TextStyle(color: kTextSecondary)),
                    ),
                    const Text(
                      'Pilih Tarikh Lahir',
                      style: TextStyle(
                        color: kPrimaryGold,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedDate = pickedDate;
                        });
                      },
                      child: const Text(
                        'Siap',
                        style: TextStyle(
                          color: kPrimaryGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1),

              // Cupertino Date Picker (RODA PUSING-PUSING MACAM APPLE!)
              Expanded(
                child: CupertinoTheme(
                  data: const CupertinoThemeData(
                    brightness: Brightness.dark,
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        color: kPrimaryGold,
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: pickedDate,
                    minimumDate: DateTime(1950),
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (DateTime newDate) {
                      pickedDate = newDate;
                    },
                    backgroundColor: kCardDark,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _submit() async {
    if (_selectedDate == null) return;

    setState(() => _isLoading = true);

    print('🔵 SUBMIT STARTED');

    // 1. Simpan dalam User Model (Masihi & Hijri akan diuruskan oleh model)
    final user = Provider.of<UserModel>(context, listen: false);

    print('📅 Saving Masihi date: $_selectedDate');

    try {
      user.setBirthDate(_selectedDate!);
      print('✅ User saved: ${user.hijriDOB}');
    } catch (e) {
      print('❌ ERROR saving user: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ralat menyimpan data. Cuba lagi.'),
            backgroundColor: kWarningRed,
          ),
        );
      }
      return;
    }

    // Simulasi loading untuk UX
    await Future.delayed(const Duration(milliseconds: 800));

    print('🚀 Navigating to HomePage...');

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PremiumRoute.createRoute(const HomePage())
      );
      print('✅ Navigation completed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundDark,
      body: SafeArea(
        child: Padding(
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

              // INPUT DISPLAY (Tap untuk buka calendar)
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.cardRadius)
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: kBackgroundDark,
                            strokeWidth: 2
                          )
                        )
                      : const Text(
                          "MULAKAN PERJALANAN",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1
                          )
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}