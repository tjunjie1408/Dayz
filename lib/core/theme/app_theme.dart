import 'package:flutter/material.dart';

/// Dayz app theme — "Soft & Airy" design language.
///
/// Warm pinks/peaches for the romantic (anniversary) aspect and
/// calming mint greens/light blues for the self-discipline (streak) aspect.

// ─── Color Palette ────────────────────────────────────────────────────────────

/// Romantic warm tones.
class RomanticColors {
  RomanticColors._();

  static const Color peach = Color(0xFFFDD6C4);
  static const Color softPink = Color(0xFFFBC2EB);
  static const Color blush = Color(0xFFF8B4B4);
  static const Color roseDark = Color(0xFFE07A7A);

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFEE2D5),
      Color(0xFFFDD6E8),
    ],
  );
}

/// Discipline cool tones.
class DisciplineColors {
  DisciplineColors._();

  static const Color mint = Color(0xFFC3F0E0);
  static const Color skyBlue = Color(0xFFBDE3F8);
  static const Color teal = Color(0xFFA8E6CF);
  static const Color accent = Color(0xFF5BB9A5);

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFD4F5E9),
      Color(0xFFCDE9F7),
    ],
  );
}

/// Neutral canvas tones.
class CanvasColors {
  CanvasColors._();

  static const Color background = Color(0xFFF9F7F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF2D2D3A);
  static const Color textSecondary = Color(0xFF7B7B8E);
  static const Color textMuted = Color(0xFFADADBE);
}

// ─── Theme ────────────────────────────────────────────────────────────────────

/// The light theme for the Dayz app.
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,

  // Global color scheme.
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFF4A9A8),
    brightness: Brightness.light,
    surface: CanvasColors.surface,
  ),

  // Off-white background — never harsh pure white.
  scaffoldBackgroundColor: CanvasColors.background,

  // Typography — clean sans-serif.
  fontFamily: 'Roboto',
  textTheme: const TextTheme(
    // The enormous day counter.
    displayLarge: TextStyle(
      fontSize: 72,
      fontWeight: FontWeight.w200,
      letterSpacing: -2,
      color: CanvasColors.textPrimary,
      height: 1.0,
    ),
    // Section headings.
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: CanvasColors.textPrimary,
    ),
    // Card labels.
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: CanvasColors.textSecondary,
    ),
    // Small helper text.
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: CanvasColors.textMuted,
    ),
    // Body text.
    bodyMedium: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: CanvasColors.textSecondary,
    ),
    // Button labels.
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    ),
  ),

  // Card theme — large rounded corners, soft shadow, no harsh border.
  cardTheme: CardThemeData(
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
    ),
    color: CanvasColors.surface,
  ),

  // Elevated button — pill-shaped.
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    ),
  ),

  // App bar — transparent, blending with the background.
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: CanvasColors.textPrimary,
      letterSpacing: -0.5,
    ),
  ),
);

// ─── Shared Decoration Helpers ────────────────────────────────────────────────

/// A very soft, diffuse box shadow used on cards throughout the app.
const List<BoxShadow> softCardShadow = [
  BoxShadow(
    color: Color(0x0D000000), // ~5% opacity black.
    blurRadius: 24,
    spreadRadius: 0,
    offset: Offset(0, 8),
  ),
  BoxShadow(
    color: Color(0x08000000), // ~3% opacity.
    blurRadius: 10,
    spreadRadius: 0,
    offset: Offset(0, 2),
  ),
];

/// Standard border radius used for cards.
final BorderRadius cardBorderRadius = BorderRadius.circular(24);
