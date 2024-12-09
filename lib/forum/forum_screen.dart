import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'models/forum_model.dart'; // Pastikan model sudah diimpor

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  // Fungsi untuk mengambil data dari API
  Future<List<Forum>> fetchForums() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/forum'));

    if (response.statusCode == 200) {
      // Jika request berhasil, parse data JSON ke dalam objek Forum
      return forumFromJson(response.body);
    } else {
      throw Exception('Failed to load forums');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text('Forum Page'),
        backgroundColor: const Color(0xFF333333),
      ),
      body: FutureBuilder<List<Forum>>(
        future: fetchForums(), // Memanggil fungsi fetchForums
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Menampilkan loading spinner saat data sedang dimuat
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Menampilkan error jika terjadi masalah saat mengambil data
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Jika data berhasil diambil, tampilkan daftar forum
            List<Forum> forums = snapshot.data!;
            return ListView.builder(
              itemCount: forums.length,
              itemBuilder: (context, index) {
                return Card(
                  color: const Color(0xFF222222),
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                      forums[index].fields.title, // Menampilkan judul forum
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      forums[index].fields.content, // Menampilkan konten forum
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    trailing: Text(
                      // Menampilkan tanggal terakhir diupdate
                      forums[index].fields.lastUpdated.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                );
              },
            );
          } else {
            // Jika tidak ada data
            return const Center(child: Text('No data available.'));
          }
        },
      ),
    );
  }
}
