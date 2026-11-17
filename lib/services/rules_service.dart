import 'package:dio/dio.dart';

import '../core/api/api_client.dart';
import '../core/api/api_endpoints.dart';
import '../core/api/api_exception.dart';

class RulesService {
  RulesService._();

  static final RulesService instance = RulesService._();

  /// Текст согласия на обработку персональных данных.
  ///
  /// Сервер отдаёт готовую HTML-разметку, поэтому запрос запрашивается как
  /// обычный текст, без разбора JSON.
  Future<String> getRules() async {
    try {
      final response = await ApiClient.instance.dio.get(
        ApiEndpoints.rules,
        options: Options(responseType: ResponseType.plain),
      );
      return response.data?.toString().trim() ?? '';
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error as ApiException;
      throw ApiException('Не удалось загрузить текст согласия');
    }
  }
}
