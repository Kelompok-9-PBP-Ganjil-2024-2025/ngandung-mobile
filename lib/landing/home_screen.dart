// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ngandung_mobile/landing/widgets/logout.dart';
import 'package:ngandung_mobile/landing/widgets/navbar.dart';
import 'package:ngandung_mobile/store/models/makanan.dart';
import 'package:ngandung_mobile/store/screens/makanan_form.dart';
import 'package:ngandung_mobile/store/screens/rumahmakan_form.dart';
import 'package:ngandung_mobile/store/widgets/makanan_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Makanan> _allMakanan = [];
  List<Makanan> _filteredMakanan = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSuperuser = false;

  Future<List<Makanan>> fetchMakanan(CookieRequest request) async {
    final response = await request.get('http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/makanan-json/');

    List<Makanan> listMakanan = [];
    for (var d in response) {
      if (d != null) {
        listMakanan.add(Makanan.fromJson(d));
      }
    }
    return listMakanan;
  }

  void _filterMakanan(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredMakanan = _allMakanan;
      } else {
        _filteredMakanan = _allMakanan
            .where((makanan) =>
                makanan.fields.name
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                makanan.fields.price
                    .toString()
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  Future<bool> _deleteMakanan(BuildContext context, int id) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request
          .post('http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/delete-makanan-flutter/$id/', {
        'id': id.toString(),
      });

      if (response['success']) {
        setState(() {
          _allMakanan.removeWhere((makanan) => makanan.pk == id);
          _filteredMakanan.removeWhere((makanan) => makanan.pk == id);
        });
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting makanan: $e');
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    final req = context.read<CookieRequest>();
    setState(() {
      _isSuperuser = req.jsonData['is_superuser'] ?? false;
    });
    _searchController.addListener(() {
      _filterMakanan(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final req = context.watch<CookieRequest>();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(150), // Tinggi AppBar termasuk search bar
        child: AppBar(
          backgroundColor: const Color(0xFFFE9B12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
          flexibleSpace: Padding(
            padding: const EdgeInsets.fromLTRB(16, 5, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Title
                Text(
                  'NGANDUNG', // Sesuaikan teks title
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: _filterMakanan,
                  decoration: InputDecoration(
                    hintText: "Cari cemilan favoritmu...",
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon:
                        const Icon(Icons.search, color: Color(0xFFFE9B12)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.transparent, width: 0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.transparent, width: 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              color: const Color(0xFFFFF4E5),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang di Ngandung!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFE9B12),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Lagi di Bandung trs bingung mau makan apa? (・・？), cari aja disini!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isSuperuser)
            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Tombol di kiri
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MakananFormPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange, // Warna tombol
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tambah Makanan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(right: 16.0), // Jarak antar tombol
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RumahMakanFormPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Warna tombol
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tambah Rumah Makan',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          FutureBuilder<List<Makanan>>(
            future: fetchMakanan(req),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }

              // Store all makanan when data is first loaded
              if (_allMakanan.isEmpty && snapshot.hasData) {
                _allMakanan = snapshot.data!;
                _filteredMakanan = _allMakanan;
              }

              if (_filteredMakanan.isEmpty) {
                return const Center(
                  child: Text('Tidak ada makanan ditemukan'),
                );
              }

              // Display makanan dalam grid view
              return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _filteredMakanan.length,
                itemBuilder: (context, index) {
                  Makanan makanan = _filteredMakanan[index];
                  return MakananCard(
                    imageurl:
                        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/12/00/d2/8e/flavours-of-china.jpg',
                    name: makanan.fields.name,
                    price: makanan.fields.price,
                    id: makanan.pk,
                    onDelete: () =>
                        _showDeleteConfirmation(context, makanan.pk),
                    admin: _isSuperuser,
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: const LogoutButton(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text("Apakah Anda yakin ingin menghapus makanan ini?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                final success = await _deleteMakanan(context, id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "Makanan berhasil dihapus"
                          : "Gagal menghapus makanan",
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                "Hapus",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
