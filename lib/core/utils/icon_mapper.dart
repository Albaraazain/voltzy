import 'package:flutter/material.dart';

class IconMapper {
  static IconData getCategoryIcon(String? categoryName) {
    if (categoryName == null) return Icons.category;

    switch (categoryName.toLowerCase()) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'painting':
        return Icons.format_paint;
      case 'gardening':
        return Icons.yard;
      case 'carpentry':
        return Icons.handyman;
      case 'appliance repair':
        return Icons.home_repair_service;
      case 'moving':
        return Icons.local_shipping;
      case 'pest control':
        return Icons.pest_control;
      case 'roofing':
        return Icons.roofing;
      case 'hvac':
        return Icons.hvac;
      case 'flooring':
        return Icons.grid_on;
      case 'security':
        return Icons.security;
      case 'windows':
        return Icons.window;
      case 'doors':
        return Icons.door_sliding;
      case 'general maintenance':
        return Icons.build;
      default:
        return Icons.home_repair_service;
    }
  }
}
