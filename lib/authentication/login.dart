import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:booku/payment/purchases.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _passwordVisible = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? _errorMessage;
  String? _appUserId;


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

    Future<void> getUsersDetail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _appUserId = user.uid;
      });
    }
  }

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Login successful, clear any previous error message
      setState(() {
        _errorMessage = null;
      });
      getUsersDetail();
      PurchaseApi.setAppUserId(_appUserId!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged In'),
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
          content: Text('Failed to log in: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 40, right: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
              ElevatedButton(onPressed: login, child: const Text('Login')),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/forgotPassword');
                },
                child: const Text('Forgot password?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/signup');
                },
                child: const Text('Don\'t have an account? Sign up now! '),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
