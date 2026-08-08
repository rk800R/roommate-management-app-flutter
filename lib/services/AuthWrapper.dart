import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/HomeScreen.dart';
import '../screens/LoginScreen.dart';
//tells if the user is logged in or not and returns the appropriate screen
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      return const HomeScreen();
    }

    return const LoginScreen();
  }
}