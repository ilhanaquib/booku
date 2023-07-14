import 'package:booku/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:booku/payment/paywall.dart';
import 'package:booku/payment/purchases.dart';

class ThemeSelectionScreen extends StatefulWidget {
  const ThemeSelectionScreen({super.key});

  @override
  _ThemeSelectionScreenState createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  // this fucntion fetch all the offers from revenueCat
  Future fetchOffers(BuildContext context) async {
    final offerings = await PurchaseApi.fetchOffers();
    if (offerings.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) =>
            Paywall(offer: offerings.first, selectedIndex: selectedIndex),
      ).then((value) {
        if (value != null) {
          final themeProvider =
              Provider.of<ThemeProvider>(context, listen: false);
          final selectedTheme = themes[selectedIndex];
          if (themeProvider.isThemePurchased(selectedTheme)) {
            themeProvider.setTheme(selectedTheme);
          }
        }
      });
    }
  }

  // this list stores all the themes
  final List<ThemeData> themes = [
    redTheme,
    purpleTheme,
    tealTheme,
    orangeTheme,
    greenTheme
  ];

  int selectedIndex = 0;

  // this maps the themes to a name
  final Map<ThemeData, String> themeNames = {
    redTheme: 'Red Theme',
    purpleTheme: 'Purple Theme',
    tealTheme: 'Teal Theme',
    orangeTheme: 'Orange Theme',
    greenTheme: 'Green Theme'
  };

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Theme'),
      ),
      body: ListView.builder(
        itemCount: themes.length,
        itemBuilder: (context, index) {
          final theme = themes[index];
          final themeName = themeNames[theme];
          final isPurchasedTheme = themeProvider.isThemePurchased(theme);

          return ListTile(
            title: Text(themeName ?? ''),
            onTap: () async {
              setState(() {
                selectedIndex = index;
              });

              if (isPurchasedTheme) {
                themeProvider.setTheme(theme);
              } else {
                await fetchOffers(context);
                return; // Return without closing the ThemeSelectionScreen
              }

              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
