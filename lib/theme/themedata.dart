import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

/// Design tokens and theme for the Roommate app.
///
/// Single source of truth for colors, gradients, radii, padding, shadows,
/// text styles, decorations, button styles, widget helpers, and the app
/// [ThemeData]. Import this module anywhere you need a token instead of
/// hardcoding a value.
///
/// This file merges the former `themedata.dart` (base tokens) and
/// `appstyling.dart` (extended tokens) into one module. The `*Extended`
/// class names have been collapsed into their base counterparts:
///
///   AppColorsExtended        -> AppColors
///   AppGradientsExtended     -> AppGradients
///   AppRadiiExtended         -> AppRadii
///   AppShadowsExtended       -> AppShadows
///   AppTextStylesExtended    -> AppTextStyles
///
/// The old warm brand gradient (`[AppColors.primary, AppColors.accentBlue]`)
/// is preserved as [AppGradients.brandWarm]; the new cool brand gradient
/// (`[AppColors.violetBrand, AppColors.blueBrand]`) is the default
/// [AppGradients.brand] and is what [AppButtonStyles.decoration] uses.

// ============================================================================
// COLORS
// ============================================================================

abstract final class AppColors {
  // --- Brand --------------------------------------------------------------
  static const Color primary = Color.fromARGB(255, 218, 75, 57);
  static const Color accentBlue = Color.fromARGB(255, 223, 179, 59);
  static const Color violetBrand = Color(0xFF7C6BFF);
  static const Color blueBrand = Color(0xFF3B82F6);
  static const Color violetOrb = Color(0xFF6D5DF6);
  static const Color link = Color(0xFF9B8CFF);

  // --- Backgrounds --------------------------------------------------------
  static const Color background = Color(0xFF080B16);
  static const Color gradientStart = Color(0xFF141B33);
  static const Color gradientMid = Color(0xFF080B16);
  static const Color gradientEnd = Color(0xFF1A1030);

  // --- Text ---------------------------------------------------------------
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9AA3B5);
  static const Color textMuted = Color(0xFF6B7489);

  // --- Interactive / feedback --------------------------------------------
  static const Color icon = Color(0xFF7C8A9F);
  static const Color success = Color(0xFF5AD1A0);
  static const Color error = Color(0xFFE5484D);
  static const Color errorText = Color(0xFFFF8A8D);

  // --- Glassmorphism ------------------------------------------------------
  static const Color glassFillLogin = Color(0x0EFFFFFF);
  static const Color glassFillChore = Color(0x0DFFFFFF);
  static const Color glassFillInput = Color(0x0FFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassBorderLogin = Color(0x1FFFFFFF);
  static const Color glassBorderInput = Color(0x1AFFFFFF);

  // --- Inputs -------------------------------------------------------------
  static const Color inputFocusedBorder = Color(0xCC7C6BFF);
  static const Color inputErrorBorder = Color(0xFFFF8A8D);

  // --- Tiles / badges / dividers -----------------------------------------
  static const Color tileIconBgPrimary = Color(0x299B4B39);
  static const Color urgentBadgeBg = Color(0x33E5484D);
  static const Color divider = Color(0x12FFFFFF);

  // --- Shadow tints -------------------------------------------------------
  static const Color shadowBlack35 = Color(0x59330000);
  static const Color shadowBrand40 = Color(0x667C6BFF);
  static const Color shadowBrand45 = Color(0x737C6BFF);
  static const Color shadowButton = Color(0x667C6BFF);
}

// ============================================================================
// GRADIENTS
// ============================================================================

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

  /// Cool brand gradient used by the logo icon and primary buttons.
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.violetBrand, AppColors.blueBrand],
  );

  /// Warm brand gradient (legacy). Use only when the original
  /// `[AppColors.primary, AppColors.accentBlue]` look is required.
  static const LinearGradient brandWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.accentBlue],
  );
}

// ============================================================================
// RADII
// ============================================================================

abstract final class AppRadii {
  static const double input = 16;
  static const double field = 16; // alias of [input]
  static const double button = 16;
  static const double logo = 20;
  static const double card = 28;
  static const double badge = 8;
  static const double chip = 11;
  static const double iconContainer = 12;
  static const double toggle = 28;
}

// ============================================================================
// PADDING
// ============================================================================

abstract final class AppPadding {
  static const EdgeInsets card = EdgeInsets.all(20);
  static const EdgeInsets cardLogin = EdgeInsets.all(28);

  static const EdgeInsets inputHorizontal = EdgeInsets.symmetric(
    horizontal: 16,
  );
  static const EdgeInsets inputField = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 18,
  );

  static const EdgeInsets tileHorizontal = EdgeInsets.symmetric(
    horizontal: 16,
  );
  static const EdgeInsets tile = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 13,
  );
  static const EdgeInsets tileInner = EdgeInsets.all(14);

  static const EdgeInsets badge = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 2,
  );
  static const EdgeInsets badgePts = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 0,
  );

  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(
    horizontal: 20,
  );
  static const EdgeInsets pageVertical = EdgeInsets.symmetric(vertical: 32);

  static const SizedBox space2 = SizedBox(height: 2);
  static const SizedBox space3 = SizedBox(height: 3);
  static const SizedBox space4 = SizedBox(height: 4);
  static const SizedBox space6 = SizedBox(height: 6);
  static const SizedBox space8 = SizedBox(width: 8, height: 8);
  static const SizedBox space12 = SizedBox(width: 12, height: 12);
  static const SizedBox space20 = SizedBox(height: 20);
}

// ============================================================================
// SHADOWS
// ============================================================================

abstract final class AppShadows {
  static const BoxShadow card = BoxShadow(
    color: AppColors.shadowBlack35,
    blurRadius: 40,
    offset: Offset(0, 20),
  );

  static const BoxShadow button = BoxShadow(
    color: AppColors.shadowButton,
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  /// Backwards-compatible alias for [button].
  static const BoxShadow brand = button;

  static const BoxShadow logo = BoxShadow(
    color: AppColors.shadowBrand45,
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}

// ============================================================================
// TEXT STYLES
// ============================================================================

abstract final class AppTextStyles {
  // --- Base / generic -----------------------------------------------------
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

  // --- Inputs / forms -----------------------------------------------------
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    color: AppColors.textMuted,
  );

  static const TextStyle requirementMet = TextStyle(
    fontSize: 12.5,
    color: AppColors.success,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle requirementUnmet = TextStyle(
    fontSize: 12.5,
    color: AppColors.textMuted,
    fontWeight: FontWeight.w400,
  );

  // --- Activity feed ------------------------------------------------------
  static const TextStyle activityTitle = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle activitySubtitle = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle activityAmount = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  static const TextStyle emptyState = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  // --- Chores -------------------------------------------------------------
  static const TextStyle choreTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle choreTitleCompleted = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    decoration: TextDecoration.lineThrough,
  );

  static const TextStyle choreSubtitle = TextStyle(
    fontSize: 12.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle choreSubtitleCompleted = TextStyle(
    fontSize: 12.5,
    color: AppColors.textMuted,
  );

  static const TextStyle chorePoints = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.success,
  );

  static const TextStyle urgentBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    color: AppColors.error,
  );

  static const TextStyle choreDate = TextStyle(
    fontSize: 11,
    color: AppColors.textSecondary,
  );

  static const TextStyle choreDateCompleted = TextStyle(
    fontSize: 11,
    color: AppColors.textMuted,
  );
}

// ============================================================================
// BOX DECORATIONS
// ============================================================================

abstract final class AppDecorations {
  static BoxDecoration glassCardLogin({EdgeInsetsGeometry? padding}) =>
      BoxDecoration(
        color: AppColors.glassFillLogin,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.glassBorderLogin),
        boxShadow: const [AppShadows.card],
      );

  static BoxDecoration glassCardChore({EdgeInsetsGeometry? padding}) =>
      BoxDecoration(
        color: AppColors.glassFillChore,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.glassBorder),
      );

  static BoxDecoration inputField({
    bool focused = false,
    bool hasError = false,
  }) =>
      BoxDecoration(
        color: AppColors.glassFillInput,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(
          color: hasError
              ? AppColors.inputErrorBorder
              : focused
                  ? AppColors.inputFocusedBorder
                  : AppColors.glassBorderInput,
        ),
      );

  static BoxDecoration tileIcon({required Color color, bool active = true}) =>
      BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.18)
            : AppColors.tileIconBgPrimary,
        borderRadius: BorderRadius.circular(AppRadii.iconContainer),
      );

  static BoxDecoration urgentBadge() => BoxDecoration(
        color: AppColors.urgentBadgeBg,
        borderRadius: BorderRadius.circular(AppRadii.badge),
      );

  static BoxDecoration toggleCircle({
    required bool completed,
    required Color color,
  }) =>
      BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? AppColors.success : Colors.transparent,
        border: Border.all(
          color: completed ? AppColors.success : AppColors.glassBorder,
          width: 2,
        ),
      );

  static BoxDecoration requirementIndicator({
    required bool met,
    required Color color,
  }) =>
      BoxDecoration(
        shape: BoxShape.circle,
        color: met ? color.withValues(alpha: 0.15) : Colors.transparent,
        border: Border.all(color: color.withValues(alpha: 0.6)),
      );
}

// ============================================================================
// BUTTON STYLES
// ============================================================================

abstract final class AppButtonStyles {
  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 14,
  );

  static const BorderRadius border = BorderRadius.all(Radius.circular(16));

  static BoxDecoration decoration({bool enabled = true}) => BoxDecoration(
        gradient: enabled ? AppGradients.brand : null,
        borderRadius: border,
        boxShadow: enabled ? const [AppShadows.button] : null,
      );

  static TextStyle textStyle({bool enabled = true}) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        letterSpacing: 0.3,
      );
}

// ============================================================================
// WIDGET HELPERS
// ============================================================================

abstract final class AppWidgets {
  static Widget glowOrb({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) =>
      Positioned(
        top: top,
        bottom: bottom,
        left: left,
        right: right,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      );

  static Widget glassCard({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(28)),
    double blurSigma = 16,
    Color? fillColor,
    Color? borderColor,
    List<BoxShadow>? boxShadow,
  }) =>
      ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: fillColor ?? AppColors.glassFillLogin,
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColor ?? AppColors.glassBorderLogin,
              ),
              boxShadow: boxShadow ?? const [AppShadows.card],
            ),
            child: child,
          ),
        ),
      );
}

// ============================================================================
// THEME DATA
// ============================================================================

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
