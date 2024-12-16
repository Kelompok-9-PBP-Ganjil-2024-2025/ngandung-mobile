import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../models/poll.dart';
import 'dart:convert';
import 'package:provider/provider.dart';

class PollsScreen extends StatefulWidget {
  const PollsScreen({super.key});

  @override
  State<PollsScreen> createState() => _PollsScreenState();
}

class _PollsScreenState extends State<PollsScreen> {
  Future<List<Poll>> fetchPolls(CookieRequest request) async {
    final response =
        await request.get('http://127.0.0.1:8000/polling-makanan/');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load polls');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Polls')),
        body: FutureBuilder<List<Poll>>(
          future: fetchPolls(context.watch<CookieRequest>()),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (!snapshot.hasData) {
                return const Center(
                  child: Text('No data'),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data[index].question),
                    );
                  },
                );
              }
            }
          },
        ));
  }
}
