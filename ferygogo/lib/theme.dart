import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.blue,
  fontFamily: 'Poppins',
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0F52BA),
    primary: const Color(0xFF0F52BA),
    onPrimary: Colors.white,
    secondary: const Color(0xFF3B7DE9),
    onSecondary: Colors.white,
    surface: Colors.white,
    onSurface: Colors.black87,
    background: Colors.grey[50]!,
    onBackground: Colors.black87,
  ),
  cardTheme: const CardTheme(
    color: Colors.white,
    shadowColor: Colors.black12,
    elevation: 2,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[50],
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF0F52BA)),
    ),
    labelStyle: TextStyle(color: Colors.grey[700]),
    hintStyle: TextStyle(color: Colors.grey[500]),
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.grey[900]),
    bodyMedium: TextStyle(color: Colors.grey[800]),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F52BA),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
);

final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.blue,
  fontFamily: 'Poppins',
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0F52BA),
    brightness: Brightness.dark,
    primary: const Color(0xFF0F52BA),
    onPrimary: Colors.white,
    secondary: const Color(0xFF3B7DE9),
    onSecondary: Colors.white,
    surface: const Color(0xFF1E1E1E),
    onSurface: Colors.white,
    background: const Color(0xFF121212),
    onBackground: Colors.white,
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF1E1E1E),
    shadowColor: Colors.black45,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white10,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white24),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.white24),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF0F52BA)),
    ),
    labelStyle: const TextStyle(color: Colors.white70),
    hintStyle: const TextStyle(color: Colors.white60),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F52BA),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    selectedItemColor: Color(0xFF0F52BA),
    unselectedItemColor: Colors.white54,
  ),
);
