import 'payment.dart';

/// Шаги оформления заказа.
///
/// Услуга выбирается из списка на экране «Оплата», поэтому отдельного шага
/// выбора услуги внутри сценария нет — сценарий стартует сразу со станции
/// (либо со способа оплаты, если станция не нужна).
enum FlowStep { station, method, personal, vehicle, order }

/// Поле реквизитов организации.
///
/// Набор полей различается по услугам, поэтому шаг реквизитов собирается из
/// списка [PaymentFlowSpec.legalRequisites], а не из одного жёстко заданного
/// набора: у техосмотра банковские реквизиты не спрашиваются, а у договоров
/// обязательно нужен полный комплект.
enum LegalField {
  unp,
  codePodr,
  nameOrg,
  face,
  mainDoc,
  cert,
  regNumber,
  location,
  bankAccount,
  bankName,
  bankBic,
  email,
}

/// Полный комплект реквизитов — услуги с договорами и безналичным счётом.
const fullLegalRequisites = <LegalField>[
  LegalField.unp,
  LegalField.codePodr,
  LegalField.nameOrg,
  LegalField.face,
  LegalField.mainDoc,
  LegalField.cert,
  LegalField.regNumber,
  LegalField.location,
  LegalField.bankAccount,
  LegalField.bankName,
  LegalField.bankBic,
  LegalField.email,
];

/// Реквизиты для услуг, где банковские данные не запрашиваются.
const shortLegalRequisites = <LegalField>[
  LegalField.unp,
  LegalField.codePodr,
  LegalField.nameOrg,
  LegalField.cert,
  LegalField.regNumber,
  LegalField.email,
];

/// Реквизиты для услуг с банковскими данными, но без данных о транспорте.
const bankingOnlyRequisites = <LegalField>[
  LegalField.unp,
  LegalField.codePodr,
  LegalField.nameOrg,
  LegalField.location,
  LegalField.bankAccount,
  LegalField.bankName,
  LegalField.bankBic,
  LegalField.email,
];

/// Реквизиты для услуг с банковскими данными и представителем организации, но
/// без свидетельства о регистрации и госномера.
const representativeRequisites = <LegalField>[
  LegalField.unp,
  LegalField.codePodr,
  LegalField.nameOrg,
  LegalField.face,
  LegalField.mainDoc,
  LegalField.location,
  LegalField.bankAccount,
  LegalField.bankName,
  LegalField.bankBic,
  LegalField.email,
];

/// Реквизиты свидетельства о допуске к перевозке опасных грузов: банковские
/// данные без свидетельства о регистрации и госномера.
const dangerousPermitRequisites = <LegalField>[
  LegalField.unp,
  LegalField.codePodr,
  LegalField.nameOrg,
  LegalField.location,
  LegalField.bankAccount,
  LegalField.bankName,
  LegalField.bankBic,
  LegalField.email,
];

/// Сценарий оформления заказа для конкретной услуги.
///
/// Поля сценария описаны флагами, а не комбинациями режимов: у каждой услуги
/// свой набор шагов, полей транспортного средства, способов оплаты и
/// документов, и перечисление услуг в [PaymentFlowResolver] читается как
/// техническое задание.
class PaymentFlowSpec {
  const PaymentFlowSpec({
    required this.serviceId,
    this.isLegal = false,
    this.requiresStation = true,
    this.requireCert = false,
    this.requireRegNumber = false,
    this.requirePersonalReg = false,
    this.requiresVehicleType = false,
    this.requiresVehicleCount = false,
    this.requiresAxlesSelection = false,
    this.axlesOptions = const [2, 3, 4, 5],
    this.axlesApiIds = const <int, int>{},
    this.axlesForTypes = const <String>[],
    this.axlesMassRange = const <String>[],
    this.requireCertainTypes = false,
    this.hasCheckboxesForPayment = false,
    this.allowsDocumentDownload = true,
    this.excludedDocumentLabels = const <String>[],
    this.legalRequisites = fullLegalRequisites,
    this.hiddenVehicleTypes = const <List<String>>[],
    this.allowedVehicleTypes = const <List<String>>[],
    this.stationStepSubtitle = 'Выбор станции',
    this.vehicleStepSubtitle = 'Информация о транспортном средстве',
  });

  /// Копия сценария с заменой части полей.
  ///
  /// Нужна, чтобы дополнить сценарий по номеру услуги, не переписывая его ветку
  /// целиком: набор реквизитов и признак счётчика транспорта задаются по
  /// `serviceId` уже после разбора по названию.
  PaymentFlowSpec copyWith({
    bool? requiresVehicleCount,
    List<LegalField>? legalRequisites,
  }) {
    return PaymentFlowSpec(
      serviceId: serviceId,
      isLegal: isLegal,
      requiresStation: requiresStation,
      requireCert: requireCert,
      requireRegNumber: requireRegNumber,
      requirePersonalReg: requirePersonalReg,
      requiresVehicleType: requiresVehicleType,
      requiresVehicleCount: requiresVehicleCount ?? this.requiresVehicleCount,
      requiresAxlesSelection: requiresAxlesSelection,
      axlesOptions: axlesOptions,
      axlesApiIds: axlesApiIds,
      axlesForTypes: axlesForTypes,
      axlesMassRange: axlesMassRange,
      requireCertainTypes: requireCertainTypes,
      hasCheckboxesForPayment: hasCheckboxesForPayment,
      allowsDocumentDownload: allowsDocumentDownload,
      excludedDocumentLabels: excludedDocumentLabels,
      legalRequisites: legalRequisites ?? this.legalRequisites,
      hiddenVehicleTypes: hiddenVehicleTypes,
      allowedVehicleTypes: allowedVehicleTypes,
      stationStepSubtitle: stationStepSubtitle,
      vehicleStepSubtitle: vehicleStepSubtitle,
    );
  }

  final int serviceId;
  final bool isLegal;

  /// Нужно ли выбирать место оказания услуги.
  final bool requiresStation;

  /// Свидетельство о регистрации ТС (техпаспорт) в реквизитах/личных данных.
  final bool requireCert;

  /// Регистрационный знак в реквизитах организации.
  final bool requireRegNumber;

  /// Регистрационный знак в личных данных физлица.
  final bool requirePersonalReg;

  /// Спрашивается ли тип транспортного средства.
  final bool requiresVehicleType;

  /// Спрашивается ли количество ТС.
  final bool requiresVehicleCount;

  /// Можно ли считать расчёт стоимости итогом заказа.
  ///
  /// Услуги, у которых сервер не возвращает сумму заказа — международный
  /// сертификат, ЕКМТ, свидетельство о допуске к перевозке опасных грузов, —
  /// оплачиваются, но из заказа суммы вовсе нет, и на последнем шаге остаётся
  /// только расчёт `legal-price.php`. Он и есть итог: количество ТС уходит в
  /// расчёт и в заказ одним и тем же числом, поэтому расхождения между ними не
  /// возникает.
  ///
  /// Обратное верно для услуг, где спрашивается тип ТС: у ГТО расчёт ниже
  /// итога, потому что сервер добавляет стоимость печати диагностической карты
  /// уже при регистрации заказа, и подставлять расчёт вместо итога нельзя.
  bool get mayUseCalculationAsTotal => requiresVehicleCount;

  /// Спрашивается ли количество осей.
  final bool requiresAxlesSelection;

  /// Допустимые значения количества осей. Для ЕКМТ — 2 или 3.
  final List<int> axlesOptions;

  /// Идентификаторы справочника для значений из [axlesOptions].
  ///
  /// Показываемое число осей и идентификатор, который ждёт сервер, — разные
  /// вещи: у ГТО прицепа одна ось — это `111`, а две — `49`. Собственного
  /// поля `TRANS_OS` сервер для ГТО не присылает, поэтому соответствие живёт
  /// здесь, и без него цена прицепа не считается вовсе.
  ///
  /// Пустая карта означает, что сервер понимает само число осей. Значения, для
  /// которых идентификатора здесь нет, уходят как есть.
  final Map<int, int> axlesApiIds;

  /// Идентификатор сервера для выбранного количества осей.
  int? axlesApiId(int count) => axlesApiIds[count] ?? count;

  /// Типы ТС, для которых нужно спрашивать количество осей.
  ///
  /// Пустой список означает, что количество осей запрашивается у любого типа
  /// ТС: так у ЕКМТ, где оси есть и у грузовика, и у прицепа, и у комбинации.
  /// У ГТО физлица оси спрашиваются только у прицепа.
  final List<String> axlesForTypes;

  /// Границы массы, при которой количество осей спрашивается.
  ///
  /// Пустой список означает «у всех типов из `axlesForTypes`». У прицепа на
  /// ГТО оси нужны только в диапазоне `> 0,75 т и < 3,5 т`: подпись выбранной
  /// массы должна содержать обе границы, иначе поле не показывается.
  final List<String> axlesMassRange;

  /// Спрашиваются ли отдельные виды контрольно-диагностических работ.
  final bool requireCertainTypes;

  /// Способы оплаты показываются чекбоксами, а не переключателями.
  final bool hasCheckboxesForPayment;

  /// Показывается ли после заказа выбор документа для скачивания.
  ///
  /// Документы нужны только при безналичной оплате — юрлицам, которые платят
  /// переводом и получают счёт. Физлица платят картой, через ЕРИП или «Оплати»,
  /// счёта у них нет, и показывать скачивание нечего: раньше сервер всё равно
  /// присылал пустой список, и пользователь видел лишнюю кнопку.
  final bool allowsDocumentDownload;

  /// Документы, которых нет в списке выбора для этой услуги.
  ///
  /// Сервер присылает шаблоны без разбора по услугам, поэтому в списке оказывается
  /// лишнее: у повторного прохождения КДР это «Акт», которого там не должно быть —
  /// документ один, счёт-договор. Сравнение идёт по буквам, поэтому регистр и
  /// номера не важны.
  final List<String> excludedDocumentLabels;

  /// Поля реквизитов организации, которые запрашиваются у услуги.
  final List<LegalField> legalRequisites;

  /// Исключён ли документ из списка скачивания по правилам услуги.
  ///
  /// Сравнение идёт по буквам без цифр: «Акт», «акт» и «Акт №5» — один и тот же
  /// документ, а в шаблоне номер может быть или не быть.
  bool isDocumentExcluded(String? label) {
    if (excludedDocumentLabels.isEmpty) return false;
    final normalized = _documentKey(label);
    if (normalized.isEmpty) return false;
    return excludedDocumentLabels.any(
      (excluded) => _documentKey(excluded) == normalized,
    );
  }

  /// Буквы названия без цифр и знаков, в нижнем регистре.
  static String _documentKey(String? value) =>
      _normalizeToken(value ?? '').replaceAll(RegExp(r'\d'), '');

  /// Типы ТС, которые не показываются пользователю.
  ///
  /// Правило — список маркеров, и тип скрывается, только если его название
  /// содержит их все. Например, `[['груз', 'прицеп']]` убирает вариант
  /// «Грузовой автомобиль + Прицеп (полуприцеп)», но оставляет «Грузовой
  /// автомобиль» и «Прицеп/полуприцеп» по отдельности. Типы приходят с сервера,
  /// поэтому исключение описано здесь, а не правкой выдачи.
  final List<List<String>> hiddenVehicleTypes;

  /// Типы ТС, которые показываются, остальные скрываются.
  ///
  /// Услуга может оказываться по ограниченному набору видов техники: у ЕКМТ
  /// это грузовик, прицеп и их комбинация, а в общем каталоге типов есть ещё
  /// автобусы, мопеды и легковые, которые по ЕКМТ не проводятся. Список пустой
  /// — ограничения нет, показываются все типы, кроме скрытых.
  ///
  /// Правило — те же маркеры, что и в `hiddenVehicleTypes`, но срабатывает оно,
  /// когда название содержит все маркеры правила. Для трёх видов ЕКМТ хватает
  /// правил `[['груз'], ['прицеп']]`: «груз» оставляет грузовик и комбинацию,
  /// «прицеп» — прицеп и комбинацию.
  final List<List<String>> allowedVehicleTypes;

  /// Показывается ли тип транспортного средства пользователю.
  bool isVehicleTypeAllowed(String? title) {
    if (hiddenVehicleTypes.isNotEmpty) {
      final normalized = _normalizeToken(title ?? '');
      if (normalized.isEmpty) return false;
      var hidden = false;
      for (final rule in hiddenVehicleTypes) {
        if (rule.isEmpty) continue;
        if (_matchesAll(normalized, rule)) hidden = true;
      }
      if (hidden) return false;
    }
    if (allowedVehicleTypes.isEmpty) return true;
    final normalized = _normalizeToken(title ?? '');
    if (normalized.isEmpty) return false;
    return allowedVehicleTypes.any(
      (rule) => rule.isNotEmpty && _matchesAll(normalized, rule),
    );
  }

  /// Является ли тип комбинацией «грузовой автомобиль + прицеп».
  ///
  /// У такой комбинации осей две группы — у автомобиля и у прицепа, — и сервер
  /// записывает их составным числом («2+2», «3+3»), а не одним числом. Поэтому
  /// список осей комбинации отличается от списка одиночного ТС.
  bool isCombinationVehicleType(String? title) =>
      _matchesAll(_normalizeToken(title ?? ''), const ['груз', 'прицеп']);

  /// Значения осей, которые подходят выбранному типу ТС.
  ///
  /// У ЕКМТ сервер присылает один список осей на все типы: одиночному ТС
  /// подходят простые числа из [axlesOptions] (2, 3), а комбинации «грузовик +
  /// прицеп» — составные («2+2», «2+3» и т.п.). Без разбора в обоих случаях
  /// предлагались бы все восемь значений: у одиночного ТС — оси прицепа, у
  /// комбинации — оси одиночного, и цену нельзя было посчитать правильно.
  List<DropdownValue> filterAxlesValues(
    String? typeTitle,
    List<DropdownValue> values,
  ) {
    final combination = isCombinationVehicleType(typeTitle);
    final simple = axlesOptions.map((value) => value.toString()).toSet();
    return values.where((value) {
      final title = value.title.trim();
      return combination ? title.contains('+') : simple.contains(title);
    }).toList();
  }

  /// Запрашивается ли свидетельство о регистрации в реквизитах.
  bool get requiresCertNumber => legalRequisites.contains(LegalField.cert);

  /// Подпись шага выбора места оказания услуги.
  final String stationStepSubtitle;

  /// Подпись шага с данными о транспортном средстве.
  final String vehicleStepSubtitle;

  /// Есть ли у услуги поля транспортного средства (тип, оси, количество).
  bool get hasVehicleFields =>
      requiresVehicleType || requiresAxlesSelection || requiresVehicleCount;

  /// Нужно ли запрашивать у сервера типы транспортного средства.
  ///
  /// Количество ТС приходит полем `COL_TS` в той же выдаче, поэтому услуги,
  /// которые спрашивают только количество, типы ТС тоже запрашивают: из
  /// `COL_TS` берётся минимальное значение счётчика.
  bool get needsVehicleTypes => hasVehicleFields;

  /// Нужно ли спрашивать количество осей для выбранного типа ТС.
  ///
  /// Пока тип ТС не выбран, поле не показывается. У прицепа оси спрашиваются
  /// не всегда, а только в заданном диапазоне массы, поэтому одного названия
  /// типа мало — решение принимает экран вместе с выбранной массой.
  bool requiresAxlesFor(VehicleType? type) {
    if (!requiresAxlesSelection) return false;
    if (requiresVehicleType && type == null) return false;
    if (axlesForTypes.isEmpty) return true;
    return _matchesAnyPrefix(type?.title, axlesForTypes);
  }

  /// Оси спрашиваются только для массы, чья подпись содержит обе границы
  /// диапазона: `['0,75', '3,5']` — это `> 0,75 т и < 3,5 т`.
  bool requiresAxlesForMass(String? massTitle) {
    if (axlesMassRange.isEmpty) return true;
    final normalized = _normalizeToken(massTitle ?? '');
    if (normalized.isEmpty) return false;
    return axlesMassRange.every(
      (bound) => normalized.contains(_normalizeToken(bound)),
    );
  }

  /// Показывать ли и отправлять ли поле типа ТС, пришедшее от сервера.
  ///
  /// Серверное поле осей (`TRANS_OS`) показывается только там, где сценарий не
  /// задаёт собственный справочник осей. У ЕКМТ такого справочника нет, и оси
  /// приходят от сервера. У ГТО оси заданы в [axlesApiIds] (1 → 111, 2 → 49),
  /// поэтому серверный `TRANS_OS` скрывается: иначе в форме появился бы второй
  /// список с чужими значениями, а в `payment` ушло бы не то число.
  bool showsVehicleField(String name) {
    final normalized = _normalizeToken(name);
    if (normalized == 'transos') {
      return requiresAxlesSelection && axlesApiIds.isEmpty;
    }
    return true;
  }

  /// Совпадение по началу названия вместо вхождения.
  ///
  /// Нужно, чтобы «Грузовой автомобиль+Прицеп (полуприцеп)» не попал под маркер
  /// «прицеп»: оси спрашиваются у прицепа, но не у комбинации грузовика с ним.
  bool _matchesAnyPrefix(String? value, List<String> markers) {
    if (markers.isEmpty) return true;
    final normalized = _normalizeToken(value ?? '');
    if (normalized.isEmpty) return false;
    return markers.any((marker) {
      final token = _normalizeToken(marker);
      return token.isNotEmpty && normalized.startsWith(token);
    });
  }

  bool _matchesAll(String normalized, List<String> markers) {
    for (final marker in markers) {
      final token = _normalizeToken(marker);
      if (token.isEmpty) continue;
      if (!normalized.contains(token)) return false;
    }
    return true;
  }

  bool get requiresEmail => true;

  /// Порядок шагов сценария.
  ///
  /// У юрлиц услуга выбирается на экране «Оплата», поэтому шаг станции
  /// добавляется только тем услугам, которые без неё не принимаются. Далее
  /// способ оплаты, реквизиты организации и — если услуга спрашивает что-то о
  /// транспорте — сведения о ТС вместе с итоговой стоимостью.
  ///
  /// У физлиц сначала личные данные, потом сведения о ТС (или виды работ), и
  /// только затем способ оплаты вместе с итоговой суммой.
  List<FlowStep> get steps {
    final result = <FlowStep>[];
    if (requiresStation) result.add(FlowStep.station);
    if (isLegal) {
      result
        ..add(FlowStep.method)
        ..add(FlowStep.personal);
      if (hasVehicleFields || requireCertainTypes) {
        result.add(FlowStep.vehicle);
      }
      result.add(FlowStep.order);
      return result;
    }
    result.add(FlowStep.personal);
    if (hasVehicleFields || requireCertainTypes) {
      result.add(FlowStep.vehicle);
    }
    result
      ..add(FlowStep.method)
      ..add(FlowStep.order);
    return result;
  }
}

/// Приводит значение к виду, по которому можно искать маркеры полей и типов.
String _normalizeToken(String value) =>
    value.toLowerCase().replaceAll(RegExp(r'[^a-zа-яё0-9]'), '');

class PaymentFlowResolver {
  PaymentFlowResolver._();

  /// Разрешение на допуск ТС к участию в дорожном движении. Стоимость у него
  /// фиксированная (13,50 BYN) и не зависит ни от станции, ни от типа ТС.
  static const kAdmissionRoad = 58434;
  static const kTechnicalInspection = 58439;

  /// Отдельные виды контрольно-диагностических работ при повторном
  /// прохождении: здесь, наоборот, обязательны станция и виды работ.
  static const kRepeatDiagnostic = 58442;
  static const kEkmT = 58441;

  /// Физическим лицам доступны только три услуги.
  static const physicalIds = <int>{
    kAdmissionRoad,
    kTechnicalInspection,
    kRepeatDiagnostic,
  };

  /// Восемь услуг, доступных юридическим лицам.
  static const legalIds = <int>{
    58418,
    58422,
    58434,
    58437,
    58438,
    58439,
    58441,
    58442,
  };

  /// Сертификат технического контроля. ID неизвестен — определяем по названию,
  /// чтобы услуга не терялась из списка.
  static bool isTechnicalControlCertificate(PaymentService service) =>
      service.title.toLowerCase().contains('сертификат');

  /// Международный сертификат технического осмотра: тип ТС не запрашивается,
  /// нужен только счётчик количества ТС.
  static bool isInternationalCertificate(PaymentService service) {
    final title = service.title.toLowerCase();
    return title.contains('международн') && title.contains('сертификат');
  }

  /// Разрешение на допуск ТС к участию в дорожном движении. Определяем и по
  /// названию, чтобы пункт не пропадал из списка при другом ID.
  static bool isAdmissionRoadPermit(PaymentService service) {
    final title = service.title.toLowerCase();
    return service.id == kAdmissionRoad ||
        (title.contains('допуск') && title.contains('дорожн')) ||
        (title.contains('разрешени') && title.contains('дорожн'));
  }

  static bool isVisibleFor(PaymentService service, {required bool isLegal}) =>
      isLegal
      ? legalIds.contains(service.id) ||
            isTechnicalControlCertificate(service) ||
            isInternationalCertificate(service)
      : physicalIds.contains(service.id) ||
            isTechnicalControlCertificate(service) ||
            isInternationalCertificate(service) ||
            isAdmissionRoadPermit(service);

  /// Скрывается комбинация «груз + прицеп»: такая техника на техосмотре не
  /// обслуживается, и сервер всё равно не может посчитать по ней стоимость.
  /// Типы ТС для проверки по нормам ЕКМТ.
  ///
  /// Проверяют только грузовой транспорт: «Грузовой автомобиль»,
  /// «Прицеп/полуприцеп» и «Грузовой автомобиль+Прицеп (полуприцеп)». Правила
  /// записаны маркерами, а не точными названиями: каталог типов у сервера
  /// меняет формулировки, а «груз» и «прицеп» в названии остаются.
  static const ekmtVehicleTypes = <List<String>>[
    ['груз'],
    ['прицеп'],
  ];

  static const truckWithTrailerRule = <List<String>>[
    ['груз', 'прицеп'],
  ];

  /// Сценарий для физического лица.
  ///
  /// У разрешения на допуск к дорожному движению место оказания услуги не
  /// выбирается: услуга не привязана к станциям, и сценарий начинается с
  /// личных данных. Остальным услугам организация нужна.
  static PaymentFlowSpec _individual(
    PaymentService service, {
    required bool requireCert,
    required bool requirePersonalReg,
    bool requiresStation = true,
    bool requiresVehicleType = false,
    bool requireCertainTypes = false,
    bool requiresAxlesSelection = false,
    List<int> axlesOptions = const [2, 3, 4, 5],
    Map<int, int> axlesApiIds = const <int, int>{},
    List<List<String>> hiddenVehicleTypes = const <List<String>>[],
    List<List<String>> allowedVehicleTypes = const <List<String>>[],
    List<String> axlesForTypes = const <String>[],
    List<String> axlesMassRange = const <String>[],
    String vehicleStepSubtitle = 'Информация о транспортном средстве',
  }) {
    return PaymentFlowSpec(
      serviceId: service.id,
      requiresStation: requiresStation,
      requireCert: requireCert,
      requirePersonalReg: requirePersonalReg,
      requiresVehicleType: requiresVehicleType,
      requireCertainTypes: requireCertainTypes,
      requiresAxlesSelection: requiresAxlesSelection,
      axlesOptions: axlesOptions,
      axlesApiIds: axlesApiIds,
      axlesForTypes: axlesForTypes,
      axlesMassRange: axlesMassRange,
      // Физлица оплачивают картой, ЕРИП или «Оплати» — счёта у них нет, и
      // скачивать нечего.
      allowsDocumentDownload: false,
      hiddenVehicleTypes: hiddenVehicleTypes,
      allowedVehicleTypes: allowedVehicleTypes,

      vehicleStepSubtitle: requireCertainTypes
          ? 'Отдельные виды контрольно-диагностических работ'
          : vehicleStepSubtitle,
    );
  }

  /// Услуги, у которых итог берётся из расчёта, а реквизиты одинаковы.
  ///
  /// Сервер не возвращает сумму заказа по этим услугам (в частности, при оплате
  /// через ЕРИП), поэтому итогом становится расчёт `legal-price.php`. Набор
  /// реквизитов у них один: представитель и банковские данные без свидетельства
  /// о регистрации. Признак задан по номеру услуги, а не по названию: сервер
  /// меняет формулировки, и от текста зависели бы и набор полей, и итог.
  static const representativeServiceIds = <int>{58418, 58433, 58438};

  static PaymentFlowSpec resolve(
    PaymentService service, {
    required bool isLegal,
  }) {
    final spec = _resolveScenario(service, isLegal: isLegal);
    if (isLegal && representativeServiceIds.contains(service.id)) {
      return spec.copyWith(
        requiresVehicleCount: true,
        legalRequisites: representativeRequisites,
      );
    }
    return spec;
  }

  static PaymentFlowSpec _resolveScenario(
    PaymentService service, {
    required bool isLegal,
  }) {
    final id = service.id;
    final title = service.title.toLowerCase();
    final isEkmT = id == kEkmT || title.contains('екмт');
    final isRepeat =
        id == kRepeatDiagnostic ||
        title.contains('повторном') ||
        title.contains('отдельные виды');
    final isAdmission =
        id == kAdmissionRoad ||
        title.contains('допуск') ||
        title.contains('разрешени');
    final isInspection =
        id == kTechnicalInspection ||
        title.contains('государственного технического осмотра') ||
        title.contains('технического осмотра');
    final isExtraCheck = title.contains('дополнительная проверка');
    final isDangerousPermit = title.contains('опасных грузов') && !isExtraCheck;

    if (!isLegal) {
      // 2.1. Разрешение на допуск к дорожному движению: станция, личные данные
      // и сразу сумма со способом оплаты, без сведений о ТС.
      //
      // Количество ТС физлицам не отправляется — контракт `private-person.php`
      // и `price.php` его не принимает, — поэтому счётчик у физлиц не
      // запрашивается, иначе поле было бы декоративным.
      if (isInternationalCertificate(service)) {
        return _individual(
          service,
          requireCert: true,
          requirePersonalReg: true,
        );
      }
      if (isTechnicalControlCertificate(service)) {
        return _individual(
          service,
          requireCert: true,
          requirePersonalReg: true,
          requiresVehicleType: true,
        );
      }
      if (isRepeat) {
        // 2.3. Отдельные виды КДР: станция → личные данные → виды работ →
        // сумма и оплата.
        return _individual(
          service,
          requireCert: true,
          requirePersonalReg: false,
          requireCertainTypes: true,
        );
      }
      if (isAdmission) {
        // 2.1. Разрешение на допуск к дорожному движению: услуга → личные
        // данные (фамилия, имя, отчество, СТС, e-mail) → способ оплаты.
        return _individual(
          service,
          requireCert: true,
          requirePersonalReg: false,
          requiresStation: false,
        );
      }
      // 2.2. Государственный технический осмотр. Набор дополнительных полей
      // зависит от выбранного типа ТС: у автобуса — технически допустимая
      // общая масса, у грузовых и прицепов — свои параметры, поэтому поля
      // отрисовываются ровно те, что пришли с выбранным типом.
      //
      // Количество осей спрашивается только у прицепа в диапазоне
      // 0,75–3,5 т — это единственный случай, где оно нужно. У грузовика и у
      // остальных масс прицепа осей не спрашивают.
      return _individual(
        service,
        requireCert: true,
        requirePersonalReg: true,
        requiresVehicleType: true,
        requiresAxlesSelection: true,
        axlesOptions: const [1, 2],
        // Цена прицепа 0,75–3,5 т зависит от количества осей, и сервер ждёт не
        // число осей, а элемент справочника: `1` → 111, `2` → 49. Поля
        // `TRANS_OS` сервер для ГТО не присылает, поэтому соответствие задано
        // здесь. Со значением «1» вместо `111` цена не считается.
        axlesApiIds: const {1: 111, 2: 49},
        axlesForTypes: const ['прицеп'],
        axlesMassRange: const ['0,75', '3,5'],
        hiddenVehicleTypes: truckWithTrailerRule,
      );
    }

    // 1.8. Международный сертификат технического осмотра: безналичный расчёт,
    // реквизиты, количество ТС и счёт для скачивания.
    if (isInternationalCertificate(service)) {
      return PaymentFlowSpec(
        serviceId: id,
        isLegal: true,
        requiresVehicleCount: true,
        legalRequisites: representativeRequisites,
      );
    }
    // 1.3. Сертификат технического контроля: выбор станции, безналичный расчёт
    // или ЕРИП, реквизиты, количество ТС и кнопка скачивания счёта.
    if (isTechnicalControlCertificate(service)) {
      return PaymentFlowSpec(
        serviceId: id,
        isLegal: true,
        // У сертификата технического контроля спрашивается только количество
        // ТС, тип транспортного средства не запрашивается.
        requiresVehicleCount: true,
        legalRequisites: bankingOnlyRequisites,
      );
    }
    // 1.6. Проверка технического состояния ТС для соответствия нормам ЕКМТ:
    // тип ТС, затем количество осей (2 или 3) и количество ТС.
    if (isEkmT) {
      return PaymentFlowSpec(
        serviceId: id,
        isLegal: true,
        requiresVehicleType: true,
        requiresVehicleCount: true,
        requiresAxlesSelection: true,
        axlesOptions: const [2, 3],
        // По ЕКМТ проверяют только грузовой транспорт: грузовик, прицеп и их
        // комбинация. Оси запрашиваются у любого из трёх, у каждого они есть.
        allowedVehicleTypes: ekmtVehicleTypes,
        legalRequisites: fullLegalRequisites,
      );
    }
    // 1.7. Отдельные виды КДР при повторном прохождении: виды работ выбираются
    // списком, стоимость считается вместе с ними, документ один — счёт-договор.
    if (isRepeat) {
      return PaymentFlowSpec(
        serviceId: id,
        isLegal: true,
        requireCertainTypes: true,
        vehicleStepSubtitle: 'Отдельные виды контрольно-диагностических работ',
        // Без свидетельства о регистрации в реквизитах сервер отклоняет заказ
        // на оплате, поэтому набор реквизитов здесь полный.
        legalRequisites: fullLegalRequisites,
      );
    }
    // 1.5. Дополнительная проверка ТС для перевозки опасных грузов: чекбоксы
    // безнала и ЕРИП, реквизиты, количество ТС, ЕРИП-инструкция или счёт.
    if (isExtraCheck) {
      return PaymentFlowSpec(
        serviceId: id,
        isLegal: true,
        requiresVehicleCount: true,
        hasCheckboxesForPayment: true,
        legalRequisites: bankingOnlyRequisites,
      );
    }
    // 1.4. Государственный технический осмотр: выбор станции, чекбоксы всех
    // способов оплаты, короткий набор реквизитов (без банковских данных) и
    // выбор документа для скачивания. У прицепа 0,75–3,5 т, как и у физлиц,
    // спрашивается количество осей: значение уходит в заказ ключом `os`.
    if (isInspection) {
      return PaymentFlowSpec(
        serviceId: id,
        isLegal: true,
        requiresVehicleType: true,
        requiresAxlesSelection: true,
        axlesOptions: const [1, 2],
        // Те же идентификаторы, что и у физлиц: одна ось — `111`, две — `49`.
        axlesApiIds: const {1: 111, 2: 49},
        axlesForTypes: const ['прицеп'],
        axlesMassRange: const ['0,75', '3,5'],
        legalRequisites: shortLegalRequisites,
        hiddenVehicleTypes: truckWithTrailerRule,
      );
    }
    // 1.1. Свидетельство о допуске ТС к перевозке опасных грузов: выбор
    // организации, чекбоксы безнала и ЕРИП, реквизиты, количество ТС вместе со
    // стоимостью и один документ — счёт-договор.
    if (isDangerousPermit) {
      return PaymentFlowSpec(
        serviceId: id,
        isLegal: true,
        requiresVehicleCount: true,
        hasCheckboxesForPayment: true,
        legalRequisites: dangerousPermitRequisites,
        stationStepSubtitle: 'Выбор организации',
      );
    }
    // 1.2. Разрешение на допуск ТС к участию в дорожном движении: место
    // оказания услуги не запрашивается, сразу способ оплаты, затем реквизиты
    // и выбор одного из договоров для скачивания.
    if (isAdmission) {
      return PaymentFlowSpec(
        serviceId: id,
        isLegal: true,
        requiresStation: false,
        hasCheckboxesForPayment: true,
        legalRequisites: fullLegalRequisites,
      );
    }
    return PaymentFlowSpec(
      serviceId: id,
      isLegal: true,
      requiresVehicleCount: true,
      legalRequisites: fullLegalRequisites,
    );
  }
}
