import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'UserPage.dart';
import 'sign_in_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  Map<String, dynamic>? _userData;

  void _updateUserData(Map<String, dynamic> userData) {
    setState(() {
      _userData = userData;
      _currentIndex = 1;
    });
  }

  List<Widget> _buildPages() {
    return [
      const HomePage(),
      _userData == null
          ? SignInScreen(onSignIn: _updateUserData)
          : UserPage(
              fname: _userData!['fname'],
              lname: _userData!['lname'],
              email: _userData!['email'],
              phone: _userData!['phone'],
            ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPages()[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 255, 131, 218),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}