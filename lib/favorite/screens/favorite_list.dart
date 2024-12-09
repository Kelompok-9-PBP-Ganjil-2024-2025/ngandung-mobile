import 'package:flutter/material.dart';

class FavoriteListPage extends StatefulWidget {
  @override
  _FavoriteListPageState createState() => _FavoriteListPageState();
}

class _FavoriteListPageState extends State<FavoriteListPage> {
  final List<Map<String, String>> allRestaurants = [
    {"name": "Restoran A", "location": "Jakarta", "rating": "4.5"},
    {"name": "Restoran B", "location": "Bandung", "rating": "4.7"},
    {"name": "Restoran C", "location": "Surabaya", "rating": "4.3"},
    {"name": "Restoran D", "location": "Yogyakarta", "rating": "4.6"},
    {"name": "Restoran E", "location": "Bali", "rating": "4.8"},
    {"name": "Restoran F", "location": "Semarang", "rating": "4.2"},
  ];

  List<Map<String, String>> filteredRestaurants = [];

  @override
  void initState() {
    super.initState();
    filteredRestaurants = allRestaurants; // Awalnya menampilkan semua restoran
  }

  void filterRestaurants(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredRestaurants = allRestaurants;
      } else {
        filteredRestaurants = allRestaurants
            .where((restaurant) =>
                restaurant["name"]!
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                restaurant["location"]!
                    .toLowerCase()
                    .contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header dengan Background Kuning Lebar
          Container(
            width: double
                .infinity, // Membuat background kuning memenuhi lebar layar
            color: Color(0xFFFE9B12), // Warna kuning
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
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
                  borderSide: BorderSide(color: Color(0xFFFE9B12), width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFFFE9B12), width: 2),
                ),
              ),
            ),
          ),
          // Grid View
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, // Lebar maksimum tile
                  crossAxisSpacing: 8, // Jarak antar kolom
                  mainAxisSpacing: 8, // Jarak antar baris
                  childAspectRatio: 3 / 4, // Rasio aspek tile
                ),
                itemCount: filteredRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = filteredRestaurants[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Color(0xFFFE9B12), width: 2),
                    ),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        restaurant["name"]!,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: constraints.maxWidth * 0.1,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        restaurant["location"]!,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: constraints.maxWidth * 0.08,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.star,
                                            color: Colors.amber,
                                            size: constraints.maxWidth * 0.08),
                                        SizedBox(width: 4),
                                        FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text(
                                            restaurant["rating"]!,
                                            style: TextStyle(
                                              fontSize:
                                                  constraints.maxWidth * 0.08,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
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
    );
  }
}
