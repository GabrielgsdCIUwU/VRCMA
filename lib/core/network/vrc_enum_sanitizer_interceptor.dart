import 'package:dio/dio.dart';
import 'package:vrcma/core/network/sanitizer/i_json_sanitizer_rule.dart';

/// Interceptor that applies a list of sanitization rules to API responses.
/// This prevents the application from crashing due to parsing errors caused by
/// unexpected data or unsupported enums newly added by VRChat.
class VrcEnumSanitizerInterceptor extends Interceptor {
  final List<IJsonSanitizerRule> rules;

  VrcEnumSanitizerInterceptor(this.rules);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data != null) {
      for (final rule in rules) {
        if (rule.canHandle(response.requestOptions)) {
          response.data = rule.sanitize(response.data);
        }
      }
    }
    super.onResponse(response, handler);
  }
}
