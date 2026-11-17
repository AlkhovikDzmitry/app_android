import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';
import 'cookie_jar_provider.dart';

class ApiClient {
  ApiClient._internal();

  static final ApiClient instance = ApiClient._internal();

  late final Dio dio;
  late final Dio externalDio;
  CookieJar? _cookieJar;
  Future<void>? _initFuture;

  Future<void> ensureInitialized() {
    return _initFuture ??= _init();
  }

  Future<void> _init() async {
    _cookieJar = await createCookieJar();

    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    dio.interceptors.add(CookieManager(_cookieJar!));
    dio.interceptors.add(_ErrorInterceptor());

    externalDio = Dio(
      BaseOptions(
        headers: {'Content-Type': 'application/json'},
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
    externalDio.interceptors.add(CookieManager(_cookieJar!));
    externalDio.interceptors.add(_ErrorInterceptor());
  }

  Future<void> clearCookies() async {
    await ensureInitialized();
    await _cookieJar?.deleteAll();
  }

  Future<void> addCookie(String name, String value) async {
    await ensureInitialized();
    final uri = Uri.parse(ApiEndpoints.baseUrl);
    await _cookieJar?.saveFromResponse(uri, [Cookie(name, value)]);
  }

  Future<void> restoreCookies(String? rawCookies) async {
    if (rawCookies == null || rawCookies.trim().isEmpty) return;
    await ensureInitialized();
    final cookies = <Cookie>[];
    for (final part in rawCookies.split(';')) {
      final value = part.trim();
      final separator = value.indexOf('=');
      if (separator <= 0) continue;
      final name = value.substring(0, separator).trim();
      final cookieValue = value.substring(separator + 1).trim();
      if (name.isEmpty || cookieValue.isEmpty) continue;
      if (const {
        'path',
        'domain',
        'expires',
        'max-age',
        'httponly',
        'secure',
        'samesite',
      }.contains(name.toLowerCase())) {
        continue;
      }
      cookies.add(Cookie(name, cookieValue));
    }
    if (cookies.isEmpty) return;
    await _cookieJar?.saveFromResponse(
      Uri.parse(ApiEndpoints.baseUrl),
      cookies,
    );
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    final data = response.data;
    if (data is Map) {
      final apiError = ApiError.fromJson(Map<String, dynamic>.from(data));
      final status = data['status'];
      final statusCode = int.tryParse(status?.toString() ?? '');
      final rawError = data['error'];
      final errorValue = rawError?.toString().trim() ?? '';
      final hasError =
          (apiError.errors != null && apiError.errors!.isNotEmpty) ||
          data['success'] == false ||
          data['success']?.toString().toLowerCase() == 'false' ||
          status == false ||
          status?.toString().toLowerCase() == 'false' ||
          (statusCode != null && statusCode >= 400) ||
          (rawError != 0 &&
              errorValue.isNotEmpty &&
              errorValue.toLowerCase() != 'false' &&
              errorValue != '0');
      if (hasError) {
        final message =
            apiError.message ??
            apiError.title ??
            apiError.details ??
            (apiError.errors?.join('\n') ?? 'Произошла ошибка');
        handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            response: response,
            error: ApiException(
              message,
              statusCode: response.statusCode,
              errors: apiError.errors,
              code: apiError.code,
              details: apiError.details,
            ),
          ),
        );
        return;
      }
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      handler.next(
        DioException(
          requestOptions: err.requestOptions,
          error: ApiException('Нет соединения с сервером. Проверьте интернет.'),
        ),
      );
      return;
    }

    final response = err.response;
    if (response != null) {
      final data = response.data;
      if (data is Map) {
        final apiError = ApiError.fromJson(Map<String, dynamic>.from(data));
        final message =
            apiError.message ??
            apiError.title ??
            apiError.details ??
            (apiError.errors != null && apiError.errors!.isNotEmpty
                ? apiError.errors!.join('\n')
                : 'Произошла ошибка');
        handler.next(
          DioException(
            requestOptions: err.requestOptions,
            response: response,
            error: ApiException(
              message,
              statusCode: response.statusCode,
              errors: apiError.errors,
              code: apiError.code,
              details: apiError.details,
            ),
          ),
        );
        return;
      }
    }

    handler.next(err);
  }
}
