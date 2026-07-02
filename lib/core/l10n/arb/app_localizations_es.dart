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

  @override
  String get sectionProfiles => 'Perfiles';

  @override
  String get sectionRoles => 'Roles';

  @override
  String get sectionFriendAutomations => 'Automatización de amigos';

  @override
  String get bgAutomationTitle => 'Automatización en segundo plano';

  @override
  String get bgAutomationDesc =>
      'Sigue procesando invitaciones cuando la aplicación esté cerrada';

  @override
  String get dialogNewProfileTitle => 'Nuevo perfil';

  @override
  String get dialogNewProfileLabel => 'Nombre del perfil';

  @override
  String get dialogNewRoleTitle => 'Nuevo rol';

  @override
  String get dialogNewRoleLabel => 'Nombre del rol';

  @override
  String get btnCancel => 'Cancelar';

  @override
  String get btnCreate => 'Crear';

  @override
  String get btnDelete => 'Eliminar';

  @override
  String roleMembersCount(int count) {
    return '$count miembros';
  }

  @override
  String profileRulesCount(int count) {
    return '$count reglas de automatización';
  }

  @override
  String get dialogDeleteRoleTitle => '¿Eliminar rol?';

  @override
  String dialogDeleteRoleContent(String roleName) {
    return '¿Estás seguro de que deseas eliminar \'$roleName\'?\nEsto eliminará este rol de todos los usuarios y perfiles.';
  }

  @override
  String get dialogDeleteProfileTitle => '¿Eliminar perfil?';

  @override
  String dialogDeleteProfileContent(String profileName) {
    return '¿Estás seguro de que deseas eliminar \'$profileName\'? Esta acción no se puede deshacer.';
  }

  @override
  String get dialogDeleteAutomationTitle => '¿Eliminar automatización?';

  @override
  String get dialogDeleteAutomationContent =>
      '¿Estás seguro de que deseas eliminar esta automatización?';

  @override
  String get stateLoading => 'Cargando...';

  @override
  String stateError(String error) {
    return 'Error: $error';
  }

  @override
  String get tooltipEdit => 'Editar';

  @override
  String get tooltipDeactivate => 'Desactivar perfil';

  @override
  String get tooltipActivate => 'Establecer como activo';

  @override
  String get tooltipMoreOptions => 'Más opciones';

  @override
  String get noAutomationsConfigured => 'No hay automatizaciones configuradas';

  @override
  String get triggerOnNewFriend => 'Al agregar nuevo amigo';

  @override
  String triggerHasTag(String tagName) {
    return 'Tiene la etiqueta $tagName';
  }

  @override
  String automationAssigns(String roles) {
    return 'Asigna: $roles';
  }
}
