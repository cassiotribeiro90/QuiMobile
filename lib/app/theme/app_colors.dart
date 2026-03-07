import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ========== CORES PRINCIPAIS ==========
  static const Color primary = Color(0xFF3949AB);
  static const Color secondary = Color(0xFF26A69A);
  static const Color accent = Color(0xFFFF7043);
  
  // ========== CORES DE TEXTO ==========
  static const Color textPrimary = Color(0xFF212121);   // Texto principal
  static const Color textSecondary = Color(0xFF757575); // Texto secundário
  static const Color textLight = Color(0xFF9E9E9E);     // Texto claro
  static const Color textHint = Color(0xFFBDBDBD);      // Hint text
  static const Color textWhite = Colors.white;           // Texto branco
  static const Color textDark = Color(0xFF212121);       // Texto escuro
  static const Color textDisabled = Color(0xFFBDBDBD);   // Texto desabilitado
  
  // ========== CORES DE FUNDO ==========
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  
  // ========== CORES DE STATUS ==========
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);
  
  // ========== CORES DE BORDA ==========
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  static const Color cardBorder = Color(0xFFE0E0E0);
  
  // ========== CORES DE ÍCONES ==========
  static const Color iconPrimary = Color(0xFF212121);
  static const Color iconSecondary = Color(0xFF757575);
  static const Color iconLight = Color(0xFF9E9E9E);
  
  // ========== CORES DE AVALIAÇÃO ==========
  static const Color starFilled = Color(0xFFFFC107);
  static const Color starEmpty = Color(0xFFE0E0E0);
  
  // ========== CORES DE CATEGORIAS ==========
  static const Color categoryPizza = Color(0xFFFF6B6B);
  static const Color categoryBurger = Color(0xFF4ECDC4);
  static const Color categoryJapa = Color(0xFF45B7D1);
  static const Color categoryBrasileira = Color(0xFF96CEB4);
  static const Color categoryMarmita = Color(0xFFFFE194);
  static const Color categoryDoces = Color(0xFFD4A5A5);
  
  // ========== CORES PARA O TEMA DARK ==========
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextLight = Color(0xFF808080);
  static const Color darkIconPrimary = Colors.white;
  static const Color darkIconSecondary = Color(0xFFB0B0B0);

  // Mantendo constantes legíveis para compatibilidade
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color dark = Color(0xFF212121);
}
