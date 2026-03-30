import 'package:mockito/annotations.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:dio/dio.dart';

@GenerateMocks([
  VrchatDart,
  AuthenticationApi,
  CookieJar,
  Dio
])
void main() {}