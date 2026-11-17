import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';

class AppealsService {
  AppealsService._();

  static final AppealsService instance = AppealsService._();

  static Future<String> requirements() => instance.getRequirements();

  Future<String> getRequirements() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.appealsRequirements,
        options: Options(responseType: ResponseType.plain),
      );
      return response.data?.toString() ?? '';
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  Future<String> withdraw() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.appealsWithdraw,
        options: Options(responseType: ResponseType.plain),
      );
      return response.data?.toString() ?? '';
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  ApiException _extractError(DioException e) {
    if (e.error is ApiException) return e.error as ApiException;
    return ApiException('Произошла ошибка');
  }
}
