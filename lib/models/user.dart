import '../core/utils/text_utils.dart';

class UserProfile {
  UserProfile({
    this.isLegal = false,
    this.phone,
    this.email,
    this.fio,
    this.lastName,
    this.name,
    this.secondName,
    this.unp,
    this.codePodr,
    this.face,
    this.mainDoc,
    this.nameOrg,
    this.location,
    this.legalName,
    this.legalRegion,
    this.legalAddress,
    this.workPosition,
    this.workProfile,
    this.bankName,
    this.bankBic,
    this.bankAccount,
    this.bankAddress,
  });

  final bool isLegal;
  final String? phone;
  final String? email;
  final String? fio;
  final String? lastName;
  final String? name;
  final String? secondName;
  final String? unp;
  final String? codePodr;
  final String? face;
  final String? mainDoc;
  final String? nameOrg;
  final String? location;
  final String? legalName;
  final String? legalRegion;
  final String? legalAddress;
  final String? workPosition;
  final String? workProfile;
  final String? bankName;
  final String? bankBic;
  final String? bankAccount;
  final String? bankAddress;

  /// Копия профиля с заменёнными реквизитами.
  ///
  /// Значение `null` означает «оставить как было», поэтому пустая строка не
  /// затирает прежнее значение: введено при регистрации может быть не всё.
  UserProfile copyWith({
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
  }) => UserProfile(
    isLegal: isLegal,
    phone: phone,
    email: email,
    fio: fio,
    lastName: lastName,
    name: name,
    secondName: secondName,
    unp: unp ?? this.unp,
    codePodr: codePodr,
    face: face,
    mainDoc: mainDoc,
    nameOrg: nameOrg ?? this.nameOrg,
    location: location ?? this.location,
    legalName: legalName,
    legalRegion: legalRegion,
    legalAddress: legalAddress ?? this.legalAddress,
    workPosition: workPosition ?? this.workPosition,
    workProfile: workProfile ?? this.workProfile,
    bankName: bankName ?? this.bankName,
    bankBic: bankBic ?? this.bankBic,
    bankAccount: bankAccount ?? this.bankAccount,
    bankAddress: bankAddress ?? this.bankAddress,
  );

  String? get fullName {
    final parts = [
      lastName,
      name,
      secondName,
    ].where((value) => value != null && value.isNotEmpty).toList();
    if (parts.isNotEmpty) return parts.join(' ');
    final fallback = fio?.trim();
    return fallback == null || fallback.isEmpty ? null : fallback;
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final data = nested is Map
        ? Map<String, dynamic>.from(nested)
        : Map<String, dynamic>.from(json);
    final organization = _mapOf(
      data['organization'] ??
          data['organizationInfo'] ??
          data['company'] ??
          data['org'],
    );
    final bank = _mapOf(
      data['bank'] ?? data['bankRequisites'] ?? data['requisites'],
    );
    final fioText = _deepText(data, const ['fio']);
    final fioParts =
        fioText
            ?.split(RegExp(r'\s+'))
            .where((part) => part.isNotEmpty)
            .toList() ??
        const <String>[];
    return UserProfile(
      isLegal:
          _asBool(
            data['isLegal'] ??
                data['legal'] ??
                data['userType'] ??
                data['accountType'],
          ) ||
          (data['unp'] != null || organization['unp'] != null),
      phone: _text(
        data['phone'] ??
            data['legalPhone'] ??
            data['contactPhone'] ??
            data['mobile'],
      ),
      email: _text(data['email'] ?? organization['email']),
      fio: fioText,
      lastName:
          _text(data['lastName'] ?? data['familyName']) ??
          (fioParts.isNotEmpty ? fioParts.first : null),
      name: _text(data['name']) ?? (fioParts.length > 1 ? fioParts[1] : null),
      secondName:
          _text(data['secondName'] ?? data['patronymic']) ??
          (fioParts.length > 2 ? fioParts[2] : null),
      unp:
          _text(data['unp'] ?? organization['unp'] ?? organization['UNP']) ??
          _deepText(data, const ['unp', 'UNP', 'inn']),
      codePodr:
          _text(data['codePodr'] ?? organization['codePodr']) ??
          _deepText(data, const ['codePodr']),
      face:
          _text(
            data['face'] ??
                organization['face'] ??
                data['workPosition'] ??
                organization['workPosition'],
          ) ??
          _deepText(data, const ['face', 'workPosition']),
      mainDoc:
          _text(
            data['mainDoc'] ??
                organization['mainDoc'] ??
                data['workProfile'] ??
                organization['workProfile'],
          ) ??
          _deepText(data, const ['mainDoc', 'workProfile']),
      nameOrg:
          _text(
            data['nameOrg'] ??
                data['legalName'] ??
                data['companyName'] ??
                organization['name'] ??
                organization['companyName'] ??
                organization['nameOrg'],
          ) ??
          _deepText(data, const [
            'nameOrg',
            'legalName',
            'companyName',
            'organizationName',
          ]),
      location:
          _text(
            data['location'] ?? data['legalRegion'] ?? organization['location'],
          ) ??
          _deepText(data, const ['location', 'legalRegion']),
      legalName: _text(data['legalName'] ?? organization['legalName']),
      legalRegion: _text(data['legalRegion'] ?? organization['region']),
      legalAddress:
          _text(
            data['legalAddress'] ??
                organization['legalAddress'] ??
                organization['address'],
          ) ??
          _deepText(data, const ['legalAddress', 'legalAdress']),
      workPosition:
          _text(data['workPosition'] ?? organization['workPosition']) ??
          _deepText(data, const ['workPosition']),
      workProfile:
          _text(data['workProfile'] ?? organization['workProfile']) ??
          _deepText(data, const ['workProfile']),
      bankName:
          _text(data['bankName'] ?? bank['name'] ?? bank['bankName']) ??
          _deepText(data, const ['bankName']),
      bankBic: _text(data['bankBic'] ?? bank['bic'] ?? bank['BIC']),
      bankAccount:
          _text(
            data['bankAccount'] ?? bank['account'] ?? bank['accountNumber'],
          ) ??
          _deepText(data, const ['bankAccount', 'account']),
      bankAddress:
          _text(
            data['bankAddress'] ?? bank['address'] ?? bank['bankAddress'],
          ) ??
          _deepText(data, const ['bankAddress']),
    );
  }
}

String? _text(Object? value) => cleanApiTextOrNull(value);

Map<String, dynamic> _mapOf(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

/// Ищет значение по списку ключей на любой глубине ответа.
///
/// Нужно, потому что `users/me.php` отдаёт реквизиты организации по-разному:
/// часть полей лежит плоско в корне, часть — внутри `organization` /
/// `organizationInfo`, иногда с дополнительной обёрткой `data`.
String? _deepText(Object? node, List<String> keys, {int depth = 0}) {
  if (node is Map) {
    final map = Map<String, dynamic>.from(node);
    for (final key in keys) {
      final direct = cleanApiTextOrNull(map[key]);
      if (direct != null) return direct;
    }
    if (depth >= 4) return null;
    for (final value in map.values) {
      final found = _deepText(value, keys, depth: depth + 1);
      if (found != null) return found;
    }
    return null;
  }
  if (node is List && depth < 4) {
    for (final item in node) {
      final found = _deepText(item, keys, depth: depth + 1);
      if (found != null) return found;
    }
  }
  return null;
}

bool _asBool(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value?.toString().toLowerCase();
  return text == 'true' ||
      text == '1' ||
      text == 'legal' ||
      text == 'juristic' ||
      text == 'юридическое лицо';
}
