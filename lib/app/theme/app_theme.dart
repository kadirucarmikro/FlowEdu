import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Tango Dansı Renk Paleti
  static const Color tangoRed = Color(0xFFC41E3A); // Tutkulu kırmızı
  static const Color tangoBlack = Color(0xFF000000); // Zarif siyah
  static const Color tangoGold = Color(0xFFFFD700); // Lüks altın
  static const Color tangoBurgundy = Color(0xFF800020); // Derin bordo
  static const Color tangoDarkGray = Color(0xFF1A1A1A); // Koyu gri
  static const Color tangoLightGray = Color(0xFFF5F5F5); // Açık gri (arka plan)

  static ThemeData get light {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: tangoRed,
      onPrimary: Colors.white,
      primaryContainer: tangoBurgundy,
      onPrimaryContainer: Colors.white,
      secondary: tangoGold,
      onSecondary: tangoBlack,
      secondaryContainer: const Color(0xFFFFE082),
      onSecondaryContainer: tangoBlack,
      tertiary: tangoBurgundy,
      onTertiary: Colors.white,
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: Colors.white,
      onSurface: tangoDarkGray,
      surfaceContainerHighest: tangoLightGray,
      onSurfaceVariant: const Color(0xFF424242),
      outline: const Color(0xFF757575),
      outlineVariant: const Color(0xFFE0E0E0),
      shadow: tangoBlack.withOpacity(0.2),
      scrim: tangoBlack,
      inverseSurface: tangoDarkGray,
      onInverseSurface: Colors.white,
      inversePrimary: tangoRed.withOpacity(0.8),
      surfaceTint: tangoRed,
    );

    final base = ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      textTheme: GoogleFonts.playfairDisplayTextTheme().copyWith(
        // Başlıklar için Dancing Script
        displayLarge: GoogleFonts.dancingScript(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: tangoDarkGray,
        ),
        displayMedium: GoogleFonts.dancingScript(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: tangoDarkGray,
        ),
        displaySmall: GoogleFonts.dancingScript(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: tangoDarkGray,
        ),
        headlineLarge: GoogleFonts.playfairDisplay(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: tangoDarkGray,
        ),
        headlineMedium: GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: tangoDarkGray,
        ),
        headlineSmall: GoogleFonts.playfairDisplay(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: tangoDarkGray,
        ),
        titleLarge: GoogleFonts.playfairDisplay(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: tangoDarkGray,
        ),
        titleMedium: GoogleFonts.playfairDisplay(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: tangoDarkGray,
        ),
        titleSmall: GoogleFonts.playfairDisplay(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: tangoDarkGray,
        ),
        bodyLarge: GoogleFonts.playfairDisplay(
          fontSize: 16,
          color: tangoDarkGray,
        ),
        bodyMedium: GoogleFonts.playfairDisplay(
          fontSize: 14,
          color: tangoDarkGray,
        ),
        bodySmall: GoogleFonts.playfairDisplay(
          fontSize: 12,
          color: tangoDarkGray,
        ),
        labelLarge: GoogleFonts.playfairDisplay(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: tangoDarkGray,
        ),
        labelMedium: GoogleFonts.playfairDisplay(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: tangoDarkGray,
        ),
        labelSmall: GoogleFonts.playfairDisplay(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: tangoDarkGray,
        ),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: tangoLightGray,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: tangoRed.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: tangoRed.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          borderSide: const BorderSide(color: tangoRed, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: tangoRed,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        shadowColor: tangoBlack.withOpacity(0.1),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: tangoRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tangoRed,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: tangoLightGray,
        selectedColor: tangoRed,
        labelStyle: GoogleFonts.playfairDisplay(),
        secondaryLabelStyle: GoogleFonts.playfairDisplay(color: Colors.white),
      ),
    );
  }
}
