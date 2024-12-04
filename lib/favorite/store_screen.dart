import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor:  Color(0xFF111111), 
      body:  Center(
        child: Text(
          'Fav tokoook',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFFF9900), 
          ),
        ),
      ),
    );
  }
}
