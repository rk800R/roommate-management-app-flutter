import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

import '../themedata.dart';
export '../themedata.dart';

// ============================================================================
// COLORS
// ============================================================================

abstract final class AppColorsExtended {
  static const Color violetBrand = Color(0xFF7C6BFF);
  static const Color blueBrand = Color(0xFF3B82F6);

  static const Color glassFillLogin = Color(0x0EFFFFFF);
  static const Color glassFillChore = Color(0x0DFFFFFF);
  static const Color glassFillInput = Color(0x0FFFFFFF);
  static const Color glassBorder = Color(0x1AFFFFFF);
  static const Color glassBorderLogin = Color(0x1FFFFFFF);
  static const Color glassBorderInput = Color(0x1AFFFFFF);

  static const Color inputFocusedBorder = Color(0xCC7C6BFF);
  static const Color inputErrorBorder = Color(0xFFFF8A8D);

  static const Color tileIconBgPrimary = Color(0x299B4B39);

  static const Color urgentBadgeBg = Color(0x33E5484D);
  static const Color divider = Color(0x12FFFFFF);

  static const Color shadowBlack35 = Color(0x59330000);
  static const Color shadowBrand40 = Color(0x667C6BFF);
  static const Color shadowBrand45 = Color(0x737C6BFF);
  static const Color shadowButton = Color(0x667C6BFF);
}

// ============================================================================
// RADII
// ============================================================================

abstract final class AppRadiiExtended {
  static const double input = 16;
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

  static const EdgeInsets tileHorizontal = EdgeInsets.symmetric(horizontal: 16);
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

  static const EdgeInsets pageHorizontal = EdgeInsets.symmetric(horizontal: 20);
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

abstract final class AppShadowsExtended {
  static const BoxShadow card = BoxShadow(
    color: AppColorsExtended.shadowBlack35,
    blurRadius: 40,
    offset: Offset(0, 20),
  );

  static const BoxShadow button = BoxShadow(
    color: AppColorsExtended.shadowButton,
    blurRadius: 20,
    offset: Offset(0, 8),
  );

  static const BoxShadow logo = BoxShadow(
    color: AppColorsExtended.shadowBrand45,
    blurRadius: 24,
    offset: Offset(0, 8),
  );
}

// ============================================================================
// TEXT STYLES
// ============================================================================

abstract final class AppTextStylesExtended {
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
// GRADIENTS
// ============================================================================

abstract final class AppGradientsExtended {
  static const LinearGradient brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColorsExtended.violetBrand, AppColorsExtended.blueBrand],
  );
}

// ============================================================================
// BOX DECORATIONS
// ============================================================================

abstract final class AppDecorations {
  static BoxDecoration glassCardLogin({EdgeInsetsGeometry? padding}) =>
      BoxDecoration(
        color: AppColorsExtended.glassFillLogin,
        borderRadius: BorderRadius.circular(AppRadiiExtended.card),
        border: Border.all(color: AppColorsExtended.glassBorderLogin),
        boxShadow: [AppShadowsExtended.card],
      );

  static BoxDecoration glassCardChore({EdgeInsetsGeometry? padding}) =>
      BoxDecoration(
        color: AppColorsExtended.glassFillChore,
        borderRadius: BorderRadius.circular(AppRadiiExtended.card),
        border: Border.all(color: AppColorsExtended.glassBorder),
      );

  static BoxDecoration inputField({
    bool focused = false,
    bool hasError = false,
  }) => BoxDecoration(
    color: AppColorsExtended.glassFillInput,
    borderRadius: BorderRadius.circular(AppRadiiExtended.input),
    border: Border.all(
      color: hasError
          ? AppColorsExtended.inputErrorBorder
          : focused
          ? AppColorsExtended.inputFocusedBorder
          : AppColorsExtended.glassBorderInput,
    ),
  );

  static BoxDecoration tileIcon({required Color color, bool active = true}) =>
      BoxDecoration(
        color: active
            ? color.withValues(alpha: 0.18)
            : AppColorsExtended.tileIconBgPrimary,
        borderRadius: BorderRadius.circular(AppRadiiExtended.iconContainer),
      );

  static BoxDecoration urgentBadge() => BoxDecoration(
    color: AppColorsExtended.urgentBadgeBg,
    borderRadius: BorderRadius.circular(AppRadiiExtended.badge),
  );

  static BoxDecoration toggleCircle({
    required bool completed,
    required Color color,
  }) => BoxDecoration(
    shape: BoxShape.circle,
    color: completed ? AppColors.success : Colors.transparent,
    border: Border.all(
      color: completed ? AppColors.success : AppColorsExtended.glassBorder,
      width: 2,
    ),
  );

  static BoxDecoration requirementIndicator({
    required bool met,
    required Color color,
  }) => BoxDecoration(
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
    gradient: enabled ? AppGradientsExtended.brand : null,
    borderRadius: border,
    boxShadow: enabled ? const [AppShadowsExtended.button] : null,
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
  }) => Positioned(
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
          colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)],
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
  }) => ClipRRect(
    borderRadius: borderRadius,
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: fillColor ?? AppColorsExtended.glassFillLogin,
          borderRadius: borderRadius,
          border: Border.all(
            color: borderColor ?? AppColorsExtended.glassBorderLogin,
          ),
          boxShadow: boxShadow ?? [AppShadowsExtended.card],
        ),
        child: child,
      ),
    ),
  );
}
