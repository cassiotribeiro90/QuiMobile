import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Cores
  static const Color primaryColor = Color(0xFFEA1D2C);
  static const Color accentColor = Color(0xFFF0C421);
  static const Color darkColor = Color(0xFF333333);
  static const Color lightGreyColor = Color(0xFFF5F5F5);
  static const Color greyColor = Color(0xFF888888);

  // ThemeData
  static ThemeData get themeData {
    final baseTheme = ThemeData.light(useMaterial3: true);

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.normal,
          fontSize: 20,
          color: darkColor,
          fontFamily: 'Roboto',
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: greyColor,
        showUnselectedLabels: true,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryColor,
      ),
      // Definindo a fonte padrão e os estilos de texto customizados
      textTheme: baseTheme.textTheme.apply(fontFamily: 'Roboto').copyWith(
        titleMedium: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1))],
        ),
        bodySmall: const TextStyle(
          color: Colors.white,
          shadows: [Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1))],
        ),
        labelLarge: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1))],
        ),
        bodyLarge: baseTheme.textTheme.bodyLarge?.copyWith(
          color: greyColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
