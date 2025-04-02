import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test3/session_manager.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    final user = SessionManager.currentUser;
    final userId = user?['user_id'];

    if (userId == null) {
      _showDialog("User not logged in", Colors.red);
      return;
    }

    final oldPassword = _oldPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (newPassword.isEmpty) {
      _showDialog("New password cannot be empty", Colors.orange);
      return;
    }

    if (oldPassword != user?['password']) {
      _showDialog("Old password is incorrect", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('https://hotel-api-six.vercel.app/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
          "fname": user!['fname'],
          "lname": user['lname'],
          "email": user['email'],
          "phone": user['phone'],
          "password": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        // อัปเดต password ใหม่เข้า SessionManager
        SessionManager.currentUser?['password'] = newPassword;
        _showDialog("Password updated successfully", Colors.green);
      } else {
        _showDialog("Failed to update password", Colors.red);
      }
    } catch (e) {
      _showDialog("Error: $e", Colors.red);
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
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Change Password"),
          backgroundColor: Colors.pinkAccent),
      backgroundColor: Colors.grey[300],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.pink.shade100, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Old Password"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password"),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updatePassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                      ),
                      child: const Text("Save"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
