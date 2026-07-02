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
    return 'Are you sure you want to delete \'$roleName\'? \nThis will remove this role from all users and profiles.';
  }

  @override
  String get dialogDeleteProfileTitle => 'Delete Profile?';

  @override
  String dialogDeleteProfileContent(String profileName) {
    return 'Are you sure you want to delete \'$profileName\'? This action cannot be undone.';
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
    return 'Assign \'$content\' to a Slot';
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
}
