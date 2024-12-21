import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:ngandung_mobile/landing/widgets/navbar.dart'; // Import Navbar

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

  // Fungsi untuk filter restoran berdasarkan nama atau lokasi
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
          return name.contains(query.toLowerCase()) ||
              location.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator()) // Tampilkan indikator loading
          : Column(
              children: [
                // Header dengan Background Kuning Lebar
                Container(
                  width: double.infinity,
                  color: Color(0xFFFE9B12),
                  padding: const EdgeInsets.symmetric(
                      vertical: 20.0, horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Restoran Favorit",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Restoran favorit kamu disimpan di sini!",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: filterRestaurants,
                    decoration: InputDecoration(
                      hintText: "Cari restoran...",
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
                        ? Center(child: Text("Tidak ada restoran favorit."))
                        : GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 200,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 3 / 4,
                            ),
                            itemCount: filteredRestaurants.length,
                            itemBuilder: (context, index) {
                              final restaurant =
                                  filteredRestaurants[index]['rumah_makan'];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                      color: Color(0xFFFE9B12), width: 2),
                                ),
                                elevation: 4,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // Placeholder untuk gambar restoran
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[300],
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(12),
                                          ),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.restaurant_menu,
                                            size: 50,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Informasi restoran
                                    Expanded(
                                      flex: 1,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
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
                                            Text(
                                              restaurant[
                                                  'bps_nama_kabupaten_kota'],
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
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
      bottomNavigationBar: BottomNavBar(), // Tambahkan Navbar di sini
    );
  }
}
