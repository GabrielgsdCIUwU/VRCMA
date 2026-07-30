import 'package:dio/dio.dart';

/// Interface for JSON sanitization rules, useful for preventing deserialization errors
/// when processing unstable responses from external APIs.
abstract class IJsonSanitizerRule {
  /// Determines whether the rule should be applied based on the request options.
  bool canHandle(RequestOptions options);

  /// Executes the sanitization on the payload (usually a Map or List) before parsing.
  dynamic sanitize(dynamic data);
}
