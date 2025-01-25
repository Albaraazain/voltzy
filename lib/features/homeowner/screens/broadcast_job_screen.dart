import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/service_model.dart';
import '../../../models/job_model.dart';
import '../../../providers/database_provider.dart';

class BroadcastJobScreen extends StatefulWidget {
  final Service service;
  final DateTime scheduledDate;
  final int hours;
  final double budget;
  final double locationLat;
  final double locationLng;
  final double radiusKm;

  const BroadcastJobScreen({
    super.key,
    required this.service,
    required this.scheduledDate,
    required this.hours,
    required this.budget,
    required this.locationLat,
    required this.locationLng,
    required this.radiusKm,
  });

  @override
  State<BroadcastJobScreen> createState() => _BroadcastJobScreenState();
}

class _BroadcastJobScreenState extends State<BroadcastJobScreen> {
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = context.read<DatabaseProvider>();
      await provider.createJobRequest(
        title: widget.service.name,
        description: _descriptionController.text.trim(),
        scheduledDate: widget.scheduledDate,
        price: widget.budget,
        locationLat: widget.locationLat,
        locationLng: widget.locationLng,
        radiusKm: widget.radiusKm,
        requestType: Job.REQUEST_TYPE_BROADCAST,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request broadcasted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to broadcast request: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Broadcast'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow('Service', widget.service.name),
            _buildDetailRow(
              'Date',
              '${widget.scheduledDate.year}-${widget.scheduledDate.month.toString().padLeft(2, '0')}-${widget.scheduledDate.day.toString().padLeft(2, '0')}',
            ),
            _buildDetailRow(
              'Time',
              '${widget.scheduledDate.hour.toString().padLeft(2, '0')}:${widget.scheduledDate.minute.toString().padLeft(2, '0')}',
            ),
            _buildDetailRow('Duration', '${widget.hours} hours'),
            _buildDetailRow('Budget', '\$${widget.budget.toStringAsFixed(2)}'),
            _buildDetailRow(
                'Search Radius', '${widget.radiusKm.toStringAsFixed(1)} km'),
            const SizedBox(height: 24),
            Text(
              'Additional Details',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Add any specific requirements or details...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitRequest,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Broadcast Request'),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
