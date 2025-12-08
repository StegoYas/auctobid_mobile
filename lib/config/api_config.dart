class ApiConfig {
  // Change this to your Laravel backend URL
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator localhost
  // static const String baseUrl = 'http://localhost:8000'; // iOS simulator
  // static const String baseUrl = 'http://YOUR_IP:8000'; // Physical device
  
  static const String apiVersion = '/api/v1';
  static const String apiUrl = '$baseUrl$apiVersion';
  
  // WebSocket (Reverb)
  static const String wsHost = '10.0.2.2';
  static const int wsPort = 8080;
  
  // Endpoints
  static const String login = '/login';
  static const String register = '/register';
  static const String logout = '/logout';
  static const String me = '/me';
  static const String refreshToken = '/refresh-token';
  
  static const String categories = '/categories';
  static const String conditions = '/conditions';
  
  static const String items = '/items';
  static const String myItems = '/my-items';
  
  static const String auctions = '/auctions';
  static const String auctionsAll = '/auctions/all';
  
  static const String myBids = '/my-bids';
  static const String myWins = '/my-wins';
  static const String myActiveBids = '/my-active-bids';
  
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';
  
  static const String profile = '/profile';
  static const String profilePhoto = '/profile/photo';
  static const String profileIdentityPhoto = '/profile/identity-photo';
  static const String profilePassword = '/profile/password';
  static const String changePassword = '/profile/password';
  static const String profileStatistics = '/profile/statistics';
  
  static const String paymentHistory = '/payment-history';
  
  // Helper methods
  static String auctionBid(int auctionId) => '/auctions/$auctionId/bid';
  static String auctionBids(int auctionId) => '/auctions/$auctionId/bids';
  static String auctionDetail(int auctionId) => '/auctions/$auctionId';
  static String auctionPayment(int auctionId) => '/auctions/$auctionId/payment';
  static String auctionPay(int auctionId) => '/auctions/$auctionId/pay';
  static String itemDetail(int itemId) => '/items/$itemId';
  static String notificationRead(int notificationId) => '/notifications/$notificationId/read';
  static String notificationDelete(int notificationId) => '/notifications/$notificationId';
  
  // Storage URL
  static String storageUrl(String path) => '$baseUrl/storage/$path';
}
