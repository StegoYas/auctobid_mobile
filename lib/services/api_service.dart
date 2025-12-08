import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.apiUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        // Handle 401 Unauthorized
        if (error.response?.statusCode == 401) {
          _storage.delete(key: 'auth_token');
        }
        return handler.next(error);
      },
    ));
  }
  
  // GET request
  Future<Response> get(String endpoint, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(endpoint, queryParameters: queryParameters);
  }
  
  // POST request
  Future<Response> post(String endpoint, {dynamic data}) async {
    return _dio.post(endpoint, data: data);
  }
  
  // PUT request
  Future<Response> put(String endpoint, {dynamic data}) async {
    return _dio.put(endpoint, data: data);
  }
  
  // DELETE request
  Future<Response> delete(String endpoint) async {
    return _dio.delete(endpoint);
  }
  
  // POST with FormData (for file uploads)
  Future<Response> postFormData(String endpoint, FormData data) async {
    return _dio.post(
      endpoint, 
      data: data,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
  
  // POST with multipart data (mixed files and fields)
  Future<Response> postMultipart(
    String endpoint, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? files,
  }) async {
    final formData = FormData();
    
    // Add regular fields
    if (data != null) {
      data.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });
    }
    
    // Add files
    if (files != null) {
      for (final entry in files.entries) {
        final file = entry.value;
        if (file != null) {
          formData.files.add(MapEntry(
            entry.key,
            await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
          ));
        }
      }
    }
    
    return _dio.post(
      endpoint,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
  }
  
  // Save auth token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  // Get auth token
  Future<String?> getToken() async {
    return _storage.read(key: 'auth_token');
  }
  
  // Clear auth token
  Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }
  
  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }
}
