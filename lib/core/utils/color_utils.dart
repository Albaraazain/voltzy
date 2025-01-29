import 'package:flutter/material.dart';

/// Extension on Color to provide modern opacity handling
extension ColorX on Color {
  /// Creates a new color with the specified opacity using modern Color.fromARGB
  Color withAlpha(double opacity) {
    return Color.fromARGB(
      (opacity * 255).round(),
      red,
      green,
      blue,
    );
  }
}
