import 'package:flutter/material.dart';
import '../services/app_service.dart';
import '../services/validators.dart';
import '../theme/themedata.dart';
import '../widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _service = AppService();
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  bool _obscure = true, _loading = false, _isSignUp = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isSignUp) {
        await _service.signUp(
          _email.text.trim(),
          _pass.text,
          displayName: _name.text.trim(),
        );
      } else {
        await _service.login(_email.text.trim(), _pass.text);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isSignUp = !_isSignUp;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppWidgets.pageLayout(
        orbs: [
          AppWidgets.glowOrb(top: -120, right: -100, size: 280, color: AppColors.violetOrb),
          AppWidgets.glowOrb(bottom: -140, left: -110, size: 320, color: AppColors.blueBrand),
        ],
        child: Center(
          child: SingleChildScrollView(
            padding: AppPadding.pageHorizontal,
            child: AppWidgets.glassCard(
              padding: AppPadding.cardLogin,
              boxShadow: const [AppShadows.card],
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: AppDecorations.logoIcon(),
                      child: const Icon(Icons.group_rounded, color: Colors.white, size: 32),
                    ),
                    AppPadding.space20,
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isSignUp ? 'Create Account' : 'Welcome Back',
                        key: ValueKey(_isSignUp),
                        style: AppTextStyles.heading,
                      ),
                    ),
                    AppPadding.space8,
                    Text(
                      _isSignUp
                          ? 'Join your apartment today'
                          : 'Sign in to your RoomieSync account',
                      style: AppTextStyles.subtitle,
                    ),
                    AppPadding.space32,
                    // Name field (sign-up only)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      child: _isSignUp
                          ? Column(
                              children: [
                                AuthTextField(
                                  controller: _name,
                                  label: 'Display Name',
                                  hint: 'e.g. Alice',
                                  icon: Icons.person_outline_rounded,
                                  validator: (v) =>
                                      v != null && v.trim().length >= 2 ? null : 'Min 2 characters',
                                ),
                                AppPadding.space20,
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    AuthTextField(
                      controller: _email,
                      label: 'Email',
                      hint: 'you@example.com',
                      icon: Icons.alternate_email_rounded,
                      validator: AppValidators.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    AppPadding.space20,
                    AuthTextField(
                      controller: _pass,
                      label: 'Password',
                      hint: 'Enter password',
                      icon: Icons.lock_outline_rounded,
                      obscureText: _obscure,
                      validator: AppValidators.password,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _obscure = !_obscure),
                        icon: Icon(
                          _obscure ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.icon,
                        ),
                      ),
                    ),
                    AppPadding.space24,
                    AppWidgets.primaryButton(
                      label: _isSignUp ? 'Sign Up' : 'Sign In',
                      onTap: _submit,
                      loading: _loading,
                    ),
                    AppPadding.space20,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isSignUp ? 'Already have an account?' : "Don't have an account?",
                          style: AppTextStyles.subtitle,
                        ),
                        TextButton(
                          onPressed: _toggleMode,
                          child: Text(
                            _isSignUp ? 'Sign in' : 'Sign up',
                            style: AppTextStyles.link,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}