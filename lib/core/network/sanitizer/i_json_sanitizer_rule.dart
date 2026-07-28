import 'package:dio/dio.dart';

/// Interfaz para reglas de sanitización de JSON, útil para evitar errores de deserialización
/// al procesar respuestas inestables de APIs externas.
abstract class IJsonSanitizerRule {
  /// Determina si la regla debe aplicarse basándose en las opciones de la petición.
  bool canHandle(RequestOptions options);

  /// Ejecuta la sanitización sobre los datos (usualmente Map o List) antes del parseo.
  dynamic sanitize(dynamic data);
}
