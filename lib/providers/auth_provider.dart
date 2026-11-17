import 'package:flutter/foundation.dart';

import '../core/api/api_exception.dart';
import '../core/storage/app_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _init();
  }

  int _sessionVersion = 0;
  bool _isLoading = false;
  bool _authStatus = false;
  bool _isLegal = false;
  UserProfile? _profile;

  int get sessionVersion => _sessionVersion;
  bool get isLoading => _isLoading;
  bool get authStatus => _authStatus;
  bool get isLegal => _isLegal;
  UserProfile? get profile => _profile;

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();
    final start = DateTime.now();
    try {
      _authStatus = await AuthService.instance.isAuthenticated().timeout(
        const Duration(seconds: 5),
      );
      if (_authStatus) {
        _isLegal = await AppStorage.getIsLegal();
        try {
          final profile = await AuthService.instance.getUserProfile().timeout(
            const Duration(seconds: 10),
          );
          if (profile == null) {
            _authStatus = false;
          } else {
            _profile = profile;
            _isLegal = profile.isLegal;
          }
        } on ApiException catch (error) {
          if (error.statusCode == 401 || error.statusCode == 403) {
            _authStatus = false;
          }
        } catch (_) {}
      }
    } catch (_) {}
    final elapsed = DateTime.now().difference(start);
    if (elapsed < const Duration(milliseconds: 2000)) {
      await Future.delayed(const Duration(milliseconds: 2000) - elapsed);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login({
    required String login,
    required String password,
    bool rememberMe = false,
    bool singleSession = false,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await AuthService.instance.login(
        login: login,
        password: password,
        rememberMe: rememberMe,
        singleSession: singleSession,
      );
      final profile = await AuthService.instance.getUserProfile();
      if (profile == null) {
        _authStatus = false;
        throw ApiException('Профиль не загружен');
      }
      _authStatus = true;
      _isLegal = profile.isLegal;
      _profile = profile;
      _sessionVersion++;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await AuthService.instance.logout();
    } finally {
      _authStatus = false;
      _isLegal = false;
      _profile = null;
      _sessionVersion++;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<UserProfile?> refreshProfile() async {
    final profile = await AuthService.instance.getUserProfile();
    if (profile == null) {
      throw StateError('Профиль не загружен');
    }
    _profile = profile;
    _isLegal = profile.isLegal;
    notifyListeners();
    return profile;
  }

  /// Подставляет реквизиты, введённые при регистрации юрлица.
  ///
  /// Сразу после регистрации `users/me.php` ещё не отдаёт реквизиты, и раздел
  /// «Реквизиты организации» в кабинете выглядит пустым, хотя всё заполнено.
  /// Значение подставляется только там, где сервер ничего не вернул: как только
  /// данные появятся в профиле, они вытеснят введённые.
  void fillLegalRequisites({
    String? unp,
    String? nameOrg,
    String? location,
    String? legalAddress,
    String? workPosition,
    String? workProfile,
    String? bankName,
    String? bankAddress,
    String? bankAccount,
    String? bankBic,
  }) {
    final profile = _profile;
    if (profile == null || !profile.isLegal) return;

    String? fill(String? fromServer, String? entered) {
      final server = fromServer?.trim();
      if (server != null && server.isNotEmpty) return server;
      final value = entered?.trim();
      return value == null || value.isEmpty ? fromServer : value;
    }

    _profile = profile.copyWith(
      unp: fill(profile.unp, unp),
      nameOrg: fill(profile.nameOrg, nameOrg),
      location: fill(profile.location, location),
      legalAddress: fill(profile.legalAddress, legalAddress),
      workPosition: fill(profile.workPosition, workPosition),
      workProfile: fill(profile.workProfile, workProfile),
      bankName: fill(profile.bankName, bankName),
      bankAddress: fill(profile.bankAddress, bankAddress),
      bankAccount: fill(profile.bankAccount, bankAccount),
      bankBic: fill(profile.bankBic, bankBic),
    );
    notifyListeners();
  }
}
