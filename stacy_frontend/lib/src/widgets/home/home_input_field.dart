// class for a custom input field in the home screen
import 'package:flutter/material.dart';
import 'package:stacy_frontend/src/utilities/constants.dart';

class HomeInputField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final Icon prefixIcon;
  final Function? validator;
  final TextInputAction textInputAction;
  final Widget? suffixIcon;
  final void Function(String)? onFieldSubmitted;

  const HomeInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.keyboardType,
    required this.prefixIcon,
    required this.validator,
    required this.textInputAction,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: TextStyle(color: textPrimaryColor),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        labelStyle: TextStyle(color: textPrimaryColor),
        hintStyle: TextStyle(color: textSecondaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: tertiaryColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: secondaryColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorStyle: TextStyle(color: Colors.red.shade700),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.teal.shade50.withAlpha(128),
      ),
      validator: validator != null ? (value) => validator!(value) : null,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      obscureText: obscureText,
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
