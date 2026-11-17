import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/station.dart';
import '../../widgets/animated_press.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/rn_button.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({
    super.key,
    required this.filters,
    required this.selected,
  });

  final List<StationFilter> filters;
  final Map<String, Set<String>> selected;

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  late final Map<String, Set<String>> _selected;
  final Map<String, bool> _expanded = {};

  @override
  void initState() {
    super.initState();
    _selected = widget.selected.map((k, v) => MapEntry(k, Set<String>.of(v)));
    for (final f in widget.filters) {
      _expanded[f.key] = false;
    }
  }

  void _toggle(String key, String value, bool checked) {
    setState(() {
      final set = _selected.putIfAbsent(key, () => <String>{});
      if (checked) {
        set.add(value);
      } else {
        set.remove(value);
      }
      if (set.isEmpty) _selected.remove(key);
    });
  }

  void _reset() {
    setState(() => _selected.clear());
  }

  void _apply() {
    Navigator.of(context).pop(_selected);
  }

  int _countSelected(String key) => _selected[key]?.length ?? 0;

  List<StationFilter> get _quickFilters => widget.filters
      .where((filter) => filter.key == 'belto' || filter.key == 'onlineRecord')
      .toList();

  List<StationFilter> get _accordionFilters {
    final service = widget.filters.where((filter) => filter.key == 'service');
    final region = widget.filters.where((filter) => filter.key == 'region');
    return [...service, ...region];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
        title: const Text('Фильтр'),
        actions: [
          TextButton(onPressed: _reset, child: const Text('Сбросить все')),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              children: [
                ..._quickFilters.map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FilterCard(
                      child: Column(
                        children: filter.values
                            .map(
                              (value) => _CheckboxRow(
                                title: value.title,
                                checked:
                                    _selected[filter.key]?.contains(value.id) ??
                                    false,
                                onChanged: (checked) =>
                                    _toggle(filter.key, value.id, checked),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ),
                ..._accordionFilters.map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _FilterCard(
                      child: Column(
                        children: [
                          _SectionHeader(
                            icon: filter.key == 'region'
                                ? Icons.public_rounded
                                : Icons.medical_services_outlined,
                            title: filter.title,
                            count: _countSelected(filter.key),
                            expanded: _expanded[filter.key] ?? false,
                            onTap: () => setState(() {
                              _expanded[filter.key] =
                                  !(_expanded[filter.key] ?? false);
                            }),
                          ),
                          AnimatedCrossFade(
                            duration: const Duration(milliseconds: 200),
                            crossFadeState: (_expanded[filter.key] ?? false)
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            firstChild: const SizedBox(width: double.infinity),
                            secondChild: Column(
                              children: filter.values
                                  .map(
                                    (value) => _CheckboxRow(
                                      title: value.title,
                                      checked:
                                          _selected[filter.key]?.contains(
                                            value.id,
                                          ) ??
                                          false,
                                      onChanged: (checked) => _toggle(
                                        filter.key,
                                        value.id,
                                        checked,
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              16 + bikeNavBottomInset(context),
            ),
            child: RNButton(title: 'Применить', onPress: _apply),
          ),
        ],
      ),
    );
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: child,
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  const _CheckboxRow({
    required this.title,
    required this.checked,
    required this.onChanged,
  });

  final String title;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: () => onChanged(!checked),
      scale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: checked,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.expanded,
    required this.onTap,
    this.icon,
  });

  final IconData? icon;
  final String title;
  final int count;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: onTap,
      scale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.primary, size: 21),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Выбрано: $count',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: expanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutBack,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary,
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
