import 'dart:convert';

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
  Future<List<Makanan>> fetchMakanan() async {
    final request = context.watch<CookieRequest>();

    final response =
        await request.get('https://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/');

    // Parse the JSON response using the makananFromJson function
    List<Makanan> makananList = makananFromJson(json.encode(response));

    return makananList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Makanan'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Makanan>>(
        future: fetchMakanan(),
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
