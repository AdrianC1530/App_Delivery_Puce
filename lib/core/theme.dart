import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Premium Light Theme Palette
  static const Color primaryColor = Color(0xFF4A00E0); // Deep Violet
  static const Color accentColor = Color(0xFFFF416C);  // Vibrant Coral
  static const Color darkPurple = Color(0xFF1E0B3B);   // Very Dark Purple for text headers
  static const Color lightPurple = Color(0xFFF3EDFD);  // Soft background for chips
  
  // Neutral Colors
  static const Color bgLight = Color(0xFFFAFAFA); // Pure minimalist background
  static const Color cardLight = Colors.white;
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)], // Beautiful Purple Gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF4B2B), Color(0xFFFF416C)], // Coral Gradient
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        tertiary: darkPurple,
        surface: cardLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      scaffoldBackgroundColor: bgLight,
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.light().textTheme).copyWith(
        titleLarge: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 26, color: darkPurple, letterSpacing: -0.5),
        titleMedium: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 20, color: darkPurple, letterSpacing: -0.3),
        bodyLarge: GoogleFonts.outfit(fontSize: 16, color: Colors.black87),
        bodyMedium: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade600),
      ),
      cardTheme: CardThemeData(
        color: cardLight,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: primaryColor, width: 2.0),
        ),
        labelStyle: GoogleFonts.outfit(color: Colors.grey.shade600),
        hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
      ),
    );
  }

  // We are keeping dark theme as an option, but the focus is on lightTheme as requested.
  static ThemeData get darkTheme => lightTheme; 
}
