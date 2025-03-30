import 'package:flutter/material.dart';
import 'Cpass.dart';
import 'Cphone.dart';

class UserPage extends StatelessWidget {
  final String fname;
  final String lname;
  final String email;
  final String phone;

  const UserPage({
    super.key,
    required this.fname,
    required this.lname,
    required this.email,
    required this.phone,
  });

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
                      child: const Text("Change Password"),
                    ),
                    const SizedBox(height: 15),
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
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                      ),
                      child: const Text("Change Phone number"),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF1417),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
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