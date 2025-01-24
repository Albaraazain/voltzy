import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/text_styles.dart';
import '../../../models/payment_model.dart';
import '../../../providers/payment_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../common/widgets/custom_button.dart';
import '../../../widgets/loading_overlay.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId != null) {
      await context.read<PaymentProvider>().loadPaymentMethods(userId);
    }
  }

  Widget _buildPaymentMethodCard({
    required PaymentMethodModel method,
    required VoidCallback onTap,
  }) {
    IconData icon;
    switch (method.type) {
      case PaymentMethod.creditCard:
      case PaymentMethod.debitCard:
        icon = Icons.credit_card;
        break;
      case PaymentMethod.bankTransfer:
        icon = Icons.account_balance;
        break;
      case PaymentMethod.wallet:
        icon = Icons.account_balance_wallet;
        break;
      case PaymentMethod.applePay:
        icon = Icons.apple;
        break;
      case PaymentMethod.googlePay:
        icon = Icons.android;
        break;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: method.isDefault ? AppColors.accent : AppColors.border,
          width: method.isDefault ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.brand,
                      style: AppTextStyles.subtitle1,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      method.maskedNumber,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (method.expiryDate.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Expires ${method.expiryDate}',
                        style: AppTextStyles.caption.copyWith(
                          color: method.isExpired
                              ? AppColors.error
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (method.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Default',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPaymentMethod() async {
    // TODO: Implement add payment method with Stripe SDK
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please sign in to add a payment method')),
        );
      }
      return;
    }

    try {
      // This would typically integrate with Stripe SDK
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method added successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding payment method: $e')),
        );
      }
    }
  }

  Future<void> _setDefaultPaymentMethod(PaymentMethodModel method) async {
    try {
      await context.read<PaymentProvider>().setDefaultPaymentMethod(method.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default payment method updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating default payment method: $e')),
        );
      }
    }
  }

  Future<void> _removePaymentMethod(PaymentMethodModel method) async {
    try {
      await context.read<PaymentProvider>().removePaymentMethod(method.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method removed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing payment method: $e')),
        );
      }
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
          'Payment Methods',
          style: AppTextStyles.h2,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, paymentProvider, child) {
          if (paymentProvider.isLoading) {
            return const LoadingOverlay();
          }

          final paymentMethods = paymentProvider.paymentMethods;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Payment Methods',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 8),
                Text(
                  'Manage your payment methods for job payments and transactions.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 24),
                if (paymentMethods.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.credit_card_off,
                          size: 64,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No payment methods added yet',
                          style: AppTextStyles.subtitle1.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: paymentMethods.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final method = paymentMethods[index];
                      return _buildPaymentMethodCard(
                        method: method,
                        onTap: () => showModalBottomSheet(
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!method.isDefault)
                                ListTile(
                                  leading: const Icon(Icons.check_circle),
                                  title: const Text('Set as default'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _setDefaultPaymentMethod(method);
                                  },
                                ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('Remove'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _removePaymentMethod(method);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 32),
                Text(
                  'Add New Payment Method',
                  style: AppTextStyles.h3,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  onPressed: _addPaymentMethod,
                  text: 'Add Payment Method',
                  type: ButtonType.primary,
                  icon: Icons.add,
                ),
                const SizedBox(height: 24),
                Text(
                  'Your payment information is securely stored and encrypted.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
