import 'package:flutter/material.dart';

extension ThemeExtensions on BuildContext {
  // Cores principais via Theme
  Color get primaryColor => Theme.of(this).colorScheme.primary;
  Color get secondaryColor => Theme.of(this).colorScheme.secondary;
  Color get surfaceColor => Theme.of(this).colorScheme.surface;
  Color get errorColor => Theme.of(this).colorScheme.error;
  
  // Cores de texto via TextTheme
  Color get textPrimary => Theme.of(this).textTheme.bodyLarge?.color ?? Colors.black;
  Color get textSecondary => Theme.of(this).textTheme.bodyMedium?.color ?? Colors.grey;
  Color get textLight => Theme.of(this).textTheme.bodySmall?.color ?? Colors.grey[400]!;
  
  // Cores de fundo
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(this).cardTheme.color ?? Colors.white;
  
  // Cores de ícones
  Color get iconColor => Theme.of(this).iconTheme.color ?? Colors.black;
  
  // Utilitários
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
