import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  /// Controls whether the app shows the light or dark theme
  ThemeMode get currentTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Define your light theme
  ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    // Using a color scheme, app bar theme, and text theme suitable for light mode
    colorScheme: const ColorScheme.light(
      primary: Colors.blue,
      background: Colors.white,
      onBackground: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.black),
      headlineMedium: TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  /// Define your dark theme
  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    // Using a color scheme, app bar theme, and text theme suitable for dark mode
    colorScheme: ColorScheme.dark(
      primary: Colors.blueGrey,
      background: Colors.grey.shade900,
      onBackground: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      foregroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      headlineMedium: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  /// Toggles between light and dark
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners(); // Notifies that the theme changed
  }
}
