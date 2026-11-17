import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../models/station.dart';
import '../../models/vehicle.dart';
import '../../providers/auth_provider.dart';
import '../../services/station_service.dart';
import '../../services/user_service.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/month_calendar.dart';
import '../../widgets/rn_button.dart';
import '../../widgets/rn_input.dart';
import '../../widgets/vehicle_reg_field.dart';

DateTime _firstBookableDate() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day + 1);
}

String _apiDate(DateTime date) => DateFormat('dd.MM.yyyy').format(date);

class StationRecordScreen extends StatefulWidget {
  const StationRecordScreen({super.key, required this.station, this.service});

  final DiagnosticStation station;
  final StationService? service;

  @override
  State<StationRecordScreen> createState() => _StationRecordScreenState();
}

class _StationRecordScreenState extends State<StationRecordScreen> {
  DateTime _selectedDate = _firstBookableDate();
  List<StationDaySlots> _days = [];
  StationSlot? _selectedSlotData;
  bool _loadingSlots = false;
  bool _submitting = false;
  String? _slotsError;
  String? _formError;

  StationService? _selectedService;
  final _vehicleName = TextEditingController();
  final _regNumber = TextEditingController();
  final _vehicleNameFocus = FocusNode();
  final _regNumberFocus = FocusNode();
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  int _slotsRequestId = 0;

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

  final _invalidFields = <String>{};

  @override
  void initState() {
    super.initState();
    _selectedService = widget.service;
    _regNumber.addListener(_onRegNumberEdited);
    _loadSlots();
    _loadVehicles();
  }

  @override
  void dispose() {
    _vehicleName.dispose();
    _regNumber.removeListener(_onRegNumberEdited);
    _regNumber.dispose();
    _vehicleNameFocus.dispose();
    _regNumberFocus.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    if (!context.read<AuthProvider>().authStatus) return;
    try {
      final vehicles = await UserService.instance.getVehicles();
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles
            .where((vehicle) => vehicle.regNumber?.isNotEmpty == true)
            .toList();
        if (_vehicles.length == 1) {
          _applyVehicle(_vehicles.first);
        }
      });
    } catch (_) {
      // Автомобили — удобное дополнение формы, ошибка загрузки не критична.
    }
  }

  void _applyVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    _regNumber.text = vehicle.regNumber ?? '';
    if (vehicle.name?.isNotEmpty == true) {
      _vehicleName.text = vehicle.name!;
      _markValid('vehicleName');
    }
    _markValid('regNumber');
  }

  /// Ручное редактирование номера отвязывает поле от выбранного авто.
  void _onRegNumberEdited() {
    final vehicle = _selectedVehicle;
    if (vehicle == null) return;
    if (_regNumber.text.trim() != (vehicle.regNumber?.trim() ?? '')) {
      setState(() => _selectedVehicle = null);
    }
  }

  void _onVehicleSelected(Vehicle vehicle) {
    setState(() => _applyVehicle(vehicle));
  }

  Future<void> _loadSlots() async {
    final requestId = ++_slotsRequestId;
    final date = _apiDate(_selectedDate);
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
      _selectedSlotData = null;
    });
    try {
      final days = await StationApi.instance.getSlots(widget.station.id, date);
      if (!mounted ||
          requestId != _slotsRequestId ||
          _apiDate(_selectedDate) != date) {
        return;
      }
      setState(() => _days = days);
    } on ApiException catch (e) {
      if (!mounted ||
          requestId != _slotsRequestId ||
          _apiDate(_selectedDate) != date) {
        return;
      }
      setState(() {
        _days = const [];
        _slotsError = e.message;
      });
    } catch (_) {
      if (!mounted ||
          requestId != _slotsRequestId ||
          _apiDate(_selectedDate) != date) {
        return;
      }
      setState(() {
        _days = const [];
        _slotsError = 'Не удалось загрузить расписание';
      });
    } finally {
      if (mounted && requestId == _slotsRequestId) {
        setState(() => _loadingSlots = false);
      }
    }
  }

  void _onDaySelected(DateTime date) {
    setState(() => _selectedDate = date);
    _loadSlots();
  }

  Future<void> _submit() async {
    setState(() => _formError = null);
    if (_selectedService == null) {
      setState(() => _formError = 'Выберите услугу');
      return;
    }
    if (_loadingSlots) {
      setState(() => _formError = 'Дождитесь загрузки расписания');
      return;
    }
    if (_selectedSlotData == null) {
      setState(() => _formError = _slotsError ?? 'Выберите время');
      return;
    }
    _clearInvalid();
    if (_vehicleName.text.trim().isEmpty) _markInvalid('vehicleName');
    if (_regNumber.text.trim().isEmpty) _markInvalid('regNumber');
    if (_invalidFields.isNotEmpty) return;
    setState(() {
      _submitting = true;
      _formError = null;
    });
    try {
      await StationApi.instance.recordOnStation({
        'stationId': widget.station.id,
        'serviceId': _selectedService!.id,
        'date': _apiDate(_selectedDate),
        'time': _selectedSlotData!.timeSlot,
        'dayId': _selectedSlotData!.dayId,
        'vechicleName': _vehicleName.text.trim(),
        'regNumber': _regNumber.text.trim(),
        'notificationWay': {'sms': true, 'email': true},
      });
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          Future<void>.delayed(const Duration(seconds: 2)).then((_) {
            if (dialogContext.mounted) {
              Navigator.of(dialogContext).pop();
            }
          });
          return AlertDialog(
            icon: Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 48,
            ),
            title: const Text('Запись создана'),
            content: const Text('Вы успешно записаны на технический осмотр.'),
          );
        },
      );
      if (mounted) {
        context.go('/registration', extra: const {'showHistory': true});
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _formError = e.message);
    } catch (_) {
      if (mounted) setState(() => _formError = 'Произошла ошибка');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  List<StationSlot> get _availableSlots {
    final serviceId = _selectedService?.id;
    return _days
        .expand((day) => day.slots)
        .where(
          (slot) =>
              serviceId == null ||
              slot.serviceId == null ||
              slot.serviceId == serviceId,
        )
        .where((slot) => slot.timeSlot.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final services = widget.station.services ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись на осмотр'),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          16,
          8,
          16,
          32 + bikeNavBottomInset(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.splashMid.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.station.title ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (widget.station.address != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.station.address!,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (services.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Услуга',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              AppSelectField<StationService>(
                value: _selectedService,
                hint: 'Выберите услугу',
                items: services,
                searchable: services.length > 5,
                labelOf: (service) => service.title,
                subtitleOf: (service) =>
                    service.price == null ? null : '${service.price} руб.',
                onChanged: (value) {
                  setState(() => _selectedService = value);
                  _loadSlots();
                },
              ),
            ],
            const SizedBox(height: 16),
            RNInput(
              controller: _vehicleName,
              focusNode: _vehicleNameFocus,
              hintText: 'Марка и модель автомобиля',
              showError: _isInvalid('vehicleName'),
              onChanged: (_) => _markValid('vehicleName'),
              prefixIcon: Icons.directions_car_outlined,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => _regNumberFocus.requestFocus(),
            ),
            const SizedBox(height: 8),
            VehicleRegField(
              controller: _regNumber,
              focusNode: _regNumberFocus,
              vehicles: _vehicles,
              showError: _isInvalid('regNumber'),
              onChanged: (_) => _markValid('regNumber'),
              onVehicleSelected: _onVehicleSelected,
              onNextField: () => FocusManager.instance.primaryFocus?.unfocus(),
            ),
            const SizedBox(height: 20),
            Text(
              'Дата',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            MonthCalendar(
              stationId: widget.station.id,
              selectedDate: _selectedDate,
              onDaySelected: _onDaySelected,
            ),
            const SizedBox(height: 20),
            Text(
              'Время',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            if (_loadingSlots)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_slotsError != null)
              Text(_slotsError!, style: TextStyle(color: AppColors.error))
            else if (_availableSlots.isEmpty)
              Text(
                'На выбранную дату свободного времени нет. Выберите другую дату.',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableSlots.map((slot) {
                  final selected =
                      _selectedSlotData?.timeSlot == slot.timeSlot &&
                      _selectedSlotData?.dayId == slot.dayId;
                  return ChoiceChip(
                    label: Text(slot.timeSlot),
                    selected: selected,
                    onSelected: (_) => setState(() {
                      _selectedSlotData = slot;
                    }),
                  );
                }).toList(),
              ),
            if (_formError != null) ...[
              const SizedBox(height: 12),
              Text(_formError!, style: TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 24),
            RNButton(
              title: 'Записаться',
              onPress: _submit,
              loading: _submitting,
            ),
          ],
        ),
      ),
    );
  }
}
