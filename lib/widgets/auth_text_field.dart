import 'package:flutter/material.dart';
import '../theme/themedata.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final Widget? suffixIcon;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: AppTextStyles.inputHint,
        labelStyle: AppTextStyles.inputLabel,
        prefixIcon: Icon(icon, color: AppColors.icon, size: 22),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.glassFillInput,
        contentPadding: AppPadding.inputField,
        border: _border(),
        enabledBorder: _border(),
        focusedBorder: _border(focused: true),
        errorBorder: _border(hasError: true),
        focusedErrorBorder: _border(hasError: true, focused: true),
        errorStyle: AppTextStyles.error,
      ),
    );
  }

  OutlineInputBorder _border({bool focused = false, bool hasError = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadii.input),
      borderSide: BorderSide(
        color: hasError
            ? AppColors.inputErrorBorder
            : focused
                ? AppColors.inputFocusedBorder
                : AppColors.glassBorderInput,
        width: focused ? 1.4 : 1,
      ),
    );
  }
}
