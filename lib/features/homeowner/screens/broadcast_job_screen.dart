import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/homeowner/models/service.dart';
import '../../../core/theme/colors.dart';
import '../../../core/utils/input_validators.dart';
import 'broadcast_request_map_screen.dart';

class BroadcastJobScreen extends StatefulWidget {
  final CategoryService service;

  const BroadcastJobScreen({
    super.key,
    required this.service,
  });

  @override
  State<BroadcastJobScreen> createState() => _BroadcastJobScreenState();
}

class _BroadcastJobScreenState extends State<BroadcastJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _hoursController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Set initial hours based on service duration
    _hoursController.text = widget.service.durationHours.toString();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _hoursController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final hours = double.parse(_hoursController.text);
    final maxBudgetPerHour = double.parse(_maxBudgetController.text);
    final description = _descriptionController.text;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BroadcastRequestMapScreen(
          service: widget.service,
          hours: hours,
          maxBudgetPerHour: maxBudgetPerHour,
          description: description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Service Info Card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.service.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.service.description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Base Price: \$${widget.service.basePrice.toStringAsFixed(2)}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.primary,
                                  ),
                        ),
                        Text(
                          'Min. Duration: ${widget.service.durationHours}h',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Hours Needed
            TextFormField(
              controller: _hoursController,
              decoration: const InputDecoration(
                labelText: 'Hours Needed',
                hintText: 'Enter number of hours',
                prefixIcon: Icon(Icons.access_time),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter hours needed';
                }
                final hours = double.tryParse(value);
                if (hours == null) {
                  return 'Please enter a valid number';
                }
                if (hours < widget.service.durationHours) {
                  return 'Hours must be at least ${widget.service.durationHours}';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Max Budget per Hour
            TextFormField(
              controller: _maxBudgetController,
              decoration: const InputDecoration(
                labelText: 'Maximum Budget per Hour',
                hintText: 'Enter maximum hourly rate',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
              ],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter maximum budget per hour';
                }
                final budget = double.tryParse(value);
                if (budget == null) {
                  return 'Please enter a valid number';
                }
                if (budget < widget.service.basePrice) {
                  return 'Budget must be at least \$${widget.service.basePrice}';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Job Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Job Description',
                hintText: 'Describe your specific needs...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide a job description';
                }
                if (value.length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _onSubmit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Continue to Search'),
            ),
          ],
        ),
      ),
    );
  }
}
