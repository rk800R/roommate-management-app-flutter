import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'HomeScreen.dart';

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
  static final RegExp _passwordStrengthRegex = RegExp(
    r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()_\-+=\[\]{};:,.<>?/])\S{8,}$",
  );

  static bool _hasSpecialCharacter(String value) =>
      value.contains(RegExp(r"[!@#$%^&*()_\-+=\[\]{};:,.<>?/]"));

  /// Ordered set of password requirements used by both the live checklist
  /// and the final regex validator.
  static final List<MapEntry<String, bool Function(String)>> _requirements = [
    MapEntry("At least 6 characters", (p) => p.length >= 6),
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

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (!_passwordStrengthRegex.hasMatch(password)) {
      return 'Password must meet all requirements below';
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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login successful!'),
          duration: Duration(seconds: 1),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      _showError(_friendlyAuthMessage(e));
    } catch (_) {
      _showError('Something went wrong. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _friendlyAuthMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'That email address looks invalid.';
      case 'user-not-found':
        return 'No account found for this email.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Login failed (${e.code}). Please try again.';
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
      backgroundColor: const Color(0xFF080B16),
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
            const _GlowOrb(
              top: -120,
              right: -100,
              size: 280,
              color: Color(0xFF6D5DF6),
            ),
            const _GlowOrb(
              bottom: -140,
              left: -110,
              size: 320,
              color: Color(0xFF3B82F6),
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
                            _buildPasswordField(),
                            const SizedBox(height: 14),
                            _PasswordRequirements(
                              password: passwordController.text,
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
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C6BFF), Color(0xFF3B82F6)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C6BFF).withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
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

  Widget _buildPasswordField() {
    return ValueListenableBuilder(
      valueListenable: passwordController,
      builder: (context, value, _) {
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
      },
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
      hintStyle: const TextStyle(color: Color(0xFF6B7489)),
      labelStyle: const TextStyle(color: Color(0xFF9AA3B5)),
      prefixIcon: Icon(icon, color: const Color(0xFF7C8A9F), size: 22),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      errorStyle: const TextStyle(color: Color(0xFFFF8A8D), fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: _glassBorder(),
      enabledBorder: _glassBorder(),
      focusedBorder: _glassBorder(isFocused: true),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF8A8D), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF8A8D), width: 1.4),
      ),
    );
  }

  OutlineInputBorder _glassBorder({bool isFocused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: isFocused
            ? const Color(0xFF7C6BFF).withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.10),
        width: isFocused ? 1.4 : 1,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C6BFF), Color(0xFF3B82F6)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C6BFF).withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
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
                  : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
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
        const Text(
          "Don't have an account?",
          style: TextStyle(color: Color(0xFF9AA3B5), fontSize: 14),
        ),
        TextButton(
          onPressed: () {
            // TODO: wire up to a SignUpScreen when implemented.
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sign up is coming soon')),
            );
          },
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF9B8CFF)),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.055),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.size,
    required this.color,
  });

  final double? top;
  final double? bottom;
  final double? left;
  final double? right;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
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
