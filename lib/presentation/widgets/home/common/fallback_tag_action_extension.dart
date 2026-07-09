import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';

extension FallbackTagActionL10n on FallbackTagAction {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case FallbackTagAction.disabled:
        return context.l10n.fallbackTagActionDisabled;
      
      case FallbackTagAction.accept:
        return context.l10n.fallbackTagActionAccept;
      
      case FallbackTagAction.reject:
        return context.l10n.fallbackTagActionReject;
    }
  }
}