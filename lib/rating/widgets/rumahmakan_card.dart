import 'package:flutter/material.dart';
import '../models/rumahmakan_model.dart';
import '../screens/rating_view.dart';

class RumahMakanCard extends StatelessWidget {
  final RumahMakan rumahMakan;
  final VoidCallback? onUpdate; // Add onUpdate callback

  const RumahMakanCard({
    super.key,
    required this.rumahMakan,
    this.onUpdate, // Initialize callback
  });

  @override
  Widget build(BuildContext context) {
    final fields = rumahMakan.fields;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Match the border radius
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0), // Apply the same radius here
        onTap: () async {
          bool? result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RatingPage(id: rumahMakan.pk),
            ),
          );
          if (result == true && onUpdate != null) {
            onUpdate!(); // Invoke the callback to refresh TokoPage data
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment:
                CrossAxisAlignment.center, // Center horizontally
            children: [
              Text(
                fields.namaRumahMakan,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                fields.alamat,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Rating: ${fields.averageRating}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star,
                    color: Colors.yellow,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Reviewed by ${fields.numberOfRatings}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
