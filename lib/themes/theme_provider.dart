import 'package:flutter/material.dart';

import 'themes.dart';
import 'package:booku/databases/database_helper.dart';

class ThemeProvider extends ChangeNotifier {
  int _selectedThemeId = 0;
  List<ThemeData> _purchasedThemes = [
    redTheme
  ]; // Start with red theme as default

  ThemeData get selectedTheme => allThemes[_selectedThemeId];

  List<ThemeData> get purchasedThemes => _purchasedThemes;

  void setTheme(ThemeData theme) {
    _selectedThemeId = allThemes.indexOf(theme);
    _saveSelectedThemeId();
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
      _purchasedThemes = [
        redTheme
      ]; // Start with red theme if no purchased themes found
    }
  }

  Future<void> loadSelectedThemeId() async {
    _selectedThemeId = await DatabaseHelper.instance.getSelectedThemeId();
  }

  Future<void> _savePurchasedThemes() async {
    await DatabaseHelper.instance.savePurchasedThemes(_purchasedThemes);
  }

  Future<void> _saveSelectedThemeId() async {
    await DatabaseHelper.instance.saveSelectedThemeId(_selectedThemeId);
  }
}
