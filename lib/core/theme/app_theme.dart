import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  static ThemeData get luxuryTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      
      // Define the Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGold,
        secondary: AppColors.primaryGold,
        surface: AppColors.surfaceGrey,
        onSurface: AppColors.textWhite,
        error: AppColors.errorRed,
      ),

      // Text Theme using Google Fonts
      textTheme: TextTheme(
        displayLarge: GoogleFonts.instrumentSerif(
          fontSize: 32, 
          fontWeight: FontWeight.bold, 
          color: AppColors.primaryGold
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20, 
          fontWeight: FontWeight.w600, 
          color: AppColors.textWhite
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14, 
          color: AppColors.textGrey
        ),
      ),

      // Default Card Style (FIXED: CardTheme -> CardThemeData)
      cardTheme: CardThemeData(
        color: AppColors.surfaceGrey,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      ),
      
      // Default Button Style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: Colors.black, // Text color on Gold button
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}