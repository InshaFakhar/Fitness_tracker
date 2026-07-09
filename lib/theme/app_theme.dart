import 'package:flutter/material.dart';

class AppColors {
  static const primary      = Color(0xFF6C63FF);
  static const primaryDark  = Color(0xFF4E46E5);
  static const secondary    = Color(0xFF00D4AA);
  static const accent       = Color(0xFFFF6B9D);
  static const success      = Color(0xFF2ECC71);
  static const warning      = Color(0xFFF39C12);
  static const error        = Color(0xFFE74C3C);
  static const info         = Color(0xFF3498DB);
  static const running      = Color(0xFFFF6B9D);
  static const cycling      = Color(0xFF6C63FF);
  static const swimming     = Color(0xFF00D4AA);
  static const gym          = Color(0xFFFF8C42);
  static const yoga         = Color(0xFFA8E6CF);
  static const hiit         = Color(0xFFFF6B6B);
  static const lightBg      = Color(0xFFF8F9FE);
  static const lightCard    = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF0F1FF);
  static const darkBg       = Color(0xFF0F0F1A);
  static const darkCard     = Color(0xFF1A1A2E);
  static const darkSurface  = Color(0xFF16213E);
}

class AppTheme {
  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.light, primary: AppColors.primary, secondary: AppColors.secondary),
    scaffoldBackgroundColor: AppColors.lightBg,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: false,
        iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
        titleTextStyle: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
    cardTheme: CardThemeData(color: AppColors.darkCard, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15))),
    inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.error)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: Color(0xFF888888), fontFamily: 'Poppins')),
    textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
        bodyLarge: TextStyle(fontSize: 15, color: Color(0xFF444444)),
        bodyMedium: TextStyle(fontSize: 13, color: Color(0xFF666666)),
        labelSmall: TextStyle(fontSize: 11, color: Color(0xFF888888))),
  );

  static ThemeData dark() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: Brightness.dark, primary: AppColors.primary, secondary: AppColors.secondary),
    scaffoldBackgroundColor: AppColors.darkBg,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(fontFamily: 'Poppins', fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white)),
    cardTheme: CardThemeData(color: AppColors.darkCard, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),    elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary, foregroundColor: Colors.white, elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600, fontSize: 15))),
    inputDecorationTheme: InputDecorationTheme(
        filled: true, fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: Color(0xFF888888), fontFamily: 'Poppins')),
    textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        bodyLarge: TextStyle(fontSize: 15, color: Color(0xFFCCCCCC)),
        bodyMedium: TextStyle(fontSize: 13, color: Color(0xFF999999)),
        labelSmall: TextStyle(fontSize: 11, color: Color(0xFF666666))),
  );
}