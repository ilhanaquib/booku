import 'package:booku/pages/books_page.dart';
import 'package:booku/payment/purchases.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:booku/themes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PurchaseApi.init();

  final themeProvider = ThemeProvider();
  await themeProvider.loadPurchasedThemes();
  await themeProvider.loadSelectedThemeId();

  runApp(ChangeNotifierProvider.value(
      value: themeProvider, child: const MyApp()));
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
      theme: Provider.of<ThemeProvider>(context).selectedTheme,
      home: const Books(),
    );
  }
}
