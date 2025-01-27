import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/database_provider.dart';
import '../../../repositories/service_repository.dart';
import '../../../models/professional_service_model.dart';
import '../../../core/services/logger_service.dart';

class EditProfessionalServiceScreen extends StatefulWidget {
  final ProfessionalService service;

  const EditProfessionalServiceScreen({
    super.key,
    required this.service,
  });

  @override
  State<EditProfessionalServiceScreen> createState() =>
      _EditProfessionalServiceScreenState();
}

class _EditProfessionalServiceScreenState
    extends State<EditProfessionalServiceScreen> {
  late TextEditingController _priceController;
  late TextEditingController _durationController;
  late TextEditingController _emergencyFeeController;
  late List<String> _serviceTags;
  late List<String> _requirements;
  late Map<String, dynamic> _availabilitySchedule;
  late Map<String, dynamic> _serviceArea;
  bool _isActive = true;
  bool _emergencyService = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(
      text: widget.service.customPrice?.toString() ??
          widget.service.baseService.basePrice.toString(),
    );
    _durationController = TextEditingController(
      text: widget.service.customDuration?.toString() ??
          widget.service.baseService.durationHours.toString(),
    );
    _emergencyFeeController = TextEditingController(
      text: widget.service.emergencyFee?.toString() ?? '',
    );
    _serviceTags = List.from(widget.service.serviceTags);
    _requirements = List.from(widget.service.requirements);
    _availabilitySchedule = Map.from(widget.service.availabilitySchedule ??
        {
          'weekdays': {'start': '08:00', 'end': '18:00'},
          'weekend': {'start': '09:00', 'end': '17:00'}
        });
    _serviceArea = Map.from(widget.service.serviceArea ??
        {'radius': 25, 'center': 'Boston', 'unit': 'miles'});
    _isActive = widget.service.isActive;
    _emergencyService = widget.service.emergencyService;
  }

  @override
  void dispose() {
    _priceController.dispose();
    _durationController.dispose();
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

      final customPrice = double.tryParse(_priceController.text);
      final customDuration = double.tryParse(_durationController.text);
      final emergencyFee = double.tryParse(_emergencyFeeController.text);

      await serviceRepo.updateProfessionalService(
        professionalId,
        widget.service.id,
        customPrice: customPrice,
        customDuration: customDuration,
        isActive: _isActive,
        availabilitySchedule: _availabilitySchedule,
        serviceArea: _serviceArea,
        serviceTags: _serviceTags,
        emergencyService: _emergencyService,
        emergencyFee: emergencyFee,
        requirements: _requirements,
      );

      if (!mounted) return;

      await context.read<DatabaseProvider>().refreshProfessionalData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service updated successfully')),
      );
      Navigator.of(context).pop();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to update service', e, stackTrace);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update service')),
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

  Widget _buildTagInput() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ..._serviceTags.map((tag) => Chip(
              label: Text(tag),
              onDeleted: () {
                setState(() {
                  _serviceTags.remove(tag);
                });
              },
            )),
        ActionChip(
          label: const Text('Add Tag'),
          onPressed: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (context) => _AddTagDialog(),
            );
            if (result != null && result.isNotEmpty) {
              setState(() {
                _serviceTags.add(result);
              });
            }
          },
        ),
      ],
    );
  }

  Widget _buildRequirementsList() {
    return Column(
      children: [
        ..._requirements.asMap().entries.map((entry) {
          final index = entry.key;
          final requirement = entry.value;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(requirement),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                setState(() {
                  _requirements.removeAt(index);
                });
              },
            ),
          );
        }),
        TextButton.icon(
          onPressed: () async {
            final result = await showDialog<String>(
              context: context,
              builder: (context) => _AddRequirementDialog(),
            );
            if (result != null && result.isNotEmpty) {
              setState(() {
                _requirements.add(result);
              });
            }
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Requirement'),
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
                  widget.service.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Customize your service details',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Price Input
                _buildInfoCard(
                  title: 'Service Rate',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,2}')),
                        ],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          prefixText: '\$ ',
                          prefixStyle: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Text(
                        'Base rate: \$${widget.service.baseService.basePrice}/hour',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Duration Input
                _buildInfoCard(
                  title: 'Service Duration',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _durationController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'^\d*\.?\d{0,1}')),
                        ],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          suffixText: ' hours',
                          suffixStyle: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      Text(
                        'Base duration: ${widget.service.baseService.durationHours} hours',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Service Tags
                _buildInfoCard(
                  title: 'Service Tags',
                  child: _buildTagInput(),
                ),

                // Service Requirements
                _buildInfoCard(
                  title: 'Service Requirements',
                  child: _buildRequirementsList(),
                ),

                // Service Area
                _buildInfoCard(
                  title: 'Service Area',
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _serviceArea['center'] as String,
                        onChanged: (value) {
                          setState(() {
                            _serviceArea['center'] = value;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Service Center',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue:
                                  (_serviceArea['radius'] as num).toString(),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                setState(() {
                                  _serviceArea['radius'] =
                                      int.tryParse(value) ?? 25;
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Radius',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _serviceArea['unit'] as String,
                              items: ['miles', 'kilometers']
                                  .map((unit) => DropdownMenuItem(
                                        value: unit,
                                        child: Text(unit),
                                      ))
                                  .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _serviceArea['unit'] = value;
                                  });
                                }
                              },
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Emergency Service
                _buildInfoCard(
                  title: 'Emergency Service',
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Offer Emergency Service'),
                        value: _emergencyService,
                        onChanged: (value) {
                          setState(() {
                            _emergencyService = value;
                          });
                        },
                      ),
                      if (_emergencyService)
                        TextFormField(
                          controller: _emergencyFeeController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d{0,2}')),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Emergency Fee (per hour)',
                            prefixText: '\$ ',
                            border: OutlineInputBorder(),
                          ),
                        ),
                    ],
                  ),
                ),

                // Active Status
                _buildInfoCard(
                  title: 'Service Status',
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Service Active'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
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

class _AddTagDialog extends StatefulWidget {
  @override
  _AddTagDialogState createState() => _AddTagDialogState();
}

class _AddTagDialogState extends State<_AddTagDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Tag'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter tag name',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _AddRequirementDialog extends StatefulWidget {
  @override
  _AddRequirementDialogState createState() => _AddRequirementDialogState();
}

class _AddRequirementDialogState extends State<_AddRequirementDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Requirement'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Enter requirement',
        ),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
