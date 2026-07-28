import 'package:dio/dio.dart';
import 'package:vrcma/core/network/sanitizer/i_json_sanitizer_rule.dart';

/// Interceptor que aplica una lista de reglas de sanitización a las respuestas
/// de la API. Esto previene que la aplicación colapse debido a errores de parseo
/// por datos inesperados o enums no soportados añadidos por VRChat.
class VrcEnumSanitizerInterceptor extends Interceptor {
  final List<IJsonSanitizerRule> rules;

  VrcEnumSanitizerInterceptor(this.rules);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.data != null) {
      // Iteramos sobre las reglas y aplicamos aquellas que puedan manejar la petición
      for (final rule in rules) {
        if (rule.canHandle(response.requestOptions)) {
          response.data = rule.sanitize(response.data);
        }
      }
    }
    super.onResponse(response, handler);
  }
}
