import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

//AppTheme centralizes visual identity of app
//using static getter, we ensurea single source of truth for all ui components
class AppTheme {
  //uses Material 3 design srandards for component rendering
  static ThemeData get luxuryTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      
      // defines color scheme
      // ColorSchemeis the engine that drives Material 3 component colors
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGold, //color for buttons and highlghts
        secondary: AppColors.primaryGold, //secondary accents
        surface: AppColors.surfaceGrey, //bg for cards and tiles
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

      // Default Card Style 
      // to eliminate need to manually add padding to every Venue Card
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
