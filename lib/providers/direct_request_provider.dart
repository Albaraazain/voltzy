import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/direct_request_model.dart';
import '../services/logger_service.dart';

class DirectRequestProvider extends ChangeNotifier {
  final List<DirectRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  List<DirectRequest> get requests => List.unmodifiable(_requests);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<DirectRequest> get pendingRequests => _requests
      .where((request) =>
          request.status == DirectRequest.STATUS_AWAITING_ACCEPTANCE)
      .toList();

  List<DirectRequest> get acceptedRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_SCHEDULED)
      .toList();

  List<DirectRequest> get inProgressRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_STARTED)
      .toList();

  List<DirectRequest> get completedRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_COMPLETED)
      .toList();

  List<DirectRequest> get cancelledRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_CANCELLED)
      .toList();

  List<DirectRequest> get declinedRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_CANCELLED)
      .toList();

  Future<void> loadProfessionalRequests() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await Supabase.instance.client.from('direct_requests').select('''
            *,
            homeowner:homeowner_id(
              *,
              profile:profiles (*)
            ),
            professional:professional_id(
              *,
              profile:profiles (*)
            )
          ''').order('created_at', ascending: false);

      final List<DirectRequest> requests = (response as List)
          .map((json) => DirectRequest.fromJson(json))
          .toList();

      _requests.clear();
      _requests.addAll(requests);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHomeownerRequests(String homeownerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('direct_requests')
          .select('''
            *,
            homeowner:homeowner_id(
              *,
              profile:profiles (*)
            ),
            professional:professional_id(
              *,
              profile:profiles (*)
            )
          ''')
          .eq('homeowner_id', homeownerId)
          .order('created_at', ascending: false);

      final List<DirectRequest> requests = (response as List)
          .map((json) => DirectRequest.fromJson(json))
          .toList();

      _requests.clear();
      _requests.addAll(requests);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDirectRequest({
    required String homeownerId,
    required String professionalId,
    required String description,
    required DateTime preferredDate,
    required String preferredTime,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await Supabase.instance.client.from('direct_requests').insert({
        'homeowner_id': homeownerId,
        'professional_id': professionalId,
        'description': description,
        'preferred_date': preferredDate.toIso8601String(),
        'preferred_time': preferredTime,
        'status': DirectRequest.STATUS_AWAITING_ACCEPTANCE,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select('''
            *,
            homeowner:homeowner_id(
              *,
              profile:profiles (*)
            ),
            professional:professional_id(
              *,
              profile:profiles (*)
            )
          ''').single();

      final newRequest = DirectRequest.fromJson(response);
      _requests.insert(0, newRequest);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptRequest(String requestId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final request = _requests.firstWhere((r) => r.id == requestId);
      if (request.status != DirectRequest.STATUS_AWAITING_ACCEPTANCE) {
        throw Exception('Request cannot be accepted');
      }

      await Supabase.instance.client.from('direct_requests').update({
        'status': DirectRequest.STATUS_SCHEDULED,
      }).eq('id', requestId);

      // Update local state
      final index = _requests.indexWhere((r) => r.id == requestId);
      _requests[index] = _requests[index].copyWith(
        status: DirectRequest.STATUS_SCHEDULED,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> declineRequest(String requestId, String reason) async {
    try {
      _isLoading = true;
      notifyListeners();

      final request = _requests.firstWhere((r) => r.id == requestId);
      if (request.status != DirectRequest.STATUS_AWAITING_ACCEPTANCE) {
        throw Exception('Request cannot be declined');
      }

      await Supabase.instance.client.from('direct_requests').update({
        'status': DirectRequest.STATUS_CANCELLED,
        'decline_reason': reason,
      }).eq('id', requestId);

      // Update local state
      final index = _requests.indexWhere((r) => r.id == requestId);
      _requests[index] = _requests[index].copyWith(
        status: DirectRequest.STATUS_CANCELLED,
        declineReason: reason,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startRequest(String requestId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final request = _requests.firstWhere((r) => r.id == requestId);
      if (request.status != DirectRequest.STATUS_SCHEDULED) {
        throw Exception('Request cannot be started');
      }

      await Supabase.instance.client.from('direct_requests').update({
        'status': DirectRequest.STATUS_STARTED,
      }).eq('id', requestId);

      // Update local state
      final index = _requests.indexWhere((r) => r.id == requestId);
      _requests[index] = _requests[index].copyWith(
        status: DirectRequest.STATUS_STARTED,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeService(String requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.from('direct_requests').update(
          {'status': DirectRequest.STATUS_COMPLETED}).eq('id', requestId);

      await _refreshRequest(requestId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelRequest(String requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.from('direct_requests').update(
          {'status': DirectRequest.STATUS_CANCELLED}).eq('id', requestId);

      await _refreshRequest(requestId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> proposeReschedule(
    String requestId,
    DateTime alternativeDate,
    String alternativeTime,
    String alternativeMessage,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('direct_requests')
          .update({
            'status': DirectRequest.STATUS_AWAITING_ACCEPTANCE,
            'alternative_date': alternativeDate.toIso8601String(),
            'alternative_time': alternativeTime,
            'alternative_message': alternativeMessage,
          })
          .eq('id', requestId)
          .select('''
            *,
            homeowner:homeowner_id(
              *,
              profile:profiles (*)
            ),
            professional:professional_id(
              *,
              profile:profiles (*)
            )
          ''')
          .single();

      if (response['status'] == DirectRequest.STATUS_SCHEDULED) {
        // Create job when request is accepted
        final request = DirectRequest.fromJson(response);
        await Supabase.instance.client.from('jobs').insert({
          'homeowner_id': request.homeownerId,
          'professional_id': request.professionalId,
          'title': 'Electrical Service',
          'description': request.message,
          'status': DirectRequest.STATUS_SCHEDULED,
          'date': DateTime.parse(
                  '${request.date.toIso8601String().split('T')[0]}T${request.time}')
              .toIso8601String(),
          'price': 0.00, // Price will be set by professional
        });
      }

      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = DirectRequest.fromJson(response);
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<DirectRequest>> loadDirectRequests() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response =
          await Supabase.instance.client.from('direct_requests').select('''
        *,
        homeowner:homeowners (
          *,
          profile:profiles (*)
        ),
        professional:professionals (
          *,
          profile:profiles (*)
        )
      ''');

      _requests.clear();
      _requests.addAll(response.map((json) => DirectRequest.fromJson(json)));

      _isLoading = false;
      notifyListeners();

      return _requests;
    } catch (e) {
      _isLoading = false;
      LoggerService.error('Failed to load direct requests', e);
      notifyListeners();
      rethrow;
    }
  }

  Future<void> respondToDirectRequest({
    required String requestId,
    required String status,
    String? reason,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = {'status': status};
      if (reason != null) {
        data['decline_reason'] = reason;
      }

      final response = await Supabase.instance.client
          .from('direct_requests')
          .update(data)
          .eq('id', requestId)
          .select('''
            *,
            homeowner:homeowner_id(
              *,
              profile:profiles (*)
            ),
            professional:professional_id(
              *,
              profile:profiles (*)
            )
          ''').single();

      if (status == DirectRequest.STATUS_SCHEDULED) {
        // Create job when request is accepted
        final request = DirectRequest.fromJson(response);
        await Supabase.instance.client.from('jobs').insert({
          'homeowner_id': request.homeownerId,
          'professional_id': request.professionalId,
          'title': 'Electrical Service',
          'description': request.message,
          'status': DirectRequest.STATUS_SCHEDULED,
          'date': DateTime.parse(
                  '${request.date.toIso8601String().split('T')[0]}T${request.time}')
              .toIso8601String(),
          'price': 0.00, // Price will be set by professional
        });
      }

      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = DirectRequest.fromJson(response);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> proposeAlternativeTime({
    required String requestId,
    required DateTime alternativeDate,
    required String alternativeTime,
    String? message,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await Supabase.instance.client
          .from('direct_requests')
          .update({
            'status': DirectRequest.STATUS_AWAITING_ACCEPTANCE,
            'alternative_date': alternativeDate.toIso8601String(),
            'alternative_time': alternativeTime,
            'alternative_message': message,
          })
          .eq('id', requestId)
          .select('''
            *,
            homeowner:homeowner_id(
              *,
              profile:profiles (*)
            ),
            professional:professional_id(
              *,
              profile:profiles (*)
            )
          ''')
          .single();

      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = DirectRequest.fromJson(response);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateRequestStatus({
    required String requestId,
    required String status,
    String? declineReason,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final data = {'status': status};
      if (declineReason != null) {
        data['decline_reason'] = declineReason;
      }

      final response = await Supabase.instance.client
          .from('direct_requests')
          .update(data)
          .eq('id', requestId)
          .select('''
            *,
            homeowner:homeowner_id(
              *,
              profile:profiles (*)
            ),
            professional:professional_id(
              *,
              profile:profiles (*)
            )
          ''').single();

      final index = _requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        _requests[index] = DirectRequest.fromJson(response);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _refreshRequest(String requestId) async {
    final response =
        await Supabase.instance.client.from('direct_requests').select('''
          *,
          homeowner:homeowner_id(
            *,
            profile:profiles (*)
          ),
          professional:professional_id(
            *,
            profile:profiles (*)
          )
        ''').eq('id', requestId).single();

    final updatedRequest = DirectRequest.fromJson(response);
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index != -1) {
      _requests[index] = updatedRequest;
      notifyListeners();
    }
  }

  Future<void> checkRequestStatus(String requestId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final request = _requests.firstWhere((r) => r.id == requestId);
      if (request.status != DirectRequest.STATUS_AWAITING_ACCEPTANCE) {
        throw Exception('Request status cannot be checked');
      }

      // Update local state
      final index = _requests.indexWhere((r) => r.id == requestId);
      _requests[index] = _requests[index].copyWith(
        status: DirectRequest.STATUS_AWAITING_ACCEPTANCE,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rescheduleRequest(
      String requestId, DateTime newDate, String newTime) async {
    try {
      _isLoading = true;
      notifyListeners();

      final request = _requests.firstWhere((r) => r.id == requestId);
      if (request.status != DirectRequest.STATUS_AWAITING_ACCEPTANCE) {
        throw Exception('Request cannot be rescheduled');
      }

      await Supabase.instance.client.from('direct_requests').update({
        'preferred_date': newDate.toIso8601String(),
        'preferred_time': newTime,
        'status': DirectRequest.STATUS_AWAITING_ACCEPTANCE,
      }).eq('id', requestId);

      // Update local state
      final index = _requests.indexWhere((r) => r.id == requestId);
      _requests[index] = _requests[index].copyWith(
        date: newDate,
        time: newTime,
        status: DirectRequest.STATUS_AWAITING_ACCEPTANCE,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> handleRequestStatus(String requestId, String status) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (status == DirectRequest.STATUS_SCHEDULED) {
        // Handle accepting the request
        await Supabase.instance.client.from('direct_requests').update(
            {'status': DirectRequest.STATUS_SCHEDULED}).eq('id', requestId);
      } else {
        // Handle other status updates
        await Supabase.instance.client
            .from('direct_requests')
            .update({'status': status}).eq('id', requestId);
      }

      // Update local state
      final index = _requests.indexWhere((r) => r.id == requestId);
      _requests[index] = _requests[index].copyWith(
        status: status,
      );

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
