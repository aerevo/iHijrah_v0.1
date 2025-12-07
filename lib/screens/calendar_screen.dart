// lib/screens/calendar_screen.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/hijri_service.dart';
import '../widgets/metallic_gold.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Logic simple untuk demo kalendar bulan semasa
    // Dalam production, guna package 'hijri' sebenar untuk generate days
    final List<int> days = List.generate(30, (index) => index + 1);
    final int today = 15; // Contoh hari ini 15hb

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: (){}, icon: const Icon(Icons.chevron_left, color: kTextSecondary)),
              const MetallicGold(
                child: Text("Muharram 1446H", style: TextStyle(fontSize: AppFontSizes.xl, fontWeight: FontWeight.bold, fontFamily: 'Playfair'))
              ),
              IconButton(onPressed: (){}, icon: const Icon(Icons.chevron_right, color: kTextSecondary)),
            ],
          ),
        ),

        // Days of Week
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: ['A','I','S','R','K','J','S'].map((d) => 
            Text(d, style: const TextStyle(color: kAccentOlive, fontWeight: FontWeight.bold))
          ).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),

        // Calendar Grid
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: days.length,
            itemBuilder: (context, index) {
              final day = days[index];
              final isToday = day == today;
              
              return Container(
                decoration: BoxDecoration(
                  color: isToday ? kPrimaryGold : kCardDark,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday ? null : Border.all(color: Colors.white10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "$day",
                  style: TextStyle(
                    color: isToday ? kBackgroundDark : kTextPrimary,
                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal
                  ),
                ),
              );
            },
          ),
        ),
        
        // Footer Info
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: kCardDark, 
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
              border: Border.all(color: kPrimaryGold.withOpacity(0.3))
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: kPrimaryGold),
                SizedBox(width: AppSpacing.md),
                Expanded(child: Text("Puasa Sunat Ayyamul Bidh pada 13, 14, 15 haribulan.", style: TextStyle(color: kTextSecondary, fontSize: AppFontSizes.sm))),
              ],
            ),
          ),
        )
      ],
    );
  }
}