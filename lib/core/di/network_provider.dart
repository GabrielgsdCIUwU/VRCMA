import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path/path.dart' as p;

part 'network_provider.g.dart';

@riverpod
Future<CookieJar> cookieJar(Ref ref) async {
  // getApplicationSupportDirectory maps to %APPDATA%\vrcma on Windows,
  // which is the OS-standard location for per-user application data.
  final appSupportDir = await getApplicationSupportDirectory();
  final String path = p.join(appSupportDir.path, '.cookies');

  await Directory(path).create(recursive: true);

  return PersistCookieJar(
    storage: FileStorage(path),
    ignoreExpires: false,
  );
}