import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/service_repository.dart';
import '../../../models/professional_service_model.dart';
import '../../../core/services/logger_service.dart';

class AvailabilitySettingsScreen extends StatefulWidget {
  final ProfessionalService service;

  const AvailabilitySettingsScreen({
    super.key,
    required this.service,
  });

  @override
  State<AvailabilitySettingsScreen> createState() =>
      _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState
    extends State<AvailabilitySettingsScreen> {
  late Map<String, dynamic> _availabilitySchedule;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _availabilitySchedule = Map.from(widget.service.availabilitySchedule ??
        {
          'weekdays': {'start': '08:00', 'end': '18:00'},
          'weekend': {'start': '09:00', 'end': '17:00'}
        });
  }

  Future<void> _saveChanges() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final serviceRepo =
          ServiceRepository(context.read<DatabaseProvider>().client);
      final professionalId =
          context.read<DatabaseProvider>().currentProfessional!.id;

      await serviceRepo.updateProfessionalService(
        professionalId,
        widget.service.id,
        availabilitySchedule: _availabilitySchedule,
      );

      if (!mounted) return;

      await context.read<DatabaseProvider>().refreshProfessionalData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Availability updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update availability', e, stackTrace);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update availability')),
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

  Widget _buildTimeRangePicker({
    required String title,
    required String startTime,
    required String endTime,
    required Function(String) onStartTimeChanged,
    required Function(String) onEndTimeChanged,
  }) {
    return Column(
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
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(startTime.split(':')[0]),
                      minute: int.parse(startTime.split(':')[1]),
                    ),
                  );
                  if (time != null) {
                    onStartTimeChanged(
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.access_time, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'to',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: int.parse(endTime.split(':')[0]),
                      minute: int.parse(endTime.split(':')[1]),
                    ),
                  );
                  if (time != null) {
                    onEndTimeChanged(
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        endTime,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(Icons.access_time, color: Colors.grey[600]),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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
                  'Availability Settings',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Set your working hours for this service',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Weekday Hours
                _buildInfoCard(
                  title: 'Weekday Hours',
                  child: _buildTimeRangePicker(
                    title: 'Monday - Friday',
                    startTime: (_availabilitySchedule['weekdays']
                            as Map<String, dynamic>)['start'] as String? ??
                        '08:00',
                    endTime: (_availabilitySchedule['weekdays']
                            as Map<String, dynamic>)['end'] as String? ??
                        '18:00',
                    onStartTimeChanged: (value) {
                      setState(() {
                        (_availabilitySchedule['weekdays']
                            as Map<String, dynamic>)['start'] = value;
                      });
                    },
                    onEndTimeChanged: (value) {
                      setState(() {
                        (_availabilitySchedule['weekdays']
                            as Map<String, dynamic>)['end'] = value;
                      });
                    },
                  ),
                ),

                // Weekend Hours
                _buildInfoCard(
                  title: 'Weekend Hours',
                  child: _buildTimeRangePicker(
                    title: 'Saturday - Sunday',
                    startTime: (_availabilitySchedule['weekend']
                            as Map<String, dynamic>)['start'] as String? ??
                        '09:00',
                    endTime: (_availabilitySchedule['weekend']
                            as Map<String, dynamic>)['end'] as String? ??
                        '17:00',
                    onStartTimeChanged: (value) {
                      setState(() {
                        (_availabilitySchedule['weekend']
                            as Map<String, dynamic>)['start'] = value;
                      });
                    },
                    onEndTimeChanged: (value) {
                      setState(() {
                        (_availabilitySchedule['weekend']
                            as Map<String, dynamic>)['end'] = value;
                      });
                    },
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
