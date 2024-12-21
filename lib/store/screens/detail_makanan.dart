// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ngandung_mobile/landing/widgets/navbar.dart';
import 'package:ngandung_mobile/store/screens/edit_rumahmakan.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class DetailMakananPage extends StatelessWidget {
  final int id;

  const DetailMakananPage({super.key, required this.id});

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
        future: fetchDetail(req, id), // Panggil fetchDetail
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                //*===========================================Edit Button===========================================
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditRumahMakanPage(id: data['rumah_makan']['id']),
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
                        _showDeleteConfirmation(context, data['rumah_makan']['id']);
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
                const SizedBox(height: 20),
                //*===========================================List Makanan===========================================
                const Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 10.0), 
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
}

//* Untuk memunculkan popup ketika delete rumah makan
void _showDeleteConfirmation(BuildContext context, int id) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus rumah makan ini? Semua makanan yang terkait juga akan dihapus.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Tutup dialog
              final success = await _deleteRumahMakan(context, id);
              if (success) {
                // Kembali ke halaman utama jika berhasil
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
          ),
        ],
      );
    },
  );
}

Future<bool> _deleteRumahMakan(BuildContext context, int id) async {
  try {
    final response = await http.delete(
      Uri.parse('http://127.0.0.1:8000/delete-rumahmakan/$id/'),
    );

    if (response.statusCode == 200) {
      // Tampilkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rumah makan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } else {
      // Tampilkan pesan gagal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus rumah makan'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  } catch (e) {
    // Tampilkan pesan error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Terjadi kesalahan, coba lagi'),
        backgroundColor: Colors.red,
      ),
    );
    return false;
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
