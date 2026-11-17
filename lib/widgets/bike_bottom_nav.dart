import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

const double kBikeNavHeight = 64;
const double kBikeNavBottomMargin = 12;

double bikeNavBottomInset(BuildContext context) =>
    kBikeNavHeight +
    kBikeNavBottomMargin +
    MediaQuery.viewPaddingOf(context).bottom;

/// Возвращает телу оболочки настоящий системный нижний инсет.
///
/// [Scaffold] с `extendBody` и `bottomNavigationBar` обнуляет у body не только
/// `padding.bottom`, но и `viewPadding.bottom` (см. `MediaQueryData.removePadding`).
/// Из-за этого [bikeNavBottomInset] внутри body возвращал меньше нужного, и
/// контент (карточка станций, списки) заезжал под панель навигации при
/// кнопочном управлении. Здесь восстанавливаем реальное значение, не трогая
/// `padding.bottom` — его Scaffold выставляет сам.
Widget appBodyWithNavInset(BuildContext context, Widget child) {
  final systemBottom = MediaQuery.viewPaddingOf(context).bottom;
  return Builder(
    builder: (context) {
      final media = MediaQuery.of(context);
      return MediaQuery(
        data: media.copyWith(
          viewPadding: media.viewPadding.copyWith(bottom: systemBottom),
        ),
        child: child,
      );
    },
  );
}

class BikeBottomNav extends StatelessWidget {
  const BikeBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const items = [
    (Icons.home_outlined, Icons.home_rounded, 'Главная'),
    (Icons.map_outlined, Icons.map_rounded, 'Карта'),
    (Icons.add_circle_outline, Icons.add_circle_rounded, 'Запись'),
    (
      Icons.account_balance_wallet_outlined,
      Icons.account_balance_wallet_rounded,
      'Оплата',
    ),
    (Icons.person_outline, Icons.person_rounded, 'Профиль'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? AppColors.dark.surface : AppColors.light.surface;
    final inactiveColor = isDark
        ? AppColors.dark.textSecondary
        : AppColors.light.textSecondary;
    final activeColor = isDark
        ? AppColors.dark.primary
        : AppColors.light.primary;
    final background = isDark
        ? AppColors.dark.background
        : AppColors.light.background;
    // Отступ системной навигации (кнопки или жест) держим снаружи панели:
    // иначе её фон заходит под системные кнопки и сливается с ними. Зону под
    // системными кнопками заливаем цветом фона приложения, чтобы сквозь неё
    // не просвечивал контент (карта) при кнопочном управлении.
    final systemInset = MediaQuery.viewPaddingOf(context).bottom;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, kBikeNavBottomMargin),
          child: Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: SizedBox(
              height: kBikeNavHeight,
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavItem(
                        icon: items[i].$1,
                        selectedIcon: items[i].$2,
                        label: items[i].$3,
                        selected: index == i,
                        activeColor: activeColor,
                        inactiveColor: inactiveColor,
                        onTap: () => onChanged(i),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (systemInset > 0)
          ColoredBox(
            color: background,
            child: SizedBox(height: systemInset, width: double.infinity),
          ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? activeColor : inactiveColor;
    return InkWell(
      onTap: onTap,
      splashColor: activeColor.withValues(alpha: 0.12),
      highlightColor: activeColor.withValues(alpha: 0.06),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: selected
                    ? activeColor.withValues(alpha: 0.12)
                    : const Color(0x00000000),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selected
                      ? activeColor.withValues(alpha: 0.45)
                      : const Color(0x00000000),
                ),
              ),
              child: Icon(
                selected ? selectedIcon : icon,
                size: 22,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.2,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
