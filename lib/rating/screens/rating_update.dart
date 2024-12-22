// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class RatingUpdate extends StatefulWidget {
  final int rating;
  final String review;
  final int idRating;
  final int idRumahMakan;

  const RatingUpdate({
    super.key,
    required this.rating,
    required this.review,
    required this.idRating,
    required this.idRumahMakan,
  });

  @override
  State<RatingUpdate> createState() => _RatingUpdateState();
}

class _RatingUpdateState extends State<RatingUpdate> {
  late int _rating;
  late TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
    _reviewController = TextEditingController(text: widget.review);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Review'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Star Rating Input
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: index < _rating ? Colors.yellow : Colors.grey,
                    size: 50,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 20),
            // Review Text Input
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Edit review-mu di sini boz!',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 20),
            // Update Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[400],
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              onPressed: () async {
                if (_rating > 0 && _reviewController.text.isNotEmpty) {
                  final response = await request.postJson(
                    "http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/api/rating-toko/update-flutter/",
                    jsonEncode(<String, dynamic>{
                      'rating': _rating,
                      'review': _reviewController.text,
                      'id_rating': widget.idRating,
                      'id_rumah_makan': widget.idRumahMakan,
                    }),
                  );
                  if (response['status'] == 'success') {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Review berhasil diupdate!"),
                      ),
                    );
                    Navigator.pop(context, true); // Return true on success
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Gagal mengupdate review."),
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Silakan isi semua field."),
                    ),
                  );
                }
              },
              child: const Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
