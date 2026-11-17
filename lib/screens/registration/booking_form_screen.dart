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
import '../../widgets/animated_press.dart';
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

class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({
    super.key,
    this.initialStation,
    this.initialService,
  });

  final DiagnosticStation? initialStation;
  final StationService? initialService;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen>
    with WidgetsBindingObserver {
  List<DiagnosticStation> _stations = [];
  List<StationService> _services = [];
  bool _loadingStations = true;
  bool _loadingServices = false;
  String? _error;

  DiagnosticStation? _station;
  StationService? _service;
  DateTime _selectedDate = _firstBookableDate();
  List<StationDaySlots> _days = [];
  StationSlot? _selectedSlot;
  bool _loadingSlots = false;
  String? _slotsError;

  final _vehicleName = TextEditingController();
  final _regNumber = TextEditingController();
  final _regNumberFocus = FocusNode();
  final _vehicleNameFocus = FocusNode();
  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  int _servicesRequestId = 0;
  int _slotsRequestId = 0;
  bool _notifySms = true;
  bool _notifyEmail = true;
  bool _notifyPush = false;
  bool _submitting = false;

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
    _station = widget.initialStation;
    _service = widget.initialService;
    WidgetsBinding.instance.addObserver(this);
    _regNumberFocus.addListener(() => _ensureFocusVisible(_regNumberFocus));
    _vehicleNameFocus.addListener(() => _ensureFocusVisible(_vehicleNameFocus));
    _regNumber.addListener(_onRegNumberEdited);
    _loadStations();
    _loadVehicles();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _vehicleName.dispose();
    _regNumber.removeListener(_onRegNumberEdited);
    _regNumber.dispose();
    _regNumberFocus.dispose();
    _vehicleNameFocus.dispose();
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

  /// Появление и уход клавиатуры меняют только размеры вьюпорта: перестраиваем
  /// экран, чтобы кнопка «Записаться» успела спрятаться или вернуться.
  @override
  void didChangeMetrics() {
    if (mounted) setState(() {});
  }

  /// Подводит сфокусированное поле в видимую область.
  ///
  /// Клавиатура сжимает экран снизу, а `EditableText` сам не поднимает поле:
  /// внутри оболочки `Scaffold` срезает `viewInsets` из MediaQuery тела. Второй
  /// заход с задержкой нужен потому, что клавиатура анимируется дольше кадра,
  /// в котором пришёл фокус.
  void _ensureFocusVisible(FocusNode node) {
    if (!node.hasFocus) return;
    void reveal() {
      if (!mounted) return;
      final targetContext = node.context;
      if (targetContext == null || !targetContext.mounted) return;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: 0.3,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      reveal();
      Future<void>.delayed(const Duration(milliseconds: 300), reveal);
    });
  }

  Future<void> _loadStations() async {
    setState(() {
      _loadingStations = true;
      _error = null;
    });
    try {
      final stations = await StationApi.instance.getStations(
        filters: const {
          'onlineRecord': {'18'},
        },
      );
      if (!mounted) return;
      final available = stations
          .where((station) => station.isOnlineRecord)
          .toList();
      final initial = widget.initialStation;
      if (initial != null &&
          initial.isOnlineRecord &&
          !available.any((station) => station.id == initial.id)) {
        available.insert(0, initial);
      }
      final selected = _station == null
          ? null
          : available.cast<DiagnosticStation?>().firstWhere(
              (station) => station?.id == _station!.id,
              orElse: () => null,
            );
      setState(() {
        _stations = available;
        _station = selected;
        _loadingStations = false;
      });
      if (selected != null) {
        await _loadServicesForStation(
          selected,
          preferredService: widget.initialService,
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loadingStations = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить организации';
          _loadingStations = false;
        });
      }
    }
  }

  Future<void> _loadServicesForStation(
    DiagnosticStation station, {
    StationService? preferredService,
  }) async {
    final requestId = ++_servicesRequestId;
    setState(() => _loadingServices = true);
    try {
      final services = await StationApi.instance.getStationServices(station.id);
      if (!mounted ||
          requestId != _servicesRequestId ||
          _station?.id != station.id) {
        return;
      }
      final isLegal = context.read<AuthProvider>().isLegal;
      final visible = filterStationServices(services, isLegal: isLegal);
      final selectedService = preferredService == null
          ? null
          : visible.cast<StationService?>().firstWhere(
              (service) => service?.id == preferredService.id,
              orElse: () => null,
            );
      setState(() {
        _services = visible;
        _service = selectedService;
        _loadingServices = false;
      });
      if (selectedService != null) {
        _loadSlots();
      }
    } on ApiException catch (e) {
      if (!mounted ||
          requestId != _servicesRequestId ||
          _station?.id != station.id) {
        return;
      }
      setState(() {
        _error = e.message;
        _loadingServices = false;
      });
    } catch (_) {
      if (!mounted ||
          requestId != _servicesRequestId ||
          _station?.id != station.id) {
        return;
      }
      setState(() {
        _error = 'Не удалось загрузить услуги';
        _loadingServices = false;
      });
    }
  }

  Future<void> _onStationChanged(DiagnosticStation? station) async {
    setState(() {
      _station = station;
      _service = null;
      _services = [];
      _days = [];
      _selectedSlot = null;
      _slotsRequestId++;
    });
    if (station != null) {
      await _loadServicesForStation(station);
    }
  }

  void _onServiceChanged(StationService? service) {
    setState(() {
      _service = service;
      _days = [];
      _selectedSlot = null;
      _slotsError = null;
    });
    if (_station != null && service != null) {
      _loadSlots();
    }
  }

  Future<void> _loadSlots() async {
    final station = _station;
    if (station == null) return;
    final requestId = ++_slotsRequestId;
    final date = _apiDate(_selectedDate);
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
      _selectedSlot = null;
    });
    try {
      final days = await StationApi.instance.getSlots(station.id, date);
      if (!mounted ||
          requestId != _slotsRequestId ||
          _station?.id != station.id ||
          _apiDate(_selectedDate) != date) {
        return;
      }
      setState(() {
        _days = days;
        _loadingSlots = false;
      });
    } on ApiException catch (e) {
      if (!mounted ||
          requestId != _slotsRequestId ||
          _station?.id != station.id ||
          _apiDate(_selectedDate) != date) {
        return;
      }
      setState(() {
        _days = const [];
        _slotsError = e.message;
        _loadingSlots = false;
      });
    } catch (_) {
      if (!mounted ||
          requestId != _slotsRequestId ||
          _station?.id != station.id ||
          _apiDate(_selectedDate) != date) {
        return;
      }
      setState(() {
        _days = const [];
        _slotsError = 'Не удалось загрузить расписание';
        _loadingSlots = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final station = _station;
    if (station == null) return;
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: MonthCalendar(
          stationId: station.id,
          selectedDate: _selectedDate,
          onDaySelected: (date) => Navigator.of(sheetContext).pop(date),
        ),
      ),
    );
    if (picked != null && mounted) _onDaySelected(picked);
  }

  void _onDaySelected(DateTime date) {
    setState(() => _selectedDate = date);
    _loadSlots();
  }

  List<StationSlot> get _availableSlots {
    final serviceId = _service?.id;
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

  Future<void> _submit() async {
    if (_station == null) {
      setState(() => _error = 'Выберите организацию');
      return;
    }
    if (_service == null) {
      setState(() => _error = 'Выберите услугу');
      return;
    }
    if (_selectedSlot == null) {
      setState(() {
        _error =
            _slotsError ??
            (_availableSlots.isEmpty
                ? 'На выбранную дату свободного времени нет'
                : 'Выберите время');
      });
      return;
    }
    _clearInvalid();
    if (_regNumber.text.trim().isEmpty) _markInvalid('regNumber');
    if (_vehicleName.text.trim().isEmpty) _markInvalid('vehicleName');
    if (_invalidFields.isNotEmpty) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await StationApi.instance.recordOnStation({
        'stationId': _station!.id,
        'serviceId': _service!.id,
        'date': _apiDate(_selectedDate),
        'time': _selectedSlot!.timeSlot,
        'dayId': _selectedSlot!.dayId,
        'vechicleName': _vehicleName.text.trim(),
        'regNumber': _regNumber.text.trim(),
        'notificationWay': {
          'sms': _notifySms,
          'email': _notifyEmail,
          'push': _notifyPush,
        },
      });
      if (!mounted) return;
      final station = _station;
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
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Вы успешно записаны на технический осмотр.'),
                const SizedBox(height: 12),
                _InfoLine(label: 'Станция', value: station?.title ?? ''),
                _InfoLine(label: 'Услуга', value: _service?.title ?? ''),
                _InfoLine(
                  label: 'Дата и время',
                  value:
                      '${DateFormat('dd.MM.yyyy').format(_selectedDate)}, ${_selectedSlot?.timeSlot ?? ''}',
                ),
              ],
            ),
          );
        },
      );
      if (mounted) {
        context.go('/registration', extra: const {'showHistory': true});
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Произошла ошибка');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Настоящие отступы клавиатуры берём из вьюпорта: внешний Scaffold оболочки
    // срезает `viewInsets` из MediaQuery тела, и `MediaQuery.viewInsetsOf`
    // внутри экрана всегда показал бы ноль.
    final keyboardVisible = View.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Запись на услуги и административные процедуры',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      // Нижний отступ кнопки считаем сами через bikeNavBottomInset: SafeArea с
      // bottom: true добавлял высоту нижней навигации повторно, и кнопка
      // «Записаться» висела над формой, перекрывая нижние поля ввода. На время
      // ввода кнопка прячется совсем: под клавиатурой нижней навигации нет, а
      // кнопка на её месте закрывала бы поля, в которые пишешь.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFieldLabel('Организация, оказывающая услугу *'),
                    const SizedBox(height: 8),
                    _buildStationPicker(),
                    const SizedBox(height: 20),
                    _buildFieldLabel('Наименование услуги *'),
                    const SizedBox(height: 8),
                    _buildServicePicker(),
                    if (_station != null && _service != null) ...[
                      const SizedBox(height: 20),
                      _buildFieldLabel('Дата оказания услуги *'),
                      const SizedBox(height: 8),
                      _DateField(date: _selectedDate, onTap: _pickDate),
                      const SizedBox(height: 20),
                      _buildFieldLabel('Время оказания услуги *'),
                      const SizedBox(height: 8),
                      _buildTimeSlots(),
                    ] else if (_station != null) ...[
                      const SizedBox(height: 20),
                      Text(
                        'Выберите услугу, чтобы увидеть доступное время',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildFieldLabel('Регистрационный номер ТС *'),
                    const SizedBox(height: 6),
                    _buildRegNumberField(),
                    const SizedBox(height: 12),
                    _buildFieldLabel('Марка и модель ТС *'),
                    const SizedBox(height: 6),
                    RNInput(
                      controller: _vehicleName,
                      focusNode: _vehicleNameFocus,
                      hintText: 'Например, Audi A6',
                      showError: _isInvalid('vehicleName'),
                      onChanged: (_) => _markValid('vehicleName'),
                      prefixIcon: Icons.directions_car_outlined,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel('Напоминание'),
                    const SizedBox(height: 8),
                    _buildNotificationCheckboxes(),
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
            if (!keyboardVisible)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  16 + bikeNavBottomInset(context),
                ),
                child: RNButton(
                  title: 'Записаться',
                  onPress: _submit,
                  loading: _submitting,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildRegNumberField() {
    return VehicleRegField(
      controller: _regNumber,
      focusNode: _regNumberFocus,
      vehicles: _vehicles,
      showError: _isInvalid('regNumber'),
      onChanged: (_) => _markValid('regNumber'),
      onVehicleSelected: _onVehicleSelected,
      onNextField: () => _vehicleNameFocus.requestFocus(),
    );
  }

  Widget _buildStationPicker() {
    if (_loadingStations) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_stations.isEmpty) {
      return Text(
        _error ?? 'Нет доступных организаций',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return AppSelectField<DiagnosticStation>(
      value: _station,
      hint: 'Выберите организацию',
      items: _stations,
      labelOf: (s) => s.title ?? 'Станция ${s.id}',
      subtitleOf: (s) => s.address,
      searchable: _stations.length > 5,
      onChanged: _onStationChanged,
    );
  }

  Widget _buildServicePicker() {
    if (_station == null) {
      return Text(
        'Сначала выберите организацию',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    if (_loadingServices) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_services.isEmpty) {
      return Text(
        'У выбранной организации нет услуг',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return AppSelectField<StationService>(
      value: _service,
      hint: 'Выберите услугу',
      items: _services,
      labelOf: (s) => s.title,
      subtitleOf: (s) => s.price == null ? null : '${s.price} руб.',
      searchable: _services.length > 5,
      onChanged: _onServiceChanged,
    );
  }

  Widget _buildTimeSlots() {
    if (_loadingSlots) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_slotsError != null) {
      return Text(_slotsError!, style: TextStyle(color: AppColors.error));
    }
    if (_availableSlots.isEmpty) {
      return Text(
        'На выбранную дату свободного времени нет. Выберите другую дату.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return AppSelectField<StationSlot>(
      value: _selectedSlot,
      hint: 'Выберите время',
      items: _availableSlots,
      labelOf: (slot) => slot.timeSlot,
      subtitleOf: (slot) => slot.dayId == null ? null : 'Запись №${slot.dayId}',
      searchable: _availableSlots.length > 8,
      onChanged: (slot) => setState(() => _selectedSlot = slot),
    );
  }

  Widget _buildNotificationCheckboxes() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _CheckboxRow(
            title: 'SMS',
            value: _notifySms,
            onChanged: (v) => setState(() => _notifySms = v),
          ),
          _CheckboxRow(
            title: 'E-mail',
            value: _notifyEmail,
            onChanged: (v) => setState(() => _notifyEmail = v),
          ),
          _CheckboxRow(
            title: 'Push-уведомления',
            value: _notifyPush,
            onChanged: (v) => setState(() => _notifyPush = v),
          ),
        ],
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  DateFormat('dd.MM.yyyy').format(date),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckboxRow extends StatelessWidget {
  const _CheckboxRow({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: () => onChanged(!value),
      scale: 0.98,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
