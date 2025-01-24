import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFE2D7C9); // Claude AI beige
  static const Color secondary = Color(0xFFC4B5A5); // Darker beige
  static const Color accent = Color(0xFF8B7355); // Rich brown accent

  // Text Colors
  static const Color textPrimary =
      Color(0xFF2C2C2C); // Near black for better contrast
  static const Color textSecondary = Color(0xFF6B6B6B); // Medium gray
  static const Color textTertiary = Color(0xFF9E9E9E); // Light gray

  // Background Colors
  static const Color background = Color(0xFFFAF9F7); // Off-white background
  static const Color surface = Color(0xFFFFFFFF); // Pure white surface
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
}
