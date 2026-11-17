import 'package:cookie_jar/cookie_jar.dart';

import 'cookie_jar_provider_io.dart'
    if (dart.library.js_interop) 'cookie_jar_provider_web.dart'
    as impl;

Future<CookieJar> createCookieJar() => impl.createCookieJar();
