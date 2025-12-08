import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../services/api_service.dart';

class Bid {
  final int id;
  final int auctionId;
  final int userId;
  final double amount;
  final DateTime createdAt;
  
  // Auction info (for bid history)
  final String? auctionTitle;
  final String? auctionImage;
  final String? auctionStatus;
  final DateTime? auctionEndTime;
  
  Bid({
    required this.id,
    required this.auctionId,
    required this.userId,
    required this.amount,
    required this.createdAt,
    this.auctionTitle,
    this.auctionImage,
    this.auctionStatus,
    this.auctionEndTime,
  });
  
  factory Bid.fromJson(Map<String, dynamic> json) {
    return Bid(
      id: json['id'] ?? 0,
      auctionId: json['auction_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      auctionTitle: json['auction']?['item']?['name'],
      auctionImage: json['auction']?['item']?['images']?[0]?['image_path'],
      auctionStatus: json['auction']?['status'],
      auctionEndTime: json['auction']?['end_time'] != null 
          ? DateTime.parse(json['auction']['end_time']) 
          : null,
    );
  }
}

class BidProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Bid> _myBids = [];
  List<Bid> _myActiveBids = [];
  List<Map<String, dynamic>> _myWins = [];
  bool _isLoading = false;
  String? _error;
  
  List<Bid> get myBids => _myBids;
  List<Bid> get myActiveBids => _myActiveBids;
  List<Map<String, dynamic>> get myWins => _myWins;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Fetch all my bids history
  Future<void> fetchMyBids() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConfig.myBids);
      
      if (response.data['success'] == true) {
        final List<dynamic> bidsJson = response.data['data']['bids'] ?? [];
        _myBids = bidsJson.map((json) => Bid.fromJson(json)).toList();
      }
    } catch (e) {
      _error = 'Gagal memuat riwayat bid';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Fetch my active bids (auctions still running)
  Future<void> fetchMyActiveBids() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConfig.myActiveBids);
      
      if (response.data['success'] == true) {
        final List<dynamic> bidsJson = response.data['data']['bids'] ?? [];
        _myActiveBids = bidsJson.map((json) => Bid.fromJson(json)).toList();
      }
    } catch (e) {
      _error = 'Gagal memuat bid aktif';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Fetch my won auctions
  Future<void> fetchMyWins() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConfig.myWins);
      
      if (response.data['success'] == true) {
        final List<dynamic> winsJson = response.data['data']['wins'] ?? [];
        _myWins = winsJson.map((json) => Map<String, dynamic>.from(json)).toList();
      }
    } catch (e) {
      _error = 'Gagal memuat kemenangan';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([
      fetchMyBids(),
      fetchMyActiveBids(),
      fetchMyWins(),
    ]);
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
