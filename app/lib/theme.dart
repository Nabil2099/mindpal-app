import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MindPalColors {
  static const sand50 = Color(0xFFF8F6F2);
  static const sand100 = Color(0xFFF2EDE6);
  static const sand200 = Color(0xFFE7DDD1);
  static const clay100 = Color(0xFFE7DDD1);
  static const clay200 = Color(0xFFD6C4AF);
  static const clay300 = Color(0xFFBEA489);
  static const clay400 = Color(0xFFA98765);
  static const sage100 = Color(0xFFE2E6DF);
  static const ink700 = Color(0xFF5A5148);
  static const ink800 = Color(0xFF3F372F);
  static const ink900 = Color(0xFF261F19);
  static const inkDeep = Color(0xFF1F1813);
  static const navBg = Color(0xFFF3EFE9);
  static const surface = Color(0xFFFBF9F5);
  static const surfaceLow = Color(0xFFF5F3EF);
  static const surfaceHigh = Color(0xFFE4E2DE);
  static const recommendationGradientStart = Color(0xFFFFFCF6);
  static const recommendationGradientEnd = Color(0xFFF0E8DD);
  static const timerCardBg = Color(0xFFF5EFE4);

  static const emotionJoy = Color(0xFFE2CAB0);
  static const emotionExcitement = Color(0xFFC9958A);
  static const emotionGratitude = Color(0xFFC89A77);
  static const emotionCalm = Color(0xFFB79282);
  static const emotionNeutral = Color(0xFFD8BEA4);
  static const emotionAnxiety = Color(0xFFD6A88C);
  static const emotionSadness = Color(0xFFAD8A7A);
  static const emotionFrustration = Color(0xFFBD8777);
  static const emotionAnger = Color(0xFFBF8476);

  static Color emotionColor(String label) {
    switch (label.trim().toLowerCase()) {
      case 'joy':
        return emotionJoy;
      case 'excitement':
        return emotionExcitement;
      case 'gratitude':
        return emotionGratitude;
      case 'calm':
        return emotionCalm;
      case 'anxiety':
        return emotionAnxiety;
      case 'sadness':
        return emotionSadness;
      case 'frustration':
        return emotionFrustration;
      case 'anger':
        return emotionAnger;
      default:
        return emotionNeutral;
    }
  }
}

ThemeData get mindpalTheme {
  final base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: MindPalColors.clay300,
    scaffoldBackgroundColor: MindPalColors.surface,
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
  );

  return base.copyWith(
    textTheme: TextTheme(
      headlineLarge: GoogleFonts.newsreader(
        fontSize: 44,
        height: 1.05,
        fontWeight: FontWeight.w500,
        color: MindPalColors.ink900,
      ),
      headlineMedium: GoogleFonts.newsreader(
        fontSize: 32,
        height: 1.12,
        fontWeight: FontWeight.w500,
        color: MindPalColors.ink900,
      ),
      titleLarge: GoogleFonts.newsreader(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: MindPalColors.ink900,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 16,
        height: 1.5,
        color: MindPalColors.ink800,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 1.45,
        color: MindPalColors.ink700,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 10,
        letterSpacing: 1.1,
        fontWeight: FontWeight.w700,
        color: MindPalColors.ink700,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: MindPalColors.surface.withValues(alpha: 0.85),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.newsreader(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: MindPalColors.ink900,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: MindPalColors.navBg,
      selectedItemColor: MindPalColors.ink900,
      unselectedItemColor: MindPalColors.ink700,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: MindPalColors.sand50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: MindPalColors.clay300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: MindPalColors.clay300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(color: MindPalColors.clay300, width: 1.5),
      ),
      hintStyle: const TextStyle(color: MindPalColors.ink700),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  );
}
