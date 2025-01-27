import 'package:flutter/foundation.dart';
import '../models/professional_model.dart';
import '../models/professional_service_model.dart';
import '../core/services/logger_service.dart';
import 'database_provider.dart';

class ProfessionalProvider extends ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  Professional? _professional;
  bool _isLoading = false;

  ProfessionalProvider(this._databaseProvider) {
    _initialize();
  }

  Professional? get professional => _professional;
  List<ProfessionalService> get services => _professional?.services ?? [];
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    await refreshProfessionalData();
  }

  Future<void> refreshProfessionalData() async {
    try {
      _isLoading = true;
      notifyListeners();

      _professional = await _databaseProvider.getCurrentProfessional();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to refresh professional data', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleAvailability() async {
    try {
      if (_professional == null) {
        throw Exception('No professional logged in');
      }

      await _databaseProvider.updateProfessionalAvailability(
        _professional!.id,
        !_professional!.isAvailable,
      );

      await refreshProfessionalData();
    } catch (e) {
      LoggerService.error('Failed to toggle availability', e);
      rethrow;
    }
  }

  String getCurrentProfessionalId() {
    if (_professional == null) {
      throw Exception('No professional logged in');
    }
    return _professional!.id;
  }
}
