import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/station.dart';
import '../../services/station_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/empty_data.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key, this.showHistory = false});

  /// Открыть раздел сразу с историей записей — сюда ведём после успешной записи.
  final bool showHistory;

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  late bool _showHistory = widget.showHistory;
  late Future<List<RegistrationRecord>> _upcomingFuture;
  late Future<List<RegistrationRecord>> _pastFuture;
  final Set<int> _cancelledIds = <int>{};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didUpdateWidget(covariant RegistrationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showHistory && !_showHistory) {
      _reload();
      setState(() => _showHistory = true);
    }
  }

  void _loadHistory() {
    _upcomingFuture = StationApi.instance.getRegistrationHistory(isOld: false);
    _pastFuture = StationApi.instance.getRegistrationHistory(isOld: true);
  }

  void _reload() {
    setState(_loadHistory);
  }

  void _openBooking() {
    context.push('/booking-form');
  }

  void _openHistory() {
    _reload();
    setState(() => _showHistory = true);
  }

  void _closeHistory() {
    setState(() => _showHistory = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: !_showHistory,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _showHistory) _closeHistory();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_showHistory ? 'История записей' : 'Онлайн запись'),
          automaticallyImplyLeading: false,
          leading: _showHistory
              ? AppBackButton(onPressed: _closeHistory)
              : null,
        ),
        body: _showHistory ? _buildHistory() : _buildMenu(),
      ),
    );
  }

  Widget _buildMenu() {
    return ListView(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bikeNavBottomInset(context)),
      children: [
        _MenuCard(
          icon: Icons.assignment_outlined,
          title: 'Запись на услуги и административные процедуры',
          subtitle: 'Выберите организацию, услугу и удобное время',
          onTap: _openBooking,
        ),
        const SizedBox(height: 12),
        _MenuCard(
          icon: Icons.history_rounded,
          title: 'История записей',
          subtitle: 'Просмотр предстоящих и прошедших записей',
          onTap: _openHistory,
        ),
      ],
    );
  }

  Widget _buildHistory() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                tabs: const [
                  Tab(text: 'Предстоящие'),
                  Tab(text: 'Прошедшие'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _HistoryList(
                  future: _upcomingFuture,
                  cancelledIds: _cancelledIds,
                  emptyText: 'У вас нет предстоящих записей',
                  canCancel: true,
                  onCancel: _cancel,
                  onRetry: _reload,
                ),
                _HistoryList(
                  future: _pastFuture,
                  cancelledIds: _cancelledIds,
                  emptyText: 'У вас нет прошедших записей',
                  canCancel: false,
                  onCancel: _cancel,
                  onRetry: _reload,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancel(RegistrationRecord record) async {
    final elementId = record.elementId;
    if (elementId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Не удалось определить запись для отмены'),
          ),
        );
      }
      return;
    }
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить запись?'),
        content: const Text('Вы уверены, что хотите отменить запись?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Да'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await StationApi.instance.cancelRecord(elementId);
      if (!mounted) return;
      setState(() {
        _cancelledIds.add(elementId);
        _loadHistory();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Запись отменена')));
    } on ApiException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.message)));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось отменить запись')),
        );
      }
    }
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({
    required this.future,
    required this.cancelledIds,
    required this.emptyText,
    required this.canCancel,
    required this.onCancel,
    required this.onRetry,
  });

  final Future<List<RegistrationRecord>> future;
  final Set<int> cancelledIds;
  final String emptyText;
  final bool canCancel;
  final ValueChanged<RegistrationRecord> onCancel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RegistrationRecord>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          final message = snapshot.error is ApiException
              ? (snapshot.error as ApiException).message
              : 'Не удалось загрузить записи';
          return _ErrorView(message: message, onRetry: onRetry);
        }
        final records = (snapshot.data ?? const <RegistrationRecord>[])
            .where(
              (record) =>
                  record.elementId == null ||
                  !cancelledIds.contains(record.elementId),
            )
            .toList();
        if (records.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              onRetry();
              await Future<void>.delayed(const Duration(milliseconds: 400));
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.55,
                  child: EmptyData(
                    text: emptyText,
                    icon: Icons.info_outline_rounded,
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () async => onRetry(),
          child: ListView.separated(
            padding: EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24 + bikeNavBottomInset(context),
            ),
            itemCount: records.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _HistoryCard(
              record: records[index],
              canCancel: canCancel && records[index].canCancel,
              onCancel: () => onCancel(records[index]),
            ),
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.record,
    required this.canCancel,
    required this.onCancel,
  });

  final RegistrationRecord record;
  final bool canCancel;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.stationName ?? 'Диагностическая станция',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (record.serviceName?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        record.serviceName!,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (record.dateTime?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            _HistoryInfo(icon: Icons.schedule_rounded, text: record.dateTime!),
          ],
          if (record.regNumber?.isNotEmpty == true)
            _HistoryInfo(
              icon: Icons.confirmation_number_outlined,
              text: record.regNumber!,
            ),
          if (record.vehicleName?.isNotEmpty == true)
            _HistoryInfo(
              icon: Icons.directions_car_outlined,
              text: record.vehicleName!,
            ),
          if (canCancel) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Отменить запись'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _HistoryInfo extends StatelessWidget {
  const _HistoryInfo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 25),
                ),
                const SizedBox(width: 14),
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
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
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
