import 'package:cookie_jar/cookie_jar.dart';

/// Cookie jar в памяти.
///
/// Раньше сессия (`PHPSESSID`) сохранялась на диск открытым текстом через
/// [PersistCookieJar]. Файл с токеном сессии читается при физическом доступе к
/// устройству и попадает в резервные копии, поэтому дисковая запись убрана:
/// сессия хранится только в защищённом хранилище (`AppStorage`) и
/// восстанавливается при запуске.
Future<CookieJar> createCookieJar() async => CookieJar();
