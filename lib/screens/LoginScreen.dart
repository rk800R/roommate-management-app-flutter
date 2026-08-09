import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/AuthService.dart';
import '../theme/styling/appstyling.dart';

/// A modern, dark-theme login screen with a glassmorphism aesthetic.
///
/// Uses frosted, semi-transparent cards (BackdropFilter + blur) layered over
/// a deep gradient with soft glowing orbs. Email and password are validated
/// with strong regular expressions before any Firebase call is made.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // ---- Strong validation rules -------------------------------------------

  /// RFC-inspired email pattern: local@domain.tld (supports +, dots,
  /// hyphens, and multi-part TLDs).
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$",
  );

  /// Passwords must be 8+ chars and contain at least one uppercase letter,
  /// one lowercase letter, one digit, and one special character.
  /// Retained for future sign-up validation; login does not use this.
  // ignore: unused_field
  static final RegExp _passwordStrengthRegex = RegExp(
    r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()_\-+=\[\]{};:,.<>?/])\S{8,}$",
  );

  static bool _hasSpecialCharacter(String value) =>
      value.contains(RegExp(r"[!@#$%^&*()_\-+=\[\]{};:,.<>?/]"));

  /// Ordered set of password requirements shown in the live checklist.
  /// These are for future sign-up UI; login only requires a non-empty password.
  static final List<MapEntry<String, bool Function(String)>> _requirements = [
    MapEntry("At least 8 characters", (p) => p.length >= 8),
    MapEntry(
      "At least one uppercase letter",
      (p) => p.contains(RegExp("[A-Z]")),
    ),
    MapEntry(
      "At least one lowercase letter",
      (p) => p.contains(RegExp("[a-z]")),
    ),
    MapEntry("At least one number", (p) => p.contains(RegExp("[0-9]"))),
    MapEntry("At least one special character", _hasSpecialCharacter),
  ];

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(email)) {
      return 'Enter a valid email (e.g. name@example.com)';
    }
    return null;
  }

  /// Login only requires that the password field is non-empty.
  /// Strength requirements are enforced on sign-up, not login.
  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    return null;
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    // Run validation first; abort if any field fails.
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Use AuthService so Firebase is never called directly from the screen.
      // AuthWrapper reacts to the resulting authStateChanges() event and
      // navigates to HomeScreen automatically — no manual push needed.
      await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      _showError(AuthService.friendlyMessage(e));
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFE5484D),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF141B33), Color(0xFF080B16), Color(0xFF1A1030)],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Soft glowing orbs for depth behind the glass.
            AppWidgets.glowOrb(
              top: -120,
              right: -100,
              size: 280,
              color: AppColors.violetOrb,
            ),
            AppWidgets.glowOrb(
              bottom: -140,
              left: -110,
              size: 320,
              color: AppColorsExtended.blueBrand,
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: _GlassCard(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 32),
                            _buildEmailField(),
                            const SizedBox(height: 18),
                            // Single ValueListenableBuilder covers both the
                            // password field and the live requirements checklist
                            // so the checklist updates on every keystroke.
                            ValueListenableBuilder(
                              valueListenable: passwordController,
                              builder: (context, value, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildPasswordFieldInner(),
                                    const SizedBox(height: 14),
                                    _PasswordRequirements(password: value.text),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            _buildLoginButton(),
                            const SizedBox(height: 20),
                            _buildSignUpRow(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: AppGradientsExtended.brand,
            borderRadius: BorderRadius.circular(AppRadiiExtended.logo),
            boxShadow: [AppShadowsExtended.logo],
          ),
          child: const Icon(Icons.group_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 20),
        const Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to your Roommate account',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF9AA3B5), fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enableSuggestions: false,
      style: const TextStyle(color: Colors.white),
      validator: _validateEmail,
      decoration: _glassInputDecoration(
        label: 'Email',
        hint: 'you@example.com',
        icon: Icons.alternate_email_rounded,
      ),
    );
  }

  /// The inner password [TextFormField] — used inside the shared
  /// [ValueListenableBuilder] in [build] so the checklist gets the same rebuild.
  Widget _buildPasswordFieldInner() {
    return TextFormField(
      controller: passwordController,
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) => _login(),
      style: const TextStyle(color: Colors.white),
      validator: _validatePassword,
      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
      decoration:
          _glassInputDecoration(
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock_outline_rounded,
          ).copyWith(
            suffixIcon: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF9AA3B5),
              ),
            ),
          ),
    );
  }

  InputDecoration _glassInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      hintStyle: AppTextStylesExtended.inputHint,
      labelStyle: AppTextStylesExtended.inputLabel,
      prefixIcon: Icon(icon, color: AppColors.icon, size: 22),
      filled: true,
      fillColor: AppColorsExtended.glassFillInput,
      errorStyle: AppTextStylesExtended.choreDate.copyWith(
        color: AppColorsExtended.inputErrorBorder,
      ),
      contentPadding: AppPadding.inputField,
      border: _glassBorder(),
      enabledBorder: _glassBorder(),
      focusedBorder: _glassBorder(isFocused: true),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiiExtended.input),
        borderSide: const BorderSide(
          color: AppColorsExtended.inputErrorBorder,
          width: 1,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadiiExtended.input),
        borderSide: const BorderSide(
          color: AppColorsExtended.inputErrorBorder,
          width: 1.4,
        ),
      ),
    );
  }

  OutlineInputBorder _glassBorder({bool isFocused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadiiExtended.input),
      borderSide: BorderSide(
        color: isFocused
            ? AppColorsExtended.inputFocusedBorder
            : AppColorsExtended.glassBorderInput,
        width: isFocused ? 1.4 : 1,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: AppButtonStyles.decoration(enabled: !_isLoading),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppButtonStyles.border,
            onTap: _isLoading ? null : _login,
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Sign In',
                      style: AppButtonStyles.textStyle(enabled: !_isLoading),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account?", style: AppTextStyles.subtitle),
        TextButton(
          onPressed: () {
            // TODO: wire up to a SignUpScreen when implemented.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign up is coming soon')),
            );
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.link),
          child: const Text(
            'Sign up',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Presentational helpers
// ---------------------------------------------------------------------------

/// Frosted-glass container: authentic glassmorphism via backdrop blur over a
/// semi-transparent fill and a hairline border.
class _GlassCard extends StatelessWidget {
  const _GlassCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppWidgets.glassCard(
      padding: AppPadding.cardLogin,
      fillColor: AppColorsExtended.glassFillLogin,
      borderColor: AppColorsExtended.glassBorderLogin,
      blurSigma: 16,
      child: child,
    );
  }
}

/// Live-updating checklist of password strength requirements. It reacts to
/// the password as the user types by reading the current field text.
class _PasswordRequirements extends StatelessWidget {
  const _PasswordRequirements({required this.password});

  final String password;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final requirement in _LoginScreenState._requirements) ...[
          _RequirementRow(
            met: requirement.value(password),
            label: requirement.key,
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.label});

  final bool met;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = met ? const Color(0xFF5AD1A0) : const Color(0xFF6B7489);
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: met ? color.withValues(alpha: 0.15) : Colors.transparent,
            border: Border.all(color: color.withValues(alpha: 0.6)),
          ),
          child: met ? Icon(Icons.check_rounded, size: 12, color: color) : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: color,
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
