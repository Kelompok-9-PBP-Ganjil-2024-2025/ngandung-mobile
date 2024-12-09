import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../models/poll.dart';
import 'create_poll_screen.dart';
import 'vote_screen.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({Key? key}) : super(key: key);

  @override
  _PollsScreenState createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  List<Poll> _myPolls = [];
  List<Poll> _otherPolls = [];
  List<String> _votedPollIds = [];
  Poll? _selectedPoll;

  @override
  void initState() {
    super.initState();
    _fetchPolls();
  }

  Future<void> _fetchPolls() async {
    final request = context.read<CookieRequest>();
    try {
      final response =
          await request.get('http://127.0.0.1:8000/polling-makanan/');

      setState(() {
        _myPolls = (response['my_polls'] as List)
            .map((pollData) => Poll.fromJson(pollData))
            .toList();

        _otherPolls = (response['other_polls'] as List)
            .map((pollData) => Poll.fromJson(pollData))
            .toList();

        _votedPollIds =
            (response['votes'] as List).map((id) => id.toString()).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching polls: $e')),
      );
    }
  }

  Future<void> _fetchPollResults(Poll poll) async {
    final request = context.read<CookieRequest>();
    try {
      final response =
          await request.get('/polling-makanan/ajax_poll_results/${poll.id}/');

      setState(() {
        _selectedPoll = Poll.fromJson(response);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching poll results: $e')),
      );
    }
  }

  void _deletePoll(Poll poll) async {
    final request = context.read<CookieRequest>();
    try {
      await request.post('/polling-makanan/delete/${poll.id}/', {});
      await _fetchPolls();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Poll deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting poll: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Polls'),
        backgroundColor: const Color(0xFFFF9900),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Polls',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreatePollScreen(),
                            ),
                          ).then((_) => _fetchPolls());
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9900),
                        ),
                        child: const Text('Create Poll'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_myPolls.isEmpty && _otherPolls.isEmpty)
                    const Center(child: Text('No polls available.')),
                  Expanded(
                    child: ListView(
                      children: [
                        ..._myPolls.map(
                            (poll) => _buildPollCard(poll, isMyPoll: true)),
                        ..._otherPolls.map(
                            (poll) => _buildPollCard(poll, isMyPoll: false)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              color: Colors.black,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Poll Results',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_selectedPoll == null)
                    const Text(
                      'Click on any of the polls to show its result',
                      style: TextStyle(color: Colors.grey),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedPoll!.question,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'by ${_selectedPoll!.authorUsername}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        SfCartesianChart(
                          primaryXAxis: CategoryAxis(),
                          series: <ChartSeries>[
                            BarSeries<Choice, String>(
                              dataSource: _selectedPoll!.choices,
                              xValueMapper: (Choice choice, _) =>
                                  choice.choiceText,
                              yValueMapper: (Choice choice, _) =>
                                  choice.voteCount,
                              color: const Color(0xFFFF9900),
                            )
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPollCard(Poll poll, {required bool isMyPoll}) {
    bool hasVoted = _votedPollIds.contains(poll.id.toString());
    bool canVote = poll.isActive && !hasVoted;

    return Card(
      child: ListTile(
        title: Text(poll.question),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created by: ${isMyPoll ? 'You' : poll.authorUsername}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: poll.isActive ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                poll.isActive ? 'Open' : 'Closed',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMyPoll)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deletePoll(poll),
              ),
            TextButton(
              onPressed: () => _fetchPollResults(poll),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
              ),
              child: const Text('Results'),
            ),
            if (canVote)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VoteScreen(poll: poll),
                    ),
                  ).then((_) {
                    _fetchPolls();
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green,
                ),
                child: const Text('Vote'),
              ),
          ],
        ),
      ),
    );
  }
}
