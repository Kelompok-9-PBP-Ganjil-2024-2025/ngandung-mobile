import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

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
                // Title
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
              children: [
                // Gambar
                Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      "https://cdn-icons-png.flaticon.com/256/695/695992.png", // Ganti dengan URL dari data jika ada
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
                // Nama Rumah Makan
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InfoCard(
                      icon: Icons.restaurant_rounded,
                      content: getMakananType(data['rumah_makan']['makanan_berat_ringan'] ?? ''),
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

                // Memberikan jarak vertikal 16 unit.
                const SizedBox(height: 16.0),
              ],
            );
          }
          return const Center(child: Text("Data tidak tersedia"));
        },
      ),
    );
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
      elevation: 2.0,
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
