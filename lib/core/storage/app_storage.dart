import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage._();

  static const _secure = FlutterSecureStorage();

  static const _kLogin = 'login';
  static const _kSavedPassword = 'savedPassword';
  static const _kCookies = 'cookies';
  static const _kIsLegal = 'isLegal';
  static const _kRememberMe = 'rememberMe';
  static const _kUserToken = 'userToken';
  static const _kSessionExpiresAt = 'sessionExpiresAt';
  static const _kSingleSession = 'singleSession';
  static const _kBackgroundedAt = 'backgroundedAt';

  static const sessionDuration = Duration(days: 365);

  // ---- Secure storage ----

  static Future<String?> getLogin() => _secure.read(key: _kLogin);
  static Future<void> setLogin(String value) =>
      _secure.write(key: _kLogin, value: value);

  static Future<String?> getSavedPassword() =>
      _secure.read(key: _kSavedPassword);
  static Future<void> setSavedPassword(String value) =>
      _secure.write(key: _kSavedPassword, value: value);

  static Future<String?> getCookies() => _secure.read(key: _kCookies);
  static Future<void> setCookies(String value) =>
      _secure.write(key: _kCookies, value: value);

  static Future<String?> getUserToken() => _secure.read(key: _kUserToken);
  static Future<void> setUserToken(String value) =>
      _secure.write(key: _kUserToken, value: value);

  // ---- Shared preferences ----

  static Future<bool> getIsLegal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kIsLegal) ?? false;
  }

  static Future<void> setIsLegal(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kIsLegal, value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kRememberMe) ?? false;
  }

  static Future<void> setRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kRememberMe, value);
  }

  /// Сессия, которая действует только до перезапуска приложения.
  /// Ставится сразу после регистрации: пользователь попадает внутрь без ввода
  /// логина, но после выхода из приложения приходится вводить его снова.
  static Future<bool> getSingleSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSingleSession) ?? false;
  }

  static Future<void> setSingleSession(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value) {
      await prefs.setBool(_kSingleSession, true);
    } else {
      await prefs.remove(_kSingleSession);
    }
  }

  static Future<DateTime?> getSessionExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_kSessionExpiresAt);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  static Future<void> setSessionExpiresAt(DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kSessionExpiresAt, value.millisecondsSinceEpoch);
  }

  static Future<void> extendSession() =>
      setSessionExpiresAt(DateTime.now().add(sessionDuration));

  /// Момент сворачивания приложения: по нему считается простой пользователя.
  ///
  /// Храним в настройках, а не только в памяти: Android может завершить процесс
  /// в фоне, и после повторного запуска сессия всё равно должна истечь.
  static Future<DateTime?> getBackgroundedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_kBackgroundedAt);
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  static Future<void> setBackgroundedAt(DateTime value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kBackgroundedAt, value.millisecondsSinceEpoch);
  }

  static Future<void> clearBackgroundedAt() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kBackgroundedAt);
  }

  static Future<bool> isSessionExpired() async {
    final expiresAt = await getSessionExpiresAt();
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt);
  }

  static Future<void> setLoginData({
    required String login,
    required String password,
    required bool rememberMe,
    required bool isLegal,
    required String cookies,
  }) async {
    await setCookies(cookies);
    await setIsLegal(isLegal);
    await setRememberMe(rememberMe);
    await extendSession();
    if (rememberMe) {
      await setLogin(login);
      await setSavedPassword(password);
    } else {
      await setLogin('');
      await setSavedPassword('');
    }
  }

  static Future<void> clearLoginData() async {
    await _secure.delete(key: _kCookies);
    await _secure.delete(key: _kLogin);
    await _secure.delete(key: _kSavedPassword);
    await _secure.delete(key: _kUserToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kIsLegal);
    await prefs.remove(_kRememberMe);
    await prefs.remove(_kSessionExpiresAt);
    await prefs.remove(_kSingleSession);
    await prefs.remove(_kBackgroundedAt);
  }

  static Future<void> clearAll() async {
    await _secure.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
