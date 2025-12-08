import 'package:flutter/material.dart';
import '../config/app_theme.dart';

class MyItemsScreen extends StatelessWidget {
  const MyItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is implemented in home_screen.dart as _MyItemsPage
    return const Scaffold(
      body: Center(
        child: Text('My Items Screen'),
      ),
    );
  }
}
