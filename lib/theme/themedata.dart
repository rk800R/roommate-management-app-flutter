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
  static const primary = Color(0xFFFF6B4A);
  static const accentBlue = Color(0xFFF2B84B);
  static const violetBrand = Color(0xFF7D6BFF);
  static const blueBrand = Color(0xFF4FA3FF);
  static const violetOrb = Color(0xFF7D6BFF);

  // --- Screen background & gradients (theme-dependent) -----------------------
  static const _darkBg = Color(0xFF11151F);
  static const _lightBg = Color(0xFFF7F5F0);
  static Color get background => isDark ? _darkBg : _lightBg;
  static Color get surface =>
      isDark ? const Color(0xFF171D29) : const Color(0xFFFFFFFF);
  static Color get gradientStart =>
      isDark ? const Color(0xFF182033) : const Color(0xFFFFFBF4);
  static Color get gradientEnd =>
      isDark ? const Color(0xFF0E1118) : const Color(0xFFEDE8DD);

  // --- Text (theme-dependent) ------------------------------------------------
  static Color get textPrimary =>
      isDark ? const Color(0xFFF6F8FB) : const Color(0xFF20242D);
  static Color get textSecondary =>
      isDark ? const Color(0xFFB2BAC8) : const Color(0xFF626873);
  static Color get textMuted =>
      isDark ? const Color(0xFF778195) : const Color(0xFF8E929B);

  // --- Icon & status ---------------------------------------------------------
  static Color get icon =>
      isDark ? const Color(0xFFA7B0C1) : const Color(0xFF5D6470);
  static const success = Color(0xFF42C897);
  static const warning = Color(0xFFF0A83A);
  static const info = Color(0xFF3B82F6);
  static const error = Color(0xFFE5484D);
  static const errorAccent = Colors.redAccent;
  static const errorText = Color(0xFFFF8A8D);

  // --- Glass / surface effects (theme-dependent) -----------------------------
  static Color get glassFill =>
      isDark ? const Color(0x1FFFFFFF) : const Color(0xF7FFFFFF);
  static Color get glassFillInput =>
      isDark ? const Color(0x29FFFFFF) : const Color(0xFFFFFFFF);
  static Color get glassBorder =>
      isDark ? const Color(0x24FFFFFF) : const Color(0x1A20242D);

  // --- Focus / selection -----------------------------------------------------
  static const inputFocusedBorder = Color(0xCCFF6B4A);
  static const link = Color(0xFFFF8A68);

  // --- Badge & tile fills ----------------------------------------------------
  static const urgentBadgeBg = Color(0x33E5484D);

  // --- Dividers & shadows ----------------------------------------------------
  static Color get divider =>
      isDark ? const Color(0x1FFFFFFF) : const Color(0x1A20242D);
  static const shadowBlack35 = Color(0x40000000);
  static const shadowBrand45 = Color(0x66FF6B4A);
  static const shadowButton = Color(0x4DFF6B4A);
}

abstract final class AppGradients {
  /// Full-screen background gradient — theme-dependent.
  static LinearGradient get background => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.gradientStart,
      AppColors.background,
      AppColors.gradientEnd,
    ],
    stops: const [0.0, 0.55, 1.0],
  );

  /// Default brand gradient (violet → blue) — constant.
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.accentBlue],
  );

  /// Warm brand gradient (primary red → gold) — constant.
  static const brandWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.violetBrand, AppColors.blueBrand],
  );
}

abstract final class AppRadii {
  static const input = 8.0;
  static const button = 8.0;
  static const logo = 12.0;
  static const tile = 8.0;
  static const bubble = 14.0;
  static const card = 8.0;
  static const badge = 8.0;
  static const chip = 8.0;
  static const dismissible = 8.0;

  // --- Component Sizes ---
  static const actionItemHeight = 62.0;
  static const actionIconSize = 26.0;
  static const splashIconSize = 48.0;
  static const splashIconContainerSize = 96.0;
  static const avatarTiny = 30.0;
  static const avatarSmall = 22.0;
  static const avatarDefault = 48.0;
  static const avatarLarge = 96.0;
  static const logoSmall = 32.0;
  static const logoSmallContainer = 64.0;

  static const chatroomIconSize = 22.0;
  static const chatroomIconContainerSize = 44.0;

  static const summaryIconSize = 19.0;
  static const summaryIconContainerSize = 34.0;
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
  static const bubbleItem = EdgeInsets.only(bottom: 10);
  static const messageBubble = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 10,
  );
  static const composer = EdgeInsets.fromLTRB(12, 4, 12, 8);
  static const composerInner = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 6,
  );
  static const vertical4 = EdgeInsets.symmetric(vertical: 4);
  static const top8 = EdgeInsets.only(top: 8);
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

  // --- Shared Layouts ---
  static const actionGap = 16.0;
  static const actionIconGap = 10.0;
  static const messageAvatarGap = 8.0;
  static const rowGap = 16.0;
}

abstract final class AppShadows {
  static const card = BoxShadow(
    color: AppColors.shadowBlack35,
    blurRadius: 24,
    offset: Offset(0, 14),
  );
  static const button = BoxShadow(
    color: AppColors.shadowButton,
    blurRadius: 16,
    offset: Offset(0, 8),
  );
  static const logo = BoxShadow(
    color: AppColors.shadowBrand45,
    blurRadius: 18,
    offset: Offset(0, 8),
  );
}

abstract final class AppTextStyles {
  // --- Screen-level text (theme-dependent → getters) -------------------------
  static TextStyle get heading => TextStyle(
    fontSize: 28,
    height: 1.08,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );
  static TextStyle get subtitle =>
      TextStyle(fontSize: 15, height: 1.35, color: AppColors.textSecondary);
  static TextStyle get body =>
      TextStyle(fontSize: 14, height: 1.35, color: AppColors.textPrimary);
  static TextStyle get sectionHeader => TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static TextStyle get emptyState =>
      TextStyle(fontSize: 15, height: 1.35, color: AppColors.textSecondary);

  // --- Interactive / actions -------------------------------------------------
  static const button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  static const link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.link,
  );

  // --- Form fields -----------------------------------------------------------
  static TextStyle get inputLabel => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  static TextStyle get inputHint =>
      TextStyle(fontSize: 14, color: AppColors.textMuted);
  static const error = TextStyle(fontSize: 12, color: AppColors.errorText);

  // --- Summary Cards (always white text on gradient) -------------------------
  static const summaryTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  static const summaryValue = TextStyle(
    fontSize: 27,
    height: 1.0,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );
  static const summarySubtitle = TextStyle(
    fontSize: 12,
    color: Color(0xD9FFFFFF),
  );

  // --- Activity list ---------------------------------------------------------
  static TextStyle get activityTitle => TextStyle(
    fontSize: 14.5,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static TextStyle get activitySubtitle =>
      TextStyle(fontSize: 12, color: AppColors.textSecondary);
  static TextStyle get activityAmount => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  // --- Chore list ------------------------------------------------------------
  static TextStyle get choreTitle => TextStyle(
    fontSize: 15,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  static TextStyle get choreTitleCompleted => TextStyle(
    fontSize: 15,
    height: 1.25,
    fontWeight: FontWeight.w700,
    color: AppColors.textMuted,
    decoration: TextDecoration.lineThrough,
  );
  static TextStyle get choreSubtitle =>
      TextStyle(fontSize: 12.5, color: AppColors.textSecondary);
  static TextStyle get choreDate =>
      TextStyle(fontSize: 11, color: AppColors.textSecondary);

  // --- Avatars & mini badges ---------------------------------------------------
  static TextStyle avatarInitial(
    double fontSize, {
    FontWeight fontWeight = FontWeight.w700,
  }) => TextStyle(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: Colors.white,
  );
  static const smallBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
  );

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

  // --- Special Screen styles ---
  static TextStyle get splashTitle => heading.copyWith(fontSize: 34);
}

abstract final class AppDecorations {
  static BoxDecoration actionTile() => BoxDecoration(
    color: AppColors.glassFillInput,
    borderRadius: BorderRadius.circular(AppRadii.tile),
    border: Border.all(color: AppColors.glassBorder),
    boxShadow: AppColors.isDark ? null : const [AppShadows.card],
  );

  static BoxDecoration messageBubble({required bool isMine}) => BoxDecoration(
    gradient: isMine ? AppGradients.brand : null,
    color: isMine ? null : AppColors.glassFillInput,
    borderRadius: BorderRadius.only(
      topLeft: const Radius.circular(AppRadii.bubble),
      topRight: const Radius.circular(AppRadii.bubble),
      bottomLeft: Radius.circular(isMine ? AppRadii.bubble : 4),
      bottomRight: Radius.circular(isMine ? 4 : AppRadii.bubble),
    ),
    border: isMine ? null : Border.all(color: AppColors.glassBorder),
  );

  static BoxDecoration inputField({
    bool focused = false,
    bool hasError = false,
  }) => BoxDecoration(
    color: AppColors.glassFillInput,
    borderRadius: BorderRadius.circular(AppRadii.input),
    border: Border.all(
      color: hasError
          ? AppColors.errorText
          : focused
          ? AppColors.inputFocusedBorder
          : AppColors.glassBorder,
    ),
  );

  static BoxDecoration summaryCard(Gradient gradient) => BoxDecoration(
    borderRadius: BorderRadius.circular(AppRadii.card),
    gradient: gradient,
    boxShadow: const [
      BoxShadow(
        color: Color(0x33000000),
        blurRadius: 18,
        offset: Offset(0, 10),
      ),
    ],
  );

  static BoxDecoration summaryIcon() => BoxDecoration(
    color: Colors.white.withValues(alpha: 0.18),
    borderRadius: BorderRadius.circular(10),
  );

  static BoxDecoration statusTag(bool isPaid) => BoxDecoration(
    color: (isPaid ? AppColors.success : AppColors.warning).withValues(
      alpha: 0.2,
    ),
    borderRadius: BorderRadius.circular(AppRadii.badge),
    border: Border.all(
      color: isPaid ? AppColors.success : AppColors.warning,
      width: 1,
    ),
  );

  static BoxDecoration priorityBadge(bool isUrgent) => BoxDecoration(
    color: (isUrgent ? AppColors.warning : AppColors.info).withValues(
      alpha: 0.2,
    ),
    borderRadius: BorderRadius.circular(AppRadii.badge),
    border: Border.all(
      color: isUrgent ? AppColors.errorAccent : AppColors.blueBrand,
      width: 1,
    ),
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

  static BoxDecoration logoIconSmall() => BoxDecoration(
    gradient: AppGradients.brand,
    borderRadius: BorderRadius.circular(AppRadii.logo),
    boxShadow: const [AppShadows.logo],
  );
}

abstract final class AppDurations {
  static const splash = Duration(milliseconds: 1400);
  static const splashDelay = Duration(seconds: 2);
  static const authToggle = Duration(milliseconds: 300);
  static const authExpand = Duration(milliseconds: 250);
  static const fast = Duration(milliseconds: 200);
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
    color: enabled ? Colors.white : AppColors.textMuted,
  );
}

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
    child: IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withValues(alpha: 0.14),
              color.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    ),
  );

  static Widget userAvatar({
    required String initial,
    double size = 48,
    double? fontSize,
    List<BoxShadow>? boxShadow,
    Border? border,
  }) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: AppGradients.brand,
      shape: BoxShape.circle,
      boxShadow: boxShadow,
      border: border,
    ),
    child: Center(
      child: Text(
        initial.isNotEmpty ? initial[0].toUpperCase() : '?',
        style: AppTextStyles.avatarInitial(fontSize ?? size * 0.42),
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
            boxShadow:
                boxShadow ??
                (AppColors.isDark ? null : const [AppShadows.card]),
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
  }) => SizedBox(
    width: width,
    height: height,
    child: Material(
      color: Colors.transparent,
      child: Ink(
        decoration: AppButtonStyles.decoration(
          enabled: onTap != null && !loading,
        ),
        child: InkWell(
          onTap: loading ? null : onTap,
          borderRadius: AppButtonStyles.border,
          child: Center(
            child: loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    label,
                    style: AppButtonStyles.textStyle(enabled: onTap != null),
                  ),
          ),
        ),
      ),
    ),
  );

  /// Page header with optional back button (hidden in bottom-nav tabs).
  static Widget pageHeader(
    BuildContext context,
    String title, {
    bool showBack = true,
  }) => Padding(
    padding: AppPadding.header,
    child: Row(
      children: [
        if (showBack)
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back, color: AppColors.icon),
          ),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.heading,
          ),
        ),
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

  static Widget pageLayout({required Widget child, List<Widget>? orbs}) =>
      Container(
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
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: ColorScheme(
        primary: AppColors.primary,
        secondary: AppColors.accentBlue,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSurface: AppColors.textPrimary,
        onSecondary: Colors.white,
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
        backgroundColor: AppColors.glassFillInput,
        selectedColor: AppColors.primary,
        secondarySelectedColor: AppColors.primary,
        labelStyle: TextStyle(color: AppColors.icon),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.chip),
        ),
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
        backgroundColor: AppColors.surface,
        titleTextStyle: AppTextStyles.heading.copyWith(fontSize: 22),
        contentTextStyle: AppTextStyles.body,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.icon,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  static OutlineInputBorder _inputBorder({
    bool focused = false,
    bool hasError = false,
  }) {
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
