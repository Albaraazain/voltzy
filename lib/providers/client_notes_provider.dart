import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/client_note_model.dart';
import '../models/client_service_history_model.dart';

class ClientNotesProvider extends ChangeNotifier {
  final SupabaseClient _client = SupabaseConfig.client;

  List<ClientNote> _notes = [];
  List<ClientServiceHistory> _serviceHistory = [];
  bool _isLoading = false;
  String? _error;

  List<ClientNote> get notes => _notes;
  List<ClientServiceHistory> get serviceHistory => _serviceHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadClientNotes(
      String homeownerId, String professionalId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('client_notes')
          .select()
          .eq('homeowner_id', homeownerId)
          .eq('professional_id', professionalId)
          .order('created_at', ascending: false);

      _notes = response
          .map<ClientNote>((json) => ClientNote.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _error = 'Failed to load client notes';
      LoggerService.error('Failed to load client notes', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadServiceHistory(
      String homeownerId, String professionalId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('client_service_history')
          .select()
          .eq('homeowner_id', homeownerId)
          .eq('professional_id', professionalId)
          .order('service_date', ascending: false);

      _serviceHistory = response
          .map<ClientServiceHistory>(
              (json) => ClientServiceHistory.fromJson(json))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _error = 'Failed to load service history';
      LoggerService.error('Failed to load service history', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addClientNote({
    required String homeownerId,
    required String professionalId,
    required String title,
    required String content,
    required String category,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('client_notes')
          .insert({
            'homeowner_id': homeownerId,
            'professional_id': professionalId,
            'title': title,
            'content': content,
            'category': category,
          })
          .select()
          .single();

      final newNote = ClientNote.fromJson(response);
      _notes.insert(0, newNote);

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _error = 'Failed to add client note';
      LoggerService.error('Failed to add client note', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addServiceHistory({
    required String homeownerId,
    required String professionalId,
    required String serviceName,
    required double amount,
    required String status,
    required DateTime serviceDate,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _client
          .from('client_service_history')
          .insert({
            'homeowner_id': homeownerId,
            'professional_id': professionalId,
            'service_name': serviceName,
            'amount': amount,
            'status': status,
            'service_date': serviceDate.toIso8601String(),
          })
          .select()
          .single();

      final newHistory = ClientServiceHistory.fromJson(response);
      _serviceHistory.insert(0, newHistory);

      _isLoading = false;
      notifyListeners();
    } catch (e, stackTrace) {
      _isLoading = false;
      _error = 'Failed to add service history';
      LoggerService.error('Failed to add service history', e, stackTrace);
      notifyListeners();
      rethrow;
    }
  }
}
