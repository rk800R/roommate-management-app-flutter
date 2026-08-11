abstract final class AppValidators {
  /// RFC-style email regex — stricter than before.
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(v.trim()) ? null : 'Enter a valid email address';
  }

  /// Strong password: min 8 chars, at least 1 uppercase, 1 lowercase, 1 digit.
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Minimum 8 characters required';
    final hasUpper = RegExp(r'[A-Z]').hasMatch(v);
    final hasLower = RegExp(r'[a-z]').hasMatch(v);
    final hasDigit = RegExp(r'\d').hasMatch(v);
    if (!hasUpper || !hasLower || !hasDigit) {
      return 'Need 1 uppercase, 1 lowercase, 1 number';
    }
    return null;
  }

  /// Display name validator — min 2 characters.
  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Name is required';
    return v.trim().length >= 2 ? null : 'Min 2 characters';
  }
}