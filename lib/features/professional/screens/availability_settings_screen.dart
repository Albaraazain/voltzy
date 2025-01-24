import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/schedule_provider.dart';
import '../../../providers/professional_provider.dart';
import '../../../models/working_hours_model.dart';
import '../../common/widgets/custom_button.dart';
import '../../../services/logger_service.dart';

class AvailabilitySettingsScreen extends StatefulWidget {
  const AvailabilitySettingsScreen({super.key});

  @override
  State<AvailabilitySettingsScreen> createState() =>
      _AvailabilitySettingsScreenState();
}

class _AvailabilitySettingsScreenState
    extends State<AvailabilitySettingsScreen> {
  bool _isLoading = false;
  WorkingHours? _workingHours;
  String? _updatingDay;

  @override
  void initState() {
    super.initState();
    _loadWorkingHours();
  }

  Future<void> _loadWorkingHours() async {
    setState(() => _isLoading = true);

    try {
      final professionalProvider = context.read<ProfessionalProvider>();
      final professionalId = professionalProvider.getCurrentProfessionalId();
      final workingHours = await context
          .read<ScheduleProvider>()
          .loadWorkingHours(professionalId);
      setState(() => _workingHours = workingHours);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load working hours')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateWorkingHours(
    int dayOfWeek,
    bool isEnabled,
    String? startTime,
    String? endTime,
  ) async {
    LoggerService.info('Updating working hours for day $dayOfWeek');
    LoggerService.info(
        'Current state - Enabled: $isEnabled, Start: $startTime, End: $endTime');

    // Set loading state only for this specific day
    setState(() => _updatingDay = dayOfWeek.toString());

    try {
      final professionalProvider = context.read<ProfessionalProvider>();
      final professionalId = professionalProvider.getCurrentProfessionalId();
      LoggerService.info('professional ID: $professionalId');

      // Initialize working hours if null
      _workingHours ??=
          WorkingHours.defaults(professionalId: professionalId)[0];

      // Create updated working hours
      final updatedHours = _workingHours!.copyWith(
        dayOfWeek: dayOfWeek,
        isWorkingDay: isEnabled,
        startTime: startTime ?? '09:00',
        endTime: endTime ?? '17:00',
        updatedAt: DateTime.now(),
      );

      // Convert to JSON for the API
      final workingHoursJson = updatedHours.toJson();

      // Update the database
      final updatedWorkingHours = await context
          .read<ScheduleProvider>()
          .updateWorkingHours(professionalId, workingHoursJson);

      if (mounted) {
        setState(() {
          _workingHours = updatedWorkingHours;
          _updatingDay = null;
        });
      }
    } catch (e) {
      LoggerService.error('Failed to update working hours: ${e.toString()}');
      if (mounted) {
        setState(() => _updatingDay = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update working hours: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  WorkingHours _getDaySchedule(int dayOfWeek) {
    if (_workingHours == null) {
      final professionalProvider = context.read<ProfessionalProvider>();
      final professionalId = professionalProvider.getCurrentProfessionalId();
      _workingHours = WorkingHours.defaults(professionalId: professionalId)[0];
    }
    return _workingHours!.copyWith(dayOfWeek: dayOfWeek);
  }

  Widget _buildDaySettings(int dayOfWeek) {
    final schedule = _getDaySchedule(dayOfWeek);
    final isEnabled = schedule.isWorkingDay;
    final isUpdating = _updatingDay == dayOfWeek.toString();
    final dayName = WorkingHours.getDayName(dayOfWeek);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  dayName,
                  style: AppTextStyles.h3,
                ),
                if (isUpdating)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                else
                  Switch(
                    value: isEnabled,
                    onChanged: (value) {
                      LoggerService.info(
                          'Switch toggled to: $value for $dayName');
                      _updateWorkingHours(
                        dayOfWeek,
                        value,
                        value ? '09:00' : null,
                        value ? '17:00' : null,
                      );
                    },
                    activeColor: AppColors.accent,
                    inactiveTrackColor: Colors.grey[300],
                  ),
              ],
            ),
            if (isEnabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Time',
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: int.parse(
                                    schedule.startTime.split(':')[0] ?? '9'),
                                minute: int.parse(
                                    schedule.startTime.split(':')[1] ?? '0'),
                              ),
                            );
                            if (time != null) {
                              _updateWorkingHours(
                                dayOfWeek,
                                true,
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                                schedule.endTime,
                              );
                            }
                          },
                          text: schedule.startTime ?? '09:00',
                          type: ButtonType.secondary,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'End Time',
                          style: AppTextStyles.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CustomButton(
                          onPressed: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: int.parse(
                                    schedule.endTime.split(':')[0] ?? '17'),
                                minute: int.parse(
                                    schedule.endTime.split(':')[1] ?? '0'),
                              ),
                            );
                            if (time != null) {
                              _updateWorkingHours(
                                dayOfWeek,
                                true,
                                schedule.startTime,
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                              );
                            }
                          },
                          text: schedule.endTime ?? '17:00',
                          type: ButtonType.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Working Hours'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: 7,
              itemBuilder: (context, index) => _buildDaySettings(index),
            ),
    );
  }
}
