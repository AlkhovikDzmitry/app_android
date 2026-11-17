import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/payment.dart';

/// Счётчик изменений истории заказов.
///
/// Экран истории находится во вкладке и не пересоздаётся при переключении
/// вкладок, поэтому после оплаты новый заказ в нём не появлялся до перезапуска
/// приложения. Оформление заказа отмечает историю как изменившуюся, и экран
/// перечитывает её — как это делает исходное приложение, обновляя историю при
/// каждом открытии.
final ValueNotifier<int> historyRevision = ValueNotifier<int>(0);

/// Пометить историю заказов как изменившуюся.
void markHistoryChanged() => historyRevision.value++;

class PaymentApi {
  PaymentApi._();

  static final PaymentApi instance = PaymentApi._();

  Future<List<PaymentService>> getServices() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.paymentServices,
      );
      return _list(response.data)
          .map(PaymentService.fromJson)
          .where((service) => service.id != 0 || service.title.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<PaymentHistoryGroup>> getHistory() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.paymentHistory,
      );
      final data = response.data;
      if (data is Map) _throwIfFailed(Map<String, dynamic>.from(data));
      final list = _findList(data);
      if (list == null) return const [];
      final maps = list
          .whereType<Map>()
          .map((value) => Map<String, dynamic>.from(value))
          .toList();
      if (maps.isEmpty) return const [];
      if (maps.any((item) => item['posts'] is List)) {
        return maps.map(PaymentHistoryGroup.fromJson).toList();
      }
      final groups = <String, List<PaymentHistoryItem>>{};
      for (final item in maps) {
        final historyItem = PaymentHistoryItem.fromJson(item);
        final month = _historyMonth(historyItem.visitDate);
        groups.putIfAbsent(month, () => []).add(historyItem);
      }
      return groups.entries
          .map(
            (entry) =>
                PaymentHistoryGroup(monthName: entry.key, posts: entry.value),
          )
          .toList();
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  String _historyMonth(String? value) {
    if (value == null || value.isEmpty) return 'Без даты';
    final formats = [
      'dd.MM.yyyy',
      'dd.MM.yy',
      'yyyy-MM-dd',
      'yyyy-MM-dd HH:mm:ss',
    ];
    for (final format in formats) {
      try {
        final parsed = DateFormat(format).parse(value);
        return DateFormat('MMMM yyyy', 'ru_RU').format(parsed);
      } catch (_) {}
    }
    final iso = DateTime.tryParse(value);
    if (iso != null) return DateFormat('MMMM yyyy', 'ru_RU').format(iso);
    return value;
  }

  /// Места оказания услуг.
  ///
  /// Некоторые услуги (например, разрешение на допуск к участию в дорожном
  /// движении) не привязаны к конкретным организациям, и фильтр по услуге
  /// возвращает пустой список. Для таких услуг [forAllServices] повторяет
  /// запрос без `serviceId`, чтобы список всё же оказался непустым.
  Future<List<PaymentStation>> getStations(
    int serviceId, {
    bool forAllServices = false,
  }) async {
    try {
      final response = forAllServices
          ? await ApiClient.instance.dio.get(ApiEndpoints.paymentStations)
          : await ApiClient.instance.dio.get(
              ApiEndpoints.paymentStations,
              queryParameters: {'serviceId': serviceId},
            );
      return _list(response.data)
          .map(PaymentStation.fromJson)
          .where((station) => station.id != 0 || station.title.isNotEmpty)
          .toList();
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<PaymentMethod>> getPaymentMethodsIndividual() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.paymentMethodsIndividual,
      );
      return _list(response.data).map(PaymentMethod.fromJson).toList();
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<PaymentMethod>> getPaymentMethodsJuristic(int serviceId) async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.paymentMethodsJuristic,
        queryParameters: {'serviceId': serviceId},
      );
      return _list(response.data).map(PaymentMethod.fromJson).toList();
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<Map<String, dynamic>?> getPrice(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.paymentPrice,
        data: data,
      );
      final value = _map(response.data);
      _throwIfFailed(value);
      return value;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<Map<String, dynamic>?> getPriceJuristic(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.paymentPriceJuristic,
        data: data,
      );
      final value = _map(response.data);
      _throwIfFailed(value);
      return value;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<VehicleType>> getVehicleTypes({
    required int serviceId,
    required int stationId,
  }) async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.paymentVehicleTypes,
        queryParameters: {'serviceId': serviceId, 'stationId': stationId},
      );
      return _parseVehicleTypes(response.data);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<VehicleType>> getVehicleTypesJuristic({
    required int serviceId,
    required int stationId,
  }) async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.paymentVehicleTypesJuristic,
        queryParameters: {'serviceId': serviceId, 'stationId': stationId},
      );
      return _parseVehicleTypes(response.data);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<DropdownValue>> getCertainTypesWork() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.paymentCertainTypesWork,
      );
      return _list(response.data).map(DropdownValue.fromJson).toList();
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<OrderInfo?> getOrderInfoIndividual(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.paymentOrderIndividual,
        data: data,
      );
      final value = _orderValue(response.data);
      _throwIfFailed(value);
      return value == null ? null : OrderInfo.fromJson(value);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<OrderInfo?> getOrderInfoJuristic(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.paymentOrderJuristic,
        data: data,
      );
      final value = _orderValue(response.data);
      _throwIfFailed(value);
      return value == null ? null : OrderInfo.fromJson(value);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<DocumentTemplate>> getDocsTemplates(int serviceId) async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.paymentDocsTemplates,
        queryParameters: {'id': serviceId},
      );
      return _list(response.data).map(DocumentTemplate.fromJson).toList();
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  List<DocumentTemplate>? _documentTemplates;

  /// Шаблоны документов для скачивания.
  ///
  /// Список общий для всех услуг: сервер игнорирует `serviceId` и отдаёт одни и
  /// те же тринадцать шаблонов, поэтому запрашивается один раз и кешируется.
  Future<List<DocumentTemplate>> getDocumentTemplates() async {
    final cached = _documentTemplates;
    if (cached != null) return cached;
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.paymentDocsTemplates,
      );
      final templates = _list(
        response.data,
      ).map(DocumentTemplate.fromJson).toList();
      _documentTemplates = templates;
      return templates;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  /// Ссылка на скачивание документа заказа.
  ///
  /// Документы истории приходят ссылкой `.../doc_new/<группа>.<номер>.pdf`, но
  /// по ней сервер отвечает 404. Скачивание работает только через
  /// `get_report.php` с номером заказа и идентификатором шаблона, поэтому адрес
  /// собирается заново. Если номер или шаблон найти не удалось, возвращается
  /// исходная ссылка — лучше открыть её, чем не открыть ничего.
  Future<Uri?> documentDownloadUri({
    String? href,
    String? title,
    int? templateId,
    String? orderId,
  }) async {
    final resolvedOrderId =
        orderIdFromDocumentHref(href) ?? int.tryParse((orderId ?? '').trim());
    var template = templateId;
    try {
      final matched = matchDocumentTemplate(
        title,
        await getDocumentTemplates(),
      );
      if (matched?.id != null) template = matched!.id;
    } catch (_) {}
    if (resolvedOrderId != null && template != null) {
      return Uri.parse(
        '${ApiEndpoints.reportBaseUrl}${ApiEndpoints.report}'
        '?ID=$resolvedOrderId&templateID=$template',
      );
    }
    return _resolveDocumentHref(href);
  }

  Uri? _resolveDocumentHref(String? href) {
    final raw = href?.trim();
    if (raw == null || raw.isEmpty) return null;
    var uri = Uri.tryParse(raw);
    if (uri != null && !uri.hasScheme) {
      uri = Uri.parse(ApiEndpoints.reportBaseUrl).resolveUri(uri);
    }
    return uri != null && uri.hasScheme ? uri : null;
  }

  Future<Response<dynamic>> webPayMethod(
    String action,
    Map<String, dynamic> data,
  ) async {
    var uri = Uri.tryParse(action);
    if (uri == null) {
      throw ApiException('Некорректный адрес платёжной системы');
    }
    if (!uri.hasScheme) {
      final base = Uri.parse(ApiEndpoints.baseUrl);
      uri = base.resolve(action);
    }
    if (!uri.hasScheme) {
      throw ApiException('Некорректный адрес платёжной системы');
    }
    if (!uri.path.trim().endsWith('/api/v1/payment')) {
      final path = uri.path.trim();
      final apiPath = path.endsWith('/')
          ? '${path}api/v1/payment'
          : '$path/api/v1/payment';
      uri = uri.replace(path: apiPath);
    }
    try {
      return await ApiClient.instance.externalDio.post(
        uri.toString(),
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          followRedirects: false,
          validateStatus: (status) => status != null && status < 400,
        ),
      );
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  void _throwIfFailed(Map<String, dynamic>? value) {
    if (value == null) return;
    final nested = value['data'];
    if (nested is Map) {
      _throwIfFailed(Map<String, dynamic>.from(nested));
    }
    final errors = value['errors'];
    final hasErrors = errors is List
        ? errors.isNotEmpty
        : errors is Map
        ? errors.isNotEmpty
        : errors != null &&
              errors.toString().trim().isNotEmpty &&
              errors.toString().trim().toLowerCase() != 'false';
    final status = value['status'];
    final statusCode = int.tryParse(status?.toString() ?? '');
    final rawError = value['error'];
    final errorValue = rawError?.toString().trim() ?? '';
    final failed =
        hasErrors ||
        value['success'] == false ||
        value['success']?.toString().toLowerCase() == 'false' ||
        status == false ||
        status?.toString().toLowerCase() == 'false' ||
        (statusCode != null && statusCode >= 400) ||
        (rawError != 0 &&
            errorValue.isNotEmpty &&
            errorValue.toLowerCase() != 'false' &&
            errorValue != '0');
    if (!failed) return;
    final message = value['message'] ?? value['title'] ?? value['error'];
    throw ApiException(
      message?.toString() ?? 'Платёжная операция завершилась ошибкой',
      errors: errors is List
          ? errors.map((item) => item.toString()).toList()
          : errors is Map
          ? errors.values.map((item) => item.toString()).toList()
          : null,
    );
  }

  Map<String, dynamic>? _orderValue(Object? response) {
    if (response is Map) return Map<String, dynamic>.from(response);
    if (response == null) return null;
    return {'data': response};
  }

  /// Разбирает выдачу типов транспортного средства.
  ///
  /// Сервер отдаёт её в трёх видах, и каждый нужно уметь прочитать:
  ///
  /// 1. список типов, у каждого свой список полей:
  ///    `[{"id": 1, "title": "Автобус", "fields": [...]}]`;
  /// 2. список описаний полей, где тип — поле `trans`, а его значения и есть
  ///    варианты выбора: `[{"name": "trans", "values": [...]}, ...]`;
  /// 3. объект с именами полей: `{"trans": [...], "massa": [...]}`.
  ///
  /// В последних двух случаях варианты берутся из значений поля `trans`: без
  /// них выбрать тип нечем, поэтому такая выдача считается пустой, а не
  /// превращается в один фиктивный пункт «Тип транспортного средства».
  /// Разбор выдачи типов ТС. Открыт для тестов: сетевой слой здесь не нужен.
  @visibleForTesting
  List<VehicleType> parseVehicleTypes(Object? response) =>
      _parseVehicleTypes(response);

  List<VehicleType> _parseVehicleTypes(Object? response) {
    final items = _list(response);
    List<VehicleType>? types;
    if (items.isNotEmpty) {
      if (items.any(
        (item) => item['fields'] is List || item['fieldList'] is List,
      )) {
        types = items
            .map(VehicleType.fromJson)
            .where((item) => item.id != 0 || item.title.isNotEmpty)
            .toList();
      } else {
        final fromList = _vehicleTypesFromFieldList(items);
        if (fromList.isNotEmpty) types = fromList;
      }
    }
    types ??= _vehicleTypesFromFieldMap(response);
    return _withServerVehicleCount(types, response);
  }

  /// Добавляет поле `COL_TS` туда, где его можно найти.
  ///
  /// Количество ТС — поле уровня услуги, а не типа: в выдаче «список типов» его
  /// лежит рядом со списком, и в поле типа оно не попадает. Из-за этого
  /// количество оставалось равным единице вместо минимума от сервера, а сервер
  /// на единицу цену не отдавал — стоимость появлялась только после ввода
  /// двух. Исходное приложение показывает это поле не редактируемым и всегда
  /// подставляет значение сервера.
  List<VehicleType> _withServerVehicleCount(
    List<VehicleType> types,
    Object? response,
  ) {
    if (types.isEmpty) return types;
    for (final type in types) {
      final fields = type.fields ?? const <VehicleTypeField>[];
      final hasCount = fields.any(
        (field) => field.name.toUpperCase() == 'COL_TS',
      );
      if (hasCount) return types;
    }
    final field = _vehicleCountField(response);
    if (field == null) return types;
    return types
        .map(
          (type) => VehicleType(
            id: type.id,
            title: type.title,
            fields: [...?type.fields, field],
          ),
        )
        .toList();
  }

  /// Поле `COL_TS` из любой части ответа.
  VehicleTypeField? _vehicleCountField(Object? response) {
    final min = _findVehicleCountMin(response);
    if (min == null) return null;
    return VehicleTypeField.fromJson(<String, dynamic>{
      'name': 'COL_TS',
      'min': min,
      'title': 'Количество ТС',
    });
  }

  /// Минимальное количество ТС, если сервер его прислал.
  int? _findVehicleCountMin(Object? node, {int depth = 0}) {
    if (depth > 4) return null;
    if (node is List) {
      for (final item in node) {
        final found = _findVehicleCountMin(item, depth: depth + 1);
        if (found != null) return found;
      }
      return null;
    }
    if (node is! Map) return null;
    final map = Map<String, dynamic>.from(node);
    for (final entry in map.entries) {
      if (entry.key.toUpperCase() == 'COL_TS') {
        final value = entry.value;
        final parsed = value is Map
            ? _findVehicleCountMin(value, depth: depth + 1)
            : int.tryParse(value?.toString() ?? '');
        if (parsed != null && parsed > 0) return parsed;
        // Внутри COL_TS может лежать отдельное поле с минимальным значением.
        final nested = value is Map
            ? _minFromFieldMap(value as Map<String, dynamic>)
            : null;
        if (nested != null) return nested;
      }
    }
    for (final value in map.values) {
      final found = _findVehicleCountMin(value, depth: depth + 1);
      if (found != null) return found;
    }
    return null;
  }

  /// Минимум из объекта вида `{"COL_TS": {"min": 2}}` или `{"COL_TS": {"values": [...]}}`.
  int? _minFromFieldMap(Map<String, dynamic> value) {
    final direct = int.tryParse(value['min']?.toString() ?? '');
    if (direct != null && direct > 0) return direct;
    for (final key in const ['min', 'MIN', 'value', 'amount']) {
      final parsed = int.tryParse(value[key]?.toString() ?? '');
      if (parsed != null && parsed > 0) return parsed;
    }
    return null;
  }

  /// Типы из выдачи вида «список описаний полей».
  List<VehicleType> _vehicleTypesFromFieldList(
    List<Map<String, dynamic>> items,
  ) {
    final fields = items
        .where((item) => item['name'] != null || item['field'] != null)
        .map(VehicleTypeField.fromJson)
        .toList();
    return _vehicleTypesFromFields(fields);
  }

  /// Типы из выдачи вида «объект с именами полей».
  List<VehicleType> _vehicleTypesFromFieldMap(Object? response) {
    Object? data = response;
    if (data is Map && data['data'] != null && data['data'] is Map) {
      data = data['data'];
    }
    if (data is! Map) return const [];
    final fields = <VehicleTypeField>[];
    data.forEach((key, value) {
      if (value is! List || value.isEmpty) return;
      fields.add(
        VehicleTypeField.fromJson(<String, dynamic>{
          'name': key,
          'values': value,
        }),
      );
    });
    if (fields.isEmpty) return const [];
    return _vehicleTypesFromFields(fields);
  }

  /// Варианты типа ТС берутся из значений поля `trans`.
  ///
  /// Остальные поля — параметры выбранного типа: у автобуса это масса, у
  /// грузового и прицепа — свои значения. Они приходят одним списком, поэтому
  /// каждому типу достаются только те поля, что к нему относятся: масса с
  /// подходящим `parentValue`, оси — всегда, двигатель и колёсная формула —
  /// у легкового. Без разбора `parentValue` массив массы попадал бы в каждый
  /// тип, а одинаковые поля дублировались и ломали форму.
  List<VehicleType> _vehicleTypesFromFields(List<VehicleTypeField> fields) {
    VehicleTypeField? transField;
    for (final field in fields) {
      final normalized = field.name.toLowerCase().replaceAll(
        RegExp(r'[^a-zа-яё0-9]'),
        '',
      );
      if (normalized == 'trans' || normalized == 'vehicle') {
        transField = field;
        break;
      }
    }
    final transName = transField?.name.toLowerCase();
    final otherFields = fields
        .where(
          (field) => transName == null || field.name.toLowerCase() != transName,
        )
        .toList();
    final options = transField?.values ?? const <DropdownValue>[];
    if (options.isEmpty) return const [];
    return options
        .map(
          (option) => VehicleType(
            id: option.id,
            title: option.title,
            fields: otherFields
                .where((field) => _fieldBelongsToType(field, option))
                .toList(),
          ),
        )
        .toList();
  }

  /// Относится ли поле к выбранному типу ТС.
  ///
  /// Поле с `parentValue` показывается только для совпавшего типа. Глобальные
  /// поля (`parentValue` пуст) распределяются как в исходном приложении: оси
  /// (`TRANS_OS`) есть у любого типа, а двигатель и колёсная формула
  /// (`TRANS_MOTOR`, `TRANS_KOL`) — только у легкового автомобиля.
  bool _fieldBelongsToType(VehicleTypeField field, DropdownValue type) {
    final parent = field.parentValue;
    if (parent != null && parent.toString().trim().isNotEmpty) {
      final parsed = int.tryParse(parent.toString());
      if (parsed != null) return parsed == type.id;
      return parent.toString() == type.rawId;
    }
    final name = field.name.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (name.contains('TRANSOS')) return true;
    if (name.contains('MOTOR') || name.contains('KOL')) {
      return type.title.toLowerCase().contains('легков');
    }
    return false;
  }

  List<dynamic>? _findList(Object? value) {
    if (value is List) return value;
    if (value is Map) {
      for (final key in const [
        'data',
        'posts',
        'records',
        'items',
        'list',
        'result',
        'response',
        'stations',
        'rows',
      ]) {
        final nested = _findList(value[key]);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _list(Object? response) {
    final data = _findList(response);
    if (data == null) return const [];
    return data
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
  }

  Map<String, dynamic>? _map(Object? response) {
    if (response is Map) return Map<String, dynamic>.from(response);
    return null;
  }

  ApiException _extractError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    final response = e.response;
    final data = response?.data;
    if (data is Map) {
      final error = ApiError.fromJson(Map<String, dynamic>.from(data));
      return ApiException(
        error.message ??
            error.title ??
            error.details ??
            (error.errors?.join('\n') ??
                'Платёжная операция завершилась ошибкой'),
        statusCode: response?.statusCode,
        errors: error.errors,
        code: error.code,
        details: error.details,
      );
    }
    return ApiException(
      response?.statusCode == null
          ? 'Платёжная операция завершилась ошибкой'
          : 'Платёжная операция завершилась ошибкой (${response!.statusCode})',
      statusCode: response?.statusCode,
    );
  }
}
