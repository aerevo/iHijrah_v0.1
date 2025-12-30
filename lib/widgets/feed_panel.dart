// lib/widgets/feed_panel.dart (VERSI MUKTAMAD: POKOK + SIRAH + AMALAN)

import 'package:flutter/material.dart';
// import 'package:provider/provider.dart'; // Tak perlu jika tak guna provider direct di sini

// Import 3 Widget Utama
import 'hijrah_tree.dart';   
import 'sirah_card.dart';    
import 'amalan_list.dart';   
import '../utils/constants.dart';

class FeedPanel extends StatelessWidget {
  const FeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 20, 
        bottom: 150, // Ruang bawah besar untuk scroll selesa
      ),
      child: Column(
        children: const [
          // 1. POKOK (Sentiasa di atas)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: HijrahTree(),
          ),

          SizedBox(height: 30),

          // 2. KAD SIRAH (Kisah Nabi - Ganti Grid Lama)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SirahCard(), 
          ),

          SizedBox(height: 25),

          // 3. SENARAI AMALAN (Checklist - Ganti Grid Lama)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AmalanList(), 
          ),
        ],
      ),
    );
  }
}
