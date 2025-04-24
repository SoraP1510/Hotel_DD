import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:test3/session_manager.dart';

class ChangePhonePage extends StatefulWidget {
  const ChangePhonePage({super.key});

  @override
  State<ChangePhonePage> createState() => _ChangePhonePageState();
}
// ใช้ texteditingcontroller เพื่อดึงค่าต่างๆจาก textfield *รับค่า oldphone และ newphone*
class _ChangePhonePageState extends State<ChangePhonePage> {
  final TextEditingController _oldPhoneController = TextEditingController();
  final TextEditingController _newPhoneController = TextEditingController();
  bool _isLoading = false;

// ฟังชันอัปเดตหมายเลขโทรศัพท์
  Future<void> _updatePhone() async {
    final user = SessionManager.currentUser; // ดึงข้อมูลผู้ใช้จาก session
    final userId = user?['user_id']; 

    if (user == null || userId == null) { 
      _showDialog("User not logged in", Colors.red);
      return;
    }

    final oldPhone = _oldPhoneController.text;
    final newPhone = _newPhoneController.text;

    if (newPhone.isEmpty) { // ตรวจสอบว่าหมายเลขโทรศัพท์ใหม่มีค่าหรือไม่
      _showDialog("New phone number cannot be empty", Colors.orange);
      return;
    }

    if (oldPhone != user['phone']) {  // ตรวจสอบหมายเลขโทรศัพท์เก่าใน session 
      _showDialog("Old phone number is incorrect", Colors.red); // ถ้าหมายเลขโทรศัพท์เก่าไม่ถูกต้องก็ error จ้า
      return;
    }
 setState(() => _isLoading = true);

//ส่งข้อมูลไปยัง API เพื่ออัปเดตหมายเลขโทรศัพท์
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

 // อัปเดตใหม่ใน session
      if (response.statusCode == 200) {
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

//กล่องข้อความที่แสดงผลลัพธ์
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

//สร้าง UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
          title: const Text("Change Phone number"),
          leading: const BackButton()),
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
                decoration:
                    const InputDecoration(labelText: 'Old Phone number'),
              ),
              TextField(
                controller: _newPhoneController,
                decoration:
                    const InputDecoration(labelText: 'New Phone number'),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updatePhone,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 255, 131, 218)),
                      child: const Text('Confirm'), //ปุ่ม save
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
