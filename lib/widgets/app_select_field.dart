import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class AppSelectField<T> extends StatelessWidget {
  const AppSelectField({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    required this.labelOf,
    required this.onChanged,
    this.fieldLabel,
    this.subtitleOf,
    this.searchable = false,
    this.enabled = true,
  });

  final T? value;
  final String hint;
  final List<T> items;
  final String Function(T) labelOf;
  final String? Function(T)? subtitleOf;
  final ValueChanged<T?> onChanged;
  final String? fieldLabel;
  final bool searchable;
  final bool enabled;

  Future<void> _open(BuildContext context) async {
    if (!enabled || items.isEmpty) return;
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      builder: (context) => _SelectSheet<T>(
        title: fieldLabel ?? hint,
        items: items,
        value: value,
        labelOf: labelOf,
        subtitleOf: subtitleOf,
        searchable: searchable,
      ),
    );
    if (selected != null && context.mounted) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final selectedLabel = value == null ? null : labelOf(value as T);
    final subtitle = value == null ? null : subtitleOf?.call(value as T);
    final isEnabled = enabled && items.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (fieldLabel != null) ...[
          Text(
            fieldLabel!,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Material(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: isEnabled ? () => _open(context) : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(minHeight: 52),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEnabled
                      ? AppColors.divider
                      : AppColors.divider.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedLabel ?? hint,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.2,
                            fontWeight: selectedLabel == null
                                ? FontWeight.w400
                                : FontWeight.w600,
                            color: selectedLabel == null
                                ? AppColors.textSecondary
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null && subtitle.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              height: 1.2,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isEnabled
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 26,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectSheet<T> extends StatefulWidget {
  const _SelectSheet({
    required this.title,
    required this.items,
    required this.value,
    required this.labelOf,
    this.subtitleOf,
    this.searchable = false,
  });

  final String title;
  final List<T> items;
  final T? value;
  final String Function(T) labelOf;
  final String? Function(T)? subtitleOf;
  final bool searchable;

  @override
  State<_SelectSheet<T>> createState() => _SelectSheetState<T>();
}

class _SelectSheetState<T> extends State<_SelectSheet<T>> {
  late final TextEditingController _searchController;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<T> get _visibleItems {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return widget.items;
    return widget.items.where((item) {
      final title = widget.labelOf(item).toLowerCase();
      final subtitle = widget.subtitleOf?.call(item)?.toLowerCase() ?? '';
      return title.contains(query) || subtitle.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final items = _visibleItems;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottomInset + 16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.78,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            if (widget.searchable) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _searchController,
                autofocus: false,
                onChanged: (value) => setState(() => _query = value),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Найти в списке',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Text(
                    'Ничего не найдено',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final selected = item == widget.value;
                    final subtitle = widget.subtitleOf?.call(item);
                    return Material(
                      color: selected
                          ? AppColors.primaryLight
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(item),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 13,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.labelOf(item),
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.3,
                                        fontWeight: selected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    if (subtitle != null &&
                                        subtitle.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        subtitle,
                                        style: TextStyle(
                                          fontSize: 13,
                                          height: 1.3,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (selected) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
