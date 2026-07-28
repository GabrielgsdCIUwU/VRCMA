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

  @override
  String get statusOverrideNotification =>
      'Automatización pausada. Has cambiado tu estado de VRChat manualmente.';

  @override
  String get themeModeLabel => 'Modo del tema';

  @override
  String get themeModeSystem => 'Predeterminado del sistema';

  @override
  String get themeModeLight => 'Claro';

  @override
  String get themeModeDark => 'Oscuro';

  @override
  String get languageLabel => 'Idioma';

  @override
  String get diagnosticTitle => 'Diagnóstico y datos';

  @override
  String get clearCacheLabel => 'Borrar caché de metadatos';

  @override
  String get clearCacheDesc =>
      'Vuelve a cargar los nombres de los mundos y las imágenes de los avatares.';

  @override
  String get toastCacheCleared =>
      'La caché de metadatos se ha borrado correctamente.';

  @override
  String get rolesManagementTitle => 'Gestionar roles';

  @override
  String get rolesManagementDesc =>
      'Crea y administra categorías personalizadas para tus amigos.';

  @override
  String get automationManagementDesc =>
      'Crea reglas de automatización basadas en amigos, roles u otras condiciones.';

  @override
  String get dashboardHeader => 'Centro de control';

  @override
  String get dashboardSubheader =>
      'Administra los filtros activos y los perfiles de automatización de estado.';

  @override
  String get clearCachesBtn => 'Borrar caché';

  @override
  String get defaultMessageCustomOption => 'Sin mensaje personalizado';

  @override
  String get defaultMessageCustomOptionDesc =>
      'Usa el mensaje de estado predeterminado sin aplicar una plantilla personalizada.';

  @override
  String get themeLabel => 'Tema';

  @override
  String get toastLocaleChanged => 'El idioma se ha cambiado correctamente.';

  @override
  String get systemLogsTitle => 'Registros del sistema';

  @override
  String get themeSeedColorLabel => 'Color de Acento';

  @override
  String get noProfilesAdded => 'Aún no se han añadido perfiles de filtro.';

  @override
  String get nativeBackgroundRuntimeFail =>
      'Error al inicializar el servicio de segundo plano nativo.';

  @override
  String get automationTriggerNewFriend => 'Al agregar nuevo amigo';

  @override
  String automationTriggerTag(String tag) {
    return 'Etiqueta coincidente: $tag';
  }

  @override
  String automationAssignsRoles(String roles) {
    return 'Asigna: $roles';
  }

  @override
  String get colorDeepPurple => 'Púrpura Profundo';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorTeal => 'Turquesa';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorOrange => 'Naranja';

  @override
  String get colorRose => 'Rosa';

  @override
  String get statusVariablesHelperTitle => 'Guía de Plantillas de Estado';

  @override
  String get statusVariablesHelperDesc =>
      'Toca una plantilla para insertarla en la posición actual del cursor.';

  @override
  String get statusVariableWorld => 'Nombre del Mundo Actual';

  @override
  String get statusVariableCount => 'Número de Jugadores';

  @override
  String get statusVariableBattery => 'Nivel de Batería';

  @override
  String get statusVariableInstance => 'Tipo de Acceso';

  @override
  String get statusVariableTime => 'Hora Local';

  @override
  String get statusVariableFriends => 'Nombres de Amigos';

  @override
  String get contextMenuActivate => 'Activar Perfil';

  @override
  String get contextMenuDeactivate => 'Desactivar Perfil';

  @override
  String get contextMenuEdit => 'Editar Perfil';

  @override
  String get contextMenuDelete => 'Eliminar Perfil';

  @override
  String get dashboardManagementTools => 'Herramientas de Gestión';

  @override
  String get logoutDialogTitle => 'Cerrar Sesión';

  @override
  String get logoutDialogContent =>
      '¿Estás seguro de que deseas cerrar tu sesión de VRChat?';

  @override
  String get logoutButtonLabel => 'Salir';

  @override
  String get errorWorldIdInvalid =>
      'El ID del mundo no es válido. Debe comenzar por \'wrld_\' y tener al menos 10 caracteres.';

  @override
  String get errorMsgEmpty => 'El mensaje personalizado no puede estar vacío.';

  @override
  String errorMsgTooLong(int actual, int max) {
    return 'El mensaje tiene $actual caracteres, pero el máximo permitido es $max.';
  }

  @override
  String errorMsgInvalidSlot(int index) {
    return 'La ranura de mensaje $index no existe.';
  }

  @override
  String get errorRuleInviteMismatch =>
      'Esta regla requiere un mensaje de invitación.';

  @override
  String get errorRuleRequestMismatch =>
      'Esta regla requiere un mensaje de solicitud.';

  @override
  String errorStatusInvalidOperator(String operator, String condition) {
    return 'El operador \'$operator\' no es compatible con la condición \'$condition\'.';
  }

  @override
  String get errorStatusEmptyValue =>
      'Debes indicar un valor para esta condición.';

  @override
  String get errorRoleAutoEmptyRoles =>
      'Selecciona al menos un rol antes de guardar esta automatización.';

  @override
  String get errorRoleAutoMissingTag =>
      'Debes indicar una etiqueta de destino para esta automatización basada en etiquetas.';

  @override
  String get calHeader => 'Automatizaciones del Calendario';

  @override
  String get calSubheader =>
      'Configura reglas automáticas que crean y gestionan eventos de grupo de VRChat en segundo plano.';

  @override
  String get calBtnCreate => 'Crear automatización';

  @override
  String get calEditorTitleNew => 'Nueva regla de calendario';

  @override
  String get calEditorTitleEdit => 'Editar regla de calendario';

  @override
  String get calFieldLabelName => 'Nombre de la regla';

  @override
  String get calFieldLabelGroupId => 'ID del grupo de VRChat';

  @override
  String get calFieldLabelTitle => 'Plantilla del título del evento';

  @override
  String get calFieldLabelDesc => 'Plantilla de la descripción del evento';

  @override
  String get calFieldHintTitle => 'Admite el marcador {{incremental}}.';

  @override
  String get calSectionSchedule => 'Programación';

  @override
  String get calFieldLabelTime => 'Hora de inicio';

  @override
  String get calFieldLabelDuration => 'Duración (minutos)';

  @override
  String get calFieldLabelTimezone => 'Zona horaria (IANA)';

  @override
  String get calSectionRecurrence => 'Recurrencia';

  @override
  String get calSectionIncremental => 'Contador incremental';

  @override
  String get calSectionVrcMetadata => 'Configuración del evento de VRChat';

  @override
  String get calFieldLabelHostEarly =>
      'Acceso anticipado para el host (minutos)';

  @override
  String get calFieldLabelGuestEarly =>
      'Acceso anticipado para miembros (minutos)';

  @override
  String get calFieldLabelCloseDelay =>
      'Retraso de limpieza automática (minutos)';

  @override
  String get calFieldLabelOverflow =>
      'Activar protección contra desbordamiento de instancias';

  @override
  String get calToastSaved =>
      'La regla de calendario se ha guardado correctamente.';

  @override
  String get calConfirmDeleteTitle => 'Eliminar regla de automatización';

  @override
  String get calConfirmDeleteContent =>
      '¿Seguro que quieres eliminar esta regla de automatización? Esta acción no se puede deshacer.';

  @override
  String get calMsgEmptyRules =>
      'Todavía no se ha creado ninguna regla de automatización del calendario.';

  @override
  String get calRecurrenceOnce => 'Una vez';

  @override
  String get calRecurrenceDaily => 'Diario';

  @override
  String get calRecurrenceWeekly => 'Semanal';

  @override
  String get calRecurrenceMonthly => 'Mensual';

  @override
  String get calCategoryArts => 'Artes';

  @override
  String get calCategoryAvatars => 'Avatares';

  @override
  String get calCategoryDance => 'Danza';

  @override
  String get calCategoryEducation => 'Educación';

  @override
  String get calCategoryExploration => 'Exploración';

  @override
  String get calCategoryFilmMedia => 'Cine y Medios';

  @override
  String get calCategoryGaming => 'Videojuegos';

  @override
  String get calCategoryHangout => 'Quedadas';

  @override
  String get calCategoryMusic => 'Música';

  @override
  String get calCategoryPerformance => 'Espectáculos';

  @override
  String get calCategoryRoleplaying => 'Rol';

  @override
  String get calCategoryWellness => 'Bienestar';

  @override
  String get calCategoryOther => 'Otro';

  @override
  String get calFieldLabelEndTime => 'Hora de finalización';

  @override
  String get calFieldLabelDaysOfWeek => 'Días de la semana';

  @override
  String calDurationHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String calDurationMinutesOnly(int minutes) {
    return '${minutes}m';
  }

  @override
  String get calFieldLabelPlatform => 'Plataformas del evento';

  @override
  String get calFieldLabelIncrementalStart => 'Valor inicial';

  @override
  String get calFieldLabelIncrementalStep => 'Incremento';

  @override
  String get calFieldLabelIncrementalEnable => 'Activar contador incremental';

  @override
  String get calFieldLabelIncrementalDesc =>
      'Incrementa automáticamente la numeración (p. ej. Evento #1, Evento #2)';

  @override
  String get calSectionTolerances => 'Tolerancias avanzadas de acceso';

  @override
  String get calFieldLabelOverflowDesc =>
      'Evita que la instancia se desborde al alcanzar el límite';

  @override
  String get calFieldLabelHostEarlyShort => 'Acceso host (min)';

  @override
  String get calFieldLabelGuestEarlyShort => 'Acceso miembros (min)';

  @override
  String get calFieldLabelCloseDelayShort => 'Retraso de cierre (min)';

  @override
  String get calLiveCardPreview => 'Vista previa de la tarjeta en vivo';

  @override
  String get calNoTitleTemplate => 'Sin título';

  @override
  String get calNoDescriptionTemplate => 'Sin descripción';

  @override
  String get calPlatformDesc =>
      'Determina qué plataformas de VRChat serán compatibles oficialmente con este evento.';

  @override
  String get calAccessPublicDesc =>
      'Cualquier usuario de VRChat podrá ver y unirse a este evento.';

  @override
  String get calAccessGroupDesc =>
      'Solo los miembros aprobados del grupo podrán ver y acceder a este evento.';

  @override
  String get calToleranceHostTitle => 'Acceso de anfitriones';

  @override
  String get calToleranceHostDesc =>
      'Permite que los anfitriones entren antes a la instancia del mundo para prepararla.';

  @override
  String get calToleranceMemberTitle => 'Acceso de miembros';

  @override
  String get calToleranceMemberDesc =>
      'Define cuántos minutos antes del inicio podrán unirse los miembros del grupo.';

  @override
  String get calToleranceCloseTitle => 'Retraso de cierre';

  @override
  String get calToleranceCloseDesc =>
      'Tiempo de espera tras la hora de finalización antes de cerrar la instancia.';

  @override
  String get calGroupSelectHint => 'Selecciona un grupo de VRChat...';

  @override
  String get calGroupNoPerms =>
      'No se encontraron grupos en los que tengas permisos para gestionar el calendario.';

  @override
  String get calGroupValidating => 'Comprobando permisos...';

  @override
  String get calGroupPermissionDenied =>
      'No tienes permisos para gestionar el calendario de este grupo.';

  @override
  String get calFieldLabelStartDate => 'Fecha de inicio';

  @override
  String get calFieldLabelEndDate => 'Fecha de finalización';

  @override
  String get calSectionExceptions => 'Excepciones';

  @override
  String get calExceptionAdd => 'Añadir excepción';

  @override
  String get calExceptionCancel => 'Cancelar el evento en esta fecha';

  @override
  String get calExceptionsEmpty => 'No hay excepciones configuradas';

  @override
  String get calDaysOfMonth => 'Días del mes';

  @override
  String get calOptionalDate => 'Opcional';

  @override
  String calExceptionUntil(String date) {
    return ' hasta el $date';
  }

  @override
  String get calSectionStrategy => 'Estrategia de generación';

  @override
  String get calFieldLabelStrategy => 'Estrategia';

  @override
  String get calFieldLabelMaxEvents => 'Máximo de eventos próximos';

  @override
  String get calStrategyLazy => 'Perezosa (mantiene 1 evento)';

  @override
  String get calStrategyBatch => 'Por lotes (múltiples eventos)';
}
