import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:booku/databases/database_helper.dart';

class UserAccount extends StatefulWidget {
  const UserAccount({super.key});

  @override
  State<UserAccount> createState() => _UserAccountState();
}

class _UserAccountState extends State<UserAccount> {
  String? userId;
  String? email;

  @override
  void initState() {
    super.initState();
    getUsersDetail();
  }

  Future<void> getUsersDetail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userId = user.uid;
        email = user.email;
      });
    }
  }

  Future<void> userSignOut() async {
    DatabaseHelper db = DatabaseHelper.instance;
    String tablename = 'books';
    FirebaseAuth.instance.signOut();
    db.deleteAllDataFromTable(tablename);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          Text('User id (UID) : $userId'),
          Text('Email : $email'),
          ElevatedButton(
            onPressed: userSignOut,
            child: const Text('Log Out'),
          )
        ],
      ),
    );
  }
}
