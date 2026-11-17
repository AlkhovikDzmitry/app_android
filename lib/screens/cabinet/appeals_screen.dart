import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../services/appeals_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/rn_button.dart';

enum AppealsSection { submission, requirements, withdraw }

const _submissionText =
    'Подача электронных обращений в государственные органы либо '
    'государственные организации осуществляется посредством государственной '
    'единой (интегрированной) республиканской информационной системы учета '
    'и обработки обращений граждан и юридических лиц обращения.бел.';

const _withdrawText =
    'Заявитель имеет право отозвать свое обращение до рассмотрения его по '
    'существу путем подачи соответствующего письменного заявления (часть '
    'первая ст.16 Закона Республики Беларусь от 18 июля 2011 г. № 300-З '
    '«Об обращениях граждан и юридических лиц»).\n\n'
    'Отзыв электронного обращения осуществляется путем подачи письменного '
    'заявления либо направления заявления в электронной форме тем же '
    'способом, которым было направлено электронное обращение '
    '(п.3 ст.25 Закона).';

class AppealsScreen extends StatelessWidget {
  const AppealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Электронные обращения'),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          24 + bikeNavBottomInset(context),
        ),
        children: [
          _AppealsItem(
            icon: Icons.send_rounded,
            title: 'Подача электронного обращения',
            onTap: () => _open(
              context,
              title: 'Подача электронного обращения',
              child: _StaticText(_submissionText),
            ),
          ),
          const SizedBox(height: 10),
          _AppealsItem(
            icon: Icons.rule_rounded,
            title: 'Требования к подаче обращений',
            onTap: () => _open(
              context,
              title: 'Требования к подаче обращений',
              child: const _ApiText(AppealsService.requirements),
            ),
          ),
          const SizedBox(height: 10),
          _AppealsItem(
            icon: Icons.undo_rounded,
            title: 'Отзыв обращения',
            onTap: () => _open(
              context,
              title: 'Отзыв обращения',
              child: _StaticText(_withdrawText),
            ),
          ),
        ],
      ),
    );
  }

  void _open(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _AppealsDetailScreen(title: title, child: child),
      ),
    );
  }
}

class _AppealsItem extends StatelessWidget {
  const _AppealsItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppealsDetailScreen extends StatelessWidget {
  const _AppealsDetailScreen({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            24 + bikeNavBottomInset(context),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _StaticText extends StatelessWidget {
  const _StaticText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
    );
  }
}

class _ApiText extends StatefulWidget {
  const _ApiText(this.loader);

  final Future<String> Function() loader;

  @override
  State<_ApiText> createState() => _ApiTextState();
}

class _ApiTextState extends State<_ApiText> {
  late Future<String> _future = widget.loader();

  void _reload() => setState(() => _future = widget.loader());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Column(
            children: [
              Text(
                snapshot.error is ApiException
                    ? (snapshot.error as ApiException).message
                    : 'Не удалось загрузить информацию',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              RNButton(
                title: 'Повторить',
                type: ButtonType.empty,
                onPress: _reload,
              ),
            ],
          );
        }
        final data = snapshot.data ?? '';
        if (data.trim().isEmpty) {
          return Text(
            'Информация пока недоступна',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }
        return HtmlWidget(
          data,
          textStyle: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        );
      },
    );
  }
}
