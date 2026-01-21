import 'package:flutter/material.dart';

class UniversalBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color? iconColor;
  final double size;

  const UniversalBackButton({
    super.key,
    this.onPressed,
    this.iconColor,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed ?? () => Navigator.of(context).pop(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: iconColor ?? const Color(0xFF1A1A1A),
            size: size,
          ),
        ),
      ),
    );
  }
}
