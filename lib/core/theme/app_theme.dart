import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.bgMain,
      ),
      scaffoldBackgroundColor: AppColors.bgMain,
      textTheme: GoogleFonts.tajawalTextTheme().copyWith(
        displayLarge: GoogleFonts.fredoka(
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
          fontSize: 32,
        ),
        displayMedium: GoogleFonts.fredoka(
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          fontSize: 28,
        ),
        displaySmall: GoogleFonts.fredoka(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontSize: 24,
        ),
        titleLarge: GoogleFonts.tajawal(
          fontWeight: FontWeight.w900,
          color: AppColors.textDark,
          fontSize: 26,
        ),
        titleMedium: GoogleFonts.tajawal(
          fontWeight: FontWeight.w800,
          color: AppColors.textDark,
          fontSize: 22,
        ),
        bodyLarge: GoogleFonts.tajawal(
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
          fontSize: 18,
        ),
        bodyMedium: GoogleFonts.tajawal(
          fontWeight: FontWeight.w600,
          color: AppColors.textMid,
          fontSize: 16,
        ),
      ),
    );
  }
}
