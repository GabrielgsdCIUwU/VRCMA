import 'package:flutter/cupertino.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/entities/automation/automation_log.dart';

extension AutomationLogUiExtension on AutomationLog {
  /// Resolves the localized applied rule string on the fly based on current locale.
  String getLocalizedAppliedRule(BuildContext context) {
    if (matchedRoleName == null) {
      return "$profileName (${context.l10n.logNoRuleMatched})";
    }
    return "$profileName (${context.l10n.logRuleMatched(matchedRoleName!)})";
  }
}