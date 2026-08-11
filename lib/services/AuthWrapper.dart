import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/MainNavigation.dart';
import '../screens/LoginScreen.dart';
import '../screens/SplashScreen.dart';
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
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          );
        }
        // Logged in → MainNavigation (5 tabs)
        // Not logged in → LoginScreen
        return snapshot.hasData ? const MainNavigation() : const LoginScreen();
      },
    );
  }
}