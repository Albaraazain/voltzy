import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_model.dart';
import '../providers/database_provider.dart';
import '../core/services/logger_service.dart';
import '../features/homeowner/screens/broadcast_request_map_screen.dart';

class BroadcastRequestScreen extends StatefulWidget {
  final Service service;

  const BroadcastRequestScreen({
    super.key,
    required this.service,
  });

  @override
  State<BroadcastRequestScreen> createState() => _BroadcastRequestScreenState();
}

class _BroadcastRequestScreenState extends State<BroadcastRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  double _radius = 10.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.service.name;
    if (widget.service.basePrice != null) {
      _priceController.text = widget.service.basePrice!.toString();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && picked != _selectedDate) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final databaseProvider =
          Provider.of<DatabaseProvider>(context, listen: false);

      final job = await databaseProvider.createJobRequest(
        title: _titleController.text,
        description: _descriptionController.text,
        scheduledDate: _selectedDate,
        price: double.parse(_priceController.text),
        radiusKm: _radius,
        requestType: 'broadcast',
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BroadcastRequestMapScreen(
            service: widget.service,
            hours: widget.service.estimatedDuration ?? 60,
            maxBudgetPerHour: double.parse(_priceController.text),
            scheduledDate: _selectedDate,
            scheduledTime: TimeOfDay.fromDateTime(_selectedDate),
            additionalNotes: _descriptionController.text,
          ),
        ),
      );
    } catch (e, stackTrace) {
      LoggerService.error('Error creating broadcast request', e, stackTrace);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create request: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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
        title: const Text('Create Broadcast Request'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Budget',
                border: OutlineInputBorder(),
                prefixText: '\$',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your budget';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Scheduled Date & Time'),
              subtitle: Text(
                '${_selectedDate.toLocal()}'.split('.')[0],
                style: Theme.of(context).textTheme.titleMedium,
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Radius: ${_radius.toStringAsFixed(1)} km',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Slider(
                  value: _radius,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '${_radius.toStringAsFixed(1)} km',
                  onChanged: (value) {
                    setState(() {
                      _radius = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitRequest,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Create Broadcast Request'),
          ),
        ),
      ),
    );
  }
}
