import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          onPressed: onPressed ?? (context.canPop() ? context.pop : null),
          tooltip: 'Назад',
          style: IconButton.styleFrom(
            padding: EdgeInsets.zero,
            foregroundColor: AppColors.primary,
            // Ряпь убрана: на экране оплаты кнопка не закрывает экран, а
            // переключает шаг, и splash доигрывал прямо на месте кнопки.
            splashFactory: NoSplash.splashFactory,
            highlightColor: Colors.transparent,
            overlayColor: Colors.transparent,
          ),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 19,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
