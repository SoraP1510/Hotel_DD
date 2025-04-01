import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test3/session_manager.dart';

class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({super.key});

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}

class _ChangePhonePageState extends State<ChangePhonePage> {
  final TextEditingController _oldPhoneController = TextEditingController();
  final TextEditingController _newPhoneController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePhone() async {
    final user = SessionManager.currentUser;
    final userId = user?['user_id'];

    if (user == null || userId == null) {
      _showDialog("User not logged in", Colors.red);
      return;
    }

    final oldPhone = _oldPhoneController.text;
    final newPhone = _newPhoneController.text;

    if (newPhone.isEmpty) {
      _showDialog("New phone number cannot be empty", Colors.orange);
      return;
    }

    if (oldPhone != user['phone']) {
      _showDialog("Old phone number is incorrect", Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.put(
        Uri.parse('https://hotel-api-six.vercel.app/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "user_id": userId,
          "fname": user['fname'],
          "lname": user['lname'],
          "email": user['email'],
          "phone": newPhone,
          "password": user['password'],
        }),
      );

      if (response.statusCode == 200) {
        // อัปเดต phone ใหม่ใน session
        SessionManager.currentUser?['phone'] = newPhone;
        _showDialog("Phone number updated successfully", Colors.green);
      } else {
        _showDialog("Failed to update phone number", Colors.red);
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
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: const Text("Change Phone number"), leading: const BackButton()),
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
              controller: _oldPhoneController,
                decoration: const InputDecoration(labelText: 'Old Phone number'),
              ),
              TextField(
                  controller: _newPhoneController,
                decoration: const InputDecoration(labelText: 'New Phone number'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updatePhone,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
                      child: const Text('Confirm'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
