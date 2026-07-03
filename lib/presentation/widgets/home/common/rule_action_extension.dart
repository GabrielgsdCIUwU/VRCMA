import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';

extension RuleActionL10n on RuleAction {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case RuleAction.accept:
        return context.l10n.ruleActionAccept;
      
      case RuleAction.reject:
        return context.l10n.ruleActionReject;
    }
  }
}