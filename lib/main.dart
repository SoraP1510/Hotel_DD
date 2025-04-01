import 'package:flutter/material.dart';
import 'package:test3/screens/main_screen.dart';
import 'package:test3/screens/sign_in_screen.dart'; // <-- เพิ่มไฟล์ login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel DD App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // ตั้ง route แรกเริ่มต้น
      routes: {
        '/': (context) => const MainScreen(),
        '/login': (context) => const SignInScreen(), 
      },
    );
  }
}
