// Discussion_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'models/forum_model.dart';
import 'models/comment_model.dart';
import 'edit_forum.dart';
import 'package:http/http.dart' as http;

/// Halaman diskusi forum, menampilkan daftar komentar.
/// Hanya pembuat forum atau Admin (ID == 1) yang dapat mengedit/hapus forum.
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

  /// Menyimpan ID user yang sedang login (agar bisa cek apakah sudah like komentar, dll).
  int _currentUserId = -1;

  @override
  void initState() {
    super.initState();
    currentForum = widget.forum;
    _commentsFuture = fetchComments(currentForum.pk);
    _fetchCurrentUserId(); // Ambil user.id dari endpoint Django
  }

  /// Fungsi untuk mengambil user.id dari endpoint Django:
  Future<void> _fetchCurrentUserId() async {
    final request = context.read<CookieRequest>();
    final url = 'http://127.0.0.1:8000/api/current-user/';
    try {
      final response = await request.get(url);
      if (response['status'] == 'success') {
        setState(() {
          // Simpan user.id di _currentUserId
          _currentUserId = response['user']['id'];
        });
      }
    } catch (e) {
      // Jika error, biarkan saja _currentUserId = -1
    }
  }

  /// Fungsi untuk GET komentar dari endpoint Django
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

  /// Fungsi untuk menambah komentar (POST ke endpoint Django)
  Future<void> addComment(String content) async {
    final request = context.read<CookieRequest>();
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/discussion/${currentForum.pk}/add_comment/',
    );

    final response = await request.post(
      url.toString(),
      {
        "content": content,
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

  /// Fungsi untuk menghapus komentar (DELETE ke endpoint Django)
  Future<void> deleteComment(String commentId) async {
    final request = context.read<CookieRequest>();
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/discussion/comments/$commentId/delete/',
    );

    final response = await request.post(url.toString(), {});

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

  /// Fungsi untuk men–like/unlike komentar
  Future<void> likeComment(String commentId) async {
    final request = context.read<CookieRequest>();
    final url = Uri.parse(
      'http://127.0.0.1:8000/api/discussion/comments/$commentId/like/',
    );

    final response = await request.post(url.toString(), {});

    if (response['status'] == 'success') {
      setState(() {
        // Reload komentar agar total likes terupdate
        _commentsFuture = fetchComments(currentForum.pk);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Gagal mem–like komentar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Menampilkan dialog Add Comment
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

  /// Fungsi untuk menghapus forum
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
        Navigator.pop(context, true); // Kembali ke halaman sebelumnya
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

    // Pastikan forum tidak kosong (title & content)
    if (currentForum.fields.title.trim().isEmpty &&
        currentForum.fields.content.trim().isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF000000),
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Color(0xFFFF9900)),
          backgroundColor: const Color(0xFF111111),
          title: const Text(
            "Forum Kosong",
            style: TextStyle(color: Color(0xFFFF9900)),
          ),
        ),
        body: const Center(
          child: Text(
            'Belum ada forum yang dibuat, ayo buat forum!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFFF9900),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Cek apakah user saat ini adalah pemilik forum atau admin (id = 1)
    final forumOwnerId = currentForum.fields.user; // ID pembuat forum
    final isForumOwnerOrAdmin =
        (forumOwnerId == _currentUserId) || (_currentUserId == 1);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Color(0xFFFF9900), // Warna ikon back
        ),
        title: Text(
          currentForum.fields.title,
          style: const TextStyle(color: Color(0xFFFF9900)),
        ),
        backgroundColor: const Color(0xFF111111),
        // Tampilkan tombol Edit & Delete *hanya* jika isForumOwnerOrAdmin == true
        actions: [
          if (isForumOwnerOrAdmin) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // Navigasi ke halaman EditForumPage dengan data forum
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditForumPage(forum: currentForum),
                  ),
                ).then((value) {
                  if (value != null && value is Map<String, String>) {
                    setState(() {
                      // Update currentForum dengan data yang diubah
                      currentForum.fields.title =
                          value['title'] ?? currentForum.fields.title;
                      currentForum.fields.content =
                          value['content'] ?? currentForum.fields.content;
                    });
                    // Kembalikan data yang diupdate ke ForumScreen
                    Navigator.pop(context, value);
                  }
                });
              },
            ),
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
        ],
      ),
      // Konten
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan konten forum
            Text(
              currentForum.fields.content,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 16),

            // Bagian daftar komentar (FutureBuilder)
            Expanded(
              child: FutureBuilder<List<Comment>>(
                future: _commentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // TULISAN “Belum ada komentar” di tengah dengan warna #FF9900
                    return const Center(
                      child: Text(
                        'Belum ada komentar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFFF9900),
                          fontSize: 16,
                        ),
                      ),
                    );
                  } else {
                    final comments = snapshot.data!;
                    // Tampilkan komentar
                    return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final fields = comment.fields;

                        // Apakah user telah men-like komentar?
                        final isLiked = fields.likes.contains(_currentUserId);

                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(
                              fields.content,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              'Oleh userId: ${fields.user}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            // Tampilkan aksi di trailing
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tombol Hapus Komentar
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Konfirmasi Hapus'),
                                        content: const Text(
                                          'Yakin ingin menghapus komentar ini?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, false),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(ctx, true),
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
                                // Tombol Like
                                IconButton(
                                  icon: Icon(
                                    isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isLiked ? Colors.red : Colors.white,
                                  ),
                                  onPressed: () {
                                    likeComment(comment.pk);
                                  },
                                ),
                                // Jumlah Like
                                Text(
                                  '${fields.likes.length}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
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

      // FloatingActionButton untuk menambah komentar
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommentDialog,
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add_comment, color: Colors.white),
        tooltip: 'Tambah Komentar',
      ),
      backgroundColor: const Color(0xFF000000),
    );
  }
}
