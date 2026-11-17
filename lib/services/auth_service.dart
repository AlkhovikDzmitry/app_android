import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../core/storage/app_storage.dart';
import '../models/user.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  Future<void> login({
    required String login,
    required String password,
    bool rememberMe = false,
    bool singleSession = false,
  }) async {
    final normalizedLogin = login.trim();
    if (normalizedLogin.isEmpty || password.isEmpty) {
      throw ApiException('Введите логин и пароль');
    }
    try {
      final userToken = await AppStorage.getUserToken();
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.login,
        data: {
          'login': normalizedLogin,
          'password': password,
          'userToken': userToken,
        },
      );

      final authCookie = response.headers.value('x-gto-auth-cookie');
      final setCookies = response.headers['set-cookie'];
      String? sessionId;
      if (authCookie != null && authCookie.isNotEmpty) {
        final firstCookie = authCookie.split(';').first.trim();
        final separator = firstCookie.indexOf('=');
        sessionId = separator >= 0
            ? firstCookie.substring(separator + 1).trim()
            : firstCookie;
      }
      final cookies = <String>[
        if (setCookies != null) ...setCookies,
        if (sessionId != null && sessionId.isNotEmpty) 'PHPSESSID=$sessionId',
      ];
      if (cookies.isEmpty) {
        throw ApiException('Сервер не создал сессию пользователя');
      }
      if (sessionId != null && sessionId.isNotEmpty) {
        await ApiClient.instance.addCookie('PHPSESSID', sessionId);
      }
      final profile = await getUserProfile();
      if (profile == null) {
        throw ApiException('Такого пользователя не найдено');
      }
      await AppStorage.setIsLegal(profile.isLegal);
      await AppStorage.setSingleSession(singleSession);
      await AppStorage.setLoginData(
        login: normalizedLogin,
        password: password,
        rememberMe: rememberMe,
        isLegal: profile.isLegal,
        cookies: cookies.join('; '),
      );
    } on DioException catch (error) {
      throw _extractLoginError(error);
    } on ApiException catch (error) {
      final text = error.message.toLowerCase();
      if (text.contains('не найден') || text.contains('not found')) {
        throw ApiException('Такого пользователя не найдено');
      }
      if (text.contains('неверный логин') ||
          text.contains('неверный пароль') ||
          text.contains('неверно указан') ||
          text.contains('wrong password') ||
          text.contains('invalid password') ||
          text.contains('wrong login') ||
          text.contains('incorrect login') ||
          text.contains('bad credentials')) {
        throw ApiException('Неверный логин или пароль');
      }
      rethrow;
    }
  }

  Future<Response<dynamic>> register(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.register,
        data: data,
      );
      _throwIfRegistrationFailed(response);
      return response;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> logout() async {
    // Локальные данные очищаем первыми: выход по таймауту не должен зависеть
    // от доступности сервера, иначе сессия останется на устройстве.
    await AppStorage.clearLoginData();
    await ApiClient.instance.clearCookies();
    try {
      await ApiClient.instance.dio
          .post(ApiEndpoints.logout)
          .timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  Future<void> resetPassword(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.resetPassword,
        data: data,
      );
      _throwIfPasswordResetFailed(response);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> changePassword(Map<String, dynamic> data) async {
    try {
      await ApiClient.instance.dio.post(
        ApiEndpoints.changePassword,
        data: data,
      );
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.userProfile,
      );
      final data = response.data;
      if (data is Map) {
        final profile = UserProfile.fromJson(Map<String, dynamic>.from(data));
        if (profile.email == null &&
            profile.fullName == null &&
            profile.phone == null &&
            profile.nameOrg == null &&
            profile.unp == null &&
            profile.legalAddress == null) {
          return null;
        }
        return profile;
      }
      return null;
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<bool> isAuthenticated() async {
    // Сессия, выданная сразу после регистрации, живёт только до перезапуска.
    if (await AppStorage.getSingleSession()) {
      await AppStorage.clearLoginData();
      await ApiClient.instance.clearCookies();
      return false;
    }
    if (await AppStorage.isSessionExpired()) {
      await AppStorage.clearLoginData();
      await ApiClient.instance.clearCookies();
      return false;
    }
    final cookies = await AppStorage.getCookies();
    if (cookies == null || cookies.isEmpty) return false;
    await ApiClient.instance.restoreCookies(cookies);
    await AppStorage.extendSession();
    return true;
  }

  void _throwIfPasswordResetFailed(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map) return;
    final value = Map<String, dynamic>.from(data);
    final status = value['status'];
    final statusCode = int.tryParse(status?.toString() ?? '');
    final rawError = value['error'];
    final errorValue = rawError?.toString().trim() ?? '';
    final errors = value['errors'];
    final hasErrors = errors is List
        ? errors.isNotEmpty
        : errors is Map
        ? errors.isNotEmpty
        : errors != null &&
              errors.toString().trim().isNotEmpty &&
              errors.toString().trim().toLowerCase() != 'false';
    var failed =
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
    final statusText = status?.toString().trim().toLowerCase();
    final statusSucceeded =
        status == true ||
        statusText == 'true' ||
        statusText == 'success' ||
        statusText == 'ok' ||
        statusCode == 1 ||
        (statusCode != null && statusCode >= 200 && statusCode < 300);
    if (!failed && status != null && !statusSucceeded) failed = true;
    if (!failed) return;
    final error = ApiError.fromJson(value);
    throw ApiException(
      error.message ??
          error.title ??
          error.details ??
          'Не удалось отправить инструкцию по восстановлению пароля',
      statusCode: response.statusCode,
      errors: error.errors,
      code: error.code,
      details: error.details,
    );
  }

  void _throwIfRegistrationFailed(Response<dynamic> response) {
    final data = response.data;
    if (data is! Map) return;
    final json = Map<String, dynamic>.from(data);
    final error = ApiError.fromJson(json);
    final status = json['status'];
    final statusCode = int.tryParse(status?.toString() ?? '');
    final rawError = json['error'];
    final errorValue = rawError?.toString().trim() ?? '';
    final hasError =
        (error.errors != null && error.errors!.isNotEmpty) ||
        json['success'] == false ||
        json['success']?.toString().toLowerCase() == 'false' ||
        status == false ||
        status?.toString().toLowerCase() == 'false' ||
        (statusCode != null && statusCode >= 400) ||
        (rawError != 0 &&
            errorValue.isNotEmpty &&
            errorValue.toLowerCase() != 'false' &&
            errorValue != '0');
    if (!hasError) return;
    final message =
        error.message ??
        error.title ??
        error.details ??
        (error.errors?.join('\n') ?? 'Не удалось выполнить регистрацию');
    throw ApiException(
      message,
      statusCode: response.statusCode,
      errors: error.errors,
      code: error.code,
      details: error.details,
    );
  }

  ApiException _extractLoginError(DioException error) {
    final normalized = _extractError(error);
    final text = [
      normalized.message,
      normalized.details,
      normalized.code,
      if (normalized.errors != null) ...normalized.errors!,
    ].join(' ').toLowerCase();
    if (error.response?.statusCode == 404 ||
        text.contains('not found') ||
        text.contains('не найден') ||
        text.contains('не существует') ||
        text.contains('unknown user')) {
      return ApiException(
        'Такого пользователя не найдено',
        statusCode: normalized.statusCode,
        code: normalized.code,
      );
    }
    if (error.response?.statusCode == 401 ||
        error.response?.statusCode == 403 ||
        text.contains('неверный логин') ||
        text.contains('неверно указан') ||
        text.contains('неверный пароль') ||
        text.contains('wrong password') ||
        text.contains('invalid password') ||
        text.contains('incorrect login') ||
        text.contains('wrong login') ||
        text.contains('bad credentials') ||
        text.contains('authorization')) {
      return ApiException(
        'Неверный логин или пароль',
        statusCode: normalized.statusCode,
        code: normalized.code,
      );
    }
    return normalized;
  }

  ApiException _extractError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    final data = e.response?.data;
    if (data is Map) {
      final error = ApiError.fromJson(Map<String, dynamic>.from(data));
      return ApiException(
        error.message ??
            error.title ??
            error.details ??
            (error.errors?.join('\n') ?? 'Произошла ошибка'),
        statusCode: e.response?.statusCode,
        errors: error.errors,
        code: error.code,
        details: error.details,
      );
    }
    return ApiException('Произошла ошибка');
  }
}
