import 'package:flutter/material.dart';
import '../theme.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final bool glowing;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const NeonCard({
    super.key,
    required this.child,
    required this.glowColor,
    this.glowing = true,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: padding,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: glowColor.withOpacity(glowing ? 0.9 : 0.25),
            width: 1.5,
          ),
          boxShadow: glowing
              ? [
                  BoxShadow(
                    color: glowColor.withOpacity(0.45),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: child,
      ),
    );
  }
}
