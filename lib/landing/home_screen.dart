import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor:  Color(0xFF111111), 
      body:  Center(
        child: Text(
          'Home Screen ARSHQ',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFFF9900), 
          ),
        ),
      ),
    );
  }
}
