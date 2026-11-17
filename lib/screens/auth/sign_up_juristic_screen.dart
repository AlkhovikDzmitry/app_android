import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/phone_utils.dart';
import '../../core/utils/text_utils.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/password_input.dart';
import '../../widgets/rn_button.dart';
import '../../widgets/rn_input.dart';

class SignUpJuristicScreen extends StatefulWidget {
  const SignUpJuristicScreen({super.key});

  @override
  State<SignUpJuristicScreen> createState() => _SignUpJuristicScreenState();
}

class _SignUpJuristicScreenState extends State<SignUpJuristicScreen> {
  int _step = 0;
  bool _loading = false;
  bool _sendingSms = false;
  bool _smsPrepared = false;
  int _smsCooldown = 0;
  Timer? _smsTimer;
  bool _acceptsTerms = false;
  String? _error;

  final _unp = TextEditingController();
  final _nameOrg = TextEditingController();
  final _location = TextEditingController();
  final _legalAddress = TextEditingController();
  final _familyName = TextEditingController();
  final _name = TextEditingController();
  final _patronymic = TextEditingController();
  final _workPosition = TextEditingController();
  final _workProfile = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _bankAccount = TextEditingController();
  final _bankBic = TextEditingController();
  final _bankName = TextEditingController();
  final _bankAddress = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _smsCode = TextEditingController();

  final _unpFocus = FocusNode();
  final _nameOrgFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _legalAddressFocus = FocusNode();
  final _familyNameFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _patronymicFocus = FocusNode();
  final _workPositionFocus = FocusNode();
  final _workProfileFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _bankNameFocus = FocusNode();
  final _bankAddressFocus = FocusNode();
  final _bankAccountFocus = FocusNode();
  final _bankBicFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _passwordConfirmFocus = FocusNode();
  final _smsCodeFocus = FocusNode();

  late final List<FocusNode> _stepZeroOrder = [
    _unpFocus,
    _nameOrgFocus,
    _locationFocus,
    _legalAddressFocus,
    _familyNameFocus,
    _nameFocus,
    _patronymicFocus,
    _workPositionFocus,
    _workProfileFocus,
    _emailFocus,
    _phoneFocus,
  ];
  late final List<FocusNode> _stepOneOrder = [
    _bankNameFocus,
    _bankAddressFocus,
    _bankAccountFocus,
    _bankBicFocus,
  ];
  late final List<FocusNode> _stepTwoOrder = [
    _passwordFocus,
    _passwordConfirmFocus,
  ];
  late final List<FocusNode> _allFocusNodes = [
    ..._stepZeroOrder,
    ..._stepOneOrder,
    ..._stepTwoOrder,
    _smsCodeFocus,
  ];

  void _focusNextIn(List<FocusNode> order, int index) {
    if (index + 1 < order.length) {
      order[index + 1].requestFocus();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

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

  TextEditingController _controllerFor(String field) => switch (field) {
    'unp' => _unp,
    'nameOrg' => _nameOrg,
    'location' => _location,
    'legalAddress' => _legalAddress,
    'familyName' => _familyName,
    'name' => _name,
    'patronymic' => _patronymic,
    'workPosition' => _workPosition,
    'workProfile' => _workProfile,
    'email' => _email,
    'phone' => _phone,
    'bankName' => _bankName,
    'bankAddress' => _bankAddress,
    'bankAccount' => _bankAccount,
    'bankBic' => _bankBic,
    'password' => _password,
    'passwordConfirm' => _passwordConfirm,
    'smsCode' => _smsCode,
    _ => _smsCode,
  };

  @override
  void dispose() {
    _smsTimer?.cancel();
    for (final node in _allFocusNodes) {
      node.dispose();
    }
    _unp.dispose();
    _nameOrg.dispose();
    _location.dispose();
    _legalAddress.dispose();
    _familyName.dispose();
    _name.dispose();
    _patronymic.dispose();
    _workPosition.dispose();
    _workProfile.dispose();
    _email.dispose();
    _phone.dispose();
    _bankAccount.dispose();
    _bankBic.dispose();
    _bankName.dispose();
    _bankAddress.dispose();
    _password.dispose();
    _passwordConfirm.dispose();
    _smsCode.dispose();
    super.dispose();
  }

  String? _normalizedPhone() => PhoneUtils.normalize(_phone.text);

  void _startSmsCooldown() {
    _smsTimer?.cancel();
    _smsTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_smsCooldown <= 1) {
        _smsTimer?.cancel();
        setState(() => _smsCooldown = 0);
      } else {
        setState(() => _smsCooldown--);
      }
    });
  }

  Future<void> _sendRegistrationSms({required bool initial}) async {
    if (!initial && _smsCooldown > 0) return;
    final phone = _normalizedPhone();
    if (phone == null) {
      _markInvalid('phone');
      return;
    }
    final email = _email.text.trim();
    if (email.isEmpty) {
      _markInvalid('email');
      return;
    }
    setState(() {
      _error = null;
      if (initial) {
        _loading = true;
      } else {
        _sendingSms = true;
      }
    });
    try {
      if (!_smsPrepared) {
        await AuthService.instance.register({
          'stepNumber': '04',
          'email': email,
        });
        await AuthService.instance.register({
          'stepNumber': '05',
          'phone': PhoneUtils.format(phone),
        });
      }
      await AuthService.instance.register({
        'stepNumber': '02',
        'phone': PhoneUtils.format(phone),
      });
      if (!mounted) return;
      setState(() {
        _smsPrepared = true;
        _smsCooldown = 60;
        if (initial) _step = 3;
      });
      _startSmsCooldown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Код отправлен на ${PhoneUtils.format(phone)}'),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Не удалось отправить код');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _sendingSms = false;
        });
      }
    }
  }

  String _formatCooldown(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainder.toString().padLeft(2, '0')}';
  }

  Future<void> _next() async {
    setState(() => _error = null);
    if (_step == 0) {
      _clearInvalid();
      const required = <String, String>{
        'unp': 'УНП',
        'nameOrg': 'Наименование организации',
        'location': 'Местонахождение',
        'legalAddress': 'Юридический адрес',
        'familyName': 'Фамилия',
        'name': 'Имя',
        'workPosition': 'Должность',
        'workProfile': 'Профиль деятельности',
        'email': 'Email',
        'phone': 'Телефон',
      };
      for (final field in required.keys) {
        if (_controllerFor(field).text.trim().isEmpty) _markInvalid(field);
      }
      if (_invalidFields.isNotEmpty) return;
      if (!isValidUnp(_unp.text)) {
        _markInvalid('unp');
        return;
      }
      if (_normalizedPhone() == null) {
        _markInvalid('phone');
        return;
      }
      if (!_acceptsTerms) {
        setState(() => _error = 'Необходимо согласиться с условиями');
        return;
      }
      setState(() => _step = 1);
    } else if (_step == 1) {
      _clearInvalid();
      for (final field in const [
        'bankName',
        'bankAddress',
        'bankAccount',
        'bankBic',
      ]) {
        if (_controllerFor(field).text.trim().isEmpty) _markInvalid(field);
      }
      if (_invalidFields.isNotEmpty) return;
      setState(() => _step = 2);
    } else if (_step == 2) {
      _clearInvalid();
      if (_password.text.isEmpty) _markInvalid('password');
      if (_passwordConfirm.text.isEmpty) _markInvalid('passwordConfirm');
      if (_invalidFields.isNotEmpty) return;
      if (_password.text != _passwordConfirm.text) {
        setState(() => _error = 'Пароли не совпадают');
        return;
      }
      await _sendRegistrationSms(initial: true);
    } else if (_step == 3) {
      _clearInvalid();
      if (_smsCode.text.length != 6) {
        _markInvalid('smsCode');
        return;
      }
      final phone = _normalizedPhone();
      if (phone == null) {
        _markInvalid('phone');
        return;
      }
      setState(() => _loading = true);
      try {
        await AuthService.instance.register({
          'stepNumber': '03',
          'smsCode': _smsCode.text.trim(),
          'user': {
            'acceptsTerms': _acceptsTerms,
            'email': _email.text.trim(),
            'password': _password.text,
            'workPosition': _workPosition.text.trim(),
            'workProfile': _workProfile.text.trim(),
            'legalAddress': _legalAddress.text.trim(),
            'phone': PhoneUtils.format(phone),
            'familyName': _familyName.text.trim(),
            'name': _name.text.trim(),
            'patronymic': _patronymic.text.trim(),
          },
          'organization': {
            'unp': normalizeUnp(_unp.text),
            'location': _location.text.trim(),
            'companyName': _nameOrg.text.trim(),
          },
          'bank': {
            'bankName': _bankName.text.trim(),
            'address': _bankAddress.text.trim(),
            'account': _bankAccount.text.trim(),
            'bic': _bankBic.text.trim(),
          },
        });
        if (!mounted) return;
        setState(() => _step = 4);
        await _loginAfterRegistration();
      } on ApiException catch (e) {
        if (mounted) setState(() => _error = e.message);
      } catch (_) {
        if (mounted) setState(() => _error = 'Произошла ошибка');
      } finally {
        if (mounted) setState(() => _loading = false);
      }
    }
  }

  /// Автоматический вход сразу после регистрации. Сессия одноразовая:
  /// после перезапуска приложения логин и пароль придётся ввести снова.
  Future<void> _loginAfterRegistration() async {
    if (!mounted) return;
    try {
      await context.read<AuthProvider>().login(
        login: _email.text.trim(),
        password: _password.text,
        singleSession: true,
      );
      if (!mounted) return;
      // Реквизиты, введённые здесь, сразу попадают в профиль: сразу после
      // регистрации `users/me.php` ещё не отдаёт их, и раздел «Реквизиты
      // организации» выглядел бы пустым, хотя всё заполнено. Введённые значения
      // подставляются только там, где сервер ничего не вернул.
      context.read<AuthProvider>().fillLegalRequisites(
        unp: normalizeUnp(_unp.text),
        nameOrg: _nameOrg.text.trim(),
        location: _location.text.trim(),
        legalAddress: _legalAddress.text.trim(),
        workPosition: _workPosition.text.trim(),
        workProfile: _workProfile.text.trim(),
        bankName: _bankName.text.trim(),
        bankAddress: _bankAddress.text.trim(),
        bankAccount: _bankAccount.text.trim(),
        bankBic: _bankBic.text.trim(),
      );
      if (mounted) context.go('/');
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Войдите в приложение под своим логином');
      }
    }
  }

  Future<void> _sendSms() => _sendRegistrationSms(initial: false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация юридического лица')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStepIndicator(),
                    const SizedBox(height: 24),
                    if (_step == 0) _buildOrganizationInfo(),
                    if (_step == 1) _buildBankRequisites(),
                    if (_step == 2) _buildAccountData(),
                    if (_step == 3) _buildSmsCode(),
                    if (_step == 4) _buildSuccess(),
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
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_step < 4)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: RNButton(
                  title: _step == 3 ? 'Зарегистрироваться' : 'Далее',
                  onPress: _next,
                  loading: _loading,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    const labels = ['Организация', 'Банк', 'Аккаунт', 'Код', 'Готово'];
    return Row(
      children: List.generate(5, (i) {
        final active = i <= _step;
        return Expanded(
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.divider,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: active && i < _step
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 16,
                        )
                      : Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: active
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildOrganizationInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Информация об организации',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        RNInput(
          controller: _unp,
          focusNode: _unpFocus,
          hintText: 'УНП',
          showError: _isInvalid('unp'),
          onChanged: (_) => _markValid('unp'),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 0),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _nameOrg,
          focusNode: _nameOrgFocus,
          hintText: 'Наименование организации',
          showError: _isInvalid('nameOrg'),
          onChanged: (_) => _markValid('nameOrg'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 1),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _location,
          focusNode: _locationFocus,
          hintText: 'Местонахождение',
          showError: _isInvalid('location'),
          onChanged: (_) => _markValid('location'),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 2),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _legalAddress,
          focusNode: _legalAddressFocus,
          hintText: 'Юридический адрес',
          showError: _isInvalid('legalAddress'),
          onChanged: (_) => _markValid('legalAddress'),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 3),
        ),
        const SizedBox(height: 20),
        Text(
          'Руководитель',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        RNInput(
          controller: _familyName,
          focusNode: _familyNameFocus,
          hintText: 'Фамилия',
          showError: _isInvalid('familyName'),
          onChanged: (_) => _markValid('familyName'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 4),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _name,
          focusNode: _nameFocus,
          hintText: 'Имя',
          showError: _isInvalid('name'),
          onChanged: (_) => _markValid('name'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 5),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _patronymic,
          focusNode: _patronymicFocus,
          hintText: 'Отчество',
          showError: _isInvalid('patronymic'),
          onChanged: (_) => _markValid('patronymic'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 6),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _workPosition,
          focusNode: _workPositionFocus,
          hintText: 'Должность',
          showError: _isInvalid('workPosition'),
          onChanged: (_) => _markValid('workPosition'),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 7),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _workProfile,
          focusNode: _workProfileFocus,
          hintText: 'Профиль деятельности',
          showError: _isInvalid('workProfile'),
          onChanged: (_) => _markValid('workProfile'),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 8),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _email,
          focusNode: _emailFocus,
          hintText: 'Email',
          showError: _isInvalid('email'),
          onChanged: (_) => _markValid('email'),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 9),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _phone,
          focusNode: _phoneFocus,
          hintText: '+375 XX XXX-XX-XX',
          showError: _isInvalid('phone'),
          onChanged: (_) => _markValid('phone'),
          keyboardType: TextInputType.phone,
          prefixIcon: Icons.phone_outlined,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _focusNextIn(_stepZeroOrder, 10),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          value: _acceptsTerms,
          onChanged: (v) => setState(() => _acceptsTerms = v ?? false),
          activeColor: AppColors.primary,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(
            'Согласен с условиями обработки персональных данных',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildBankRequisites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Банковские реквизиты',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        RNInput(
          controller: _bankName,
          focusNode: _bankNameFocus,
          hintText: 'Наименование банка',
          showError: _isInvalid('bankName'),
          onChanged: (_) => _markValid('bankName'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepOneOrder, 0),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _bankAddress,
          focusNode: _bankAddressFocus,
          hintText: 'Адрес банка',
          showError: _isInvalid('bankAddress'),
          onChanged: (_) => _markValid('bankAddress'),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepOneOrder, 1),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _bankAccount,
          focusNode: _bankAccountFocus,
          hintText: 'Расчётный счёт',
          showError: _isInvalid('bankAccount'),
          onChanged: (_) => _markValid('bankAccount'),
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepOneOrder, 2),
        ),
        const SizedBox(height: 8),
        RNInput(
          controller: _bankBic,
          focusNode: _bankBicFocus,
          hintText: 'БИК',
          showError: _isInvalid('bankBic'),
          onChanged: (_) => _markValid('bankBic'),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _focusNextIn(_stepOneOrder, 3),
        ),
      ],
    );
  }

  Widget _buildAccountData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Данные аккаунта',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Логином будет ваш email',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        PasswordInput(
          controller: _password,
          focusNode: _passwordFocus,
          hintText: 'Пароль',
          showError: _isInvalid('password'),
          onChanged: (_) => _markValid('password'),
          autofillHints: const [AutofillHints.newPassword],
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextIn(_stepTwoOrder, 0),
        ),
        const SizedBox(height: 8),
        PasswordInput(
          controller: _passwordConfirm,
          focusNode: _passwordConfirmFocus,
          hintText: 'Повторите пароль',
          showError: _isInvalid('passwordConfirm'),
          onChanged: (_) => _markValid('passwordConfirm'),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _focusNextIn(_stepTwoOrder, 1),
        ),
      ],
    );
  }

  Widget _buildSmsCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Подтверждение',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Введите код из SMS-сообщения',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        RNInput(
          controller: _smsCode,
          focusNode: _smsCodeFocus,
          hintText: 'Код из SMS',
          showError: _isInvalid('smsCode'),
          onChanged: (_) => _markValid('smsCode'),
          keyboardType: TextInputType.number,
          maxLength: 6,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: _sendingSms || _smsCooldown > 0 ? null : _sendSms,
          icon: _sendingSms
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.sms_outlined, size: 18),
          label: Text(
            _smsCooldown > 0
                ? 'Повторить через ${_formatCooldown(_smsCooldown)}'
                : 'Отправить код',
          ),
        ),
      ],
    );
  }

  Widget _buildSuccess() {
    return Column(
      children: [
        const SizedBox(height: 24),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
        ),
        const SizedBox(height: 20),
        Text(
          'Регистрация успешна',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Вы вошли в приложение. При следующем запуске потребуется ввести логин и пароль.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        RNButton(
          title: 'Перейти в приложение',
          onPress: () => Navigator.of(context).popUntil((r) => r.isFirst),
        ),
      ],
    );
  }
}
