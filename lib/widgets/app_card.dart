import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 24,
    this.color,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: color != null ? [color!, color!] : AppColors.cardGradient,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppColors.isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.transparent,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadow,
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );

    final content = Padding(padding: padding, child: child);

    return Container(
      margin: margin,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? Material(
              color: Colors.transparent,
              child: InkWell(onTap: onTap, child: content),
            )
          : content,
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 20, 4, 12),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primary, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}
