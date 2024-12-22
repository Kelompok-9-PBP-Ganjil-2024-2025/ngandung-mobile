import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class VoteScreen extends StatefulWidget {
  final String pollId;

  const VoteScreen({super.key, required this.pollId});

  @override
  State<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends State<VoteScreen> {
  Map<String, dynamic>? pollData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPollData(context.read<CookieRequest>());
  }

  Future<void> fetchPollData(CookieRequest request) async {
    final response = await request.get(
      'http://127.0.0.1:8000/polling-makanan/vote/${widget.pollId}/',
    );

    if (response['status'] == 'success') {
      setState(() {
        pollData = response;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load poll: ${response['message']}')),
      );
    }
  }

  Future<void> submitVote(CookieRequest request, String choiceId) async {
    final response = await request.post(
      'http://127.0.0.1:8000/polling-makanan/vote/${widget.pollId}/',
      jsonEncode({  // Encode the data as JSON
        'choice': choiceId
      }),
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vote recorded successfully!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit vote: ${response['message']}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vote on Poll')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pollData == null
          ? const Center(child: Text('Failed to load poll.'))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              pollData!['poll'],
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...pollData!['choices'].map<Widget>((choice) {
            return ListTile(
              title: Text(choice['choice_text']),
              trailing: ElevatedButton(
                onPressed: () {
                  submitVote(context.read<CookieRequest>(), choice['id']);
                },
                child: const Text('Vote'),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
