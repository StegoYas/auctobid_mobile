import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  
  // Initialize - check if user is already logged in
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final hasToken = await _apiService.isLoggedIn();
      if (hasToken) {
        await fetchUser();
      }
    } catch (e) {
      _isLoggedIn = false;
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );
      
      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        await _apiService.saveToken(token);
        _user = User.fromJson(response.data['data']['user']);
        _isLoggedIn = true;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Login gagal';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone': phone,
          'address': address,
        },
      );
      
      if (response.data['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Registrasi gagal';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Fetch current user
  Future<void> fetchUser() async {
    try {
      final response = await _apiService.get(ApiConfig.me);
      
      if (response.data['success'] == true) {
        _user = User.fromJson(response.data['data']['user']);
        _isLoggedIn = true;
        notifyListeners();
      }
    } catch (e) {
      _isLoggedIn = false;
      await _apiService.clearToken();
    }
  }
  
  // Logout
  Future<void> logout() async {
    try {
      await _apiService.post(ApiConfig.logout);
    } catch (e) {
      // Ignore errors during logout
    }
    
    await _apiService.clearToken();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }
  
  // Update profile with optional file upload
  Future<bool> updateProfile({
    String? name, 
    String? phone, 
    String? address,
    dynamic profileImage,
    dynamic identityImage,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.postMultipart(
        ApiConfig.profile,
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (address != null) 'address': address,
        },
        files: {
          if (profileImage != null) 'profile_photo': profileImage,
          if (identityImage != null) 'identity_photo': identityImage,
        },
      );
      
      if (response.data['success'] == true) {
        _user = User.fromJson(response.data['data']['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = response.data['message'] ?? 'Gagal memperbarui profil';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        ApiConfig.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': newPassword,
        },
      );
      
      if (response.data['success'] == true) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _error = response.data['message'] ?? 'Gagal mengubah password';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = _parseError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Parse error message
  String _parseError(dynamic e) {
    if (e is Exception) {
      final errorString = e.toString();
      if (errorString.contains('message')) {
        // Try to extract message from DioException
        try {
          final match = RegExp(r'"message":"([^"]+)"').firstMatch(errorString);
          if (match != null) return match.group(1)!;
        } catch (_) {}
      }
    }
    return 'Terjadi kesalahan. Silakan coba lagi.';
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
