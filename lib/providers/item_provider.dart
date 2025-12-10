import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class Item {
  final int id;
  final String name;
  final String description;
  final double startingPrice;
  final double minimumBidIncrement;
  final String status;
  final String? rejectionReason;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? condition;
  final List<Map<String, dynamic>>? images;
  final String? primaryImage;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.startingPrice,
    required this.minimumBidIncrement,
    required this.status,
    this.rejectionReason,
    this.category,
    this.condition,
    this.images,
    this.primaryImage,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      startingPrice: (json['starting_price'] ?? 0).toDouble(),
      minimumBidIncrement: (json['minimum_bid_increment'] ?? 10000).toDouble(),
      status: json['status'] ?? 'pending',
      rejectionReason: json['rejection_reason'],
      category: json['category'],
      condition: json['condition'],
      images: json['images'] != null 
          ? List<Map<String, dynamic>>.from(json['images'])
          : null,
      primaryImage: json['primary_image'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class Category {
  final int id;
  final String name;
  final String? description;

  Category({required this.id, required this.name, this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }
}

class Condition {
  final int id;
  final String name;
  final String? description;
  final int qualityRating;

  Condition({required this.id, required this.name, this.description, required this.qualityRating});

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      qualityRating: json['quality_rating'] ?? 5,
    );
  }
}

class ItemProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Item> _myItems = [];
  List<Category> _categories = [];
  List<Condition> _conditions = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  bool _hasMore = true;
  
  List<Item> get myItems => _myItems;
  List<Category> get categories => _categories;
  List<Condition> get conditions => _conditions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  
  // Fetch categories
  Future<void> fetchCategories() async {
    try {
      final response = await _apiService.get(ApiConfig.categories);
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        _categories = data.map((json) => Category.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  // Fetch conditions
  Future<void> fetchConditions() async {
    try {
      final response = await _apiService.get(ApiConfig.conditions);
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        _conditions = data.map((json) => Condition.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  // Fetch my items
  Future<void> fetchMyItems({bool refresh = false, String? status}) async {
    if (refresh) {
      _currentPage = 1;
      _myItems = [];
      _hasMore = true;
    }
    
    if (!_hasMore && !refresh) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final params = <String, dynamic>{'page': _currentPage};
      if (status != null) params['status'] = status;
      
      final response = await _apiService.get(ApiConfig.myItems, queryParameters: params);
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final meta = response.data['meta'];
        
        final newItems = data.map((json) => Item.fromJson(json)).toList();
        
        if (refresh) {
          _myItems = newItems;
        } else {
          _myItems.addAll(newItems);
        }
        
        _currentPage = meta['current_page'] + 1;
        _hasMore = meta['current_page'] < meta['last_page'];
      }
    } catch (e) {
      _error = 'Gagal memuat data barang';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Submit new item
  Future<bool> submitItem({
    required int categoryId,
    required int conditionId,
    required String name,
    required String description,
    required double startingPrice,
    double? minimumBidIncrement,
    required List<XFile> images, // Changed from File to XFile
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final formData = FormData.fromMap({
        'category_id': categoryId,
        'condition_id': conditionId,
        'name': name,
        'description': description,
        'starting_price': startingPrice,
        'minimum_bid_increment': minimumBidIncrement ?? 10000,
      });
      
      // Add images
      for (int i = 0; i < images.length; i++) {
        String fileName = images[i].name;
        if (fileName.isEmpty) {
          fileName = 'image_$i.jpg';
        }

        if (kIsWeb) {
            final bytes = await images[i].readAsBytes();
            formData.files.add(MapEntry(
              'images[]',
              MultipartFile.fromBytes(
                bytes, 
                filename: fileName,
                // contentType: MediaType('image', 'jpeg'), // fallback if needed
              ),
            ));
        } else {
            formData.files.add(MapEntry(
              'images[]',
              await MultipartFile.fromFile(
                images[i].path, 
                filename: fileName,
              ),
            ));
        }
      }
      
      print('Submitting item payload: ${formData.fields}'); 
      
      final response = await _apiService.postFormData(ApiConfig.items, formData);
      
      print('Submit Response Status: ${response.statusCode}');
      print('Submit Response Data: ${response.data}');

      if (response.data['success'] == true) {
        await fetchMyItems(refresh: true);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Gagal mengajukan barang (Server Error)';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is DioException) {
         print('DioException: ${e.message}');
         print('Response: ${e.response?.data}');
         print('Headers: ${e.response?.headers}');
         
         String serverMsg = '';
         if (e.response?.data is Map && e.response!.data['message'] != null) {
           serverMsg = e.response!.data['message'];
         } else if (e.response?.data is String) { // HTML sometimes
            serverMsg = 'Terjadi kesalahan server (500)';
         }
         
         _error = serverMsg.isNotEmpty ? serverMsg : 'Gagal menghubungi server: ${e.message}';
      } else {
         print('General Error: $e');
         _error = 'Gagal mengajukan barang: $e';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
