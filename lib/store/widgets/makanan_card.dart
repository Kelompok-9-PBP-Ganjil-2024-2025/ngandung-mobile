import 'package:flutter/material.dart';

class MakananCard extends StatelessWidget {
  final String imageurl;
  final String name;
  final int price;

  const MakananCard({
    super.key,
    required this.imageurl,
    required this.name,
    required this.price,
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
              // Image with full width and fixed height
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

              // Padding for text content
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food name
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

                    // Price
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

              // Tambahkan ruang kosong untuk mendorong tombol ke bawah
              const Spacer(),
            ],
          ),

          // Tombol di pojok kiri bawah
          Positioned(
              bottom: 10,
              left: 10,
              child: ElevatedButton(
                onPressed: () {
                  // Aksi tombol
                },
                style: ElevatedButton.styleFrom(
                  // Warna latar belakang button
                  backgroundColor: Colors.orange, // Ubah warna sesuai keinginan

                  // Warna teks
                  foregroundColor: Colors.white,

                  // Bentuk button
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10), // Atur radius sudut
                  ),

                  // Padding internal button
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                  // Elevasi (bayangan)
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
        ],
      ),
    );
  }
}
