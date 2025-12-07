// lib/screens/tracker_screen.dart (FAIL BARU - Tempat Tracker)

import 'package:flutter/material.dart';
import '../widgets/fardhu_tracker.dart';
import '../widgets/amalan_list.dart';
import '../widgets/event_card.dart';
import '../utils/constants.dart';

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundDark,
      appBar: AppBar(
        // Tema Emas Kilau untuk AppBar
        title: const Text('Jejak & Aktiviti Harian'),
        backgroundColor: kCardDark,
        foregroundColor: kPrimaryGold,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Matlamat Wajib Harian', 
              style: TextStyle(color: kTextPrimary, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Playfair')
            ),
            SizedBox(height: 15),
            FardhuTracker(), // Tracker Solat Fardhu
            
            SizedBox(height: 30),
            
            Text(
              'Amalan Sunnah Pilihan', 
              style: TextStyle(color: kTextPrimary, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Playfair')
            ),
            SizedBox(height: 15),
            AmalanList(), // Senarai Amalan Sunnah

            SizedBox(height: 30),

            Text(
              'Jendela Waktu & Sejarah', 
              style: TextStyle(color: kTextPrimary, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Playfair')
            ),
            SizedBox(height: 15),
            EventCard(), // Kad Peristiwa
            
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}