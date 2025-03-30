import 'package:flutter/material.dart';
import 'sign_in_screen.dart';
import 'sign_up_screen.dart';

class UserPage2 extends StatelessWidget {
  const UserPage2({super.key});

  void _goToSignIn(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  }

  void _goToSignUp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SignUpScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => _goToSignIn(context),
                child: const Text('Sign In'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _goToSignUp(context),
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}