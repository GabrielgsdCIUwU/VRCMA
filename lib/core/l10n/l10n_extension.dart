import 'package:flutter/widgets.dart';
import 'package:vrcma/core/l10n/arb/app_localizations.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// Translates raw VRChat presence status string to their localized equivalents.
  String getLocalizedStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return l10n.statusTypeActive;
      
      case 'join me':
        return l10n.statusTypeJoinMe;
      
      case 'ask me':
        return l10n.statusTypeAskMe;
      
      case 'busy':
        return l10n.statusTypeBusy;
      
      default:
        return status;
    }
  }
}