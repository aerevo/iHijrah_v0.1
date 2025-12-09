// lib/widgets/event_card.dart (OVERWRITE PENUH - PREMIUM UI)

import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../utils/event_service.dart';
import 'feed_card.dart'; // Helper widget yang digunakan

class EventCard extends StatelessWidget {
  const EventCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: EventService.getEventForToday(), // Dapatkan peristiwa hari ini
      builder: (context, snapshot) {
        // 1. Loading State (Guna Shimmer/Progress Emas)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 100,
            decoration: BoxDecoration(color: kCardDark, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: CircularProgressIndicator(color: kPrimaryGold)),
          );
        }

        String title = "Tiada Peristiwa Khas";
        String subtitle = "Hari ini dalam sejarah Islam sunyi dari peristiwa besar yang dicatatkan.";
        IconData icon = Icons.history_edu;

        // 2. Data Wujud
        if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
          final data = snapshot.data!;
          title = data['tajuk'] ?? "Peristiwa Hari Ini";
          subtitle = data['keterangan'] ?? "";
          icon = Icons.event_available;
        }

        // 3. Paparan Kad (Menggunakan FeedCard yang seragam)
        return FeedCard(
          title: title,
          subtitle: subtitle,
          leadingIcon: icon,
        );
      },
    );
  }
}