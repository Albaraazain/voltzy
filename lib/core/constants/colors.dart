import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFB8926A);
  static const Color secondary = Color(0xFFC4B5A5); // Darker beige
  static const Color accent = Color(0xFFC4A484);

  // Text Colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E); // Light gray

  // Background Colors
  static const Color background = Color(0xFFFAF9F6);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE8E3DD); // Subtle beige border

  // Status Colors
  static const Color success = Color(0xFF7FA67B); // Muted green
  static const Color warning = Color(0xFFD4B483); // Warm beige
  static const Color error = Color(0xFFC15B5B); // Muted red
  static const Color info = Color(0xFF8B9DAF); // Muted blue

  // Overlay Colors
  static const Color overlay = Color(0x80000000); // Black overlay
  static const Color scrim = Color(0x33000000); // Light scrim

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFE2D7C9), // Claude AI beige
    Color(0xFFD4C5B9), // Slightly darker beige
  ];

  // Shadow Color
  static const Color shadow = Color(0x40000000); // Softer shadow

  // Category colors - warm beige palette
  static const List<Color> categoryColors = [
    Color(0xFFB8926A), // Warm beige
    Color(0xFFC4A484), // Soft tan
    Color(0xFFD4B996), // Light beige
    Color(0xFFE6CCB2), // Pale beige
    Color(0xFFDEB887), // Burlywood
    Color(0xFFD2B48C), // Tan
    Color(0xFFBC8F8F), // Rosy brown
    Color(0xFFDAA520), // Goldenrod
    Color(0xFFCD853F), // Peru
    Color(0xFFDEB887), // Burlywood
  ];

  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  static Color getAccentColorFromName(String name) {
    final index = name.hashCode % categoryColors.length;
    return categoryColors[index].withOpacity(0.8);
  }
}
