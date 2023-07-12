import 'package:flutter/material.dart';
import 'themes.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _selectedTheme = redTheme;
  List<ThemeData> _purchasedThemes = [
    redTheme
  ]; // Start with red theme as default

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
      notifyListeners();
    }
  }
}
