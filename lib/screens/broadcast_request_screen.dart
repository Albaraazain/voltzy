import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../features/homeowner/models/service.dart';
import '../providers/database_provider.dart';
import '../core/services/logger_service.dart';
import '../features/homeowner/screens/broadcast_request_map_screen.dart';
import '../features/homeowner/screens/broadcast_job_screen.dart';

class BroadcastRequestScreen extends StatefulWidget {
  final CategoryService service;

  const BroadcastRequestScreen({
    super.key,
    required this.service,
  });

  @override
  State<BroadcastRequestScreen> createState() => _BroadcastRequestScreenState();
}

class _BroadcastRequestScreenState extends State<BroadcastRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _broadcastRequest() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final databaseProvider = context.read<DatabaseProvider>();
      final homeowner = databaseProvider.currentHomeowner;

      if (homeowner == null) {
        throw Exception('No homeowner profile found');
      }

      final scheduledFor = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BroadcastJobScreen(
            service: widget.service,
          ),
        ),
      );
    } catch (e) {
      LoggerService.error('Failed to broadcast request', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to broadcast request. Please try again.'),
            backgroundColor: Colors.red,
          ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Broadcast Request'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              widget.service.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              widget.service.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                Text(
                  'Duration: ${widget.service.durationHours} hours',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.attach_money),
                const SizedBox(width: 8),
                Text(
                  'Base Price: \$${widget.service.basePrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Additional Details',
                hintText: 'Describe your specific needs...',
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please provide some details';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Preferred Date'),
              subtitle: Text(
                '${_selectedDate.year}-${_selectedDate.month}-${_selectedDate.day}',
              ),
              onTap: _selectDate,
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Preferred Time'),
              subtitle: Text(_selectedTime.format(context)),
              onTap: _selectTime,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _broadcastRequest,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
