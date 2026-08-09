abstract final class AppValidators {
  static String? email(String? v) => 
      v != null && RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v) ? null : 'Invalid email';
  
static String? password(String? v) => 
    (v != null && v.isNotEmpty && RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$').hasMatch(v)) 
    ? null 
    : 'Min 8 chars, 1 letter, 1 number';
}
