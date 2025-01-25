import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFFFFB347); // Warm yellow/orange
  static const Color secondary = Color(0xFFFFF4E3); // Light cream
  static const Color accent = Color(0xFFFFD93D); // Bright yellow

  // Text Colors
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);

  // Background Colors
  static const Color background = Color(0xFFFFFBF5); // Warm white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFEEEEEE); // Light gray border

  // Status Colors
  static const Color success = Color(0xFF95D1CC); // Mint green
  static const Color warning = Color(0xFFFFB5A7); // Pastel coral
  static const Color error = Color(0xFFFF9494); // Soft red
  static const Color info = Color(0xFFA7C7E7); // Pastel blue

  // Overlay Colors
  static const Color overlay = Color(0x80000000);
  static const Color scrim = Color(0x33000000);

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFFFFD93D), // Bright yellow
    Color(0xFFFFB347), // Warm orange
  ];

  // Shadow Color
  static const Color shadow = Color(0x15000000); // Very soft shadow

  // Category colors - pastel palette
  static const List<Color> categoryColors = [
    Color(0xFFFFB5A7), // Pastel coral
    Color(0xFF95D1CC), // Mint green
    Color(0xFFFFC3E7), // Pastel pink
    Color(0xFFB5DEFF), // Light blue
    Color(0xFFE7CBFF), // Lavender
    Color(0xFFFFE5A7), // Pastel yellow
    Color(0xFFA7E7CB), // Seafoam green
    Color(0xFFFFCBA7), // Peach
    Color(0xFFA7B5FF), // Periwinkle
    Color(0xFFE7FFB5), // Lime green
  ];

  static Color getCategoryColor(int index) {
    return categoryColors[index % categoryColors.length];
  }

  static Color getAccentColorFromName(String name) {
    final index = name.hashCode % categoryColors.length;
    return categoryColors[index].withOpacity(0.8);
  }
}
