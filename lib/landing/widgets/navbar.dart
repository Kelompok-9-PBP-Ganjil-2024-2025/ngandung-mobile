
// lib/widget/navbar.dart
import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({super.key, required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF111111),
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      selectedItemColor: const Color(0xFFFEC123),
      unselectedItemColor: const Color(0xFFACB0B8),
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
    );
  }
}
