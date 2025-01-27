import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../providers/database_provider.dart';
import '../../../models/professional_service_model.dart';
import '../../../repositories/service_repository.dart';

class ServiceCard extends StatelessWidget {
  final ProfessionalService service;
  final VoidCallback onToggle;

  const ServiceCard({
    Key? key,
    required this.service,
    required this.onToggle,
  }) : super(key: key);

  String _formatDuration(double? hours) {
    if (hours == null) return 'Varies';
    if (hours < 1) return '${(hours * 60).round()} minutes';
    if (hours == 1) return '1 hour';
    if (hours % 1 == 0) return '${hours.round()} hours';
    return '$hours hours';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.baseService.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.attach_money,
                              size: 16, color: Colors.grey[600]),
                          Text(
                            '${service.effectivePrice}/hr',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.schedule,
                              size: 16, color: Colors.grey[600]),
                          Text(
                            _formatDuration(service.effectiveDuration),
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
                GestureDetector(
                  onTap: onToggle,
                  child: Container(
                    width: 48,
                    height: 24,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: service.isActive
                          ? Colors.pink.shade100
                          : Colors.grey.shade100,
                    ),
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 200),
                          left: service.isActive ? 26 : 2,
                          top: 2,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: service.isActive
                                  ? Colors.pink.shade500
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: service.availableToday
                        ? Colors.green.shade100
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    service.availableToday
                        ? 'Available Today'
                        : 'Not Available',
                    style: TextStyle(
                      fontSize: 12,
                      color: service.availableToday
                          ? Colors.green.shade700
                          : Colors.grey.shade600,
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

class ProfessionalServicesManagementScreen extends StatelessWidget {
  const ProfessionalServicesManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<DatabaseProvider>(
          builder: (context, dbProvider, child) {
            if (dbProvider.currentProfessional == null) {
              print('DEBUG: currentProfessional is null');
              return const Center(child: CircularProgressIndicator());
            }

            final services = dbProvider.currentProfessional!.services;
            print('DEBUG: Loaded services: ${services.length}');
            print('DEBUG: Services data: $services');

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

                    // Title and Description
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

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'All Services',
                              style: TextStyle(
                                color: Colors.pink.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Inactive',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Service Area Card
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
                                  color: Colors.grey[400]),
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

                    // Service Cards
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return ServiceCard(
                          service: service,
                          onToggle: () async {
                            final serviceRepo =
                                ServiceRepository(Supabase.instance.client);
                            await serviceRepo.toggleServiceActive(
                              service.id,
                              service.professionalId,
                              !service.isActive,
                            );
                          },
                        );
                      },
                    ),

                    // Add Service Button
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Navigate to add service screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pink.shade500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Add New Service',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 80), // Space for bottom nav
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
