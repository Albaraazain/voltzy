import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/professional_repository.dart';
import '../../../repositories/service_repository.dart';
import '../../../models/service_model.dart';
import '../../../core/services/logger_service.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const InfoCard({
    Key? key,
    required this.title,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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
    Key? key,
    required this.serviceData,
  }) : super(key: key);

  @override
  State<ProfessionalServiceDetailsScreen> createState() =>
      _ProfessionalServiceDetailsScreenState();
}

class _ProfessionalServiceDetailsScreenState
    extends State<ProfessionalServiceDetailsScreen> {
  late Future<Service> _serviceFuture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    LoggerService.debug('Initializing ProfessionalServiceDetailsScreen');
    _serviceFuture = _loadServiceDetails();
  }

  Future<Service> _loadServiceDetails() async {
    try {
      LoggerService.debug(
          'Loading service details with data: ${widget.serviceData}');

      // Get the service ID from the navigation arguments
      final serviceId = widget.serviceData['service_id'];
      if (serviceId == null) {
        LoggerService.error('Service ID is missing from navigation arguments',
            'Available keys: ${widget.serviceData.keys.join(', ')}');
        throw Exception('Service ID is missing from navigation arguments');
      }

      LoggerService.debug('Loading service with ID: $serviceId');

      final dbProvider = context.read<DatabaseProvider>();
      final serviceRepo = ServiceRepository(dbProvider.client);

      try {
        final service = await serviceRepo.getService(serviceId);
        LoggerService.debug('Service loaded successfully: ${service.toJson()}');
        return service;
      } catch (e, stackTrace) {
        LoggerService.error(
            'Failed to load service from repository', e, stackTrace);
        rethrow;
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to load service details', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _deleteService() async {
    try {
      setState(() => _isLoading = true);

      final dbProvider = context.read<DatabaseProvider>();
      final professionalRepo = ProfessionalRepository(dbProvider.client);

      // Remove service from professional's services
      await professionalRepo.removeServiceFromProfessional(
        dbProvider.currentProfessional!.id,
        widget.serviceData['id'],
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service removed successfully')),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to delete service', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to remove service')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateService(Service service) async {
    try {
      setState(() => _isLoading = true);

      final dbProvider = context.read<DatabaseProvider>();
      final professionalRepo = ProfessionalRepository(dbProvider.client);

      // Update service details
      await professionalRepo.updateProfessionalService(
        dbProvider.currentProfessional!.id,
        service.id,
        customPrice: service.basePrice,
        customDuration: service.estimatedDuration,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully')),
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update service', e, stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update service')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: FutureBuilder<Service>(
          future: _serviceFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              LoggerService.error(
                  'Error in service details build', snapshot.error);
              return Center(
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
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _serviceFuture = _loadServiceDetails();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
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
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Row(
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
                        ),
                        Icon(Icons.settings_outlined,
                            size: 24, color: Colors.grey[600]),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title and Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: widget.serviceData['is_active']
                                        ? Colors.green[100]
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    widget.serviceData['is_active']
                                        ? 'Active'
                                        : 'Inactive',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: widget.serviceData['is_active']
                                          ? Colors.green[700]
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Basic Information
                    InfoCard(
                      title: 'Basic Information',
                      child: Column(
                        children: [
                          _buildInfoRow(
                            'Base Rate',
                            '\$${service.basePrice?.toString() ?? "0"}/hour',
                          ),
                          _buildInfoRow(
                            'Duration',
                            service.estimatedDuration != null
                                ? '${service.estimatedDuration} minutes'
                                : 'Varies',
                          ),
                          _buildInfoRow(
                            'Category',
                            'Professional Services',
                            showBorder: false,
                          ),
                        ],
                      ),
                    ),

                    // Service Description
                    if (service.description != null)
                      InfoCard(
                        title: 'Service Description',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.description!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Service Notice
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Service Notice',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.amber[800],
                                  ),
                                ),
                                Text(
                                  'Custom pricing and duration available on request',
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
                    if (!_isLoading) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _buildActionButton(
                              'Delete Service',
                              Icons.delete_outline,
                              Colors.grey[100]!,
                              Colors.grey[600]!,
                              onPressed: _deleteService,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildActionButton(
                              'Edit Service',
                              Icons.edit_outlined,
                              Colors.pink[500]!,
                              Colors.white,
                              onPressed: () {
                                // TODO: Navigate to edit service screen
                              },
                            ),
                          ),
                        ],
                      ),
                    ] else
                      const Center(child: CircularProgressIndicator()),
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

  Widget _buildInfoRow(String label, String value, {bool showBorder = true}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: showBorder
            ? Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              )
            : null,
      ),
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    Color backgroundColor,
    Color textColor, {
    VoidCallback? onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}
