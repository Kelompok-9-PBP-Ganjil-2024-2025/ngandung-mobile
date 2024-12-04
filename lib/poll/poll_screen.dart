import 'package:flutter/material.dart';

class PollScreen extends StatelessWidget {
  const PollScreen({super.key});

  @override
Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor:  Color(0xFF111111), 
      body:  Center(
        child: Text(
          'Polling MAKANAN/TOKO',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFFF9900), 
          ),
        ),
      ),
    );
  }
}
