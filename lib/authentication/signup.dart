import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _passwordVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void initState() {
    _passwordVisible = false;
    _errorMessage = null;
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Login successful, clear any previous error message
      setState(() {
        _errorMessage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Go add more books!'),
          duration: Duration(seconds: 3),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Handle login errors and show error message under the TextField
      setState(() {
        _errorMessage = e.message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create account: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                  'Create an account now and be apart of our community. Creating an account will give you access to more features!'),
              const SizedBox(
                height: 20,
              ),
              TextField(
                decoration: InputDecoration(
                  hintText: AutofillHints.email,
                  errorText: _errorMessage, // Show the error message here
                ),
                controller: emailController,
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  hintText: AutofillHints.password,
                  errorText: _errorMessage, // Show the error message here
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                controller: passwordController,
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: signup, child: const Text('Sign Up')),
            ],
          ),
        ),
      ),
    );
  }
}
