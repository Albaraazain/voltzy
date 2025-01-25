import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/payment_info_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/database_provider.dart';
import '../../common/widgets/custom_button.dart';
import '../../common/widgets/custom_text_field.dart';

class PaymentSettingsScreen extends StatefulWidget {
  const PaymentSettingsScreen({super.key});

  @override
  State<PaymentSettingsScreen> createState() => _PaymentSettingsScreenState();
}

class _PaymentSettingsScreenState extends State<PaymentSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _routingNumberController = TextEditingController();
  bool _isLoading = false;
  String _selectedAccountType = 'Checking';

  @override
  void initState() {
    super.initState();
    _loadPaymentInfo();
  }

  Future<void> _loadPaymentInfo() async {
    try {
      setState(() => _isLoading = true);
      final dbProvider = context.read<DatabaseProvider>();

      // Load professional data if not already loaded
      if (dbProvider.professionals.isEmpty) {
        await dbProvider.loadProfessionals();
      }

      final professional = dbProvider.professionals.first;

      // Update controllers with payment info data
      setState(() {
        _accountNameController.text =
            professional.paymentInfo?.accountName ?? '';
        _accountNumberController.text =
            professional.paymentInfo?.accountNumber ?? '';
        _bankNameController.text = professional.paymentInfo?.bankName ?? '';
        _routingNumberController.text =
            professional.paymentInfo?.routingNumber ?? '';
        _selectedAccountType =
            professional.paymentInfo?.accountType ?? 'Checking';
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load payment info')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _savePaymentInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final paymentInfo = PaymentInfo(
        id: const Uuid().v4(),
        userId: context.read<AuthProvider>().userId,
        accountName: _accountNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        bankName: _bankNameController.text.trim(),
        routingNumber: _routingNumberController.text.trim(),
        accountType: _selectedAccountType,
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final dbProvider = context.read<DatabaseProvider>();
      await dbProvider.updatePaymentInfo(paymentInfo);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment info updated successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update payment info')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _bankNameController.dispose();
    _routingNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: Text('Payment Settings', style: AppTextStyles.h2),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bank Account Information', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _accountNameController,
                label: 'Account Holder Name',
                hint: 'Enter account holder name',
                validator: (value) => value?.isEmpty ?? true
                    ? 'Account holder name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _accountNumberController,
                label: 'Account Number',
                hint: 'Enter account number',
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Account number is required'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _bankNameController,
                label: 'Bank Name',
                hint: 'Enter bank name',
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Bank name is required' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _routingNumberController,
                label: 'Routing Number',
                hint: 'Enter routing number',
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true
                    ? 'Routing number is required'
                    : null,
              ),
              const SizedBox(height: 16),
              Text('Account Type', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedAccountType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: ['Checking', 'Savings'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedAccountType = value);
                  }
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                onPressed: _isLoading ? () {} : _savePaymentInfo,
                text: _isLoading ? 'Saving...' : 'Save Changes',
                type: ButtonType.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
