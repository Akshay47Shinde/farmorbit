import 'package:flutter/material.dart';
import 'news_feed_screen.dart'; // Import NewsFeedScreen
import 'profile_screen.dart'; // Import ProfileScreen
import 'create_post_screen.dart'; // Import CreatePostScreen

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Track the selected index

  // List of screens for bottom navigation
  final List<Widget> _screens = [
    NewsFeedScreen(), // News Feed Screen
    ProfileScreen(), // Profile Screen
  ];

  // Function to handle bottom navigation item taps
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FarmOrbit'),
      ),
      body: _screens[_selectedIndex], // Display the selected screen
      floatingActionButton:
          _selectedIndex == 0 // Show button only on NewsFeedScreen
              ? FloatingActionButton(
                  onPressed: () {
                    // Navigate to Create Post screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostScreen(),
                      ),
                    );
                  },
                  child: Icon(Icons.add),
                  tooltip: 'Create a Post',
                )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Current selected index
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: _onItemTapped, // Update the index when a tab is tapped
      ),
    );
  }
}
