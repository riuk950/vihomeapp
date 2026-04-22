import 'package:flutter/material.dart';
import 'package:vihomeapp/core/theme/app_theme.dart';

class BtnPrimary extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? elevation;

  const BtnPrimary({
    super.key,
    required this.text,
    this.onPressed,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: elevation ?? 4,
        shadowColor: primaryColor.withValues(alpha: 0.4),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}
