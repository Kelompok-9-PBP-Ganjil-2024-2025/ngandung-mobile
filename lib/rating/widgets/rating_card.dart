import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/rating_model.dart';
import '../screens/rating_update.dart';

class RatingCard extends StatelessWidget {
  final Rating rating;
  final String userName;
  final int idRating;
  final int idRumahMakan;
  final VoidCallback? onUpdate; // Optional callback

  const RatingCard({
    super.key,
    required this.rating,
    required this.userName,
    required this.idRating,
    required this.idRumahMakan,
    this.onUpdate,
  });

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isSuperuser = request.jsonData['is_superuser'];
    final String username = request.jsonData['username'];

    final stars = List.generate(
      rating.fields.rating,
      (i) => const Icon(Icons.star, color: Colors.yellow, size: 16),
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Row(children: stars),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(rating.fields.review),
            const SizedBox(height: 4),
            Text(
              _formatDate(rating.fields.tanggal),
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 8),
            if (isSuperuser || username == userName)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Edit Button
                  ElevatedButton(
                    onPressed: () async {
                      bool? result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RatingUpdate(
                            rating: rating.fields.rating,
                            review: rating.fields.review,
                            idRating: idRating,
                            idRumahMakan: idRumahMakan,
                          ),
                        ),
                      );
                      if (result == true && onUpdate != null) {
                        onUpdate!();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      minimumSize: const Size(40, 40),
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.orange.shade400,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8), // Spacing between buttons
                  // Delete Button
                  ElevatedButton(
                    onPressed: () async {
                      bool? shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: const Text(
                                'Are you sure you want to delete this rating?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );

                      if (shouldDelete == true) {
                        final response = await request.postJson(
                          "http://daffa-abhipraya-ngandung.pbp.cs.ui.ac.id/api/rating-toko/delete-flutter/",
                          jsonEncode({
                            'id_rating': idRating,
                            'id_rumah_makan': idRumahMakan,
                          }),
                        );

                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Rating successfully deleted")),
                            );
                            if (onUpdate != null) {
                              onUpdate!();
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Failed to delete rating")),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 8.0,
                      ),
                      minimumSize: const Size(40, 40),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
