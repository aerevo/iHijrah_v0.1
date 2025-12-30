// lib/widgets/sirah_view.dart (KHAS SIRAH)

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'sirah_card.dart';   

class SirahView extends StatelessWidget {
  const SirahView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.only(left: 10, bottom: 20),
          child: const Text(
            "KHAZANAH NABI",
            style: TextStyle(
              color: kPrimaryGold, 
              letterSpacing: 2.0, 
              fontWeight: FontWeight.bold,
              fontSize: 12
            ),
          ),
        ),

        // HANYA KAD SIRAH DI SINI
        const SirahCard(),
      ],
    );
  }
}
