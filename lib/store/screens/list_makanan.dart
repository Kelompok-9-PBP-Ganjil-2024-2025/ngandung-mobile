import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:ngandung_mobile/store/models/makanan.dart';
import 'package:ngandung_mobile/store/widgets/makanan_card.dart';

class MakananPage extends StatefulWidget {
  const MakananPage({super.key});

  @override
  State<MakananPage> createState() => _MakananPageState();
}

class _MakananPageState extends State<MakananPage> {

  List<Makanan> hardcodedMakananList = [
    Makanan(
      model: 'makanan',
      pk: 1,
      fields: Fields(
        name: 'Nasi Goreng',
        price: 25000,
        rumahMakan: 1,
      ),
    ),
    Makanan(
      model: 'makanan',
      pk: 2,
      fields: Fields(
        name: 'Sate Ayam',
        price: 30000,
        rumahMakan: 1,
      ),
    ),
    Makanan(
      model: 'makanan',
      pk: 3,
      fields: Fields(
        name: 'Mie Goreng',
        price: 20000,
        rumahMakan: 1,
      ),
    ),
    Makanan(
      model: 'makanan',
      pk: 4,
      fields: Fields(
        name: 'Bakso',
        price: 15000,
        rumahMakan: 1,
      ),
    ),
    Makanan(
      model: 'makanan',
      pk: 5,
      fields: Fields(
        name: 'Gado-Gado',
        price: 22000,
        rumahMakan: 1,
      ),
    ),
    Makanan(
      model: 'makanan',
      pk: 6,
      fields: Fields(
        name: 'Ayam Goreng',
        price: 35000,
        rumahMakan: 1,
      ),
    ),
  ];

  Future<List<Makanan>> fetchMakanan(CookieRequest request) async {
    // TODO: Ganti URL dan jangan lupa tambahkan trailing slash (/) di akhir URL!
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

  @override
  Widget build(BuildContext context) {
    final req = context.watch<CookieRequest>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makanan'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Makanan>>(
        future: fetchMakanan(req),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No makanan available'),
            );
          }

          // Display makanan in a grid view
          return GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Makanan makanan = snapshot.data![index];
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
    );
  }
}
