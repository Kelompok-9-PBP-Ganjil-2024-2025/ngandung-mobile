import 'package:flutter/material.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor:  Color(0xFF111111), 
      body:  Center(
        child: Text(
          'Forum page REDDIT',
          style: TextStyle(
            fontSize: 24,
            color: Color(0xFFFF9900), 
          ),
        ),
      ),
    );
  }
}
