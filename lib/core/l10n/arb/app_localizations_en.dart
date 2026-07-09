// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loginTitle => 'VRCMA';

  @override
  String get usernameLabel => 'Username or Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get loginButton => 'Login';

  @override
  String get enter2faTitle => 'Enter 2FA Code';

  @override
  String get digitCodeLabel => '6-Digit Code';

  @override
  String get verifyButton => 'Verify';

  @override
  String get backButton => 'Back';

  @override
  String get loginSuccess => 'Login Success!';

  @override
  String get connectionTimeout =>
      'Connection timeout. Check your internet connection';

  @override
  String unexpectedError(String error) {
    return 'Unexpected error: $error';
  }

  @override
  String get navConfig => 'Config';

  @override
  String get navMessages => 'Messages';

  @override
  String get navLogs => 'Logs';

  @override
  String get navFriends => 'Friends';

  @override
  String get workspaceTabMessages => 'Messages & Slots';

  @override
  String get workspaceTabLogs => 'Automation Logs';

  @override
  String get sectionProfiles => 'Profiles';

  @override
  String get sectionRoles => 'Roles';

  @override
  String get sectionFriendAutomations => 'Friend Automations';

  @override
  String get bgAutomationTitle => 'Background Automation';

  @override
  String get bgAutomationDesc => 'Keep processing invites when app is closed';

  @override
  String get dialogNewProfileTitle => 'New Profile';

  @override
  String get dialogNewProfileLabel => 'Profile name';

  @override
  String get dialogNewRoleTitle => 'New Role';

  @override
  String get dialogNewRoleLabel => 'Role name';

  @override
  String get btnCancel => 'Cancel';

  @override
  String get btnCreate => 'Create';

  @override
  String get btnDelete => 'Delete';

  @override
  String roleMembersCount(int count) {
    return '$count members';
  }

  @override
  String profileRulesCount(int count) {
    return '$count automation rules';
  }

  @override
  String get dialogDeleteRoleTitle => 'Delete Role?';

  @override
  String dialogDeleteRoleContent(String roleName) {
    return 'Are you sure you want to delete $roleName? \nThis will remove this role from all users and profiles.';
  }

  @override
  String get dialogDeleteProfileTitle => 'Delete Profile?';

  @override
  String dialogDeleteProfileContent(String profileName) {
    return 'Are you sure you want to delete $profileName? This action cannot be undone.';
  }

  @override
  String get dialogDeleteAutomationTitle => 'Delete Automation?';

  @override
  String get dialogDeleteAutomationContent =>
      'Are you sure you want to delete this automation?';

  @override
  String get stateLoading => 'Loading...';

  @override
  String stateError(String error) {
    return 'Error: $error';
  }

  @override
  String get tooltipEdit => 'Edit';

  @override
  String get tooltipDeactivate => 'Deactivate profile';

  @override
  String get tooltipActivate => 'Set as active';

  @override
  String get tooltipMoreOptions => 'More options';

  @override
  String get noAutomationsConfigured => 'No automations configured';

  @override
  String get triggerOnNewFriend => 'On New Friend';

  @override
  String triggerHasTag(String tagName) {
    return 'Has Tag $tagName';
  }

  @override
  String automationAssigns(String roles) {
    return 'Assigns: $roles';
  }

  @override
  String get logsHeader => 'Automation Logs';

  @override
  String get logsSearchHint => 'Search by name or rule...';

  @override
  String get logsEmpty => 'No logs found';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '${minutes}m ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '${hours}h ago';
  }

  @override
  String timeDaysAgo(int days) {
    return '${days}d ago';
  }

  @override
  String get actionAccepted => 'ACCEPTED';

  @override
  String get actionRejected => 'REJECTED';

  @override
  String get tabInvite => 'INVITE';

  @override
  String get tabRequest => 'REQUEST';

  @override
  String get messageTypeInvite => 'Invite';

  @override
  String get messageTypeResponse => 'Response';

  @override
  String get messageTypeRequest => 'Request';

  @override
  String get messageTypeRequestResponse => 'Request Response';

  @override
  String get tabResponse => 'Response';

  @override
  String get tabReqResponse => 'Request Response';

  @override
  String get liveSlotsHeader => 'Live VRChat Slots';

  @override
  String get tooltipSyncFromVrc => 'Sync with VRChat';

  @override
  String get messageLibraryHeader => 'Message Library';

  @override
  String get tooltipAddMessage => 'Add Message';

  @override
  String get libraryEmpty => 'No messages in the library';

  @override
  String get unassignedMessagesHeader => 'UNASSIGNED MESSAGES';

  @override
  String get assignedMessagesHeader => 'ASSIGNED TO LIVE SLOTS';

  @override
  String dialogNewMessageTitle(String type) {
    return 'New $type Message';
  }

  @override
  String get dialogNewMessageDesc =>
      'This message will be saved to your library and can be assigned to automation rules.';

  @override
  String get inputMessageHint => 'Enter your message...';

  @override
  String get inputMessageLabel => 'Message';

  @override
  String get btnCreateMessage => 'Create Message';

  @override
  String toastMessageAdded(String type) {
    return '$type message added to the library';
  }

  @override
  String messageSlotLabel(int index) {
    return 'Slot $index';
  }

  @override
  String slotPickerTitle(String content) {
    return 'Assign $content to a Slot';
  }

  @override
  String slotPickerCategory(String category) {
    return 'Category: $category';
  }

  @override
  String get friendsHeader => 'Friends';

  @override
  String get tooltipRefreshFriends => 'Refresh Friends';

  @override
  String get searchFriendsHint => 'Search friends...';

  @override
  String get noFriendsFound => 'No friends found';

  @override
  String get presenceOnline => 'Online';

  @override
  String get presenceOffline => 'Offline';

  @override
  String get presenceActiveWebsite => 'Active on the Website';

  @override
  String get presenceTraveling => 'Traveling...';

  @override
  String get presencePrivateInstance => 'Private Instance';

  @override
  String presenceInstanceDesc(String accessType, String region) {
    return '$accessType Instance ($region)';
  }

  @override
  String get categoryFavorites => 'Favorites';

  @override
  String get categorySameInstance => 'Same Instance';

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
  String get accessUnknown => 'Unknown';

  @override
  String get editProfileTitle => 'Edit Profile';

  @override
  String get dialogUnsavedTitle => 'Unsaved Changes';

  @override
  String get dialogUnsavedContent =>
      'You have unsaved changes. Do you want to save them before leaving?';

  @override
  String get btnDiscard => 'Discard';

  @override
  String get btnSave => 'Save';

  @override
  String get btnSaveChanges => 'Save Changes';

  @override
  String get sectionProfileSettings => 'Profile Settings';

  @override
  String get inputProfileName => 'Profile Name';

  @override
  String get sectionActions => 'Actions';

  @override
  String get priorityRulesCaption =>
      'Rules with higher priority are evaluated first.';

  @override
  String get sectionAutomationRules => 'Automation Rules';

  @override
  String get tooltipRemoveRule => 'Remove Rule';

  @override
  String get contextOnInviteReceived => 'ON INVITE RECEIVED';

  @override
  String get contextOnRequestToJoin => 'ON REQUEST TO JOIN';

  @override
  String get defaultVrcMessage => 'Default VRChat Message';

  @override
  String dialogSelectMessage(String category) {
    return 'Select $category';
  }

  @override
  String get defaultMessageOption => 'Use Default VRChat Message';

  @override
  String get defaultMessageOptionDesc =>
      'Use VRChat\'s default notification message.';

  @override
  String get btnAddRoleRule => 'Add Role Rule';

  @override
  String get searchRolesHint => 'Search roles...';

  @override
  String get sectionFallbackTags => 'Fallback Tags';

  @override
  String get fallbackTagsDesc => 'Applied when no role matches.';

  @override
  String get btnAddTag => 'Add Tag';

  @override
  String get searchTagsHint => 'Search tags or languages...';

  @override
  String get fallbackTagActionDisabled => 'DISABLED';

  @override
  String get fallbackTagActionAccept => 'ACCEPT';

  @override
  String get fallbackTagActionReject => 'REJECT';

  @override
  String get newAutomationTitle => 'New Automation';

  @override
  String get editAutomationTitle => 'Edit Automation';

  @override
  String get sectionCondition => 'Condition';

  @override
  String get triggerNewFriendTitle => 'On Any New Friend';

  @override
  String get triggerNewFriendDesc =>
      'Assign default roles to every new friend.';

  @override
  String get triggerHasTagTitle => 'Has Specific Tag';

  @override
  String get triggerHasTagDesc =>
      'Assign roles only if the user has the selected profile tag.';

  @override
  String get targetTagHeader => 'Target Tag';

  @override
  String get tagRequired => 'Required';

  @override
  String get tagSelected => 'Selected Tag';

  @override
  String get tagSelectPlaceholder => 'Select a tag...';

  @override
  String get searchTagsVrcHint => 'Search VRChat tags...';

  @override
  String get sectionAssignRoles => 'Assign Roles';

  @override
  String get btnAddRole => 'Add Role';

  @override
  String get noRolesSelectedWarning => 'You must assign at least one role.';

  @override
  String get searchLocalRolesHint => 'Search local roles...';

  @override
  String get tooltipRemoveRole => 'Remove Role';

  @override
  String get editRoleTitle => 'Edit Role';

  @override
  String get errorNameInUseTitle => 'Name Already Exists';

  @override
  String get inputRoleName => 'Role Name';

  @override
  String get sectionAppRoles => 'App Roles';

  @override
  String get sectionVrcTagsReadOnly => 'VRChat Tags (Read Only)';

  @override
  String get errorLoadingRoles => 'Failed to load roles';

  @override
  String get noRulesAdded =>
      'No rules added yet.\nClick \'Add role rule\' to start.';

  @override
  String get errorLoadingMessages => 'Error loading messages';

  @override
  String get ruleActionAccept => 'Accept';

  @override
  String get ruleActionReject => 'Reject';

  @override
  String get searchPlaceholder => 'Search...';

  @override
  String get noItemsMatchSearch => 'No items match your search';

  @override
  String get btnOk => 'OK';

  @override
  String get tooltipShowPassword => 'Show password';

  @override
  String get tooltipHidePassword => 'Hide password';

  @override
  String get logNoRuleMatched => 'No matching rule applied';

  @override
  String logRuleMatched(String roleName) {
    return 'Matched rule for $roleName';
  }

  @override
  String get bgNotificationTitle => 'VRCMA Processed';

  @override
  String get bgInitialNotificationTitle => 'VRCMA Automation';

  @override
  String get bgInitialNotificationContent => 'Running in background...';

  @override
  String bgNotificationContent(String senderName) {
    return 'Last: $senderName';
  }

  @override
  String get sectionStatusAutomation => 'Status Automation';

  @override
  String get dialogNewStatusProfileTitle => 'New Status Profile';

  @override
  String get dialogNewStatusProfileLabel => 'Profile Name';

  @override
  String get editStatusProfileTitle => 'Edit Status Profile';

  @override
  String get sectionGeneralSettings => 'General Settings';

  @override
  String get inputStatusProfileName => 'Profile Name';

  @override
  String get inputFallbackStatus => 'Fallback Status';

  @override
  String get inputFallbackTemplate => 'Fallback Message Template';

  @override
  String get statusPriorityRulesCaption =>
      'Use templates such as: In {{world}} ({{battery}}🔋)\nStatus rules are evaluated from top to bottom by priority.';

  @override
  String get sectionAutomationConditions => 'Automation Conditions';

  @override
  String get btnAddConditionRule => 'Add Condition Rule';

  @override
  String get noStatusRulesAdded =>
      'No dynamic status rules configured.\nThis profile will always use the fallback configuration.';

  @override
  String get rulesReorderSubtitle => 'Rules (Drag to Reorder)';

  @override
  String get dialogNewStatusRuleTitle => 'New Status Rule';

  @override
  String get inputTriggerCondition => 'Trigger Condition';

  @override
  String get inputOperator => 'Operator';

  @override
  String get inputComparisonValue => 'Comparison Value';

  @override
  String get inputTargetStatus => 'Target Status';

  @override
  String get inputStatusMessageTemplate => 'Status Message Template';

  @override
  String get btnCreateRule => 'Create Rule';

  @override
  String statusProfileSubtitle(int count, String fallback) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count rules',
      one: '1 rule',
    );
    return '$_temp0, fallback: $fallback';
  }

  @override
  String get tooltipEditStatusProfile => 'Edit Status Profile';

  @override
  String get dialogDeleteStatusProfileTitle => 'Delete Status Profile';

  @override
  String dialogDeleteStatusProfileContent(String name) {
    return 'Are you sure you want to delete \'$name\'?';
  }

  @override
  String get statusRuleComparisonHint => 'e.g. 5, Public, 30';

  @override
  String get statusMessageTemplateHint => 'e.g. In {{world}} with {{friends}}';

  @override
  String get statusRuleNoMessage => 'No Message';

  @override
  String get statusTypeActive => 'Active';

  @override
  String get statusTypeJoinMe => 'Join Me';

  @override
  String get statusTypeAskMe => 'Ask Me';

  @override
  String get statusTypeBusy => 'Busy';

  @override
  String get conditionTypePopulation => 'Player Count';

  @override
  String get conditionTypeInstanceType => 'Instance Access';

  @override
  String get conditionTypeBatteryLevel => 'Battery Level';

  @override
  String get conditionTypeFriendPresent => 'Friend Present';

  @override
  String get conditionTypeTimeRange => 'Time Range';

  @override
  String get conditionTypeWorld => 'Current World';

  @override
  String get operatorGreaterThan => 'Greater Than';

  @override
  String get operatorLessThan => 'Less Than';

  @override
  String get operatorEqualTo => 'Equals';

  @override
  String get operatorContains => 'Contains';

  @override
  String get operatorBetween => 'Between';

  @override
  String get statusRuleComparisonHintNumber => 'e.g. 50';

  @override
  String get statusRuleComparisonHintRange => 'e.g. 20-80';

  @override
  String get statusRuleComparisonHintTimeRange => 'e.g. 22:00-06:00';

  @override
  String get statusRuleComparisonHintWorldList => 'e.g. wrld_abc, wrld_def';

  @override
  String get statusOverrideNotification =>
      'Automation paused. Your VRChat status was changed manually.';

  @override
  String get themeModeLabel => 'Theme Mode';

  @override
  String get themeModeSystem => 'System Default';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get languageLabel => 'Language';

  @override
  String get diagnosticTitle => 'Diagnostics & Data';

  @override
  String get clearCacheLabel => 'Clear Metadata Cache';

  @override
  String get clearCacheDesc =>
      'Force refresh cached world names and avatar images.';

  @override
  String get toastCacheCleared => 'Metadata cache cleared successfully.';

  @override
  String get rolesManagementTitle => 'Manage Roles';

  @override
  String get rolesManagementDesc =>
      'Create and manage custom categories for your friends.';

  @override
  String get automationManagementDesc =>
      'Create automation rules based on friends, roles, or other conditions.';

  @override
  String get dashboardHeader => 'Control Room';

  @override
  String get dashboardSubheader =>
      'Manage active filters and status automation profiles.';

  @override
  String get clearCachesBtn => 'Clear Cache';

  @override
  String get defaultMessageCustomOption => 'No Custom Message';

  @override
  String get defaultMessageCustomOptionDesc =>
      'Use the default status message without applying a custom template.';

  @override
  String get themeLabel => 'Theme';

  @override
  String get toastLocaleChanged => 'Language changed successfully.';

  @override
  String get systemLogsTitle => 'System Logs';

  @override
  String get themeSeedColorLabel => 'Accent Color';

  @override
  String get noProfilesAdded => 'No filter profiles added yet.';

  @override
  String get nativeBackgroundRuntimeFail =>
      'Native background runtime initialization failed.';

  @override
  String get automationTriggerNewFriend => 'On New Friend Added';

  @override
  String automationTriggerTag(String tag) {
    return 'Matching Tag: $tag';
  }

  @override
  String automationAssignsRoles(String roles) {
    return 'Assigns: $roles';
  }

  @override
  String get colorDeepPurple => 'Deep Purple';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorRose => 'Rose';
}
