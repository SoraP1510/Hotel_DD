import 'package:flutter/material.dart';
import 'package:test3/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

/// แอปหลัก ที่กำหนดธีม และเรียก MainScreen เป็นหน้าแรก
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel DD App test',
      theme: ThemeData(
        primarySwatch: Colors.blue, // ธีมสีน้ำเงิน
      ),
      home: const MainScreen(),     // เรียกหน้า MainScreen
    );
  }
}