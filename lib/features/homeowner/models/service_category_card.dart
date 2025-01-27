import 'package:flutter/material.dart';

enum CardSize { small, medium, large }

class ServiceCategoryCard extends StatelessWidget {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final int serviceCount;
  final double minPrice;
  final double maxPrice;
  final CardSize size;
  final MaterialColor accentColor;

  const ServiceCategoryCard({
    super.key,
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.serviceCount,
    required this.minPrice,
    required this.maxPrice,
    required this.size,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/images/';
    switch (name.toLowerCase().replaceAll(' services', '')) {
      case 'electrical':
        imagePath += 'electrical_services.png';
        break;
      case 'plumbing':
        imagePath += 'plumbing_services.png';
        break;
      case 'hvac':
        imagePath += 'hvac_services.png';
        break;
      case 'landscaping':
        imagePath += 'landscaping_services.png';
        break;
      case 'security systems':
      case 'security':
        imagePath += 'security_services.png';
        break;
      case 'smart home':
        imagePath += 'smart_home_services.png';
        break;
      case 'home cleaning':
      case 'cleaning':
        imagePath += 'home_cleaning_services.png';
        break;
      case 'carpentry':
        imagePath += 'carpentry_services.png';
        break;
      case 'painting':
        imagePath += 'painting_services.png';
        break;
      case 'solar services':
      case 'solar':
        imagePath += 'solar_services.png';
        break;
      case 'appliance repair':
      case 'appliance':
        imagePath += 'appliance_repair_services.png';
        break;
      default:
        imagePath += 'default_service.png';
    }

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.6),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Text(
                name.replaceAll(' Services', ''),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '$serviceCount services',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '\$${minPrice.toStringAsFixed(0)}-${maxPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData() {
    switch (iconName.toLowerCase()) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'maintenance':
        return Icons.build;
      case 'installation':
        return Icons.settings;
      case 'repair':
        return Icons.handyman;
      case 'landscaping':
        return Icons.grass;
      default:
        return Icons.home_repair_service;
    }
  }
}
