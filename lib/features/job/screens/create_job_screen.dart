import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/job_provider.dart';
import '../../../core/services/logger_service.dart';
import '../../../core/utils/validators.dart';

class CreateJobScreen extends StatefulWidget {
  static const String routeName = '/create-job';
  final String serviceName;

  const CreateJobScreen({
    super.key,
    required this.serviceName,
  });

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.serviceName;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final jobProvider = Provider.of<JobProvider>(context, listen: false);
      await jobProvider.createJob(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
      );

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      LoggerService.error('Failed to create job', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create job')),
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
      appBar: AppBar(title: const Text('Create Job')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: Validators.required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              validator: Validators.required,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Price is required';
                }
                final price = double.tryParse(value);
                if (price == null) {
                  return 'Please enter a valid number';
                }
                if (price < 20) {
                  return 'Minimum price is \$20';
                }
                if (price > 1000) {
                  return 'Maximum price is \$1000';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _submitForm,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Create Job'),
            ),
          ],
        ),
      ),
    );
  }
}
