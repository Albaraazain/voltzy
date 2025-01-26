import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/config/routes.dart';
import '../../../core/services/logger_service.dart';
import '../../../providers/database_provider.dart';
import '../../../models/service_model.dart';
import '../../../repositories/professional_repository.dart';

class ServiceCard extends StatelessWidget {
  final Service service;
  final bool isActive;
  final bool availableToday;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.isActive,
    required this.availableToday,
  }) : super(key: key);

  void _navigateToServiceDetails(BuildContext context) {
    try {
      LoggerService.debug(
          'Preparing service details navigation for service: ${service.id}');

      // Validate required fields
      if (service.id == null) {
        LoggerService.error(
            'Service ID is null', 'Service: ${service.toJson()}');
        throw Exception('Service ID is null');
      }

      final serviceData = {
        'service_id': service.id,
        'name': service.name,
        'price': service.basePrice,
        'duration': service.estimatedDuration != null
            ? '${service.estimatedDuration} minutes'
            : 'Varies',
        'is_active': isActive,
        'available_today': availableToday,
        'description': service.description ?? 'No description available',
        'category_id': service.categoryId,
      };

      LoggerService.debug('Service data prepared for navigation: $serviceData');

      Navigator.pushNamed(
        context,
        AppRoutes.professionalServiceDetails,
        arguments: serviceData,
      ).then((_) async {
        try {
          // Refresh services using repository
          LoggerService.debug('Refreshing professional services after return');
          final dbProvider =
              Provider.of<DatabaseProvider>(context, listen: false);
          final professionalRepo = ProfessionalRepository(dbProvider.client);

          try {
            final professional = await professionalRepo.getCurrentProfessional(
              dbProvider.currentProfile!.id,
            );

            if (professional != null) {
              LoggerService.debug(
                  'Services refreshed successfully. Count: ${professional.services.length}');
            } else {
              LoggerService.warning('No professional data found after refresh');
            }
          } catch (e, stackTrace) {
            LoggerService.error(
                'Failed to get current professional', e, stackTrace);
            rethrow;
          }
        } catch (e, stackTrace) {
          LoggerService.error('Failed to refresh services', e, stackTrace);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to refresh services'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      });
    } catch (e, stackTrace) {
      LoggerService.error(
          'Failed to navigate to service details', e, stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening service details: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToServiceDetails(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.attach_money,
                                  size: 16, color: Colors.grey[600]),
                              Text(
                                service.basePrice != null
                                    ? '${service.basePrice}/hr'
                                    : 'Price varies',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Row(
                            children: [
                              Icon(Icons.schedule,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                service.estimatedDuration != null
                                    ? '${service.estimatedDuration} min'
                                    : 'Varies',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        availableToday ? Colors.green[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    availableToday ? 'Available Today' : 'Not Available',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          availableToday ? Colors.green[700] : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProfessionalServicesScreen extends StatelessWidget {
  const ProfessionalServicesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<DatabaseProvider>(
          builder: (context, dbProvider, child) {
            final professional = dbProvider.currentProfessional;
            if (professional == null) {
              return const Center(child: CircularProgressIndicator());
            }

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
                              width: 24,
                              height: 4,
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
                    const Text(
                      'My Services',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Manage your service offerings and availability',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.pink[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'All Services',
                              style: TextStyle(
                                color: Colors.pink[700],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Service Area
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      size: 20, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Service Area',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(Icons.chevron_right,
                                  size: 20, color: Colors.grey[400]),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Greater Boston Area (25 mile radius)',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Services List
                    ...services.map((service) {
                      // In a real app, you'd get these from the service status
                      final isActive = true;
                      final availableToday =
                          service.estimatedDuration != null &&
                              service.estimatedDuration! <= 60;

                      return ServiceCard(
                        service: service,
                        isActive: isActive,
                        availableToday: availableToday,
                      );
                    }).toList(),
                    const SizedBox(height: 24),
                    // Add Service Button
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Handle add service
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink[500],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 20),
                          SizedBox(width: 8),
                          Text('Add New Service'),
                        ],
                      ),
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
