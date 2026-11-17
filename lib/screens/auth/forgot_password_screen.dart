import 'package:flutter/material.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/rn_button.dart';
import '../../widgets/rn_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool _emailInvalid = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    setState(() => _error = null);
    if (email.isEmpty) {
      setState(() => _emailInvalid = true);
      return;
    }
    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _emailInvalid = true);
      return;
    }
    setState(() => _emailInvalid = false);
    setState(() => _loading = true);
    try {
      await AuthService.instance.resetPassword({'email': email});
      if (mounted) setState(() => _sent = true);
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
      appBar: AppBar(title: const Text('Восстановление пароля')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              if (_sent) ...[
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Инструкция по восстановлению пароля отправлена на вашу почту',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                RNButton(
                  title: 'Вернуться ко входу',
                  onPress: () => Navigator.of(context).pop(),
                ),
              ] else ...[
                Text(
                  'Введите Email, и мы отправим инструкцию по восстановлению пароля',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                RNInput(
                  controller: _emailController,
                  hintText: 'Email',
                  showError: _emailInvalid,
                  onChanged: (_) {
                    if (_emailInvalid) setState(() => _emailInvalid = false);
                  },
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  enableSuggestions: false,
                  textCapitalization: TextCapitalization.none,
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
                RNButton(
                  title: 'Отправить',
                  onPress: _submit,
                  loading: _loading,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
