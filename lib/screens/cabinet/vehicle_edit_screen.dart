import 'package:flutter/material.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/text_utils.dart';
import '../../models/vehicle.dart';
import '../../services/user_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/rn_button.dart';
import '../../widgets/rn_input.dart';

class VehicleEditScreen extends StatefulWidget {
  const VehicleEditScreen({super.key, this.vehicle});

  final Vehicle? vehicle;

  @override
  State<VehicleEditScreen> createState() => _VehicleEditScreenState();
}

class _VehicleEditScreenState extends State<VehicleEditScreen> {
  final _name = TextEditingController();
  final _regNumber = TextEditingController();
  final _passport = TextEditingController();
  final _nameFocus = FocusNode();
  final _regNumberFocus = FocusNode();
  final _passportFocus = FocusNode();
  bool _loading = false;
  String? _error;

  bool get _isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    if (v != null) {
      _name.text = v.name ?? '';
      _regNumber.text = v.regNumber ?? '';
      _passport.text = v.vehiclePassport ?? '';
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _regNumber.dispose();
    _passport.dispose();
    _nameFocus.dispose();
    _regNumberFocus.dispose();
    _passportFocus.dispose();
    super.dispose();
  }

  final _passportKey = GlobalKey();

  void _focusPassport() {
    _passportFocus.requestFocus();
    final passportContext = _passportKey.currentContext;
    if (passportContext != null) {
      Scrollable.ensureVisible(
        passportContext,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: 0.2,
      );
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

  Future<void> _submit() async {
    setState(() => _error = null);
    _clearInvalid();
    if (_name.text.trim().isEmpty) _markInvalid('name');
    if (_regNumber.text.trim().isEmpty) _markInvalid('regNumber');
    final passport = _passport.text.trim().toUpperCase();
    if (passport.isEmpty) _markInvalid('passport');
    if (_invalidFields.isNotEmpty) return;
    if (!isValidCertNumber(passport)) {
      _markInvalid('passport');
      return;
    }
    setState(() => _loading = true);
    try {
      final data = <String, dynamic>{
        'vechicleName': _name.text.trim(),
        'regNumber': _regNumber.text.trim(),
        'certNumber': passport,
      };
      if (_isEdit) {
        data['vechicleId'] = widget.vehicle!.id;
        await UserService.instance.editVehicle(data);
      } else {
        await UserService.instance.addVehicle(data);
      }
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
        title: Text(
          _isEdit ? 'Редактировать автомобиль' : 'Добавить автомобиль',
        ),
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
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.splashMid,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              if (_isEdit && widget.vehicle!.permitExpired != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Срок действия разрешения: '
                          '${widget.vehicle!.permitExpired}',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              RNInput(
                controller: _name,
                focusNode: _nameFocus,
                hintText: 'Название (марка, модель)',
                showError: _isInvalid('name'),
                onChanged: (_) => _markValid('name'),
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _regNumberFocus.requestFocus(),
              ),
              const SizedBox(height: 8),
              RNInput(
                controller: _regNumber,
                focusNode: _regNumberFocus,
                hintText: 'Регистрационный номер',
                showError: _isInvalid('regNumber'),
                onChanged: (_) => _markValid('regNumber'),
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _focusPassport(),
              ),
              const SizedBox(height: 8),
              RNInput(
                key: _passportKey,
                controller: _passport,
                focusNode: _passportFocus,
                hintText: 'Номер технического паспорта',
                showError: _isInvalid('passport'),
                onChanged: (_) => _markValid('passport'),
                textCapitalization: TextCapitalization.characters,
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
                title: _isEdit ? 'Сохранить' : 'Добавить',
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
