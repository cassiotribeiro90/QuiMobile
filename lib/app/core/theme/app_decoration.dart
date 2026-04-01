import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppDecoration {
  // Bordas
  static BorderRadius get borderRadiusSmall => BorderRadius.circular(8);
  static BorderRadius get borderRadiusMedium => BorderRadius.circular(12);
  static BorderRadius get borderRadiusLarge => BorderRadius.circular(16);
  static BorderRadius get borderRadiusXLarge => BorderRadius.circular(24);
  
  // Inputs
  static InputBorder get inputEnabledBorder => OutlineInputBorder(
    borderRadius: borderRadiusMedium,
    borderSide: const BorderSide(color: AppColors.border),
  );
  
  static InputBorder get inputFocusedBorder => OutlineInputBorder(
    borderRadius: borderRadiusMedium,
    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
  );
  
  // Cards
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.card,
    borderRadius: borderRadiusMedium,
    border: Border.all(color: AppColors.border),
    boxShadow: AppColors.cardShadow,
  );
  
  // Search
  static BoxDecoration get searchDecoration => BoxDecoration(
    color: AppColors.surface,
    borderRadius: borderRadiusMedium,
    border: Border.all(color: AppColors.border),
  );
  
  // Chips
  static BoxDecoration chipDecoration({required bool selected}) {
    return BoxDecoration(
      color: selected ? AppColors.primarySurface : AppColors.surface,
      borderRadius: borderRadiusLarge,
      border: Border.all(
        color: selected ? AppColors.primary : AppColors.border,
      ),
    );
  }
  
  // Botões
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    textStyle: AppTextStyles.button,
  );
  
  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: borderRadiusMedium),
    textStyle: AppTextStyles.button,
  );
}
