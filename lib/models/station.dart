import '../core/utils/text_utils.dart';

class DiagnosticStation {
  DiagnosticStation({
    required this.id,
    this.title,
    this.stationNumber,
    this.address,
    this.phone,
    this.workTime,
    this.categories,
    this.services,
    this.isOnlineRecord = false,
    this.isBelto = false,
    this.lat,
    this.lon,
    this.regionId,
  });

  final int id;
  final String? title;
  final String? stationNumber;
  final String? address;
  final String? phone;
  final String? workTime;
  final List<String>? categories;

  /// Название станции вместе с номером, одной строкой.
  ///
  /// Сервер отдаёт номер в начале названия («ДС№210-УП "БЕЛТЕХОСМОТР"»),
  /// поэтому номер дублировался отдельной строкой над названием, а само
  /// название ещё и обрезалось многоточием. Здесь номер убирается из названия
  /// и возвращается в конец: «УП "БЕЛТЕХОСМОТР" ДС№210».
  String get displayTitle {
    final number = stationNumber?.trim() ?? '';
    final rawTitle = title?.trim() ?? '';
    if (number.isEmpty) {
      return rawTitle.isEmpty ? 'Диагностическая станция' : rawTitle;
    }
    // Ищем номер по цифрам: в названии он может быть написан без пробела
    // («ДС№210»), а приходить как «ДС №210».
    final digits = RegExp(r'\d+').firstMatch(number)?.group(0) ?? '';
    var name = rawTitle;
    if (digits.isNotEmpty) {
      name = name.replaceAll(
        RegExp(r'ДС\s*№?\s*' + RegExp.escape(digits), caseSensitive: false),
        ' ',
      );
    }
    // Убираем разделители, оставшиеся от номера по краям названия.
    name = name
        .replaceAll(RegExp(r'^[\s\-–—·|,]+'), '')
        .replaceAll(RegExp(r'[\s\-–—·|,]+$'), '')
        .trim();
    if (name.isEmpty) return rawTitle.isEmpty ? number : rawTitle;
    if (name.toLowerCase().contains(number.toLowerCase())) return name;
    return '$name $number';
  }

  final List<StationService>? services;
  final bool isOnlineRecord;
  final bool isBelto;
  final double? lat;
  final double? lon;
  final String? regionId;

  factory DiagnosticStation.fromJson(Map<String, dynamic> json) {
    final rawServices = json['services'];
    final title = cleanApiTextOrNull(json['title'] ?? json['name']);
    final explicitNumber = cleanApiTextOrNull(
      json['stationNumber'] ??
          json['number'] ??
          json['code'] ??
          json['dsNumber'],
    );
    final stationNumber = explicitNumber == '0'
        ? _extractStationNumber(title)
        : explicitNumber ?? _extractStationNumber(title);
    final rawRegion = json['regionId'] ?? json['region'];
    final regionId = rawRegion is Map
        ? cleanApiTextOrNull(
            rawRegion['id'] ?? rawRegion['value'] ?? rawRegion['name'],
          )
        : cleanApiTextOrNull(rawRegion);
    return DiagnosticStation(
      id: parseApiInt(json['id']) ?? 0,
      title: title,
      stationNumber: stationNumber,
      address: cleanApiTextOrNull(json['address']),
      phone: _cleanApiValue(json['phone']),
      workTime: _cleanApiValue(json['workTime']),
      categories: (json['categories'] as List?)
          ?.map(cleanApiText)
          .where((value) => value.isNotEmpty)
          .toList(),
      services: rawServices is List
          ? rawServices
                .whereType<Map>()
                .map(
                  (value) =>
                      StationService.fromJson(Map<String, dynamic>.from(value)),
                )
                .where((service) => service.id != 0 || service.title.isNotEmpty)
                .toList()
          : null,
      isOnlineRecord: _asBool(json['isOnlineRecord']),
      isBelto: _asBool(json['isBelto']),
      lat: _parseCoordinate(
        json['lat'] ?? json['latitude'],
        json['coordinates'],
      ),
      lon: _parseCoordinate(
        json['lon'] ?? json['longitude'] ?? json['lng'],
        json['coordinates'],
        isLongitude: true,
      ),
      regionId: regionId,
    );
  }
}

class StationService {
  StationService({required this.id, required this.title, this.price});

  final int id;
  final String title;
  final String? price;

  factory StationService.fromJson(Map<String, dynamic> json) {
    return StationService(
      id: parseApiInt(json['id']) ?? 0,
      title: cleanApiText(json['title'] ?? json['value'] ?? json['name']),
      price: cleanApiTextOrNull(json['price']),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StationService &&
          other.id == id &&
          other.title == title &&
          other.price == price;

  @override
  int get hashCode => Object.hash(id, title, price);
}

class RegistrationRecord {
  const RegistrationRecord({
    this.elementId,
    this.stationName,
    this.serviceName,
    this.dateTime,
    this.regNumber,
    this.vehicleName,
    this.status,
    this.isOld,
  });

  final int? elementId;
  final String? stationName;
  final String? serviceName;
  final String? dateTime;
  final String? regNumber;
  final String? vehicleName;
  final String? status;
  final bool? isOld;

  bool get hasKnownSchedule =>
      isOld != null || _parseRecordDate(dateTime) != null;

  bool get isPast {
    final normalizedStatus = status?.trim().toLowerCase();
    if (const {
      'past',
      'completed',
      'complete',
      'done',
      'finished',
      'прошедшая',
      'завершена',
      'выполнена',
    }.contains(normalizedStatus)) {
      return true;
    }
    if (const {
      'upcoming',
      'future',
      'planned',
      'предстоящая',
    }.contains(normalizedStatus)) {
      return false;
    }
    if (isOld != null) return isOld!;
    if (const {
      'upcoming',
      'future',
      'planned',
      'предстоящая',
    }.contains(normalizedStatus)) {
      return false;
    }
    final parsed = _parseRecordDate(dateTime);
    if (parsed == null) return false;
    final now = DateTime.now();
    return parsed.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get canCancel {
    if (elementId == null) return false;
    final normalizedStatus = status?.trim().toLowerCase();
    return !isPast &&
        !const {
          'cancelled',
          'canceled',
          'отменена',
          'completed',
          'выполнена',
        }.contains(normalizedStatus);
  }

  factory RegistrationRecord.fromJson(Map<String, dynamic> json) {
    final date = _recordText(
      json['date'] ?? json['dateTime'] ?? json['visitDate'],
    );
    final time = _recordText(
      json['time'] ?? json['timeSlot'] ?? json['visitTime'],
    );
    return RegistrationRecord(
      elementId: parseApiInt(
        json['elementId'] ?? json['id'] ?? json['recordId'],
      ),
      stationName: _recordText(
        json['stationName'] ?? json['station'] ?? json['stationTitle'],
      ),
      serviceName: _recordText(
        json['serviceName'] ?? json['service'] ?? json['serviceTitle'],
      ),
      dateTime: [date, time].where((value) => value.isNotEmpty).join(' '),
      regNumber: _recordText(json['regNumber'] ?? json['registrationNumber']),
      vehicleName: _recordText(
        json['vehicleName'] ?? json['vechicleName'] ?? json['carName'],
      ),
      status: _recordText(json['status'] ?? json['state']),
      isOld: _optionalBool(json['isOld'] ?? json['old']),
    );
  }
}

DateTime? _parseRecordDate(String? value) {
  if (value == null || value.isEmpty) return null;
  final match = RegExp(
    r'(\d{1,2})[./-](\d{1,2})[./-](\d{2,4})(?:[ T](\d{1,2}):(\d{2}))?',
  ).firstMatch(value);
  if (match == null) return DateTime.tryParse(value);
  final year = int.parse(match.group(3)!);
  final normalizedYear = year < 100 ? 2000 + year : year;
  return DateTime(
    normalizedYear,
    int.parse(match.group(2)!),
    int.parse(match.group(1)!),
    int.tryParse(match.group(4) ?? '') ?? 0,
    int.tryParse(match.group(5) ?? '') ?? 0,
  );
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

String _recordText(Object? value) {
  if (value is Map) {
    return cleanApiText(
      value['title'] ??
          value['name'] ??
          value['value'] ??
          value['date'] ??
          value['text'],
    );
  }
  return cleanApiText(value);
}

class StationSlot {
  StationSlot({required this.timeSlot, this.dayId, this.serviceId});

  final String timeSlot;
  final int? dayId;
  final int? serviceId;

  factory StationSlot.fromJson(Map<String, dynamic> json) {
    return StationSlot(
      timeSlot: cleanApiText(json['timeSlot'] ?? json['time'] ?? json['value']),
      dayId: parseApiInt(json['dayId']),
      serviceId: parseApiInt(json['serviceId']),
    );
  }
}

class StationDaySlots {
  StationDaySlots({this.serviceId, this.dayId, required this.slots});

  final int? serviceId;
  final int? dayId;
  final List<StationSlot> slots;

  factory StationDaySlots.fromJson(Map<String, dynamic> json) {
    final rawSlots = json['slots'];
    final serviceId = parseApiInt(json['serviceId']);
    final dayId = parseApiInt(json['dayId']);
    final slots = rawSlots is List
        ? rawSlots
              .map((value) {
                if (value is Map) {
                  final slot = StationSlot.fromJson(
                    Map<String, dynamic>.from(value),
                  );
                  return StationSlot(
                    timeSlot: slot.timeSlot,
                    dayId: slot.dayId ?? dayId,
                    serviceId: slot.serviceId ?? serviceId,
                  );
                }
                return StationSlot(
                  timeSlot: cleanApiText(value),
                  dayId: dayId,
                  serviceId: serviceId,
                );
              })
              .where((slot) => slot.timeSlot.isNotEmpty)
              .toList()
        : <StationSlot>[];

    return StationDaySlots(serviceId: serviceId, dayId: dayId, slots: slots);
  }
}

class StationFilter {
  const StationFilter({
    required this.key,
    required this.title,
    required this.values,
    this.localOnly = false,
  });

  final String key;
  final String title;
  final List<StationFilterValue> values;
  final bool localOnly;

  factory StationFilter.fromJson(Map<String, dynamic> json) {
    final rawValues = json['values'] ?? json['list'];
    return StationFilter(
      key: json['key']?.toString() ?? json['id']?.toString() ?? '',
      title: cleanApiText(json['title']),
      values: rawValues is List
          ? rawValues
                .whereType<Map>()
                .map(
                  (value) => StationFilterValue.fromJson(
                    Map<String, dynamic>.from(value),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

class StationFilterValue {
  const StationFilterValue({required this.id, required this.title});

  final String id;
  final String title;

  factory StationFilterValue.fromJson(Map<String, dynamic> json) {
    return StationFilterValue(
      id: json['id']?.toString() ?? '',
      title: cleanApiText(json['title'] ?? json['value'] ?? json['name']),
    );
  }
}

class StationCalendarDay {
  StationCalendarDay({required this.dayNumber, required this.availableSlots});

  final int dayNumber;
  final int availableSlots;

  factory StationCalendarDay.fromJson(Map<String, dynamic> json) {
    return StationCalendarDay(
      dayNumber: parseApiInt(json['dayNumber']) ?? 0,
      availableSlots: parseApiInt(json['availableSlots']) ?? 0,
    );
  }
}

class StationCalendar {
  StationCalendar({
    required this.year,
    required this.month,
    required this.days,
  });

  final int year;
  final int month;
  final List<StationCalendarDay> days;

  factory StationCalendar.fromJson(Map<String, dynamic> json) {
    return StationCalendar(
      year: parseApiInt(json['year']) ?? 0,
      month: parseApiInt(json['month']) ?? 0,
      days: (json['days'] as List? ?? [])
          .whereType<Map>()
          .map(
            (value) =>
                StationCalendarDay.fromJson(Map<String, dynamic>.from(value)),
          )
          .toList(),
    );
  }
}

String? _extractStationNumber(String? title) {
  if (title == null || title.isEmpty) return null;
  final withNumber = RegExp(
    r'№\s*([A-Za-zА-Яа-я0-9][A-Za-zА-Яа-я0-9./-]*)',
  ).firstMatch(title);
  if (withNumber != null) return 'ДС №${withNumber.group(1)}';
  final dsNumber = RegExp(
    r'\bДС\s+([0-9]+)',
    caseSensitive: false,
  ).firstMatch(title);
  if (dsNumber != null) return 'ДС №${dsNumber.group(1)}';
  return null;
}

String? _cleanApiValue(Object? value) {
  if (value is List) {
    final text = value
        .map(cleanApiText)
        .where((item) => item.isNotEmpty)
        .join(', ');
    return text.isEmpty ? null : text;
  }
  return cleanApiTextOrNull(value);
}

double? _parseCoordinate(
  Object? value,
  Object? coordinates, {
  bool isLongitude = false,
}) {
  if (value != null) return double.tryParse(value.toString());
  if (coordinates is List && coordinates.length >= 2) {
    return double.tryParse(coordinates[isLongitude ? 0 : 1].toString());
  }
  return null;
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value?.toString().toLowerCase() == 'true' || value?.toString() == '1';
}
