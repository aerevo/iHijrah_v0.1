// lib/widgets/calendar_view.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import '../screens/calendar_screen.dart'; // Memanggil skrin penuh

class CalendarView extends StatelessWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Membungkus skrin kalendar dalam container yang sesuai untuk Flyout Panel
    return const SizedBox(
      height: 700, 
      child: CalendarScreen(),
    );
  }
}