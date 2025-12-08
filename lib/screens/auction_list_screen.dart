import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class AuctionListScreen extends StatelessWidget {
  const AuctionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is implemented in home_screen.dart as _AuctionsPage
    // This file exists for routing purposes
    return const Scaffold(
      body: Center(
        child: Text('Auction List Screen'),
      ),
    );
  }
}
