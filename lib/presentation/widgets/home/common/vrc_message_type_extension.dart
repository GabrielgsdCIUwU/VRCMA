import 'package:flutter/material.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

extension VrcMessagetypeL10n on VrcMessageType {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case VrcMessageType.invite:
        return context.l10n.messageTypeInvite;

      case VrcMessageType.response:
        return context.l10n.messageTypeResponse;
      
      case VrcMessageType.request:
        return context.l10n.messageTypeRequest;
      
      case VrcMessageType.requestResponse:
        return context.l10n.messageTypeRequestResponse;
    }
  }
}