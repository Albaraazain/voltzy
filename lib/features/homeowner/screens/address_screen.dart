import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voltz/features/common/widgets/custom_text_field.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../providers/database_provider.dart';
import '../../common/widgets/custom_button.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _zipController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final homeowner = context.read<DatabaseProvider>().currentHomeowner;
    final address = homeowner?.address ?? '';

    // Parse address if exists
    final addressParts = address.split(', ');
    _streetController = TextEditingController(
      text: addressParts.isNotEmpty ? addressParts[0] : '',
    );
    _cityController = TextEditingController(
      text: addressParts.length > 1 ? addressParts[1] : '',
    );
    _stateController = TextEditingController(
      text: addressParts.length > 2 ? addressParts[2] : '',
    );
    _zipController = TextEditingController(
      text: addressParts.length > 3 ? addressParts[3] : '',
    );
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final address = [
        _streetController.text,
        _cityController.text,
        _stateController.text,
        _zipController.text,
      ].join(', ');

      await context.read<DatabaseProvider>().updateHomeownerAddress(address);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving address: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Address',
          style: AppTextStyles.h2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Address',
                style: AppTextStyles.h3,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                controller: _streetController,
                label: 'Street Address',
                hint: 'Enter your street address',
                validator: (value) => value?.isEmpty ?? true
                    ? 'Street address is required'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter your city',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'City is required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stateController,
                      label: 'State',
                      hint: 'Enter state',
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'State is required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _zipController,
                      label: 'ZIP Code',
                      hint: 'Enter ZIP code',
                      keyboardType: TextInputType.number,
                      validator: (value) => value?.isEmpty ?? true
                          ? 'ZIP code is required'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              CustomButton(
                onPressed: _isLoading ? () {} : _saveChanges,
                text: 'Save Changes',
                isLoading: _isLoading,
                type: ButtonType.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
