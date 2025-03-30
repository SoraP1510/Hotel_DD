import 'package:flutter/material.dart';
import 'package:test3/screens/Cpass.dart';
import 'package:test3/screens/Cphone.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(title: const Text("User"), leading: const BackButton()),
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
              const Text("First Name:  ___________________________"),
              const SizedBox(height: 12),
              const Text("Last Name:   ____________________________"),
              const SizedBox(height: 12),
              const Text("E-mail:      _________________________________"),
              const SizedBox(height: 12),
              const Text("Phone number: _______________________"),
              const SizedBox(height: 30),

              // ปุ่ม Change Password
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePasswordPage()),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFCCAFF),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text(
                          "Change Password"), // ถ้าจะให้สื่อถึง ChangePhonePage ควรเปลี่ยนข้อความด้วย
                    ),

                    const SizedBox(height: 15),

                    // ปุ่ม Change Phone
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePhonePage()),
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

                    // ปุ่ม Delete
                    ElevatedButton(
                      onPressed: () {},
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
