import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:booku/databases/database_helper.dart';
import 'package:booku/pages/books_page.dart';
import 'package:booku/payment/purchases.dart';
import 'package:booku/themes/theme_provider.dart';
import 'firebase_options.dart';
import 'authentication/login.dart';
import 'package:booku/authentication/forgot_password.dart';
import 'package:booku/authentication/signup.dart';
import 'package:booku/users/account.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PurchaseApi.init();

  await DatabaseHelper.instance.database;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  final themeProvider = ThemeProvider();
  await themeProvider.loadPurchasedThemes();
  await themeProvider.loadSelectedThemeId();

  runApp(
    ChangeNotifierProvider.value(
      value: themeProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/home': (context) =>  Books(),
        '/login': (context) => StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Return a loading indicator or any other UI while waiting for auth state
                  return CircularProgressIndicator();
                }

                final user = snapshot.data;
                final bool isLoggedIn = user != null;

                if (isLoggedIn) {
                  // User is logged in, remove all previous routes and navigate to the new page
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (route) => false);
                  });
                  // Return a placeholder widget while the navigation is in progress
                  return Container();
                } else {
                  // User is not logged in, show the LoginPage
                  return LoginPage();
                }
              },
            ),
        '/signup': (context) => const SignupPage(),
        '/account': (context) => const UserAccount(),
        '/forgotPassword': (context) => const ForgotPassword(),
      },
      theme: Provider.of<ThemeProvider>(context).selectedTheme,
      home:  const Books(),
    );
  }
}
