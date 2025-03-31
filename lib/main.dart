import 'package:flutter/material.dart';
import 'package:test3/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel DD App',
      theme: ThemeData(
        primarySwatch: Colors.blue
      ),
      home: const MainScreen(),
    );
  }
}