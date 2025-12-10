import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/auction_detail_screen.dart';
import '../screens/bid_history_screen.dart';
import '../screens/submit_item_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/change_password_screen.dart';
import '../screens/won_auctions_screen.dart';
import '../screens/auction_list_screen.dart';
import '../screens/my_items_screen.dart';
import '../screens/profile_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String auctionList = '/auctions';
  static const String auctionDetail = '/auction-detail';
  static const String bidHistory = '/bid-history';
  static const String submitItem = '/submit-item';
  static const String myItems = '/my-items';
  static const String payment = '/payment';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  
  static const String changePassword = '/change-password';
  static const String wonAuctions = '/won-auctions';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    auctionList: (context) => const AuctionListScreen(),
    myItems: (context) => const MyItemsScreen(),
    bidHistory: (context) => const BidHistoryScreen(),
    wonAuctions: (context) => const WonAuctionsScreen(),
    submitItem: (context) => const SubmitItemScreen(),
    notifications: (context) => const NotificationsScreen(),
    settings: (context) => const SettingsScreen(),
    profile: (context) => const ProfileScreen(),
    editProfile: (context) => const EditProfileScreen(),
    changePassword: (context) => const ChangePasswordScreen(),
  };
  
  // For routes that need arguments
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case auctionDetail:
        final auctionId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => AuctionDetailScreen(auctionId: auctionId),
        );
      case payment:
        final auctionId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => PaymentScreen(auctionId: auctionId),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('Halaman tidak ditemukan'),
            ),
          ),
        );
    }
  }
}
