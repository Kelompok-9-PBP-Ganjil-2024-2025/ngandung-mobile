import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/rumahmakan_model.dart';
import '../widgets/rumahmakan_card.dart';

class TokoPage extends StatefulWidget {
  const TokoPage({super.key});

  @override
  State<TokoPage> createState() => _TokoPageState();
}

class _TokoPageState extends State<TokoPage> {
  late Future<List<RumahMakan>> _futureRumahMakan;

  @override
  void initState() {
    super.initState();
    // Fetch data when the widget is initialized
    _futureRumahMakan = fetchRumahMakanData();
  }

  // Function to fetch data from the API
  Future<List<RumahMakan>> fetchRumahMakanData() async {
    final url = Uri.parse('http://127.0.0.1:8000/api/toko/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Parse the JSON response into a list of RumahMakan objects
      return rumahMakanFromJson(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Rating Toko',
      // Define an orange theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.orange,
        ).copyWith(secondary: Colors.orange[400]),
      ),
      home: Scaffold(
        // Removed the AppBar as per your request
        body: FutureBuilder<List<RumahMakan>>(
          future: _futureRumahMakan,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // Show a loading indicator while waiting for data
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              // Display an error message if data fetching fails
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              // Display a message if no data is found
              return const Center(child: Text('No data found'));
            } else {
              final rumahMakanList = snapshot.data!;
              // Make the entire content scrollable
              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Title Text at the top
                    Container(
                      width: double.infinity,
                      color: Colors.orange[400],
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 8),
                      child: const Text(
                        'Rating Rumah Makan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    // Subtitle Text under the title
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Text(
                        'Ayo kasih ratingmu kepada rumah makan yang sudah kamu kunjungi, biar pengunjung lain bisa tau gambarannya! :D',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16, // Regular text size
                        ),
                      ),
                    ),
                    // Grid of RumahMakan cards
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.builder(
                        // Disable GridView's own scrolling
                        physics: const NeverScrollableScrollPhysics(),
                        // Let GridView take up only the necessary space
                        shrinkWrap: true,
                        itemCount: rumahMakanList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns in the grid
                          mainAxisSpacing: 8, // Spacing between rows
                          crossAxisSpacing: 8, // Spacing between columns
                        ),
                        itemBuilder: (context, index) {
                          // Build each RumahMakanCard
                          return RumahMakanCard(
                            rumahMakan: rumahMakanList[index],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
