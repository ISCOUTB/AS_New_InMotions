import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isOutlined = false,
    this.enabled = true,
    this.gradientColors,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isOutlined;
  final bool enabled;
  final List<Color>? gradientColors;

  @override
  Widget build(BuildContext context) {
    final Color disabledColor = Colors.grey.shade300;
    final List<Color> colors = gradientColors ?? [AppColors.primary, AppColors.primaryDark];

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : null,
          gradient: !isOutlined && enabled ? LinearGradient(colors: colors) : null,
          borderRadius: BorderRadius.circular(16),
          border: isOutlined ? Border.all(color: Colors.white.withValues(alpha: 0.40), width: 1.5) : null,
          boxShadow: !isOutlined && enabled
              ? [
                  BoxShadow(
                    color: colors.first.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ElevatedButton(
          onPressed: enabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: isOutlined ? Colors.white.withValues(alpha: 0.10) : Colors.transparent,
            disabledBackgroundColor: disabledColor,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: isOutlined ? Colors.white : Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 8),
                Icon(icon, color: Colors.white, size: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
