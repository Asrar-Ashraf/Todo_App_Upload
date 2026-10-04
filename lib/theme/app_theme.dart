import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color scaffoldColor = Color(0xFF050B0A);
const Color surfaceColor = Color(0xFF0D1715);
const Color higherSurfaceColor = Color(0xFF16221F);
const Color primaryColor = Color(0xFF34D399);
const Color secondaryColor = Color(0xFF22D3EE);
const Color accentColor = Color(0xFFA78BFA);
const Color lowPriorityColor = Color(0xFF34D399);
const Color mediumPriorityColor = Color(0xFFFBBF24);
const Color highPriorityColor = Color(0xFFFB7185);
const Color titleTextColor = Color(0xFFEEECFF);
const Color subtitleTextColor = Color(0xFFA9A6C8);

final ThemeData appTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  scaffoldBackgroundColor: scaffoldColor,
  colorScheme: const ColorScheme.dark(
    primary: primaryColor,
    secondary: secondaryColor,
    surface: surfaceColor,
    onPrimary: scaffoldColor,
    onSurface: titleTextColor,
  ),
  textTheme: TextTheme(
    displayLarge: GoogleFonts.poppins(
      color: titleTextColor,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displayMedium: GoogleFonts.poppins(
      color: titleTextColor,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    displaySmall: GoogleFonts.poppins(
      color: titleTextColor,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.poppins(
      color: titleTextColor,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    headlineMedium: GoogleFonts.poppins(
      color: titleTextColor,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    headlineSmall: GoogleFonts.poppins(
      color: titleTextColor,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    titleLarge: GoogleFonts.poppins(
      color: titleTextColor,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
    ),
    titleMedium: GoogleFonts.inter(color: subtitleTextColor),
    titleSmall: GoogleFonts.inter(color: subtitleTextColor),
    bodyLarge: GoogleFonts.inter(color: titleTextColor),
    bodyMedium: GoogleFonts.inter(color: titleTextColor),
    bodySmall: GoogleFonts.inter(color: subtitleTextColor),
    labelLarge: GoogleFonts.inter(color: titleTextColor),
  ),
  cardTheme: CardThemeData(
    color: surfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(28),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.05),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: primaryColor),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: const StadiumBorder(),
      backgroundColor: primaryColor,
      foregroundColor: scaffoldColor,
    ),
  ),
  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: surfaceColor,
    modalBackgroundColor: surfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
  ),
  snackBarTheme: SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    contentTextStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ),
    actionTextColor: primaryColor,
  ),
);
