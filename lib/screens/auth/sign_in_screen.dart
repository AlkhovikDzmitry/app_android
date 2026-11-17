import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/storage/app_storage.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/password_input.dart';
import '../../widgets/rn_button.dart';
import '../../widgets/rn_input.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  /// Подсказки автозаполнения логина.
  ///
  /// Поле принимает и логин, и почту, поэтому подсказки обе: по одной только
  /// `username` сохранённый по почте email не предлагается, и поле приходилось
  /// заполнять заново при каждом входе.
  static const loginAutofillHints = <String>[
    AutofillHints.email,
    AutofillHints.username,
  ];

  /// Подсказка автозаполнения пароля.
  static const passwordAutofillHints = <String>[AutofillHints.password];

  /// Размер текста полей входа.
  ///
  /// Общий для логина и пароля: у email-клавиатуры набор текста рисуется
  /// своим размером, и при меньшем размере шрифта поля выглядят по-разному.
  static const _fieldFontSize = 16.0;

  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  final _loginFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _rememberMe = false;
  String? _error;
  bool _loginInvalid = false;
  bool _passwordInvalid = false;

  void _markInvalidLogin() => setState(() => _loginInvalid = true);
  void _markInvalidPassword() => setState(() => _passwordInvalid = true);

  @override
  void initState() {
    super.initState();
    _restoreRememberedCredentials();
  }

  Future<void> _restoreRememberedCredentials() async {
    final rememberMe = await AppStorage.getRememberMe();
    if (!rememberMe || !mounted) return;
    final login = await AppStorage.getLogin();
    final password = await AppStorage.getSavedPassword();
    if (!mounted) return;
    setState(() {
      _rememberMe = true;
      _loginController.text = login ?? '';
      _passwordController.text = password ?? '';
    });
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _loginFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (auth.isLoading) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _error = null;
      _loginInvalid = _loginController.text.trim().isEmpty;
      _passwordInvalid = _passwordController.text.isEmpty;
    });
    if (_loginInvalid || _passwordInvalid) return;
    try {
      await auth.login(
        login: _loginController.text.trim(),
        password: _passwordController.text,
        rememberMe: _rememberMe,
      );
      if (mounted && context.canPop()) context.pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
      final message = e.message.toLowerCase();
      if (message.contains('неверный логин') || message.contains('парол')) {
        _markInvalidPassword();
      } else {
        _markInvalidLogin();
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Произошла ошибка');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.accent],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shield_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'БЕЛТЕХОСМОТР',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Вход в личный кабинет',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    RNInput(
                      controller: _loginController,
                      focusNode: _loginFocus,
                      hintText: 'Логин или Email',
                      showError: _loginInvalid,
                      fontSize: _fieldFontSize,
                      onChanged: (_) {
                        if (_loginInvalid) {
                          setState(() => _loginInvalid = false);
                        }
                      },
                      // Email-клавиатура нужна для подсказок сохранённых
                      // адресов: на обычном текстовом поле подсказка не
                      // появляется. Размер текста выровнен по полю пароля,
                      // иначе набираемый текст выглядит крупнее соседнего.
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      autofillHints: loginAutofillHints,
                      onEditingComplete: () => _passwordFocus.requestFocus(),
                      prefixIcon: Icons.person_outline,
                    ),
                    const SizedBox(height: 12),
                    PasswordInput(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      hintText: 'Пароль',
                      showError: _passwordInvalid,
                      fontSize: _fieldFontSize,
                      onChanged: (_) {
                        if (_passwordInvalid) {
                          setState(() => _passwordInvalid = false);
                        }
                      },
                      textInputAction: TextInputAction.done,
                      autofillHints: passwordAutofillHints,
                      onSubmitted: (_) => _submit(),
                      prefixIcon: Icons.lock_outline,
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
                    style: TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) =>
                        setState(() => _rememberMe = value ?? false),
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Запомнить меня',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              RNButton(
                title: 'Войти',
                onPress: _submit,
                loading: auth.isLoading,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: () => context.push('/forgot-password'),
                child: Text(
                  'Забыли пароль?',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Нет аккаунта?',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              RNButton(
                title: 'Регистрация',
                type: ButtonType.empty,
                onPress: () => context.push('/sign-up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
