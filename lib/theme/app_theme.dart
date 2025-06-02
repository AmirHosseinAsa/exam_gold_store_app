import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/constants.dart';

class AppTheme {
  static TextTheme darkTextTheme = TextTheme(
    bodyLarge: GoogleFonts.vazirmatn(
      fontSize: 16,
      color: cTextPrimary,
      fontWeight: FontWeight.w400,
    ),  
    bodyMedium: GoogleFonts.vazirmatn(
      fontSize: 14,
      color: cTextPrimary,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: GoogleFonts.vazirmatn(
      fontSize: 12,
      color: cTextSecondary,
      fontWeight: FontWeight.w400,
    ),
    headlineLarge: GoogleFonts.vazirmatn(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: cTextPrimary,
    ),
    headlineMedium: GoogleFonts.vazirmatn(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: cTextPrimary,
    ),
    headlineSmall: GoogleFonts.vazirmatn(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: cTextPrimary,
    ),
    titleLarge: GoogleFonts.vazirmatn(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: cTextPrimary,
    ),
    titleMedium: GoogleFonts.vazirmatn(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: cTextPrimary,
    ),
    titleSmall: GoogleFonts.vazirmatn(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: cTextSecondary,
    ),
    labelLarge: GoogleFonts.vazirmatn(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: cTextPrimary,
    ),
    labelMedium: GoogleFonts.vazirmatn(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: cTextSecondary,
    ),
    labelSmall: GoogleFonts.vazirmatn(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: cTextSecondary,
    ),
  );

  static ThemeData dark() {
    return ThemeData(
      primarySwatch: Colors.amber,
      iconTheme: IconThemeData(color: cTextPrimary),
      primaryIconTheme: IconThemeData(color: cTextPrimary),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: cBackgroundColor,
      primaryColor: cPrimaryColor,
      colorScheme: ColorScheme.dark(
        primary: cPrimaryColor,
        secondary: cAccentColor,
        surface: cSurfaceColor,
        background: cBackgroundColor,
        onPrimary: cTextPrimary,
        onSecondary: cTextPrimary,
        onSurface: cTextPrimary,
        onBackground: cTextPrimary,
        outline: cBorderColor,
        surfaceVariant: cCardBackground,
      ),
      appBarTheme: AppBarTheme(
        foregroundColor: cTextPrimary,
        backgroundColor: cSurfaceColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: cTextPrimary),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: cPrimaryColor),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        foregroundColor: cTextPrimary,
        backgroundColor: cPrimaryColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: cPrimaryColor,
        unselectedItemColor: cTextSecondary,
        backgroundColor: cSurfaceColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cPrimaryColor.withOpacity(0.65),
          foregroundColor: cTextPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: cTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: cCardBackground,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cSurfaceColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(color: cBorderColor, thickness: 1),
      textTheme: darkTextTheme,
    );
  }

  static TextTheme whiteTextTheme = darkTextTheme;
  static ThemeData white() => dark(); 
}