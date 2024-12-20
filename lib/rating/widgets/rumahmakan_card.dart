// /lib/rating/widgets/rumahmakan_card.dart
import 'package:flutter/material.dart';
import '../models/rumahmakan.dart';

class RumahMakanCard extends StatelessWidget {
  final RumahMakan rumahMakan;

  const RumahMakanCard({
    super.key,
    required this.rumahMakan,
  });

  @override
  Widget build(BuildContext context) {
    // We only use certain fields for display, but you can customize as needed
    final fields = rumahMakan.fields;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              fields.namaRumahMakan,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              fields.alamat,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Rating: ${fields.averageRating}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Total Ratings: ${fields.numberOfRatings}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
