import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/notification.dart';
import '../services/api_service.dart';

class NotificationProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  
  // Fetch notifications
  Future<void> fetchNotifications({bool refresh = false, bool unreadOnly = false}) async {
    if (refresh) {
      _currentPage = 1;
      _notifications = [];
      _hasMore = true;
    }
    
    if (!_hasMore && !refresh) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final params = <String, dynamic>{
        'page': _currentPage,
        'unread_only': unreadOnly,
      };
      
      final response = await _apiService.get(ApiConfig.notifications, queryParameters: params);
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final meta = response.data['meta'];
        
        final newNotifications = data.map((json) => AppNotification.fromJson(json)).toList();
        
        if (refresh) {
          _notifications = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }
        
        _currentPage = meta['current_page'] + 1;
        _hasMore = meta['current_page'] < meta['last_page'];
        _unreadCount = meta['unread_count'] ?? 0;
      }
    } catch (e) {
      _error = 'Gagal memuat notifikasi';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Fetch unread count only
  Future<void> fetchUnreadCount() async {
    try {
      final response = await _apiService.get(ApiConfig.notificationsUnreadCount);
      
      if (response.data['success'] == true) {
        _unreadCount = response.data['data']['unread_count'] ?? 0;
        notifyListeners();
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  // Mark as read
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.post(ApiConfig.notificationRead(notificationId));
      
      if (response.data['success'] == true) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          // Create new notification with isRead = true
          final oldNotif = _notifications[index];
          _notifications[index] = AppNotification(
            id: oldNotif.id,
            title: oldNotif.title,
            message: oldNotif.message,
            type: oldNotif.type,
            referenceType: oldNotif.referenceType,
            referenceId: oldNotif.referenceId,
            isRead: true,
            readAt: DateTime.now(),
            createdAt: oldNotif.createdAt,
          );
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          notifyListeners();
        }
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.post(ApiConfig.notificationsMarkAllRead);
      
      if (response.data['success'] == true) {
        _unreadCount = 0;
        _notifications = _notifications.map((oldNotif) => AppNotification(
          id: oldNotif.id,
          title: oldNotif.title,
          message: oldNotif.message,
          type: oldNotif.type,
          referenceType: oldNotif.referenceType,
          referenceId: oldNotif.referenceId,
          isRead: true,
          readAt: DateTime.now(),
          createdAt: oldNotif.createdAt,
        )).toList();
        notifyListeners();
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  // Delete notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.delete(ApiConfig.notificationDelete(notificationId));
      
      if (response.data['success'] == true) {
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
