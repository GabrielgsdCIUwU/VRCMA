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
