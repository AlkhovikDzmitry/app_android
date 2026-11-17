import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/payment.dart';
import '../../services/payment_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/rn_button.dart';

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  late Future<List<PaymentHistoryGroup>> _future;

  /// Счётчик, под который история уже загружена.
  int _loadedRevision = historyRevision.value;

  @override
  void initState() {
    super.initState();
    _future = PaymentApi.instance.getHistory();
  }

  Future<void> _reload() async {
    final future = PaymentApi.instance.getHistory();
    if (!mounted) return;
    setState(() => _future = future);
    await future;
  }

  @override
  Widget build(BuildContext context) {
    // Экран живёт во вкладке и не пересоздаётся при переключении, поэтому сам по
    // себе не обновляется: после оформления заказа перечитываем список заново.
    return ValueListenableBuilder<int>(
      valueListenable: historyRevision,
      builder: (context, revision, _) {
        if (revision != _loadedRevision) {
          _loadedRevision = revision;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _reload();
          });
        }
        return _buildScaffold();
      },
    );
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('История заказов'),
        automaticallyImplyLeading: false,
        leading: AppBackButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<PaymentHistoryGroup>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final error = snapshot.error;
              final message = error is ApiException
                  ? error.message
                  : 'Не удалось загрузить историю';
              return _StateView(
                icon: Icons.error_outline_rounded,
                title: 'Не удалось загрузить',
                message: message,
                actionLabel: 'Повторить',
                onAction: _reload,
              );
            }
            final groups = snapshot.data ?? const <PaymentHistoryGroup>[];
            if (groups.isEmpty) {
              return const _StateView(
                icon: Icons.receipt_long_outlined,
                title: 'Заказов пока нет',
                message: 'Оформленные заказы появятся в этом разделе',
              );
            }
            return RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  24 + bikeNavBottomInset(context),
                ),
                children: [
                  for (final group in groups) ...[
                    _MonthHeader(title: group.monthName),
                    const SizedBox(height: 8),
                    for (final post in group.posts) ...[
                      _OrderCard(post: post),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.post});

  final PaymentHistoryItem post;

  @override
  Widget build(BuildContext context) {
    final files = post.files ?? const <PaymentFile>[];
    // Показываем и файлы без готовой ссылки: по номеру заказа и идентификатору
    // шаблона ссылка собирается сама, как в исходном приложении.
    final downloadable = files
        .where(
          (file) =>
              (file.href?.trim().isNotEmpty ?? false) ||
              (file.id != null && (post.orderId?.trim().isNotEmpty ?? false)),
        )
        .toList(growable: false);
    final status = _orderStatus(post);
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  post.serviceName ?? 'Услуга',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
              if (post.price != null) ...[
                const SizedBox(width: 10),
                Text(
                  '${post.price} руб.',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
          if (status != null) ...[
            const SizedBox(height: 8),
            _StatusChip(status: status),
          ],
          const SizedBox(height: 10),
          if (post.stationName != null)
            _Row(icon: Icons.location_on_outlined, value: post.stationName!),
          if (post.visitDate != null)
            _Row(icon: Icons.event_outlined, value: post.visitDate!),
          if (post.certNumber != null && post.certNumber!.isNotEmpty)
            _Row(
              icon: Icons.confirmation_number_outlined,
              value: post.certNumber!,
            ),
          if (post.payServiceName != null)
            _Row(
              icon: Icons.account_balance_wallet_outlined,
              value: post.payServiceName!,
            ),
          if (post.orderId != null && post.orderId!.isNotEmpty)
            _Row(icon: Icons.tag_outlined, value: 'Заказ №${post.orderId}'),
          if (downloadable.isNotEmpty) ...[
            const SizedBox(height: 4),
            AppSelectField<PaymentFile>(
              value: null,
              hint: 'Скачать документ',
              fieldLabel: 'Документы заказа',
              items: downloadable,
              labelOf: (file) => file.title ?? 'Документ',
              subtitleOf: (file) => file.href,
              searchable: downloadable.length > 5,
              onChanged: (file) {
                if (file != null) _openFile(context, post, file);
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Открывает документ заказа.
  ///
  /// Ссылка `.../doc_new/...` из истории не работает (сервер отвечает 404),
  /// поэтому адрес пересобирается на `get_report.php` с номером заказа из самой
  /// ссылки и шаблоном, подобранным по названию файла. Открывается внешним
  /// приложением: `get_report.php` отдаёт docx/pdf, а встроенное окно их не
  /// показывает.
  Future<void> _openFile(
    BuildContext context,
    PaymentHistoryItem post,
    PaymentFile file,
  ) async {
    final uri = await PaymentApi.instance.documentDownloadUri(
      href: file.href,
      title: file.title,
      templateId: file.id,
      orderId: post.orderId,
    );
    if (!context.mounted) return;
    if (uri == null) {
      _showHint(context, 'Не удалось сформировать ссылку на документ');
      return;
    }
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      _showHint(context, 'Не удалось открыть документ');
    }
  }

  void _showHint(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Состояние оплаты заказа в терминах экрана истории.
///
/// Оплата переводом и через ЕРИП подтверждается вне приложения, поэтому по
/// одному факту регистрации заказа нельзя сказать, оплачен он или нет: без
/// статуса пользователь не понимает, нужно ли ещё платить.
enum _OrderStatus {
  paid('Оплачен', Icons.check_circle_outline_rounded),
  failed('Ошибка оплаты', Icons.error_outline_rounded),
  pending('Ожидает оплаты', Icons.schedule_rounded);

  const _OrderStatus(this.label, this.icon);

  final String label;
  final IconData icon;

  Color get color => switch (this) {
    _OrderStatus.paid => AppColors.success,
    _OrderStatus.failed => AppColors.error,
    _OrderStatus.pending => AppColors.textSecondary,
  };
}

/// Статус заказа по его полю `status`.
///
/// Отсутствие статуса — это не «ожидает оплаты»: сервер может его не отдавать,
/// и тогда показывать метку без опоры на данные нельзя.
_OrderStatus? _orderStatus(PaymentHistoryItem post) {
  if (post.isPaid) return _OrderStatus.paid;
  if (post.isFailed) return _OrderStatus.failed;
  final raw = post.status?.trim();
  if (raw == null || raw.isEmpty) return null;
  return _OrderStatus.pending;
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: 14, color: status.color),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final Future<void> Function()? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 30, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.35,
                color: AppColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 20),
              RNButton(title: actionLabel!, onPress: () => onAction!()),
            ],
          ],
        ),
      ),
    );
  }
}
