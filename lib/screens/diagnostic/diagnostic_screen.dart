import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/station.dart';
import '../../services/station_service.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/empty_data.dart';
import '../../widgets/yandex_map_view.dart';

final _regionFilter = StationFilter(
  key: 'region',
  title: 'Регионы',
  localOnly: true,
  values: const [
    StationFilterValue(id: '22', title: 'Минск'),
    StationFilterValue(id: '24', title: 'Минская область'),
    StationFilterValue(id: '23', title: 'Могилевская область'),
    StationFilterValue(id: '25', title: 'Гродненская область'),
    StationFilterValue(id: '26', title: 'Гомельская область'),
    StationFilterValue(id: '27', title: 'Витебская область'),
    StationFilterValue(id: '28', title: 'Брестская область'),
  ],
);

const _defaultFilters = [
  StationFilter(
    key: 'belto',
    title: 'Станции УП «Белтехосмотр»',
    values: [StationFilterValue(id: '10', title: 'Станции УП «Белтехосмотр»')],
  ),
  StationFilter(
    key: 'onlineRecord',
    title: 'Онлайн-запись',
    values: [StationFilterValue(id: '18', title: 'Онлайн-запись')],
  ),
];

class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({super.key, this.showMap = true});

  final bool showMap;

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  late Future<List<DiagnosticStation>> _future;
  List<StationFilter> _filters = [_regionFilter, ..._defaultFilters];
  final Map<String, Set<String>> _selectedFilters = {};
  String _query = '';
  late bool _showMap;

  @override
  void initState() {
    super.initState();
    _showMap = widget.showMap;
    _load();
  }

  void _load() {
    final apiFilters = Map<String, Set<String>>.from(_selectedFilters)
      ..remove('service')
      ..remove('category');
    _future = StationApi.instance.getStations(
      query: _query,
      filters: apiFilters,
    );
    StationApi.instance
        .getFilters()
        .then((filters) {
          if (!mounted) return;
          final byTitle = <String, StationFilter>{};
          StationFilter? apiRegion;
          for (final filter in [..._defaultFilters, ...filters]) {
            final title = _filterTitleKey(filter.title);
            if (title == 'регион' ||
                title == 'регионы' ||
                title.startsWith('регион ')) {
              if (filter.values.isNotEmpty) apiRegion = filter;
              continue;
            }
            byTitle[title] = filter;
          }
          final visibleFilters = byTitle.values.toList();
          setState(() {
            _filters = [apiRegion ?? _regionFilter, ...visibleFilters];
            _selectedFilters.removeWhere((key, value) {
              final filter = visibleFilters.where((item) => item.key == key);
              return value.isEmpty || (filter.isEmpty && key != 'region');
            });
            final regionValues = _filters.first.values
                .map((value) => value.id)
                .toSet();
            _selectedFilters['region']?.removeWhere(
              (value) => !regionValues.contains(value),
            );
          });
        })
        .catchError((_) {});
  }

  List<DiagnosticStation> _filterStations(List<DiagnosticStation> stations) {
    final query = _query.trim().toLowerCase();
    final regions = _selectedFilters['region'] ?? const <String>{};
    final services = _selectedFilters['service'] ?? const <String>{};
    final categories = _selectedFilters['category'] ?? const <String>{};

    return stations.where((station) {
      final searchable = [
        station.title ?? '',
        station.address ?? '',
        ...?station.services?.map((service) => service.title),
        ...?station.categories,
      ].join(' ').toLowerCase();
      if (query.isNotEmpty && !searchable.contains(query)) return false;
      if (regions.isNotEmpty &&
          station.regionId?.isNotEmpty == true &&
          !regions.contains(station.regionId)) {
        return false;
      }
      if (services.isNotEmpty) {
        final stationServices = station.services ?? const <StationService>[];
        if (!services.any(
          (id) => stationServices.any((service) => service.id.toString() == id),
        )) {
          return false;
        }
      }
      if (categories.isNotEmpty) {
        final stationCategories = station.categories ?? const <String>[];
        if (!categories.every(stationCategories.contains)) return false;
      }
      return true;
    }).toList();
  }

  String _filterTitleKey(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[«»"“”]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _reload() {
    setState(() => _load());
  }

  bool get _hasActiveFilters =>
      _selectedFilters.values.any((s) => s.isNotEmpty);

  void _onTabChanged(bool showMap) {
    if (showMap == _showMap) return;
    // Смена вкладки сбрасывает поиск: поле ввода живёт только на «Списке» и при
    // переключении уничтожается, а остаток старой выдачи в _query фильтровал бы
    // список дальше — вход и результаты разъезжались бы.
    final hadQuery = _query.isNotEmpty;
    setState(() {
      _showMap = showMap;
      _query = '';
      if (hadQuery) _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Диагностические станции'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: _showFilters,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryButton,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : [
                              BoxShadow(
                                color: AppColors.primaryButton.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  if (_hasActiveFilters)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE11D2E),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.background,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _ViewTabs(showMap: _showMap, onChanged: _onTabChanged),
          ),
          if (!_showMap)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _query = v.trim()),
                onSubmitted: (_) => _reload(),
                textInputAction: TextInputAction.search,
                style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'Поиск по названию или адресу',
                  hintStyle: TextStyle(color: AppColors.textSecondary),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                  ),
                  isDense: true,
                  filled: true,
                  fillColor: AppColors.cardBackground,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.divider),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<DiagnosticStation>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Не удалось загрузить станции';
                  return _ErrorView(message: message, onRetry: _reload);
                }
                final stations = _filterStations(snapshot.data ?? []);
                if (stations.isEmpty) {
                  return const EmptyData(text: 'Станции не найдены');
                }
                if (_showMap) {
                  return YandexMapView(
                    stations: stations,
                    onStationTap: (station) =>
                        context.push('/station-detail', extra: station),
                  );
                }
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        24 + bikeNavBottomInset(context),
                      ),
                      itemCount: stations.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, i) => _StationCard(
                        key: ValueKey(stations[i].id),
                        station: stations[i],
                        onDetails: () =>
                            context.push('/station-detail', extra: stations[i]),
                        onRecord: () => context.push(
                          '/booking-form',
                          extra: {'station': stations[i]},
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilters() async {
    final result = await context.push<Map<String, Set<String>>>(
      '/filter',
      extra: {'filters': _filters, 'selected': _selectedFilters},
    );
    if (result != null && mounted) {
      setState(() {
        _selectedFilters
          ..clear()
          ..addAll(result);
        _load();
      });
    }
  }
}

class _ViewTabs extends StatelessWidget {
  const _ViewTabs({required this.showMap, required this.onChanged});

  final bool showMap;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabButton(
              label: 'Карта',
              selected: showMap,
              onTap: () => onChanged(true),
            ),
          ),
          Expanded(
            child: _TabButton(
              label: 'Список',
              selected: !showMap,
              onTap: () => onChanged(false),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryButton : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected && Theme.of(context).brightness != Brightness.dark
              ? [
                  BoxShadow(
                    color: AppColors.primaryButton.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _StationCard extends StatefulWidget {
  const _StationCard({
    super.key,
    required this.station,
    required this.onDetails,
    required this.onRecord,
  });

  final DiagnosticStation station;
  final VoidCallback onDetails;
  final VoidCallback onRecord;

  @override
  State<_StationCard> createState() => _StationCardState();
}

class _StationCardState extends State<_StationCard> {
  bool _expanded = false;

  Future<void> _callPhone() async {
    final phone = widget.station.phone;
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(
      scheme: 'tel',
      path: phone.replaceAll(RegExp(r'[^+\d]'), ''),
    );
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  void _showServices() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      builder: (_) => _StationServicesSheet(station: widget.station),
    );
  }

  @override
  Widget build(BuildContext context) {
    final station = widget.station;
    final address = station.address?.trim() ?? '';
    final phone = station.phone?.trim() ?? '';
    final workTime = station.workTime?.trim() ?? '';
    final categories = station.categories ?? const <String>[];
    final services = station.services ?? const <StationService>[];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.directions_car_filled_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Название с номером: длинное переносится на вторую
                          // строку вместо уменьшения кегля — номер остаётся
                          // читаемым, а текст не сжимается до 7px.
                          Text(
                            station.displayTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              height: 1.3,
                            ),
                          ),
                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              address,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: 25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  if (address.isNotEmpty)
                    _CardInfoRow(
                      icon: Icons.location_on_outlined,
                      text: address,
                    ),
                  if (phone.isNotEmpty)
                    _CardInfoRow(
                      icon: Icons.phone_outlined,
                      text: phone,
                      textColor: AppColors.primary,
                      onTap: _callPhone,
                    ),
                  if (workTime.isNotEmpty)
                    _CardInfoRow(icon: Icons.schedule_outlined, text: workTime),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: widget.onDetails,
                      icon: const Icon(Icons.directions_car_outlined, size: 18),
                      label: const Text('Категории транспортных средств'),
                    ),
                  ),
                  if (categories.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: categories
                          .map(
                            (category) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _showServices,
                      icon: const Icon(Icons.key_outlined, size: 18),
                      label: Text(
                        services.isEmpty
                            ? 'Услуги'
                            : 'Услуги (${services.length})',
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: _buildCardActions(station),
          ),
        ],
      ),
    );
  }

  Widget _buildCardActions(DiagnosticStation station) {
    if (!station.isOnlineRecord) {
      return OutlinedButton.icon(
        onPressed: widget.onDetails,
        icon: const Icon(Icons.info_outline_rounded),
        label: const Text('Подробнее о станции'),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final detailsButton = OutlinedButton.icon(
          onPressed: widget.onDetails,
          icon: const Icon(Icons.info_outline_rounded),
          label: const Text('Подробнее'),
        );
        final recordButton = ElevatedButton.icon(
          onPressed: widget.onRecord,
          icon: const Icon(Icons.event_available_rounded),
          label: const Text('Записаться'),
        );
        if (constraints.maxWidth < 360) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [detailsButton, const SizedBox(height: 8), recordButton],
          );
        }
        return Row(
          children: [
            Expanded(child: detailsButton),
            const SizedBox(width: 10),
            Expanded(child: recordButton),
          ],
        );
      },
    );
  }
}

class _CardInfoRow extends StatelessWidget {
  const _CardInfoRow({
    required this.icon,
    required this.text,
    this.textColor,
    this.onTap,
  });

  final IconData icon;
  final String text;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: textColor ?? AppColors.textPrimary,
                decoration: onTap == null ? null : TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return content;
    return InkWell(onTap: onTap, child: content);
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StationServicesSheet extends StatelessWidget {
  const _StationServicesSheet({required this.station});

  final DiagnosticStation station;

  @override
  Widget build(BuildContext context) {
    final services = station.services ?? const <StationService>[];
    final maxHeight = MediaQuery.sizeOf(context).height * 0.7;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Услуги',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  station.displayTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (services.isEmpty)
            const _ServicesMessage(text: 'Услуги не найдены')
          else
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                itemCount: services.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final service = services[i];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.build_circle_outlined,
                            size: 19,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            service.title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (service.price != null &&
                            service.price!.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Text(
                            '${service.price} руб.',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ServicesMessage extends StatelessWidget {
  const _ServicesMessage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }
}
