import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Cpass.dart';
import 'Cphone.dart';
import 'package:test3/session_manager.dart';
import 'main_screen.dart'; // เพิ่ม import เพื่อกลับ MainScreen

class UserPage extends StatelessWidget {
  final int userId;
  final String fname;
  final String lname;
  final String email;
  final String phone;

  const UserPage({
    super.key,
    required this.userId,
    required this.fname,
    required this.lname,
    required this.email,
    required this.phone,
  });

  Future<void> deleteAccount(BuildContext context) async {
    final url = Uri.parse('https://hotel-api-six.vercel.app/users/$userId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        // แสดง SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully.")),
        );

        await Future.delayed(const Duration(seconds: 1));

        // ล้าง session แล้วกลับหน้า MainScreen
        SessionManager.currentUser = null;

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      } else {
        throw Exception('Failed to delete account: ${response.body}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  void confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx); // ปิด dialog
              deleteAccount(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete"),
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
        title: const Text("User"),
        automaticallyImplyLeading: false,
        ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
          margin: const EdgeInsets.all(30),
          width: 350,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(color: Colors.pink.shade100, blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("First Name: $fname", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text("Last Name: $lname", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text("E-mail: $email", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text("Phone number: $phone",
                  style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChangePasswordPage()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFCCAFF),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text("Change Password"),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ChangePhonePage()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFCCAFF),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text("Change Phone number"),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () => confirmDelete(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1417),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text("Delete Account"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
