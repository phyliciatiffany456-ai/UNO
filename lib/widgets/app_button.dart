import 'package:flutter/material.dart';

enum AppButtonVariant { primary, outline }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.variant = AppButtonVariant.primary,
    this.height = 40,
    this.fontSize = 13,
    this.borderRadius = 10,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;
  final AppButtonVariant variant;
  final double height;
  final double fontSize;
  final double borderRadius;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;
    final bool primary = variant == AppButtonVariant.primary;

    final Color bgColor = !enabled
        ? const Color(0xFF454852)
        : primary
        ? const Color(0xFFFF6A2D)
        : const Color(0xFF0E1014);

    final Color borderColor = primary
        ? const Color(0xFFFF6A2D)
        : const Color(0xFF2D313B);

    final Widget button = SizedBox(
      height: height,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (expand) return SizedBox(width: double.infinity, child: button);
    return button;
  }
}
