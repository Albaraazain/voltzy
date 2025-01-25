import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../models/service_model.dart';
import '../../../core/services/location_service.dart';
import 'broadcast_request_map_screen.dart';

class BroadcastJobScreen extends StatefulWidget {
  final Service service;

  const BroadcastJobScreen({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  State<BroadcastJobScreen> createState() => _BroadcastJobScreenState();
}

class _BroadcastJobScreenState extends State<BroadcastJobScreen> {
  bool _isLoading = false;

  Future<void> _navigateToMap() async {
    setState(() => _isLoading = true);
    try {
      final location = await LocationService.getCurrentLocation();
      if (!mounted) return;

      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BroadcastRequestMapScreen(
            service: widget.service,
            initialLat: location.latitude,
            initialLng: location.longitude,
          ),
        ),
      );

      if (result == true && mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get location')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(service.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Details',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (service.description != null)
                      Text(
                        service.description!,
                        style: theme.textTheme.bodyLarge,
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Base Price',
                              style: theme.textTheme.titleMedium,
                            ),
                            if (service.basePrice != null)
                              Text(
                                '\$${service.basePrice!.toStringAsFixed(2)}',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.primaryColor,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Duration',
                              style: theme.textTheme.titleMedium,
                            ),
                            if (service.estimatedDuration != null)
                              Text(
                                '${(service.estimatedDuration! / 60).toStringAsFixed(1)} hours',
                                style: theme.textTheme.titleLarge,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToMap,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Start Broadcast Request'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
