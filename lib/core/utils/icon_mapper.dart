import 'package:flutter/material.dart';

class IconMapper {
  static final Map<String, IconData> _iconMap = {
    'electrical_services': Icons.electrical_services,
    'plumbing': Icons.plumbing,
    'hvac': Icons.hvac,
    'cleaning_services': Icons.cleaning_services,
    'format_paint': Icons.format_paint,
    'carpenter': Icons.carpenter,
    'smart_home': Icons.smart_toy,
    'yard': Icons.yard,
    'settings_suggest': Icons.settings_suggest,
    'security': Icons.security,
    // Add a default icon
    'default': Icons.handyman,
  };

  static IconData getIcon(String? iconName) {
    if (iconName == null || !_iconMap.containsKey(iconName)) {
      return _iconMap['default']!;
    }
    return _iconMap[iconName]!;
  }
}
