import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/text_utils.dart';
import '../../models/payment.dart';
import '../../models/payment_flow_spec.dart';
import '../../models/vehicle.dart';
import '../../providers/auth_provider.dart';
import '../../services/payment_service.dart';
import '../../services/user_service.dart';
import '../../widgets/animated_press.dart';
import '../../widgets/app_back_button.dart';
import '../../widgets/app_select_field.dart';
import '../../widgets/bike_bottom_nav.dart';
import '../../widgets/rn_button.dart';
import '../../widgets/vehicle_menu.dart';
import '../../widgets/webview_container.dart';

enum _PaymentStatus { created, pending, paid, failed }

class PaymentFlowScreen extends StatefulWidget {
  const PaymentFlowScreen({super.key, required this.service});

  final PaymentService service;

  @override
  State<PaymentFlowScreen> createState() => _PaymentFlowScreenState();
}

class _PaymentFlowScreenState extends State<PaymentFlowScreen>
    with WidgetsBindingObserver {
  static const _legalSubtitle = 'Реквизиты организации';

  int _step = 0;
  bool _loading = false;
  String? _error;

  late PaymentFlowSpec _spec;
  PaymentService? _service;
  PaymentStation? _station;
  VehicleType? _vehicleType;
  PaymentMethod? _method;
  OrderInfo? _order;
  _PaymentStatus _paymentStatus = _PaymentStatus.created;
  String? _paymentStatusMessage;
  List<PaymentMethod> _paymentMethods = const [];
  List<VehicleType> _vehicleTypes = const [];
  PriceInfo? _price;

  /// Сумма, которую сервер взял за созданный заказ.
  ///
  /// Расчёт из [PriceInfo] и итог заказа — разные числа: у ГТО расчёт на
  /// 5 BYN меньше, потому что в него не входит печать диагностической карты.
  /// Показывать расчёт на шаге оплаты можно, но платить будут по итогу,
  /// поэтому рядом с кнопкой оплаты показывается именно [_orderTotal].
  double? _orderTotal;
  List<DocumentTemplate> _documents = const [];

  final _vehicleFieldValues = <String, DropdownValue>{};
  final _vehicleFieldKeys = <String, GlobalKey>{};
  int? _axlesCount;

  List<DropdownValue> _certainTypes = const [];
  bool _loadingCertainTypes = false;
  String? _certainTypesError;
  final Set<int> _selectedCertainTypeIds = <int>{};

  final _vehicleCount = TextEditingController(text: '1');
  final _vehicleTypeName = TextEditingController();

  final _lastName = TextEditingController();
  final _firstName = TextEditingController();
  final _middleName = TextEditingController();
  final _personalEmail = TextEditingController();
  final _certNumber = TextEditingController();
  final _regNumber = TextEditingController();

  final _legalNameOrg = TextEditingController();
  final _legalUnp = TextEditingController();
  final _legalCodePodr = TextEditingController();
  final _legalFace = TextEditingController();
  final _legalMainDoc = TextEditingController();
  final _legalLocation = TextEditingController();
  final _legalBankName = TextEditingController();
  final _legalBankAccount = TextEditingController();
  final _legalBankBic = TextEditingController();
  final _legalEmail = TextEditingController();
  final _legalPhone = TextEditingController();

  bool _loadingPrice = false;
  bool _awaitingExternalPayment = false;
  int _priceRequestId = 0;
  int _vehicleRequestId = 0;
  Timer? _priceDebounce;
  bool _loadingVehicleTypes = false;
  bool _vehicleTypesRequested = false;

  /// Автомобили из личного кабинета: выбор в меню подставляет и госномер, и
  /// свидетельство, потому что это данные одного транспортного средства.
  List<Vehicle> _vehicles = const [];
  Vehicle? _selectedVehicle;

  final _scrollController = ScrollController();
  final _certFieldKey = GlobalKey();
  final _regFieldKey = GlobalKey();
  final _vehicleTypeKey = GlobalKey();
  final _certFocus = FocusNode();
  final _regFocus = FocusNode();
  final _vehicleCountFocus = FocusNode();
  final _lastNameFocus = FocusNode();
  final _firstNameFocus = FocusNode();
  final _middleNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _legalUnpFocus = FocusNode();
  final _legalNameOrgFocus = FocusNode();
  final _legalFaceFocus = FocusNode();
  final _legalMainDocFocus = FocusNode();
  final _legalCodePodrFocus = FocusNode();
  final _legalLocationFocus = FocusNode();
  final _legalBankNameFocus = FocusNode();
  final _legalBankAccountFocus = FocusNode();
  final _legalBankBicFocus = FocusNode();
  final _legalEmailFocus = FocusNode();

  final _invalidFields = <String>{};

  /// Причина, по конкретному полю: «в знаке менее четырёх цифр».
  ///
  /// Общая подсказка «заполните поле» для таких случаев бесполезна, поэтому
  /// рядом с признаком не заполнено хранится и объяснение.
  final _fieldProblems = <String, String>{};

  /// Название полей для подсказки: пользователю показывается то, что он видит
  /// на экране, а не внутренний идентификатор.
  static const _fieldTitles = <String, String>{
    'station': 'Место оказания услуги',
    'method': 'Способ оплаты',
    'cert': 'Свидетельство о регистрации ТС',
    'reg': 'Регистрационный номер ТС',
    'lastName': 'Фамилия',
    'firstName': 'Имя',
    'middleName': 'Отчество',
    'email': 'Email',
    'unp': 'УНП',
    'codePodr': 'Код подразделения',
    'nameOrg': 'Наименование организации',
    'face': 'Должность',
    'mainDoc': 'Документ, уполномоченный подписать',
    'location': 'Место нахождения организации',
    'bankName': 'Наименование банка',
    'bankAccount': 'Расчётный счёт',
    'bankBic': 'БИК',
    'phone': 'Телефон',
    'legalUnp': 'УНП',
    'legalCodePodr': 'Код обособленного подразделения',
    'legalNameOrg': 'Наименование организации',
    'legalFace': 'В лице',
    'legalMainDoc': 'На основании',
    'legalLocation': 'Место нахождения',
    'legalBankName': 'В банке',
    'legalBankAccount': 'Расчётный счёт',
    'legalBankBic': 'BIC банка',
    'legalEmail': 'E-mail',
    'vehicleType': 'Тип транспортного средства',
    'axles': 'Количество осей',
    'count': 'Количество ТС',
    'certainTypes': 'Виды работ',
  };

  /// Ключи полей, к которым подводится экран при подсказке.
  final _fieldKeys = <String, GlobalKey>{};

  bool _legalPrefilled = false;
  bool _personalPrefilled = false;

  bool get _isLegal => _spec.isLegal;

  List<FlowStep> get _steps => _spec.steps;

  FlowStep get _currentStep => _steps[_step.clamp(0, _steps.length - 1)];

  bool get _isLastStep => _step == _steps.length - 1;

  /// Шаг, на котором показывается стоимость услуги.
  ///
  /// У юрлиц итог считается вместе с данными о ТС, у физлиц — на шаге способа
  /// оплаты. У услуг без данных о ТС (например, разрешения на допуск) шага ТС
  /// нет, поэтому стоимость показывается на шаге способа оплаты — как и у
  /// физлиц, а не в реквизитах.
  FlowStep get _priceStep {
    if (!_isLegal) return FlowStep.method;
    return _steps.contains(FlowStep.vehicle)
        ? FlowStep.vehicle
        : FlowStep.method;
  }

  /// Регистрационный знак запрашивается по обоим сценариям.
  bool get _requiresRegistrationNumber =>
      _spec.requireRegNumber || _spec.requirePersonalReg;

  /// Показывается ли поле свидетельства о регистрации на текущем наборе шагов.
  ///
  /// У юрлиц состав реквизитов задаёт `legalRequisites`, у физлиц — отдельные
  /// флаги сценария, поэтому проверка разная для двух сценариев.
  bool get _showsCertField => _isLegal
      ? _spec.legalRequisites.contains(LegalField.cert)
      : _spec.requireCert;

  /// Показывается ли поле регистрационного знака.
  bool get _showsRegField => _isLegal
      ? _spec.legalRequisites.contains(LegalField.regNumber)
      : _requiresRegistrationNumber;

  /// Есть ли смысл предлагать меню: машин несколько и хотя бы одно поле ТС
  /// на экране. У услуги без полей транспорта меню не нужно, а предзаполнение
  /// таких полей добавило бы в заказ данные, которые сервер не запрашивал.
  bool get _canPickVehicle =>
      _vehicles.length > 1 && (_showsCertField || _showsRegField);

  /// Показывается ли поле количества осей.
  ///
  /// У ЕКМТ оси запрашиваются у любого типа. На ГТО у физлица — только
  /// у прицепа и только в диапазоне 0,75–3,5 т. Если у выбранного типа сервер
  /// прислал поле `TRANS_OS` с вариантами, оно рисуется как обычное поле типа:
  /// там и набор значений, и обязательность — всё как задумано на сервере.
  bool get _showsAxlesField {
    if (_vehicleType == null) return false;
    if (_hasServerAxlesField) return true;
    if (!_spec.requiresAxlesFor(_vehicleType)) return false;
    return _spec.requiresAxlesForMass(_selectedMassTitle);
  }

  /// Подпись выбранной массы: по ней решается, спрашивать ли оси.
  String? get _selectedMassTitle {
    for (final field in _vehicleType?.fields ?? const <VehicleTypeField>[]) {
      if (!_isMassField(field)) continue;
      return _vehicleFieldValues[field.name]?.title;
    }
    return null;
  }

  /// Есть ли у выбранного типа поле `TRANS_OS` с вариантами выбора.
  bool get _hasServerAxlesField =>
      (_vehicleType?.fields ?? const <VehicleTypeField>[])
          .where(_isVisibleAxlesField)
          .where((field) => !_isUnselectableField(field))
          .isNotEmpty;

  /// Выбранное количество осей: из серверного поля или из поля сценария.
  int? get _selectedAxles {
    if (_axlesCount != null) return _axlesCount;
    for (final field in _vehicleType?.fields ?? const <VehicleTypeField>[]) {
      if (!_isAxlesField(field) || _isUnselectableField(field)) continue;
      return _vehicleFieldValues[field.name]?.id;
    }
    return null;
  }

  String get _currentSubtitle => switch (_currentStep) {
    FlowStep.station => _spec.stationStepSubtitle,
    FlowStep.method => 'Выбор способа оплаты',
    FlowStep.personal => _isLegal ? _legalSubtitle : 'Личные данные',
    FlowStep.vehicle => _spec.vehicleStepSubtitle,
    FlowStep.order => 'Заказ зарегистрирован',
  };

  bool _isNoncashOrder([OrderInfo? order]) =>
      _paymentKind(order) == PaymentMethodKind.noncash;

  /// Выбран ли способ оплаты через АИС «Расчёт» (ЕРИП).
  bool get _isEripOrder => _paymentKind() == PaymentMethodKind.erip;

  /// Определение способа оплаты: выбор пользователя важнее данных сервера.
  PaymentMethodKind _paymentKind([OrderInfo? order]) => resolvePaymentKind(
    methodType: _method?.type,
    methodTitle: _method?.title,
    payService: order?.payService ?? _order?.payService,
  );

  int? _documentId(DocumentTemplate document) =>
      document.id ?? int.tryParse(document.code ?? '');

  /// Подпись документа заказа: как в исходном приложении — из `value`.
  ///
  /// Начинающееся слово «Договор» из подписи убирается: у договоров оно одно и
  /// то же и в списке выбора только занимает место, а остаток названия — «№123»,
  /// «оказания услуг» — своё дело делает.
  String _documentLabel(DocumentTemplate document) =>
      documentLabel(document.value, title: document.title);

  /// Порядок полей текущего шага для перехода по клавише «Далее» на клавиатуре.
  final _focusChain = <FocusNode>[];

  /// Регистрирует [node] в цепочке фокуса и возвращает его для `focusNode`.
  FocusNode _chain(FocusNode node) {
    if (!_focusChain.contains(node)) _focusChain.add(node);
    return node;
  }

  /// Ставит фокус на следующее поле шага и прокручивает его в видимую область.
  void _focusNextField(FocusNode current) {
    final index = _focusChain.indexOf(current);
    if (index < 0 || index + 1 >= _focusChain.length) {
      FocusManager.instance.primaryFocus?.unfocus();
      return;
    }
    final next = _focusChain[index + 1];
    next.requestFocus();
    _scrollFocusIntoView(next);
  }

  void _scrollFocusIntoView(FocusNode node) {
    final targetContext = node.context;
    if (targetContext == null || !targetContext.mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        alignment: 0.35,
        alignmentPolicy: ScrollPositionAlignmentPolicy.explicit,
      );
    });
  }

  /// Подводит поле в видимую область в момент, когда оно получает фокус.
  ///
  /// `EditableText` сам не поднимает поле над клавиатурой: внешний Scaffold
  /// оболочки срезает `viewInsets` из MediaQuery тела, и до полей это событие
  /// не доходит. Второй заход с задержкой нужен потому, что клавиатура
  /// анимируется дольше кадра, в котором пришёл фокус.
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

  /// Поле ввода, соответствующее идентификатору ошибки.
  ///
  /// Нужно, чтобы при нажатии «Далее» не только подсказать, чего не хватает,
  /// но и сразу поставить курсор в проблемное поле.
  FocusNode? _focusForField(String field) => switch (field) {
    'cert' => _certFocus,
    'reg' => _regFocus,
    'lastName' => _lastNameFocus,
    'firstName' => _firstNameFocus,
    'middleName' => _middleNameFocus,
    'email' => _emailFocus,
    'unp' || 'legalUnp' => _legalUnpFocus,
    'codePodr' || 'legalCodePodr' => _legalCodePodrFocus,
    'nameOrg' || 'legalNameOrg' => _legalNameOrgFocus,
    'face' || 'legalFace' => _legalFaceFocus,
    'mainDoc' || 'legalMainDoc' => _legalMainDocFocus,
    'location' || 'legalLocation' => _legalLocationFocus,
    'bankName' || 'legalBankName' => _legalBankNameFocus,
    'bankAccount' || 'legalBankAccount' => _legalBankAccountFocus,
    'bankBic' || 'legalBankBic' => _legalBankBicFocus,
    'legalEmail' => _legalEmailFocus,
    _ => null,
  };

  void _markInvalid(String field, [String? problem]) {
    final added = _invalidFields.add(field);
    if (problem != null) _fieldProblems[field] = problem;
    if (!added && problem == null) return;
    setState(() {});
  }

  void _markValid(String field) {
    _fieldProblems.remove(field);
    if (_invalidFields.remove(field)) setState(() {});
  }

  void _clearInvalid() {
    if (_invalidFields.isEmpty && _fieldProblems.isEmpty) return;
    setState(() {
      _invalidFields.clear();
      _fieldProblems.clear();
    });
  }

  bool _isInvalid(String field) => _invalidFields.contains(field);

  @override
  void initState() {
    super.initState();
    _service = widget.service;
    _spec = PaymentFlowResolver.resolve(
      widget.service,
      isLegal: context.read<AuthProvider>().isLegal,
    );
    WidgetsBinding.instance.addObserver(this);
    // Количество ТС заполняется сразу: первый запрос цены уходит без `colTs`,
    // сервер сумму не возвращает, и стоимость появлялась только после того, как
    // пользователь вручную вводил цифру.
    _vehicleCount.text = '1';
    _certFocus.addListener(() => _ensureFieldVisible(_certFieldKey));
    _regFocus.addListener(() => _ensureFieldVisible(_regFieldKey));
    // Личные данные и реквизиты — самые нижние поля шага: без подводки при
    // фокусе они уходят под клавиатуру, где их не видно и не поправить.
    for (final node in <FocusNode>[
      _vehicleCountFocus,
      _lastNameFocus,
      _firstNameFocus,
      _middleNameFocus,
      _emailFocus,
      _legalUnpFocus,
      _legalNameOrgFocus,
      _legalFaceFocus,
      _legalMainDocFocus,
      _legalCodePodrFocus,
      _legalLocationFocus,
      _legalBankNameFocus,
      _legalBankAccountFocus,
      _legalBankBicFocus,
      _legalEmailFocus,
    ]) {
      node.addListener(() => _ensureFocusVisible(node));
    }
    _loadPaymentMethods();
    if (_spec.requireCertainTypes) _loadCertainTypes();
    _loadVehicleTypes();
    _loadVehicles();
    _prepareForPrice();
  }

  /// Первичная подготовка: типы ТС загружаются только после выбора станции,
  /// стоимость считается, когда данных для запроса достаточно.
  ///
  /// Услугам, у которых место оказания не выбирается (у разрешения на допуск к
  /// дорожному движению), станция не подставляется: сервер считает их стоимость
  /// и без `stationId`, а чужая организация в заказе не проходит.
  Future<void> _prepareForPrice() async {
    if (_station == null && _spec.requiresStation) return;
    if (_spec.needsVehicleTypes && _station != null) {
      await _loadVehicleTypes();
    }
    if (!mounted) return;
    await _loadPrice();
  }

  /// Смена услуги: пересобираем сценарий и сбрасываем всё, что относилось к
  /// предыдущей услуге, — станцию, тип ТС, реквизиты транспорта и стоимость.
  Future<void> _onServiceChanged(PaymentService? service) async {
    if (service == null || service == _service) return;
    final isLegal = context.read<AuthProvider>().isLegal;
    setState(() {
      _service = service;
      _spec = PaymentFlowResolver.resolve(service, isLegal: isLegal);
      // Набор шагов у услуг разный, поэтому возвращаемся на первый шаг.
      _step = 0;
      _station = null;
      _vehicleType = null;
      _vehicleTypes = const [];
      _vehicleTypesRequested = false;
      _vehicleFieldValues.clear();
      _vehicleFieldKeys.clear();
      _vehicleRequestId++;
      _axlesCount = null;
      _vehicleCount.text = '1';
      // Свидетельство и госномер относятся к предыдущему транспорту.
      _certNumber.clear();
      _regNumber.clear();
      _selectedVehicle = null;
      _selectedCertainTypeIds.clear();
      _invalidFields.clear();
      _error = null;
      _resetPrice();
      _method = null;
      _order = null;
      _orderTotal = null;
      _documents = const [];
      _paymentStatus = _PaymentStatus.created;
      _paymentStatusMessage = null;
    });
    await _loadPaymentMethods();
    if (!mounted) return;
    if (_spec.requireCertainTypes) await _loadCertainTypes();
    if (!mounted) return;
    _loadVehicleTypes();
    await _prepareForPrice();
  }

  void _prefillPersonalProfile() {
    if (_personalPrefilled) return;
    final profile = context.read<AuthProvider>().profile;
    if (profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _prefillPersonalProfile();
      });
      return;
    }

    void fill(TextEditingController controller, String? value) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty && controller.text.isEmpty) {
        controller.text = text;
      }
    }

    fill(_lastName, profile.lastName);
    fill(_firstName, profile.name);
    fill(_middleName, profile.secondName);
    fill(_personalEmail, profile.email);
    _personalPrefilled = true;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _prefillLegalProfile();
    _prefillPersonalProfile();
  }

  /// Подставляет в реквизиты данные организации из профиля.
  ///
  /// Поля, для которых в профиле нет значения, остаются пустыми и при проверке
  /// подсвечиваются красной рамкой.
  void _prefillLegalProfile() {
    if (_legalPrefilled) return;
    if (!context.read<AuthProvider>().isLegal) return;
    final profile = context.read<AuthProvider>().profile;
    if (profile == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _prefillLegalProfile();
      });
      return;
    }

    void fill(TextEditingController controller, String? value) {
      final text = value?.trim();
      if (text != null && text.isNotEmpty && controller.text.isEmpty) {
        controller.text = text;
      }
    }

    fill(_legalUnp, profile.unp);
    fill(_legalCodePodr, profile.codePodr);
    fill(_legalNameOrg, profile.nameOrg ?? profile.legalName);
    fill(_legalFace, profile.face ?? profile.workPosition);
    fill(_legalMainDoc, profile.mainDoc ?? profile.workProfile);
    fill(_legalLocation, profile.location ?? profile.legalRegion);
    fill(_legalBankName, profile.bankName);
    fill(_legalBankAccount, profile.bankAccount);
    fill(_legalBankBic, profile.bankBic);
    fill(_legalEmail, profile.email);
    fill(_legalPhone, profile.phone);
    _legalPrefilled = true;
  }

  /// Загружает автомобили из личного кабинета.
  ///
  /// Если машина одна — она подставляется в оба поля сразу: вводить то, что о
  /// пользователе уже известно, незачем. Если машин несколько, выбор остаётся
  /// за пользователем, меню открывается по тапу на поле.
  Future<void> _loadVehicles() async {
    if (!context.read<AuthProvider>().authStatus) return;
    try {
      final vehicles = await UserService.instance.getVehicles();
      if (!mounted) return;
      setState(() {
        _vehicles = vehicles
            .where(
              (vehicle) =>
                  vehicle.regNumber?.trim().isNotEmpty == true ||
                  vehicle.vehiclePassport?.trim().isNotEmpty == true,
            )
            .toList();
        if (_vehicles.length == 1) _applyVehicle(_vehicles.first, onlyIfEmpty: true);
      });
    } catch (_) {
      // Список ТС — только удобство: без него поля заполняются вручную.
    }
  }

  /// Подставляет в поля знак и свидетельство выбранного автомобиля.
  ///
  /// Явный выбор из меню заменяет оба поля целиком: оставив в них данные другой
  /// машины, пользователь получил бы в заказе чужую пару «знак — техпаспорт».
  /// Поэтому у автомобиля без свидетельства поле очищается, и проверка подсветит
  /// его как незаполненное.
  ///
  /// [onlyIfEmpty] — для автоматической подстановки единственного автомобиля:
  /// запрос приходит асинхронно и не должен затирать то, что пользователь уже
  /// успел ввести.
  void _applyVehicle(Vehicle vehicle, {bool onlyIfEmpty = false}) {
    _selectedVehicle = vehicle;
    final reg = vehicle.regNumber?.trim() ?? '';
    final cert = vehicle.vehiclePassport?.trim() ?? '';

    if (_showsRegField) {
      final keepTyped = onlyIfEmpty && _regNumber.text.trim().isNotEmpty;
      if (!keepTyped) {
        _regNumber.text = reg;
        if (reg.isNotEmpty) _markValid('reg');
      }
    }
    if (_showsCertField) {
      final keepTyped = onlyIfEmpty && _certNumber.text.trim().isNotEmpty;
      if (!keepTyped) {
        _certNumber.text = cert;
        if (cert.isNotEmpty) _markValid('cert');
      }
    }
  }

  Future<void> _pickVehicle({required bool forCert}) async {
    if (_vehicles.length <= 1) return;
    (forCert ? _certFocus : _regFocus).unfocus();
    final selected = await showVehicleMenu(
      context,
      anchorKey: forCert ? _certFieldKey : _regFieldKey,
      vehicles: _vehicles,
      // В меню знака показывается марка/модель, в меню свидетельства — знак:
      // вторая строка всегда объясняет, к какому автомобилю относится значение.
      primaryOf: (vehicle) =>
          forCert ? vehicle.vehiclePassport ?? '' : vehicle.regNumber ?? '',
      secondaryOf: (vehicle) =>
          forCert ? vehicle.regNumber ?? '' : vehicle.name ?? '',
    );
    if (selected == null || !mounted) return;
    // «Ввести вручную»: поле, а не автомобиль, — открываем клавиатуру.
    if (identical(selected, vehicleManualEntryMarker)) {
      (forCert ? _certFocus : _regFocus).requestFocus();
      return;
    }
    setState(() => _applyVehicle(selected));
  }

  /// Ручная правка отвязывает поле от выбранного автомобиля: значение больше не
  /// совпадает с данными из кабинета, и подставлять его к другой машине нельзя.
  void _unlinkVehicle(String field, String text) {
    final vehicle = _selectedVehicle;
    if (vehicle == null) return;
    final source =
        (field == 'cert'
                ? vehicle.vehiclePassport
                : vehicle.regNumber)
            ?.trim() ??
        '';
    if (text.trim() != source) setState(() => _selectedVehicle = null);
  }

  /// Стрелка меню автомобилей: появляется только когда выбирать есть из чего.
  Widget? _vehicleMenuIcon({required bool forCert}) {
    if (!_canPickVehicle) return null;
    return IconButton(
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      color: AppColors.primary,
      onPressed: () => _pickVehicle(forCert: forCert),
    );
  }

  VoidCallback? _vehicleMenuTap({required bool forCert}) => _canPickVehicle
      ? () => _pickVehicle(forCert: forCert)
      : null;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _awaitingExternalPayment) {
      _awaitingExternalPayment = false;
      _checkPaymentStatus();
    }
  }

  /// Появление и уход клавиатуры меняют только размеры вьюпорта: перестраиваем
  /// экран, чтобы кнопка «Далее» успела спрятаться или вернуться.
  @override
  void didChangeMetrics() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _priceDebounce?.cancel();
    _scrollController.dispose();
    for (final node in <FocusNode>[
      _certFocus,
      _regFocus,
      _vehicleCountFocus,
      _lastNameFocus,
      _firstNameFocus,
      _middleNameFocus,
      _emailFocus,
      _legalUnpFocus,
      _legalNameOrgFocus,
      _legalFaceFocus,
      _legalMainDocFocus,
      _legalCodePodrFocus,
      _legalLocationFocus,
      _legalBankNameFocus,
      _legalBankAccountFocus,
      _legalBankBicFocus,
      _legalEmailFocus,
    ]) {
      node.dispose();
    }
    for (final controller in <TextEditingController>[
      _certNumber,
      _regNumber,
      _vehicleCount,
      _vehicleTypeName,
      _lastName,
      _firstName,
      _middleName,
      _personalEmail,
      _legalNameOrg,
      _legalUnp,
      _legalCodePodr,
      _legalFace,
      _legalMainDoc,
      _legalLocation,
      _legalBankName,
      _legalBankAccount,
      _legalBankBic,
      _legalEmail,
      _legalPhone,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadPaymentMethods() async {
    final service = _service;
    if (service == null) return;
    final isLegal = context.read<AuthProvider>().isLegal;
    try {
      final methods = isLegal
          ? await PaymentApi.instance.getPaymentMethodsJuristic(service.id)
          : await PaymentApi.instance.getPaymentMethodsIndividual();
      if (!mounted) return;
      final normalized = methods
          .where((method) => method.title?.isNotEmpty == true)
          // «Оплати» — приложение-платёж, которое в этом приложении не
          // поддерживается, поэтому способ из списка исключается.
          .where(
            (method) =>
                classifyPaymentMethod(type: method.type, title: method.title) !=
                PaymentMethodKind.oplati,
          )
          .toList();
      setState(() {
        _paymentMethods = normalized;
        _method = normalized.isNotEmpty ? normalized.first : null;
        if (normalized.isEmpty) {
          _error = 'Не удалось загрузить способы оплаты';
        }
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _paymentMethods = const [];
        _method = null;
        _error = error is ApiException
            ? error.message
            : 'Не удалось загрузить способы оплаты';
      });
    }
    if (_paymentMethods.isEmpty) {
      debugPrint(
        'payment methods empty: isLegal=$isLegal serviceId=${service.id} '
        'title=${service.title}',
      );
    }
  }

  Future<void> _loadCertainTypes() async {
    if (!_spec.requireCertainTypes) {
      if (mounted) {
        setState(() {
          _certainTypes = const [];
          _selectedCertainTypeIds.clear();
        });
      }
      return;
    }
    setState(() {
      _loadingCertainTypes = true;
      _certainTypesError = null;
    });
    try {
      final types = await PaymentApi.instance.getCertainTypesWork();
      if (!mounted) return;
      setState(() {
        _certainTypes = types;
        _selectedCertainTypeIds.removeWhere(
          (id) => !types.any((type) => type.id == id),
        );
        if (types.isEmpty) {
          _certainTypesError = 'Не удалось загрузить виды работ';
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _certainTypes = const [];
          _selectedCertainTypeIds.clear();
          _certainTypesError = 'Не удалось загрузить виды работ';
        });
      }
    } finally {
      if (mounted) setState(() => _loadingCertainTypes = false);
    }
  }

  /// Минимальное количество ТС, заданное сервером для услуги.
  ///
  /// Приходит полем `COL_TS` в выдаче типов транспортного средства. Услуги без
  /// выбора типа ТС отдают в этой выдаче только счётчик, поэтому количество
  /// нужно брать отсюда, а не считать равным единице.
  int? _serverVehicleCount() {
    for (final type in _vehicleTypes) {
      for (final field in type.fields ?? const <VehicleTypeField>[]) {
        if (field.name.toUpperCase() != 'COL_TS') continue;
        final parsed = int.tryParse(field.min?.toString() ?? '');
        if (parsed != null && parsed > 0) return parsed;
      }
    }
    return null;
  }

  /// Количество ТС задаётся сервером и не редактируется.
  ///
  /// Исходное приложение показывает это поле нередактируемым и всегда
  /// подставляет минимум от сервера. Значение вручную можно было поставить
  /// отличное от серверного, и тогда цена не считалась.
  bool get _vehicleCountIsFixed => _serverVehicleCount() != null;

  void _applyServerVehicleCount() {
    if (!_spec.requiresVehicleCount) return;
    final value = _serverVehicleCount();
    if (value == null) return;
    if (_vehicleCount.text.trim() == value.toString()) return;
    _vehicleCount.text = value.toString();
    _markValid('count');
  }

  /// Запрашивает типы транспортного средства услуги.
  ///
  /// Выдача нужна и тем услугам, которые не спрашивают тип: в ней приходит
  /// минимальное количество ТС. Если запрос уже выполнялся, а список остался
  /// пустым, повторяем один раз — иначе после смены станции на экране останется
  /// вечное «Типы ТС не загружены».
  Future<void> _loadVehicleTypes({bool force = false}) async {
    if (!_spec.needsVehicleTypes) return;
    final service = _service;
    final station = _station;
    if (service == null || station == null) return;
    if (_loadingVehicleTypes) return;
    if (!force && _vehicleTypes.isEmpty && _vehicleTypesRequested) return;

    final requestId = ++_vehicleRequestId;
    _vehicleTypesRequested = true;
    final isLegal = context.read<AuthProvider>().isLegal;
    if (mounted) setState(() => _loadingVehicleTypes = true);
    try {
      final types = await _fetchVehicleTypes(
        serviceId: service.id,
        stationId: station.id,
        isLegal: isLegal,
      );
      if (!mounted || requestId != _vehicleRequestId) return;
      setState(() {
        // Часть вариантов скрывается правилами услуги: типы приходят с
        // сервера, и исключённые не должны попадать ни в список, ни в
        // уже выбранное значение.
        _vehicleTypes = types
            .where((type) => _spec.isVehicleTypeAllowed(type.title))
            .toList();
        _vehicleFieldValues.clear();
        _vehicleFieldKeys.clear();
        _vehicleType = null;
        _applyServerVehicleCount();
        if (_vehicleTypes.isEmpty && _spec.requiresVehicleType) {
          _error = 'Для выбранной услуги не получены типы ТС';
        }
      });
      if (types.isEmpty && _spec.requiresVehicleType) {
        debugPrint(
          'vehicle types empty: serviceId=${service.id} '
          'stationId=${station.id} title=${service.title}',
        );
      }
      _refreshPriceDebounced();
    } catch (_) {
      if (!mounted || requestId != _vehicleRequestId) return;
      setState(() {
        _vehicleTypes = const [];
        _vehicleFieldKeys.clear();
        _vehicleType = null;
        if (_spec.requiresVehicleType) {
          _error = 'Не удалось загрузить типы транспортных средств';
        }
      });
    } finally {
      if (mounted) setState(() => _loadingVehicleTypes = false);
    }
  }

  /// Типы ТС услуги: сначала выдача для юрлиц, затем для физлиц.
  ///
  /// Выдача для юрлиц — та, что использует оригинал. Если она пустая, пробуем
  /// выдачу для физлиц: каталог типов у услуг общий, и на ГТО и ЕКМТ физлиц
  /// он отдаётся, а юридическая выдача может быть пустой. Без типов шаг
  /// транспортного средства непроходим, и услуга вовсе не оформляется.
  ///
  /// Станции тоже перебираются: типы привязаны к станции, а станция из общего
  /// списка может их не отдавать.
  Future<List<VehicleType>> _fetchVehicleTypes({
    required int serviceId,
    required int stationId,
    required bool isLegal,
  }) async {
    Future<List<VehicleType>> load(int id) async {
      if (isLegal) {
        final juristic = await _tryVehicleTypes(
          () => PaymentApi.instance.getVehicleTypesJuristic(
            serviceId: serviceId,
            stationId: id,
          ),
        );
        if (juristic.isNotEmpty) return juristic;
        final individual = await _tryVehicleTypes(
          () => PaymentApi.instance.getVehicleTypes(
            serviceId: serviceId,
            stationId: id,
          ),
        );
        if (individual.isNotEmpty) {
          debugPrint(
            'vehicle types taken from the individual endpoint: '
            'serviceId=$serviceId stationId=$id',
          );
        }
        return individual;
      }
      return PaymentApi.instance.getVehicleTypes(
        serviceId: serviceId,
        stationId: id,
      );
    }

    var types = await load(stationId);
    if (types.isNotEmpty || !_spec.requiresVehicleType) return types;
    List<PaymentStation> stations;
    try {
      stations = await PaymentApi.instance.getStations(serviceId);
    } catch (_) {
      return types;
    }
    const maxAttempts = 5;
    var attempts = 0;
    for (final candidate in stations) {
      if (candidate.id == stationId || candidate.id == 0) continue;
      if (++attempts > maxAttempts) break;
      try {
        types = await load(candidate.id);
      } catch (_) {
        continue;
      }
      if (types.isNotEmpty) {
        debugPrint(
          'vehicle types found at another station: serviceId=$serviceId '
          'stationId=${candidate.id} instead of $stationId',
        );
        return types;
      }
    }
    return types;
  }

  /// Запрос типов, не падающий на недоступной выдаче.
  ///
  /// Если одна из выдач недоступна, вторая всё равно может ответить, поэтому
  /// ошибку здесь глотаем: пустой список разбирается наверху, где у него есть
  /// и сообщение пользователю, и запись в logcat.
  Future<List<VehicleType>> _tryVehicleTypes(
    Future<List<VehicleType>> Function() request,
  ) async {
    try {
      return await request();
    } catch (_) {
      return const [];
    }
  }

  ///
  /// `trans` — это сам тип ТС, он уходит отдельным ключом; `COL_TS` — счётчик
  /// количества, он уходит значением `colTs`; `KDR` — виды работ, их выбор
  /// уходит списком в `values`. Все три нельзя отправлять объектом `payment`.
  bool _isServiceLevelVehicleField(VehicleTypeField field) {
    final name = field.name.toUpperCase();
    if (name == 'COL_TS' || name == 'KDR') return true;
    return field.name.toLowerCase().replaceAll(RegExp(r'[^a-zа-яё0-9]'), '') ==
        'trans';
  }

  /// Поле количества осей в выдаче сервера: `TRANS_OS`.
  ///
  /// Уходит оно таким же именем, каким пришло. Если же оси спрашиваются
  /// отдельным полем сценария — так у ГТО, где сервер `TRANS_OS` не присылает,
  /// — поле не рисуется, иначе в выборе оказалось бы два одинаковых поля.
  bool _isAxlesField(VehicleTypeField field) {
    final normalized = field.name.toLowerCase().replaceAll(
      RegExp(r'[^a-zа-яё0-9]'),
      '',
    );
    return normalized == 'transos';
  }

  /// Нужно ли показывать и отправлять серверное поле осей.
  ///
  /// Оси — параметр только тех услуг, где сценарий прямо их запрашивает (ЕКМТ).
  /// ГТО тоже получает `TRANS_OS` от сервера, но осей не спрашивает: поле
  /// скрывается и в `payment` не уходит, иначе в форме появлялся бы лишний
  /// выпадающий список, а сервер это значение игнорирует.
  bool _isVisibleAxlesField(VehicleTypeField field) =>
      _isAxlesField(field) && _spec.showsVehicleField(field.name);

  /// Поле общей массы в выдаче сервера: `TRANS_MASSA`, в заказе — `massa`.
  ///
  /// Именно по нему выбирается диапазон, в котором спрашивается количество осей.
  bool _isMassField(VehicleTypeField field) {
    final normalized = field.name.toLowerCase().replaceAll(
      RegExp(r'[^a-zа-яё0-9]'),
      '',
    );
    return normalized == 'transmassa';
  }

  String? _missingRequiredVehicleField() {
    for (final field in _vehicleType?.fields ?? const <VehicleTypeField>[]) {
      if (_isServiceLevelVehicleField(field)) continue;
      // Скрытое серверное поле осей не показывается, значит и требовать его
      // заполнения нельзя — иначе шаг был бы непроходим.
      if (_isAxlesField(field) && !_isVisibleAxlesField(field)) continue;
      // Поле без вариантов выбора заполнить нельзя: требовать его значит
      // заблокировать оформление заказа. Такие поля просто не показываем.
      if (_isUnselectableField(field)) continue;
      if (field.isRequired && !_vehicleFieldValues.containsKey(field.name)) {
        return field.title;
      }
    }
    return null;
  }

  /// Поле ТС, которому нечем заполняться: сервер не прислал вариантов.
  ///
  /// Например, у прицепа масса зашита в название типа («Прицеп/полуприцеп от 0,7
  /// до 3,5 т»), и отдельного списка значений для неё нет. Показывать
  /// неактивный выпадающий список бессмысленно, и он же блокировал расчёт
  /// стоимости.
  bool _isUnselectableField(VehicleTypeField field) =>
      (field.values?.isEmpty ?? true);

  /// Варианты поля ТС: у осей они зависят от выбранного типа.
  ///
  /// У ЕКМТ сервер присылает один список осей на все типы: одиночному ТС
  /// подходят простые числа (2, 3), а комбинации «грузовик + прицеп» —
  /// составные («2+2», «2+3» и т.п.). Без разбора в обоих случаях предлагались
  /// бы все восемь значений: у одиночного ТС — оси прицепа, у комбинации —
  /// оси одиночного, и цену нельзя было посчитать правильно.
  List<DropdownValue> _vehicleFieldOptions(VehicleTypeField field) {
    final values = field.values ?? const <DropdownValue>[];
    final type = _vehicleType;
    if (type == null || !_isVisibleAxlesField(field)) return values;
    return _spec.filterAxlesValues(type.title, values);
  }

  /// Имя поля ТС в том виде, в котором его ждёт сервер.
  String _paymentFieldKey(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('mass')) return 'massa';
    if (normalized.contains('motor')) return 'motor';
    if (normalized.contains('kol')) return 'kol';
    if (normalized.contains('trans_os') || normalized == 'transos') {
      return 'trans_os';
    }
    return name;
  }

  /// Тело запроса стоимости и регистрации заказа.
  ///
  /// Набор ключей повторяет контракт исходного приложения: `type` уходит
  /// только для физлиц, а `certNumber` и `regNumber` отправляются лишь при
  /// регистрации заказа, но не в расчёт цены.
  ///
  /// `colTs` отправляется только тем услугам, которые реально спрашивают
  /// количество транспорта: у услуг с типом ТС счётчик не запрашивается, и
  /// лишнее значение сервер трактует как число печатаемых карт.
  ///
  /// Печать диагностической карты, из-за которой в ЕРИП сумма выходила на 5 BYN
  /// больше показанной, отключается флагом `PRINT_DK` в объекте `payment`.
  Map<String, dynamic> _pricePayload() {
    final payload = <String, dynamic>{
      'serviceId': _service!.id,
      if (_station != null) 'stationId': _station!.id,
      // `type` уходит только для физлиц и только когда сервер его прислал.
      //
      // Раньше при отсутствии значения подставлялась строка `DEF`. Исходное
      // приложение этого не делает: там пустое значение просто не отправляется.
      // С такой подстановкой сумма выходила на 5 BYN больше, чем в расчёте, —
      // совпадало с ценой с печатью диагностической карты.
      if (!_isLegal && _service!.type?.trim().isNotEmpty == true)
        'type': _service!.type!.trim(),
    };
    if (_spec.requiresVehicleCount) {
      final count = int.tryParse(_vehicleCount.text.trim());
      if (count != null && count > 0) payload['colTs'] = count;
    }
    if (_vehicleType != null) {
      final payment = <String, dynamic>{
        'trans': _vehicleType!.id,
        // Без этого признака сервер считает заказ «с печатью диагностической
        // карты» и добавляет к цене её стоимость: в ЕРИП сумма выходила на
        // 5 BYN больше показанной. `1` — без печати.
        'PRINT_DK': 1,
      };
      for (final field in _vehicleType!.fields ?? const <VehicleTypeField>[]) {
        if (_isServiceLevelVehicleField(field)) continue;
        // Оси берутся из отдельного поля сценария, поэтому значение серверного
        // поля TRANS_OS сюда не попадает — иначе в выборе было бы два поля.
        if (_isAxlesField(field) && !_hasServerAxlesField) continue;
        final value = _vehicleFieldValues[field.name];
        if (value != null) {
          payment[_paymentFieldKey(field.name)] = value.apiValue;
        }
      }
      // Оси, выбранные отдельным полем сценария, уходят ключом `os` внутри
      // `payment` и значением справочника, а не числом осей: у прицепа одна
      // ось — это `111`, две — `49`. Ключ `trans_os` сервер не смотрит, с ним
      // цена оставалась нулевой.
      //
      // Поле `TRANS_OS`, пришедшее от сервера, сюда не попадает: его вид и
      // значения задаёт сервер, и ЕКМТ по-прежнему получает своё `trans_os`.
      if (_showsAxlesField && _axlesCount != null) {
        payment['os'] = _spec.axlesApiId(_axlesCount!);
      }
      payload['payment'] = payment;
    }
    if (_spec.requireCertainTypes && _selectedCertainTypeIds.isNotEmpty) {
      payload['values'] = _selectedCertainTypeIds.toList();
    }
    return payload;
  }

  Future<void> _loadPrice() async {
    if (_service == null) return;
    // Без места оказания услуги сервер цену не считает.
    if (_station == null && _spec.requiresStation) return;
    // Пока не выбраны виды работ, сумма не считается: запрос только мешал бы.
    if (_spec.requireCertainTypes && _selectedCertainTypeIds.isEmpty) return;
    final requestId = ++_priceRequestId;
    final isLegal = context.read<AuthProvider>().isLegal;
    setState(() {
      _loadingPrice = true;
      _price = null;
    });
    try {
      final payload = _pricePayload();
      // Состав запроса печатается только в debug-сборке: в теле есть
      // персональные данные, и в релизе они не должны попадать в логи.
      if (kDebugMode) {
        debugPrint(
          'price request: service=${_service?.id} type=${_service?.type} '
          'station=${_station?.id} trans=${_vehicleType?.title} '
          'body=${jsonEncode(payload)}',
        );
      }
      final response = isLegal
          ? await PaymentApi.instance.getPriceJuristic(payload)
          : await PaymentApi.instance.getPrice(payload);
      final price = PriceInfo.fromResponse(response);
      // Ответ печатается только в debug-сборке: вместе с суммой сервер может
      // прислать и параметры заказа, а в лог релизной сборки им нельзя.
      if (kDebugMode) {
        debugPrint(
          'price response: serviceId=${_service?.id} '
          'stationId=${_station?.id} body=${jsonEncode(response)} '
          'parsed=${price.price}',
        );
      }
      if (!mounted || requestId != _priceRequestId) return;
      setState(() => _price = price);
      if (price.price == null) {
        // Стоимость не разобралась: без ответа сервера причину не понять, а
        // пользователь видит пустое поле. Пишем ответ вместе с параметрами
        // выбранного типа — по нему видно, чего не хватило серверу. Только в
        // debug-сборке: ответ содержит персональные данные.
        if (kDebugMode) {
          debugPrint(
            'price not parsed: serviceId=${_service?.id} '
            'stationId=${_station?.id} '
            'type=${_vehicleType?.title} '
            'fields=${_vehicleType?.fields?.map((f) => '${f.name}:${f.values?.length}').join(',')} '
            'selected=${_vehicleFieldValues.keys.join(',')} '
            'response=$response',
          );
        }
      }
    } catch (error) {
      if (!mounted || requestId != _priceRequestId) return;
      setState(() => _price = null);
      if (kDebugMode) {
        debugPrint(
          'price failed: serviceId=${_service?.id} stationId=${_station?.id} '
          'type=${_vehicleType?.title} error=$error',
        );
      }
    } finally {
      if (mounted && requestId == _priceRequestId) {
        setState(() => _loadingPrice = false);
      }
    }
  }

  void _ensureFieldVisible(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fieldContext = key.currentContext;
      if (!mounted || fieldContext == null) return;
      Scrollable.ensureVisible(
        fieldContext,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        alignment: 0.35,
      );
    });
  }

  void _resetPrice() {
    _priceRequestId++;
    _loadingPrice = false;
    _price = null;
  }

  /// Пересчитывает стоимость после изменения количества ТС или осей, типа ТС
  /// либо его параметров. Запрос откладывается, чтобы не слать его на ввод.
  void _refreshPriceDebounced() {
    _resetPrice();
    _priceDebounce?.cancel();
    final count = int.tryParse(_vehicleCount.text.trim());
    if (_spec.requiresVehicleCount && (count == null || count < 1)) return;
    if (_spec.requiresVehicleType && _vehicleType == null) return;
    if (_showsAxlesField && _selectedAxles == null) return;
    if (_spec.requireCertainTypes && _selectedCertainTypeIds.isEmpty) return;
    _priceDebounce = Timer(const Duration(milliseconds: 400), () {
      _loadPrice();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Настоящие отступы клавиатуры берём из вьюпорта: внешний Scaffold оболочки
    // срезает `viewInsets` из MediaQuery тела, и `MediaQuery.viewInsetsOf`
    // внутри экрана всегда показал бы ноль.
    final keyboardVisible = View.of(context).viewInsets.bottom > 0;
    return PopScope<void>(
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _step > 0) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Оплата услуг'),
          automaticallyImplyLeading: false,
          leading: AppBackButton(onPressed: _handleBack),
        ),
        // Нижний отступ кнопки считаем сами через bikeNavBottomInset: SafeArea с
        // bottom: true добавлял высоту нижней навигации повторно, и кнопка
        // «Далее» висела выше панели, перекрывая реквизиты организации. На
        // время ввода кнопка прячется совсем: под клавиатурой нижней навигации
        // нет, а кнопка на её месте закрывала бы поля реквизитов.
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _Stepper(currentStep: _step, totalSteps: _steps.length),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Text(
                  _currentSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_error != null) ...[
                        _ErrorBanner(message: _error!),
                        const SizedBox(height: 12),
                      ],
                      ..._buildCurrentStep(),
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
                  child: _buildBottomButton(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCurrentStep() {
    // Цепочка фокуса всегда соответствует видимым полям текущего шага.
    _focusChain.clear();
    return switch (_currentStep) {
      FlowStep.station => [_buildStationStep()],
      FlowStep.method => [_buildMethodStep()],
      FlowStep.personal => [_buildDetailsStep()],
      FlowStep.vehicle => [_buildVehicleStep()],
      FlowStep.order => [_buildConfirmStep()],
    };
  }

  void _handleBack() {
    // Назад — это всегда предыдущий шаг, включая последний. Раньше на последнем
    // шаге кнопка уводила сразу к списку заказов, и возврат выглядел как
    // переход в начало. Выход из оплаты остаётся только на первом шаге.
    if (_step > 0) {
      setState(() {
        // Возврат с шага заказа отменяет созданный заказ: иначе при повторном
        // входе на шаг старый заказ и сумма остались бы висеть, а при сбое
        // создания нового кнопка оплаты вела бы к устаревшему заказу.
        if (_currentStep == FlowStep.order) {
          _order = null;
          _orderTotal = null;
          _documents = const [];
          _paymentStatus = _PaymentStatus.created;
          _paymentStatusMessage = null;
        }
        _step--;
        _error = null;
      });
      return;
    }
    if (context.canPop()) context.pop();
  }

  /// Разобранная положительная стоимость, либо null, если цена неизвестна.
  double? get _priceValue => _parseAmount(_price?.price);

  /// Расчёт стоимости как запасной итог заказа.
  ///
  /// Часть услуг (международный сертификат, ЕКМТ, свидетельство о допуске к
  /// перевозке опасных грузов) при оплате через ЕРИП получает заказ вообще без
  /// суммы: ни в подписанной форме, ни отдельным полем, ни в тексте инструкции
  /// её нет, и раньше показывалось «Стоимость заказа не получена — оплата
  /// недоступна», хотя услуга прекрасно оплачивается.
  ///
  /// Единственная серверная цифра в таком заказе — расчёт `legal-price.php`, и
  /// у услуг со счётчиком транспорта он и есть итог: то же количество ТС уходит
  /// и в расчёт, и в заказ, поэтому расхождения между ними не возникает.
  ///
  /// Подстановка ограничена такими услугами намеренно: у ГТО расчёт на 5 BYN
  /// меньше итога, потому что в него не входит печать диагностической карты, и
  /// показывать расчёт вместо итога там по-прежнему нельзя.
  double? get _calculatedOrderTotal =>
      _spec.mayUseCalculationAsTotal ? _priceValue : null;

  /// Сумма сервера в виде числа; ноль и нечисловой текст — это отсутствие цены.
  static double? _parseAmount(String? raw) {
    final text = raw?.trim();
    if (text == null || text.isEmpty) return null;
    final value = double.tryParse(
      text.replaceAll(',', '.').replaceAll(' ', ''),
    );
    if (value == null || value <= 0) return null;
    return value;
  }

  Widget _buildBottomButton() {
    final isLast = _isLastStep;
    final noncash = _isNoncashOrder();
    final paid = _paymentStatus == _PaymentStatus.paid;
    final pending = _paymentStatus == _PaymentStatus.pending;
    // Заказ мог не создаться — тогда на последнем шаге должна оставаться
    // возможность создать его заново.
    if (isLast && _order == null) {
      return RNButton(
        title: 'Создать заказ',
        type: ButtonType.empty,
        onPress: _createOrder,
        loading: _loading || _loadingPrice,
      );
    }
    // Оплата в ЕРИП и безналичный перевод не требуют действия в приложении:
    // заказ уже зарегистрирован, документы выбираются на этом же шаге.
    if (isLast && (_isEripOrder || noncash) && !paid) {
      return RNButton(
        title: 'Перейти к заказам',
        type: ButtonType.fill,
        onPress: _goToPaymentHistory,
        loading: _loading,
      );
    }
    // На последнем шаге оплачивать нельзя, пока сервер не вернул сумму заказа.
    // Расчёт с шага способа оплаты для этого не годится: у ГТО он на 5 BYN
    // меньше списываемого, и блокировать оплату по нему значило бы разрешить
    // платить по неизвестной цене.
    final priceBlocked =
        isLast && !paid && !pending && noncash == false && _orderTotal == null;
    // Отдельной кнопки проверки статуса нет: после возврата из платёжной
    // системы статус запрашивается сам, здесь полезно только повторить оплату.
    final title = !isLast
        ? 'Далее'
        : paid
        ? 'Вернуться к списку услуг'
        : 'Оплатить';
    final action = !isLast
        ? _next
        : paid
        ? _goToPaymentHistory
        : _pay;
    return RNButton(
      title: priceBlocked ? 'Дождитесь расчёта стоимости' : title,
      type: ButtonType.empty,
      onPress: priceBlocked
          ? () => _showHint('Стоимость не рассчитана, оплата недоступна')
          : action,
      disabled: priceBlocked,
      loading: _loading || _loadingPrice,
    );
  }

  void _showHint(String message) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Проверка e-mail по стандарту RFC 2822 (как требует сервер).
  bool _isValidEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return false;
    return RegExp(
      r"^[A-Za-z0-9!#$%&'*+/=?^_`{|}~\-]+(\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~\-]+)*"
      r'@(?:[A-Za-z0-9](?:[A-Za-z0-9\-]*[A-Za-z0-9])?\.)+[A-Za-z]{2,}$',
    ).hasMatch(email);
  }

  bool _isValidCertificate(String value) => isValidCertNumber(value);

  Future<void> _next() async {
    setState(() => _error = null);
    if (_isLastStep) {
      await _pay();
      return;
    }
    if (!_validateCurrentStep()) {
      // Пользователю показывается всплывающая подсказка с названием первого
      // незаполненного поля, а экран подводится к нему.
      _showMissingFieldHint();
      return;
    }
    // На шаге со стоимостью нельзя идти дальше, пока сумма считается.
    if (_currentStep == _priceStep && _loadingPrice) {
      _showHint('Дождитесь загрузки стоимости');
      return;
    }
    setState(() => _step++);
    if (_currentStep == FlowStep.order) await _createOrder();
  }

  /// Подсказка о незаполненном поле.
  ///
  /// Показывает всплывающее окно с названием поля, которое предстоит заполнить,
  /// и прокручивает к нему: поле часто находится ниже видимой части экрана, и
  /// пользователь не понимает, о чём речь.
  void _showMissingFieldHint() {
    if (_invalidFields.isEmpty) return;
    final field = _invalidFields.first;
    final title = _fieldTitles[field] ?? 'Нужное поле';
    _showHint(_fieldProblems[field] ?? 'Заполните поле «$title»');
    final focus = _focusForField(field);
    focus?.requestFocus();

    void reveal() {
      if (!mounted) return;
      final targetContext =
          _fieldKeys[field]?.currentContext ?? focus?.context;
      if (targetContext == null || !targetContext.mounted) return;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.35,
      );
    }

    // Первый вызов подводит экран сразу, второй — после появления клавиатуры:
    // иначе поле, поднятое клавиатурой, снова оказывается частично скрытым.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      reveal();
      Future.delayed(const Duration(milliseconds: 300), reveal);
    });
  }

  bool _validateCurrentStep() {
    _clearInvalid();
    switch (_currentStep) {
      case FlowStep.station:
        if (_service == null) {
          _showHint('Выберите услугу');
          return false;
        }
        if (_spec.requiresStation && _station == null) {
          _markInvalid('station');
          _showHint('Выберите место оказания услуги');
          return false;
        }
        return true;
      case FlowStep.method:
        if (_method == null) {
          _markInvalid('method');
          _showHint('Выберите способ оплаты');
          return false;
        }
        return true;
      case FlowStep.personal:
        return _isLegal ? _validateLegalDetails() : _validatePersonalDetails();
      case FlowStep.vehicle:
        // Типы ТС могли не прийти: без них шаг непроходим, и повторяем запрос.
        if (_spec.requiresVehicleType &&
            _vehicleTypes.isEmpty &&
            !_loadingVehicleTypes) {
          _loadVehicleTypes(force: true);
          _showHint('Загрузите типы транспортных средств');
          return false;
        }
        if (_spec.requireCertainTypes && _selectedCertainTypeIds.isEmpty) {
          _markInvalid('certainTypes');
        }
        _validateVehicleFields();
        return _invalidFields.isEmpty;
      case FlowStep.order:
        return true;
    }
  }

  /// Минимальная длина наименования организации.
  ///
  /// Требование сервера, а не оформления: в исходном приложении проверялось
  /// при регистрации.
  static const _minNameOrgLength = 6;

  /// Минимальная длина места нахождения.
  static const _minLocationLength = 14;

  /// Проверка реквизитов организации.
  ///
  /// Проверяются только те реквизиты, которые услуга запрашивает: требовать
  /// банковские данные у техосмотра, где их не спрашивают, нельзя.
  bool _validateLegalDetails() {
    if (_fieldKeys['cert'] == null) _fieldKeys['cert'] = _certFieldKey;
    if (_fieldKeys['reg'] == null) _fieldKeys['reg'] = _regFieldKey;
    for (final field in _spec.legalRequisites) {
      switch (field) {
        case LegalField.unp:
          if (!isValidUnp(_legalUnp.text)) _markInvalid('legalUnp');
        case LegalField.codePodr:
          break;
        case LegalField.nameOrg:
          if (_legalNameOrg.text.trim().length < _minNameOrgLength) {
            _markInvalid('legalNameOrg');
          }
        case LegalField.face:
          if (_legalFace.text.trim().isEmpty) _markInvalid('legalFace');
        case LegalField.mainDoc:
          if (_legalMainDoc.text.trim().isEmpty) _markInvalid('legalMainDoc');
        case LegalField.cert:
          if (!_isValidCertificate(_certNumber.text.trim())) {
            _markInvalid('cert');
          }
        case LegalField.regNumber:
          if (_regNumber.text.trim().isEmpty) _markInvalid('reg');
        case LegalField.location:
          if (_legalLocation.text.trim().length < _minLocationLength) {
            _markInvalid('legalLocation');
          }
        case LegalField.bankAccount:
          if (_legalBankAccount.text.trim().length < 20) {
            _markInvalid('legalBankAccount');
          }
        case LegalField.bankName:
          if (_legalBankName.text.trim().length < 7) {
            _markInvalid('legalBankName');
          }
        case LegalField.bankBic:
          if (_legalBankBic.text.trim().length < 6) {
            _markInvalid('legalBankBic');
          }
        case LegalField.email:
          if (!_isValidEmail(_legalEmail.text)) _markInvalid('legalEmail');
      }
    }
    return _invalidFields.isEmpty;
  }

  /// Проверка личных данных физлица вместе со свидетельством о регистрации.
  bool _validatePersonalDetails() {
    if (_lastName.text.trim().isEmpty) _markInvalid('lastName');
    if (_firstName.text.trim().isEmpty) _markInvalid('firstName');
    if (_spec.requireCert && !_isValidCertificate(_certNumber.text.trim())) {
      _markInvalid('cert');
    }
    if (_fieldKeys['cert'] == null) _fieldKeys['cert'] = _certFieldKey;
    if (_fieldKeys['reg'] == null) _fieldKeys['reg'] = _regFieldKey;
    if (_requiresRegistrationNumber && _regNumber.text.trim().isEmpty) {
      _markInvalid('reg');
    }
    if (!_isValidEmail(_personalEmail.text)) _markInvalid('email');
    return _invalidFields.isEmpty;
  }

  /// Проверка полей транспортного средства.
  void _validateVehicleFields() {
    if (_spec.requiresVehicleCount) {
      final count = int.tryParse(_vehicleCount.text.trim());
      if (count == null || count < 1) _markInvalid('count');
    }
    if (_spec.requiresVehicleType) {
      if (_vehicleType == null) {
        _markInvalid('vehicleType');
      } else if (_missingRequiredVehicleField() != null) {
        _markInvalid('vehicleType');
      }
    }
    if (_showsAxlesField && _selectedAxles == null) {
      _markInvalid('axles');
    }
  }

  Future<void> _createOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = context.read<AuthProvider>();
      final profile = auth.profile;
      if (auth.isLegal) {
        // Проверяем только те реквизиты, которые услуга запрашивает: у
        // техосмотра банковские поля не спрашиваются и остаются пустыми.
        if (_spec.legalRequisites.contains(LegalField.nameOrg) &&
            _legalNameOrg.text.trim().length < _minNameOrgLength) {
          throw ApiException('Укажите наименование организации');
        }
        if (_spec.legalRequisites.contains(LegalField.unp) &&
            normalizeUnp(_legalUnp.text).length != 9) {
          throw ApiException('Укажите корректный УНП');
        }
        if (_spec.legalRequisites.contains(LegalField.email) &&
            !_legalEmail.text.trim().contains('@')) {
          throw ApiException('Укажите корректный Email');
        }
      }
      final method = _method;
      if (method == null) {
        throw ApiException('Выберите способ оплаты');
      }
      final payload = _pricePayload();
      // Свою цену в заказе не отправляем, как и исходное приложение: сервер
      // берёт её сам, без добавления стоимости печати диагностической карты.
      // Отправка `price` была причиной того, что в WebPay сумма выходила на
      // 5 BYN больше, чем показывал расчёт: у сайта две цены — с печатью
      // карты и без неё.
      payload['payMethod'] = method.apiValue;
      // Пустые значения серверные проверки считают ошибкой, поэтому
      // отправляем только то, что реально заполнено.
      final certNumber = _certNumber.text.trim();
      if (certNumber.isNotEmpty) payload['certNumber'] = certNumber;
      final regNumber = _regNumber.text.trim();
      if (regNumber.isNotEmpty) payload['regNumber'] = regNumber;

      if (auth.isLegal) {
        final fio =
            profile?.fio ??
            [
              profile?.lastName,
              profile?.name,
              profile?.secondName,
            ].whereType<String>().where((value) => value.isNotEmpty).join(' ');
        final legalFields = <String, dynamic>{
          'unp': normalizeUnp(_legalUnp.text),
          'nameOrg': _legalNameOrg.text.trim(),
          'fio': fio,
          'face': _legalFace.text.trim(),
          'mainDoc': _legalMainDoc.text.trim(),
          'legalPhone': _legalPhone.text.trim(),
          'email': _legalEmail.text.trim(),
          'codePodr': _legalCodePodr.text.trim(),
          'location': _legalLocation.text.trim(),
          'bankName': _legalBankName.text.trim(),
          'bankBic': _legalBankBic.text.trim(),
          'bankAccount': _legalBankAccount.text.trim(),
        };
        for (final entry in legalFields.entries) {
          if (entry.value.toString().isNotEmpty) {
            payload[entry.key] = entry.value;
          }
        }
      } else {
        final lastName = _lastName.text.trim().isNotEmpty
            ? _lastName.text.trim()
            : profile?.lastName ?? '';
        final firstName = _firstName.text.trim().isNotEmpty
            ? _firstName.text.trim()
            : profile?.name ?? '';
        final middleName = _middleName.text.trim().isNotEmpty
            ? _middleName.text.trim()
            : profile?.secondName ?? '';
        final email = _personalEmail.text.trim().isNotEmpty
            ? _personalEmail.text.trim()
            : profile?.email ?? '';
        final fio = [
          lastName,
          firstName,
          middleName,
        ].where((value) => value.isNotEmpty).join(' ');
        payload
          ..['firstName'] = firstName
          ..['familyName'] = lastName
          ..['surName'] = middleName
          // Часть версий API ждёт те же поля в нижнем регистре.
          ..['firstname'] = firstName
          ..['familyname'] = lastName
          ..['surname'] = middleName
          ..['name'] = firstName
          ..['lastName'] = lastName
          ..['patronymic'] = middleName
          ..['secondName'] = middleName
          ..['fio'] = fio
          ..['email'] = email;
      }

      final order = auth.isLegal
          ? await PaymentApi.instance.getOrderInfoJuristic(payload)
          : await PaymentApi.instance.getOrderInfoIndividual(payload);
      // Тело заказа печатается только в debug-сборке: в нём персональные
      // данные (ФИО, email, реквизиты), которые не должны попадать в логи
      // релизной сборки.
      if (kDebugMode) {
        debugPrint(
          'order request: legal=${auth.isLegal} '
          'service=${_service?.id} body=${jsonEncode(payload)}',
        );
      }
      if (!mounted) return;
      if (order == null || !_hasOrderPaymentData(order)) {
        setState(() => _error = 'Сервер не вернул данные для оплаты');
        return;
      }
      setState(() {
        _order = order;
        _paymentStatus = _PaymentStatus.created;
        _paymentStatusMessage = _isEripOrder
            ? 'Заказ зарегистрирован. Оплатите его в системе «Расчёт» (ЕРИП)'
            : _isNoncashOrder()
            ? 'Заказ зарегистрирован. Выберите документ для скачивания'
            : 'Заказ зарегистрирован, но оплата ещё не подтверждена';
        _step = _steps.length - 1;
        // Итог заказа — это ровно та сумма, которую спишут. Расчёт остаётся на
        // шаге способа оплаты, а здесь показывается серверное число, чтобы
        // перед оплатой не пришлось гадать, почему цифра изменилась. Если сервер
        // сумму не вернул вовсе, у услуг со счётчиком транспорта итогом
        // считается расчёт — см. [_calculatedOrderTotal].
        _orderTotal = _parseAmount(order.price) ?? _calculatedOrderTotal;
      });
      // Заказ появился в истории: сообщаем экрану истории, чтобы он перечитал
      // список. Иначе новый заказ был бы виден только после перезапуска.
      markHistoryChanged();
      // Документы приходят с заказом. Услуги без скачивания их не грузим.
      // У остальных берём заказ и шаблоны услуги вместе: у юрлиц заказ документы
      // не возвращает, а шаблоны содержат идентификаторы, без которых ссылка
      // не скачивается.
      if (_spec.allowsDocumentDownload) {
        final documents = <DocumentTemplate>[
          ...order.documents ?? const <DocumentTemplate>[],
        ];
        try {
          for (final template in await PaymentApi.instance.getDocsTemplates(
            _service!.id,
          )) {
            documents.add(template);
          }
        } catch (_) {}
        if (mounted) {
          setState(() => _documents = _downloadableDocuments(documents));
        }
        if (_documents.isEmpty && mounted) {
          debugPrint(
            'documents empty: serviceId=${_service?.id} '
            'orderDocuments=${order.documents?.length} method=${_method?.title}',
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Произошла ошибка');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _validateWebPayForm(WebPayForm form) {
    const required = [
      'wsb_storeid',
      'wsb_order_num',
      'wsb_currency_id',
      'wsb_version',
      'wsb_seed',
      'wsb_signature',
      'wsb_test',
      'wsb_total',
    ];
    final missing = required
        .where(
          (key) =>
              !form.rawFields.containsKey(key) ||
              form.rawFields[key] == null ||
              form.rawFields[key].toString().trim().isEmpty,
        )
        .toList();
    for (final key in const [
      'wsb_invoice_item_name',
      'wsb_invoice_item_quantity',
      'wsb_invoice_item_price',
    ]) {
      final indexedKey = '$key[0]';
      final hasIndexed = form.rawFields.containsKey(indexedKey);
      final hasScalar = form.rawFields.containsKey(key);
      final value = hasIndexed
          ? form.rawFields[indexedKey]
          : hasScalar
          ? form.rawFields[key]
          : null;
      if ((!hasIndexed && !hasScalar) ||
          value == null ||
          value.toString().trim().isEmpty) {
        missing.add(key);
      }
    }
    if (missing.isNotEmpty) {
      throw ApiException(
        'Платёжная форма заполнена не полностью',
        details: missing.join(', '),
      );
    }
  }

  /// Поля платёжной формы для отправки шлюзу.
  ///
  /// Сервер сам считает подпись по `wsb_seed`, `wsb_storeid`, `wsb_order_num`,
  /// `wsb_test`, `wsb_currency_id` и `wsb_total`, поэтому эти значения
  /// передаются без изменений: любая правка ломает подпись, и шлюз отклоняет
  /// платёж. Недостающие поля добавляются из разобранной формы, а позиции
  /// счёта — из суммы заказа, иначе шлюз не увидит, за что платят.
  Map<String, dynamic> _webPayFields(WebPayForm form, double? total) {
    final fields = <String, dynamic>{...form.rawFields};

    void keep(String key, Object? value) {
      if (value == null) return;
      if (fields.containsKey(key)) return;
      final text = value.toString();
      if (text.isEmpty) return;
      fields[key] = value;
    }

    keep('wsb_storeid', form.wsbStoreid);
    keep('wsb_order_num', form.wsbOrderNum);
    keep('wsb_currency_id', form.wsbCurrencyId);
    keep('wsb_version', form.wsbVersion ?? '2');
    keep('wsb_seed', form.wsbSeed);
    keep('wsb_signature', form.wsbSignature);
    keep('wsb_test', form.wsbTest ?? '0');
    keep('wsb_total', form.wsbTotal);
    keep('wsb_email', form.wsbEmail);
    keep('wsb_return_url', form.wsbReturnUrl);
    keep('wsb_notify_url', form.wsbNotifyUrl);

    // Позиции счёта. Сервер присылает их уже посчитанными, но если не
    // прислал, их нужно собрать: без `wsb_invoice_item_*` платёж не проходит.
    if (_webPayField(fields, 'wsb_invoice_item_name') == null) {
      final amount = total ?? _webPayAmount(fields['wsb_total']);
      if (amount != null) {
        final count = _spec.requiresVehicleCount
            ? int.tryParse(_vehicleCount.text.trim())
            : null;
        final quantity = count != null && count > 0 ? count : 1;
        fields['wsb_invoice_item_name[0]'] = _service?.title ?? 'Услуга';
        fields['wsb_invoice_item_quantity[0]'] = quantity;
        fields['wsb_invoice_item_price[0]'] = amount / quantity;
      }
    }

    // `*scart` шлюз ждёт пустым, остальные пустые значения убираем: в
    // form-urlencoded они ушли бы как пустая строка и ломали бы проверку.
    fields['*scart'] = fields['*scart'] ?? '';
    fields.removeWhere(
      (key, value) =>
          key != '*scart' && (value == null || value.toString().isEmpty),
    );
    return fields;
  }

  /// Значение поля позиции счёта с учётом индексированного имени.
  Object? _webPayField(Map<String, dynamic> fields, String key) {
    final indexed = fields['$key[0]'];
    if (indexed != null && indexed.toString().isNotEmpty) return indexed;
    final scalar = fields[key];
    if (scalar != null && scalar.toString().isNotEmpty) return scalar;
    return null;
  }

  double? _webPayAmount(Object? raw) {
    final text = raw?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return double.tryParse(text.replaceAll(',', '.').replaceAll(' ', ''));
  }

  String? _webPayRedirect(Object? value) {
    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? null : text;
    }
    if (value is Map) {
      for (final key in const [
        'redirectUrl',
        'redirect_url',
        'redirectURL',
        'url',
        'href',
        'data',
      ]) {
        final redirect = _webPayRedirect(value[key]);
        if (redirect != null) return redirect;
      }
      return null;
    }
    if (value is List) {
      for (final item in value) {
        final redirect = _webPayRedirect(item);
        if (redirect != null) return redirect;
      }
    }
    return null;
  }

  /// Есть ли в ответе заказа хоть что-то, с чем можно работать дальше.
  ///
  /// У ЕРИП сервер возвращает только текст инструкции, у банковского перевода —
  /// документы, поэтому одного `linkToPay` мало: заказ считается созданным,
  /// если есть номер, ссылка, форма, инструкция или документы.
  bool _hasOrderPaymentData(OrderInfo order) =>
      order.orderId?.trim().isNotEmpty == true ||
      order.linkToPay?.isNotEmpty == true ||
      order.webpayForm != null ||
      order.documents?.isNotEmpty == true ||
      order.info?.trim().isNotEmpty == true ||
      order.infoHtml?.trim().isNotEmpty == true;

  Future<void> _openPaymentUrl(String url, {String? baseUrl}) async {
    var uri = Uri.tryParse(url);
    if (uri == null) throw ApiException('Некорректная ссылка оплаты');
    if (!uri.hasScheme && baseUrl != null) {
      final base = Uri.tryParse(baseUrl);
      if (base != null && base.hasScheme) uri = base.resolve(url);
    }
    if (!uri.hasScheme) throw ApiException('Некорректная ссылка оплаты');
    _awaitingExternalPayment = true;
    var opened = false;
    try {
      opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      opened = false;
    }
    if (!opened && mounted) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(builder: (_) => _WebPayScreen(url: uri.toString())),
      );
      if (mounted) {
        _awaitingExternalPayment = false;
        await _checkPaymentStatus();
      }
    }
  }

  /// Скачивание выбранного документа заказа.
  Future<void> _downloadDocument(DocumentTemplate document) async {
    final orderId = _order?.orderId;
    if (orderId == null || orderId.isEmpty) {
      setState(() => _error = 'Сервер не вернул номер заказа');
      return;
    }
    final uri = await PaymentApi.instance.documentDownloadUri(
      href: document.href,
      title: document.value ?? document.title,
      templateId: _documentId(document),
      orderId: orderId,
    );
    if (uri == null) {
      setState(() => _error = 'Не удалось сформировать ссылку на документ');
      return;
    }
    setState(() {
      _error = null;
      _paymentStatusMessage = 'Документ «${_documentLabel(document)}» открыт';
    });
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      setState(() => _error = 'Не удалось открыть документ');
    }
  }

  Future<void> _pay() async {
    final order = _order;
    if (order == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final kind = _paymentKind(order);
      if (kind == PaymentMethodKind.noncash) {
        // Безнал суммой не списывает: платёж идёт по счёту из документа
        // заказа, поэтому за её отсутствие в ответе ругаться не на что.
        if (mounted) {
          setState(() {
            _paymentStatus = _PaymentStatus.pending;
            _paymentStatusMessage = _order?.documents?.isNotEmpty == true
                ? 'Оплатите услугу переводом и скачайте документ заказа'
                : 'Оплатите услугу переводом. Документы доступны в истории заказов';
          });
        }
        return;
      }
      // Оплата по карте и через ЕРИП списывает сумму заказа. Если сервер её не
      // вернул, идти в платёжную систему нельзя: пользователь увидит там цену,
      // которой в приложении нет, а расчёт на 5 BYN меньше списываемого.
      if (_orderTotal == null) {
        setState(() => _error = 'Стоимость не рассчитана, проверьте данные');
        return;
      }
      if (kind == PaymentMethodKind.erip) {
        if (mounted) {
          setState(() {
            _paymentStatus = _PaymentStatus.pending;
            _paymentStatusMessage =
                'Следуйте инструкции ЕРИП; оплата ещё не подтверждена';
          });
        }
        return;
      }
      if (kind == PaymentMethodKind.webpay && order.webpayForm != null) {
        final form = order.webpayForm!;
        _validateWebPayForm(form);
        if (form.action == null || form.action!.isEmpty) {
          throw ApiException('Не указан адрес платёжной системы');
        }
        var openedByApi = false;
        // Подпись формы серверная, но если позиций в ней нет, они добавляются
        // нами — тогда суммой позиции должен быть итог заказа, а не расчёт.
        final fields = _webPayFields(form, _orderTotal);
        // Только в debug-сборке и без подписи/seed: это секреты платёжной
        // формы, по которым можно подделать платёж.
        if (kDebugMode) {
          debugPrint(
            'webpay: order=${order.orderId} total=${fields['wsb_total']} '
            'store=${fields['wsb_storeid']} '
            'item=${fields['wsb_invoice_item_name[0]']} '
            'price=${fields['wsb_invoice_item_price[0]']} '
            'quantity=${fields['wsb_invoice_item_quantity[0]']}',
          );
        }
        try {
          final response = await PaymentApi.instance.webPayMethod(
            form.action!,
            fields,
          );
          final redirect = _webPayRedirect(response.data);
          final redirectUri = redirect == null ? null : Uri.tryParse(redirect);
          if (redirectUri != null && redirectUri.hasScheme) {
            await _openPaymentUrl(redirectUri.toString());
            openedByApi = true;
            if (mounted) {
              setState(() {
                _paymentStatus = _PaymentStatus.pending;
                _paymentStatusMessage =
                    'Платёж отправлен. Статус пока не подтверждён банком';
              });
            }
          }
        } catch (_) {}
        if (!openedByApi && mounted) {
          await Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => _WebPayScreen(html: _buildWebPayHtml(form)),
            ),
          );
          if (mounted) await _checkPaymentStatus();
        }
      } else if (kind == PaymentMethodKind.oplati && order.linkToPay != null) {
        await _openPaymentUrl(order.linkToPay!);
        if (mounted) {
          setState(() {
            _paymentStatus = _PaymentStatus.pending;
            _paymentStatusMessage =
                'Приложение «Оплати» открыто, ожидаем подтверждение';
          });
        }
      } else if (kind == PaymentMethodKind.oplati &&
          (order.info?.trim().isNotEmpty == true ||
              order.infoHtml?.trim().isNotEmpty == true)) {
        if (mounted) {
          setState(() {
            _paymentStatus = _PaymentStatus.pending;
            _paymentStatusMessage = 'Следуйте инструкции приложения «Оплати»';
          });
        }
      } else if (order.linkToPay?.trim().isNotEmpty == true) {
        await _openPaymentUrl(order.linkToPay!);
        if (mounted) {
          setState(() {
            _paymentStatus = _PaymentStatus.pending;
            _paymentStatusMessage =
                'Платёж отправлен. Статус пока не подтверждён банком';
          });
        }
      } else if (order.webpayForm != null) {
        final form = order.webpayForm!;
        _validateWebPayForm(form);
        if (form.action == null || form.action!.isEmpty) {
          throw ApiException('Не указан адрес платёжной системы');
        }
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) =>
                _WebPayScreen(html: _buildWebPayHtml(order.webpayForm!)),
          ),
        );
        if (mounted) await _checkPaymentStatus();
      } else {
        throw ApiException('Для этого способа оплаты нет ссылки');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _paymentStatus = _PaymentStatus.failed;
          _paymentStatusMessage = e.message;
          _error = e.message;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _paymentStatus = _PaymentStatus.failed;
          _paymentStatusMessage = 'Не удалось открыть оплату';
          _error = 'Не удалось открыть оплату';
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _checkPaymentStatus() async {
    final order = _order;
    if (order == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final groups = await PaymentApi.instance.getHistory();
      // Статус платежа берётся из истории, поэтому историю нужно перечитать:
      // список на экране был загружен до оплаты и показывал заказ как
      // неоплаченный.
      markHistoryChanged();
      final items = groups.expand((group) => group.posts).toList();
      final orderId = order.orderId;
      PaymentHistoryItem? found;
      for (final item in items) {
        if (item.matchesOrder(orderId ?? '')) {
          found = item;
          break;
        }
      }
      if (kDebugMode) {
        debugPrint(
          'payment status: order=$orderId found=${found?.orderId} '
          'status=${found?.status} paid=${found?.isPaid} of ${items.length}',
        );
      }
      var confirmed = false;
      if (mounted) {
        setState(() {
          if (found?.isPaid == true) {
            _paymentStatus = _PaymentStatus.paid;
            _paymentStatusMessage = 'Оплата подтверждена в истории';
            confirmed = true;
          } else if (found?.isFailed == true) {
            _paymentStatus = _PaymentStatus.failed;
            _paymentStatusMessage = 'Платёж отклонён платёжной системой';
          } else {
            _paymentStatus = _PaymentStatus.pending;
            _paymentStatusMessage =
                'Оплата ещё не подтверждена банком, попробуйте позже';
          }
        });
      }
      if (confirmed && mounted) {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        if (mounted) context.go('/payment');
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = 'Не удалось проверить статус');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToPaymentHistory() => context.go('/payment');

  Widget _buildStationStep() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _buildServiceDropdown(),
      const SizedBox(height: 12),
      _buildStationDropdown(),
    ],
  );

  Widget _buildServiceDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _FieldLabel('Наименование услуги *'),
      const SizedBox(height: 8),
      _ServiceDropdown(
        value: _service,
        isLegal: _isLegal,
        onChanged: _onServiceChanged,
      ),
    ],
  );

  Widget _buildStationDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const _FieldLabel('Место оказания услуги *'),
      const SizedBox(height: 8),
      _StationDropdown(
        serviceId: _service?.id,
        value: _station,
        onChanged: (station) {
          if (station == null) return;
          setState(() {
            _station = station;
            _vehicleType = null;
            _vehicleFieldValues.clear();
            _vehicleTypes = const [];
            _vehicleTypesRequested = false;
            _vehicleRequestId++;
            _axlesCount = null;
            _markValid('station');
            _resetPrice();
          });
          _loadVehicleTypes();
          // Место оказания услуги входит в расчёт стоимости, поэтому запрос
          // цены нужно отправить сразу.
          _refreshPriceDebounced();
        },
      ),
      if (_isInvalid('station')) ...[
        const SizedBox(height: 6),
        Text(
          'Выберите место оказания услуги',
          style: TextStyle(fontSize: 12, color: AppColors.error),
        ),
      ],
    ],
  );

  /// Личные данные физлица или реквизиты организации.
  Widget _buildDetailsStep() {
    _prefillLegalProfile();
    _prefillPersonalProfile();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [...(_isLegal ? _buildLegalDetails() : _buildPhysicalDetails())],
    );
  }

  /// Реквизиты организации.
  ///
  /// Набор и порядок полей задаёт услуга: у техосмотра спрашиваются только УНП,
  /// наименование, СТС, госномер и e-mail, у услуг с договорами — полный
  /// комплект вместе с банковскими данными.
  List<Widget> _buildLegalDetails() {
    final widgets = <Widget>[];
    for (final field in _spec.legalRequisites) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 10));
      widgets
        ..add(_legalFieldLabel(field))
        ..add(const SizedBox(height: 6))
        ..add(_buildLegalField(field));
    }
    return widgets;
  }

  /// Заголовок реквизита: у обязательных полей стоит звёздочка, у полей с
  /// ограничением длины — счётчик «текущее/минимальное».
  Widget _legalFieldLabel(LegalField field) {
    final counter = switch (field) {
      LegalField.bankAccount => _LengthCounter(
        controller: _legalBankAccount,
        minimum: 20,
      ),
      LegalField.bankName => _LengthCounter(
        controller: _legalBankName,
        minimum: 7,
      ),
      LegalField.bankBic => _LengthCounter(
        controller: _legalBankBic,
        minimum: 6,
      ),
      // Сервер требует не меньше 6 знаков в наименовании и 14 — в месте
      // нахождения, поэтому ограничение показываем сразу, а не после ошибки.
      LegalField.nameOrg => _LengthCounter(
        controller: _legalNameOrg,
        minimum: _minNameOrgLength,
      ),
      LegalField.location => _LengthCounter(
        controller: _legalLocation,
        minimum: _minLocationLength,
      ),
      _ => null,
    };
    return _FieldLabel(switch (field) {
      LegalField.unp => 'УНП*',
      LegalField.codePodr => 'Код обособленного подразделения',
      LegalField.nameOrg => 'Наименование организации*',
      LegalField.face => 'В лице*',
      LegalField.mainDoc => 'На основании*',
      LegalField.cert => 'Свидетельство о регистрации (техпаспорт)*',
      LegalField.regNumber => 'Регистрационный знак*',
      LegalField.location => 'Место нахождения*',
      LegalField.bankAccount => 'Расчетный счет*',
      LegalField.bankName => 'В банке*',
      LegalField.bankBic => 'BIC банка*',
      LegalField.email => 'E-mail*',
    }, counter: counter);
  }

  /// Поле реквизита.
  Widget _buildLegalField(LegalField field) {
    return switch (field) {
      LegalField.unp => _FlowInput(
        controller: _legalUnp,
        focusNode: _chain(_legalUnpFocus),
        hintText: 'УНП',
        showError: _isInvalid('legalUnp'),
        onChanged: (_) => _markValid('legalUnp'),
        icon: Icons.badge_outlined,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_legalUnpFocus),
      ),
      LegalField.codePodr => _FlowInput(
        controller: _legalCodePodr,
        focusNode: _chain(_legalCodePodrFocus),
        hintText: 'Код обособленного подразделения',
        onChanged: (_) => _markValid('legalCodePodr'),
        icon: Icons.apartment_outlined,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_legalCodePodrFocus),
      ),
      LegalField.nameOrg => _FlowInput(
        controller: _legalNameOrg,
        focusNode: _chain(_legalNameOrgFocus),
        hintText: 'Наименование организации',
        showError: _isInvalid('legalNameOrg'),
        onChanged: (_) => _markValid('legalNameOrg'),
        icon: Icons.business_outlined,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_legalNameOrgFocus),
      ),
      LegalField.face => _FlowInput(
        controller: _legalFace,
        focusNode: _chain(_legalFaceFocus),
        hintText: 'В лице',
        showError: _isInvalid('legalFace'),
        onChanged: (_) => _markValid('legalFace'),
        icon: Icons.person_outline,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_legalFaceFocus),
      ),
      LegalField.mainDoc => _FlowInput(
        controller: _legalMainDoc,
        focusNode: _chain(_legalMainDocFocus),
        hintText: 'На основании',
        showError: _isInvalid('legalMainDoc'),
        onChanged: (_) => _markValid('legalMainDoc'),
        icon: Icons.description_outlined,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_legalMainDocFocus),
      ),
      LegalField.cert => _FlowInput(
        key: _certFieldKey,
        controller: _certNumber,
        focusNode: _chain(_certFocus),
        hintText: 'Свидетельство о регистрации (техпаспорт)',
        showError: _isInvalid('cert'),
        onChanged: (value) {
          _markValid('cert');
          _unlinkVehicle('cert', value);
          _refreshPriceDebounced();
        },
        onTap: _vehicleMenuTap(forCert: true),
        icon: Icons.description_outlined,
        suffixIcon: _vehicleMenuIcon(forCert: true),
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_certFocus),
      ),
      LegalField.regNumber => _FlowInput(
        key: _regFieldKey,
        controller: _regNumber,
        focusNode: _chain(_regFocus),
        hintText: 'Регистрационный знак',
        showError: _isInvalid('reg'),
        onChanged: (value) {
          _markValid('reg');
          _unlinkVehicle('reg', value);
          _refreshPriceDebounced();
        },
        onTap: _vehicleMenuTap(forCert: false),
        icon: Icons.directions_car_filled_rounded,
        suffixIcon: _vehicleMenuIcon(forCert: false),
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_regFocus),
      ),
      LegalField.location => _FlowInput(
        controller: _legalLocation,
        focusNode: _chain(_legalLocationFocus),
        hintText: 'Место нахождения',
        showError: _isInvalid('legalLocation'),
        onChanged: (_) => _markValid('legalLocation'),
        icon: Icons.map_outlined,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_legalLocationFocus),
      ),
      LegalField.bankAccount => _FlowInput(
        controller: _legalBankAccount,
        focusNode: _chain(_legalBankAccountFocus),
        hintText: 'Не менее 20 символов',
        showError: _isInvalid('legalBankAccount'),
        onChanged: (_) => _markValid('legalBankAccount'),
        icon: Icons.account_balance_outlined,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_legalBankAccountFocus),
      ),
      LegalField.bankName => _FlowInput(
        controller: _legalBankName,
        focusNode: _chain(_legalBankNameFocus),
        hintText: 'Не менее 7 символов',
        showError: _isInvalid('legalBankName'),
        onChanged: (_) => _markValid('legalBankName'),
        icon: Icons.account_balance,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_legalBankNameFocus),
      ),
      LegalField.bankBic => _FlowInput(
        controller: _legalBankBic,
        focusNode: _chain(_legalBankBicFocus),
        hintText: 'Не менее 6 символов',
        showError: _isInvalid('legalBankBic'),
        onChanged: (_) => _markValid('legalBankBic'),
        icon: Icons.pin_outlined,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_legalBankBicFocus),
      ),
      LegalField.email => _FlowInput(
        controller: _legalEmail,
        focusNode: _chain(_legalEmailFocus),
        hintText: 'E-mail',
        showError: _isInvalid('legalEmail'),
        onChanged: (_) => _markValid('legalEmail'),
        icon: Icons.alternate_email,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      ),
    };
  }

  List<Widget> _buildPhysicalDetails() {
    final widgets = <Widget>[];
    void add(String label, Widget input) {
      if (widgets.isNotEmpty) widgets.add(const SizedBox(height: 10));
      widgets
        ..add(_FieldLabel(label))
        ..add(const SizedBox(height: 6))
        ..add(input);
    }

    add(
      'Фамилия *',
      _FlowInput(
        controller: _lastName,
        focusNode: _chain(_lastNameFocus),
        hintText: 'Фамилия',
        showError: _isInvalid('lastName'),
        onChanged: (_) => _markValid('lastName'),
        icon: Icons.person_outline,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_lastNameFocus),
      ),
    );
    add(
      'Имя *',
      _FlowInput(
        controller: _firstName,
        focusNode: _chain(_firstNameFocus),
        hintText: 'Имя',
        showError: _isInvalid('firstName'),
        onChanged: (_) => _markValid('firstName'),
        icon: Icons.person_outline,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_firstNameFocus),
      ),
    );
    add(
      'Отчество',
      _FlowInput(
        controller: _middleName,
        focusNode: _chain(_middleNameFocus),
        hintText: 'Отчество',
        icon: Icons.person_outline,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => _focusNextField(_middleNameFocus),
      ),
    );
    if (_spec.requireCert) {
      add(
        'Свидетельство о регистрации (техпаспорт)*',
        _FlowInput(
          key: _certFieldKey,
          controller: _certNumber,
          focusNode: _chain(_certFocus),
          hintText: 'Серия и номер',
          showError: _isInvalid('cert'),
          onChanged: (value) {
            _markValid('cert');
            _unlinkVehicle('cert', value);
            _refreshPriceDebounced();
          },
          onTap: _vehicleMenuTap(forCert: true),
          icon: Icons.description_outlined,
          suffixIcon: _vehicleMenuIcon(forCert: true),
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextField(_certFocus),
        ),
      );
    }
    if (_requiresRegistrationNumber) {
      add(
        'Регистрационный номер ТС*',
        _FlowInput(
          key: _regFieldKey,
          controller: _regNumber,
          focusNode: _chain(_regFocus),
          hintText: 'Например, 1234 AB-5',
          showError: _isInvalid('reg'),
          onChanged: (value) {
            _markValid('reg');
            _unlinkVehicle('reg', value);
            _refreshPriceDebounced();
          },
          onTap: _vehicleMenuTap(forCert: false),
          icon: Icons.directions_car_filled_rounded,
          suffixIcon: _vehicleMenuIcon(forCert: false),
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _focusNextField(_regFocus),
        ),
      );
    }
    add(
      'Email *',
      _FlowInput(
        controller: _personalEmail,
        focusNode: _chain(_emailFocus),
        hintText: 'Email',
        showError: _isInvalid('email'),
        onChanged: (_) => _markValid('email'),
        icon: Icons.alternate_email,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _focusNextField(_emailFocus),
      ),
    );
    return widgets;
  }

  /// Шаг «Информация о транспортном средстве»: виды работ, параметры ТС и
  /// итоговая стоимость.
  ///
  /// У юрлиц стоимость идёт под полями на этом же шаге: отдельный экран расчёта
  /// разрывал форму. У физлиц итог остаётся на шаге способа оплаты.
  Widget _buildVehicleStep() {
    // Экран мог открыться при незагруженных типах ТС: повторяем запрос, иначе
    // выбрать тип было бы нечем.
    if (_spec.needsVehicleTypes &&
        _station != null &&
        _vehicleTypes.isEmpty &&
        !_loadingVehicleTypes &&
        !_vehicleTypesRequested) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadVehicleTypes();
      });
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_spec.requireCertainTypes) ...[
          ..._buildCertainTypesSelector(),
          const SizedBox(height: 12),
        ],
        ..._buildVehicleFields(),
        if (_priceStep == FlowStep.vehicle) ...[
          const SizedBox(height: 16),
          _buildPriceBlock(),
        ],
      ],
    );
  }

  /// Выбор отдельных видов контрольно-диагностических работ.
  List<Widget> _buildCertainTypesSelector() {
    if (_loadingCertainTypes) {
      return [const LinearProgressIndicator()];
    }
    if (_certainTypesError != null) {
      return [
        Row(
          children: [
            Expanded(
              child: Text(
                _certainTypesError!,
                style: TextStyle(fontSize: 12, color: AppColors.error),
              ),
            ),
            TextButton(
              onPressed: _loadCertainTypes,
              child: const Text('Повторить'),
            ),
          ],
        ),
      ];
    }
    return [
      const _FieldLabel('Отдельные виды контрольно-диагностических работ'),
      const SizedBox(height: 6),
      OutlinedButton.icon(
        onPressed: _selectCertainTypes,
        icon: const Icon(Icons.checklist_rounded),
        label: Text('Выбрано: ${_selectedCertainTypeIds.length}'),
      ),
      if (_isInvalid('certainTypes')) ...[
        const SizedBox(height: 4),
        Text(
          'Выберите хотя бы один вид работ',
          style: TextStyle(fontSize: 12, color: AppColors.error),
        ),
      ],
      if (_selectedCertainTypeIds.isNotEmpty) ...[
        const SizedBox(height: 6),
        Text(
          _certainTypes
              .where((type) => _selectedCertainTypeIds.contains(type.id))
              .map((type) => type.title)
              .join(', '),
          style: TextStyle(
            fontSize: 12,
            height: 1.3,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    ];
  }

  Future<void> _selectCertainTypes() async {
    if (_certainTypes.isEmpty) {
      await _loadCertainTypes();
      if (!mounted) return;
      if (_certainTypes.isEmpty) {
        setState(
          () => _error = 'Не удалось загрузить виды диагностических работ',
        );
        return;
      }
    }
    final selected = <int>{..._selectedCertainTypeIds};
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Отдельные виды диагностических работ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: _certainTypes
                        .map(
                          (type) => CheckboxListTile(
                            value: selected.contains(type.id),
                            title: Text(type.title),
                            controlAffinity: ListTileControlAffinity.leading,
                            onChanged: (checked) {
                              setSheetState(() {
                                if (checked == true) {
                                  selected.add(type.id);
                                } else {
                                  selected.remove(type.id);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 12),
                RNButton(
                  title: 'Готово',
                  onPress: () {
                    setState(() {
                      _selectedCertainTypeIds
                        ..clear()
                        ..addAll(selected);
                      _error = null;
                    });
                    // Предупреждение «выберите хотя бы один вариант» должно
                    // исчезнуть сразу после выбора, а не висеть до следующей
                    // проверки.
                    if (_selectedCertainTypeIds.isNotEmpty) {
                      _markValid('certainTypes');
                    } else {
                      _markInvalid('certainTypes');
                    }
                    Navigator.of(sheetContext).pop();
                    // Стоимость зависит от выбранных видов работ.
                    _refreshPriceDebounced();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Поля транспортного средства: тип ТС с его параметрами, количество осей и
  /// количество ТС.
  List<Widget> _buildVehicleFields() {
    return [
      if (_spec.requiresVehicleType) ...[
        const _FieldLabel('Тип транспортного средства*'),
        const SizedBox(height: 6),
        _buildVehicleTypeSelector(),
        if (_isInvalid('vehicleType')) ...[
          const SizedBox(height: 4),
          Text(
            'Выберите тип транспортного средства',
            style: TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
        // Дополнительные поля отрисовываются все, какие пришли с выбранным
        // типом: у автобуса это масса, у грузовых и прицепов — свои параметры.
        if (_vehicleType?.fields != null)
          ..._vehicleType!.fields!
              .where((f) => !_isServiceLevelVehicleField(f))
              // Поле осей из выдачи сервера рисуется само, но только там, где
              // сценарий реально спрашивает оси. Отдельное поле ниже
              // показывается лишь когда сервер его не прислал, иначе выбор
              // дублировался бы.
              .where((f) => !_isAxlesField(f) || _isVisibleAxlesField(f))
              .where((f) => !_isUnselectableField(f))
              .map(_buildVehicleField),
      ],
      if (_showsAxlesField && !_hasServerAxlesField) ...[
        if (_spec.requiresVehicleType) const SizedBox(height: 12),
        const _FieldLabel('Количество осей*'),
        const SizedBox(height: 6),
        _buildAxlesSelector(),
        if (_isInvalid('axles')) ...[
          const SizedBox(height: 4),
          Text(
            'Выберите количество осей',
            style: TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
      if (_spec.requiresVehicleCount) ...[
        const SizedBox(height: 12),
        _FieldLabel(_vehicleCountIsFixed ? 'Количество ТС' : 'Количество ТС*'),
        const SizedBox(height: 6),
        _FlowInput(
          controller: _vehicleCount,
          focusNode: _chain(_vehicleCountFocus),
          hintText: 'Например, 1',
          showError: _isInvalid('count'),
          onChanged: (_) {
            _markValid('count');
            _refreshPriceDebounced();
          },
          icon: Icons.directions_car_outlined,
          readOnly: _vehicleCountIsFixed,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _focusNextField(_vehicleCountFocus),
        ),
        if (_isInvalid('count')) ...[
          const SizedBox(height: 4),
          Text(
            'Укажите количество ТС',
            style: TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
      ],
    ];
  }

  /// Выбор типа транспортного средства.
  ///
  /// Пустой список означает, что сервер не вернул типы для выбранной станции:
  /// показываем об этом явно и даём повторить запрос, иначе поле выглядит как
  /// неработающее.
  Widget _buildVehicleTypeSelector() {
    if (_loadingVehicleTypes) return const LinearProgressIndicator();
    if (_vehicleTypes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Типы ТС не загружены',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          OutlinedButton(
            onPressed: () => _loadVehicleTypes(force: true),
            child: const Text('Загрузить'),
          ),
        ],
      );
    }
    return AppSelectField<VehicleType>(
      key: _vehicleTypeKey,
      value: _vehicleType,
      hint: 'Выберите тип ТС',
      items: _vehicleTypes,
      searchable: true,
      labelOf: (type) => type.title,
      onChanged: (type) {
        setState(() {
          _vehicleType = type;
          _vehicleFieldValues.clear();
          _vehicleFieldKeys.clear();
          // Оси относятся к конкретному типу: у типа, где их нет, прежний
          // выбор больше не должен уходить в заказ.
          if (!_spec.requiresAxlesFor(type)) _axlesCount = null;
          _markValid('vehicleType');
        });
        _refreshPriceDebounced();
      },
    );
  }

  /// Выбор количества осей.
  ///
  /// Например, сколько вариантов у прицепа — 1 или 2, у грузовика ЕКМТ — 2 или 3, у автобуса — 3 или 4. Поэтому список идёт в сценарии, а не зашитоко в коде.
  Widget _buildAxlesSelector() => AppSelectField<int>(
    value: _axlesCount,
    hint: 'Выберите количество осей',
    items: _spec.axlesOptions,
    labelOf: (value) => value.toString(),
    onChanged: (value) {
      if (value == null) return;
      setState(() {
        _axlesCount = value;
        _markValid('axles');
      });
      _refreshPriceDebounced();
    },
  );

  Widget _buildVehicleField(VehicleTypeField field) {
    final options = _vehicleFieldOptions(field);
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FieldLabel(field.isRequired ? '${field.title} *' : field.title),
          const SizedBox(height: 6),
          AppSelectField<DropdownValue>(
            key: _vehicleFieldKeys.putIfAbsent(field.name, GlobalKey.new),
            value: _vehicleFieldValues[field.name],
            hint: 'Выберите значение',
            items: options,
            searchable: options.length > 5,
            labelOf: (value) => value.title,
            onChanged: (value) {
              setState(() {
                if (value == null) {
                  _vehicleFieldValues.remove(field.name);
                } else {
                  _vehicleFieldValues[field.name] = value;
                }
                // Смена массы меняет и видимость количества осей: оси
                // спрашиваются только в диапазоне 0,75–3,5 т, поэтому прошлая
                // цифра сгорает.
                if (_isMassField(field) && !_showsAxlesField) {
                  _axlesCount = null;
                }
              });
              // Цена зависит и от этих полей (масса, количество колёс и т.д.).
              _refreshPriceDebounced();
            },
          ),
        ],
      ),
    );
  }

  /// Подсказка вместо красной ошибки, пока стоимость ещё не рассчитана.
  String get _priceHint {
    if (_spec.requireCertainTypes && _selectedCertainTypeIds.isEmpty) {
      return 'Выберите виды работ, чтобы рассчитать стоимость';
    }
    if (_spec.requiresVehicleType && _vehicleType == null) {
      return 'Стоимость рассчитывается после выбора типа транспортного средства';
    }
    if (_showsAxlesField && _selectedAxles == null) {
      return 'Стоимость рассчитывается после выбора количества осей';
    }
    if (_spec.requiresVehicleCount) {
      final count = int.tryParse(_vehicleCount.text.trim());
      if (count == null || count < 1) {
        return 'Укажите количество ТС, чтобы рассчитать стоимость';
      }
    }
    if (_spec.requiresVehicleType && _missingRequiredVehicleField() != null) {
      return 'Заполните параметры транспортного средства, чтобы рассчитать стоимость';
    }
    // Сервер отвечает нулём, когда у выбранной станции нет цены на этот вид
    // работ: например, на прицеп 0,75–3,5 т цена не заведена ни на одной
    // станции. Это не «бесплатно», и показывать «0,00 руб.» нельзя.
    if (_priceZeroed) {
      return 'Стоимость на выбранную станцию не установлена — выберите другую станцию или другой вид работ';
    }
    return 'Стоимость рассчитывается автоматически';
  }

  /// Сервер ответил ценой `0`.
  ///
  /// Так бывает, когда у станции нет прайса на выбранную комбинацию типа ТС и
  /// массы. Ноль — не цена, и платить по нему заказ нельзя.
  bool get _priceZeroed {
    final raw = _price?.price?.trim();
    if (raw == null || raw.isEmpty) return false;
    final value = double.tryParse(raw.replaceAll(',', '.').replaceAll(' ', ''));
    return value == 0;
  }

  Widget _buildPriceBlock() {
    final displayedPrice = _priceValue;
    if (_loadingPrice) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      );
    }
    // Ноль и отсутствие цены показываются одинаково: показать «0,00 руб.» было
    // бы неверно, у такой комбинации цены просто нет.
    if (displayedPrice == null) {
      return Text(
        _priceHint,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      );
    }
    return _priceCard('Стоимость:', displayedPrice);
  }

  /// Итоговая сумма заказа на шаге оплаты.
  ///
  /// Расчёт показывается на шаге способа оплаты, но списывается итог заказа, а у
  /// ГТО он на 5 BYN больше, потому что в расчёт не входит печать диагностической
  /// карты. Поэтому рядом с кнопкой оплаты стоит именно серверная сумма: если
  /// расхождение есть, пользователь видит его до оплаты, а не после.
  ///
  /// Если сервер сумму не вернул, у части услуг итогом считается расчёт —
  /// см. [_calculatedOrderTotal]. Там, где и это не годится, вместо суммы
  /// показывается прямое объяснение, потому что заплатить по неизвестной цене
  /// нельзя.
  Widget _buildOrderTotalBlock() {
    final total = _orderTotal;
    // Пока заказ создаётся, суммы ещё нет — вместо ошибки показываем прогресс,
    // чтобы при входе на шаг не мелькало «Стоимость заказа не получена».
    if (total == null && _loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: LinearProgressIndicator(),
      );
    }
    if (total == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
        ),
        child: Text(
          'Стоимость заказа не получена — оплата недоступна',
          style: TextStyle(color: AppColors.error, fontSize: 14, height: 1.35),
        ),
      );
    }
    return _priceCard('К оплате:', total);
  }

  Widget _priceCard(String label, double amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15)),
          Text(
            _formatPrice(amount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Сумма с двумя знаками: столько присылает сервер, столько и показываем.
  String _formatPrice(double value) =>
      '${value.toStringAsFixed(2).replaceAll('.', ',')} руб.';

  Widget _buildMethodStep() {
    final methods = _paymentMethods;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (methods.isEmpty)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Не удалось загрузить способы оплаты',
                    style: TextStyle(fontSize: 14, color: AppColors.error),
                  ),
                ),
                TextButton(
                  onPressed: _loadPaymentMethods,
                  child: const Text('Повторить'),
                ),
              ],
            ),
          )
        else if (_spec.hasCheckboxesForPayment)
          ...methods.map(_buildMethodCheckbox)
        else
          ...methods.map(
            (method) => _SelectCard(
              title: method.title ?? '',
              selected: _method?.id == method.id,
              onTap: () => _selectMethod(method),
            ),
          ),
        if (_isInvalid('method')) ...[
          const SizedBox(height: 4),
          Text(
            'Выберите способ оплаты',
            style: TextStyle(fontSize: 12, color: AppColors.error),
          ),
        ],
        // Стоимость показывается на том шаге, где она уже посчитана: у физлиц
        // и у юрлиц без шага ТС — на способе оплаты, у остальных юрлиц — на
        // сведениях о ТС.
        if (_priceStep == FlowStep.method) ...[
          const SizedBox(height: 16),
          _buildPriceBlock(),
        ],
      ],
    );
  }

  /// Способ оплаты в виде чекбокса.
  ///
  /// Часть услуг юрлиц оформляется с выбором способа оплаты чекбоксами
  /// («Безналичный расчёт», «АИС «Расчёт» (ЕРИП)»). Заказ оплачивается одним
  /// способом, поэтому отмеченным остаётся только выбранный.
  Widget _buildMethodCheckbox(PaymentMethod method) {
    final selected = _method?.id == method.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected ? AppColors.primaryLight : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectMethod(method),
          child: CheckboxListTile(
            value: selected,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            dense: true,
            title: Text(
              method.title ?? '',
              style: TextStyle(
                fontSize: 15,
                height: 1.3,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            onChanged: (_) => _selectMethod(method),
          ),
        ),
      ),
    );
  }

  void _selectMethod(PaymentMethod method) {
    setState(() {
      _method = method;
      _error = null;
      _markValid('method');
    });
  }

  /// Документы заказа, готовые к скачиванию.
  ///
  /// Список приходит с заказом, и только он: без идентификатора шаблона ссылка
  /// не скачивается, поэтому документы без `id` или `href` показывать нельзя.
  /// Подпись берётся из поля `value`, а не из `title` — так же, как в исходном
  /// приложении.
  List<DocumentTemplate> _availableDocuments() => _documents;

  /// Оставляет только те документы, которые действительно можно скачать.
  List<DocumentTemplate> _downloadableDocuments(
    List<DocumentTemplate> documents,
  ) {
    final result = <DocumentTemplate>[];
    final seen = <Object>{};
    for (final document in documents) {
      // Документы, которых в списке выбора быть не должно: сервер присылает общий
      // список шаблонов без разбора по услугам, а «Договор» и «Акт» в оплате
      // не выдаются.
      if (isDocumentHidden(document.value, title: document.title)) continue;
      // Документы, исключённые правилами самой услуги.
      if (_spec.isDocumentExcluded(document.value ?? document.title)) continue;
      final id = _documentId(document);
      final hasHref = document.href?.trim().isNotEmpty ?? false;
      if (id == null && !hasHref) continue;
      final Object key = hasHref ? document.href! : id!;
      if (!seen.add(key)) continue;
      result.add(
        DocumentTemplate(
          id: document.id,
          code: document.code,
          title: document.value ?? document.title,
          value: document.value ?? document.title,
          href: document.href,
        ),
      );
    }
    return result;
  }

  Widget _buildConfirmStep() {
    final paid = _paymentStatus == _PaymentStatus.paid;
    final pending = _paymentStatus == _PaymentStatus.pending;
    final failed = _paymentStatus == _PaymentStatus.failed;
    final statusColor = paid
        ? AppColors.success
        : failed
        ? AppColors.error
        : AppColors.primary;
    final statusTitle = paid
        ? 'Оплата подтверждена'
        : failed
        ? 'Оплата не завершена'
        : pending
        ? 'Ожидаем подтверждение оплаты'
        : 'Заказ зарегистрирован';
    final statusText =
        _paymentStatusMessage ??
        (paid
            ? 'Платёж найден в истории заказов'
            : 'Оплата ещё не подтверждена банком');
    final isErip = _isEripOrder;
    // Документ предлагается только при безналичном переводе: счёт выставляется
    // на него, и только его нужно скачать и оплатить в банке. При оплате картой,
    // через ЕРИП или «Оплати» счёта нет, поэтому и выбирать нечего.
    final documents = _spec.allowsDocumentDownload && !paid && _isNoncashOrder()
        ? _availableDocuments()
        : const <DocumentTemplate>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            paid
                ? Icons.check_rounded
                : failed
                ? Icons.error_outline_rounded
                : Icons.schedule_rounded,
            color: statusColor,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          statusTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          statusText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: failed ? AppColors.error : AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        if (!paid && !failed && !isErip && !_isNoncashOrder())
          Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Нажмите «Оплатить», затем проверьте статус после возврата из '
              'платёжной системы.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
          ),
        // Сумма к оплате — первое, что нужно на этом шаге: дальше либо
        // подписывается платёжная форма с этой суммой, либо она уходит в
        // инструкцию ЕРИП. Безнал сюда не попадает: там платёж идёт по счёту
        // из документа заказа, и своей суммой у ответа сервера он не обладает.
        if (!paid && !failed && !_isNoncashOrder()) ...[
          const SizedBox(height: 16),
          _buildOrderTotalBlock(),
        ],
        if (isErip) ...[const SizedBox(height: 16), _buildEripInstructions()],
        if (documents.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildDocuments(documents),
        ],
        // Отдельной кнопки перехода к заказам в теле шага нет: она уже есть
        // внизу экрана и делает ровно то же самое.
        //
        // Номер заказа при ЕРИП не показываем: он уже есть в инструкции
        // от сервера, а собственный идентификатор заказа — другое число,
        // и второй «номер заказа» рядом сбивает с толку.
        if (_order?.orderId != null && !isErip) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _InfoRow(label: 'Номер заказа', value: _order!.orderId!),
          ),
        ],
      ],
    );
  }

  /// Документы заказа: один документ скачивается кнопкой, несколько — из
  /// выпадающего списка.
  Widget _buildDocuments(List<DocumentTemplate> documents) {
    if (documents.length == 1) {
      final document = documents.first;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Документ заказа',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          RNButton(
            title: 'Скачать «${_documentLabel(document)}»',
            type: ButtonType.empty,
            onPress: () => _downloadDocument(document),
            loading: _loading,
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Выберите документ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        AppSelectField<DocumentTemplate>(
          value: null,
          hint: 'Выберите документ для скачивания',
          items: documents,
          labelOf: _documentLabel,
          onChanged: (document) {
            if (document == null) return;
            _downloadDocument(document);
          },
        ),
      ],
    );
  }

  /// Инструкция по оплате через АИС «Расчёт» (ЕРИП).
  ///
  /// Текст и путь в ЕРИП приходят с сервера, поэтому приоритет у них. Если
  /// сервер ничего не вернул, показываем нумерованный список по умолчанию.
  Widget _buildEripInstructions() {
    final order = _order;
    final infoHtml = order?.infoHtml?.trim();
    final info = order?.info?.trim();
    final serverInstruction =
        (infoHtml != null && infoHtml.isNotEmpty) ||
        (info != null && info.isNotEmpty);
    final steps = <String>[
      'Система «Расчёт» (ЕРИП) > Прочие платежи > БЕЛТЕХОСМОТР > '
          '${_service?.title ?? 'услуга'}',
      // Свой идентификатор заказа подставляем, только когда сервер не прислал
      // текст инструкции: в нём уже есть настоящий номер заказа для ЕРИП, и два
      // номера рядом вводят пользователя в заблуждение.
      serverInstruction
          ? 'Введите номер заказа, указанный в инструкции ниже'
          : order?.orderId != null
          ? 'Введите номер заказа ${order!.orderId}'
          : 'Введите номер заказа, указанный при оформлении',
      'Дополнительно потребуется ввести ФИО',
      'Оплатите услугу',
    ];
    final introDuplicated =
        info?.contains('последовательно следующие пункты') ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (infoHtml != null && infoHtml.isNotEmpty)
            HtmlWidget(
              infoHtml,
              textStyle: TextStyle(
                fontSize: 13,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            )
          else ...[
            if (!introDuplicated)
              Text(
                'Для оплаты услуги через систему «Расчёт» (ЕРИП) выберите '
                'последовательно следующие пункты:',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            if (!introDuplicated) const SizedBox(height: 12),
            ...steps.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      child: Text(
                        '${entry.key + 1}.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (info != null && info.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                info,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ],
          // Кнопки перехода к заказам внутри инструкции нет: такая же кнопка
          // стоит внизу экрана, и вторая рядом с ней только мешает.
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        style: TextStyle(color: AppColors.error, fontSize: 14),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.counter});

  final String text;

  /// Необязательный счётчик «текущее/минимальное» для полей с ограничением
  /// длины (расчётный счёт, банк, BIC).
  final Widget? counter;

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
    final counterWidget = counter;
    if (counterWidget == null) return label;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: label),
        const SizedBox(width: 8),
        counterWidget,
      ],
    );
  }
}

/// Счётчик символов с подсветкой, пока не набрано минимальной длины.
class _LengthCounter extends StatelessWidget {
  const _LengthCounter({required this.controller, required this.minimum});

  final TextEditingController controller;
  final int minimum;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final length = controller.text.trim().length;
        final color = length == 0
            ? AppColors.textSecondary
            : length >= minimum
            ? AppColors.success
            : AppColors.error;
        return Text(
          '$length / $minimum',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        );
      },
    );
  }
}

class _FlowInput extends StatelessWidget {
  const _FlowInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.icon,
    this.suffixIcon,
    this.keyboardType,
    this.focusNode,
    this.textInputAction,
    this.textCapitalization,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.showError = false,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData? icon;

  /// Стрелка выбора автомобиля из личного кабинета у полей ТС.
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Тап по полю: открывает меню автомобилей, когда их несколько.
  final VoidCallback? onTap;
  final bool showError;

  /// Поле не редактируется: значение задаёт сервер.
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization ?? TextCapitalization.none,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      onTap: onTap,
      style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.textSecondary, size: 20)
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 38,
          minHeight: 38,
        ),
        suffixIcon: suffixIcon,
        counterText: '',
        isDense: true,
        filled: true,
        fillColor: showError
            ? AppColors.error.withValues(alpha: 0.06)
            : AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: showError ? AppColors.error : AppColors.divider,
            width: showError ? 1.6 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: showError ? AppColors.error : AppColors.primary,
            width: 1.8,
          ),
        ),
      ),
    );
  }
}

class _ServiceDropdown extends StatefulWidget {
  const _ServiceDropdown({
    required this.value,
    required this.isLegal,
    required this.onChanged,
  });

  final PaymentService? value;
  final bool isLegal;
  final ValueChanged<PaymentService?> onChanged;

  @override
  State<_ServiceDropdown> createState() => _ServiceDropdownState();
}

class _ServiceDropdownState extends State<_ServiceDropdown> {
  late Future<List<PaymentService>> _future;

  @override
  void initState() {
    super.initState();
    _future = PaymentApi.instance.getServices();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PaymentService>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final services = (snapshot.data ?? const <PaymentService>[])
            .where(
              (service) => PaymentFlowResolver.isVisibleFor(
                service,
                isLegal: widget.isLegal,
              ),
            )
            .toList();
        return AppSelectField<PaymentService>(
          value: widget.value,
          hint: 'Выберите услугу',
          items: services,
          searchable: true,
          labelOf: (service) => service.title,
          subtitleOf: (service) =>
              service.price == null ? null : '${service.price} руб.',
          onChanged: widget.onChanged,
        );
      },
    );
  }
}

class _StationDropdown extends StatefulWidget {
  const _StationDropdown({
    required this.serviceId,
    required this.value,
    required this.onChanged,
  });

  final int? serviceId;
  final PaymentStation? value;
  final ValueChanged<PaymentStation?> onChanged;

  @override
  State<_StationDropdown> createState() => _StationDropdownState();
}

class _StationDropdownState extends State<_StationDropdown> {
  late Future<List<PaymentStation>> _future;

  /// Загружает места оказания услуг.
  ///
  /// Часть услуг не привязана к конкретным организациям, и фильтр по `serviceId`
  /// возвращает пустой список. В таком случае повторяем запрос без фильтра,
  /// иначе пользователь видел «Организации не найдены» и не мог продолжить.
  Future<List<PaymentStation>> _load(int serviceId) async {
    final forService = await PaymentApi.instance.getStations(serviceId);
    if (forService.isNotEmpty) return forService;
    try {
      return await PaymentApi.instance.getStations(
        serviceId,
        forAllServices: true,
      );
    } catch (_) {
      return forService;
    }
  }

  @override
  void initState() {
    super.initState();
    _future = widget.serviceId != null
        ? _load(widget.serviceId!)
        : Future.value(<PaymentStation>[]);
  }

  @override
  void didUpdateWidget(covariant _StationDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.serviceId != widget.serviceId) {
      _future = widget.serviceId != null
          ? _load(widget.serviceId!)
          : Future.value(<PaymentStation>[]);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.serviceId == null) {
      return Text(
        'Сначала выберите услугу',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }
    return FutureBuilder<List<PaymentStation>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final stations = snapshot.data ?? [];
        if (stations.isEmpty) {
          return Text(
            'Организации не найдены',
            style: TextStyle(color: AppColors.textSecondary),
          );
        }
        return AppSelectField<PaymentStation>(
          value: widget.value,
          hint: 'Выберите организацию',
          items: stations,
          searchable: stations.length > 5,
          labelOf: (station) => station.title,
          subtitleOf: (station) => station.address,
          onChanged: widget.onChanged,
        );
      },
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.currentStep, required this.totalSteps});

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          final active = index ~/ 2 < currentStep;
          return Container(
            width: 28,
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.divider,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }
        final step = index ~/ 2;
        final done = step < currentStep;
        final active = step == currentStep;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 10,
          height: 10,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active ? AppColors.primary : AppColors.divider,
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 6,
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectCard extends StatelessWidget {
  const _SelectCard({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedPress(
      onTap: onTap,
      scale: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: selected ? 16 : 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.radio_button_unchecked_rounded,
                      key: ValueKey(selected),
                      color: selected ? AppColors.primary : AppColors.divider,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WebPayScreen extends StatelessWidget {
  const _WebPayScreen({this.url, this.html});

  final String? url;
  final String? html;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Оплата'),
        automaticallyImplyLeading: false,
        leading: const AppBackButton(),
      ),
      body: WebViewContainer(url: url, html: html),
    );
  }
}

String _buildWebPayHtml(WebPayForm form) {
  const escaper = HtmlEscape(HtmlEscapeMode.attribute);
  final fields = <String, dynamic>{};
  if (form.rawFields.isNotEmpty) {
    fields.addAll(form.rawFields);
  } else {
    fields.addAll({
      'wsb_storeid': form.wsbStoreid,
      'wsb_currency_id': form.wsbCurrencyId,
      'wsb_email': form.wsbEmail,
      'wsb_invoice_item_name[0]': form.wsbInvoiceItemName,
      'wsb_invoice_item_price[0]': form.wsbInvoiceItemPrice,
      'wsb_invoice_item_quantity[0]': form.wsbInvoiceItemQuantity,
      'wsb_total': form.wsbTotal,
      'wsb_signature': form.wsbSignature,
      'wsb_seed': form.wsbSeed,
      'wsb_order_num': form.wsbOrderNum,
      'wsb_return_url': form.wsbReturnUrl,
      'wsb_notify_url': form.wsbNotifyUrl,
      'wsb_version': form.wsbVersion,
      'wsb_test': form.wsbTest,
    });
  }
  final inputs = fields.entries
      .where(
        (entry) =>
            entry.key == '*scart' ||
            (entry.value != null && entry.value.toString().isNotEmpty),
      )
      .map(
        (entry) =>
            '<input type="hidden" name="${escaper.convert(entry.key)}" '
            'value="${escaper.convert(entry.value.toString())}">',
      )
      .join('\n');
  final action = escaper.convert(form.action ?? '');
  return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Оплата</title>
</head>
<body onload="document.getElementById('payForm').submit()">
<form id="payForm" method="post" action="$action">
$inputs
</form>
</body>
</html>
''';
}
