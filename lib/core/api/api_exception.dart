class ApiException implements Exception {
  ApiException(
    this.message, {
    this.statusCode,
    this.errors,
    this.code,
    this.details,
  });

  final String message;
  final int? statusCode;
  final List<String>? errors;
  final String? code;
  final String? details;

  @override
  String toString() => message;
}

class ApiError {
  ApiError({this.title, this.message, this.errors, this.code, this.details});

  final String? title;
  final String? message;
  final List<String>? errors;
  final String? code;
  final String? details;

  factory ApiError.fromJson(Map<String, dynamic> json) {
    final errors = _collectErrors(json['errors']);
    return ApiError(
      title: _text(json['title']),
      message: _text(json['message']),
      errors: errors.isEmpty ? null : errors,
      code: _text(json['code']),
      details: _text(json['details'] ?? json['detail'] ?? json['error']),
    );
  }

  static List<String> _collectErrors(Object? value) {
    if (value is List) {
      return value
          .expand(_collectErrors)
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is Map) {
      // Объект ошибки вида {"code":"payMethod","title":"Не указан способ
      // оплаты."}: пользователю показываем описание, а не машинный код.
      for (final key in const ['title', 'message', 'details', 'detail']) {
        final text = _text(value[key]);
        if (text != null) return [text];
      }
      final result = <String>[];
      for (final entry in value.entries) {
        if (entry.key.toString().toLowerCase() == 'code') continue;
        final text = _text(entry.value);
        if (text != null) result.add(text);
      }
      return result;
    }
    final text = _text(value);
    return text == null ? const [] : [text];
  }

  static String? _text(Object? value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}
