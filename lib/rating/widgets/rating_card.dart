import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/rating_model.dart';

class RatingCard extends StatelessWidget {
  final Rating rating;
  final String userName;
  final int idRating;
  final int idRumahMakan;

  const RatingCard({
    super.key,
    required this.rating,
    required this.userName,
    required this.idRating,
    required this.idRumahMakan,
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
          ],
        ),
      ),
    );
  }
}
