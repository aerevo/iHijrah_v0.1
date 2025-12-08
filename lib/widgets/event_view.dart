// lib/widgets/event_view.dart (UPGRADED 7.8/10)
import 'package:flutter/material.dart';
import '../screens/event_screen.dart';

class EventView extends StatelessWidget {
  const EventView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 700,
      child: EventScreen(),
    );
  }
}