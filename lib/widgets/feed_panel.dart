// lib/widgets/feed_panel.dart (UNLOCK: POKOK + SIRAH + AMALAN)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import 3 Widget Utama (Pastikan fail-fail ini wujud dalam folder widgets)
import 'hijrah_tree.dart';   // Pokok Utama
import 'sirah_card.dart';    // ✅ Kad Sirah (Live Data)
import 'amalan_list.dart';   // ✅ Senarai Amalan (Live Data)

import '../utils/constants.dart';

class FeedPanel extends StatelessWidget {
  const FeedPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        top: 20, 
        bottom: 150, // Ruang bawah besar sikit supaya tak tertutup dek menu bawah
      ),
      child: Column(
        children: [
          // 1. POKOK HIJRAH (SENTIASA DI ATAS)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: HijrahTree(),
          ),

          const SizedBox(height: 30),

          // 2. KAD SIRAH (DATA DARI PROVIDER)
          // Ini menggantikan post-post dummy dulu
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: SirahCard(), 
          ),

          const SizedBox(height: 25),

          // 3. SENARAI AMALAN SUNNAH
          // Ini menggantikan grid masonry dulu
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AmalanList(), 
          ),
        ],
      ),
    );
  }
}
