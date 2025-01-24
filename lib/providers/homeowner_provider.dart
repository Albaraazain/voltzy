import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/config/supabase_config.dart';
import '../core/services/logger_service.dart';
import '../models/job_model.dart';
import 'database_provider.dart';

class HomeownerProvider extends ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  final SupabaseClient _client = SupabaseConfig.client;

  List<String> _savedProfessionals = [];
  List<Job> _activeJobs = [];
  bool _isLoading = false;

  HomeownerProvider(this._databaseProvider) {
    _initialize();
  }

  List<String> get savedProfessionals => _savedProfessionals;
  List<Job> get activeJobs => _activeJobs;
  bool get isLoading => _isLoading;

  Future<void> _initialize() async {
    await Future.wait([
      loadSavedProfessionals(),
      loadActiveJobs(),
    ]);
  }

  Future<void> loadSavedProfessionals() async {
    try {
      _isLoading = true;
      notifyListeners();

      final homeownerId = _databaseProvider.currentHomeowner?.id;
      if (homeownerId == null) throw Exception('No homeowner found');

      final response = await _client
          .from('saved_professionals')
          .select('professional_id')
          .eq('homeowner_id', homeownerId);

      _savedProfessionals = List<String>.from(
        response.map((item) => item['professional_id'] as String),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load saved professionals', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadActiveJobs() async {
    try {
      _isLoading = true;
      notifyListeners();

      final homeownerId = _databaseProvider.currentHomeowner?.id;
      if (homeownerId == null) throw Exception('No homeowner found');

      final response = await _client
          .from('jobs')
          .select('''
            *,
            professional:professionals (
              *,
              profile:profiles (*)
            )
          ''')
          .eq('homeowner_id', homeownerId)
          .neq('status', 'completed')
          .order('created_at', ascending: false);

      _activeJobs = response.map((job) => Job.fromJson(job)).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load active jobs', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> addSavedProfessional(String professionalId) async {
    try {
      final homeownerId = _databaseProvider.currentHomeowner?.id;
      if (homeownerId == null) throw Exception('No homeowner found');

      await _client.from('saved_professionals').insert({
        'homeowner_id': homeownerId,
        'professional_id': professionalId,
      });

      await loadSavedProfessionals();
    } catch (e) {
      LoggerService.error('Failed to add saved professional', e);
      rethrow;
    }
  }

  Future<void> removeSavedProfessional(String professionalId) async {
    try {
      final homeownerId = _databaseProvider.currentHomeowner?.id;
      if (homeownerId == null) throw Exception('No homeowner found');

      await _client.from('saved_professionals').delete().match({
        'homeowner_id': homeownerId,
        'professional_id': professionalId,
      });

      await loadSavedProfessionals();
    } catch (e) {
      LoggerService.error('Failed to remove saved professional', e);
      rethrow;
    }
  }

  Future<Job> createJob({
    required String title,
    required String description,
    required DateTime date,
    required double price,
    String? professionalId,
  }) async {
    try {
      final homeownerId = _databaseProvider.currentHomeowner?.id;
      if (homeownerId == null) throw Exception('No homeowner found');

      final response = await _client
          .from('jobs')
          .insert({
            'title': title,
            'description': description,
            'status': 'pending',
            'date': date.toIso8601String(),
            'homeowner_id': homeownerId,
            'professional_id': professionalId,
            'price': price,
          })
          .select()
          .single();

      final job = Job.fromJson(response);
      _activeJobs.insert(0, job);
      notifyListeners();
      return job;
    } catch (e) {
      LoggerService.error('Failed to create job', e);
      rethrow;
    }
  }

  Future<void> cancelJob(String jobId) async {
    try {
      await _client
          .from('jobs')
          .update({'status': 'cancelled'}).eq('id', jobId);

      await loadActiveJobs();
    } catch (e) {
      LoggerService.error('Failed to cancel job', e);
      rethrow;
    }
  }

  String getCurrentHomeownerId() {
    if (_databaseProvider.currentHomeowner == null) {
      throw Exception('No homeowner is currently logged in');
    }
    return _databaseProvider.currentHomeowner!.id;
  }
}
