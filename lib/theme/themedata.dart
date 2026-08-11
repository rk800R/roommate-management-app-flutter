import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';

// =============================================================================
// Theme Data — single source of truth for the app's visual design tokens.
// Theme-dependent tokens use `static get` so they react to AppColors.isDark.
// =============================================================================

abstract final class AppColors {
  /// Toggle this from ThemeProvider to switch palettes.
  static bool isDark = true;

  // --- Brand & Accent (constant across themes) -------------------------------
  static const primary = Color(0xFFDA4B39);
  static const accentBlue = Color(0xFFDFB33B);
  static const violetBrand = Color(0xFF7C6BFF);
  static const blueBrand = Color(0xFF3B82F6);
  static const violetOrb = Color(0xFF6D5DF6);

  // --- Screen background & gradients (theme-dependent) -----------------------
  static const _darkBg = Color.fromARGB(255, 175, 91, 103);
  static const _lightBg = Color(0xFFF3F2EE);
  static Color get background => isDark ? _darkBg : _lightBg;
  static Color get surface => background;
  static Color get gradientStart => isDark
      ? const Color.fromARGB(255, 127, 127, 128)
      : const Color(0xFFE8E6DF);
  static Color get gradientEnd => isDark
      ? const Color.fromARGB(255, 26, 48, 16)
      : const Color(0xFFDDD9CE);

  // --- Text (theme-dependent) ------------------------------------------------
  static Color get textPrimary =>
      isDark ? Colors.white : const Color(0xFF1C1C1E);
  static Color get textSecondary =>
      isDark ? const Color(0xFF9AA3B5) : const Color(0xFF6C6C70);
  static Color get textMuted =>
      isDark ? const Color(0xFF6B7489) : const Color(0xFF9A9AA0);

  // --- Icon & status ---------------------------------------------------------
  static Color get icon =>
      isDark ? const Color(0xFF7C8A9F) : const Color(0xFF5A5A60);
  static const success = Color(0xFF5AD1A0);
  static const warning = Colors.orange;
  static const info = Color(0xFF3B82F6);
  static const error = Color(0xFFE5484D);
  static const errorAccent = Colors.redAccent;
  static const errorText = Color(0xFFFF8A8D);

  // --- Glass / surface effects (theme-dependent) -----------------------------
  static Color get glassFill =>
      isDark ? const Color(0x0DFFFFFF) : const Color(0x0D000000);
  static Color get glassFillInput =>
      isDark ? const Color(0x0FFFFFFF) : const Color(0x0F000000);
  static Color get glassBorder =>
      isDark ? const Color(0x1AFFFFFF) : const Color(0x1A000000);

  // --- Focus / selection -----------------------------------------------------
  static const inputFocusedBorder = Color(0xCC7C6BFF);
  static const link = Color(0xFF9B8CFF);

  // --- Badge & tile fills ----------------------------------------------------
  static const urgentBadgeBg = Color(0x33E5484D);

  // --- Dividers & shadows ----------------------------------------------------
  static Color get divider =>
      isDark ? const Color(0x12FFFFFF) : const Color(0x12000000);
  static const shadowBlack35 = Color(0x59330000);
  static const shadowBrand45 = Color(0x737C6BFF);
  static const shadowButton = Color(0x667C6BFF);
}

abstract final class AppGradients {
  /// Full-screen background gradient — theme-dependent.
  static LinearGradient get background => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.gradientStart, AppColors.background, AppColors.gradientEnd],
        stops: const [0.0, 0.55, 1.0],
      );

  /// Default brand gradient (violet → blue) — constant.
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.violetBrand, AppColors.blueBrand],
  );

  /// Warm brand gradient (primary red → gold) — constant.
  static const brandWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.accentBlue],
  );
}

abstract final class AppRadii {
  static const input = 16.0;
  static const button = 16.0;
  static const logo = 20.0;
  static const card = 28.0;
  static const badge = 8.0;
  static const chip = 11.0;
  static const dismissible = 15.0;
}

abstract final class AppPadding {
  static const cardLogin = EdgeInsets.all(28);
  static const inputHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const inputField = EdgeInsets.symmetric(horizontal: 16, vertical: 18);
  static const tileInner = EdgeInsets.all(16);
  static const badge = EdgeInsets.symmetric(horizontal: 10, vertical: 4);
  static const pageHorizontal = EdgeInsets.symmetric(horizontal: 20);
  static const pageList = EdgeInsets.fromLTRB(20, 0, 20, 96);
  static const header = EdgeInsets.fromLTRB(4, 8, 16, 12);
  static const bottom12 = EdgeInsets.only(bottom: 12);
  static const bottom16 = EdgeInsets.only(bottom: 16);
  static const vertical4 = EdgeInsets.symmetric(vertical: 4);
  static const right8 = EdgeInsets.only(right: 8);
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
  static const width14 = SizedBox(width: 14);
}

abstract final class AppShadows {
  static const card = BoxShadow(color: AppColors.shadowBlack35, blurRadius: 40, offset: Offset(0, 20));
  static const button = BoxShadow(color: AppColors.shadowButton, blurRadius: 20, offset: Offset(0, 8));
  static const logo = BoxShadow(color: AppColors.shadowBrand45, blurRadius: 24, offset: Offset(0, 8));
}

abstract final class AppTextStyles {
  // --- Screen-level text (theme-dependent → getters) -------------------------
  static TextStyle get heading => TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.5);
  static TextStyle get subtitle => TextStyle(fontSize: 15, color: AppColors.textSecondary);
  static TextStyle get body => TextStyle(fontSize: 14, color: AppColors.textPrimary);
  static TextStyle get sectionHeader => TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.3);
  static TextStyle get emptyState => TextStyle(fontSize: 14, color: AppColors.textSecondary);

  // --- Interactive / actions -------------------------------------------------
  static TextStyle get button => TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.3);
  static const link = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.link);

  // --- Form fields -----------------------------------------------------------
  static TextStyle get inputLabel => TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary);
  static TextStyle get inputHint => TextStyle(fontSize: 14, color: AppColors.textMuted);
  static const error = TextStyle(fontSize: 12, color: AppColors.errorText);

  // --- Summary Cards (always white text on gradient) -------------------------
  static const summaryTitle = TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white);
  static const summaryValue = TextStyle(fontSize: 28, height: 1.0, fontWeight: FontWeight.w800, letterSpacing: -0.8, color: Colors.white);
  static const summarySubtitle = TextStyle(fontSize: 12, color: Color(0xD9FFFFFF));

  // --- Activity list ---------------------------------------------------------
  static TextStyle get activityTitle => TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
  static TextStyle get activitySubtitle => TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static TextStyle get activityAmount => TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary);

  // --- Chore list ------------------------------------------------------------
  static TextStyle get choreTitle => TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary);
  static TextStyle get choreTitleCompleted => TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textMuted, decoration: TextDecoration.lineThrough);
  static TextStyle get choreSubtitle => TextStyle(fontSize: 12.5, color: AppColors.textSecondary);
  static TextStyle get choreSubtitleCompleted => TextStyle(fontSize: 12.5, color: AppColors.textMuted);
  static TextStyle get choreDate => TextStyle(fontSize: 11, color: AppColors.textSecondary);
  static TextStyle get choreDateCompleted => TextStyle(fontSize: 11, color: AppColors.textMuted);

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
  static BoxDecoration glassCard({bool hasShadow = false}) => BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: hasShadow ? const [AppShadows.card] : null,
      );

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
          BoxShadow(color: Color(0x3D000000), blurRadius: 24, offset: Offset(0, 12)),
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
            ? [BoxShadow(color: AppColors.errorAccent.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)]
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
  static const padding = EdgeInsets.symmetric(horizontal: 20, vertical: 14);
  static const border = BorderRadius.all(Radius.circular(AppRadii.input));

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

abstract final class AppWidgets {
  static Widget glowOrb({
    double? top, double? bottom, double? left, double? right,
    required double size, required Color color,
  }) =>
      Positioned(
        top: top, bottom: bottom, left: left, right: right,
        child: Container(
          width: size, height: size,
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

  /// Page header with optional back button (hidden in bottom-nav tabs).
  static Widget pageHeader(BuildContext context, String title, {bool showBack = true}) => Padding(
        padding: AppPadding.header,
        child: Row(
          children: [
            if (showBack)
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.arrow_back, color: AppColors.icon),
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
        decoration: BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            if (orbs != null) ...orbs,
            SafeArea(child: child),
          ],
        ),
      );
}

abstract final class AppTheme {
  static ThemeData get dark => _buildTheme(brightness: Brightness.dark);
  static ThemeData get light => _buildTheme(brightness: Brightness.light);

  static ThemeData _buildTheme({required Brightness brightness}) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        primary: AppColors.primary,
        secondary: AppColors.accentBlue,
        surface: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onSecondary: AppColors.textPrimary,
        onError: Colors.white,
        brightness: brightness,
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
        labelStyle: TextStyle(color: AppColors.icon),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadii.chip)),
        side: BorderSide(color: AppColors.glassBorder),
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
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.background,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.icon,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

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