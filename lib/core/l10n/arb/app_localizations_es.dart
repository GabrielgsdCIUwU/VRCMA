// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get loginTitle => 'VRCMA';

  @override
  String get usernameLabel => 'Usuario o Correo Electrónico';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get enter2faTitle => 'Introduce el código 2FA';

  @override
  String get digitCodeLabel => 'Código de 6 dígitos';

  @override
  String get verifyButton => 'Verificar';

  @override
  String get backButton => 'Volver';

  @override
  String get loginSuccess => '¡Inicio de sesión correcto!';

  @override
  String get connectionTimeout =>
      'Tiempo de espera agotado. Comprueba tu conexión a Internet';

  @override
  String unexpectedError(String error) {
    return 'Error inesperado: $error';
  }

  @override
  String get navConfig => 'Config';

  @override
  String get navMessages => 'Mensajes';

  @override
  String get navLogs => 'Registros';

  @override
  String get navFriends => 'Amigos';

  @override
  String get workspaceTabMessages => 'Mensajes y Slots';

  @override
  String get workspaceTabLogs => 'Registros de Automatización';
}
