import 'package:flutter/material.dart';

class AppColors {
  // === PALETA PRINCIPAL ===
  static const Color primary = Color(0xFF004D40);       // Botones, íconos activos
  static const Color primaryDark = Color(0xFF00332B);   // Fondos oscuros, títulos
  static const Color secondary = Color(0xFF80CBC4);     // Acentos suaves, badges
  static const Color tertiary = Color(0xFF693527);      // Alertas, highlights alternos

  // Alias de compatibilidad
  static const Color primaryTeal = Color(0xFF80CBC4);   // = secondary
  static const Color primaryGreen = Color(0xFF004D40);  // = primary

  // Fondos
  static const Color bgLight = Color(0xFFF1F8F7);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgMint = Color(0xFFE0F2F1);
  static const Color bgSidebar = Color(0xFFE4F0EB);

  // Textos
  static const Color textPrimary = Color(0xFF00332B);
  static const Color textSecondary = Color(0xFF004D40);
  static const Color textLight = Color(0xFF5A6B63);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Estados
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFE67E22);
  static const Color danger = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Bordes
  static const Color border = Color(0xFFD5E5DD);
  static const Color borderLight = Color(0xFFE8F0EC);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.bgLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.bgCard,
        onPrimary: Colors.white,
        onSecondary: AppColors.primaryDark,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Segoe UI',
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textPrimary, height: 1.2),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        titleMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 1.5),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary),
        labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 1.2),
        labelMedium: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 1.2),
        ),
      ),
    );
  }
}
