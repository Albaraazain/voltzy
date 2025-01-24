import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/direct_request_model.dart';

class DirectRequestProvider extends ChangeNotifier {
  final List<DirectRequest> _requests = [];
  bool _isLoading = false;
  String? _error;

  List<DirectRequest> get requests => List.unmodifiable(_requests);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<DirectRequest> get pendingRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_PENDING)
      .toList();

  List<DirectRequest> get acceptedRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_ACCEPTED)
      .toList();

  List<DirectRequest> get inProgressRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_IN_PROGRESS)
      .toList();

  List<DirectRequest> get completedRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_COMPLETED)
      .toList();

  List<DirectRequest> get cancelledRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_CANCELLED)
      .toList();

  List<DirectRequest> get declinedRequests => _requests
      .where((request) => request.status == DirectRequest.STATUS_DECLINED)
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
              profile:profile_id(*)
            ),
            professional:professional_id(
              *,
              profile:profile_id(*)
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
              profile:profile_id(*)
            ),
            professional:professional_id(
              *,
              profile:profile_id(*)
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
        'status': DirectRequest.STATUS_PENDING,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).select();

      final newRequest = DirectRequest.fromJson(response.first);
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.from('direct_requests').update(
          {'status': DirectRequest.STATUS_ACCEPTED}).eq('id', requestId);

      await _refreshRequest(requestId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> declineRequest(String requestId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.from('direct_requests').update({
        'status': DirectRequest.STATUS_DECLINED,
        'decline_reason': reason,
      }).eq('id', requestId);

      await _refreshRequest(requestId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startService(String requestId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await Supabase.instance.client.from('direct_requests').update(
          {'status': DirectRequest.STATUS_IN_PROGRESS}).eq('id', requestId);

      await _refreshRequest(requestId);
    } catch (e) {
      _error = e.toString();
      rethrow;
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
      await Supabase.instance.client.from('direct_requests').update({
        'status': DirectRequest.STATUS_RESCHEDULED,
        'alternative_date': alternativeDate.toIso8601String(),
        'alternative_time': alternativeTime,
        'alternative_message': alternativeMessage,
      }).eq('id', requestId);

      await _refreshRequest(requestId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDirectRequests({
    required String professionalId,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await Supabase.instance.client
          .from('direct_requests')
          .select()
          .eq('professional_id', professionalId);

      _requests.clear();
      _requests.addAll(
        response.map<DirectRequest>((json) => DirectRequest.fromJson(json)),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
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
          .select()
          .single();

      if (status == DirectRequest.STATUS_ACCEPTED) {
        // Create job when request is accepted
        final request = DirectRequest.fromJson(response);
        await Supabase.instance.client.from('jobs').insert({
          'homeowner_id': request.homeownerId,
          'professional_id': request.professionalId,
          'title': 'Electrical Service',
          'description': request.message,
          'status': 'ACCEPTED',
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
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await Supabase.instance.client
          .from('direct_requests')
          .update({
            'alternative_date': alternativeDate.toIso8601String().split('T')[0],
            'alternative_time': alternativeTime,
            'alternative_message': message,
          })
          .eq('id', requestId)
          .select()
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
          .select()
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

  Future<void> _refreshRequest(String requestId) async {
    final response =
        await Supabase.instance.client.from('direct_requests').select('''
          *,
          homeowner:homeowner_id(
            *,
            profile:profile_id(*)
          ),
          professional:professional_id(
            *,
            profile:profile_id(*)
          )
        ''').eq('id', requestId).single();

    final updatedRequest = DirectRequest.fromJson(response);
    final index = _requests.indexWhere((request) => request.id == requestId);
    if (index != -1) {
      _requests[index] = updatedRequest;
      notifyListeners();
    }
  }
}
