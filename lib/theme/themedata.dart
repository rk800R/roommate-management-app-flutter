import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

// =============================================================================
// Theme Data — single source of truth for the app's visual design tokens.
//
// Categories (top-level):
//   • AppColors     — raw color tokens
//   • AppGradients  — reusable gradients
//   • AppRadii      — corner radius tokens
//   • AppPadding    — padding + vertical spacing tokens
//   • AppShadows    — drop-shadow tokens
//   • AppTextStyles — shared text styles
//   • AppDecorations — composed BoxDecoration presets
//   • AppButtonStyles — button decoration / text presets
//   • AppWidgets    — small reusable widgets (glow orb, glass card)
//   • AppTheme      — global ThemeData for the app
// =============================================================================

abstract final class AppColors {
  // --- Brand & Accent -------------------------------------------------------
  static const primary = Color(0xFFDA4B39);
  static const accentBlue = Color(0xFFDFB33B);
  static const violetBrand = Color(0xFF7C6BFF);
  static const blueBrand = Color(0xFF3B82F6);
  static const violetOrb = Color(0xFF6D5DF6);

  // --- Screen background & gradients -----------------------------------------
  static const background = Color.fromARGB(255, 175, 91, 103);
  static const surface = background;
  static const gradientStart = Color.fromARGB(255, 127, 127, 128);
  static const gradientEnd = Color.fromARGB(255, 26, 48, 16);

  // --- Text ------------------------------------------------------------------
  static const textPrimary = Colors.white;
  static const textSecondary = Color(0xFF9AA3B5);
  static const textMuted = Color(0xFF6B7489);

  // --- Icon & status -----------------------------------------------------------
  static const icon = Color(0xFF7C8A9F);
  static const success = Color(0xFF5AD1A0);
  static const warning = Colors.orange;
  static const info = Color(0xFF3B82F6);
  static const error = Color(0xFFE5484D);
  static const errorAccent = Colors.redAccent;
  static const errorText = Color(0xFFFF8A8D);

  // --- Glass / surface effects ------------------------------------------------
  static const glassFill = Color(0x0DFFFFFF);
  static const glassFillInput = Color(0x0FFFFFFF);
  static const glassBorder = Color(0x1AFFFFFF);

  // --- Focus / selection ------------------------------------------------------
  static const inputFocusedBorder = Color(0xCC7C6BFF);
  static const link = Color(0xFF9B8CFF);

  // --- Badge & tile fills ----------------------------------------------------
  static const urgentBadgeBg = Color(0x33E5484D);

  // --- Dividers & shadows ------------------------------------------------------
  static const divider = Color(0x12FFFFFF);
  static const shadowBlack35 = Color(0x59330000);
  static const shadowBrand45 = Color(0x737C6BFF);
  static const shadowButton = Color(0x667C6BFF);
}

abstract final class AppGradients {
  /// Full-screen background gradient (dark blue → near-black → dark violet).
  static const background = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientStart, AppColors.background, AppColors.gradientEnd],
    stops: [0.0, 0.55, 1.0],
  );

  /// Default brand gradient (violet → blue).
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.violetBrand, AppColors.blueBrand],
  );

  /// Warm brand gradient (primary red → gold) used for emphasis.
  static const brandWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.accentBlue],
  );
}

abstract final class AppRadii {
  // --- Common radius tokens ---------------------------------------------------
  static const input = 16.0;        // Text inputs & primary buttons
  static const button = 16.0;
  static const logo = 20.0;         // Logo / brand mark corners
  static const card = 28.0;         // Main card surfaces
  static const badge = 8.0;         // Small badges & pills
  static const chip = 11.0;         // Chips & compact labels
  static const dismissible = 15.0;
}

abstract final class AppPadding {
  // --- Content padding ---------------------------------------------------------
  static const cardLogin = EdgeInsets.all(28);
  static const inputHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const inputField = EdgeInsets.symmetric(horizontal: 16, vertical: 18);
  static const tileInner = EdgeInsets.all(14);
  static const badge = EdgeInsets.symmetric(horizontal: 8, vertical: 2);
  static const pageHorizontal = EdgeInsets.symmetric(horizontal: 20);
  static const header = EdgeInsets.all(20);
  static const bottom12 = EdgeInsets.only(bottom: 12);
  static const bottom16 = EdgeInsets.only(bottom: 16);
  static const vertical4 = EdgeInsets.symmetric(vertical: 4);
  static const right8 = EdgeInsets.only(right: 8);

  // --- Vertical / spacing helpers ----------------------------------------------
  static const space2 = SizedBox(height: 2);
  static const space3 = SizedBox(height: 3);
  static const space4 = SizedBox(height: 4);
  static const space6 = SizedBox(height: 6);
  static const space8 = SizedBox(height: 8);
  static const space12 = SizedBox(height: 12);
  static const space16 = SizedBox(height: 16);
  static const space20 = SizedBox(height: 20);
  static const space24 = SizedBox(height: 24);
  static const space32 = SizedBox(height: 32);
  
  static const width8 = SizedBox(width: 8);
  static const width12 = SizedBox(width: 12);
}

abstract final class AppShadows {
  /// Soft elevation shadow for cards.
  static const card = BoxShadow(color: AppColors.shadowBlack35, blurRadius: 40, offset: Offset(0, 20));
  /// Stronger shadow for primary buttons.
  static const button = BoxShadow(color: AppColors.shadowButton, blurRadius: 20, offset: Offset(0, 8));
  /// Branded glow shadow for the logo.
  static const logo = BoxShadow(color: AppColors.shadowBrand45, blurRadius: 24, offset: Offset(0, 8));
}

abstract final class AppTextStyles {
  // --- Screen-level text ------------------------------------------------------
  static const heading = TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5);
  static const subtitle = TextStyle(fontSize: 15, color: AppColors.textSecondary);
  static const body = TextStyle(fontSize: 14, color: AppColors.textPrimary);
  static const sectionHeader = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.3);
  static const emptyState = TextStyle(fontSize: 14, color: AppColors.textSecondary);

  // --- Interactive / actions --------------------------------------------------
  static const button = TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.3);
  static const link = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.link);

  // --- Form fields --------------------------------------------------------------
  static const inputLabel = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static const inputHint = TextStyle(fontSize: 14, color: AppColors.textMuted);
  static const error = TextStyle(fontSize: 12, color: AppColors.errorText);

  // --- Summary Cards -------------------------------------------------------------
  static const summaryTitle = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white);
  static const summaryValue = TextStyle(fontSize: 28, height: 1.0, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: Colors.white);
  static const summarySubtitle = TextStyle(fontSize: 12, color: Color(0xD9FFFFFF));

  // --- Activity list --------------------------------------------------------------
  static const activityTitle = TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static const activitySubtitle = TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static const activityAmount = TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  // --- Chore list -----------------------------------------------------------------
  static const choreTitle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static const choreTitleCompleted = TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted, decoration: TextDecoration.lineThrough);
  static const choreSubtitle = TextStyle(fontSize: 12.5, color: AppColors.textSecondary);
  static const choreSubtitleCompleted = TextStyle(fontSize: 12.5, color: AppColors.textMuted);
  static const choreDate = TextStyle(fontSize: 11, color: AppColors.textSecondary);
  static const choreDateCompleted = TextStyle(fontSize: 11, color: AppColors.textMuted);

  static TextStyle statusTag(bool isPaid) => TextStyle(
        color: isPaid ? AppColors.success : AppColors.warning,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      );

  static TextStyle priorityBadge(bool isUrgent) => TextStyle(
        color: isUrgent ? AppColors.errorAccent : AppColors.blueBrand,
        fontWeight: FontWeight.bold,
        fontSize: 10,
      );
}

abstract final class AppDecorations {
  // --- Glass surfaces -----------------------------------------------------------
  static BoxDecoration glassCard({bool hasShadow = false}) => BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: hasShadow ? const [AppShadows.card] : null,
      );

  // --- Form fields ---------------------------------------------------------------
  static BoxDecoration inputField({bool focused = false, bool hasError = false}) => BoxDecoration(
        color: AppColors.glassFillInput,
        borderRadius: BorderRadius.circular(AppRadii.input),
        border: Border.all(
          color: hasError ? AppColors.errorText : focused ? AppColors.inputFocusedBorder : AppColors.glassBorder,
        ),
      );

  static BoxDecoration summaryCard(Gradient gradient) => BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadii.card),
        gradient: gradient,
        boxShadow: const [
          BoxShadow(
            color: Color(0x3D000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      );
  static BoxDecoration summaryIcon() => BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      );

  static BoxDecoration statusTag(bool isPaid) => BoxDecoration(
        color: (isPaid ? AppColors.success : AppColors.warning).withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadii.badge),
        border: Border.all(color: isPaid ? AppColors.success : AppColors.warning, width: 1),
      );

  static BoxDecoration priorityBadge(bool isUrgent) => BoxDecoration(
        color: (isUrgent ? AppColors.warning : AppColors.info).withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadii.badge),
        border: Border.all(color: isUrgent ? AppColors.errorAccent : AppColors.blueBrand, width: 1),
        boxShadow: isUrgent
            ? [
                BoxShadow(
                  color: AppColors.errorAccent.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                )
              ]
            : [],
      );

  static BoxDecoration dismissibleBackground() => BoxDecoration(
    color: AppColors.error,
    borderRadius: BorderRadius.circular(AppRadii.dismissible),
  );
  
  static BoxDecoration logoIcon() => BoxDecoration(
    gradient: AppGradients.brand,
    borderRadius: BorderRadius.circular(AppRadii.logo),
    boxShadow: const [AppShadows.logo],
  );
}

abstract final class AppButtonStyles {
  /// Padding and shape for buttons.
  static const padding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  static const border = BorderRadius.all(Radius.circular(AppRadii.input));

  /// Button surface — brand gradient + shadow when enabled, plain when disabled.
  static BoxDecoration decoration({bool enabled = true}) => BoxDecoration(
        gradient: enabled ? AppGradients.brand : null,
        borderRadius: border,
        boxShadow: enabled ? const [AppShadows.button] : null,
      );

  /// Button label — light & bold when enabled, muted when disabled.
  static TextStyle textStyle({bool enabled = true}) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: enabled ? AppColors.textPrimary : AppColors.textMuted,
        letterSpacing: 0.3,
      );
}

abstract final class AppWidgets {
  /// Decorative radial glow orb, positioned via the given offsets.
  static Widget glowOrb({double? top, double? bottom, double? left, double? right, required double size, required Color color}) =>
      Positioned(
        top: top, bottom: bottom, left: left, right: right,
        child: Container(
          width: size, height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0.0)]),
          ),
        ),
      );

  /// Frosted "glass" container: clips a blurred layer over the card surface.
  static Widget glassCard({
    Key? key,
    required Widget child,
    EdgeInsetsGeometry? padding,
    BorderRadius? borderRadius,
    double blurSigma = 16,
    Color? fillColor,
    Color? borderColor,
    List<BoxShadow>? boxShadow,
  }) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadii.card);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fillColor ?? AppColors.glassFill,
            borderRadius: radius,
            border: Border.all(color: borderColor ?? AppColors.glassBorder),
            boxShadow: boxShadow,
          ),
          child: child,
        ),
      ),
    );
  }

  static Widget primaryButton({
    required String label,
    required VoidCallback? onTap,
    bool loading = false,
    double? width = double.infinity,
    double height = 54,
  }) =>
      SizedBox(
        width: width,
        height: height,
        child: DecoratedBox(
          decoration: AppButtonStyles.decoration(enabled: onTap != null && !loading),
          child: InkWell(
            onTap: loading ? null : onTap,
            borderRadius: AppButtonStyles.border,
            child: Center(
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(label, style: AppButtonStyles.textStyle(enabled: onTap != null)),
            ),
          ),
        ),
      );

  static Widget pageHeader(BuildContext context, String title) => Padding(
        padding: AppPadding.header,
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: AppColors.icon),
            ),
            Text(title, style: AppTextStyles.heading),
          ],
        ),
      );

  static Widget priorityBadge(String priority) {
    bool isUrgent = priority == 'Urgent';
    return Container(
      padding: AppPadding.badge,
      decoration: AppDecorations.priorityBadge(isUrgent),
      child: Text(priority, style: AppTextStyles.priorityBadge(isUrgent)),
    );
  }

  static Widget statusTag(bool isPaid) {
    final status = isPaid ? 'Paid' : 'Pending';
    return Container(
      padding: AppPadding.badge,
      decoration: AppDecorations.statusTag(isPaid),
      child: Text(status, style: AppTextStyles.statusTag(isPaid)),
    );
  }

  static Widget pageLayout({required Widget child, List<Widget>? orbs}) => Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            if (orbs != null) ...orbs,
            SafeArea(child: child),
          ],
        ),
      );
}

abstract final class AppTheme {
  /// Global dark theme assembled from the design tokens above.
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.accentBlue,
          surface: AppColors.background,
          error: AppColors.error,
          onPrimary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: AppTextStyles.inputLabel,
          hintStyle: AppTextStyles.inputHint,
          errorStyle: AppTextStyles.error,
          filled: true,
          fillColor: AppColors.glassFillInput,
          contentPadding: AppPadding.inputField,
          prefixIconColor: AppColors.icon,
          suffixIconColor: AppColors.icon,
          border: _inputBorder(),
          enabledBorder: _inputBorder(),
          focusedBorder: _inputBorder(focused: true),
          errorBorder: _inputBorder(hasError: true),
          focusedErrorBorder: _inputBorder(hasError: true, focused: true),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.link),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            textStyle: AppTextStyles.button,
            padding: AppButtonStyles.padding,
            shape: RoundedRectangleBorder(borderRadius: AppButtonStyles.border),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: Colors.transparent,
          selectedColor: AppColors.primary,
          secondarySelectedColor: AppColors.primary,
          labelStyle: const TextStyle(color: AppColors.icon),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.chip)),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) return AppColors.success;
            return null;
          }),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.background,
          titleTextStyle: AppTextStyles.heading.copyWith(fontSize: 22),
          contentTextStyle: AppTextStyles.body,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.card)),
        ),
      );

  static OutlineInputBorder _inputBorder({bool focused = false, bool hasError = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.input),
      borderSide: BorderSide(
        color: hasError
            ? AppColors.errorText
            : focused
                ? AppColors.inputFocusedBorder
                : AppColors.glassBorder,
        width: focused ? 1.4 : 1,
      ),
    );
  }
}
