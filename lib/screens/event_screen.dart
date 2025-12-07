// lib/screens/event_screen.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/metallic_gold.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data Dummy (Nanti ambil dari SirahService)
    final List<Map<String, String>> events = [
      {'date': '1 Muharram', 'title': 'Awal Muharram (Maal Hijrah)', 'desc': 'Permulaan tahun baru Islam dan memperingati penghijrahan Nabi SAW.'},
      {'date': '10 Muharram', 'title': 'Hari Asyura', 'desc': 'Disunatkan berpuasa. Hari bersejarah bagi para Nabi terdahulu.'},
      {'date': '12 Rabiulawal', 'title': 'Maulidur Rasul', 'desc': 'Hari kelahiran Kekasih Allah, Nabi Muhammad SAW.'},
      {'date': '27 Rejab', 'title': 'Isra\' dan Mi\'raj', 'desc': 'Perjalanan agung Nabi SAW menerima perintah solat 5 waktu.'},
    ];

    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent sebab dalam Flyout
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        child: ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final e = events[index];
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: kCardDark,
                borderRadius: BorderRadius.circular(AppSizes.cardRadius),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryGold.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text(
                    e['date']!.split(' ')[0], 
                    style: const TextStyle(color: kPrimaryGold, fontWeight: FontWeight.bold, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
                title: Text(e['title']!, style: const TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold)),
                subtitle: Text(e['desc']!, style: const TextStyle(color: kTextSecondary, fontSize: AppFontSizes.xs)),
              ),
            );
          },
        ),
      ),
    );
  }
}