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
}
