import 'package:booku/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:booku/payment/paywall.dart';
import 'package:booku/payment/purchases.dart';

class ThemeSelectionScreen extends StatefulWidget {
  @override
  _ThemeSelectionScreenState createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
  
  void fetchOffers(BuildContext context) async {
    final offerings = await PurchaseApi.fetchOffers();
    if (offerings.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Paywall(offer: offerings.first),
      );
    }
  }

  final List<ThemeData> themes = [
    redTheme,
    purpleTheme,
    tealTheme,
    orangeTheme,
    greenTheme
  ];

  int selectedIndex = 0;

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
          final isRedTheme = theme == redTheme;

          return ListTile(
            title: Text(themeName ?? ''),
            onTap: () {
              setState(() {
                selectedIndex = index;
              });

              if (isRedTheme) {
                themeProvider.setTheme(theme);
              } else {
                fetchOffers(context);
              }
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
