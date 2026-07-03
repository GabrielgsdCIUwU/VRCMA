import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'arb/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The main branding/application title displayed at the top of the login header screen.
  ///
  /// In en, this message translates to:
  /// **'VRCMA'**
  String get loginTitle;

  /// Input field label prompting the user for their VRChat username or registered email address.
  ///
  /// In en, this message translates to:
  /// **'Username or Email'**
  String get usernameLabel;

  /// Input field label prompting the user to enter their account password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Text displayed on the primary action button to submit credentials on the login form.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginButton;

  /// Header title instructing the user to type in their two-factor authentication security code.
  ///
  /// In en, this message translates to:
  /// **'Enter 2FA Code'**
  String get enter2faTitle;

  /// Input field placeholder/label specifically designated for entering the 6-digit security token.
  ///
  /// In en, this message translates to:
  /// **'6-Digit Code'**
  String get digitCodeLabel;

  /// Action button text to submit and validate the entered 2FA security code.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verifyButton;

  /// Button label used to dismiss the 2FA screen and navigate back to the credentials form.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backButton;

  /// Success message displayed to the user via SnackBar upon a verified and successful login.
  ///
  /// In en, this message translates to:
  /// **'Login Success!'**
  String get loginSuccess;

  /// Error message shown when a network request to the VRChat servers times out.
  ///
  /// In en, this message translates to:
  /// **'Connection timeout. Check your internet connection'**
  String get connectionTimeout;

  /// A generic error wrapper when an unhandled or system-specific error occurs.
  ///
  /// In en, this message translates to:
  /// **'Unexpected error: {error}'**
  String unexpectedError(String error);

  /// Label for the configuration/settings tab in the main navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Config'**
  String get navConfig;

  /// Label for the message templates management tab in the main navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get navMessages;

  /// Label for the automation execution logs tab in the main navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get navLogs;

  /// Label for the friends list and category mapping tab in the main navigation bar.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get navFriends;

  /// Tab title inside the main workspace split view displaying live slots and template libraries.
  ///
  /// In en, this message translates to:
  /// **'Messages & Slots'**
  String get workspaceTabMessages;

  /// Tab title inside the main workspace split view displaying processed automation histories.
  ///
  /// In en, this message translates to:
  /// **'Automation Logs'**
  String get workspaceTabLogs;

  /// Header title for the Profiles configuration section.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get sectionProfiles;

  /// Header title for the local security Roles configuration section.
  ///
  /// In en, this message translates to:
  /// **'Roles'**
  String get sectionRoles;

  /// Header title for the automated role assignment rules section.
  ///
  /// In en, this message translates to:
  /// **'Friend Automations'**
  String get sectionFriendAutomations;

  /// Label for the settings toggle that activates background automated processing.
  ///
  /// In en, this message translates to:
  /// **'Background Automation'**
  String get bgAutomationTitle;

  /// Explanatory subtitle describing the utility of enabling background automation.
  ///
  /// In en, this message translates to:
  /// **'Keep processing invites when app is closed'**
  String get bgAutomationDesc;

  /// Title for the modal dialog to create a new filter profile.
  ///
  /// In en, this message translates to:
  /// **'New Profile'**
  String get dialogNewProfileTitle;

  /// Form input field label prompting for a profile name.
  ///
  /// In en, this message translates to:
  /// **'Profile name'**
  String get dialogNewProfileLabel;

  /// Title for the modal dialog to create a new local security role.
  ///
  /// In en, this message translates to:
  /// **'New Role'**
  String get dialogNewRoleTitle;

  /// Form input field label prompting for a role name.
  ///
  /// In en, this message translates to:
  /// **'Role name'**
  String get dialogNewRoleLabel;

  /// Standard action text for canceling and discarding changes on dialogs.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get btnCancel;

  /// Standard action text for creating and saving a newly defined resource.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get btnCreate;

  /// Standard action text to confirm the deletion of a resource.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get btnDelete;

  /// Displays the total number of friends mapped to a specific role.
  ///
  /// In en, this message translates to:
  /// **'{count} members'**
  String roleMembersCount(int count);

  /// Label displaying the count of criteria rules inside a profile.
  ///
  /// In en, this message translates to:
  /// **'{count} automation rules'**
  String profileRulesCount(int count);

  /// Header title for the role removal confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete Role?'**
  String get dialogDeleteRoleTitle;

  /// Warning reminding the user of the consequences of role deletion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{roleName}\'? \nThis will remove this role from all users and profiles.'**
  String dialogDeleteRoleContent(String roleName);

  /// Header title for the profile removal confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile?'**
  String get dialogDeleteProfileTitle;

  /// Warning informing the user that profile deletion is permanent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'{profileName}\'? This action cannot be undone.'**
  String dialogDeleteProfileContent(String profileName);

  /// Header title for deleting an automatic role mapper rule.
  ///
  /// In en, this message translates to:
  /// **'Delete Automation?'**
  String get dialogDeleteAutomationTitle;

  /// Warning label inside the role automation deletion modal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this automation?'**
  String get dialogDeleteAutomationContent;

  /// Generic fallback loader message.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get stateLoading;

  /// Generic standard error rendering block.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String stateError(String error);

  /// Tooltip shown on standard inline editing pencil icons.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get tooltipEdit;

  /// Label indicating click will switch off the active configuration profile.
  ///
  /// In en, this message translates to:
  /// **'Deactivate profile'**
  String get tooltipDeactivate;

  /// Label indicating click will activate this specific configuration profile.
  ///
  /// In en, this message translates to:
  /// **'Set as active'**
  String get tooltipActivate;

  /// Tooltip label for standard three-dot vertical popup menus.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get tooltipMoreOptions;

  /// Placeholder shown when the automations database list is empty.
  ///
  /// In en, this message translates to:
  /// **'No automations configured'**
  String get noAutomationsConfigured;

  /// Title for automatic mappings triggered during the first-time hand-shake friendship update.
  ///
  /// In en, this message translates to:
  /// **'On New Friend'**
  String get triggerOnNewFriend;

  /// Label for automatic mappings triggered when a friend holds a specific VRChat profile tag.
  ///
  /// In en, this message translates to:
  /// **'Has Tag {tagName}'**
  String triggerHasTag(String tagName);

  /// List indicating local roles mapped upon trigger execution.
  ///
  /// In en, this message translates to:
  /// **'Assigns: {roles}'**
  String automationAssigns(String roles);

  /// Header title displayed at the top of the automation execution history panel.
  ///
  /// In en, this message translates to:
  /// **'Automation Logs'**
  String get logsHeader;

  /// Search input box placeholder text for filtering processing logs.
  ///
  /// In en, this message translates to:
  /// **'Search by name or rule...'**
  String get logsSearchHint;

  /// Information text shown when the search query returns zero matching records.
  ///
  /// In en, this message translates to:
  /// **'No logs found'**
  String get logsEmpty;

  /// Relative time indicator for actions that happened less than a minute ago.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// Relative time indicator showing elapsed minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m ago'**
  String timeMinutesAgo(int minutes);

  /// Relative time indicator showing elapsed hours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h ago'**
  String timeHoursAgo(int hours);

  /// Relative time indicator showing elapsed days.
  ///
  /// In en, this message translates to:
  /// **'{days}d ago'**
  String timeDaysAgo(int days);

  /// Status badge label indicating an invite or join request was auto-approved.
  ///
  /// In en, this message translates to:
  /// **'ACCEPTED'**
  String get actionAccepted;

  /// Status badge label indicating an invite or join request was auto-declined.
  ///
  /// In en, this message translates to:
  /// **'REJECTED'**
  String get actionRejected;

  /// Category label for invitations.
  ///
  /// In en, this message translates to:
  /// **'INVITE'**
  String get tabInvite;

  /// Category label for requests.
  ///
  /// In en, this message translates to:
  /// **'REQUEST'**
  String get tabRequest;

  /// Noun representing an invitation notification type.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get messageTypeInvite;

  /// Noun representing a response notification type.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get messageTypeResponse;

  /// Noun representing a request-to-join notification type.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get messageTypeRequest;

  /// Noun representing a response to a request-to-join notification type.
  ///
  /// In en, this message translates to:
  /// **'Request Response'**
  String get messageTypeRequestResponse;

  /// Category tab for message templates automatically sent in response to an incoming invite.
  ///
  /// In en, this message translates to:
  /// **'Response'**
  String get tabResponse;

  /// Category tab for message templates automatically sent in response to a request-to-join.
  ///
  /// In en, this message translates to:
  /// **'Request Response'**
  String get tabReqResponse;

  /// Section header displaying the currently assigned VRChat live message slots available on the server.
  ///
  /// In en, this message translates to:
  /// **'Live VRChat Slots'**
  String get liveSlotsHeader;

  /// Tooltip shown on the synchronization button that downloads the latest live slot configuration from VRChat.
  ///
  /// In en, this message translates to:
  /// **'Sync with VRChat'**
  String get tooltipSyncFromVrc;

  /// Header for the local library containing all saved message templates.
  ///
  /// In en, this message translates to:
  /// **'Message Library'**
  String get messageLibraryHeader;

  /// Tooltip shown on the button used to create a new message template.
  ///
  /// In en, this message translates to:
  /// **'Add Message'**
  String get tooltipAddMessage;

  /// Placeholder displayed when the selected message library contains no saved templates.
  ///
  /// In en, this message translates to:
  /// **'No messages in the library'**
  String get libraryEmpty;

  /// Section title grouping message templates that are not currently assigned to any live VRChat slot.
  ///
  /// In en, this message translates to:
  /// **'UNASSIGNED MESSAGES'**
  String get unassignedMessagesHeader;

  /// Section title grouping message templates currently assigned to one of the active VRChat live slots.
  ///
  /// In en, this message translates to:
  /// **'ASSIGNED TO LIVE SLOTS'**
  String get assignedMessagesHeader;

  /// Dialog title displayed when creating a new message template.
  ///
  /// In en, this message translates to:
  /// **'New {type} Message'**
  String dialogNewMessageTitle(String type);

  /// Helper text explaining what happens after creating a new message template.
  ///
  /// In en, this message translates to:
  /// **'This message will be saved to your library and can be assigned to automation rules.'**
  String get dialogNewMessageDesc;

  /// Placeholder text displayed inside the message editor before any content is entered.
  ///
  /// In en, this message translates to:
  /// **'Enter your message...'**
  String get inputMessageHint;

  /// Label for the text field where the message template content is written.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get inputMessageLabel;

  /// Primary button used to save a newly created message template.
  ///
  /// In en, this message translates to:
  /// **'Create Message'**
  String get btnCreateMessage;

  /// Confirmation message displayed after successfully creating a new message template.
  ///
  /// In en, this message translates to:
  /// **'{type} message added to the library'**
  String toastMessageAdded(String type);

  /// Label identifying one of the available VRChat live message slots.
  ///
  /// In en, this message translates to:
  /// **'Slot {index}'**
  String messageSlotLabel(int index);

  /// Dialog title prompting the user to select the live VRChat slot where the message template will be assigned.
  ///
  /// In en, this message translates to:
  /// **'Assign \'{content}\' to a Slot'**
  String slotPickerTitle(String content);

  /// Displays the message category currently being assigned in the slot selection dialog.
  ///
  /// In en, this message translates to:
  /// **'Category: {category}'**
  String slotPickerCategory(String category);

  /// Header title displayed at the top of the friends management panel.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get friendsHeader;

  /// Tooltip shown on the refresh button used to reload the friends list from VRChat.
  ///
  /// In en, this message translates to:
  /// **'Refresh Friends'**
  String get tooltipRefreshFriends;

  /// Placeholder text displayed in the search field used to filter the friends list.
  ///
  /// In en, this message translates to:
  /// **'Search friends...'**
  String get searchFriendsHint;

  /// Placeholder shown when no friends match the current search or filter.
  ///
  /// In en, this message translates to:
  /// **'No friends found'**
  String get noFriendsFound;

  /// Presence status indicating that the friend is currently online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get presenceOnline;

  /// Presence status indicating that the friend is currently offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get presenceOffline;

  /// Presence status indicating that the friend is currently using the VRChat website instead of the game client.
  ///
  /// In en, this message translates to:
  /// **'Active on the Website'**
  String get presenceActiveWebsite;

  /// Presence status displayed while the friend is transitioning between VRChat worlds.
  ///
  /// In en, this message translates to:
  /// **'Traveling...'**
  String get presenceTraveling;

  /// Presence status displayed when the friend's current world instance cannot be joined.
  ///
  /// In en, this message translates to:
  /// **'Private Instance'**
  String get presencePrivateInstance;

  /// Displays the access type and server region of the friend's current VRChat instance.
  ///
  /// In en, this message translates to:
  /// **'{accessType} Instance ({region})'**
  String presenceInstanceDesc(String accessType, String region);

  /// Header for the favorites friends category.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get categoryFavorites;

  /// Header grouping friends currently in the same VRChat instance as the user.
  ///
  /// In en, this message translates to:
  /// **'Same Instance'**
  String get categorySameInstance;

  /// Official VRChat instance access type: Public.
  ///
  /// In en, this message translates to:
  /// **'Public'**
  String get accessPublic;

  /// Official VRChat instance access type: Invite Only.
  ///
  /// In en, this message translates to:
  /// **'Invite Only'**
  String get accessInviteOnly;

  /// Official VRChat instance access type: Invite+.
  ///
  /// In en, this message translates to:
  /// **'Invite+'**
  String get accessInvitePlus;

  /// Official VRChat instance access type: Friends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get accessFriends;

  /// Official VRChat instance access type: Friends+.
  ///
  /// In en, this message translates to:
  /// **'Friends+'**
  String get accessFriendsPlus;

  /// Official VRChat instance access type: Group.
  ///
  /// In en, this message translates to:
  /// **'Group'**
  String get accessGroup;

  /// Official VRChat instance access type: Group+.
  ///
  /// In en, this message translates to:
  /// **'Group+'**
  String get accessGroupPlus;

  /// Official VRChat instance access type: Group Public.
  ///
  /// In en, this message translates to:
  /// **'Group Public'**
  String get accessGroupPublic;

  /// Fallback access type displayed when the instance visibility cannot be determined.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get accessUnknown;

  /// App bar title displayed while editing an existing profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// Confirmation dialog title shown when leaving an editor with unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get dialogUnsavedTitle;

  /// Confirmation message asking whether to save or discard pending changes before exiting the editor.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Do you want to save them before leaving?'**
  String get dialogUnsavedContent;

  /// Button that discards all unsaved changes.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get btnDiscard;

  /// Standard button used to save the current changes.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get btnSave;

  /// Primary button used to save all modifications before closing the editor.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get btnSaveChanges;

  /// Section header containing the main profile configuration.
  ///
  /// In en, this message translates to:
  /// **'Profile Settings'**
  String get sectionProfileSettings;

  /// Label for the text field where the profile name is entered.
  ///
  /// In en, this message translates to:
  /// **'Profile Name'**
  String get inputProfileName;

  /// Section header grouping profile-related actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get sectionActions;

  /// Helper text explaining the execution order of automation rules.
  ///
  /// In en, this message translates to:
  /// **'Rules with higher priority are evaluated first.'**
  String get priorityRulesCaption;

  /// Section header containing the list of automation rules assigned to the profile.
  ///
  /// In en, this message translates to:
  /// **'Automation Rules'**
  String get sectionAutomationRules;

  /// Tooltip shown on the button that removes an automation rule.
  ///
  /// In en, this message translates to:
  /// **'Remove Rule'**
  String get tooltipRemoveRule;

  /// Label indicating rules triggered when receiving a VRChat invite.
  ///
  /// In en, this message translates to:
  /// **'ON INVITE RECEIVED'**
  String get contextOnInviteReceived;

  /// Label indicating rules triggered when receiving a request-to-join.
  ///
  /// In en, this message translates to:
  /// **'ON REQUEST TO JOIN'**
  String get contextOnRequestToJoin;

  /// Label representing the default notification message provided by VRChat.
  ///
  /// In en, this message translates to:
  /// **'Default VRChat Message'**
  String get defaultVrcMessage;

  /// Dialog title prompting the user to choose a message template.
  ///
  /// In en, this message translates to:
  /// **'Select {category}'**
  String dialogSelectMessage(String category);

  /// Option that keeps VRChat's original notification message instead of using a custom template.
  ///
  /// In en, this message translates to:
  /// **'Use Default VRChat Message'**
  String get defaultMessageOption;

  /// Description explaining the default message option.
  ///
  /// In en, this message translates to:
  /// **'Use VRChat\'s default notification message.'**
  String get defaultMessageOptionDesc;

  /// Button used to add a new role rule to the profile.
  ///
  /// In en, this message translates to:
  /// **'Add Role Rule'**
  String get btnAddRoleRule;

  /// Placeholder displayed while searching available roles.
  ///
  /// In en, this message translates to:
  /// **'Search roles...'**
  String get searchRolesHint;

  /// Section containing fallback tag rules used when no role matches.
  ///
  /// In en, this message translates to:
  /// **'Fallback Tags'**
  String get sectionFallbackTags;

  /// Helper text explaining when fallback tags are evaluated.
  ///
  /// In en, this message translates to:
  /// **'Applied when no role matches.'**
  String get fallbackTagsDesc;

  /// Button used to add a fallback tag.
  ///
  /// In en, this message translates to:
  /// **'Add Tag'**
  String get btnAddTag;

  /// Placeholder displayed while searching VRChat tags or language tags.
  ///
  /// In en, this message translates to:
  /// **'Search tags or languages...'**
  String get searchTagsHint;

  /// Automation action indicating that no automatic response will be performed.
  ///
  /// In en, this message translates to:
  /// **'DISABLED'**
  String get fallbackTagActionDisabled;

  /// Automation action indicating that the invite or request will be accepted automatically.
  ///
  /// In en, this message translates to:
  /// **'ACCEPT'**
  String get fallbackTagActionAccept;

  /// Automation action indicating that the invite or request will be rejected automatically.
  ///
  /// In en, this message translates to:
  /// **'REJECT'**
  String get fallbackTagActionReject;

  /// App bar title displayed while creating a new automation.
  ///
  /// In en, this message translates to:
  /// **'New Automation'**
  String get newAutomationTitle;

  /// App bar title displayed while editing an existing automation.
  ///
  /// In en, this message translates to:
  /// **'Edit Automation'**
  String get editAutomationTitle;

  /// Section header containing the automation trigger conditions.
  ///
  /// In en, this message translates to:
  /// **'Condition'**
  String get sectionCondition;

  /// Condition that matches every newly added friend.
  ///
  /// In en, this message translates to:
  /// **'On Any New Friend'**
  String get triggerNewFriendTitle;

  /// Description of the new friend automation trigger.
  ///
  /// In en, this message translates to:
  /// **'Assign default roles to every new friend.'**
  String get triggerNewFriendDesc;

  /// Condition that matches users with a specific VRChat profile tag.
  ///
  /// In en, this message translates to:
  /// **'Has Specific Tag'**
  String get triggerHasTagTitle;

  /// Description of the profile tag automation trigger.
  ///
  /// In en, this message translates to:
  /// **'Assign roles only if the user has the selected profile tag.'**
  String get triggerHasTagDesc;

  /// Section header for selecting the required VRChat profile tag.
  ///
  /// In en, this message translates to:
  /// **'Target Tag'**
  String get targetTagHeader;

  /// Label indicating that selecting a tag is mandatory.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get tagRequired;

  /// Label displaying the currently selected VRChat tag.
  ///
  /// In en, this message translates to:
  /// **'Selected Tag'**
  String get tagSelected;

  /// Placeholder shown before a VRChat tag has been selected.
  ///
  /// In en, this message translates to:
  /// **'Select a tag...'**
  String get tagSelectPlaceholder;

  /// Placeholder displayed while searching VRChat profile tags.
  ///
  /// In en, this message translates to:
  /// **'Search VRChat tags...'**
  String get searchTagsVrcHint;

  /// Section header listing the roles assigned when the automation is triggered.
  ///
  /// In en, this message translates to:
  /// **'Assign Roles'**
  String get sectionAssignRoles;

  /// Button used to assign another role.
  ///
  /// In en, this message translates to:
  /// **'Add Role'**
  String get btnAddRole;

  /// Validation message shown when attempting to save without assigning any roles.
  ///
  /// In en, this message translates to:
  /// **'You must assign at least one role.'**
  String get noRolesSelectedWarning;

  /// Placeholder displayed while searching local application roles.
  ///
  /// In en, this message translates to:
  /// **'Search local roles...'**
  String get searchLocalRolesHint;

  /// Tooltip shown on the button that removes an assigned role.
  ///
  /// In en, this message translates to:
  /// **'Remove Role'**
  String get tooltipRemoveRole;

  /// App bar title displayed while editing a local role.
  ///
  /// In en, this message translates to:
  /// **'Edit Role'**
  String get editRoleTitle;

  /// Error shown when attempting to save a role or profile with a duplicate name.
  ///
  /// In en, this message translates to:
  /// **'Name Already Exists'**
  String get errorNameInUseTitle;

  /// Label for the text field where the role name is entered.
  ///
  /// In en, this message translates to:
  /// **'Role Name'**
  String get inputRoleName;

  /// Section listing all local roles assigned to the selected friend.
  ///
  /// In en, this message translates to:
  /// **'App Roles'**
  String get sectionAppRoles;

  /// Section displaying the friend's VRChat profile tags. These values cannot be edited.
  ///
  /// In en, this message translates to:
  /// **'VRChat Tags (Read Only)'**
  String get sectionVrcTagsReadOnly;

  /// Error message displayed when local roles cannot be loaded from storage.
  ///
  /// In en, this message translates to:
  /// **'Failed to load roles'**
  String get errorLoadingRoles;

  /// Placeholder text displayed when a profile has an empty criteria rules list.
  ///
  /// In en, this message translates to:
  /// **'No rules added yet.\nClick \'Add role rule\' to start.'**
  String get noRulesAdded;

  /// Text rendered when the message database fails to load inside criteria selectors.
  ///
  /// In en, this message translates to:
  /// **'Error loading messages'**
  String get errorLoadingMessages;

  /// Text representing the automated accept action in rule dropdowns.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get ruleActionAccept;

  /// Text representing the automated reject action in rule dropdowns.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get ruleActionReject;

  /// Standard placeholder displayed in search input fields.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchPlaceholder;

  /// Information message shown when a search in a dialog or bottom sheet returns no matching results.
  ///
  /// In en, this message translates to:
  /// **'No items match your search'**
  String get noItemsMatchSearch;

  /// Standard confirmation button label used to acknowledge and close dialogs or alerts.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get btnOk;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
