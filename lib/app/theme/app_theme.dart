import 'package:flutter/material.dart';

class AppTheme {
  // Evita que a classe seja instanciada
  AppTheme._();

  // ===========================================================================
  // Cores
  // ===========================================================================
  static const Color primaryColor = Color(0xFFEA1D2C); // Vermelho iFood
  static const Color accentColor = Color(0xFFF0C421);  // Amarelo para estrelas/destaques
  static const Color darkColor = Color(0xFF333333);    // Cinza escuro para textos principais
  static const Color lightGreyColor = Color(0xFFF5F5F5); // Cinza claro para fundos
  static const Color greyColor = Color(0xFF888888);      // Cinza para textos secundários

  // ===========================================================================
  // Estilos de Texto
  // ===========================================================================
  static const TextStyle appBarTitle = TextStyle(
    color: darkColor,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1))],
  );

  static const TextStyle cardSubtitle = TextStyle(
    color: Colors.white,
    shadows: [Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1))],
  );

  static const TextStyle ratingStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.white,
    shadows: [Shadow(blurRadius: 2, color: Colors.black54, offset: Offset(1, 1))],
  );

  static const TextStyle errorTextStyle = TextStyle(
    color: greyColor,
    fontSize: 16,
  );

  // ===========================================================================
  // ThemeData
  // ===========================================================================
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: appBarTitle,
        iconTheme: IconThemeData(color: primaryColor), // Cor dos ícones (ex: botão de voltar)
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
    );
  }
}
