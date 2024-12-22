import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ngandung_mobile/poll/models/result.dart'; // Import your model
import 'package:pbp_django_auth/pbp_django_auth.dart'; // Import CookieRequest
import 'package:provider/provider.dart';

class PollResultScreen extends StatelessWidget {
  final String pollId; // Use String to match UUID
  const PollResultScreen({super.key, required this.pollId});

  // Fetch poll results using CookieRequest
  Future<Poll> fetchPollResults(CookieRequest request, String pollId) async {
    try {
      final response = await request.get(
        'http://127.0.0.1:8000/polling-makanan/polls/$pollId/results/',
      );

      // Check if response is a String or Map and handle accordingly
      var data = response is String ? jsonDecode(response) : response;

      // Check if the data is valid and create the Poll object
      if (data != null) {
        return Poll.fromJson(data);
      } else {
        throw Exception('No data found for the poll results');
      }
    } catch (e) {
      print('Error fetching poll results: $e');
      throw Exception('Failed to load poll results');
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>(); // Get CookieRequest from context

    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Results'),
      ),
      body: FutureBuilder<Poll>(
        future: fetchPollResults(request, pollId), // Pass CookieRequest here
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No results available.'));
          }

          final poll = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView( // Wrap content inside SingleChildScrollView
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    poll.question,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  ...poll.choices.map((choice) {
                    final percentage = poll.totalVotes == 0 ? 0 : (choice.voteCount / poll.totalVotes) * 100;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${choice.choiceText}: ${choice.voteCount} votes (${percentage.toStringAsFixed(1)}%)',
                            style: const TextStyle(fontSize: 18),
                          ),
                          LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: Colors.grey[200],
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
