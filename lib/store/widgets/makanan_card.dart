// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:ngandung_mobile/store/screens/detail_makanan.dart';
import 'package:ngandung_mobile/store/screens/edit_makanan.dart';

class MakananCard extends StatelessWidget {
  final String imageurl;
  final String name;
  final int price;
  final int id;
  final Function() onDelete;

  const MakananCard({
    super.key,
    required this.imageurl,
    required this.name,
    required this.price,
    required this.id, 
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //*===========================================Image===========================================
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  imageurl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.grey),
                    );
                  },
                ),
              ),

              //*===========================================Text Content===========================================
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //*===========================================Nama Makanan===========================================
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    //*===========================================Harga Makanan===========================================
                    Text(
                      "Rp ${price.toString()}.00",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),

          //*===========================================Tombol detail===========================================
          Positioned(
              bottom: 10,
              left: 10,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi tombol
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailRumahMakanPage(id: id),
                      ));
                },
                style: ElevatedButton.styleFrom(
                  // Warna latar belakang button
                  backgroundColor: Colors.orange,
                  // Warna teks
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Atur radius sudut
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  elevation: 3,
                ),
                child: const Text(
                  'Detail',
                  style: TextStyle(
                    // Styling teks
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
          //*===========================================Button Edit & Delete===========================================
          Positioned(
            bottom: 10,
            right: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                //* Tombol Edit
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditMakananPage(id: id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  color: Colors.blue,
                ),

                //* Tombol Delete
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
