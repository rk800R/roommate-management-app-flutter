import 'package:firebase_auth/firebase_auth.dart';

/// Wraps Firebase Authentication operations.
///
/// Centralizes auth calls (signing in, signing out, reading the current user)
/// so screens and widgets never talk to `FirebaseAuth.instance` directly.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// The currently signed-in user, or `null` if signed out.
  User? get currentUser => _auth.currentUser;

  /// Signs the current user out of Firebase Authentication.
  Future<void> signOut() => _auth.signOut();

  /// Signs a user in with email and password.
  ///
  /// Throws a [FirebaseAuthException] when credentials are invalid; use
  /// [friendlyMessage] to translate the error for the user.
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Maps a [FirebaseAuthException] code to a friendly, user-facing message.
  static String friendlyMessage(FirebaseAuthException e) {
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
}
