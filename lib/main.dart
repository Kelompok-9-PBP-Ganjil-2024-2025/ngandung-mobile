import 'package:flutter/material.dart';
import 'landing/home_screen.dart';    // HomeScreen from landing/screens
import 'rating/rating_screen.dart';            // Rating screen from rating/screens
import 'poll/poll_screen.dart';                // Poll screen from poll/screens
import 'favorite/store_screen.dart';          // Store (Toko Fav) from favorite/screens
import 'forum/forum_screen.dart';             // Forum screen from forum/screens

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),    
    const RatingScreen(),  
    const PollScreen(),    
    const StoreScreen(),
    const ForumScreen(),   
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bottom Navbar Ngandung'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
  backgroundColor: const Color(0xFF111111), // Set background color to #111111
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
  selectedItemColor: const Color(0xFFFEC123),
  unselectedItemColor: const Color(0xFFEBEBEB), 
  items: const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.star),
      label: 'Rating',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.poll),
      label: 'Polling',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.thumb_up),
      label: 'Favorite',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.message),
      label: 'Comment',
    ),
  ],
),

    );
  }
}
