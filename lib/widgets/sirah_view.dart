// lib/widgets/sirah_view.dart
// Halaman ini hanya muncul bila tekan menu "SIRAH" di Sidebar

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'sirah_card.dart';   
import 'amalan_list.dart';

class SirahView extends StatelessWidget {
  const SirahView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Kecil
        Container(
          padding: const EdgeInsets.only(left: 10, bottom: 20),
          child: const Text(
            "KHAZANAH HARI INI",
            style: TextStyle(
              color: kPrimaryGold, 
              letterSpacing: 2.0, 
              fontWeight: FontWeight.bold,
              fontSize: 12
            ),
          ),
        ),

        // 1. KAD SIRAH
        const SirahCard(),

        const SizedBox(height: 30),

        // 2. SENARAI AMALAN
        const AmalanList(),
      ],
    );
  }
}
