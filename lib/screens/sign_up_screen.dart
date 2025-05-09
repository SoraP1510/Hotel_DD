import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}
//ใช้ texteditingcontroller เพื่อดึงค่าต่างๆจาก textfield
class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _fnameController = TextEditingController();
  final TextEditingController _lnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

//ฟั่งชัน signUp
  Future<void> _signUp() async {
    setState(() {
      _isLoading = true;
    });

    const String apiUrl = 'https://hotel-api-six.vercel.app/users'; //API

//ใช้ map เพื่อเก็บค่าต่างๆที่ได้จาก textfield แล้วแปลงเป็น json
    final Map<String, String> userData = {
      "fname": _fnameController.text,
      "lname": _lnameController.text,
      "email": _emailController.text,
      "phone": _phoneController.text,
      "password": _passwordController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(userData),
      );

//ผลลลัพธ์ 
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _showDialog('Sign Up Successful!', Colors.green);
      } else {
        _showDialog('Failed to sign up', Colors.red);
      }
    } catch (e) {
      _showDialog('Error: $e', Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

//ฟังชันแสดงผลลัพธ์เป็นกล่องข้อความที่บอกว่า sign up สำเร็จหรือไม่
  void _showDialog(String message, Color color) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(message, style: TextStyle(color: color)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: const BackButton(), //ปุ่มย้อนกลับ
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),

      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
          ),

//textfield 
          child: Column( 
            mainAxisSize: MainAxisSize.min, 
            children: [
              TextField(controller: _fnameController, decoration: const InputDecoration(labelText: 'First Name')),
              TextField(controller: _lnameController, decoration: const InputDecoration(labelText: 'Last Name')),
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone number')),
              TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
              const SizedBox(height: 20),

//ปุ่ม sign up
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signUp,
                      style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 255, 131, 218)),
                      child: const Text('Sign Up'),
                    ),

                    //ปุ่มย้อนกลับไปที่หน้า sign in
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back to Sign In"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}