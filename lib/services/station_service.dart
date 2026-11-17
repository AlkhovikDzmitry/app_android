import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../core/utils/text_utils.dart';
import '../models/station.dart';

class StationApi {
  StationApi._();

  static final StationApi instance = StationApi._();

  Future<List<DiagnosticStation>> getStations({
    String query = '',
    Map<String, Set<String>> filters = const {},
  }) async {
    try {
      final queryParameters = <String, dynamic>{'allNews': 'true'};
      final normalizedQuery = query.trim();
      if (normalizedQuery.isNotEmpty) {
        queryParameters['query'] = normalizedQuery;
      }
      for (final entry in filters.entries) {
        if (entry.value.isEmpty) continue;
        switch (entry.key) {
          case 'belto':
          case 'onlineRecord':
            queryParameters[entry.key] = entry.value.join(',');
            break;
          case 'region':
            if (entry.value.length == 1) {
              queryParameters['regionId'] = entry.value.first;
            }
            break;
          case 'service':
          case 'category':
            break;
          default:
            queryParameters[entry.key] = entry.value.join(',');
        }
      }
      final regionIds = filters['region'] ?? const <String>{};
      if (regionIds.length > 1) {
        final stations = <DiagnosticStation>[];
        final seenIds = <int>{};
        var successfulRequests = 0;
        for (final regionId in regionIds) {
          try {
            final response = await ApiClient.instance.dio.get(
              ApiEndpoints.stationsList,
              queryParameters: {...queryParameters, 'regionId': regionId},
            );
            successfulRequests++;
            for (final station in _parseStations(response.data)) {
              if (seenIds.add(station.id)) stations.add(station);
            }
          } on DioException {
            continue;
          }
        }
        if (successfulRequests == 0) {
          throw ApiException(
            'Не удалось загрузить станции для выбранных регионов',
          );
        }
        return stations;
      }
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.stationsList,
        queryParameters: queryParameters,
      );
      return _parseStations(response.data);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<StationFilter>> getFilters() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.stationsFilters,
      );
      final data = response.data;
      final raw = data is Map<String, dynamic> ? data['data'] : data;
      if (raw is! List) return const [];

      final groups = raw.expand((group) {
        if (group is List) return group;
        return [group];
      }).whereType<Map>();
      final filters = <StationFilter>[];
      final seenTitles = <String>{};
      final seenKeys = <String>{};
      for (final rawGroup in groups) {
        final group = Map<String, dynamic>.from(rawGroup);
        final type = group['type']?.toString();
        final title = cleanApiText(group['title']);
        final normalizedTitle = _normalizeFilterTitle(title);
        final isRegion =
            normalizedTitle == 'регион' ||
            normalizedTitle == 'регионы' ||
            normalizedTitle.startsWith('регион ');
        if (title.isEmpty || !seenTitles.add(normalizedTitle)) continue;
        final id = group['id']?.toString() ?? '';
        final key = isRegion
            ? 'region'
            : type == 'list'
            ? _filterKey(title, id)
            : id.isNotEmpty
            ? id
            : _filterKey(title, '');
        if (!seenKeys.add(key)) continue;
        if (type == 'list') {
          final values = group['list'];
          if (values is! List) continue;
          filters.add(
            StationFilter(
              key: key,
              title: title,
              values: values
                  .whereType<Map>()
                  .map(
                    (value) => StationFilterValue.fromJson(
                      Map<String, dynamic>.from(value),
                    ),
                  )
                  .where((value) => value.id.isNotEmpty)
                  .toList(),
            ),
          );
        } else {
          filters.add(
            StationFilter(
              key: key,
              title: title,
              values: [
                StationFilterValue(
                  id: group['value']?.toString() ?? '1',
                  title: title,
                ),
              ],
            ),
          );
        }
      }
      return filters;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<StationService>> getStationServices(int stationId) async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.stationServices,
        queryParameters: {'stationId': stationId},
      );
      return _parseServices(response.data);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<StationDaySlots>> getSlots(int stationId, String date) async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.stationSlots,
        queryParameters: {'stationId': stationId, 'date': date},
      );
      final data = response.data;
      final raw = data is Map<String, dynamic> ? data['data'] : data;
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map(
              (value) =>
                  StationDaySlots.fromJson(Map<String, dynamic>.from(value)),
            )
            .toList();
      }
      if (raw is Map) {
        return [StationDaySlots.fromJson(Map<String, dynamic>.from(raw))];
      }
      return const [];
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<StationCalendar?> getCalendar(int stationId, {int? ts}) async {
    try {
      final queryParameters = <String, dynamic>{'stationId': stationId};
      if (ts != null) queryParameters['ts'] = ts;
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.stationCalendar,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final raw = data['data'];
        if (raw is Map) {
          return StationCalendar.fromJson(Map<String, dynamic>.from(raw));
        }
        if (data['year'] != null && data['days'] is List) {
          return StationCalendar.fromJson(data);
        }
      }
      return null;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<Map<String, dynamic>> recordOnStation(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.stationRecord,
        data: data,
      );
      final value = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : null;
      _throwIfFailed(value);
      if (!_hasPositiveActionResult(value)) {
        throw ApiException('Сервер не подтвердил создание записи');
      }
      return value!;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<RegistrationRecord>> getRegistrationHistory({bool? isOld}) async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.stationHistory,
        queryParameters: isOld == null ? null : {'isOld': isOld ? 1 : 0},
      );
      final data = response.data;
      if (data is Map) _throwIfFailed(Map<String, dynamic>.from(data));
      final list = _findList(data);
      if (list == null) return const [];
      final records = <RegistrationRecord>[];
      for (final value in list.whereType<Map>()) {
        final map = Map<String, dynamic>.from(value);
        final nested = map['posts'] ?? map['records'] ?? map['items'];
        final groupIsOld = map['isOld'] ?? map['old'];
        final groupDate = map['date'] ?? map['dateTime'] ?? map['visitDate'];
        final groupStatus = map['status'] ?? map['state'];
        if (nested is List) {
          records.addAll(
            nested.whereType<Map>().map((item) {
              final record = Map<String, dynamic>.from(item);
              if (groupIsOld != null) {
                record.putIfAbsent('isOld', () => groupIsOld);
              }
              if (groupDate != null) {
                record.putIfAbsent('date', () => groupDate);
              }
              if (groupStatus != null) {
                record.putIfAbsent('status', () => groupStatus);
              }
              return RegistrationRecord.fromJson(record);
            }),
          );
        } else {
          records.add(RegistrationRecord.fromJson(map));
        }
      }
      if (isOld == null) return records;
      final known = records.where((record) => record.hasKnownSchedule).toList();
      if (known.isEmpty) return records;
      final filtered = known.where((record) => record.isPast == isOld).toList();
      final unknown = records.where((record) => !record.hasKnownSchedule);
      return [...filtered, if (!isOld) ...unknown];
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> cancelRecord(int elementId) async {
    try {
      final response = await ApiClient.instance.dio.delete(
        ApiEndpoints.stationCancel,
        queryParameters: {'elementId': elementId},
      );
      final value = response.data is Map
          ? Map<String, dynamic>.from(response.data as Map)
          : null;
      _throwIfFailed(value);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  List<dynamic>? _findList(Object? value) {
    if (value is List) return value;
    if (value is Map) {
      for (final key in const ['data', 'posts', 'records', 'items', 'list']) {
        final nested = _findList(value[key]);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  List<DiagnosticStation> _parseStations(Object? data) {
    final raw = data is Map<String, dynamic> ? data['data'] : data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (value) =>
              DiagnosticStation.fromJson(Map<String, dynamic>.from(value)),
        )
        .where((station) => station.id != 0)
        .toList();
  }

  List<StationService> _parseServices(Object? data) {
    final raw = data is Map<String, dynamic> ? data['data'] : data;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map(
          (value) => StationService.fromJson(Map<String, dynamic>.from(value)),
        )
        .where((service) => service.id != 0 || service.title.isNotEmpty)
        .toList();
  }

  String _normalizeFilterTitle(String title) {
    return title
        .toLowerCase()
        .replaceAll(RegExp(r'[«»"“”]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _filterKey(String title, String fallback) {
    final normalized = title.toLowerCase();
    if (normalized.contains('категор')) return 'category';
    if (normalized.contains('услуг')) return 'service';
    return fallback.isNotEmpty ? fallback : normalized;
  }

  bool _hasPositiveActionResult(Map<String, dynamic>? value) {
    if (value == null || value.isEmpty) return false;
    final data = value['data'];
    if (data is Map && data.isNotEmpty) return true;
    if (data is List && data.isNotEmpty) return true;
    if (data == true) return true;
    final success = value['success']?.toString().toLowerCase();
    if (success == 'true' || success == '1') return true;
    final status = value['status']?.toString().toLowerCase();
    if (const {'0', '1', '200', '201', 'success', 'ok'}.contains(status)) {
      return true;
    }
    return const {
      'id',
      'elementId',
      'recordId',
      'stationId',
      'serviceId',
      'date',
      'time',
    }.any(value.containsKey);
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
    throw ApiException(message?.toString() ?? 'Не удалось создать запись');
  }

  ApiException _extractError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException('Произошла ошибка');
  }
}

/// Услуги станции, которые видит пользователь.
///
/// Сервер отдаёт общий список услуг станции без разбора по типу пользователя,
/// поэтому физлицам не показываются услуги, доступные только юридическим лицам
/// (например, проверка по нормам ЕКМТ).
List<StationService> filterStationServices(
  List<StationService> services, {
  required bool isLegal,
}) {
  if (isLegal) return services;
  return services
      .where((service) => !_isLegalOnlyStationService(service))
      .toList();
}

bool _isLegalOnlyStationService(StationService service) {
  final title = service.title.toLowerCase();
  return title.contains('екмт');
}
