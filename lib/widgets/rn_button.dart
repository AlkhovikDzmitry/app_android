import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'animated_press.dart';

enum ButtonType { fill, empty }

class RNButton extends StatelessWidget {
  const RNButton({
    super.key,
    required this.title,
    required this.onPress,
    this.type = ButtonType.fill,
    this.disabled = false,
    this.customStyles,
    this.loading = false,
  });

  final String title;
  final VoidCallback onPress;
  final ButtonType type;
  final bool disabled;
  final EdgeInsetsGeometry? customStyles;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isFill = type == ButtonType.fill;
    // Цвета берём из темы, а не из статических AppColors: подписка на Theme
    // заставляет виджет перестраиваться при смене яркости системы, иначе он
    // держал бы старый цвет и старую тень после переключения темы.
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: customStyles ?? const EdgeInsets.symmetric(vertical: 8),
      child: AnimatedPress(
        enabled: !disabled && !loading,
        onTap: onPress,
        child: SizedBox(
          width: double.infinity,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 50),
            child: DecoratedBox(
              // Сплошной фон вместо градиента; тени нет ни в светлой, ни в
              // тёмной теме — кнопка плоская в обеих. Фон именно primaryButton:
              // в тёмной теме `primary` под белым текстом давал лишь 4.0:1.
              decoration: BoxDecoration(
                color: isFill ? AppColors.primaryButton : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextButton(
                onPressed: null,
                style: TextButton.styleFrom(
                  backgroundColor: isFill ? Colors.transparent : scheme.surface,
                  foregroundColor: isFill ? Colors.white : scheme.primary,
                  disabledBackgroundColor: isFill
                      ? Colors.transparent
                      : scheme.surface,
                  disabledForegroundColor: isFill
                      ? Colors.white.withValues(alpha: 0.6)
                      : scheme.primary.withValues(alpha: 0.5),
                  side: isFill
                      ? null
                      : BorderSide(
                          // Полная интенсивность: при 0.35 обводка выглядела
                          // серой. Приглушённой остаётся только заблокированная
                          // кнопка, иначе disabled выглядел бы активным.
                          color: scheme.primary.withValues(
                            alpha: disabled ? 0.35 : 1,
                          ),
                        ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: isFill ? Colors.white : scheme.primary,
                    shadows: isFill
                        ? [
                            const Shadow(
                              color: Color(0x40000000),
                              blurRadius: 1,
                              offset: Offset(0, 1),
                            ),
                          ]
                        : null,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: loading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          title,
                          key: ValueKey(title),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                            color: isFill ? Colors.white : scheme.primary,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
