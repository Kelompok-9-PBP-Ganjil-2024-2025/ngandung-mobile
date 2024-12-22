// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'models/forum_model.dart';
import 'models/comment_model.dart';
import 'edit_forum.dart';

class DiscussionPage extends StatefulWidget {
  final Forum forum;
  const DiscussionPage({super.key, required this.forum});

  @override
  State<DiscussionPage> createState() => _DiscussionPageState();
}

class _DiscussionPageState extends State<DiscussionPage> {
  late Future<List<Comment>> _commentsFuture;
  late Forum currentForum;
  final TextEditingController _commentController = TextEditingController();
  
  /// Menyimpan ID user yang sedang login
  int _currentUserId = -1;

  @override
  void initState() {
    super.initState();
    currentForum = widget.forum;
    // Mulai fetch komentar
    _commentsFuture = fetchComments(currentForum.pk);
    // Ambil user ID
    _fetchCurrentUserId();
  }

  /// 1. Mendapatkan user.id dari endpoint Django /api/current-user/
  Future<void> _fetchCurrentUserId() async {
    final request = context.read<CookieRequest>();
    const url = 'http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/api/current-user/';
    try {
      final response = await request.get(url);
      if (response['status'] == 'success') {
        setState(() {
          _currentUserId = response['user']['id'];
        });
      }
    } catch (e) {
      // Error handling
    }
  }

  /// 2. Fungsi GET komentar dari API
  Future<List<Comment>> fetchComments(String forumId) async {
    final response = await http.get(
      Uri.parse('http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/api/discussion/$forumId/comments/'),
    );
    if (response.statusCode == 200) {
      return commentFromJson(response.body);
    } else {
      throw Exception('Failed to load comments');
    }
  }

  /// 3. Fungsi menambah komentar
  Future<void> addComment(String content) async {
    final request = context.read<CookieRequest>();
    final url = Uri.parse(
      'http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/api/discussion/${currentForum.pk}/add_comment/',
    );

    final response = await request.post(url.toString(), {
      'content': content,
    });

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

  /// 4. Fungsi Like/Unlike komentar
  Future<void> likeComment(String commentId) async {
    final request = context.read<CookieRequest>();
    final url = Uri.parse(
      'http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/api/discussion/comments/$commentId/like/',
    );

    final response = await request.post(url.toString(), {});

    if (response['status'] == 'success') {
      // Reload komentar agar tampilan likes ter-update
      setState(() {
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

  /// 5. Fungsi menghapus komentar
  Future<void> deleteComment(String commentId) async {
    final request = context.read<CookieRequest>();
    final url = Uri.parse(
      'http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/api/discussion/comments/$commentId/delete/',
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

  /// 6. Fungsi menghapus forum
  Future<void> forumDelete(CookieRequest request) async {
    try {
      final response = await request.post(
        'http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/delete-forum-flutter/${currentForum.pk}/',
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

  /// Menampilkan dialog tambah komentar
  void _showAddCommentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111111),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text(
            'Add Comment',
            style: TextStyle(color: Color(0xFFFF9900)),
          ),
          content: TextField(
            controller: _commentController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Write your comment...',
              hintStyle: const TextStyle(color: Colors.grey),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFF9900)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFFF9900), width: 2),
              ),
            ),
            maxLines: 4,
          ),
          actions: [
            TextButton(
              onPressed: () {
                _commentController.clear();
                Navigator.of(context).pop();
              },
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9900),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Send'),
            ),
          ],
        );
      },
    );
  }

  // --------------------
  // Building UI
  // --------------------
  
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Jika forum kosong (title & content), tampilkan layar "No forum content yet"
    if (currentForum.fields.title.trim().isEmpty &&
        currentForum.fields.content.trim().isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFF111111),
        appBar: _buildAppBar(isForumOwnerOrAdmin: false, request: request),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.forum_outlined,
                size: 64,
                color: Color(0xFFFF9900),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 16),
              const Text(
                'No forum content yet',
                style: TextStyle(
                  color: Color(0xFFFF9900),
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn().moveY(
                    begin: 20,
                    duration: const Duration(milliseconds: 500),
                  ),
            ],
          ),
        ),
      );
    }

    // Cek kepemilikan forum => Tampilkan edit/delete jika forumOwner == userID atau userID == 1
    final forumOwnerId = currentForum.fields.user;
    final isForumOwnerOrAdmin =
        (forumOwnerId == _currentUserId) || (_currentUserId == 1);

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: _buildAppBar(
        isForumOwnerOrAdmin: isForumOwnerOrAdmin,
        request: request,
      ),
      body: Column(
        children: [
          _buildForumContent(),
          const Divider(color: Color(0xFF333333)),
          _buildCommentsList(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCommentDialog,
        backgroundColor: const Color(0xFFFF9900),
        elevation: 4,
        child: const Icon(Icons.add_comment_rounded, color: Colors.white)
            .animate(onPlay: (controller) => controller.repeat())
            .shimmer(duration: const Duration(seconds: 2)),
      ).animate().scale(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({
    required bool isForumOwnerOrAdmin,
    required CookieRequest request,
  }) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFF111111),
      title: Text(
        currentForum.fields.title,
        style: const TextStyle(
          color: Color(0xFFFF9900),
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ).animate().fadeIn().moveX(),
      // Tombol Edit & Delete hanya muncul jika isForumOwnerOrAdmin == true
      actions: isForumOwnerOrAdmin
          ? [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Color(0xFFFF9900)),
                onPressed: () => _navigateToEdit(context),
              ).animate().fadeIn(),
              IconButton(
                icon: const Icon(Icons.delete_rounded, color: Colors.redAccent),
                onPressed: () => _showDeleteConfirmation(context, request),
              ).animate().fadeIn(),
            ]
          : null,
    );
  }

  Widget _buildForumContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: const Color(0xFF222222),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            currentForum.fields.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ),
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildCommentsList() {
    return Expanded(
      child: FutureBuilder<List<Comment>>(
        future: _commentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFF9900)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 48,
                    color: Color(0xFFFF9900),
                  ).animate().fadeIn().scale(),
                  const SizedBox(height: 16),
                  const Text(
                    'No comments yet',
                    style: TextStyle(
                      color: Color(0xFFFF9900),
                      fontSize: 16,
                    ),
                  ).animate().fadeIn().moveY(begin: 20),
                ],
              ),
            );
          }

          final comments = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: comments.length,
            itemBuilder: (context, index) {
              return _buildCommentCard(comments[index])
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 100 * index))
                  .slideX();
            },
          );
        },
      ),
    );
  }

  Widget _buildCommentCard(Comment comment) {
    final fields = comment.fields;
    final isLiked = fields.likes.contains(_currentUserId);

    return Card(
      color: const Color(0xFF222222),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFFF9900),
                  radius: 16,
                  child: Text(
                    fields.user.toString()[0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'User ${fields.user}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    isLiked
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isLiked ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => _handleLike(comment),
                ),
                Text(
                  fields.likes.length.toString(),
                  style: const TextStyle(color: Colors.white70),
                ),
                // Hapus komentar jika pemilik komentar atau admin
                if (fields.user == _currentUserId || _currentUserId == 1)
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.redAccent,
                      size: 20,
                    ),
                    onPressed: () => _showDeleteCommentConfirmation(comment),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              fields.content,
              style: const TextStyle(color: Colors.white, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLike(Comment comment) {
    likeComment(comment.pk);
  }

  Future<void> _showDeleteCommentConfirmation(Comment comment) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          'Delete Comment?',
          style: TextStyle(color: Color(0xFFFF9900)),
        ),
        content: const Text(
          'Are you sure you want to delete this comment?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await deleteComment(comment.pk);
    }
  }

  void _navigateToEdit(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            EditForumPage(forum: currentForum),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    ).then((value) {
      if (value != null && value is Map<String, String>) {
        setState(() {
          currentForum.fields.title =
              value['title'] ?? currentForum.fields.title;
          currentForum.fields.content =
              value['content'] ?? currentForum.fields.content;
        });
        Navigator.pop(context, value); 
      }
    });
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, CookieRequest request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF222222),
        title: const Text(
          'Delete Forum?',
          style: TextStyle(color: Color(0xFFFF9900)),
        ),
        content: const Text(
          'Are you sure you want to delete this forum?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await forumDelete(request);
    }
  }
}
