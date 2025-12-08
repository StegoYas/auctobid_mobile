import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../models/auction.dart';
import '../services/api_service.dart';

class AuctionProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Auction> _auctions = [];
  Auction? _currentAuction;
  List<AuctionBid> _bids = [];
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _lastPage = 1;
  bool _hasMore = true;
  
  List<Auction> get auctions => _auctions;
  Auction? get currentAuction => _currentAuction;
  List<AuctionBid> get bids => _bids;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  
  // Fetch active auctions
  Future<void> fetchAuctions({bool refresh = false, String? categoryId, String? search}) async {
    if (refresh) {
      _currentPage = 1;
      _auctions = [];
      _hasMore = true;
    }
    
    if (!_hasMore && !refresh) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final params = <String, dynamic>{'page': _currentPage};
      if (categoryId != null) params['category_id'] = categoryId;
      if (search != null && search.isNotEmpty) params['search'] = search;
      
      final response = await _apiService.get(ApiConfig.auctions, queryParameters: params);
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        final meta = response.data['meta'];
        
        final newAuctions = data.map((json) => Auction.fromJson(json)).toList();
        
        if (refresh) {
          _auctions = newAuctions;
        } else {
          _auctions.addAll(newAuctions);
        }
        
        _currentPage = meta['current_page'] + 1;
        _lastPage = meta['last_page'];
        _hasMore = meta['current_page'] < meta['last_page'];
      }
    } catch (e) {
      _error = 'Gagal memuat data lelang';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Fetch auction detail
  Future<void> fetchAuctionDetail(int auctionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.get(ApiConfig.auctionDetail(auctionId));
      
      if (response.data['success'] == true) {
        _currentAuction = Auction.fromJson(response.data['data']);
        _bids = _currentAuction!.bids ?? [];
      }
    } catch (e) {
      _error = 'Gagal memuat detail lelang';
    }
    
    _isLoading = false;
    notifyListeners();
  }
  
  // Fetch auction bids
  Future<void> fetchAuctionBids(int auctionId) async {
    try {
      final response = await _apiService.get(ApiConfig.auctionBids(auctionId));
      
      if (response.data['success'] == true) {
        final data = response.data['data'] as List;
        _bids = data.map((json) => AuctionBid.fromJson(json)).toList();
        notifyListeners();
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  // Place bid
  Future<bool> placeBid(int auctionId, double amount) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final response = await _apiService.post(
        ApiConfig.auctionBid(auctionId),
        data: {'amount': amount},
      );
      
      if (response.data['success'] == true) {
        // Update current auction with new data
        if (_currentAuction != null && _currentAuction!.id == auctionId) {
          await fetchAuctionDetail(auctionId);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Gagal mengajukan tawaran';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Gagal mengajukan tawaran. Silakan coba lagi.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update auction with new bid data (from WebSocket)
  void updateAuctionWithBid(int auctionId, Map<String, dynamic> bidData) {
    if (_currentAuction != null && _currentAuction!.id == auctionId) {
      // Add new bid to the list
      final newBid = AuctionBid.fromJson(bidData['bid']);
      _bids.insert(0, newBid);
      
      // Update auction data
      fetchAuctionDetail(auctionId);
    }
    
    // Update in list
    final index = _auctions.indexWhere((a) => a.id == auctionId);
    if (index != -1) {
      // Refresh the specific auction in the list
      fetchAuctions(refresh: true);
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearCurrentAuction() {
    _currentAuction = null;
    _bids = [];
    notifyListeners();
  }
}
