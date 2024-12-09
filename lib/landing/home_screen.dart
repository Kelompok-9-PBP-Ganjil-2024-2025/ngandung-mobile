// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ngandung_mobile/landing/widgets/navbar.dart'; // Import the BottomNavBar

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add navigation or other logic here based on the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: const Center(
        child: Text(
          'Home Screen ARSHQ',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFFF9900), 
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}