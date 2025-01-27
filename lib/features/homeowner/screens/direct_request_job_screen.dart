import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/professional_model.dart';
import '../../../models/service_model.dart';
import '../../../models/job_model.dart';
import '../../../providers/database_provider.dart';

class DirectRequestJobScreen extends StatefulWidget {
  final Professional professional;
  final Service service;
  final DateTime scheduledDate;
  final int hours;
  final double budget;

  const DirectRequestJobScreen({
    super.key,
    required this.professional,
    required this.service,
    required this.scheduledDate,
    required this.hours,
    required this.budget,
  });

  @override
  State<DirectRequestJobScreen> createState() => _DirectRequestJobScreenState();
}

class _DirectRequestJobScreenState extends State<DirectRequestJobScreen> {
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
        professionalId: widget.professional.id,
        requestType: Job.REQUEST_TYPE_DIRECT,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Request sent successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send request: $e'),
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
        title: const Text('Review Request'),
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
            _buildDetailRow('Professional',
                widget.professional.profile?.name ?? 'Professional'),
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
                : const Text('Send Request'),
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
