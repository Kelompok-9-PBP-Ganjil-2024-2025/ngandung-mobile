import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:ngandung_mobile/landing/home_screen.dart';
import 'package:ngandung_mobile/store/screens/detail_makanan.dart';

class FavoriteListPage extends StatefulWidget {
  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  List<dynamic> allRestaurants = []; // Data dari API
  List<dynamic> filteredRestaurants = []; // Data setelah filter
  bool isLoading = true; // Indikator pemuatan

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Panggil fetchFavorites() hanya jika data belum dimuat
    if (isLoading) {
      CookieRequest request = context.watch<CookieRequest>();
      fetchFavorites(request);
    }
  }

  // Fungsi untuk fetch data dari API
  Future<void> fetchFavorites(CookieRequest request) async {
    try {
      final response =
          await request.get('http://127.0.0.1:8000/api/user/favorites/');
      if (response != null && response is List) {
        setState(() {
          allRestaurants = response; // Simpan semua data
          filteredRestaurants = response; // Tampilkan data awal
          isLoading = false; // Pemuatan selesai
        });
      } else {
        throw Exception('Invalid response format');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        allRestaurants = [];
        filteredRestaurants = [];
        isLoading = false; // Tetapkan false untuk menghentikan pemuatan
      });
    }
  }

  // Fungsi untuk menghapus data favorit
  Future<void> deleteFavorite(CookieRequest request, int rumahMakanId) async {
    try {
      final response = await request.post(
        'http://127.0.0.1:8000/api/user/favorites/$rumahMakanId/delete/',
        {}, // Data kosong karena parameter dikirim di URL
      );
      if (response['message'] == 'Favorite deleted successfully') {
        setState(() {
          allRestaurants.removeWhere(
              (favorite) => favorite['rumah_makan']['id'] == rumahMakanId);
          filteredRestaurants.removeWhere(
              (favorite) => favorite['rumah_makan']['id'] == rumahMakanId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restoran berhasil dihapus dari favorit!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to delete favorite');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus favorit: $e'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error deleting favorite: $e');
    }
  }

  // Fungsi untuk filter restoran berdasarkan nama, kota, atau alamat
  void filterRestaurants(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRestaurants = allRestaurants;
      } else {
        filteredRestaurants = allRestaurants.where((restaurant) {
          final name = restaurant['rumah_makan']['nama_rumah_makan']
              .toString()
              .toLowerCase();
          final location = restaurant['rumah_makan']['bps_nama_kabupaten_kota']
              .toString()
              .toLowerCase();
          final address =
              restaurant['rumah_makan']['alamat'].toString().toLowerCase();
          return name.contains(query.toLowerCase()) ||
              location.contains(query.toLowerCase()) ||
              address.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFE9B12),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen()), // Ganti HomePage dengan nama halaman utama Anda
              (route) => false,
            );
          },
        ),
        title: Text(
          "Restoran Favorit",
          style: TextStyle(
            color: Colors.white, // Mengubah warna font menjadi putih
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator()) // Tampilkan indikator loading
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    "Restoran favorit kamu akan ditampilkan di sini!",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 44, 44, 44),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: filterRestaurants, // Fungsi filter restoran Anda
                    decoration: InputDecoration(
                      hintText: "Cari restoran...",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(
                            0.5), // Ubah opacity di sini (0.0 - 1.0)
                      ),
                      prefixIcon: Icon(Icons.search, color: Color(0xFFFE9B12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFFFE9B12), width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Color(0xFFFE9B12), width: 2),
                      ),
                    ),
                  ),
                ),
                // Grid View
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: filteredRestaurants.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Tidak ada restoran favorit.",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomeScreen()),
                                      (route) => false,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(
                                        0xFFFE9B12), // Warna tombol oranye
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    "Mulai tambahkan favorit!",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: filteredRestaurants.length,
                            itemBuilder: (context, index) {
                              final favorite = filteredRestaurants[index];
                              final restaurant = favorite['rumah_makan'];
                              final relatedFoodId =
                                  restaurant['makanan_terkait']?['id'];

                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                child: Stack(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Gambar restoran
                                        AspectRatio(
                                          aspectRatio: 16 / 9,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(12)),
                                            child: Image.network(
                                              'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/12/00/d2/8e/flavours-of-china.jpg',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        // Informasi restoran
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                restaurant['nama_rumah_makan'],
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                restaurant[
                                                    'bps_nama_kabupaten_kota'],
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              Text(
                                                restaurant['alamat'],
                                                style: TextStyle(
                                                  color: Colors.grey[600],
                                                  fontSize: 12,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Tombol hapus dan detail di bagian bawah
                                    Positioned(
                                      bottom: 8,
                                      left: 8,
                                      right: 8,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Tombol hapus
                                          GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    AlertDialog(
                                                  title:
                                                      Text('Konfirmasi Hapus'),
                                                  content: Text(
                                                      'Apakah Anda yakin ingin menghapus restoran ini dari favorit?'),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(
                                                              context),
                                                      child: Text('Batal'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        await deleteFavorite(
                                                          context.read<
                                                              CookieRequest>(),
                                                          restaurant['id'],
                                                        );
                                                      },
                                                      child: Text('Hapus'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: 30,
                                              height: 30,
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                Icons.delete,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                          // Tombol detail
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Color(0xFFFE9B12),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 8),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            onPressed: relatedFoodId != null
                                                ? () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            DetailRumahMakanPage(
                                                          id: relatedFoodId, // Gunakan id makanan
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                : null, // Disable tombol jika tidak ada makanan terkait
                                            child: Text(
                                              "Detail",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
