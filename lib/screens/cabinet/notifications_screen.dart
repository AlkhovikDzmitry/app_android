import 'package:flutter/material.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../services/user_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/rn_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _smsEnabled = true;
  bool _emailEnabled = true;
  bool _pushEnabled = true;
  bool _loading = false;
  String? _error;

  Future<void> _save() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await UserService.instance.changeNotification({
        'notificationWay': {
          'email': _emailEnabled,
          'sms': _smsEnabled,
          'push': _pushEnabled,
        },
      });
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Произошла ошибка');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Уведомления'),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24 + bikeNavBottomInset(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _NotificationCheckbox(
                      title: 'SMS-уведомления',
                      subtitle: 'Уведомления по SMS',
                      value: _smsEnabled,
                      onChanged: (v) => setState(() => _smsEnabled = v),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _NotificationCheckbox(
                      title: 'E-mail уведомления',
                      subtitle: 'Уведомления на электронную почту',
                      value: _emailEnabled,
                      onChanged: (v) => setState(() => _emailEnabled = v),
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _NotificationCheckbox(
                      title: 'Push-уведомления',
                      subtitle: 'Уведомления в приложении',
                      value: _pushEnabled,
                      onChanged: (v) => setState(() => _pushEnabled = v),
                    ),
                  ],
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: AppColors.error, fontSize: 14),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              RNButton(title: 'Сохранить', onPress: _save, loading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCheckbox extends StatelessWidget {
  const _NotificationCheckbox({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
      value: value,
      activeColor: AppColors.primary,
      onChanged: (v) => onChanged(v ?? false),
    );
  }
}
