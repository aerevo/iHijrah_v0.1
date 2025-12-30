// lib/widgets/amalan_view.dart (PAGE UNTUK AMALAN)

import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'amalan_list.dart'; // ✅ Panggil fail asal Kapten

class AmalanView extends StatelessWidget {
  const AmalanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Halaman
        Container(
          padding: const EdgeInsets.only(left: 10, bottom: 20),
          child: Row(
            children: const [
              Icon(Icons.volunteer_activism, color: kPrimaryGold, size: 18),
              SizedBox(width: 10),
              Text(
                "MISI HARIAN",
                style: TextStyle(
                  color: kPrimaryGold, 
                  letterSpacing: 2.0, 
                  fontWeight: FontWeight.bold,
                  fontSize: 12
                ),
              ),
            ],
          ),
        ),

        // Panggil Widget Checklist Kapten
        const AmalanList(),
      ],
    );
  }
}
