import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sign_up_screen.dart';
import 'package:test3/session_manager.dart';

class SignInScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSignIn; // ทำให้ไม่ required

  const SignInScreen({super.key, this.onSignIn});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    const String apiUrl = 'https://hotel-api-six.vercel.app/users';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        List<dynamic> users = json.decode(response.body);

        var user = users.firstWhere(
          (u) =>
              u['email'] == _emailController.text &&
              u['password'] == _passwordController.text,
          orElse: () => null,
        );

        if (user != null) {
          // บันทึก session
          SessionManager.currentUser = user;

          // ถ้ามี onSignIn (จากหน้าอื่นเรียก), ก็เรียก callback
          if (widget.onSignIn != null) {
            widget.onSignIn!({
              'userId': user['user_id'],
              'fname': user['fname'],
              'lname': user['lname'],
              'email': user['email'],
              'phone': user['phone'],
            });
          } else {
            // ถ้าไม่มี ให้พาไปหน้า MainScreen โดยตรง
            Navigator.pushReplacementNamed(context, '/');
          }
        } else {
          _showDialog('Invalid Email or Password', Colors.red);
        }
      } else {
        _showDialog('Error connecting to server', Colors.orange);
      }
    } catch (e) {
      _showDialog('An error occurred: $e', Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

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
      appBar: AppBar(title: const Text('Sign In'), backgroundColor: Colors.pinkAccent),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signIn,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                      child: const Text('Sign In'),
                    ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignUpScreen()),
                  );
                },
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
