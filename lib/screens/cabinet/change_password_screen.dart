import 'package:flutter/material.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/password_input.dart';
import '../../widgets/rn_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _oldPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  bool _loading = false;
  String? _error;
  final _invalidFields = <String>{};

  void _markInvalid(String field) {
    if (!_invalidFields.add(field)) return;
    setState(() {});
  }

  void _markValid(String field) {
    if (_invalidFields.remove(field)) setState(() {});
  }

  void _clearInvalid() {
    if (_invalidFields.isEmpty) return;
    setState(_invalidFields.clear);
  }

  bool _isInvalid(String field) => _invalidFields.contains(field);

  @override
  void dispose() {
    _oldPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    _oldPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    _clearInvalid();
    if (_oldPassword.text.isEmpty) _markInvalid('oldPassword');
    if (_newPassword.text.isEmpty) _markInvalid('newPassword');
    if (_confirmPassword.text.isEmpty) _markInvalid('confirmPassword');
    if (_invalidFields.isNotEmpty) return;
    if (_newPassword.text != _confirmPassword.text) {
      setState(() => _error = 'Пароли не совпадают');
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.instance.changePassword({
        'oldPassword': _oldPassword.text,
        'newPassword': _newPassword.text,
        'repeatPassword': _confirmPassword.text,
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
        title: const Text('Смена пароля'),
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
              PasswordInput(
                controller: _oldPassword,
                focusNode: _oldPasswordFocus,
                hintText: 'Текущий пароль',
                showError: _isInvalid('oldPassword'),
                onChanged: (_) => _markValid('oldPassword'),
                prefixIcon: Icons.lock_outline,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _newPasswordFocus.requestFocus(),
              ),
              const SizedBox(height: 8),
              PasswordInput(
                controller: _newPassword,
                focusNode: _newPasswordFocus,
                hintText: 'Новый пароль',
                showError: _isInvalid('newPassword'),
                onChanged: (_) => _markValid('newPassword'),
                prefixIcon: Icons.lock_outline,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
              ),
              const SizedBox(height: 8),
              PasswordInput(
                controller: _confirmPassword,
                focusNode: _confirmPasswordFocus,
                hintText: 'Повторите новый пароль',
                showError: _isInvalid('confirmPassword'),
                onChanged: (_) => _markValid('confirmPassword'),
                prefixIcon: Icons.lock_outline,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
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
                title: 'Сменить пароль',
                onPress: _submit,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
