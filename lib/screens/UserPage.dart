import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:test3/session_manager.dart';
import 'main_screen.dart';
import 'Cpass.dart';
import 'Cphone.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Map<String, dynamic>? user;

  @override
  void initState() {
    super.initState();
    user = SessionManager.currentUser;
  }

  Future<void> deleteAccount(BuildContext context) async {
    final url = Uri.parse('https://hotel-api-six.vercel.app/users/${user?['user_id']}');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account deleted successfully.")),
        );

        await Future.delayed(const Duration(seconds: 1));
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
              Navigator.pop(ctx);
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
    final fname = user?['fname'] ?? '';
    final lname = user?['lname'] ?? '';
    final email = user?['email'] ?? '';
    final phone = user?['phone'] ?? '';

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
              Text("Phone number: $phone", style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                        );
                        setState(() {
                          user = SessionManager.currentUser; // อัปเดตหลังกลับ
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 131, 218),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: const Text("Change Password"),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePhonePage()),
                        );
                        setState(() {
                          user = SessionManager.currentUser; // อัปเดตหลังเปลี่ยนเบอร์
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 255, 131, 218),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                      child: const Text("Change Phone number"),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () => confirmDelete(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1417),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
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
