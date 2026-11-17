import '../core/utils/text_utils.dart';

bool _looksLikeAdmissionPermitTitle(String title) {
  final normalized = title.toLowerCase();
  return normalized.contains('разрешение на допуск') ||
      (normalized.contains('разрешени') && normalized.contains('допуск'));
}

class PaymentService {
  PaymentService({
    required this.id,
    required this.title,
    this.type,
    this.price,
    this.requiresStation,
    this.requiresVehicleData,
    this.admissionPermit,
  });

  final int id;
  final String title;
  final String? type;
  final String? price;
  final bool? requiresStation;
  final bool? requiresVehicleData;
  final bool? admissionPermit;

  /// Разрешение на допуск к дорожному движению.
  ///
  /// Тип `KDR` сюда не относится: им помечаются отдельные виды
  /// контрольно-диагностических работ при повторном прохождении, и у них, в
  /// отличие от разрешения, организация и виды работ обязательны.
  bool get isAdmissionPermit {
    if (admissionPermit != null) return admissionPermit!;
    return _looksLikeAdmissionPermitTitle(title);
  }

  bool get requiresStationOverride => requiresStation ?? !isAdmissionPermit;

  bool get requiresVehicle => requiresVehicleData ?? !isAdmissionPermit;

  factory PaymentService.fromJson(Map<String, dynamic> json) {
    final id = parseApiInt(json['id']) ?? 0;
    final title = cleanApiText(json['title'] ?? json['value'] ?? json['name']);
    final normalizedTitle = title.toLowerCase();
    final requiresStation = _optionalBool(
      json['requiresStation'] ?? json['needStation'] ?? json['stationRequired'],
    );
    final requiresVehicle = _optionalBool(
      json['requiresVehicle'] ?? json['needVehicle'] ?? json['vehicleRequired'],
    );
    final admissionPermit = _optionalBool(
      json['isAdmissionPermit'] ?? json['admissionPermit'] ?? json['permit'],
    );
    return PaymentService(
      id: id,
      title: title,
      // Тип услуги определяется её номером, а не названием: у разрешения на
      // допуск в название попадают слова «разрешение на допуск», но сервер
      // знает его как `DEF`. С `KDR` сервер требует станцию, а у разрешения её
      // нет, и расчёт падает с «Не указана станция».
      type:
          cleanApiTextOrNull(json['type']) ??
          _serviceType(id) ??
          (normalizedTitle.contains('кдр') ||
                  normalizedTitle.contains('отдельные виды')
              ? 'KDR'
              : 'DEF'),
      price: cleanApiTextOrNull(json['price']),
      requiresStation: requiresStation,
      requiresVehicleData: requiresVehicle,
      admissionPermit: admissionPermit,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentService &&
          other.id == id &&
          other.title == title &&
          other.type == type &&
          other.price == price;

  @override
  int get hashCode => Object.hash(id, title, type, price);
}

/// Тип услуги, который ждёт сервер в расчёте стоимости.
///
/// Возвращается `null` для услуг без своего типа: там решает уже серверное
/// поле `type` или название.
String? _serviceType(int id) {
  if (id == 58442) return 'KDR';
  if (id == 58439) return 'GTO';
  if (id == 58434) return 'DEF';
  return null;
}

final _stationNumberPattern = RegExp(r'ДС\s*№?\s*\d+', caseSensitive: false);

String _dedupeStationNumber(String title) {
  final matches = _stationNumberPattern.allMatches(title).toList();
  if (matches.length < 2) return title;
  final seen = <String>{};
  final buffer = StringBuffer();
  var cursor = 0;
  for (final match in matches) {
    buffer.write(title.substring(cursor, match.start));
    final token = match
        .group(0)!
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(' ', '')
        .toUpperCase();
    if (seen.add(token)) {
      buffer.write(match.group(0)!);
    }
    cursor = match.end;
  }
  buffer.write(title.substring(cursor));
  return buffer
      .toString()
      .replaceAll(RegExp(r'\s{2,}'), ' ')
      .replaceAll(RegExp(r'\s*-\s*$'), '')
      .trim();
}

class PaymentStation {
  PaymentStation({required this.id, required this.title, this.address});

  final int id;
  final String title;
  final String? address;

  factory PaymentStation.fromJson(Map<String, dynamic> json) {
    final rawTitle = cleanApiText(
      json['title'] ?? json['value'] ?? json['name'],
    );
    final title = _dedupeStationNumber(rawTitle);
    final rawAddress = cleanApiTextOrNull(json['address']);
    final normalizedTitle = title.toLowerCase();
    var address = rawAddress;
    if (address != null) {
      final normalizedAddress = address.toLowerCase();
      final hasWords = RegExp(
        r'[а-яёa-z]{3,}',
        caseSensitive: false,
      ).hasMatch(address);
      final isOnlyStationNumber =
          _stationNumberPattern
                  .allMatches(address)
                  .map(
                    (match) =>
                        match.group(0)!.replaceAll(' ', '').toUpperCase(),
                  )
                  .toSet()
                  .length ==
              1 &&
          address.replaceAll(_stationNumberPattern, '').trim().isEmpty;
      final alreadyInTitle =
          normalizedAddress.isNotEmpty &&
          normalizedTitle.contains(normalizedAddress);
      if (isOnlyStationNumber || alreadyInTitle || !hasWords) {
        address = null;
      }
    }
    return PaymentStation(
      id: parseApiInt(json['id']) ?? 0,
      title: title,
      address: address,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentStation && other.id == id && other.title == title;

  @override
  int get hashCode => Object.hash(id, title);
}

class PaymentMethod {
  PaymentMethod({
    required this.id,
    this.title,
    this.saleCard,
    this.description,
    this.type,
    this.rawId,
  });

  final int id;
  final String? title;
  final String? saleCard;
  final String? description;
  final String? type;

  /// Идентификатор в том виде, в котором его вернул сервер.
  ///
  /// Нужен, когда значение не является целым числом: сервер принимает такой
  /// идентификатор и в этом виде, а приводить его к `int` нельзя.
  final String? rawId;

  /// Значение для поля `payMethod` запроса заказа.
  Object get apiValue => rawId ?? id;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final title = cleanApiTextOrNull(
      json['title'] ??
          json['name'] ??
          json['value'] ??
          json['caption'] ??
          json['description'],
    );
    // ID приходит под разными ключами в зависимости от версии выдачи.
    final rawIdValue =
        json['id'] ??
        json['paymentMethodId'] ??
        json['paymentId'] ??
        json['methodId'] ??
        json['payMethod'] ??
        json['paymentMethod'] ??
        json['value'] ??
        json['code'] ??
        json['key'];
    final parsedId = parseApiInt(rawIdValue);
    return PaymentMethod(
      id: parsedId ?? 0,
      rawId: rawIdValue?.toString(),
      title: title,
      saleCard: cleanApiTextOrNull(json['saleCard']),
      description: cleanApiTextOrNull(json['description']),
      type:
          cleanApiTextOrNull(json['type'] ?? json['code'] ?? json['method']) ??
          _paymentMethodType(title),
    );
  }
}

/// Способ оплаты в терминах приложения.
///
/// Сервер отдаёт и служебные коды (`webpay`, `oplati`, `erip`, `noncash`), и
/// названия («Банковский перевод», «АИС «Расчёт» (ЕРИП)», «Банковской картой
/// онлайн», «Приложение «Оплати»»), поэтому тип определяется по обоим полям.
enum PaymentMethodKind { erip, noncash, webpay, oplati, unknown }

PaymentMethodKind classifyPaymentMethod({
  String? type,
  String? title,
  String? payService,
}) {
  final tokens = '${type ?? ''} ${title ?? ''} ${payService ?? ''}'
      .toLowerCase();
  if (tokens.trim().isEmpty) return PaymentMethodKind.unknown;
  // Банковский перевод часто подписан как «безналичный расчёт», поэтому его
  // нужно распознать раньше, чем проверять признаки ЕРИП.
  final isBankTransfer =
      tokens.contains('noncash') ||
      tokens.contains('безнал') ||
      tokens.contains('перевод') ||
      tokens.contains('перечисл');
  if (tokens.contains('оплати') || tokens.contains('oplati')) {
    return PaymentMethodKind.oplati;
  }
  if (tokens.contains('ерип') ||
      tokens.contains('erip') ||
      ((tokens.contains('расчет') || tokens.contains('расчёт')) &&
          !isBankTransfer)) {
    return PaymentMethodKind.erip;
  }
  if (tokens.contains('webpay') || tokens.contains('карт')) {
    return PaymentMethodKind.webpay;
  }
  if (isBankTransfer || tokens.contains('счет') || tokens.contains('счёт')) {
    return PaymentMethodKind.noncash;
  }
  return PaymentMethodKind.unknown;
}

/// Определяет способ оплаты заказа, отдавая выбор пользователя приоритет над
/// данными сервера.
///
/// Выбранный способ важнее `payService` из ответа заказа. Раньше оба значения
/// попадали в одну строку поиска, и при безналичном переводе юрлица `payService`
/// со значением `webpay` перебивал выбор: способ опознавался как оплата картой,
/// и внизу появлялась активная кнопка «Оплатить» там, где платить в приложении
/// нечего. Теперь способ читается первым, а `payService` используется, только
/// когда способ опознать не удалось.
PaymentMethodKind resolvePaymentKind({
  String? methodType,
  String? methodTitle,
  String? payService,
}) {
  final byMethod = classifyPaymentMethod(type: methodType, title: methodTitle);
  if (byMethod != PaymentMethodKind.unknown) return byMethod;
  return classifyPaymentMethod(payService: payService);
}

/// Подпись скачиваемого документа: как в исходном приложении — из `value`.
///
/// Если `value` пустой, используется запасное название: иначе вместо названия
/// показывалось бы «Документ».
String documentLabel(String? value, {String? title}) {
  final raw = [value, title]
      .map((item) => item?.trim() ?? '')
      .firstWhere((item) => item.isNotEmpty, orElse: () => '');
  return raw.isEmpty ? 'Документ' : raw;
}

/// Документы, которых нет в списке скачивания ни у одной услуги.
///
/// Сервер отдаёт шаблоны без разбора по услугам, поэтому в список попадает
/// лишнее: и «Договор», и «Акт». «Договор» у заказа есть, но по этой ссылке
/// сервер ничего не отдаёт, а «Акт» в оплате не выдаётся вовсе — оба пункта
/// только обещают возможность, которой нет.
///
/// Сверка идёт по буквам без цифр: «Акт», «акт» и «Акт №5» — один документ.
const _hiddenDocumentLabels = <String>['Договор', 'Акт'];

/// Скрывается ли документ из списка скачивания.
bool isDocumentHidden(String? value, {String? title}) {
  final letters = documentLabel(
    value,
    title: title,
  ).toLowerCase().replaceAll(RegExp('[^a-zа-яё]'), '');
  if (letters.isEmpty) return false;
  return _hiddenDocumentLabels
      .map((hidden) => hidden.toLowerCase().replaceAll(RegExp('[^a-яё]'), ''))
      .any((hidden) => hidden == letters);
}

/// Является ли документ договором.
///
/// Договор из списка скачивания убирается: у заказа он есть, но скачать его
/// нельзя — по этой ссылке сервер ничего не отдаёт, и пункт в списке выбора
/// только мешает. Сверка идёт по буквам, поэтому «Договор», «договор» и
/// «Договор №123» — это один и тот же пункт, а «Договор оказания услуг» — уже
/// другой документ и остаётся.
bool isContractDocument(String? value, {String? title}) {
  final letters = documentLabel(
    value,
    title: title,
  ).toLowerCase().replaceAll(RegExp('[^a-zа-яё]'), '');
  return letters == 'договор';
}

/// Номер заказа из ссылки на документ.
///
/// Сервер отдаёт ссылку вида `.../doc_new/<группа>.<номер заказа>.<расширение>`.
/// Именно номер заказа, а не идентификатор файла, нужен `get_report.php`:
/// по ссылке `doc_new` сервер отвечает 404, скачать документ можно только
/// пересобрав адрес с этим номером.
int? orderIdFromDocumentHref(String? href) {
  final raw = href?.trim();
  if (raw == null || raw.isEmpty) return null;
  final uri = Uri.tryParse(raw);
  final segment = uri != null && uri.pathSegments.isNotEmpty
      ? uri.pathSegments.last
      : raw.split('/').last;
  final parts = segment.split('.');
  if (parts.length < 2) return null;
  return int.tryParse(parts[1]);
}

/// Название документа без хвоста « - 1.1909564.pdf».
///
/// В истории к названию файла сервер дописывает номер заказа и расширение,
/// и без этой обрезки название не совпадает с шаблоном.
String documentTitle(String? title) {
  final raw = title?.trim() ?? '';
  if (raw.isEmpty) return raw;
  return raw.replaceFirst(RegExp(r'\s*-\s*\d+\.\d+\.\w+$'), '').trim();
}

/// Ключ сравнения названий документов: буквы и цифры в нижнем регистре.
String _documentKey(String? value) =>
    (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-zа-яё0-9]'), '');

/// Подбирает шаблон документа по названию файла.
///
/// Названия в истории и в списке шаблонов совпадают не всегда: «Счет-договор и
/// АКТ оказанных услуг» соответствует шаблону «Счет-договор ». Сначала ищем
/// точное совпадение, затем шаблон, которым название начинается, и только потом
/// самый длинный входящий.
DocumentTemplate? matchDocumentTemplate(
  String? title,
  List<DocumentTemplate> templates,
) {
  final target = _documentKey(documentTitle(title));
  if (target.isEmpty) return null;
  DocumentTemplate? prefix;
  DocumentTemplate? contains;
  var prefixLength = -1;
  var containsLength = -1;
  for (final template in templates) {
    final key = _documentKey(template.title);
    if (key.isEmpty) continue;
    if (key == target) return template;
    if (target.startsWith(key)) {
      if (key.length > prefixLength) {
        prefix = template;
        prefixLength = key.length;
      }
    } else if (target.contains(key) && key.length > containsLength) {
      contains = template;
      containsLength = key.length;
    }
  }
  return prefix ?? contains;
}

String? _paymentMethodType(String? title) {
  return switch (classifyPaymentMethod(title: title)) {
    PaymentMethodKind.erip => 'erip',
    PaymentMethodKind.noncash => 'noncash',
    PaymentMethodKind.webpay => 'webpay',
    PaymentMethodKind.oplati => 'oplati',
    PaymentMethodKind.unknown => null,
  };
}

bool? _optionalBool(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final normalized = value.toString().toLowerCase();
  if (normalized == 'true' || normalized == '1') return true;
  if (normalized == 'false' || normalized == '0') return false;
  return null;
}

class VehicleType {
  VehicleType({required this.id, required this.title, this.fields});

  final int id;
  final String title;
  final List<VehicleTypeField>? fields;

  factory VehicleType.fromJson(Map<String, dynamic> json) {
    final rawFields = json['fields'] ?? json['fieldList'];
    final rawTitle = cleanApiText(
      json['title'] ?? json['value'] ?? json['name'],
    );
    return VehicleType(
      id: parseApiInt(json['id']) ?? 0,
      title: _vehicleTitle(rawTitle, json['name']),
      fields: rawFields is List
          ? rawFields
                .whereType<Map>()
                .map(
                  (value) => VehicleTypeField.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
                )
                .toList()
          : null,
    );
  }
}

String _vehicleTitle(String title, Object? rawName) {
  final name = rawName?.toString().toLowerCase() ?? '';
  if (name == 'trans' || name == 'vehicle' || name == 'транспорт') {
    return 'Тип транспортного средства';
  }
  return title.isEmpty ? 'Транспортное средство' : title;
}

class VehicleTypeField {
  VehicleTypeField({
    required this.name,
    required this.title,
    this.values,
    this.isRequired = false,
    this.min,
    this.parentField,
    this.parentValue,
  });

  final String name;
  final String title;
  final List<DropdownValue>? values;
  final bool isRequired;
  final Object? min;

  /// Имя поля, от которого зависит это (например, `TRANS` для `TRANS_MASSA`).
  final String? parentField;

  /// Значение родительского поля, при котором поле показывается.
  ///
  /// Сервер описывает параметры ТС одним плоским списком: масса приходит
  /// несколькими записями с одним именем, различающимися `parentValue`
  /// (28 — автобус, 29 — грузовой, 34 — прицеп). Без этого признака нельзя
  /// понять, какую массу показывать для выбранного типа.
  final Object? parentValue;

  factory VehicleTypeField.fromJson(Map<String, dynamic> json) {
    final rawValues =
        json['values'] ?? json['list'] ?? json['options'] ?? json['items'];
    final name =
        (json['name'] ?? json['field'] ?? json['code'])?.toString() ?? '';
    final values = <DropdownValue>[];
    if (rawValues is List) {
      for (final rawValue in rawValues) {
        if (rawValue is Map) {
          values.add(
            DropdownValue.fromJson(Map<String, dynamic>.from(rawValue)),
          );
        } else if (rawValue != null) {
          values.add(DropdownValue.fromValue(rawValue));
        }
      }
    } else if (rawValues is Map) {
      for (final entry in rawValues.entries) {
        final value = entry.value;
        final map = value is Map
            ? Map<String, dynamic>.from(value)
            : <String, dynamic>{'value': value, 'title': value};
        map.putIfAbsent('id', () => entry.key);
        values.add(DropdownValue.fromJson(map));
      }
    }
    return VehicleTypeField(
      name: name,
      title: _vehicleFieldTitle(name, json['title'] ?? json['label']),
      isRequired: _isRequired(json['isRequired'] ?? json['required']),
      values: values.isEmpty ? null : values,
      min: json['min'],
      parentField: json['parentField']?.toString(),
      parentValue: json['parentValue'],
    );
  }
}

String _vehicleFieldTitle(String name, Object? rawTitle) {
  final normalized = name.toLowerCase().replaceAll(
    RegExp(r'[^a-zа-яё0-9]'),
    '',
  );
  final title = cleanApiText(rawTitle);
  final normalizedTitle = title.toLowerCase().replaceAll(
    RegExp(r'[^a-zа-яё0-9]'),
    '',
  );
  final token = normalized.isEmpty ? normalizedTitle : normalized;
  if (token.contains('massa')) return 'Масса транспортного средства';
  if (token.contains('motor') || token == 'engine') {
    return 'Тип двигателя';
  }
  if (token.contains('kol') || token.contains('wheel')) {
    return 'Количество колёс';
  }
  if (token.contains('transos')) return 'Особые условия';
  if (normalized == 'trans' || normalized == 'vehicle') {
    return 'Тип транспортного средства';
  }
  if (title.isNotEmpty) return title;
  return name;
}

bool _isRequired(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true' || value?.toString() == '1';
}

class DropdownValue {
  DropdownValue({required this.id, required this.title, this.rawId});

  final int id;
  final String title;
  final String? rawId;

  Object get apiValue => rawId ?? id;

  factory DropdownValue.fromJson(Map<String, dynamic> json) {
    final rawId = (json['id'] ?? json['value'] ?? json['key'])?.toString();
    final parsedId = parseApiInt(rawId);
    final value = cleanApiText(
      json['title'] ?? json['value'] ?? json['label'] ?? json['name'],
    );
    return DropdownValue(
      id: parsedId ?? 0,
      title: value.isEmpty ? 'Вариант ${rawId ?? '0'}' : value,
      rawId: parsedId == null ? rawId : null,
    );
  }

  factory DropdownValue.fromValue(Object? rawValue) {
    final text = cleanApiText(rawValue);
    final parsedId = parseApiInt(rawValue);
    return DropdownValue(
      id: parsedId ?? 0,
      title: text.isEmpty ? 'Вариант' : text,
      rawId: parsedId == null ? text : null,
    );
  }
}

class PaymentHistoryItem {
  PaymentHistoryItem({
    required this.id,
    this.serviceName,
    this.visitDate,
    this.stationName,
    this.certNumber,
    this.payServiceName,
    this.price,
    this.files,
    this.orderId,
    this.status,
  });

  final int id;
  final String? orderId;
  final String? status;
  final String? serviceName;
  final String? visitDate;
  final String? stationName;
  final String? certNumber;
  final String? payServiceName;
  final String? price;
  final List<PaymentFile>? files;

  bool get isPaid {
    final normalized = _statusValue(status);
    if (normalized == null) return false;
    return const {
      'paid',
      'success',
      'successful',
      'completed',
      'complete',
      'confirmed',
      'оплачено',
      'оплата',
      'завершено',
      '1',
      'true',
    }.contains(normalized);
  }

  bool get isFailed {
    final normalized = _statusValue(status);
    return const {
      'failed',
      'error',
      'rejected',
      'declined',
      'ошибка',
      'отклонено',
      '0',
      'false',
    }.contains(normalized);
  }

  /// Совпадает ли запись истории с заказом.
  ///
  /// Номер сравнивается по буквам и цифрам: сервер отдаёт его то строкой, то
  /// числом, иногда с разделителями, а при строгом сравнении оплаченный заказ не
  /// находился и оставался «не подтверждённым».
  bool matchesOrder(String value) {
    final expected = _orderKey(value);
    if (expected.isEmpty) return false;
    if (_orderKey(orderId) == expected) return true;
    final asNumber = int.tryParse(expected);
    return asNumber != null && id == asNumber;
  }

  /// Буквы и цифры номера в нижнем регистре, без разделителей.
  static String _orderKey(String? value) =>
      (value ?? '').toLowerCase().replaceAll(RegExp(r'[^a-zа-яё0-9]'), '');

  factory PaymentHistoryItem.fromJson(Map<String, dynamic> json) {
    final rawFiles = json['files'];
    return PaymentHistoryItem(
      id: parseApiInt(json['id'] ?? json['elementId']) ?? 0,
      orderId: cleanApiTextOrNull(
        json['orderId'] ??
            json['orderID'] ??
            json['order_id'] ??
            json['orderNumber'] ??
            json['orderNum'] ??
            json['number'] ??
            json['code'],
      ),
      status: cleanApiTextOrNull(json['status'] ?? json['state']),
      serviceName: cleanApiTextOrNull(json['serviceName'] ?? json['service']),
      visitDate: cleanApiTextOrNull(
        json['visitDate'] ?? json['date'] ?? json['dateTime'],
      ),
      stationName: cleanApiTextOrNull(json['stationName'] ?? json['station']),
      certNumber: cleanApiTextOrNull(json['certNumber'] ?? json['regNumber']),
      payServiceName: cleanApiTextOrNull(
        json['payServiceName'] ?? json['payService'],
      ),
      price: cleanApiTextOrNull(json['price'] ?? json['total']),
      files: rawFiles is List
          ? rawFiles
                .whereType<Map>()
                .map(
                  (value) =>
                      PaymentFile.fromJson(Map<String, dynamic>.from(value)),
                )
                .toList()
          : null,
    );
  }
}

String? _statusValue(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  return normalized;
}

class PaymentFile {
  PaymentFile({this.id, this.href, this.title});

  final int? id;
  final String? href;
  final String? title;

  factory PaymentFile.fromJson(Map<String, dynamic> json) => PaymentFile(
    id: parseApiInt(
      json['id'] ?? json['templateID'] ?? json['templateId'] ?? json['code'],
    ),
    href: cleanApiTextOrNull(json['href'] ?? json['url']),
    title: cleanApiTextOrNull(json['title'] ?? json['name']),
  );
}

class PaymentHistoryGroup {
  PaymentHistoryGroup({required this.monthName, required this.posts});

  final String monthName;
  final List<PaymentHistoryItem> posts;

  factory PaymentHistoryGroup.fromJson(Map<String, dynamic> json) {
    final rawPosts = json['posts'];
    return PaymentHistoryGroup(
      monthName: cleanApiText(json['monthName']),
      posts: rawPosts is List
          ? rawPosts
                .whereType<Map>()
                .map(
                  (value) => PaymentHistoryItem.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class PriceInfo {
  const PriceInfo({this.price});

  final String? price;

  factory PriceInfo.fromResponse(Object? response) {
    // Ответ приходит объектом с суммой, но для части услуг сервер отдаёт её
    // без обёртки — просто числом или строкой.
    if (response is! Map) {
      return PriceInfo(price: _scalarPrice(response));
    }
    final root = Map<String, dynamic>.from(response);
    final data = root['data'];
    if (data is Map) {
      return PriceInfo(price: _priceValue(Map<String, dynamic>.from(data)));
    }
    return PriceInfo(price: _priceValue(root) ?? _scalarPrice(data));
  }
}

/// Сумма, пришедшая без объекта-обёртки: число или строка с ценой.
String? _scalarPrice(Object? value) {
  if (value is num) return value.toString();
  final text = cleanApiTextOrNull(value);
  if (text == null) return null;
  // Берём только то, что похоже на сумму, чтобы не показать вместо цены
  // номер заказа или идентификатор услуги.
  if (!RegExp(r'^\d+(?:[.,]\d+)?$').hasMatch(text)) return null;
  return text;
}

String? _priceValue(Map<String, dynamic>? value) {
  if (value == null) return null;
  for (final key in const [
    'itogo',
    'total',
    'amount',
    'finalPrice',
    'price',
    'cost',
    'sum',
    'value',
  ]) {
    final direct = cleanApiTextOrNull(value[key]);
    if (direct != null) return direct;
    // Сумма может лежать объектом с полем вложенного вида.
    final nested = value[key];
    if (nested is Map) {
      final candidate = _priceValue(Map<String, dynamic>.from(nested));
      if (candidate != null) return candidate;
    }
  }
  for (final nested in value.values) {
    if (nested is Map) {
      final candidate = _priceValue(Map<String, dynamic>.from(nested));
      if (candidate != null) return candidate;
    }
  }
  return null;
}

/// Сумма, которую сервер возьмёт за заказ.
///
/// Источники различаются по надёжности, поэтому берутся в таком порядке:
/// подписанная сумма платёжной формы, явное поле суммы в ответе и текст
/// инструкции ЕРИП. Предварительный расчёт сюда не входит: у ГТО он на 5 BYN
/// меньше суммы заказа, и показывать расчёт вместо итога означало бы показать
/// одну цифру, а списать другую.
String? _orderTotal(
  Map<String, dynamic> data,
  Object? rawWebpay,
  String? info,
) {
  if (rawWebpay is Map) {
    final total = _positiveAmount(_scalarPrice(rawWebpay['wsb_total']));
    if (total != null) return total;
  }
  return (_positiveAmount(_priceValue(data)) ??
      _positiveAmount(eripInstructionAmount(info)));
}

/// Сумма из текста инструкции ЕРИП вида «на сумму 64.2 руб.».
///
/// Отдельного поля с суммой у ЕРИП нет — она есть только в тексте, поэтому
/// берём число, стоящее рядом со словами «руб», «р.», «BYN» или «бел.», и
/// только если оно похоже на сумму. У заказа без цены в этом месте пусто, и
/// итогом остаётся null.
///
/// Услуги, у которых инструкция приходит вовсе без суммы, разбираются уже на
/// экране: там итогом заказа считается расчёт `legal-price.php`.
String? eripInstructionAmount(String? info) {
  if (info == null) return null;
  final match = RegExp(
    r'([0-9]+(?:[.,][0-9]{1,2})?)\s*(?:руб(?:\.|л(?:ей|я|ь)?|я)?|р\.|byn|бел\.?\s*руб)',
    caseSensitive: false,
  ).firstMatch(info);
  return _scalarPrice(match?.group(1));
}

/// Положительная сумма: ноль и нечисловой текст — это отсутствие цены, а цена.
String? _positiveAmount(String? raw) {
  final text = _scalarPrice(raw);
  if (text == null) return null;
  final value = double.tryParse(text.replaceAll(',', '.'));
  return value != null && value > 0 ? text : null;
}

String? _firstPaymentLink(Map<String, dynamic> data) {
  const keys = [
    'linkToPay',
    'url',
    'redirectUrl',
    'redirect_url',
    'location',
    'paymentLink',
    'payLink',
    'link',
    'href',
    'qrCode',
    'qr',
    'deepLink',
    'appUrl',
    'urlPay',
    'oplatiLink',
  ];
  for (final key in keys) {
    final value = data[key];
    if (value is String && _looksLikePaymentUri(value)) {
      return cleanApiTextOrNull(value);
    }
    if (value is List) {
      for (final item in value) {
        if (item is String && _looksLikePaymentUri(item)) {
          return cleanApiTextOrNull(item);
        }
      }
    }
  }
  return null;
}

String? _extractPaymentLink(String? text) {
  if (text == null) return null;
  final match = RegExp(
    r'((?:https?|oplati|beltech)://[^\s<]+)',
    caseSensitive: false,
  ).firstMatch(text);
  return cleanApiTextOrNull(match?.group(1));
}

bool _looksLikePaymentUri(String value) {
  final normalized = value.trim().toLowerCase();
  return normalized.startsWith('http://') ||
      normalized.startsWith('https://') ||
      normalized.startsWith('oplati://') ||
      normalized.startsWith('beltech://') ||
      normalized.contains('://');
}

class OrderInfo {
  OrderInfo({
    this.orderId,
    this.payService,
    this.info,
    this.infoHtml,
    this.linkToPay,
    this.webpayForm,
    this.documents,
    this.price,
  });

  final String? orderId;
  final String? payService;
  final String? info;
  final String? infoHtml;
  final String? linkToPay;
  final WebPayForm? webpayForm;
  final List<DocumentTemplate>? documents;

  /// Итоговая сумма заказа по версии сервера.
  ///
  /// Предварительный расчёт стоимости и сумма, которая попадает в заказ,
  /// различаются: у ГТО итог на 5 BYN больше расчёта, потому что сервер
  /// учитывает печать диагностической карты. Показывать нужно именно эту
  /// сумму, иначе на оплате пользователь увидит другую цифру.
  ///
  /// У веб-оплаты сумма приходит в подписанной форме (`wsb_total`), у ЕРИП
  /// отдельного поля нет — она читается из текста инструкции. Если сервер не
  /// вернул ни того, ни другого, сумма остаётся пустой: платить по неизвестной
  /// цене нельзя.
  final String? price;

  OrderInfo copyWith({List<DocumentTemplate>? documents, String? price}) {
    return OrderInfo(
      orderId: orderId,
      payService: payService,
      info: info,
      infoHtml: infoHtml,
      linkToPay: linkToPay,
      webpayForm: webpayForm,
      documents: documents ?? this.documents,
      price: price ?? this.price,
    );
  }

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    var data = Map<String, dynamic>.from(json);
    String? scalarLink;
    for (var depth = 0; depth < 4; depth++) {
      final nested = data['data'] ?? data['result'] ?? data['response'];
      if (nested is Map) {
        data = <String, dynamic>{...data, ...Map<String, dynamic>.from(nested)};
        continue;
      }
      if (nested is String && _looksLikePaymentUri(nested)) {
        scalarLink ??= cleanApiTextOrNull(nested);
      }
      if (nested is List && nested.isNotEmpty) {
        final first = nested.first;
        if (first is String && _looksLikePaymentUri(first)) {
          scalarLink ??= cleanApiTextOrNull(first);
        }
      }
      break;
    }
    // `infoHtml` — инструкция ЕРИП, сервер отдаёт её отдельным ключом.
    final rawInfo =
        data['info'] ??
        data['infoHtml'] ??
        data['instruction'] ??
        data['instructions'] ??
        data['message'];
    final info = cleanApiTextOrNull(rawInfo);
    final serviceValue = data['payService'];
    if (serviceValue is Map) {
      data = <String, dynamic>{
        ...data,
        ...Map<String, dynamic>.from(serviceValue),
      };
    }
    final payServiceValue = serviceValue is Map
        ? serviceValue['type'] ??
              serviceValue['name'] ??
              serviceValue['value'] ??
              serviceValue['code'] ??
              serviceValue['id']
        : data['payService'];
    final rawWebpay =
        data['webpayForm'] ??
        data['webPayForm'] ??
        data['webpay'] ??
        data['webPay'] ??
        data['form'];
    final rawDocuments =
        data['documents'] ??
        data['docs'] ??
        data['docList'] ??
        data['files'] ??
        data['templates'];
    return OrderInfo(
      // Номер заказа приходит по разным ключам: у веб-оплаты это `id`,
      // у ЕРИП и безнала — `orderId`/`orderNumber`/`number`.
      orderId:
          (data['orderId'] ??
                  data['orderNumber'] ??
                  data['orderNum'] ??
                  data['orderN'] ??
                  data['order'] ??
                  data['number'] ??
                  data['id'] ??
                  data['ID'])
              ?.toString(),
      payService: cleanApiTextOrNull(
        payServiceValue ??
            data['paymentService'] ??
            data['paymentMethod'] ??
            data['method'] ??
            data['type'],
      ),
      info: info,
      infoHtml: rawInfo is String ? rawInfo : null,
      linkToPay:
          _firstPaymentLink(data) ?? scalarLink ?? _extractPaymentLink(info),
      webpayForm: rawWebpay is Map
          ? WebPayForm.fromJson(Map<String, dynamic>.from(rawWebpay))
          : null,
      documents: rawDocuments is List
          ? rawDocuments
                .whereType<Map>()
                .map(
                  (value) => DocumentTemplate.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
                )
                .toList()
          : null,
      price: _orderTotal(data, rawWebpay, info),
    );
  }
}

class WebPayForm {
  WebPayForm({
    this.action,
    this.wsbCurrencyId,
    this.wsbEmail,
    this.wsbInvoiceItemName,
    this.wsbInvoiceItemPrice,
    this.wsbInvoiceItemQuantity,
    this.wsbNotifyUrl,
    this.wsbOrderNum,
    this.wsbReturnUrl,
    this.wsbSeed,
    this.wsbSignature,
    this.wsbStoreid,
    this.wsbTest,
    this.wsbVersion,
    this.wsbTotal,
    this.rawFields = const {},
  });

  final String? action;
  final String? wsbCurrencyId;
  final String? wsbEmail;
  final String? wsbInvoiceItemName;
  final String? wsbInvoiceItemPrice;
  final String? wsbInvoiceItemQuantity;
  final String? wsbNotifyUrl;
  final String? wsbOrderNum;
  final String? wsbReturnUrl;
  final String? wsbSeed;
  final String? wsbSignature;
  final String? wsbStoreid;
  final String? wsbTest;
  final String? wsbVersion;
  final String? wsbTotal;
  final Map<String, dynamic> rawFields;

  factory WebPayForm.fromJson(Map<String, dynamic> json) {
    final rawFields = <String, dynamic>{};
    final nestedFields =
        json['fields'] ?? json['inputs'] ?? json['form'] ?? json['data'];
    void addFields(Object? fields) {
      if (fields is Map) {
        for (final entry in fields.entries) {
          rawFields[entry.key.toString()] = entry.value;
        }
      } else if (fields is List) {
        for (final field in fields.whereType<Map>()) {
          final name = field['name'] ?? field['key'];
          if (name != null) rawFields[name.toString()] = field['value'];
        }
      }
    }

    addFields(nestedFields);
    for (final entry in json.entries) {
      final key = entry.key.toString();
      if (key.startsWith('wsb_') ||
          key.startsWith('*') ||
          key.toLowerCase() == 'scart') {
        rawFields[key] = entry.value;
      }
    }
    for (final key in const [
      'wsb_invoice_item_name',
      'wsb_invoice_item_price',
      'wsb_invoice_item_quantity',
    ]) {
      final indexedKey = '$key[0]';
      if (rawFields.containsKey(key) && !rawFields.containsKey(indexedKey)) {
        rawFields[indexedKey] = rawFields.remove(key);
      }
    }
    final action = cleanApiTextOrNull(
      json['action'] ?? (nestedFields is Map ? nestedFields['action'] : null),
    );
    return WebPayForm(
      action: action,
      wsbCurrencyId: json['wsb_currency_id']?.toString(),
      wsbEmail: cleanApiTextOrNull(json['wsb_email']),
      wsbInvoiceItemName: cleanApiTextOrNull(json['wsb_invoice_item_name']),
      wsbInvoiceItemPrice: json['wsb_invoice_item_price']?.toString(),
      wsbInvoiceItemQuantity: json['wsb_invoice_item_quantity']?.toString(),
      wsbNotifyUrl: cleanApiTextOrNull(json['wsb_notify_url']),
      wsbOrderNum: cleanApiTextOrNull(json['wsb_order_num']),
      wsbReturnUrl: cleanApiTextOrNull(json['wsb_return_url']),
      wsbSeed: cleanApiTextOrNull(json['wsb_seed']),
      wsbSignature: cleanApiTextOrNull(json['wsb_signature']),
      wsbStoreid: cleanApiTextOrNull(json['wsb_storeid']),
      wsbTest: cleanApiTextOrNull(json['wsb_test']),
      wsbVersion: cleanApiTextOrNull(json['wsb_version']),
      wsbTotal: json['wsb_total']?.toString(),
      rawFields: rawFields,
    );
  }
}

class DocumentTemplate {
  DocumentTemplate({this.id, this.code, this.title, this.value, this.href});

  final int? id;
  final String? code;
  final String? title;
  final String? value;
  final String? href;

  factory DocumentTemplate.fromJson(Map<String, dynamic> json) {
    return DocumentTemplate(
      id: parseApiInt(json['id'] ?? json['templateID'] ?? json['templateId']),
      code: cleanApiTextOrNull(json['code']),
      title: cleanApiTextOrNull(json['title'] ?? json['name']),
      value: cleanApiTextOrNull(json['value']),
      href: cleanApiTextOrNull(json['href'] ?? json['url'] ?? json['link']),
    );
  }
}
