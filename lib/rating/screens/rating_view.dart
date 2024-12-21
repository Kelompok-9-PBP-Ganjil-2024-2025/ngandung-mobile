import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // Ensure intl is added in pubspec.yaml
import '../models/rumahmakan_model.dart';
import '../models/rating_model.dart';
import './rating_form.dart';
import '../widgets/rating_card.dart';

class RatingPage extends StatefulWidget {
  final int id;
  const RatingPage({super.key, required this.id});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

// Helper model to store rating + user name
class RatingWithUser {
  final Rating rating;
  final String userName;

  RatingWithUser({required this.rating, required this.userName});
}

class _RatingPageState extends State<RatingPage> {
  late Future<RumahMakan> _futureRumahMakan;
  late Future<List<RatingWithUser>> _futureRatings;
  bool _isUpdated = false; // Flag to track updates

  @override
  void initState() {
    super.initState();
    _futureRumahMakan = _fetchRumahMakan(widget.id);
    _futureRatings = _fetchRatingsWithUsers(widget.id);
  }

  Future<RumahMakan> _fetchRumahMakan(int id) async {
    final resp =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/toko/$id/'));
    if (resp.statusCode == 200) {
      final List data = jsonDecode(resp.body);
      return RumahMakan.fromJson(data[0]);
    } else {
      throw Exception('Failed to load RumahMakan');
    }
  }

  Future<List<RatingWithUser>> _fetchRatingsWithUsers(int id) async {
    // 1. Fetch all ratings for this Rumah Makan
    final resp =
        await http.get(Uri.parse('http://127.0.0.1:8000/api/rating-toko/$id/'));
    if (resp.statusCode != 200) {
      throw Exception('Failed to load Ratings');
    }
    final ratingsList = ratingFromJson(resp.body);

    // 2. For each rating, fetch user data and keep userName
    final List<RatingWithUser> combined = [];
    for (final rating in ratingsList) {
      final userRes = await http.get(
          Uri.parse('http://127.0.0.1:8000/api/user/${rating.fields.user}/'));
      if (userRes.statusCode == 200) {
        final List userData = jsonDecode(userRes.body);
        final userName = userData[0]["fields"]["username"] ?? "Unknown";
        combined.add(RatingWithUser(rating: rating, userName: userName));
      }
    }
    return combined;
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _isUpdated); // Return the update flag
        return false; // Prevent the default pop
      },
      child: Scaffold(
        body: FutureBuilder(
          future: Future.wait([_futureRumahMakan, _futureRatings]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while fetching data
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              // Display error message if any error occurs
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final results = snapshot.data as List;
            final rumahMakan = results[0] as RumahMakan;
            final ratingsWithUsers = results[1] as List<RatingWithUser>;

            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Container with back button and restaurant title
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.orange[400],
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        width: double.infinity,
                        child: Row(
                          children: [
                            // Back Button
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(
                                    context, _isUpdated); // Return flag
                              },
                            ),
                            const SizedBox(width: 8),
                            // Restaurant Title
                            Expanded(
                              child: Text(
                                rumahMakan.fields.namaRumahMakan,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Restaurant Address
                      Text(
                        rumahMakan.fields.alamat,
                        style: const TextStyle(fontSize: 16),
                      ),
                      // Established Year
                      Text(
                        'Berdiri tahun ${rumahMakan.fields.tahun}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      // Cuisine Origin
                      Text(
                        'Menu makanan asal ${rumahMakan.fields.masakanDariMana == 'semua' ? 'dalam & luar negeri' : rumahMakan.fields.masakanDariMana}',
                        style: const TextStyle(fontSize: 16),
                      ),

                      // A horizontal line to separate sections
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(
                          height: 20,
                          thickness: 1,
                          color: Colors.grey,
                        ),
                      ),

                      // Section for average rating + all ratings
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Average Rating: ${rumahMakan.fields.averageRating}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.star,
                            color: Colors.yellow,
                            size: 22,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Reviewed by ${rumahMakan.fields.numberOfRatings}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.person,
                            color: Colors.grey,
                            size: 14,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                        Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[400],
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          onPressed: () async {
                          bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                            builder: (context) => RatingForm(id: widget.id),
                            ),
                          );
                          if (result == true) {
                            setState(() {
                            _futureRatings =
                              _fetchRatingsWithUsers(widget.id);
                            _futureRumahMakan = _fetchRumahMakan(widget.id);
                            _isUpdated = true;
                            });
                          }
                          },
                          child: const Text(
                          'Create Review',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List of user ratings
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ratingsWithUsers.length,
                        itemBuilder: (context, index) {
                          final row = ratingsWithUsers[index];
                          return RatingCard(
                            rating: row.rating,
                            userName: row.userName,
                            idRating: row.rating.pk,
                            idRumahMakan: widget.id,
                            onUpdate: () {
                              setState(() {
                                _futureRatings =
                                    _fetchRatingsWithUsers(widget.id);
                                _futureRumahMakan = _fetchRumahMakan(widget.id);
                                _isUpdated =
                                    true; // Indicate that an update occurred
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
