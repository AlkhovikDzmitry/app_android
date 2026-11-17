String cleanApiText(Object? value) {
  if (value == null) return '';

  var text = value.toString();
  text = text.replaceAll(
    RegExp(r'<br\s*\\?\s*/?\s*>', caseSensitive: false),
    '\n',
  );
  text = text.replaceAll(RegExp(r'</?[a-z][^>]*>', caseSensitive: false), '');
  text = text.replaceAllMapped(
    RegExp(r'&#(?:x([0-9a-f]+)|([0-9]+));', caseSensitive: false),
    (match) {
      final hex = match.group(1);
      final decimal = match.group(2);
      final value =
          int.tryParse(hex ?? '', radix: 16) ?? int.tryParse(decimal ?? '');
      return value == null ? match.group(0)! : String.fromCharCode(value);
    },
  );
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&laquo;', '«')
      .replaceAll('&raquo;', '»')
      .replaceAll('&ndash;', '–')
      .replaceAll('&mdash;', '—')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&le;', '≤')
      .replaceAll('&ge;', '≥')
      .replaceAll('&apos;', "'")
      .replaceAll('&amp;', '&');
  text = text
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;lt;', '<')
      .replaceAll('&amp;gt;', '>');
  text = text.replaceAll('\r\n', '\n').replaceAll('\r', '\n');
  text = text.replaceAll(RegExp(r'[ \t]+'), ' ');
  text = text.replaceAll(RegExp(r' *\n *'), '\n');
  text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');
  return text.trim();
}

String? cleanApiTextOrNull(Object? value) {
  final text = cleanApiText(value);
  return text.isEmpty ? null : text;
}

int? parseApiInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

String normalizeUnp(String value) => value.replaceAll(RegExp(r'\D'), '');

/// Приводит номер свидетельства о регистрации ТС (техпаспорта) к единому виду:
/// верхний регистр, без пробелов и дефисов.
String normalizeCertNumber(String value) =>
    value.trim().toUpperCase().replaceAll(RegExp(r'[\s-]'), '');

/// Проверяет номер свидетельства о регистрации ТС.
///
/// Форматы в Беларуси различаются: с ведущими буквами (АВ1234567), с ведущими
/// цифрами (7ТК0021139), смешанные. Поэтому проверка намеренно мягкая — номер
/// должен состоять только из букв и цифр (латиница/кириллица), быть длиной
/// 6–14 символов и содержать хотя бы одну букву и одну цифру. Точную проверку
/// выполняет сервер.
bool isValidCertNumber(String value) {
  final normalized = normalizeCertNumber(value);
  if (normalized.isEmpty) return false;
  return RegExp(
    r'^(?=.*[A-ZА-Я])(?=.*\d)[A-ZА-Я0-9]{6,14}$',
  ).hasMatch(normalized);
}

bool isValidUnp(String value) {
  final digits = normalizeUnp(value);
  if (digits.length != 9 || digits[0] == '0') return false;
  const weights = [29, 23, 19, 17, 13, 7, 5, 3];
  var sum = 0;
  for (var i = 0; i < weights.length; i++) {
    sum += int.parse(digits[i]) * weights[i];
  }
  return sum % 11 == int.parse(digits[8]);
}
