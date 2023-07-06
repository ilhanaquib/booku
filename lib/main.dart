import 'package:booku/pages/books_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      theme: ThemeData().copyWith(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: const Color.fromARGB(214, 106, 247, 247)),
        textTheme: GoogleFonts.poppinsTextTheme()
      ),
      home: const Books(),
    ),
  );
}
