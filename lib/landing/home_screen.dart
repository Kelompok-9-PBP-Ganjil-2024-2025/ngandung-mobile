// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:ngandung_mobile/landing/widgets/navbar.dart';
import 'package:ngandung_mobile/store/models/makanan.dart';
import 'package:ngandung_mobile/store/widgets/makanan_card.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Makanan> _allMakanan = []; // Store all makanan
  List<Makanan> _filteredMakanan = []; // Store filtered makanan
  final TextEditingController _searchController = TextEditingController();

  Future<List<Makanan>> fetchMakanan(CookieRequest request) async {
    final response = await request.get('http://127.0.0.1:8000/makanan-json/');
    
    var data = response;
    
    List<Makanan> listMakanan = [];
    for (var d in data) {
      if (d != null) {
        listMakanan.add(Makanan.fromJson(d));
      }
    }
    return listMakanan;
  }

  void _filterMakanan(String query) {
    setState(() {
      _filteredMakanan = _allMakanan
          .where((makanan) => 
            makanan.fields.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    // Add listener to search controller
    _searchController.addListener(() {
      _filterMakanan(_searchController.text);
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed
    _searchController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Add navigation logic here based on the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    final req = context.watch<CookieRequest>();
    return Scaffold(
      body: Column(
        children: [
          // Header Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange[500]!, Colors.orange[300]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bingung mau makan apa? (・・？)',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Temukan Makanan Favoritmu',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari makanan...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          
          // Expanded to fill remaining space with GridView
          Expanded(
            child: FutureBuilder<List<Makanan>>(
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

                // Display makanan in a grid view
                return GridView.builder(
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
                          'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/12/00/d2/8e/flavours-of-china.jpg', // Add actual image URL if available
                      name: makanan.fields.name,
                      price: makanan.fields.price,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Move the bottomNavigationBar to the Scaffold level
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}