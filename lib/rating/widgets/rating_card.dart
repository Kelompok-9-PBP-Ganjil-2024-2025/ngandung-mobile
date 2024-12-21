import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
            // Updated ElevatedButton with Edit (Pencil) Icon
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
                  onUpdate!(); // Invoke the callback to refresh data
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
          ],
        ),
      ),
    );
  }
}
