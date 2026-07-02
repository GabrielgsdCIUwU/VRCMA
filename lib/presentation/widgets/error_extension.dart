import 'package:flutter/widgets.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/core/l10n/ll10n_extension.dart';

extension FailureLocalization on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    if (this is ApiFailure) {
      if (message.contains('timeout')) {
        return l10n.connectionTimeout;
      }
      return l10n.unexpectedError(message);
    }
    return message;
  }
}