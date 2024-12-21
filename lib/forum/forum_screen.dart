// forum_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/forum_model.dart';
import 'discussion_page.dart';
import 'add_forum.dart';

class ForumScreen extends StatefulWidget {
  const ForumScreen({super.key});

  @override
  State<ForumScreen> createState() => _ForumScreenState();
}

class _ForumScreenState extends State<ForumScreen> {
  List<Forum> _forums = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchForums();
  }

  // Fungsi untuk mengambil data dari API
  Future<void> fetchForums() async {
    try {
      final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/forum'));

      if (response.statusCode == 200) {
        // Jika permintaan berhasil, parse JSON menjadi objek Forum
        List<Forum> forums = forumFromJson(response.body);
        setState(() {
          _forums = forums;
          _isLoading = false;
          _errorMessage = null;
        });
      } else {
        setState(() {
          _errorMessage = 'Gagal memuat forum.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk menyegarkan daftar forum
  Future<void> _refreshForums() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    await fetchForums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Latar belakang terang untuk kontras
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Spinner saat memuat data
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!)) // Menampilkan pesan error
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: _forums.length,
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
                          _forums[index].fields.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111111),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _forums[index].fields.content,
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
                              _formatDate(_forums[index].fields.lastUpdated),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Navigasi ke halaman DiscussionPage saat forum ditekan
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiscussionPage(forum: _forums[index]),
                            ),
                          ).then((value) {
                            if (value != null) {
                              if (value is Map<String, String>) {
                                // Jika forum di-edit, update data lokal berdasarkan 'pk'
                                String? updatedPk = value['pk'];
                                String? updatedTitle = value['title'];
                                String? updatedContent = value['content'];

                                if (updatedPk != null && updatedTitle != null && updatedContent != null) {
                                  setState(() {
                                    // Cari index forum yang diupdate berdasarkan 'pk'
                                    int forumIndex = _forums.indexWhere((forum) => forum.pk == updatedPk);
                                    if (forumIndex != -1) {
                                      _forums[forumIndex].fields.title = updatedTitle;
                                      _forums[forumIndex].fields.content = updatedContent;
                                    }
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Forum berhasil diupdate!"),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else if (value == true) {
                                // Jika forum dihapus, refresh daftar forum
                                _refreshForums();
                              }
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
      // Menambahkan FloatingActionButton untuk navigasi ke AddForumFormPage
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddForumForm()),
          ).then((value) {
            if (value == true) {
              // Refresh daftar forum jika forum baru ditambahkan
              _refreshForums();
            }
          });
        },
        label: const Text(
          'Add Forum',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFFFF9900), // Menyesuaikan warna border
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
      ),
    );
  }

  // Fungsi pembantu untuk memformat tanggal
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
