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
  /// **'Are you sure you want to delete {roleName}? \nThis will remove this role from all users and profiles.'**
  String dialogDeleteRoleContent(String roleName);

  /// Header title for the profile removal confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile?'**
  String get dialogDeleteProfileTitle;

  /// Warning informing the user that profile deletion is permanent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {profileName}? This action cannot be undone.'**
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
  /// **'Invite'**
  String get tabInvite;

  /// Category label for requests.
  ///
  /// In en, this message translates to:
  /// **'Request'**
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
  /// **'Assign {content} to a Slot'**
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
  /// **'Use VRChat\'\'s default notification message.'**
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
  /// **'No rules added yet.\nClick \'\'Add role rule\'\' to start.'**
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

  /// Tooltip shown on the visibility icon to reveal the password in plain text.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get tooltipShowPassword;

  /// Tooltip shown on the visibility icon to hide the password.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get tooltipHidePassword;

  /// Log message written when no automation rule matches the evaluated item or profile.
  ///
  /// In en, this message translates to:
  /// **'No matching rule applied'**
  String get logNoRuleMatched;

  /// Log message prefix written when an automation rule matches an evaluated item or profile
  ///
  /// In en, this message translates to:
  /// **'Matched rule for {roleName}'**
  String logRuleMatched(String roleName);

  /// Title displayed in the Android foreground service notification while the app is processing events in the background.
  ///
  /// In en, this message translates to:
  /// **'VRCMA Processed'**
  String get bgNotificationTitle;

  /// Title displayed in the Android foreground service notification when the background automation service starts.
  ///
  /// In en, this message translates to:
  /// **'VRCMA Automation'**
  String get bgInitialNotificationTitle;

  /// Initial foreground service notification content shown while the background automation service is starting or waiting for events.
  ///
  /// In en, this message translates to:
  /// **'Running in background...'**
  String get bgInitialNotificationContent;

  /// Foreground service notification content displaying the name of the most recently processed user.
  ///
  /// In en, this message translates to:
  /// **'Last: {senderName}'**
  String bgNotificationContent(String senderName);

  /// Section header for configuring automatic VRChat status profiles.
  ///
  /// In en, this message translates to:
  /// **'Status Automation'**
  String get sectionStatusAutomation;

  /// Title for the dialog used to create a new status automation profile.
  ///
  /// In en, this message translates to:
  /// **'New Status Profile'**
  String get dialogNewStatusProfileTitle;

  /// Input field label prompting the user to enter a name for the new status profile.
  ///
  /// In en, this message translates to:
  /// **'Profile Name'**
  String get dialogNewStatusProfileLabel;

  /// App bar title displayed while editing an existing status profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Status Profile'**
  String get editStatusProfileTitle;

  /// Section header containing the general configuration for the status profile.
  ///
  /// In en, this message translates to:
  /// **'General Settings'**
  String get sectionGeneralSettings;

  /// Label for the text field where the status profile name is entered.
  ///
  /// In en, this message translates to:
  /// **'Profile Name'**
  String get inputStatusProfileName;

  /// Label for the fallback VRChat status applied when no rule matches.
  ///
  /// In en, this message translates to:
  /// **'Fallback Status'**
  String get inputFallbackStatus;

  /// Label for the fallback status message template used when no automation rule matches.
  ///
  /// In en, this message translates to:
  /// **'Fallback Message Template'**
  String get inputFallbackTemplate;

  /// Helper text explaining how status message templates work and how rule priority is evaluated.
  ///
  /// In en, this message translates to:
  /// **'Use templates such as: In \'{{world}} ({{battery}}\'🔋)\nStatus rules are evaluated from top to bottom by priority.'**
  String get statusPriorityRulesCaption;

  /// Section header containing the list of status automation conditions.
  ///
  /// In en, this message translates to:
  /// **'Automation Conditions'**
  String get sectionAutomationConditions;

  /// Button used to create a new status automation condition rule.
  ///
  /// In en, this message translates to:
  /// **'Add Condition Rule'**
  String get btnAddConditionRule;

  /// Placeholder shown when the status profile has no automation rules configured.
  ///
  /// In en, this message translates to:
  /// **'No dynamic status rules configured.\nThis profile will always use the fallback configuration.'**
  String get noStatusRulesAdded;

  /// Subtitle explaining that automation rules can be reordered by dragging.
  ///
  /// In en, this message translates to:
  /// **'Rules (Drag to Reorder)'**
  String get rulesReorderSubtitle;

  /// Title for the dialog used to create a new status automation rule.
  ///
  /// In en, this message translates to:
  /// **'New Status Rule'**
  String get dialogNewStatusRuleTitle;

  /// Label for selecting the condition that triggers the status rule.
  ///
  /// In en, this message translates to:
  /// **'Trigger Condition'**
  String get inputTriggerCondition;

  /// Label for selecting the comparison operator used by the condition.
  ///
  /// In en, this message translates to:
  /// **'Operator'**
  String get inputOperator;

  /// Label for the value compared against the selected trigger condition.
  ///
  /// In en, this message translates to:
  /// **'Comparison Value'**
  String get inputComparisonValue;

  /// Label for selecting the VRChat status that will be applied when the rule matches.
  ///
  /// In en, this message translates to:
  /// **'Target Status'**
  String get inputTargetStatus;

  /// Label for selecting the status message template applied when the rule matches.
  ///
  /// In en, this message translates to:
  /// **'Status Message Template'**
  String get inputStatusMessageTemplate;

  /// Primary action button used to create and save a new status automation rule.
  ///
  /// In en, this message translates to:
  /// **'Create Rule'**
  String get btnCreateRule;

  /// Subtitle displayed beneath a status profile showing the total number of configured rules and the fallback status used when no rule matches.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 rule} other{{count} rules}}, fallback: {fallback}'**
  String statusProfileSubtitle(int count, String fallback);

  /// Tooltip shown on the button used to edit an existing status automation profile.
  ///
  /// In en, this message translates to:
  /// **'Edit Status Profile'**
  String get tooltipEditStatusProfile;

  /// Header title for the status profile deletion confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Delete Status Profile'**
  String get dialogDeleteStatusProfileTitle;

  /// Confirmation message asking the user to verify deletion of the selected status profile.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \'\'{name}\'\'?'**
  String dialogDeleteStatusProfileContent(String name);

  /// Placeholder text showing example comparison values when creating a status automation rule.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5, Public, 30'**
  String get statusRuleComparisonHint;

  /// Placeholder text showing an example status message template with supported variables.
  ///
  /// In en, this message translates to:
  /// **'e.g. In \'{{world}} with {{friends}}\''**
  String get statusMessageTemplateHint;

  /// Placeholder displayed when a status automation rule has no custom message template assigned.
  ///
  /// In en, this message translates to:
  /// **'No Message'**
  String get statusRuleNoMessage;

  /// VRChat online status option. Indicates the user is available.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get statusTypeActive;

  /// VRChat online status option. Indicates friends are encouraged to join the user's current instance.
  ///
  /// In en, this message translates to:
  /// **'Join Me'**
  String get statusTypeJoinMe;

  /// VRChat online status option. Indicates friends should ask for permission before joining.
  ///
  /// In en, this message translates to:
  /// **'Ask Me'**
  String get statusTypeAskMe;

  /// VRChat online status option. Indicates the user does not wish to be disturbed.
  ///
  /// In en, this message translates to:
  /// **'Busy'**
  String get statusTypeBusy;

  /// Rule condition based on the number of players currently in the VRChat instance.
  ///
  /// In en, this message translates to:
  /// **'Player Count'**
  String get conditionTypePopulation;

  /// Rule condition based on the VRChat instance access level (Public, Friends+, Friends, Invite+, Invite, Group, etc.).
  ///
  /// In en, this message translates to:
  /// **'Instance Access'**
  String get conditionTypeInstanceType;

  /// Rule condition based on the battery percentage of the PC or Mobile.
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get conditionTypeBatteryLevel;

  /// Rule condition that checks whether a selected friend is currently present in the same VRChat instance.
  ///
  /// In en, this message translates to:
  /// **'Friend Present'**
  String get conditionTypeFriendPresent;

  /// Rule condition based on whether the current local time falls within the configured time range.
  ///
  /// In en, this message translates to:
  /// **'Time Range'**
  String get conditionTypeTimeRange;

  /// Rule condition based on the VRChat world the user is currently in.
  ///
  /// In en, this message translates to:
  /// **'Current World'**
  String get conditionTypeWorld;

  /// Comparison operator used by a rule. Matches when the value is greater than the comparison value.
  ///
  /// In en, this message translates to:
  /// **'Greater Than'**
  String get operatorGreaterThan;

  /// Comparison operator used by a rule. Matches when the value is less than the comparison value.
  ///
  /// In en, this message translates to:
  /// **'Less Than'**
  String get operatorLessThan;

  /// Comparison operator used by a rule. Matches when both values are equal.
  ///
  /// In en, this message translates to:
  /// **'Equals'**
  String get operatorEqualTo;

  /// Comparison operator used by a rule. Matches when the target value contains the comparison value.
  ///
  /// In en, this message translates to:
  /// **'Contains'**
  String get operatorContains;

  /// Comparison operator used by a rule. Matches when the value falls within the configured range.
  ///
  /// In en, this message translates to:
  /// **'Between'**
  String get operatorBetween;

  /// Placeholder showing an example numeric comparison value for conditions such as battery level or player count.
  ///
  /// In en, this message translates to:
  /// **'e.g. 50'**
  String get statusRuleComparisonHintNumber;

  /// Placeholder showing an example numeric range for the 'Between' comparison operator.
  ///
  /// In en, this message translates to:
  /// **'e.g. 20-80'**
  String get statusRuleComparisonHintRange;

  /// Placeholder showing an example time range in 24-hour format.
  ///
  /// In en, this message translates to:
  /// **'e.g. 22:00-06:00'**
  String get statusRuleComparisonHintTimeRange;

  /// Placeholder showing example VRChat world IDs separated by commas.
  ///
  /// In en, this message translates to:
  /// **'e.g. wrld_abc, wrld_def'**
  String get statusRuleComparisonHintWorldList;

  /// Notification shown when status automation is paused after the user manually changes their VRChat status outside the app.
  ///
  /// In en, this message translates to:
  /// **'Automation paused. Your VRChat status was changed manually.'**
  String get statusOverrideNotification;

  /// Label for the application theme mode setting.
  ///
  /// In en, this message translates to:
  /// **'Theme Mode'**
  String get themeModeLabel;

  /// Theme mode option that follows the operating system's appearance setting.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get themeModeSystem;

  /// Theme mode option that always uses the light theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeModeLight;

  /// Theme mode option that always uses the dark theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeModeDark;

  /// Label for the application language setting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// Section title for diagnostics, logs, and cached application data.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics & Data'**
  String get diagnosticTitle;

  /// Action label used to clear cached metadata such as world names and avatar images.
  ///
  /// In en, this message translates to:
  /// **'Clear Metadata Cache'**
  String get clearCacheLabel;

  /// Description explaining that cached VRChat metadata will be refreshed the next time it is needed.
  ///
  /// In en, this message translates to:
  /// **'Force refresh cached world names and avatar images.'**
  String get clearCacheDesc;

  /// Toast notification displayed after cached metadata has been successfully cleared.
  ///
  /// In en, this message translates to:
  /// **'Metadata cache cleared successfully.'**
  String get toastCacheCleared;

  /// Title for the roles management section.
  ///
  /// In en, this message translates to:
  /// **'Manage Roles'**
  String get rolesManagementTitle;

  /// Description for the roles management section where users organize friends into custom roles.
  ///
  /// In en, this message translates to:
  /// **'Create and manage custom categories for your friends.'**
  String get rolesManagementDesc;

  /// Description for the automation management section.
  ///
  /// In en, this message translates to:
  /// **'Create automation rules based on friends, roles, or other conditions.'**
  String get automationManagementDesc;

  /// Main heading displayed on the application's dashboard.
  ///
  /// In en, this message translates to:
  /// **'Control Room'**
  String get dashboardHeader;

  /// Subtitle displayed below the dashboard heading.
  ///
  /// In en, this message translates to:
  /// **'Manage active filters and status automation profiles.'**
  String get dashboardSubheader;

  /// Button label used to clear cached metadata.
  ///
  /// In en, this message translates to:
  /// **'Clear Cache'**
  String get clearCachesBtn;

  /// Option indicating that no custom automatic status message should be used.
  ///
  /// In en, this message translates to:
  /// **'No Custom Message'**
  String get defaultMessageCustomOption;

  /// Description for the option that disables custom status message templates.
  ///
  /// In en, this message translates to:
  /// **'Use the default status message without applying a custom template.'**
  String get defaultMessageCustomOptionDesc;

  /// Section title for appearance and theme settings.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get themeLabel;

  /// Toast notification displayed after changing the application language.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully.'**
  String get toastLocaleChanged;

  /// Title for the screen displaying application logs.
  ///
  /// In en, this message translates to:
  /// **'System Logs'**
  String get systemLogsTitle;

  /// Label for choosing the primary accent color of the app.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get themeSeedColorLabel;

  /// Text displayed in dashboard when no invitation filter profiles exist.
  ///
  /// In en, this message translates to:
  /// **'No filter profiles added yet.'**
  String get noProfilesAdded;

  /// Error message shown when background execution service fails.
  ///
  /// In en, this message translates to:
  /// **'Native background runtime initialization failed.'**
  String get nativeBackgroundRuntimeFail;

  /// Title displayed for new friend automation rule.
  ///
  /// In en, this message translates to:
  /// **'On New Friend Added'**
  String get automationTriggerNewFriend;

  /// Title displayed for tag-matched automation rule.
  ///
  /// In en, this message translates to:
  /// **'Matching Tag: {tag}'**
  String automationTriggerTag(String tag);

  /// Subtitle displaying list of roles assigned by automation rule.
  ///
  /// In en, this message translates to:
  /// **'Assigns: {roles}'**
  String automationAssignsRoles(String roles);

  /// Name of deep purple theme accent color.
  ///
  /// In en, this message translates to:
  /// **'Deep Purple'**
  String get colorDeepPurple;

  /// Name of blue theme accent color.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// Name of teal theme accent color.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// Name of green theme accent color.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// Name of orange theme accent color.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// Name of rose theme accent color.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// Title of a helper dialog that explains the available placeholders users can insert into their custom VRChat status message.
  ///
  /// In en, this message translates to:
  /// **'Status Placeholders Guide'**
  String get statusVariablesHelperTitle;

  /// Instruction shown above the list of available status placeholders. Tapping a placeholder inserts it into the currently edited custom VRChat status message at the current cursor position.
  ///
  /// In en, this message translates to:
  /// **'Tap a placeholder to insert it at your cursor position:'**
  String get statusVariablesHelperDesc;

  /// Placeholder label representing the name of the VRChat world the user is currently in.
  ///
  /// In en, this message translates to:
  /// **'Current World Name'**
  String get statusVariableWorld;

  /// Placeholder label representing the current number of players in the user's VRChat instance.
  ///
  /// In en, this message translates to:
  /// **'Player Count'**
  String get statusVariableCount;

  /// Placeholder label representing the device's current battery percentage.
  ///
  /// In en, this message translates to:
  /// **'Battery Level'**
  String get statusVariableBattery;

  /// Placeholder label representing the current VRChat instance access type, such as Public, Friends+, Friends, Invite+, or Invite.
  ///
  /// In en, this message translates to:
  /// **'Access Type'**
  String get statusVariableInstance;

  /// Placeholder label representing the user's current local time based on their device.
  ///
  /// In en, this message translates to:
  /// **'Local Time'**
  String get statusVariableTime;

  /// Placeholder label representing the names of friends currently in the same VRChat instance as the user.
  ///
  /// In en, this message translates to:
  /// **'Friend Names'**
  String get statusVariableFriends;

  /// Context menu action that enables the selected automation profile.
  ///
  /// In en, this message translates to:
  /// **'Activate Profile'**
  String get contextMenuActivate;

  /// Context menu action that disables the selected automation profile.
  ///
  /// In en, this message translates to:
  /// **'Deactivate Profile'**
  String get contextMenuDeactivate;

  /// Context menu action that opens the selected automation profile for editing.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get contextMenuEdit;

  /// Context menu action that permanently deletes the selected automation profile.
  ///
  /// In en, this message translates to:
  /// **'Delete Profile'**
  String get contextMenuDelete;

  /// Section header for management tools like Roles and Friend Automations on the dashboard.
  ///
  /// In en, this message translates to:
  /// **'Management Tools'**
  String get dashboardManagementTools;

  /// Title of the logout confirmation dialog.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutDialogTitle;

  /// Confirmation message warning the user about terminating their session.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out of your VRChat session?'**
  String get logoutDialogContent;

  /// Action label to confirm logging out.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutButtonLabel;

  /// Shown when a provided VRChat world ID is malformed or does not match the expected format.
  ///
  /// In en, this message translates to:
  /// **'The world ID is invalid. It must start with \'wrld_\' and contain at least 10 characters.'**
  String get errorWorldIdInvalid;

  /// Shown when a custom message is required but no text was provided.
  ///
  /// In en, this message translates to:
  /// **'The custom message cannot be empty.'**
  String get errorMsgEmpty;

  /// Shown when a custom message exceeds the maximum allowed length.
  ///
  /// In en, this message translates to:
  /// **'The message is {actual} characters long, but the maximum allowed is {max}.'**
  String errorMsgTooLong(int actual, int max);

  /// Shown when attempting to access or modify a message slot that does not exist.
  ///
  /// In en, this message translates to:
  /// **'Message slot {index} is out of range.'**
  String errorMsgInvalidSlot(int index);

  /// Shown when a rule action expects an invite message but another message type was provided.
  ///
  /// In en, this message translates to:
  /// **'This rule action requires an invite message.'**
  String get errorRuleInviteMismatch;

  /// Shown when a rule action expects a request message but another message type was provided.
  ///
  /// In en, this message translates to:
  /// **'This rule action requires a request message.'**
  String get errorRuleRequestMismatch;

  /// Shown when an unsupported comparison operator is used for a specific status condition.
  ///
  /// In en, this message translates to:
  /// **'The operator \'\'{operator}\'\' is not supported for the \'\'{condition}\'\' condition.'**
  String errorStatusInvalidOperator(String operator, String condition);

  /// Shown when a status condition requires a comparison value but none was provided.
  ///
  /// In en, this message translates to:
  /// **'A comparison value is required for this condition.'**
  String get errorStatusEmptyValue;

  /// Shown when a role automation is saved without any associated roles.
  ///
  /// In en, this message translates to:
  /// **'Select at least one role before saving this automation.'**
  String get errorRoleAutoEmptyRoles;

  /// Shown when a tag-based automation is configured without specifying the target tag.
  ///
  /// In en, this message translates to:
  /// **'A target tag is required for tag-based automation.'**
  String get errorRoleAutoMissingTag;

  /// Title of the page used to manage calendar automation rules.
  ///
  /// In en, this message translates to:
  /// **'Calendar Automations'**
  String get calHeader;

  /// Short description displayed below the page title explaining what calendar automations do.
  ///
  /// In en, this message translates to:
  /// **'Configure automated scheduling rules that create and manage VRChat Group events in the background.'**
  String get calSubheader;

  /// Button label that opens the dialog for creating a new calendar automation rule.
  ///
  /// In en, this message translates to:
  /// **'Create Automation'**
  String get calBtnCreate;

  /// Dialog title shown when creating a new calendar automation rule.
  ///
  /// In en, this message translates to:
  /// **'New Calendar Rule'**
  String get calEditorTitleNew;

  /// Dialog title shown when editing an existing calendar automation rule.
  ///
  /// In en, this message translates to:
  /// **'Edit Calendar Rule'**
  String get calEditorTitleEdit;

  /// Label for the user-defined name of the automation rule.
  ///
  /// In en, this message translates to:
  /// **'Rule Name'**
  String get calFieldLabelName;

  /// Label for the VRChat Group ID associated with this automation.
  ///
  /// In en, this message translates to:
  /// **'VRChat Group ID'**
  String get calFieldLabelGroupId;

  /// Label for the template used to generate the VRChat event title.
  ///
  /// In en, this message translates to:
  /// **'Event Title Template'**
  String get calFieldLabelTitle;

  /// Label for the template used to generate the VRChat event description.
  ///
  /// In en, this message translates to:
  /// **'Event Description Template'**
  String get calFieldLabelDesc;

  /// Helper text indicating that the {{incremental}} placeholder can be used inside the title template.
  ///
  /// In en, this message translates to:
  /// **'Supports the \'{{incremental}}\' placeholder.'**
  String get calFieldHintTitle;

  /// Section heading containing the event time, duration and timezone settings.
  ///
  /// In en, this message translates to:
  /// **'Schedule'**
  String get calSectionSchedule;

  /// Label for the daily start time of the scheduled event. Uses a 24-hour HH:mm format.
  ///
  /// In en, this message translates to:
  /// **'Start Time'**
  String get calFieldLabelTime;

  /// Label for the duration of the generated event, expressed in minutes.
  ///
  /// In en, this message translates to:
  /// **'Duration (Minutes)'**
  String get calFieldLabelDuration;

  /// Label for the IANA time zone identifier used when scheduling events.
  ///
  /// In en, this message translates to:
  /// **'Time Zone (IANA)'**
  String get calFieldLabelTimezone;

  /// Section heading containing the recurrence pattern configuration.
  ///
  /// In en, this message translates to:
  /// **'Recurrence'**
  String get calSectionRecurrence;

  /// Section heading for configuring the automatic incremental counter used by the {{incremental}} placeholder.
  ///
  /// In en, this message translates to:
  /// **'Incremental Counter'**
  String get calSectionIncremental;

  /// Section containing VRChat-specific event configuration options.
  ///
  /// In en, this message translates to:
  /// **'VRChat Event Settings'**
  String get calSectionVrcMetadata;

  /// Label for the number of minutes before the event that hosts may join.
  ///
  /// In en, this message translates to:
  /// **'Host Early Access (Minutes)'**
  String get calFieldLabelHostEarly;

  /// Label for the number of minutes before the event that group members may join.
  ///
  /// In en, this message translates to:
  /// **'Member Early Access (Minutes)'**
  String get calFieldLabelGuestEarly;

  /// Label for the delay, in minutes, before automatically closing the event instance after it ends.
  ///
  /// In en, this message translates to:
  /// **'Automatic Cleanup Delay (Minutes)'**
  String get calFieldLabelCloseDelay;

  /// Label for the option that enables VRChat instance overflow protection when creating events.
  ///
  /// In en, this message translates to:
  /// **'Enable Instance Overflow Protection'**
  String get calFieldLabelOverflow;

  /// Toast notification shown after a calendar automation rule has been saved.
  ///
  /// In en, this message translates to:
  /// **'Calendar rule saved successfully.'**
  String get calToastSaved;

  /// Title of the confirmation dialog displayed before deleting a calendar automation rule.
  ///
  /// In en, this message translates to:
  /// **'Delete Automation Rule'**
  String get calConfirmDeleteTitle;

  /// Confirmation message displayed before permanently deleting a calendar automation rule.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this automation rule? This action cannot be undone.'**
  String get calConfirmDeleteContent;

  /// Message shown when there are no calendar automation rules to display.
  ///
  /// In en, this message translates to:
  /// **'No calendar automation rules have been created yet.'**
  String get calMsgEmptyRules;

  /// Calendar recurrence option for an event that occurs only one time.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get calRecurrenceOnce;

  /// Calendar recurrence option for an event that repeats every day.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get calRecurrenceDaily;

  /// Calendar recurrence option for an event that repeats every week.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get calRecurrenceWeekly;

  /// Calendar recurrence option for an event that repeats every month.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get calRecurrenceMonthly;

  /// Event category for arts and creative activities.
  ///
  /// In en, this message translates to:
  /// **'Arts'**
  String get calCategoryArts;

  /// Event category related to avatar creation, customization, or showcases.
  ///
  /// In en, this message translates to:
  /// **'Avatars'**
  String get calCategoryAvatars;

  /// Event category for dance activities or performances.
  ///
  /// In en, this message translates to:
  /// **'Dance'**
  String get calCategoryDance;

  /// Event category for educational activities, classes, or workshops.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get calCategoryEducation;

  /// Event category for world exploration, tours, or discovery activities.
  ///
  /// In en, this message translates to:
  /// **'Exploration'**
  String get calCategoryExploration;

  /// Event category for movies, filmmaking, streaming, photography, or media-related activities.
  ///
  /// In en, this message translates to:
  /// **'Film & Media'**
  String get calCategoryFilmMedia;

  /// Event category for gaming sessions, tournaments, or game-related activities.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get calCategoryGaming;

  /// Event category for casual social gatherings where people meet and spend time together.
  ///
  /// In en, this message translates to:
  /// **'Hangout'**
  String get calCategoryHangout;

  /// Event category for music performances, concerts, DJ sets, or listening sessions.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get calCategoryMusic;

  /// Event category for live performances such as theater, comedy, or stage shows.
  ///
  /// In en, this message translates to:
  /// **'Performance'**
  String get calCategoryPerformance;

  /// Event category for roleplaying activities and roleplay communities.
  ///
  /// In en, this message translates to:
  /// **'Roleplaying'**
  String get calCategoryRoleplaying;

  /// Event category for wellness, mindfulness, meditation, fitness, or self-care activities.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get calCategoryWellness;

  /// Fallback event category when no other category applies.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get calCategoryOther;

  /// Label for the field where the user selects the event end time.
  ///
  /// In en, this message translates to:
  /// **'End Time'**
  String get calFieldLabelEndTime;

  /// Label for selecting the weekdays on which a recurring event takes place.
  ///
  /// In en, this message translates to:
  /// **'Days of Week'**
  String get calFieldLabelDaysOfWeek;

  /// Formats a duration using hours and minutes.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String calDurationHoursMinutes(int hours, int minutes);

  /// Formats a duration using only minutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String calDurationMinutesOnly(int minutes);

  /// Label for selecting the VRChat platforms where the event is available (e.g. PC, Android, iOS). Displayed in the event creation/edit form.
  ///
  /// In en, this message translates to:
  /// **'Event Platforms'**
  String get calFieldLabelPlatform;

  /// Label for the initial number used by the incremental event counter. For example, if set to 5, the first generated event title will use #5.
  ///
  /// In en, this message translates to:
  /// **'Start Value'**
  String get calFieldLabelIncrementalStart;

  /// Label for the increment applied between automatically generated sequence numbers. For example, a step of 2 produces #1, #3, #5.
  ///
  /// In en, this message translates to:
  /// **'Step Value'**
  String get calFieldLabelIncrementalStep;

  /// Toggle that enables automatic numbering of recurring events using an incremental counter.
  ///
  /// In en, this message translates to:
  /// **'Enable Incremental Counter'**
  String get calFieldLabelIncrementalEnable;

  /// Helper text explaining that recurring events can automatically append incrementing numbers to their titles, such as 'Event #1' and 'Event #2'.
  ///
  /// In en, this message translates to:
  /// **'Auto-increment sequence numbers (e.g. Event #1, Event #2)'**
  String get calFieldLabelIncrementalDesc;

  /// Section header for advanced timing settings that control when users can join or access a VRChat event instance.
  ///
  /// In en, this message translates to:
  /// **'Advanced Access Tolerances'**
  String get calSectionTolerances;

  /// Helper text for an option that prevents additional users from joining a VRChat instance once its configured capacity has been reached.
  ///
  /// In en, this message translates to:
  /// **'Prevent instance overflow when limits are reached'**
  String get calFieldLabelOverflowDesc;

  /// Short label for the number of minutes before the scheduled start time that event hosts are allowed to join the VRChat instance.
  ///
  /// In en, this message translates to:
  /// **'Host Access (min)'**
  String get calFieldLabelHostEarlyShort;

  /// Short label for the number of minutes before the scheduled start time that members or guests are allowed to join the VRChat instance.
  ///
  /// In en, this message translates to:
  /// **'Member Access (min)'**
  String get calFieldLabelGuestEarlyShort;

  /// Short label for the number of minutes after the scheduled end time before the VRChat instance is considered closed.
  ///
  /// In en, this message translates to:
  /// **'Close Delay (min)'**
  String get calFieldLabelCloseDelayShort;

  /// Title shown above the preview of the VRChat live event card while the user is configuring an event. This is only a preview and not the actual published card.
  ///
  /// In en, this message translates to:
  /// **'Live Card Preview'**
  String get calLiveCardPreview;

  /// Placeholder displayed in the live card preview when the event title has not been entered yet.
  ///
  /// In en, this message translates to:
  /// **'Untitled Event'**
  String get calNoTitleTemplate;

  /// Placeholder displayed in the live card preview when the event description is empty.
  ///
  /// In en, this message translates to:
  /// **'No description provided'**
  String get calNoDescriptionTemplate;

  /// Help text below the platform selector. Refers to supported VRChat platforms such as Windows or Android.
  ///
  /// In en, this message translates to:
  /// **'Choose which VRChat platforms are officially supported for this event.'**
  String get calPlatformDesc;

  /// Help text explaining the Public visibility option for a group event.
  ///
  /// In en, this message translates to:
  /// **'Anyone on VRChat can view and join this event.'**
  String get calAccessPublicDesc;

  /// Help text explaining the Group-only visibility option. The event is restricted to approved members of the VRChat group.
  ///
  /// In en, this message translates to:
  /// **'Only approved group members can view and join this event.'**
  String get calAccessGroupDesc;

  /// Section title for the setting that controls early access for event hosts.
  ///
  /// In en, this message translates to:
  /// **'Host Access'**
  String get calToleranceHostTitle;

  /// Help text explaining that event hosts may enter the VRChat world instance early for setup before attendees can join.
  ///
  /// In en, this message translates to:
  /// **'Allows hosts to join the world instance before the event starts so they can get everything ready.'**
  String get calToleranceHostDesc;

  /// Section title for the setting that controls early access for regular group members.
  ///
  /// In en, this message translates to:
  /// **'Member Access'**
  String get calToleranceMemberTitle;

  /// Help text for the early join window available to regular group members before the event begins.
  ///
  /// In en, this message translates to:
  /// **'Choose how many minutes before the scheduled start group members can join the instance.'**
  String get calToleranceMemberDesc;

  /// Section title for the setting that controls how long the world instance remains open after the event ends.
  ///
  /// In en, this message translates to:
  /// **'Instance Close Delay'**
  String get calToleranceCloseTitle;

  /// Help text explaining the grace period after the event's scheduled end time before the VRChat world instance is closed.
  ///
  /// In en, this message translates to:
  /// **'Keeps the world instance open for a short time after the scheduled end before it is closed.'**
  String get calToleranceCloseDesc;

  /// Placeholder shown in the group selection dropdown before a VRChat group has been selected.
  ///
  /// In en, this message translates to:
  /// **'Select a VRChat Group...'**
  String get calGroupSelectHint;

  /// Message displayed when the current user does not belong to any VRChat group where they have permission to manage the group's calendar.
  ///
  /// In en, this message translates to:
  /// **'No groups with calendar management permissions were found.'**
  String get calGroupNoPerms;

  /// Status message displayed while verifying whether the current user has permission to manage the selected VRChat group's calendar.
  ///
  /// In en, this message translates to:
  /// **'Checking permissions...'**
  String get calGroupValidating;

  /// Error message displayed when the user selects a VRChat group but lacks permission to manage its calendar.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have permission to manage this group\'s calendar.'**
  String get calGroupPermissionDenied;

  /// Label for the start date field in the calendar editor.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get calFieldLabelStartDate;

  /// Label for the end date field in the calendar editor.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get calFieldLabelEndDate;

  /// Section header for the event exceptions list.
  ///
  /// In en, this message translates to:
  /// **'Exceptions'**
  String get calSectionExceptions;

  /// Button to add a new calendar exception.
  ///
  /// In en, this message translates to:
  /// **'Add Exception'**
  String get calExceptionAdd;

  /// Option to cancel the event on a specific date.
  ///
  /// In en, this message translates to:
  /// **'Cancel event on this date'**
  String get calExceptionCancel;

  /// Placeholder when there are no exceptions.
  ///
  /// In en, this message translates to:
  /// **'No exceptions configured'**
  String get calExceptionsEmpty;

  /// Label for selecting days of the month for monthly recurrence.
  ///
  /// In en, this message translates to:
  /// **'Days of Month'**
  String get calDaysOfMonth;
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
