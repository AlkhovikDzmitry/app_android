class PhoneUtils {
  PhoneUtils._();

  static final RegExp _localPhonePattern = RegExp(r'^(29|25|44|33|17)\d{7}$');

  static String? normalize(String value) {
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('375') && digits.length == 12) {
      digits = digits.substring(3);
    } else if (digits.startsWith('80') && digits.length == 11) {
      digits = digits.substring(2);
    } else if ((digits.startsWith('8') || digits.startsWith('0')) &&
        digits.length == 10) {
      digits = digits.substring(1);
    }
    if (digits.length != 9 || !_localPhonePattern.hasMatch(digits)) {
      return null;
    }
    return '375$digits';
  }

  static String format(String value) {
    final normalized = normalize(value);
    if (normalized == null) return value.trim();
    final local = normalized.substring(3);
    return '+375 ${local.substring(0, 2)} '
        '${local.substring(2, 5)}-${local.substring(5, 7)}-'
        '${local.substring(7)}';
  }

  static bool isValid(String value) => normalize(value) != null;
}
