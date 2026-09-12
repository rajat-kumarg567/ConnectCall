
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Bold, vibrant palette: violet -> pink primary gradient, cyan accent.
  static const Color primary = Color(0xFF7C3AED); // violet
  static const Color primaryDeep = Color(0xFF6D28D9);
  static const Color pink = Color(0xFFEC4899);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color secondary = cyan;
  static const Color danger = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, pink],
  );

  static const LinearGradient coolGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, cyan],
  );

  /// Deterministic, vibrant gradient per user so avatars/tiles feel lively
  /// and consistent instead of everyone getting the same flat color.
  static const List<List<Color>> avatarGradients = [
    [Color(0xFFF59E0B), Color(0xFFEF4444)], // amber -> red
    [Color(0xFF8B5CF6), Color(0xFFEC4899)], // violet -> pink
    [Color(0xFF06B6D4), Color(0xFF3B82F6)], // cyan -> blue
    [Color(0xFF22C55E), Color(0xFF06B6D4)], // green -> cyan
    [Color(0xFFEC4899), Color(0xFFF59E0B)], // pink -> amber
    [Color(0xFF6366F1), Color(0xFF06B6D4)], // indigo -> cyan
  ];

  static LinearGradient avatarGradientFor(String seed) {
    final idx = seed.isEmpty ? 0 : seed.codeUnitAt(0) % avatarGradients.length;
    final colors = avatarGradients[idx];
    return LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors);
  }

  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: primary,
    scaffoldBackgroundColor: const Color(0xFFF7F5FC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Colors.black87,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primary, width: 1.8),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: primary.withOpacity(0.12),
      labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => TextStyle(
          fontSize: 12,
          fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          color: states.contains(WidgetState.selected) ? primary : Colors.grey.shade500,
        ),
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: primary,
    scaffoldBackgroundColor: const Color(0xFF121317),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
  );
}

