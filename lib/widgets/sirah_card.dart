// lib/widgets/sirah_card.dart (LIVE DATA)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_content_provider.dart';
import '../utils/constants.dart';
import 'metallic_gold.dart';

class SirahCard extends StatelessWidget {
  const SirahCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. Tarik data dari Provider
    final provider = Provider.of<DailyContentProvider>(context);
    final sirah = provider.todaySirah;
    final isLoading = provider.isLoading;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: const [
              Icon(Icons.history_edu, color: kPrimaryGold, size: 20),
              SizedBox(width: 10),
              Text("SIRAH HARI INI", style: TextStyle(color: kPrimaryGold, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 15),

          // Content (Loading / Ada Data)
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: kPrimaryGold))
          else if (sirah != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sirah.tajuk, // Tajuk dari JSON
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, height: 1.3),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: kPrimaryGold.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: Text(sirah.tahun, style: const TextStyle(color: kPrimaryGold, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Text(sirah.lokasi, style: const TextStyle(color: Colors.grey, fontSize: 11, fontStyle: FontStyle.italic)),
                  ],
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          sirah.pengajaran, // Pengajaran dari JSON
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            const Text("Tiada data sirah untuk tarikh ini.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
