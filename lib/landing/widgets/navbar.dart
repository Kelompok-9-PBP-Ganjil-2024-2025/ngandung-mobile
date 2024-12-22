import 'package:flutter/material.dart';
import 'package:ngandung_mobile/forum/forum_screen.dart';
import 'package:ngandung_mobile/landing/home_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ngandung_mobile/poll/screens/polls_screen.dart';
import 'package:ngandung_mobile/rating/screens/rumahmakan_view.dart';
import 'package:ngandung_mobile/favorite/screens/favorite_list.dart';

class BottomNavBar extends StatefulWidget {
  final int? currentIndex; // Make it nullable
  const BottomNavBar({super.key, this.currentIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late int? _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _selectedIndex = widget.currentIndex;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      switch (index) {
        case 0:
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const HomeScreen(),
              ),
              (route) => false);
          break;
        case 1:
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const TokoPage(),
              ),
              (route) => false);
          break;
        case 2:
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const PollsScreen(),
              ),
              (route) => false);
          break;
        case 3:
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const FavoriteListPage(),
              ),
              (route) => false);
          break;
        case 4:
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const ForumScreen(),
              ),
              (route) => false);
          break;
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
          selectedIndex:
              _selectedIndex ?? -1, // -1 ketika tidak ada tab yang diselect
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
