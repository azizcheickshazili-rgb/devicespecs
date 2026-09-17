import 'package:flutter/material.dart';

import '../../../../app/theme/auth_theme.dart';

/// Champ de saisie avec icône, label majuscule et style repris de la
/// maquette (fond `surfaceContainerLow`, coins légèrement arrondis).
class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onSuffixTap,
  });

  final String label;
  final IconData icon;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AuthText.labelCaps().copyWith(letterSpacing: 0.05),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AuthText.body(color: AuthColors.primary),
          cursorColor: AuthColors.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor: AuthColors.surfaceContainerLow,
            prefixIcon: Icon(icon, size: 18, color: AuthColors.secondary),
            suffixIcon: suffixIcon != null
                ? IconButton(
                    icon: Icon(
                      suffixIcon,
                      size: 18,
                      color: AuthColors.secondary,
                    ),
                    onPressed: onSuffixTap,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}
