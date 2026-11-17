import 'package:cookie_jar/cookie_jar.dart';

Future<CookieJar> createCookieJar() async {
  return WebCookieJar();
}
