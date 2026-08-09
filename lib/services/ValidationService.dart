/// Validation helpers for the auth forms (login, sign-up, password reset).
///
/// Extracted from the login screen so the same email / password rules can be
/// reused anywhere without duplicating regex logic.
class ValidationService {
  ValidationService._();

  // ---- Email ---------------------------------------------------------------

  /// RFC-inspired email pattern: local@domain.tld (supports +, dots,
  /// hyphens, and multi-part TLDs).
  static final RegExp emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$",
  );

  /// Validates an email address, returning an error message or `null` if valid.
  static String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email (e.g. name@example.com)';
    }
    return null;
  }

  // ---- Password ------------------------------------------------------------

  /// Passwords must be 8+ chars and contain at least one uppercase letter,
  /// one lowercase letter, one digit, and one special character.
  static final RegExp passwordStrengthRegex = RegExp(
    r"^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#$%^&*()_\-+=\[\]{};:,.<>?/])\S{8,}$",
  );

  static bool hasSpecialCharacter(String value) =>
      value.contains(RegExp(r"[!@#$%^&*()_\-+=\[\]{};:,.<>?/]"));

  /// Ordered set of password requirements used by both the live checklist
  /// and the final regex validator.
  static final List<MapEntry<String, bool Function(String)>> requirements = [
    MapEntry('At least 8 characters', (p) => p.length >= 8),
    MapEntry(
      'At least one uppercase letter',
      (p) => p.contains(RegExp('[A-Z]')),
    ),
    MapEntry(
      'At least one lowercase letter',
      (p) => p.contains(RegExp('[a-z]')),
    ),
    MapEntry('At least one number', (p) => p.contains(RegExp('[0-9]'))),
    MapEntry('At least one special character', hasSpecialCharacter),
  ];

  /// Validates a password, returning an error message or `null` if valid.
  static String? validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (!passwordStrengthRegex.hasMatch(password)) {
      return 'Password must meet all requirements below';
    }
    return null;
  }
}
