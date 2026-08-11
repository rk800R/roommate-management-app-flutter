import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/splash_screen.dart';
import '../services/app_service.dart';
import '../theme/themedata.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Show splash for 2 seconds, then reveal auth state
    Future.delayed(AppDurations.splashDelay, () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    // Phase 1: Splash screen
    if (_showSplash) {
      return const SplashScreen();
    }

    // Phase 2: Auth state listener
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: AppColors.background,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        return FutureBuilder<void>(
          future: AppService().ensureCurrentUserProfile(),
          builder: (context, profileSnapshot) {
            if (profileSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }

            if (profileSnapshot.hasError) {
              return Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: Padding(
                    padding: AppPadding.pageHorizontal,
                    child: Text(
                      'Could not load your Firebase profile. ${profileSnapshot.error}',
                      style: AppTextStyles.subtitle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}
