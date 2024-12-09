import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/poll.dart';

class VoteScreen extends StatefulWidget {
  final Poll poll;

  const VoteScreen({Key? key, required this.poll}) : super(key: key);

  @override
  _VoteScreenState createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  Choice? _selectedChoice;

  Future<void> _submitVote() async {
    if (_selectedChoice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a choice')),
      );
      return;
    }

    final request = context.read<CookieRequest>();
    try {
      final response = await request.post(
        '/polling-makanan/vote/${widget.poll.id}/',
        {'choice': _selectedChoice!.id},
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? 'Vote submitted successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting vote: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.poll.question),
        backgroundColor: const Color(0xFFFF9900),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please select one option:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...widget.poll.choices.map((choice) => RadioListTile<Choice>(
              title: Text(choice.choiceText),
              value: choice,
              groupValue: _selectedChoice,
              onChanged: (Choice? value) {
                setState(() {
                  _selectedChoice = value;
                });
              },
            )),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitVote,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9900),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Submit Vote'),
            ),
          ],
        ),
      ),
    );
  }
}