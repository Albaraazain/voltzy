import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/service_repository.dart';
import '../../../models/professional_service_model.dart';
import '../../../core/services/logger_service.dart';

class EmergencySettingsScreen extends StatefulWidget {
  final ProfessionalService service;

  const EmergencySettingsScreen({
    super.key,
    required this.service,
  });

  @override
  State<EmergencySettingsScreen> createState() =>
      _EmergencySettingsScreenState();
}

class _EmergencySettingsScreenState extends State<EmergencySettingsScreen> {
  late bool _emergencyService;
  late TextEditingController _emergencyFeeController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emergencyService = widget.service.emergencyService;
    _emergencyFeeController = TextEditingController(
      text: widget.service.emergencyFee?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _emergencyFeeController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final serviceRepo =
          ServiceRepository(context.read<DatabaseProvider>().client);
      final professionalId =
          context.read<DatabaseProvider>().currentProfessional!.id;

      final emergencyFee = double.tryParse(_emergencyFeeController.text);

      await serviceRepo.updateProfessionalService(
        professionalId,
        widget.service.id,
        emergencyService: _emergencyService,
        emergencyFee: emergencyFee,
      );

      if (!mounted) return;

      await context.read<DatabaseProvider>().refreshProfessionalData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Emergency settings updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update emergency settings', e, stackTrace);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update emergency settings')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildInfoCard({
    required String title,
    required Widget child,
  }) {
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
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
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

                // Title
                Text(
                  'Emergency Service',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configure emergency service settings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Emergency Service Toggle
                _buildInfoCard(
                  title: 'Emergency Service',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Offer Emergency Service'),
                        subtitle: Text(
                          'Enable this to receive emergency service requests',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        value: _emergencyService,
                        onChanged: (value) {
                          setState(() => _emergencyService = value);
                        },
                      ),
                    ],
                  ),
                ),

                // Emergency Fee
                if (_emergencyService)
                  _buildInfoCard(
                    title: 'Emergency Fee',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _emergencyFeeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: const InputDecoration(
                            hintText: 'Enter additional fee per hour',
                            prefixText: '\$ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This fee will be added to your regular hourly rate for emergency services',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Emergency Service Info
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 24, color: Colors.amber[700]),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Emergency Service Guidelines',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.amber[900],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Emergency services require immediate response (within 2 hours). Make sure you can meet this requirement before enabling.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink[500],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
