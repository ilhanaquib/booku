import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var kColorScheme1 =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 247, 78, 66));
var kColorScheme2 =
    ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 223, 117, 247));
var kColorScheme3 = ColorScheme.fromSeed(seedColor:const Color.fromARGB(255, 143, 223, 255));
var kColorScheme4 = ColorScheme.fromSeed(seedColor:const Color.fromARGB(255, 252, 177, 112));
var kColorScheme5 =ColorScheme.fromSeed(seedColor:const Color.fromARGB(255, 112, 248, 153));

final redTheme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: kColorScheme1,
  appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kColorScheme1.onPrimaryContainer,
      foregroundColor: kColorScheme1.primaryContainer),
  cardTheme:
      const CardTheme().copyWith(color: kColorScheme1.secondaryContainer),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: kColorScheme1.primaryContainer),
  ),
  drawerTheme: const DrawerThemeData()
      .copyWith(backgroundColor: kColorScheme1.background),
  textTheme: GoogleFonts.poppinsTextTheme(),
);

final purpleTheme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: kColorScheme2,
  appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kColorScheme2.onPrimaryContainer,
      foregroundColor: kColorScheme2.primaryContainer),
  cardTheme:
      const CardTheme().copyWith(color: kColorScheme2.secondaryContainer),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: kColorScheme2.primaryContainer),
  ),
  drawerTheme: const DrawerThemeData()
      .copyWith(backgroundColor: kColorScheme2.background),
  textTheme: GoogleFonts.poppinsTextTheme(),
);

final tealTheme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: kColorScheme3,
  appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kColorScheme3.onPrimaryContainer,
      foregroundColor: kColorScheme3.primaryContainer),
  cardTheme:
      const CardTheme().copyWith(color: kColorScheme3.secondaryContainer),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: kColorScheme3.primaryContainer),
  ),
  drawerTheme: const DrawerThemeData()
      .copyWith(backgroundColor: kColorScheme3.background),
  textTheme: GoogleFonts.poppinsTextTheme(),
);

final orangeTheme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: kColorScheme4,
  appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kColorScheme4.onPrimaryContainer,
      foregroundColor: kColorScheme4.primaryContainer),
  cardTheme:
      const CardTheme().copyWith(color: kColorScheme4.secondaryContainer),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: kColorScheme4.primaryContainer),
  ),
  drawerTheme: const DrawerThemeData()
      .copyWith(backgroundColor: kColorScheme4.background),
  textTheme: GoogleFonts.poppinsTextTheme(),
);

final greenTheme = ThemeData().copyWith(
  useMaterial3: true,
  colorScheme: kColorScheme5,
  appBarTheme: const AppBarTheme().copyWith(
      backgroundColor: kColorScheme5.onPrimaryContainer,
      foregroundColor: kColorScheme5.primaryContainer),
  cardTheme:
      const CardTheme().copyWith(color: kColorScheme5.secondaryContainer),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
        backgroundColor: kColorScheme5.primaryContainer),
  ),
  drawerTheme: const DrawerThemeData()
      .copyWith(backgroundColor: kColorScheme5.background),
  textTheme: GoogleFonts.poppinsTextTheme(),
);

final List<ThemeData> allThemes = [
  redTheme,
  purpleTheme,
  tealTheme,
  orangeTheme,
  greenTheme,
];
