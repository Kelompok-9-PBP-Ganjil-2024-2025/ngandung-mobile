// lib/widget/navbar.dart

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ngandung_mobile/favorite/screens/favorite_list.dart'; // Import FavoriteListPage
import 'package:ngandung_mobile/authentication/screens/home_placeholder.dart'; // Import HomePage

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Navigasi berdasarkan index
      if (index == 0) {
        // Jika tombol Home dipilih
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else if (index == 3) {
        // Jika tombol Favourite dipilih
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FavoriteListPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10),
        child: GNav(
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
          backgroundColor: Colors.black,
          color: Colors.white,
          activeColor: Colors.white,
          tabBackgroundColor: Colors.orange.shade300,
          gap: 8,
          padding: const EdgeInsets.all(15),
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.rate_review_rounded,
              text: 'Rating',
            ),
            GButton(
              icon: Icons.poll_rounded,
              text: 'Poll',
            ),
            GButton(
              icon: Icons.favorite_outlined,
              text: 'Favourite',
            ),
            GButton(
              icon: Icons.forum_rounded,
              text: 'Forum',
            ),
          ],
        ),
      ),
    );
  }
}
