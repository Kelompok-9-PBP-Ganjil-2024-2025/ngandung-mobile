// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ngandung_mobile/landing/home_screen.dart';
import 'package:ngandung_mobile/landing/widgets/navbar.dart';
import 'package:ngandung_mobile/store/screens/edit_rumahmakan.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailRumahMakanPage extends StatefulWidget {
  final int id;

  const DetailRumahMakanPage({super.key, required this.id});

  @override
  // ignore: library_private_types_in_public_api
  _DetailRumahMakanState createState() => _DetailRumahMakanState();
}

class _DetailRumahMakanState extends State<DetailRumahMakanPage> {
  bool _isSuperuser = false;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    fetchDetailAndCheckFavorite(request); // Fetch detail dan cek favorit
  }

  Future<Map<String, dynamic>> fetchDetail(CookieRequest req, int id) async {
    final response = await req.get('http://127.0.0.1:8000/detail-json/$id/');

    return response;
  }

  static String getMakananType(String type) {
    if (type.toLowerCase() == "semua") {
      return "Makanan Berat dan Ringan";
    } else if (type.toLowerCase() == "berat") {
      return "Makanan Berat";
    } else if (type.toLowerCase() == "ringan") {
      return "Makanan Ringan";
    } else {
      return "Tidak tersedia";
    }
  }

  Future<bool> _deleteRumahMakan(BuildContext context, int id) async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request
          .post('http://127.0.0.1:8000/delete-rumahmakan-flutter/$id/', {
        'id': id.toString(),
      });

      if (response['success']) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting makanan: $e');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final req = context.watch<CookieRequest>();
    return Scaffold(
      //*===========================================AppBar===========================================
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(100), // Tinggi AppBar termasuk search bar
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
                Text(
                  'NGANDUNG',
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
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchDetail(req, widget.id), // Panggil fetchDetail
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (snapshot.hasData) {
            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      "https://cdn-icons-png.flaticon.com/256/695/695992.png",
                      height: 120, // Atur tinggi gambar
                      width: 120, // Atur lebar gambar
                      fit: BoxFit.cover, // Sesuaikan gambar
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          width: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported,
                              color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                //*===========================================Nama Rumah Makan===========================================
                Center(
                  child: Text(
                    data['rumah_makan']
                        ['nama_rumah_makan'], // Nama rumah makan dari data
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFE9B12),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                if (_isSuperuser)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //*===========================================Edit Button===========================================
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditRumahMakanPage(
                                  id: data['rumah_makan']['id']),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Edit Rumah Makan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      //*===========================================Delete Button===========================================
                      ElevatedButton(
                        onPressed: () {
                          _showDeleteConfirmation(
                              context, data['rumah_makan']['id']);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Hapus Rumah Makan',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 20.0),
                //*===========================================Detail Rumah Makan===========================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InfoCard(
                      icon: Icons.restaurant_rounded,
                      content: getMakananType(
                          data['rumah_makan']['makanan_berat_ringan'] ?? ''),
                    ),
                    InfoCard(
                      icon: Icons.paid_outlined,
                      content:
                          'Rp ${data["min_price"]} - Rp ${data["max_price"]}',
                    ),
                    InfoCard(
                      icon: Icons.location_on_outlined,
                      content:
                          data['rumah_makan']['alamat'] ?? 'Tidak tersedia',
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),
                //*===========================================GMap Button===========================================
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFE9B12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: const Text(
                    'Buka di Maps',
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: () async {
                    final String? urlString = data['gmap_url'];
                    if (urlString == null || urlString.isEmpty) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('URL Google Maps tidak tersedia'),
                          ),
                        );
                      }
                      return;
                    }

                    final Uri url = Uri.parse(urlString);

                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    } else {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tidak dapat membuka Google Maps'),
                          ),
                        );
                      }
                    }
                  },
                ),
                const SizedBox(height: 10),
                //*===========================================Favorite Button===========================================
                isLoadingFavorite
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isFavorite ? Colors.orange : Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: Icon(
                          isFavorite ? Icons.delete : Icons.favorite,
                          color: Colors.white,
                        ),
                        label: Text(
                          isFavorite
                              ? 'Hapus dari Favorit'
                              : 'Tambah ke Favorit',
                          style: const TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          final request = context.read<CookieRequest>();
                          try {
                            // Ambil rumah_makan.id dari response API
                            final rumahMakanId = data['rumah_makan']['id'];

                            if (isFavorite) {
                              // Hapus dari favorit
                              await deleteFavorite(request, rumahMakanId);
                              setState(() {
                                isFavorite = false;
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Restoran berhasil dihapus dari favorit!'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                              // Kirimkan info bahwa data berubah ke halaman sebelumnya
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      DetailRumahMakanPage(id: widget.id),
                                ),
                                result: true, // Informasikan bahwa data berubah
                              );
                            } else {
                              // Tambah ke favorit
                              final response = await request.post(
                                'http://127.0.0.1:8000/api/user/favorites/add/$rumahMakanId/',
                                {},
                              );
                              if (response['status'] == 'success') {
                                setState(() {
                                  isFavorite = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Restoran berhasil ditambahkan ke favorit!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else if (response['status'] == 'exists') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Restoran sudah ada di favorit.'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Gagal mengubah status favorit: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      ),
                const SizedBox(height: 20),
                //*===========================================List Makanan===========================================
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text(
                    "List Makanan",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 15.0),
                if (data['list_makanan'] != null)
                  ListView.builder(
                    shrinkWrap: true, // * supaya ListView mengikuti konten
                    physics:
                        const NeverScrollableScrollPhysics(), // * Mencegah scroll tersendiri
                    itemCount: (data['list_makanan'] as List<dynamic>).length,
                    itemBuilder: (context, index) {
                      final makanan =
                          (data['list_makanan'] as List<dynamic>)[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 8.0), // * Spacing antar card
                        child: FoodCard(
                          nama: makanan['name'] ?? 'Tidak tersedia',
                          harga: makanan['price'] ?? 0,
                        ),
                      );
                    },
                  )
                else
                  const Text("Belum ada makanan yang terdaftar"),
              ],
            );
          }
          return const Center(child: Text("Data tidak tersedia"));
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  void _showDeleteConfirmation(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Konfirmasi Hapus"),
          content: const Text(
              "Apakah Anda yakin ingin menghapus Rumah Makan ini?, menghapus akan sekaligus menghapus makanan yang berkaitan"),
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
                final success = await _deleteRumahMakan(context, id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? "Rumah Makan berhasil dihapus"
                          : "Gagal menghapus Rumah Makan",
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

  bool isFavorite = false; // Status favorit
  bool isLoadingFavorite = true; // Indikator loading favorit

  Future<void> checkIfFavorite(CookieRequest request, int rumahMakanId) async {
    try {
      final response =
          await request.get('http://127.0.0.1:8000/api/user/favorites/');
      if (response != null && response is List) {
        setState(() {
          // Cek apakah rumah_makan.id ada di daftar favorit
          isFavorite =
              response.any((fav) => fav['rumah_makan']['id'] == rumahMakanId);
          isLoadingFavorite = false;
        });
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      setState(() {
        isFavorite = false;
        isLoadingFavorite = false;
      });
      print('Error checking favorite status: $e');
    }
  }

  Future<void> toggleFavorite(CookieRequest request, int id) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/api/user/favorites/add/$id/',
        {},
      );
      if (response['status'] == 'success') {
        setState(() {
          isFavorite = true; // Tambahkan ke favorit
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restoran berhasil ditambahkan ke favorit!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (response['status'] == 'exists') {
        setState(() {
          isFavorite = false; // Hapus dari favorit
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restoran dihapus dari favorit!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status favorit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteFavorite(CookieRequest request, int favoriteId) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/api/user/favorites/$favoriteId/delete/',
        {}, // Body kosong karena parameter dikirim di URL
      );
      if (response['message'] == 'Favorite deleted successfully') {
        setState(() {
          isFavorite = false; // Update status menjadi tidak favorit
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restoran berhasil dihapus dari favorit!'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Gagal menghapus favorit.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus favorit: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> fetchDetailAndCheckFavorite(CookieRequest request) async {
    try {
      final response =
          await request.get('http://127.0.0.1:8000/detail-json/${widget.id}/');
      final rumahMakanId = response['rumah_makan']
          ['id']; // Ambil rumah_makan.id dari respons detail

      await checkIfFavorite(
          request, rumahMakanId); // Panggil fungsi dengan rumahMakanId
    } catch (e) {
      print('Error fetching detail or checking favorite: $e');
    }
  }
}

class InfoCard extends StatelessWidget {
  // Kartu informasi yang menampilkan icon dan content.

  final IconData icon; // Judul kartu.
  final String content; // Isi kartu.

  const InfoCard({super.key, required this.icon, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Membuat kotak kartu dengan bayangan dibawahnya.
      elevation: 4.0,
      child: Container(
        // Mengatur ukuran dan jarak di dalam kartu.
        width: MediaQuery.of(context).size.width /
            3.5, // menyesuaikan dengan lebar device yang digunakan.
        padding: const EdgeInsets.all(16.0),
        // Menyusun icon dan content secara vertikal.
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFFFE9B12),
              size: 30.0,
            ),
            const SizedBox(height: 8.0),
            Text(
              content,
              textAlign: TextAlign.center, // Optional: Rata tengah teks
              style: const TextStyle(
                fontSize: 14, // Atur ukuran teks di sini
                fontWeight: FontWeight.w500, // Atur ketebalan teks
                color: Colors.black, // Atur warna teks
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  final String nama;
  final int harga;

  const FoodCard({
    super.key,
    required this.nama,
    required this.harga,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity, // Menggunakan lebar penuh
        padding: const EdgeInsets.all(16.0),
        child: Row(
          // Mengubah Column menjadi Row untuk layout horizontal
          mainAxisAlignment: MainAxisAlignment
              .spaceBetween, // Memberi spasi antara nama dan harga
          children: [
            Expanded(
              // Agar nama bisa wrap jika terlalu panjang
              child: Text(
                nama,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 16.0), // Spacing antara nama dan harga
            Text(
              'Rp $harga',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
