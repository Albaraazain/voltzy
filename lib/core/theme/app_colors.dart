import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF2196F3); // Blue
  static const Color secondary = Color(0xFF03A9F4); // Light Blue
  static const Color accent = Color(0xFFFFA726); // Orange

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textTertiary = Color(0xFF9E9E9E);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5); // Light Gray
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color onSurface = Color(0xFF212121);
  static const Color onBackground = Color(0xFF212121);

  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue

  // Service Category Colors
  static const Color electrical = Color(0xFFE91E63); // Pink
  static const Color plumbing = Color(0xFFFFA726); // Orange
  static const Color cleaning = Color(0xFF66BB6A); // Green
  static const Color repair = Color(0xFF42A5F5); // Blue

  // Professional Card Colors
  static const Color professionalCardBg = Color(0xFFFAFAFA);
  static const Color professionalCardBorder = Color(0xFFEEEEEE);
  static const Color professionalRatingBg = Color(0xFFFFF8E1);
  static const Color professionalRatingText = Color(0xFFFFB300);

  // Job Status Colors
  static const Color jobPending = Color(0xFFFFB74D);
  static const Color jobAccepted = Color(0xFF4CAF50);
  static const Color jobInProgress = Color(0xFF2196F3);
  static const Color jobCompleted = Color(0xFF4CAF50);
  static const Color jobCancelled = Color(0xFFF44336);

  // Misc Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1F000000);
  static const Color overlay = Color(0x33000000);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF2196F3),
    Color(0xFF1976D2),
  ];

  static const List<Color> successGradient = [
    Color(0xFF66BB6A),
    Color(0xFF4CAF50),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFFB74D),
    Color(0xFFFFA726),
  ];

  // Helper Methods
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'awaiting_acceptance':
        return jobPending;
      case 'accepted':
      case 'scheduled':
        return jobAccepted;
      case 'in_progress':
      case 'started':
        return jobInProgress;
      case 'completed':
        return jobCompleted;
      case 'cancelled':
        return jobCancelled;
      default:
        return textTertiary;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'electrical':
        return electrical;
      case 'plumbing':
        return plumbing;
      case 'cleaning':
        return cleaning;
      case 'repair':
        return repair;
      default:
        return primary;
    }
  }
}
