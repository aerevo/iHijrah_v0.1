// lib/widgets/settings_view.dart
import 'package:flutter/material.dart';
import '../screens/notification_settings_screen.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const NotificationSettingsScreen();
  }
}
