import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/phone_utils.dart';
import '../../core/utils/text_utils.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/rn_button.dart';
import '../../widgets/rn_input.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _lastName = TextEditingController();
  final _name = TextEditingController();
  final _secondName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _legalName = TextEditingController();
  final _unp = TextEditingController();
  final _legalRegion = TextEditingController();
  final _legalAddress = TextEditingController();
  final _workPosition = TextEditingController();
  final _workProfile = TextEditingController();
  final _bankName = TextEditingController();
  final _bankAddress = TextEditingController();
  final _bankAccount = TextEditingController();
  final _bankBic = TextEditingController();

  final _lastNameFocus = FocusNode();
  final _nameFocus = FocusNode();
  final _secondNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _legalNameFocus = FocusNode();
  final _unpFocus = FocusNode();
  final _legalRegionFocus = FocusNode();
  final _legalAddressFocus = FocusNode();
  final _workPositionFocus = FocusNode();
  final _workProfileFocus = FocusNode();
  final _bankNameFocus = FocusNode();
  final _bankAddressFocus = FocusNode();
  final _bankAccountFocus = FocusNode();
  final _bankBicFocus = FocusNode();

  final _scrollController = ScrollController();
  final _fieldKeys = <String, GlobalKey>{};

  bool _loading = false;
  bool _profileLoaded = false;
  bool _profileRefreshRequested = false;
  String? _error;
  UserProfile? _profile;

  bool get _isLegal => _profile?.isLegal ?? false;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profileLoaded) return;
    final profile = context.watch<AuthProvider>().profile;
    // Реквизиты, введённые при регистрации юрлица, появляются в `users/me.php`
    // не сразу: сразу после регистрации профиль приходит уже, но без них, и
    // раздел выглядит пустым. Если профиль есть, а УНП в нём нет — это тот самый
    // случай, и профиль запрашивается заново.
    final needsRequisites =
        profile != null && profile.isLegal && (profile.unp ?? '').isEmpty;
    if (profile == null || needsRequisites) {
      if (needsRequisites && !_profileRefreshRequested) {
        _profileRefreshRequested = true;
        // Форма заполняется данными, которые уже есть, а после обновления
        // профиля заполняется заново более свежими.
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (!mounted) return;
          try {
            await context.read<AuthProvider>().refreshProfile();
          } catch (_) {}
          if (!mounted) return;
          setState(() => _profileLoaded = false);
        });
      }
      if (profile == null) return;
    }
    _fillFrom(profile);
    _profileLoaded = true;
  }

  /// Заполняет форму значениями профиля.
  void _fillFrom(UserProfile profile) {
    _profile = profile;
    _lastName.text = profile.lastName ?? '';
    _name.text = profile.name ?? '';
    _secondName.text = profile.secondName ?? '';
    _email.text = profile.email ?? '';
    _phone.text = profile.phone ?? '';
    _legalName.text = profile.legalName ?? profile.nameOrg ?? '';
    _unp.text = profile.unp ?? '';
    _legalRegion.text = profile.legalRegion ?? profile.location ?? '';
    _legalAddress.text = profile.legalAddress ?? '';
    _workPosition.text = profile.workPosition ?? profile.face ?? '';
    _workProfile.text = profile.workProfile ?? profile.mainDoc ?? '';
    _bankName.text = profile.bankName ?? '';
    _bankAddress.text = profile.bankAddress ?? '';
    _bankAccount.text = profile.bankAccount ?? '';
    _bankBic.text = profile.bankBic ?? '';
  }

  @override
  void dispose() {
    _lastName.dispose();
    _name.dispose();
    _secondName.dispose();
    _email.dispose();
    _phone.dispose();
    _legalName.dispose();
    _unp.dispose();
    _legalRegion.dispose();
    _legalAddress.dispose();
    _workPosition.dispose();
    _workProfile.dispose();
    _bankName.dispose();
    _bankAddress.dispose();
    _bankAccount.dispose();
    _bankBic.dispose();
    _lastNameFocus.dispose();
    _nameFocus.dispose();
    _secondNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _legalNameFocus.dispose();
    _unpFocus.dispose();
    _legalRegionFocus.dispose();
    _legalAddressFocus.dispose();
    _workPositionFocus.dispose();
    _workProfileFocus.dispose();
    _bankNameFocus.dispose();
    _bankAddressFocus.dispose();
    _bankAccountFocus.dispose();
    _bankBicFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  GlobalKey _keyFor(String id) => _fieldKeys.putIfAbsent(id, GlobalKey.new);

  void _focusNext(String id, FocusNode? next) {
    final key = _fieldKeys[id];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: 0.15,
      );
    }
    if (next != null) {
      next.requestFocus();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    if (!_profileLoaded) {
      setState(() => _error = 'Профиль ещё загружается. Повторите попытку.');
      return;
    }
    final lastName = _lastName.text.trim();
    final name = _name.text.trim();
    final secondName = _secondName.text.trim();
    final email = _email.text.trim();
    final phone = _phone.text.trim();
    _clearInvalid();
    if (lastName.isEmpty) _markInvalid('lastName');
    if (name.isEmpty) _markInvalid('name');
    if (email.isEmpty) _markInvalid('email');
    if (phone.isEmpty) _markInvalid('phone');
    if (_isLegal) {
      if (_legalName.text.trim().isEmpty) _markInvalid('legalName');
      if (normalizeUnp(_unp.text).isEmpty) _markInvalid('unp');
    }
    if (_invalidFields.isNotEmpty) return;
    if (!email.contains('@')) {
      _markInvalid('email');
      return;
    }
    if (PhoneUtils.normalize(phone) == null) {
      _markInvalid('phone');
      return;
    }
    final unp = normalizeUnp(_unp.text);
    if (_isLegal && unp.isNotEmpty && unp.length != 9) {
      _markInvalid('unp');
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final payload = <String, dynamic>{
        'familyName': lastName,
        'name': name,
        'patronymic': secondName,
        'email': email,
        if (_isLegal) ...{
          'legalPhone': PhoneUtils.format(phone),
          'legalName': _legalName.text.trim(),
          'unp': unp,
          'legalRegion': _legalRegion.text.trim(),
          'legalAddress': _legalAddress.text.trim(),
          'workPosition': _workPosition.text.trim(),
          'workProfile': _workProfile.text.trim(),
          'bankName': _bankName.text.trim(),
          'bankAddress': _bankAddress.text.trim(),
          'bankAccount': _bankAccount.text.trim(),
          'bankBic': _bankBic.text.trim(),
        } else
          'phone': PhoneUtils.format(phone),
      };
      await UserService.instance.editProfile(payload);
      await auth.refreshProfile();
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Не удалось сохранить профиль');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isLegal ? 'Реквизиты организации' : 'Редактировать профиль',
        ),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            24 + bikeNavBottomInset(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_isLegal) _buildLegalSection() else _buildPersonalSection(),
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
              const SizedBox(height: 20),
              RNButton(
                title: 'Сохранить',
                onPress: _submit,
                loading: _loading,
                disabled: !_profileLoaded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    ),
  );

  Widget _buildPersonalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RNInput(
          key: _keyFor('lastName'),
          controller: _lastName,
          focusNode: _lastNameFocus,
          hintText: 'Фамилия',
          showError: _isInvalid('lastName'),
          onChanged: (_) => _markValid('lastName'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('lastName', _nameFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('name'),
          controller: _name,
          focusNode: _nameFocus,
          hintText: 'Имя',
          showError: _isInvalid('name'),
          onChanged: (_) => _markValid('name'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('name', _secondNameFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('secondName'),
          controller: _secondName,
          focusNode: _secondNameFocus,
          hintText: 'Отчество',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('secondName', _emailFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('email'),
          controller: _email,
          focusNode: _emailFocus,
          hintText: 'Email',
          showError: _isInvalid('email'),
          onChanged: (_) => _markValid('email'),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('email', _phoneFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('phone'),
          controller: _phone,
          focusNode: _phoneFocus,
          hintText: 'Телефон',
          showError: _isInvalid('phone'),
          onChanged: (_) => _markValid('phone'),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _focusNext('phone', null),
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle('Руководитель'),
        RNInput(
          key: _keyFor('lastName'),
          controller: _lastName,
          focusNode: _lastNameFocus,
          hintText: 'Фамилия',
          showError: _isInvalid('lastName'),
          onChanged: (_) => _markValid('lastName'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('lastName', _nameFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('name'),
          controller: _name,
          focusNode: _nameFocus,
          hintText: 'Имя',
          showError: _isInvalid('name'),
          onChanged: (_) => _markValid('name'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('name', _secondNameFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('secondName'),
          controller: _secondName,
          focusNode: _secondNameFocus,
          hintText: 'Отчество',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('secondName', _emailFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('email'),
          controller: _email,
          focusNode: _emailFocus,
          hintText: 'Email',
          showError: _isInvalid('email'),
          onChanged: (_) => _markValid('email'),
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('email', _phoneFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('phone'),
          controller: _phone,
          focusNode: _phoneFocus,
          hintText: 'Телефон',
          showError: _isInvalid('phone'),
          onChanged: (_) => _markValid('phone'),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('phone', _legalNameFocus),
        ),
        const SizedBox(height: 14),
        _sectionTitle('Организация'),
        RNInput(
          key: _keyFor('legalName'),
          controller: _legalName,
          focusNode: _legalNameFocus,
          hintText: 'Наименование организации',
          showError: _isInvalid('legalName'),
          onChanged: (_) => _markValid('legalName'),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('legalName', _unpFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('unp'),
          controller: _unp,
          focusNode: _unpFocus,
          hintText: 'УНП',
          showError: _isInvalid('unp'),
          onChanged: (_) => _markValid('unp'),
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('unp', _legalRegionFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('legalRegion'),
          controller: _legalRegion,
          focusNode: _legalRegionFocus,
          hintText: 'Местонахождение',
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('legalRegion', _legalAddressFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('legalAddress'),
          controller: _legalAddress,
          focusNode: _legalAddressFocus,
          hintText: 'Юридический адрес',
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('legalAddress', _workPositionFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('workPosition'),
          controller: _workPosition,
          focusNode: _workPositionFocus,
          hintText: 'Должность',
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('workPosition', _workProfileFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('workProfile'),
          controller: _workProfile,
          focusNode: _workProfileFocus,
          hintText: 'Профиль деятельности',
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('workProfile', _bankNameFocus),
        ),
        const SizedBox(height: 14),
        _sectionTitle('Банковские реквизиты'),
        RNInput(
          key: _keyFor('bankName'),
          controller: _bankName,
          focusNode: _bankNameFocus,
          hintText: 'Наименование банка',
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('bankName', _bankAddressFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('bankAddress'),
          controller: _bankAddress,
          focusNode: _bankAddressFocus,
          hintText: 'Адрес банка',
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('bankAddress', _bankAccountFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('bankAccount'),
          controller: _bankAccount,
          focusNode: _bankAccountFocus,
          hintText: 'Расчётный счёт',
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNext('bankAccount', _bankBicFocus),
        ),
        const SizedBox(height: 8),
        RNInput(
          key: _keyFor('bankBic'),
          controller: _bankBic,
          focusNode: _bankBicFocus,
          hintText: 'БИК',
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _focusNext('bankBic', null),
        ),
      ],
    );
  }
}
