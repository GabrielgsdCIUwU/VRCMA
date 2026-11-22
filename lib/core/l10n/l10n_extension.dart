import 'package:flutter/widgets.dart';
import 'package:vrcma/core/l10n/arb/app_localizations.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}