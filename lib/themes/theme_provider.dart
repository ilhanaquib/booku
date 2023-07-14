import 'package:booku/databases/database_helper.dart';
import 'package:flutter/material.dart';
import 'themes.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme = redTheme;
  List<ThemeData> _purchasedThemes = [redTheme]; // Start with red theme as default

  ThemeData get selectedTheme => _selectedTheme;
  List<ThemeData> get purchasedThemes => _purchasedThemes;

  void setTheme(ThemeData theme) {
    _selectedTheme = theme;
    notifyListeners();
  }

  bool isThemePurchased(ThemeData theme) {
    return _purchasedThemes.contains(theme);
  }

  void addPurchasedTheme(ThemeData theme) {
    if (!isThemePurchased(theme)) {
      _purchasedThemes.add(theme);
      _savePurchasedThemes(); // Save purchased themes to the database
      notifyListeners();
    }
  }

  Future<void> loadPurchasedThemes() async {
    _purchasedThemes = await DatabaseHelper.instance.getPurchasedThemes();
    if (_purchasedThemes.isEmpty) {
      _purchasedThemes = [redTheme]; // Start with red theme if no purchased themes found
    }
  }

  Future<void> _savePurchasedThemes() async {
    await DatabaseHelper.instance.savePurchasedThemes(_purchasedThemes);
  }
}
