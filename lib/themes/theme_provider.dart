import 'package:flutter/material.dart';
import 'themes.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme = redTheme;

  ThemeData get selectedTheme => _selectedTheme;

  void setTheme(ThemeData theme) {
    _selectedTheme = theme;
    notifyListeners();
  }
}