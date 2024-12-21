import 'package:flutter/material.dart';
import 'package:ngandung_mobile/landing/widgets/navbar.dart'; // Import navbar

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PlaceHolder'),
      ),
      body: const Center(
        child: Text(
          'Welcome to HomePage!',
          style: TextStyle(fontSize: 20),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(), // Tambahkan navbar di sini
    );
  }
}
