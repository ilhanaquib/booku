import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailController = TextEditingController();

  Future<void> resetPassword() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: emailController.text.trim());
      // Show a success message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Password reset email sent to ${emailController.text.trim()}'),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.pushNamed(context, '/login');
    } catch (e) {
      // Show an error message if something went wrong
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send password reset email: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                  'Enter your email and we will send a password reset link to you!'),
              const SizedBox(
                height: 30,
              ),
              TextField(
                decoration: const InputDecoration(
                  hintText: AutofillHints.email, // Show the error message here
                ),
                controller: emailController,
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                  onPressed: resetPassword,
                  child: const Text('Reset Password')),
            ],
          ),
        ),
      ),
    );
  }
}
