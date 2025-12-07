// lib/utils/extensions.dart (FAIL BARU - HELPER FUNCTIONS)

import 'package:flutter/material.dart';
import 'constants.dart';

/// Extension untuk BuildContext - shortcuts untuk common operations
extension ContextExtensions on BuildContext {
  // Theme shortcuts
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;
  
  // Screen size shortcuts
  Size get screenSize => MediaQuery.of(this).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  
  // Safe area shortcuts
  EdgeInsets get padding => MediaQuery.of(this).padding;
  double get topPadding => padding.top;
  double get bottomPadding => padding.bottom;
  
  // Navigation shortcuts
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  Future<T?> push<T>(Widget screen) => Navigator.of(this).push(
    MaterialPageRoute(builder: (_) => screen),
  );
  
  // SnackBar shortcut dengan styling default
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? kWarningRed : kCardDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardRadius),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

/// Extension untuk String - common string operations
extension StringExtensions on String {
  // Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  // Check if string is valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
  
  // Truncate string dengan ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
  
  // Remove extra whitespace
  String get cleanWhitespace => trim().replaceAll(RegExp(r'\s+'), ' ');
}

/// Extension untuk DateTime - Hijri & Masihi formatting
extension DateTimeExtensions on DateTime {
  // Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  // Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && 
           month == yesterday.month && 
           day == yesterday.day;
  }
  
  // Days until this date
  int get daysUntil {
    final now = DateTime.now();
    return difference(DateTime(now.year, now.month, now.day)).inDays;
  }
  
  // Format as "X hari lepas" / "Semalam" / "Hari ini"
  String get relativeTime {
    if (isToday) return 'Hari ini';
    if (isYesterday) return 'Semalam';
    
    final diff = DateTime.now().difference(this);
    
    if (diff.inDays > 0) return '${diff.inDays} hari lepas';
    if (diff.inHours > 0) return '${diff.inHours} jam lepas';
    if (diff.inMinutes > 0) return '${diff.inMinutes} minit lepas';
    return 'Baru sahaja';
  }
}

/// Extension untuk int - XP/Level calculations
extension IntExtensions on int {
  // Format number dengan separator (1000 -> 1,000)
  String get withSeparator {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
  
  // Convert seconds to readable duration
  String get toDuration {
    final hours = this ~/ 3600;
    final minutes = (this % 3600) ~/ 60;
    final seconds = this % 60;
    
    if (hours > 0) return '${hours}j ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }
}

/// Extension untuk double - Progress calculations
extension DoubleExtensions on double {
  // Clamp between 0 and 1
  double get normalized => clamp(0.0, 1.0);
  
  // Convert to percentage string
  String get toPercentage => '${(this * 100).toStringAsFixed(0)}%';
  
  // Round to decimal places
  double roundTo(int places) {
    final mod = 10.0 * places;
    return (this * mod).round() / mod;
  }
}

/// Extension untuk List - common operations
extension ListExtensions<T> on List<T> {
  // Safe get dengan default value
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }
  
  // Check if list has items
  bool get hasItems => isNotEmpty;
  
  // Get random item
  T? get random {
    if (isEmpty) return null;
    return this[(DateTime.now().millisecondsSinceEpoch % length)];
  }
}

/// Extension untuk Color - color manipulations
extension ColorExtensions on Color {
  // Lighten color
  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  // Darken color
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}