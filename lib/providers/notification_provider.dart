import 'package:flutter/foundation.dart';
import '../core/services/logger_service.dart';
import '../core/utils/api_response.dart';
import 'database_provider.dart';

class Notification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final String type;
  final String? relatedId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool read;
  final Map<String, dynamic>? data;

  const Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    this.relatedId,
    required this.createdAt,
    required this.updatedAt,
    required this.read,
    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: json['type'] as String,
      read: json['read'] as bool,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userId: json['profile_id'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'read': read,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'profile_id': userId,
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? title,
    String? message,
    String? type,
    String? relatedId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? read,
    Map<String, dynamic>? data,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      relatedId: relatedId ?? this.relatedId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      read: read ?? this.read,
      data: data ?? this.data,
    );
  }
}

class NotificationProvider with ChangeNotifier {
  final DatabaseProvider _databaseProvider;
  bool _loading = false;
  String? _error;
  List<Notification> _notifications = [];
  int _unreadCount = 0;
  dynamic _subscription;

  NotificationProvider(this._databaseProvider) {
    _initializeRealtimeSubscription();
  }

  // Getters
  bool get loading => _loading;
  String? get error => _error;
  List<Notification> get notifications => _notifications;
  int get unreadCount => _unreadCount;

  void _initializeRealtimeSubscription() {
    _subscription = _databaseProvider.client
        .from('notifications')
        .stream(primaryKey: ['id']).listen((List<Map<String, dynamic>> data) {
      if (data.isNotEmpty) {
        final notification = Notification.fromJson(data.first);
        _handleRealtimeUpdate(notification);
      }
    });
  }

  void stopListeningToNotifications() {
    _subscription?.cancel();
    _subscription = null;
  }

  void _handleRealtimeUpdate(Notification notification) {
    final index = _notifications.indexWhere((n) => n.id == notification.id);
    if (index != -1) {
      // Update existing notification
      _notifications[index] = notification;
      _updateUnreadCount();
    } else {
      // Add new notification
      _notifications.add(notification);
      if (!notification.read) {
        _unreadCount++;
      }
    }
    notifyListeners();
  }

  void _updateUnreadCount() {
    _unreadCount = _notifications.where((n) => !n.read).length;
  }

  Future<ApiResponse<List<Notification>>> loadNotifications() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      final response = await _databaseProvider.client
          .from('notifications')
          .select()
          .order('created_at', ascending: false);

      _notifications =
          response.map((data) => Notification.fromJson(data)).toList();
      _updateUnreadCount();

      _loading = false;
      notifyListeners();
      return ApiResponse.success(_notifications);
    } catch (e) {
      LoggerService.error('Failed to load notifications', e);
      _loading = false;
      _error = 'Failed to load notifications: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }

  Future<ApiResponse<void>> markAsRead(String notificationId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _databaseProvider.client
          .from('notifications')
          .update({'read': true}).eq('id', notificationId);

      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(read: true);
        _updateUnreadCount();
      }

      _loading = false;
      notifyListeners();
      return ApiResponse.success(null);
    } catch (e) {
      LoggerService.error('Failed to mark notification as read', e);
      _loading = false;
      _error = 'Failed to mark notification as read: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }

  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _databaseProvider.client
          .from('notifications')
          .update({'read': true}).eq('read', false);

      _notifications =
          _notifications.map((n) => n.copyWith(read: true)).toList();
      _unreadCount = 0;

      _loading = false;
      notifyListeners();
      return ApiResponse.success(null);
    } catch (e) {
      LoggerService.error('Failed to mark all notifications as read', e);
      _loading = false;
      _error = 'Failed to mark all notifications as read: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }

  Future<ApiResponse<void>> deleteNotification(String notificationId) async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _databaseProvider.client
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      _notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();

      _loading = false;
      notifyListeners();
      return ApiResponse.success(null);
    } catch (e) {
      LoggerService.error('Failed to delete notification', e);
      _loading = false;
      _error = 'Failed to delete notification: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }

  Future<ApiResponse<void>> clearAllNotifications() async {
    try {
      _loading = true;
      _error = null;
      notifyListeners();

      await _databaseProvider.client
          .from('notifications')
          .delete()
          .neq('id', '0');

      _notifications.clear();
      _unreadCount = 0;

      _loading = false;
      notifyListeners();
      return ApiResponse.success(null);
    } catch (e) {
      LoggerService.error('Failed to clear notifications', e);
      _loading = false;
      _error = 'Failed to clear notifications: $e';
      notifyListeners();
      return ApiResponse.error(_error!);
    }
  }

  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await _databaseProvider.client.rpc(
        'count_unread_notifications',
        params: {'profile_id': _databaseProvider.currentProfile?.id},
      );

      _unreadCount = response as int;
      notifyListeners();
      return ApiResponse.success(_unreadCount);
    } catch (e) {
      LoggerService.error('Failed to get unread count', e);
      return ApiResponse.error('Failed to get unread count: $e');
    }
  }

  Future<int> getUnreadNotificationsCount() async {
    try {
      final response = await _databaseProvider.client.rpc(
        'count_unread_notifications',
        params: {'profile_id': _databaseProvider.currentProfile?.id},
      );
      return response as int;
    } catch (e) {
      LoggerService.error('Failed to get unread notifications count', e);
      return 0;
    }
  }
}
