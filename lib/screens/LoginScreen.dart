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
  bool _obscure = true, _loading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _service.login(_email.text.trim(), _pass.text);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.background),
        child: Stack(
          children: [
            AppWidgets.glowOrb(top: -120, right: -100, size: 280, color: AppColors.violetOrb),
            AppWidgets.glowOrb(bottom: -140, left: -110, size: 320, color: AppColors.blueBrand),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: AppPadding.pageHorizontal,
                  child: AppWidgets.glassCard(
                    padding: AppPadding.cardLogin,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(gradient: AppGradients.brand, borderRadius: BorderRadius.circular(AppRadii.logo), boxShadow: [AppShadows.logo]),
                            child: const Icon(Icons.group_rounded, color: Colors.white, size: 32),
                          ),
                          const SizedBox(height: 20),
                          const Text('Welcome Back', style: AppTextStyles.heading),
                          const SizedBox(height: 8),
                          const Text('Sign in to your Roommate account', style: AppTextStyles.subtitle),
                          const SizedBox(height: 32),
                          AuthTextField(controller: _email, label: 'Email', hint: 'you@example.com', icon: Icons.alternate_email_rounded, validator: AppValidators.email),
                          const SizedBox(height: 18),
                          AuthTextField(
                            controller: _pass, label: 'Password', hint: 'Enter password', icon: Icons.lock_outline_rounded, obscureText: _obscure,
                            validator: AppValidators.password,
                            suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off, color: AppColors.icon)),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity, height: 54,
                            child: DecoratedBox(
                              decoration: AppButtonStyles.decoration(enabled: !_loading),
                              child: InkWell(
                                onTap: _loading ? null : _login,
                                child: Center(child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text('Sign In', style: AppButtonStyles.textStyle())),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?", style: AppTextStyles.subtitle),
                              TextButton(onPressed: () {}, child: const Text('Sign up', style: AppTextStyles.link)),
                            ],
                          ),
                        ],
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
}
