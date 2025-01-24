import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/schedule_slot_model.dart';
import '../widgets/availability_viewer.dart';

class ProfessionalProfileViewScreen extends StatefulWidget {
  final String professionalId;

  const ProfessionalProfileViewScreen({
    super.key,
    required this.professionalId,
  });

  @override
  State<ProfessionalProfileViewScreen> createState() =>
      _ProfessionalProfileViewScreenState();
}

class _ProfessionalProfileViewScreenState
    extends State<ProfessionalProfileViewScreen> {
  final bool _isLoading = false;

  void _handleSlotSelected(ScheduleSlot slot) {
    Navigator.pushNamed(
      context,
      '/book_appointment',
      arguments: {
        'professionalId': widget.professionalId,
        'slot': slot,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text(
          'Book Appointment',
          style: AppTextStyles.h2,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : AvailabilityViewer(
              professionalId: widget.professionalId,
              onSlotSelected: _handleSlotSelected,
            ),
    );
  }
}
