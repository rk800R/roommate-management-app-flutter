import 'package:flutter/material.dart';

/// Design tokens and theme for the Roommate app.
///
/// Extracted from the styling originally embedded in `LoginScreen` so the whole
/// app shares a single source of truth for colors, gradients, text, shape, and
/// elevation. Import this module anywhere you need a color or style instead of
/// hardcoding a value.

/// Brand and UI color tokens.
abstract final class AppColors {
  // Brand
  static const Color primary = Color.fromARGB(255, 218, 75, 57);
  static const Color accentBlue = Color.fromARGB(255, 223, 179, 59);
  static const Color violetOrb = Color(0xFF6D5DF6);
  static const Color link = Color(0xFF9B8CFF);

  // Backgrounds
  static const Color background = Color(0xFF080B16);
  static const Color gradientStart = Color(0xFF141B33);
  static const Color gradientMid = Color(0xFF080B16);
  static const Color gradientEnd = Color(0xFF1A1030);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9AA3B5);
  static const Color textMuted = Color(0xFF6B7489);

  // Interactive / feedback
  static const Color icon = Color(0xFF7C8A9F);
  static const Color success = Color(0xFF5AD1A0);
  static const Color error = Color(0xFFE5484D);
  static const Color errorText = Color(0xFFFF8A8D);
}

/// Reusable gradients.
abstract final class AppGradients {
  /// Full-screen background gradient (top-left -> bottom-right).
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientStart,
      AppColors.gradientMid,
      AppColors.gradientEnd,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Brand gradient used by the logo icon and primary buttons.
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.accentBlue],
  );
}

/// Corner radii used across the UI.
abstract final class AppRadii {
  static const double card = 28;
  static const double field = 16;
  static const double logo = 20;
}

/// Shadows used for elevation.
abstract final class AppShadows {
  static const BoxShadow card = BoxShadow(
    color: Color(0x59330000), // black @ 35% alpha
    blurRadius: 40,
    offset: Offset(0, 20),
  );

  static const BoxShadow brand = BoxShadow(
    color: Color(0x667C6BFF), // primary purple @ 40% alpha
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  static const BoxShadow logo = BoxShadow(
    color: Color(0x737C6BFF), // primary purple @ 45% alpha
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}

/// Shared text styles.
abstract final class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 15,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.3,
  );

  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.link,
  );

  static const TextStyle error = TextStyle(
    fontSize: 12,
    color: AppColors.errorText,
  );
}

/// App-wide [ThemeData] for the dark, glassmorphism look.
abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accentBlue,
      surface: AppColors.background,
      error: AppColors.error,
      onPrimary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        errorStyle: AppTextStyles.error,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.link),
      ),
    );
  }
}

