// forum_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'models/forum_model.dart';
import 'discussion_page.dart';
import 'add_forum.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  late Future<List<Forum>> _forumsFuture;

  @override
  void initState() {
    super.initState();
    _forumsFuture = fetchForums();
  }

  // Function to fetch data from API
  Future<List<Forum>> fetchForums() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/forum'));

    if (response.statusCode == 200) {
      // If request is successful, parse JSON data into Forum objects
      return forumFromJson(response.body);
    } else {
      throw Exception('Failed to load forums');
    }
  }

  // Function to refresh forums
  void _refreshForums() {
    setState(() {
      _forumsFuture = fetchForums();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background for contrast
      appBar: AppBar(
        title: const Text(
          'Forum Page',
          style: TextStyle(
            color: Color(0xFFFF9900),
          ),
        ),
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
      ),
      body: FutureBuilder<List<Forum>>(
        future: _forumsFuture, // Call the fetchForums function
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading spinner while data is loading
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show error message if there's an issue fetching data
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // If data is successfully fetched, display the list of forums
            List<Forum> forums = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: forums.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFF9900), width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    color: Colors.white,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                    title: Text(
                      forums[index].fields.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111111),
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        forums[index].fields.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF666666),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 16, color: Color(0xFF999999)),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(forums[index].fields.lastUpdated),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF999999),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      // Navigate to the discussion page when a forum is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DiscussionPage(forum: forums[index]),
                        ),
                      ).then((value) {
                        if (value == true) {
                          // Refresh the forums list if a forum was deleted
                          _refreshForums();
                        }
                      });
                    },
                  ),
                );
              },
            );
          } else {
            // If no data is available
            return const Center(child: Text('No data available.'));
          }
        },
      ),
      // Adding FloatingActionButton for navigation to AddForumFormPage
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddForumForm()),
          ).then((value) {
            if (value == true) {
              // Refresh the forums list if a new forum was added
              _refreshForums();
            }
          });
        },
        label: const Text(
          'Add Forum',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFFF9900), // Matching the border color
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
    );
  }

  // Helper function to format the date
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
