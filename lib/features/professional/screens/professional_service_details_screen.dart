import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/service_repository.dart';
import '../../../models/professional_service_model.dart';
import '../../../core/services/logger_service.dart';
import '../../../features/professional/screens/edit_professional_service_screen.dart';
import '../../../features/professional/screens/availability_settings_screen.dart';
import '../../../features/professional/screens/service_area_settings_screen.dart';
import '../../../features/professional/screens/emergency_settings_screen.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback? onEdit;

  const InfoCard({
    super.key,
    required this.title,
    required this.child,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (onEdit != null)
                GestureDetector(
                  onTap: onEdit,
                  child: Icon(Icons.edit_outlined,
                      size: 20, color: Colors.grey[400]),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class ProfessionalServiceDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> serviceData;

  const ProfessionalServiceDetailsScreen({
    super.key,
    required this.serviceData,
  });

  @override
  State<ProfessionalServiceDetailsScreen> createState() =>
      _ProfessionalServiceDetailsScreenState();
}

class _ProfessionalServiceDetailsScreenState
    extends State<ProfessionalServiceDetailsScreen> {
  late Future<ProfessionalService> _serviceFuture;
  late Future<Map<String, double>> _priceRangeFuture;

  @override
  void initState() {
    super.initState();
    LoggerService.debug(
        'Loading service details with data: ${widget.serviceData}');

    final serviceId = widget.serviceData['service_id'] as String?;
    if (serviceId == null) {
      LoggerService.error('Service ID is missing from navigation arguments',
          Exception('No service ID'));
      throw Exception('Service ID is missing from navigation arguments');
    }

    LoggerService.debug('Loading service with ID: $serviceId');
    final serviceRepo =
        ServiceRepository(context.read<DatabaseProvider>().client);

    _serviceFuture = serviceRepo.getProfessionalServiceById(
      serviceId,
      context.read<DatabaseProvider>().currentProfessional!.id,
    );
    _priceRangeFuture = serviceRepo.getBaseServicePriceRange(serviceId);
  }

  Future<void> _removeService(ProfessionalService service) async {
    try {
      final serviceRepo =
          ServiceRepository(context.read<DatabaseProvider>().client);
      await serviceRepo.removeServiceFromProfessional(
        context.read<DatabaseProvider>().currentProfessional!.id,
        service.id,
      );

      if (mounted) {
        await context.read<DatabaseProvider>().refreshProfessionalData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service removed successfully')),
        );
        Navigator.of(context).pop();
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to remove service', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove service')),
        );
      }
    }
  }

  void _editBasicInfo(ProfessionalService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfessionalServiceScreen(
          service: service,
        ),
      ),
    );
  }

  void _editAvailability(ProfessionalService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AvailabilitySettingsScreen(
          service: service,
        ),
      ),
    );
  }

  void _editServiceArea(ProfessionalService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceAreaSettingsScreen(
          service: service,
        ),
      ),
    );
  }

  void _editEmergencySettings(ProfessionalService service) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencySettingsScreen(
          service: service,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {bool hasBorder = true, Color? valueColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: hasBorder
          ? BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            )
          : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(int number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.pink[100],
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.pink[700],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FutureBuilder<ProfessionalService>(
          future: _serviceFuture,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              LoggerService.error(
                  'Error in service details build', snapshot.error);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading service details:\n${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final service = snapshot.data!;
            LoggerService.debug('Rendering service details for: ${service.id}');

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
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Icon(Icons.chevron_left, size: 24),
                            ),
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
                        Icon(Icons.settings_outlined,
                            size: 24, color: Colors.grey[600]),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title and Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Colors.amber[500],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${service.rating ?? 'No ratings'} (${service.jobsCompleted ?? 0} jobs)',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  service.isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (service.isPopular ?? false)
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
                              'Most Popular',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.pink[700],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Basic Information
                    InfoCard(
                      title: 'Basic Information',
                      onEdit: () => _editBasicInfo(service),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Your Rate',
                            '\$${service.effectivePrice}/hour',
                            hasBorder: true,
                          ),
                          if (service.customPrice != null)
                            _buildInfoRow(
                              'Base Rate',
                              '\$${service.baseService.basePrice}/hour',
                              hasBorder: true,
                              valueColor: Colors.grey[400],
                            ),
                          FutureBuilder<Map<String, double>>(
                            future: _priceRangeFuture,
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final range = snapshot.data!;
                                return _buildInfoRow(
                                  'Market Rate',
                                  '\$${range['min']?.toStringAsFixed(2)} - \$${range['max']?.toStringAsFixed(2)}/hour',
                                  hasBorder: true,
                                  valueColor: Colors.grey[400],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                          _buildInfoRow(
                            'Your Duration',
                            '${service.effectiveDuration} hours',
                            hasBorder: true,
                          ),
                          if (service.customDuration != null)
                            _buildInfoRow(
                              'Base Duration',
                              '${service.baseService.durationHours} hours',
                              hasBorder: true,
                              valueColor: Colors.grey[400],
                            ),
                          _buildInfoRow(
                            'Availability',
                            '${service.weekdayStart} - ${service.weekdayEnd}',
                            hasBorder: false,
                          ),
                        ],
                      ),
                    ),

                    // Service Description
                    InfoCard(
                      title: 'Service Description',
                      onEdit: () => _editBasicInfo(service),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: service.serviceTags
                                .map((tag) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    // Service Requirements
                    InfoCard(
                      title: 'Service Requirements',
                      onEdit: () => _editBasicInfo(service),
                      child: Column(
                        children: [
                          for (var i = 0;
                              i < service.requirements.length;
                              i++) ...[
                            if (i > 0) const SizedBox(height: 12),
                            _buildRequirement(
                              i + 1,
                              service.requirements[i],
                              'Required for service delivery',
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Service Area
                    InfoCard(
                      title: 'Service Area',
                      onEdit: () => _editServiceArea(service),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Text(
                                service.serviceAreaCenter,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${service.serviceAreaRadius} ${service.serviceAreaUnit} radius',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Emergency Service Notice
                    if (service.emergencyService)
                      Container(
                        margin: const EdgeInsets.only(bottom: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline,
                                size: 20, color: Colors.amber[600]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Emergency Service Available',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.amber[800],
                                    ),
                                  ),
                                  if (service.emergencyFee != null)
                                    Text(
                                      'Additional fee: \$${service.emergencyFee}/hour',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.amber[700],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _removeService(service),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[100],
                              foregroundColor: Colors.grey[600],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            icon: const Icon(Icons.delete_outline),
                            label: const Text(
                              'Delete Service',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _editBasicInfo(service),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.pink[500],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text(
                              'Edit Service',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
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
