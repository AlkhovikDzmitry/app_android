import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/payment.dart';
import '../../models/payment_flow_spec.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/empty_data.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Future<List<PaymentService>> _servicesFuture;
  late Future<List<PaymentHistoryGroup>> _historyFuture;

  /// Счётчик, под который история уже загружена.
  int _historyRevision = historyRevision.value;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _servicesFuture = PaymentApi.instance.getServices();
    _historyFuture = PaymentApi.instance.getHistory();
  }

  void _reload() {
    setState(_load);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Оплата'),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            tabs: const [
              Tab(text: 'Услуги'),
              Tab(text: 'История'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ServicesTab(
              future: _servicesFuture,
              isLegal: context.watch<AuthProvider>().isLegal,
              onRetry: _reload,
            ),
            // История загружается один раз при открытии экрана, а экран живёт во
            // вкладке и не пересоздаётся: после оплаты список оставался прежним,
            // и в «Оплатах» заказов не было, хотя в кабинете они были видны.
            // Перечитываем список по сигналу об изменении истории.
            ValueListenableBuilder<int>(
              valueListenable: historyRevision,
              builder: (context, revision, _) {
                if (revision != _historyRevision) {
                  _historyRevision = revision;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _reload();
                  });
                }
                return _HistoryTab(future: _historyFuture, onRetry: _reload);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({
    required this.future,
    required this.onRetry,
    required this.isLegal,
  });

  final Future<List<PaymentService>> future;
  final VoidCallback onRetry;
  final bool isLegal;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaymentService>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(
            message: snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Не удалось загрузить услуги',
            onRetry: onRetry,
          );
        }
        final all = snapshot.data ?? [];
        final services = all
            .where(
              (service) =>
                  PaymentFlowResolver.isVisibleFor(service, isLegal: isLegal),
            )
            .toList();
        if (services.isEmpty) {
          return const EmptyData(text: 'Услуги не найдены');
        }
        // У юрлиц услуг восемь, поэтому они выбираются из выпадающего списка, а
        // не карточками. Место оказания услуг уточняется уже в сценарии оплаты.
        if (isLegal) {
          return _LegalServicePicker(services: services);
        }
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24 + bikeNavBottomInset(context),
              ),
              itemCount: services.length,
              itemBuilder: (context, i) {
                final s = services[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.divider),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push('/payment-flow', extra: s),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.splashMid,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.payment_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s.title,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  if (s.price != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      '${s.price} руб.',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ] else ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Стоимость рассчитается на следующем шаге',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Выбор услуги для юридического лица: один выпадающий список вместо
/// карточек на каждую услугу.
class _LegalServicePicker extends StatelessWidget {
  const _LegalServicePicker({required this.services});

  final List<PaymentService> services;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        24,
        16,
        24 + bikeNavBottomInset(context),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Подпись услуги рисует сам `AppSelectField`: отдельный заголовок
              // над полем дублировал «Наименование услуги» на экране.
              AppSelectField<PaymentService>(
                value: null,
                hint: 'Выберите услугу',
                fieldLabel: 'Наименование услуги',
                items: services,
                searchable: true,
                labelOf: (service) => service.title,
                subtitleOf: (service) =>
                    service.price == null ? null : '${service.price} руб.',
                onChanged: (service) {
                  if (service == null) return;
                  context.push('/payment-flow', extra: service);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.future, required this.onRetry});

  final Future<List<PaymentHistoryGroup>> future;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaymentHistoryGroup>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorView(
            message: snapshot.error is ApiException
                ? (snapshot.error as ApiException).message
                : 'Не удалось загрузить историю',
            onRetry: onRetry,
          );
        }
        final groups = snapshot.data ?? [];
        if (groups.isEmpty) return const EmptyData(text: 'История оплат пуста');
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                16,
                8,
                16,
                24 + bikeNavBottomInset(context),
              ),
              itemCount: groups.length,
              itemBuilder: (context, i) {
                final g = groups[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
                      child: Text(
                        g.monthName,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    ...g.posts.map((p) => _HistoryCard(payment: p)),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.payment});

  final PaymentHistoryItem payment;

  @override
  Widget build(BuildContext context) {
    final date = payment.visitDate;
    final price = payment.price;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              payment.serviceName ?? 'Услуга',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              payment.isFailed
                  ? 'Статус: отклонено'
                  : payment.isPaid
                  ? 'Статус: оплачено'
                  : 'Статус: ожидает подтверждения',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: payment.isFailed
                    ? AppColors.error
                    : payment.isPaid
                    ? AppColors.success
                    : AppColors.textSecondary,
              ),
            ),
            if (payment.stationName != null) ...[
              const SizedBox(height: 5),
              Text(
                payment.stationName!,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
            if (date != null || price != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    payment.isFailed
                        ? Icons.error_outline_rounded
                        : payment.isPaid
                        ? Icons.check_circle_rounded
                        : Icons.schedule_rounded,
                    size: 17,
                    color: payment.isFailed
                        ? AppColors.error
                        : payment.isPaid
                        ? AppColors.success
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      [
                        ?date,
                        ?price == null ? null : '$price руб.',
                      ].join('  •  '),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (payment.certNumber != null ||
                payment.payServiceName != null) ...[
              const SizedBox(height: 8),
              Text(
                [
                  if (payment.certNumber != null) 'СТС: ${payment.certNumber}',
                  if (payment.payServiceName != null) payment.payServiceName!,
                ].join('  •  '),
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
            if (payment.files != null && payment.files!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: payment.files!
                    .where((file) => file.href?.isNotEmpty == true)
                    .map(
                      (file) => ActionChip(
                        avatar: Icon(
                          Icons.description_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        label: Text(file.title ?? 'Документ'),
                        onPressed: () => _openDocument(context, payment, file),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Открывает документ заказа из истории.
///
/// Ссылка `.../doc_new/...` из ответа сервера не работает (404), поэтому адрес
/// пересобирается на `get_report.php` с номером заказа и шаблоном, подобранным
/// по названию файла. Открывается внешним приложением: сервер отдаёт docx/pdf,
/// которые встроенное окно не показывает.
Future<void> _openDocument(
  BuildContext context,
  PaymentHistoryItem payment,
  PaymentFile file,
) async {
  final uri = await PaymentApi.instance.documentDownloadUri(
    href: file.href,
    title: file.title,
    templateId: file.id,
    orderId: payment.orderId,
  );
  if (!context.mounted) return;
  if (uri == null) {
    _showDocumentHint(context, 'Не удалось сформировать ссылку на документ');
    return;
  }
  final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened && context.mounted) {
    _showDocumentHint(context, 'Не удалось открыть документ');
  }
}

void _showDocumentHint(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.clearSnackBars();
  messenger.showSnackBar(SnackBar(content: Text(message)));
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
