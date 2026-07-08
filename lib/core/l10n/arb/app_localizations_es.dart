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
    return '¿Estás seguro de que deseas eliminar {profileName}? Esta acción no se puede deshacer.';
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

  @override
  String get logsHeader => 'Registros de automatización';

  @override
  String get logsSearchHint => 'Buscar por nombre o regla...';

  @override
  String get logsEmpty => 'No se encontraron registros';

  @override
  String get timeJustNow => 'Justo ahora';

  @override
  String timeMinutesAgo(int minutes) {
    return 'Hace ${minutes}m';
  }

  @override
  String timeHoursAgo(int hours) {
    return 'Hace ${hours}h';
  }

  @override
  String timeDaysAgo(int days) {
    return 'Hace ${days}d';
  }

  @override
  String get actionAccepted => 'ACEPTADO';

  @override
  String get actionRejected => 'RECHAZADO';

  @override
  String get tabInvite => 'Invitaciones';

  @override
  String get tabRequest => 'Solicitudes';

  @override
  String get messageTypeInvite => 'Invitación';

  @override
  String get messageTypeResponse => 'Respuesta';

  @override
  String get messageTypeRequest => 'Petición';

  @override
  String get messageTypeRequestResponse => 'Respuesta a Petición';

  @override
  String get tabResponse => 'Respuesta';

  @override
  String get tabReqResponse => 'Resp. Petición';

  @override
  String get liveSlotsHeader => 'Slots Activos en VRChat';

  @override
  String get tooltipSyncFromVrc => 'Sincronizar con VRChat';

  @override
  String get messageLibraryHeader => 'Biblioteca de Mensajes';

  @override
  String get tooltipAddMessage => 'Añadir mensaje';

  @override
  String get libraryEmpty => 'La biblioteca está vacía';

  @override
  String get unassignedMessagesHeader => 'MENSAJES SIN ASIGNAR';

  @override
  String get assignedMessagesHeader => 'ASIGNADOS A SLOTS ACTIVOS';

  @override
  String dialogNewMessageTitle(String type) {
    return 'Nuevo Mensaje de $type';
  }

  @override
  String get dialogNewMessageDesc =>
      'Este mensaje se guardará en tu biblioteca y se podrá asignar a reglas de automatización.';

  @override
  String get inputMessageHint => 'Escribe tu mensaje...';

  @override
  String get inputMessageLabel => 'Mensaje';

  @override
  String get btnCreateMessage => 'Crear Mensaje';

  @override
  String toastMessageAdded(String type) {
    return 'Mensaje de $type añadido a la biblioteca';
  }

  @override
  String messageSlotLabel(int index) {
    return 'Slot $index';
  }

  @override
  String slotPickerTitle(String content) {
    return 'Asignar \'$content\' a un Slot';
  }

  @override
  String slotPickerCategory(String category) {
    return 'Categoría: $category';
  }

  @override
  String get friendsHeader => 'Amigos';

  @override
  String get tooltipRefreshFriends => 'Actualizar amigos';

  @override
  String get searchFriendsHint => 'Buscar amigos...';

  @override
  String get noFriendsFound => 'No se encontraron amigos';

  @override
  String get presenceOnline => 'Conectado';

  @override
  String get presenceOffline => 'Desconectado';

  @override
  String get presenceActiveWebsite => 'Activo en la web';

  @override
  String get presenceTraveling => 'Cambiando de mundo...';

  @override
  String get presencePrivateInstance => 'Instancia privada';

  @override
  String presenceInstanceDesc(String accessType, String region) {
    return 'Instancia $accessType ($region)';
  }

  @override
  String get categoryFavorites => 'Favoritos';

  @override
  String get categorySameInstance => 'En la misma instancia';

  @override
  String get accessPublic => 'Public';

  @override
  String get accessInviteOnly => 'Invite Only';

  @override
  String get accessInvitePlus => 'Invite+';

  @override
  String get accessFriends => 'Friends';

  @override
  String get accessFriendsPlus => 'Friends+';

  @override
  String get accessGroup => 'Group';

  @override
  String get accessGroupPlus => 'Group+';

  @override
  String get accessGroupPublic => 'Group Public';

  @override
  String get accessUnknown => 'Desconocido';

  @override
  String get editProfileTitle => 'Editar perfil';

  @override
  String get dialogUnsavedTitle => 'Cambios sin guardar';

  @override
  String get dialogUnsavedContent =>
      'Tienes cambios sin guardar. ¿Quieres guardarlos antes de salir?';

  @override
  String get btnDiscard => 'Descartar';

  @override
  String get btnSave => 'Guardar';

  @override
  String get btnSaveChanges => 'Guardar cambios';

  @override
  String get sectionProfileSettings => 'Configuración del perfil';

  @override
  String get inputProfileName => 'Nombre del perfil';

  @override
  String get sectionActions => 'Acciones';

  @override
  String get priorityRulesCaption =>
      'Las reglas con mayor prioridad se evalúan primero.';

  @override
  String get sectionAutomationRules => 'Reglas de automatización';

  @override
  String get tooltipRemoveRule => 'Eliminar regla';

  @override
  String get contextOnInviteReceived => 'AL RECIBIR UNA INVITACIÓN';

  @override
  String get contextOnRequestToJoin => 'AL RECIBIR UNA SOLICITUD DE UNIÓN';

  @override
  String get defaultVrcMessage => 'Mensaje predeterminado de VRChat';

  @override
  String dialogSelectMessage(String category) {
    return 'Seleccionar $category';
  }

  @override
  String get defaultMessageOption => 'Usar el mensaje predeterminado de VRChat';

  @override
  String get defaultMessageOptionDesc =>
      'Usa el mensaje de notificación predeterminado de VRChat.';

  @override
  String get btnAddRoleRule => 'Añadir regla de rol';

  @override
  String get searchRolesHint => 'Buscar roles...';

  @override
  String get sectionFallbackTags => 'Etiquetas de respaldo';

  @override
  String get fallbackTagsDesc => 'Se aplican cuando ningún rol coincide.';

  @override
  String get btnAddTag => 'Añadir etiqueta';

  @override
  String get searchTagsHint => 'Buscar etiquetas o idiomas...';

  @override
  String get fallbackTagActionDisabled => 'DESACTIVADO';

  @override
  String get fallbackTagActionAccept => 'ACEPTAR';

  @override
  String get fallbackTagActionReject => 'RECHAZAR';

  @override
  String get newAutomationTitle => 'Nueva automatización';

  @override
  String get editAutomationTitle => 'Editar automatización';

  @override
  String get sectionCondition => 'Condición';

  @override
  String get triggerNewFriendTitle => 'Al añadir un nuevo amigo';

  @override
  String get triggerNewFriendDesc =>
      'Asigna los roles predeterminados a todos los nuevos amigos.';

  @override
  String get triggerHasTagTitle => 'Tiene una etiqueta específica';

  @override
  String get triggerHasTagDesc =>
      'Asigna roles solo si el usuario tiene la etiqueta seleccionada en su perfil.';

  @override
  String get targetTagHeader => 'Etiqueta objetivo';

  @override
  String get tagRequired => 'Obligatorio';

  @override
  String get tagSelected => 'Etiqueta seleccionada';

  @override
  String get tagSelectPlaceholder => 'Selecciona una etiqueta...';

  @override
  String get searchTagsVrcHint => 'Buscar etiquetas de VRChat...';

  @override
  String get sectionAssignRoles => 'Asignar roles';

  @override
  String get btnAddRole => 'Añadir rol';

  @override
  String get noRolesSelectedWarning => 'Debes asignar al menos un rol.';

  @override
  String get searchLocalRolesHint => 'Buscar roles locales...';

  @override
  String get tooltipRemoveRole => 'Eliminar rol';

  @override
  String get editRoleTitle => 'Editar rol';

  @override
  String get errorNameInUseTitle => 'Ese nombre ya está en uso';

  @override
  String get inputRoleName => 'Nombre del rol';

  @override
  String get sectionAppRoles => 'Roles de la aplicación';

  @override
  String get sectionVrcTagsReadOnly => 'Etiquetas de VRChat (solo lectura)';

  @override
  String get errorLoadingRoles => 'No se pudieron cargar los roles';

  @override
  String get noRulesAdded =>
      'Aún no se han añadido reglas.\nHaz clic en \'Añadir regla de rol\' para comenzar.';

  @override
  String get errorLoadingMessages => 'Error al cargar los mensajes';

  @override
  String get ruleActionAccept => 'Aceptar';

  @override
  String get ruleActionReject => 'Rechazar';

  @override
  String get searchPlaceholder => 'Buscar...';

  @override
  String get noItemsMatchSearch => 'Ningún elemento coincide con la búsqueda';

  @override
  String get btnOk => 'Aceptar';

  @override
  String get tooltipShowPassword => 'Mostrar contraseña';

  @override
  String get tooltipHidePassword => 'Ocultar contraseña';

  @override
  String get logNoRuleMatched => 'No se aplicó ninguna regla';

  @override
  String logRuleMatched(String roleName) {
    return 'Regla aplicada para $roleName';
  }

  @override
  String get bgNotificationTitle => 'VRCMA en ejecución';

  @override
  String get bgInitialNotificationTitle => 'Automatización de VRCMA';

  @override
  String get bgInitialNotificationContent => 'Ejecutándose en segundo plano...';

  @override
  String bgNotificationContent(String senderName) {
    return 'Último: $senderName';
  }

  @override
  String get sectionStatusAutomation => 'Automatización de Estado';

  @override
  String get dialogNewStatusProfileTitle => 'Nuevo Perfil de Estado';

  @override
  String get dialogNewStatusProfileLabel => 'Nombre del Perfil';

  @override
  String get editStatusProfileTitle => 'Editar Perfil de Estado';

  @override
  String get sectionGeneralSettings => 'Configuración General';

  @override
  String get inputStatusProfileName => 'Nombre del Perfil';

  @override
  String get inputFallbackStatus => 'Estado Predeterminado';

  @override
  String get inputFallbackTemplate => 'Plantilla de Mensaje Predeterminada';

  @override
  String get statusPriorityRulesCaption =>
      'Usa plantillas como: En {{world}} ({{battery}}🔋)\nLas reglas de estado se evalúan de arriba hacia abajo según su prioridad.';

  @override
  String get sectionAutomationConditions => 'Condiciones de Automatización';

  @override
  String get btnAddConditionRule => 'Añadir Regla de Condición';

  @override
  String get noStatusRulesAdded =>
      'No hay reglas dinámicas de estado configuradas.\nEste perfil siempre utilizará la configuración predeterminada.';

  @override
  String get rulesReorderSubtitle => 'Reglas (Arrastra para Reordenar)';

  @override
  String get dialogNewStatusRuleTitle => 'Nueva Regla de Estado';

  @override
  String get inputTriggerCondition => 'Condición de Activación';

  @override
  String get inputOperator => 'Operador';

  @override
  String get inputComparisonValue => 'Valor de Comparación';

  @override
  String get inputTargetStatus => 'Estado de Destino';

  @override
  String get inputStatusMessageTemplate => 'Plantilla de Mensaje de Estado';

  @override
  String get btnCreateRule => 'Crear Regla';

  @override
  String statusProfileSubtitle(int count, String fallback) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reglas',
      one: '1 regla',
    );
    return '$_temp0, predeterminado: $fallback';
  }

  @override
  String get tooltipEditStatusProfile => 'Editar Perfil de Estado';

  @override
  String get dialogDeleteStatusProfileTitle => 'Eliminar Perfil de Estado';

  @override
  String dialogDeleteStatusProfileContent(String name) {
    return '¿Estás seguro de que quieres eliminar \'$name\'?';
  }

  @override
  String get statusRuleComparisonHint => 'p. ej. 5, Public, 30';

  @override
  String get statusMessageTemplateHint => 'p. ej. En {{world}} con {{friends}}';

  @override
  String get statusRuleNoMessage => 'Sin mensaje';

  @override
  String get statusTypeActive => 'Activo';

  @override
  String get statusTypeJoinMe => 'Únete';

  @override
  String get statusTypeAskMe => 'Pregúntame';

  @override
  String get statusTypeBusy => 'Ocupado';

  @override
  String get conditionTypePopulation => 'Número de jugadores';

  @override
  String get conditionTypeInstanceType => 'Acceso a la instancia';

  @override
  String get conditionTypeBatteryLevel => 'Nivel de batería';

  @override
  String get conditionTypeFriendPresent => 'Amigo presente';

  @override
  String get conditionTypeTimeRange => 'Franja horaria';

  @override
  String get conditionTypeWorld => 'Mundo actual';

  @override
  String get operatorGreaterThan => 'Mayor que';

  @override
  String get operatorLessThan => 'Menor que';

  @override
  String get operatorEqualTo => 'Igual a';

  @override
  String get operatorContains => 'Contiene';

  @override
  String get operatorBetween => 'Entre';

  @override
  String get statusRuleComparisonHintNumber => 'p. ej. 50';

  @override
  String get statusRuleComparisonHintRange => 'p. ej. 20-80';

  @override
  String get statusRuleComparisonHintTimeRange => 'p. ej. 22:00-06:00';

  @override
  String get statusRuleComparisonHintWorldList => 'p. ej. wrld_abc, wrld_def';
}
