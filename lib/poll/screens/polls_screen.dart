import 'dart:convert';
import '../models/poll.dart';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:ngandung_mobile/poll/widgets/poll_card.dart';
import 'package:ngandung_mobile/landing/widgets/navbar.dart';
import 'package:ngandung_mobile/poll/screens/create_poll.dart';
import 'package:ngandung_mobile/poll/screens/vote.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  late Future<List<Poll>> _pollsFuture = fetchPolls(context.read<CookieRequest>());

  Future<List<Poll>> fetchPolls(CookieRequest request) async {
    try {
      final response =
      await request.get('http://127.0.0.1:8000/polling-makanan/polls/');

      List<dynamic> data = response is String ? jsonDecode(response) : response;

      return data.where((d) => d != null).map((d) => Poll.fromJson(d)).toList();
    } catch (e) {
      print('Error fetching polls: $e');
      return [];
    }
  }

  void _refreshPolls() {
    setState(() {
      _pollsFuture = fetchPolls(context.read<CookieRequest>());
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Polls',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Click the poll to vote/view result',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Poll>>(
              future: _pollsFuture,
              builder: (context, AsyncSnapshot<List<Poll>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No Polls yet',
                      style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Poll poll = snapshot.data![index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: PollCard(
                        pk: poll.id,
                        title: poll.question,
                        author: poll.author,
                        isActive: poll.isActive,
                        viewResult: poll.viewResults,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoteScreen(pollId: poll.id),
                            ),
                          ).then((voted) {
                            // If voted is true (voting was successful), refresh the polls
                            if (voted == true) {
                              _refreshPolls();
                            }
                          });
                        },
                        onDelete: _refreshPolls, // Refetch polls on delete
                        onEdit: _refreshPolls, // Refetch polls on edit (toggle)
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreatePollScreen(),
                  ),
                ).then((_) {
                  _refreshPolls();
                });
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.orangeAccent,
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Add New Poll',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const BottomNavBar(currentIndex: 2,),
        ],
      ),
    );
  }
}