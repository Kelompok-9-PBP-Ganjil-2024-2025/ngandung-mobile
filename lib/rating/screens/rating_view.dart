import 'package:flutter/material.dart';

class RatingPage extends StatelessWidget {
  final int id;
  const RatingPage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rating Page')),
      body: Center(
        child: Text('Rumah Makan ID: $id'),
      ),
    );
  }
}