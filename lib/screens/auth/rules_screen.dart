import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/theme/app_colors.dart';
import '../../services/rules_service.dart';

class RulesScreen extends StatefulWidget {
  const RulesScreen({super.key});

  @override
  State<RulesScreen> createState() => _RulesScreenState();
}

class _RulesScreenState extends State<RulesScreen> {
  static const _email = 'faq@gto.by';

  /// Подстановка вместо `%fields%`: какие данные собираются при регистрации.
  static const _fields =
      'фамилия, имя, отчество; контактный номер телефона; адрес электронной '
      'почты; наименование организации, УНП, банковские реквизиты (для '
      'юридических лиц)';

  late Future<String> _rules;

  @override
  void initState() {
    super.initState();
    _rules = RulesService.instance.getRules();
  }

  void _reload() {
    setState(() {
      _rules = RulesService.instance.getRules();
    });
  }

  Future<bool> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось открыть ссылку')),
      );
    }
    return opened;
  }

  /// Разметка с заполненным списком данных и рабочими ссылками на почту.
  ///
  /// Сервер присылает адрес обычным текстом, поэтому он превращается в ссылку
  /// `mailto:` — иначе касание по нему ничего не открывает.
  String _prepare(String html) => html
      .replaceAll('%fields%', _fields)
      .replaceAll(_email, '<a href="mailto:$_email">$_email</a>');

  String _hexColor(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Согласие на обработку персональных данных'),
      ),
      body: SafeArea(
        child: FutureBuilder<String>(
          future: _rules,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _RulesError(
                message: snapshot.error.toString(),
                onRetry: _reload,
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.splashMid,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.privacy_tip_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  HtmlWidget(
                    _prepare(snapshot.data ?? ''),
                    onTapUrl: _openUrl,
                    textStyle: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                    customStylesBuilder: (element) {
                      if (element.localName == 'a') {
                        return {
                          'color': _hexColor(AppColors.primary),
                          'text-decoration': 'underline',
                        };
                      }
                      return null;
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RulesError extends StatelessWidget {
  const _RulesError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}
