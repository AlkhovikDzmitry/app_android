import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../core/api/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../models/station.dart';
import '../services/station_service.dart';

class MonthCalendar extends StatefulWidget {
  const MonthCalendar({
    super.key,
    required this.stationId,
    required this.selectedDate,
    required this.onDaySelected,
  });

  final int stationId;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDaySelected;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _month;
  StationCalendar? _calendar;
  bool _loading = false;
  String? _error;
  int _requestId = 0;

  DateTime get _minimumDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.selectedDate.year, widget.selectedDate.month);
    _load();
  }

  @override
  void didUpdateWidget(covariant MonthCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stationId != widget.stationId) {
      _month = DateTime(widget.selectedDate.year, widget.selectedDate.month);
      _calendar = null;
      _error = null;
      _load();
    }
  }

  Future<void> _load() async {
    final requestId = ++_requestId;
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final ts = _month.millisecondsSinceEpoch ~/ 1000;
      final calendar = await StationApi.instance.getCalendar(
        widget.stationId,
        ts: ts,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() => _calendar = calendar);
    } on ApiException catch (e) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _calendar = null;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _calendar = null;
        _error = 'Не удалось загрузить календарь';
      });
    } finally {
      if (mounted && requestId == _requestId) {
        setState(() => _loading = false);
      }
    }
  }

  void _changeMonth(int delta) {
    final next = DateTime(_month.year, _month.month + delta);
    final current = DateTime(DateTime.now().year, DateTime.now().month);
    if (next.isBefore(current)) return;
    setState(() {
      _month = next;
      _calendar = null;
    });
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final availableDays = <int, int>{};
    for (final day in _calendar?.days ?? const <StationCalendarDay>[]) {
      if (day.availableSlots > 0) {
        availableDays[day.dayNumber] = day.availableSlots;
      }
    }
    final useFallback = _calendar == null;
    final firstDay = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leadingBlanks = (firstDay.weekday + 6) % 7;
    final currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _loading || !_month.isAfter(currentMonth)
                        ? null
                        : () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left_rounded),
                    tooltip: 'Предыдущий месяц',
                  ),
                  Expanded(
                    child: Text(
                      _capitalize(
                        DateFormat('MMMM yyyy', 'ru_RU').format(_month),
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _loading ? null : () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right_rounded),
                    tooltip: 'Следующий месяц',
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: const ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                    .map(
                      (day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 6),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                )
              else
                GridView.builder(
                  itemCount: leadingBlanks + daysInMonth,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisExtent: 42,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemBuilder: (context, index) {
                    if (index < leadingBlanks) return const SizedBox.shrink();
                    final day = index - leadingBlanks + 1;
                    return _buildDayCell(
                      day,
                      availableDays.containsKey(day),
                      useFallback,
                      DateTime(_month.year, _month.month, day),
                    );
                  },
                ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Календарь будет доступен после повторной загрузки',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (_calendar != null && availableDays.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'есть свободные окна',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell(
    int day,
    bool hasSlots,
    bool useFallback,
    DateTime date,
  ) {
    final isPast = date.isBefore(_minimumDate);
    final isSelected = DateUtils.isSameDay(date, widget.selectedDate);
    final enabled = (hasSlots || useFallback) && !isPast;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: enabled ? () => widget.onDaySelected(date) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryButton
              : enabled
              ? AppColors.primaryLight
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryButton, width: 1.5)
              : null,
        ),
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected || enabled
                ? FontWeight.w700
                : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : enabled
                ? AppColors.primary
                : AppColors.textSecondary.withValues(alpha: 0.45),
          ),
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
