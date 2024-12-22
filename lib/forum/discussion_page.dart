// discussion_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'models/forum_model.dart';
import 'models/comment_model.dart';
import 'edit_forum.dart'; // Pastikan untuk mengimpor halaman edit_forum.dart
import 'package:http/http.dart' as http;

class DiscussionPage extends StatefulWidget {
  final Forum forum;

  const DiscussionPage({Key? key, required this.forum}) : super(key: key);

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  late Future<List<Comment>> _commentsFuture;
  late Forum currentForum;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentForum = widget.forum;
    _commentsFuture = fetchComments(currentForum.pk);
  }

  // Fungsi untuk GET comments dari endpoint Django
  Future<List<Comment>> fetchComments(String forumId) async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/discussion/$forumId/comments/'), // Pastikan URL ini benar
    );
    if (response.statusCode == 200) {
      return commentFromJson(response.body);
    } else {
      throw Exception('Failed to load comments');
    }
  }

  // Fungsi untuk POST comment ke API
  Future<void> addComment(String content) async {
    final request = context.read<CookieRequest>();
    final url = Uri.parse('http://127.0.0.1:8000/api/discussion/${currentForum.pk}/add_comment/');

    final response = await request.post(
      url.toString(),
      {
        "content": content,
        // "parent": "UUID-komentar-atasan jika diperlukan" // Tambahkan jika diperlukan
      },
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar berhasil ditambahkan'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _commentsFuture = fetchComments(currentForum.pk);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Gagal menambahkan komentar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk DELETE comment ke API
  Future<void> deleteComment(String commentId) async {
    final request = context.read<CookieRequest>();
    final url = Uri.parse('http://127.0.0.1:8000/api/discussion/comments/$commentId/delete/');

    final response = await request.post(
      url.toString(),
      {}, // Payload kosong karena API hanya membutuhkan comment_id dari URL
    );

    if (response['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Komentar berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _commentsFuture = fetchComments(currentForum.pk);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Gagal menghapus komentar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk menampilkan dialog Add Comment
  void _showAddCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Komentar'),
          content: TextField(
            controller: _commentController,
            decoration: const InputDecoration(
              hintText: 'Masukkan komentar Anda...',
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _commentController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final content = _commentController.text.trim();
                if (content.isNotEmpty) {
                  addComment(content);
                  _commentController.clear();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Kirim'),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk DELETE forum
  Future<void> forumDelete(CookieRequest request) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/delete-forum-flutter/${currentForum.pk}/',
        {},
      );

      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Forum berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Kembalikan true untuk menyegarkan ForumScreen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal menghapus forum'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus forum'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Color(0xFFFF9900), // Warna tombol back
        ),
        title: Text(
          currentForum.fields.title,
          style: const TextStyle(
            color: Color(0xFFFF9900), // Warna teks
          ),
        ),
        backgroundColor: const Color(0xFF111111),
        actions: [
          // Tombol Edit
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              // Navigasi ke halaman EditForumPage dengan mengirimkan data forum
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditForumPage(forum: currentForum),
                ),
              ).then((value) {
                if (value != null && value is Map<String, String>) {
                  setState(() {
                    // Update currentForum dengan data yang diubah
                    currentForum.fields.title = value['title'] ?? currentForum.fields.title;
                    currentForum.fields.content = value['content'] ?? currentForum.fields.content;
                  });
                  // Kembalikan data yang diupdate ke ForumScreen
                  Navigator.pop(context, value);
                }
              });
            },
          ),
          // Tombol Delete
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
              currentForum.fields.content,
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
                        final comment = comments[index];
                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              comment.fields.content,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Oleh userId: ${comment.fields.user}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Tampilkan dialog konfirmasi sebelum menghapus
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Konfirmasi Hapus'),
                                    content: const Text('Yakin ingin menghapus komentar ini?'),
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
                                  await deleteComment(comment.pk);
                                }
                              },
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
      // Tambahkan tombol Add Comment
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommentDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add_comment, color: Colors.white),
        tooltip: 'Tambah Komentar',
      ),
      // Tambahkan warna latar belakang (opsional)
      backgroundColor: const Color(0xFF000000),
    );
  }
}
