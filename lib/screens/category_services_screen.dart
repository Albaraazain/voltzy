import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voltz/features/common/widgets/loading_indicator.dart';
import '../models/category_model.dart';
import '../models/service_model.dart';
import '../models/job_model.dart';
import '../providers/database_provider.dart';
import '../core/services/logger_service.dart';
import '../widgets/error_view.dart';
import 'broadcast_request_screen.dart';

class CategoryServicesScreen extends StatefulWidget {
  final Category category;

  const CategoryServicesScreen({
    super.key,
    required this.category,
  });

  @override
  State<CategoryServicesScreen> createState() => _CategoryServicesScreenState();
}

class _CategoryServicesScreenState extends State<CategoryServicesScreen> {
  late Future<List<Service>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  void _loadServices() {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    _servicesFuture =
        databaseProvider.getServicesByCategory(widget.category.id);
  }

  void _navigateToBroadcastRequest(Service service) async {
    final job = await Navigator.push<Job>(
      context,
      MaterialPageRoute(
        builder: (context) => BroadcastRequestScreen(
          service: service,
        ),
      ),
    );

    if (job != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Your request has been broadcasted to nearby professionals'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, job);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        elevation: 0,
      ),
      body: FutureBuilder<List<Service>>(
        future: _servicesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            LoggerService.error('Error loading services', snapshot.error);
            return ErrorView(
              message: 'Failed to load services',
              onRetry: () {
                setState(() {
                  _loadServices();
                });
              },
            );
          }

          final services = snapshot.data!;
          if (services.isEmpty) {
            return Center(
              child: Text(
                'No services available in this category',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () => _navigateToBroadcastRequest(service),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        if (service.description != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            service.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (service.basePrice != null)
                              Text(
                                'Starting from \$${service.basePrice!.toStringAsFixed(2)}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            if (service.estimatedDuration != null)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${service.estimatedDuration} min',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to broadcast request screen
        },
        icon: const Icon(Icons.broadcast_on_personal),
        label: const Text('Broadcast Request'),
      ),
    );
  }
}
