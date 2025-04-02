import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'sign_up_screen.dart';
import 'package:test3/session_manager.dart';

class SignInScreen extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSignIn;

  const SignInScreen({super.key, this.onSignIn});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() => _isLoading = true);

    const String apiUrl = 'https://hotel-api-six.vercel.app/users/login';
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        print("Login response: ${response.body}");
        final user = json.decode(response.body);

        // บันทึก session
        SessionManager.currentUser = user;

        // ถ้ามี onSignIn (จาก MainScreen)
        if (widget.onSignIn != null) {
          widget.onSignIn!({
            'userId': user['user_id'],
            'fname': user['fname'],
            'lname': user['lname'],
            'email': user['email'],
            'phone': user['phone'],
          });
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        _showDialog('Invalid Email or Password', Colors.red);
      }
    } catch (e) {
      _showDialog('An error occurred: $e', Colors.red);
    }

    setState(() => _isLoading = false);
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
                      style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 255, 131, 218)),
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
