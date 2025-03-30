import 'package:flutter/material.dart';
import 'package:test3/screens/HomePage.dart';
// import 'package:test3/screens/User_Page.dart';
import 'UserPage.dart';

/// หน้า MainScreen จัดการ BottomNavigationBar สลับหน้า Home/User
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),  // หน้า Home
    UserPage(),  // หน้า User
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // แสดงหน้า HomePage หรือ UserPage ตาม _currentIndex
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Color.fromARGB(255, 255, 131, 218),
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