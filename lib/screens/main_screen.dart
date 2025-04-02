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

  /// เก็บข้อมูล user ที่ล็อกอิน
  Map<String, dynamic>? _userData;

  /// ฟังก์ชันจะถูกส่งให้ SignInScreen เรียกเมื่อ SignIn สำเร็จ
  void _updateUserData(Map<String, dynamic> userData) {
    setState(() {
      _userData = userData;
      _currentIndex = 1; // ไปหน้า UserPage
    });
  }

  List<Widget> _buildPages() {
    return [
      const HomePage(),
      // ถ้ายังไม่ Sign In => ไปหน้า SignInScreen
      // ถ้า Sign In แล้ว => ไปหน้า UserPage (ไม่ต้องส่งค่าอะไรอีก)
      _userData == null
          ? SignInScreen(onSignIn: _updateUserData)
          : const UserPage(),
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
