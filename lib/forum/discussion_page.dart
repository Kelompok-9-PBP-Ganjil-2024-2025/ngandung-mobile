// discussion_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'models/forum_model.dart';
import 'models/comment_model.dart';
import 'package:http/http.dart' as http;

class DiscussionPage extends StatefulWidget {
  final Forum forum;

  const DiscussionPage({Key? key, required this.forum}) : super(key: key);

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  late Future<List<Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    // Memanggil fungsi fetchComments berdasarkan pk dari Forum (Discussion)
    _commentsFuture = fetchComments(widget.forum.pk);
  }

  // Fungsi untuk GET comments dari endpoint Django
  Future<List<Comment>> fetchComments(String forumId) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/discussion/$forumId/comments/'),
    );
    if (response.statusCode == 200) {
      return commentFromJson(response.body);
    } else {
      throw Exception('Failed to load comments');
    }
  }

  // Fungsi untuk DELETE forum
  Future<void> forumDelete(CookieRequest request) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/delete-forum-flutter/${widget.forum.pk}/',
        {},
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Forum deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembalikan true untuk menyegarkan ForumScreen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete forum'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to delete forum'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menggunakan Provider untuk mendapatkan CookieRequest
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Color(0xFFFF9900), // Warna tombol back
        ),
        title: Text(
          widget.forum.fields.title,
          style: const TextStyle(
            color: Color(0xFFFF9900), // Warna teks
          ),
        ),
        backgroundColor: const Color(0xFF111111),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              // Konfirmasi sebelum menghapus
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Hapus'),
                  content: const Text('Yakin ingin menghapus forum ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Hapus'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await forumDelete(request);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan konten forum di bagian atas
            Text(
              widget.forum.fields.content,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Expanded agar daftar komentar memenuhi sisa ruang di layar
            Expanded(
              child: FutureBuilder<List<Comment>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada komentar'));
                  } else {
                    // Tampilkan komentar di sini
                    var comments = snapshot.data!;
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              comments[index].fields.content,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Oleh userId: ${comments[index].fields.user}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      // Tambahkan warna latar belakang (opsional)
      backgroundColor: const Color(0xFF000000),
    );
  }
}
