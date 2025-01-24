import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/payment_model.dart';
import '../services/payment_service.dart';
import '../core/constants/config.dart';
import '../services/logger_service.dart';
import '../core/utils/api_response.dart';

class PaymentProvider with ChangeNotifier {
  final SupabaseClient _supabase;
  final List<PaymentMethodModel> _paymentMethods = [];
  final List<PaymentModel> _transactions = [];
  PaymentMethodModel? _selectedPaymentMethod;
  bool _isLoading = false;

  PaymentProvider(this._supabase);

  List<PaymentMethodModel> get paymentMethods => _paymentMethods;
  List<PaymentModel> get transactions => _transactions;
  PaymentMethodModel? get selectedPaymentMethod => _selectedPaymentMethod;
  bool get isLoading => _isLoading;

  Future<ApiResponse<void>> loadPaymentMethods(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('payment_methods')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _paymentMethods.clear();
      for (final method in response) {
        _paymentMethods.add(PaymentMethodModel.fromJson(method));
      }

      // Set default payment method
      _selectedPaymentMethod = _paymentMethods.firstWhere(
        (method) => method.isDefault,
        orElse: () => _paymentMethods.isEmpty
            ? throw Exception('No payment methods found')
            : _paymentMethods.first,
      );

      notifyListeners();
      return ApiResponse.success(null);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      LoggerService.error('Error loading payment methods: $e');
      return ApiResponse.error('Failed to load payment methods');
    }
  }

  Future<void> loadTransactions(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('payments')
          .select()
          .or('user_id.eq.$userId,professional_id.eq.$userId')
          .order('timestamp', ascending: false);

      _transactions.clear();
      for (final transaction in response) {
        _transactions.add(PaymentModel.fromJson(transaction));
      }

      notifyListeners();
    } catch (e) {
      LoggerService.error('Error loading transactions: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addPaymentMethod(PaymentMethodModel method) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase
          .from('payment_methods')
          .insert(method.toJson())
          .select()
          .single();
      final newMethod = PaymentMethodModel.fromJson(response);

      _paymentMethods.add(newMethod);
      if (newMethod.isDefault || _paymentMethods.length == 1) {
        _selectedPaymentMethod = newMethod;
      }

      notifyListeners();
    } catch (e) {
      LoggerService.error('Error adding payment method: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removePaymentMethod(String methodId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.from('payment_methods').delete().eq('id', methodId);

      _paymentMethods.removeWhere((method) => method.id == methodId);
      if (_selectedPaymentMethod?.id == methodId) {
        _selectedPaymentMethod =
            _paymentMethods.isNotEmpty ? _paymentMethods.first : null;
      }

      notifyListeners();
    } catch (e) {
      LoggerService.error('Error removing payment method: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setDefaultPaymentMethod(String methodId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update the database
      if (_selectedPaymentMethod?.userId != null) {
        await _supabase
            .from('payment_methods')
            .update({'is_default': false}).eq(
                'user_id', _selectedPaymentMethod!.userId);
      }
      await _supabase
          .from('payment_methods')
          .update({'is_default': true}).eq('id', methodId);

      // Update local state
      for (var method in _paymentMethods) {
        if (method.id == methodId) {
          _selectedPaymentMethod = method.copyWith(isDefault: true);
          break;
        }
      }

      notifyListeners();
    } catch (e) {
      LoggerService.error('Error setting default payment method: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<ApiResponse<PaymentModel>> processPayment({
    required String jobId,
    required double amount,
    required String paymentMethodId,
    required String professionalId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Calculate fees
      final serviceFee = amount * Config.SERVICE_FEE_PERCENTAGE;
      final platformFee = amount * Config.PLATFORM_FEE_PERCENTAGE;
      final tax = amount * Config.TAX_RATE;
      final total = amount + serviceFee + platformFee + tax;

      // Process payment
      final success = await PaymentService.processPayment(
        userId: _selectedPaymentMethod!.userId,
        amount: total,
        paymentMethodId: paymentMethodId,
      );

      if (!success) {
        return ApiResponse.error('Payment processing failed');
      }

      // Create payment record
      final savedPayment = PaymentModel(
        id: 'pmt_${DateTime.now().millisecondsSinceEpoch}',
        jobId: jobId,
        userId: _selectedPaymentMethod!.userId,
        professionalId: professionalId,
        amount: amount,
        serviceFee: serviceFee,
        platformFee: platformFee,
        tax: tax,
        total: total,
        timestamp: DateTime.now(),
        status: PaymentStatus.completed,
        method: PaymentMethod.creditCard,
        transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      // Save payment to database
      await _supabase.from('payments').insert(savedPayment.toJson());

      _isLoading = false;
      notifyListeners();

      return ApiResponse.success(savedPayment);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      LoggerService.error('Error processing payment: $e');
      return ApiResponse.error('Failed to process payment');
    }
  }

  Future<bool> refundPayment(String paymentId, double amount,
      {String? reason}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final success = await PaymentService.refundPayment(
        paymentId: paymentId,
        amount: amount,
        reason: reason,
      );

      if (success) {
        // Update payment status in database
        await _supabase.from('payments').update({
          'status': PaymentStatus.refunded.toString().split('.').last
        }).eq('id', paymentId);

        // Update local state
        final index = _transactions.indexWhere((p) => p.id == paymentId);
        if (index != -1) {
          _transactions[index] = _transactions[index].copyWith(
            status: PaymentStatus.refunded,
          );
          notifyListeners();
        }
      }

      return success;
    } catch (e) {
      LoggerService.error('Error processing refund: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
