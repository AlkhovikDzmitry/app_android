import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';
import '../models/user.dart';
import '../models/vehicle.dart';

class UserService {
  UserService._();

  static final UserService instance = UserService._();

  Future<UserProfile?> getProfile() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.userProfile,
      );
      final data = response.data;
      if (data is! Map) return null;
      return UserProfile.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> editProfile(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.instance.dio.patch(
        ApiEndpoints.userEditProfile,
        data: data,
      );
      _throwIfFailed(response.data);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> changeNotification(Map<String, dynamic> data) async {
    try {
      await ApiClient.instance.dio.patch(
        ApiEndpoints.userChangeNotification,
        data: data,
      );
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> deleteAccount(Map<String, dynamic> data) async {
    try {
      await ApiClient.instance.dio.delete(ApiEndpoints.userDelete, data: data);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<List<Vehicle>> getVehicles() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.vehiclesList,
      );
      final data = response.data;
      final list = data is List
          ? data
          : data is Map
          ? data['data']
          : null;
      if (list is List) {
        return list
            .whereType<Map>()
            .map((value) => Vehicle.fromJson(Map<String, dynamic>.from(value)))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> addVehicle(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.instance.dio.post(
        ApiEndpoints.vehicleAdd,
        data: data,
      );
      _throwIfFailed(response.data);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> editVehicle(Map<String, dynamic> data) async {
    try {
      final response = await ApiClient.instance.dio.put(
        ApiEndpoints.vehicleEdit,
        data: data,
      );
      _throwIfFailed(response.data);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<void> deleteVehicle(int vehicleId) async {
    try {
      await ApiClient.instance.dio.delete(
        ApiEndpoints.vehicleDelete,
        queryParameters: {'vechicleId': vehicleId},
      );
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<bool> checkRegNumberValid(String regNumber) async {
    try {
      await ApiClient.instance.dio.get(
        ApiEndpoints.vehicleRegNumberValidator,
        queryParameters: {'regNumber': regNumber},
      );
      return true;
    } on DioException catch (e) {
      if (e.error is ApiException) return false;
      throw _extractError(e);
    }
  }

  Future<bool> checkCertNumberValid(String certNumber) async {
    try {
      await ApiClient.instance.dio.get(
        ApiEndpoints.vehicleCertNumberValidator,
        queryParameters: {'certNumber': certNumber},
      );
      return true;
    } on DioException catch (e) {
      if (e.error is ApiException) return false;
      throw _extractError(e);
    }
  }

  void _throwIfFailed(Object? response) {
    if (response is! Map) return;
    final value = Map<String, dynamic>.from(response);
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
    throw ApiException(message?.toString() ?? 'Не удалось сохранить профиль');
  }

  ApiException _extractError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException('Произошла ошибка');
  }
}
