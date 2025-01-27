import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../models/professional_service_model.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/config/routes.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ServiceCard extends StatelessWidget {
  final Color backgroundColor;
  final String title;
  final String price;
  final String duration;
  final ProfessionalService service;

  const ServiceCard({
    super.key,
    required this.backgroundColor,
    required this.title,
    required this.price,
    required this.duration,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        LoggerService.debug('Navigating to service details from profile');
        Navigator.pushNamed(
          context,
          AppRoutes.professionalServiceDetails,
          arguments: {
            'service_id': service.id,
            'name': service.baseService.name,
            'price': service.effectivePrice,
            'duration': duration,
            'description': service.baseService.description ??
                'Professional ${service.baseService.name} services including installation, maintenance, and repairs.',
            'category_id': service.baseService.categoryId,
            'is_active': service.isActive,
            'available_today': service.availableToday,
            'rating': 4.9,
            'jobs_completed': 156,
            'requirements': [
              'Valid professional license',
              'Own tools and equipment',
              'Transportation',
              'Insurance coverage'
            ],
            'service_area': 'Greater Boston Area (25 mile radius)',
            'is_popular': service.baseService.name == 'Electrical Installation',
          },
        );
      },
      child: Container(
        height: 96,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  service.baseService.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '\$${service.effectivePrice}/hr',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String name;
  final double rating;
  final String date;
  final String comment;

  const ReviewCard({
    super.key,
    required this.name,
    required this.rating,
    required this.date,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.star, size: 16, color: Colors.amber[500]),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfessionalProfileScreen extends StatelessWidget {
  const ProfessionalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<DatabaseProvider>(
          builder: (context, dbProvider, child) {
            if (dbProvider.currentProfessional == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final professional = dbProvider.currentProfessional!;
            final profile = professional.profile;
            final services = professional.services;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.chevron_left, size: 24),
                            const SizedBox(width: 12),
                            Container(
                              height: 4,
                              width: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.settings, size: 24, color: Colors.grey[600]),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Profile Info
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.pink[100],
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              (professional.profile?.name ?? 'Professional')
                                  .substring(0, 2)
                                  .toUpperCase(),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.pink[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                professional.profile?.name ?? 'Professional',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                professional.specialties.isNotEmpty
                                    ? professional.specialties.first
                                    : 'Professional',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Greater Boston Area',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Badges
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.pink[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Licensed Pro',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.pink[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star,
                                  size: 16, color: Colors.amber.shade600),
                              const SizedBox(width: 4),
                              Text(
                                professional.rating != null
                                    ? '${professional.rating!.toStringAsFixed(1)} (${professional.reviewCount ?? 0})'
                                    : 'No ratings yet',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.work, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${professional.jobsCompleted ?? 0} jobs completed',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.attach_money,
                            size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          professional.hourlyRate != null
                              ? '${professional.hourlyRate!.toStringAsFixed(2)}/hr'
                              : 'Rate varies',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Stats Grid
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Jobs Completed',
                            value: professional.jobsCompleted.toString(),
                            icon: Icons.thumb_up,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: StatCard(
                            title: 'Years Experience',
                            value: '${professional.yearsOfExperience}+',
                            icon: Icons.military_tech,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Services
                    const Text(
                      'Services Offered',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...services.asMap().entries.map((entry) {
                      final service = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: entry.key < services.length - 1 ? 12 : 0,
                        ),
                        child: ServiceCard(
                          backgroundColor: entry.key % 2 == 0
                              ? Colors.pink[100]!
                              : Colors.amber[100]!,
                          title: service.baseService.name,
                          price: service.effectivePrice.toString(),
                          duration: service.effectiveDuration != null &&
                                  service.effectiveDuration! <= 60
                              ? '${service.effectiveDuration} min'
                              : '${(service.effectiveDuration! / 60).toStringAsFixed(1)} hr',
                          service: service,
                        ),
                      );
                    }),
                    const SizedBox(height: 24),

                    // Reviews
                    const Text(
                      'Recent Reviews',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const ReviewCard(
                      name: 'Sarah Johnson',
                      rating: 5.0,
                      date: '2 days ago',
                      comment:
                          'Mike did an excellent job installing new outlets in my home office. Very professional and efficient.',
                    ),
                    const SizedBox(height: 12),
                    const ReviewCard(
                      name: 'David Chen',
                      rating: 4.8,
                      date: '1 week ago',
                      comment:
                          'Quick response time and great work on the electrical panel upgrade. Highly recommended!',
                    ),
                    const SizedBox(height: 80), // Space for bottom navigation
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
