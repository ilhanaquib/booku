import 'package:booku/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class ThemeSelectionScreen extends StatefulWidget {
  @override
  _ThemeSelectionScreenState createState() => _ThemeSelectionScreenState();
}

class _ThemeSelectionScreenState extends State<ThemeSelectionScreen> {
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

          return ListTile(
            title: Text(themeName ?? ''),
            onTap: () {
              setState(() {
                selectedIndex = index;
              });

              themeProvider.setTheme(theme);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
