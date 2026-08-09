import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/HomeScreen.dart';
import '../screens/LoginScreen.dart';

/// Single source of truth for authentication state.
///
/// Listens to [FirebaseAuth.instance.authStateChanges()] and routes to:
/// - a loading indicator while the auth state is being determined,
/// - [HomeScreen] once the user is confirmed to be signed in, or
/// - [LoginScreen] when the user is signed out.
///
/// Because this widget reacts to the stream, neither LoginScreen nor
/// HomeScreen needs to manually navigate after sign-in / sign-out.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still waiting for the first auth event (Firebase is initialising).
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0D1021),
            body: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF7C6BFF),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
