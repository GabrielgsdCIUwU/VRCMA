import 'package:flutter/widgets.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/error/domain_exception.dart';

extension FailureLocalization on Failure {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;
    if (this is TwoFactorRequiredFailure) {
      return l10n.enter2faTitle;
    }
    if (this is ApiFailure) {
      if (message.contains('timeout')) {
        return l10n.connectionTimeout;
      }
      return l10n.unexpectedError(message);
    }
    if (this is DomainFailure) {
      return (this as DomainFailure).exception.toLocalizedString(context);
    }
    return message;
  }
}

extension DomainExceptionLocalization on DomainException {
  String toLocalizedString(BuildContext context) {
    final l10n = context.l10n;

    return switch (this) {
      WorldIdValidationException(error: final err) => switch (err) {
          WorldIdPatternValidationError() => l10n.errorWorldIdInvalid,
        },
      MessageValidationException(error: final err) => switch (err) {
          MessageEmptyValidationError() => l10n.errorMsgEmpty,
          MessageTooLongValidationError(actualLength: final act, maxLength: final max) =>
            l10n.errorMsgTooLong(act, max),
          InvalidSlotIndexValidationError(providedIndex: final prov) =>
            l10n.errorMsgInvalidSlot(prov),
        },
      ProfileRuleValidationException(error: final err) => switch (err) {
          RuleInviteMessageMismatchError() => l10n.errorRuleInviteMismatch,
          RuleRequestMessageMismatchError() => l10n.errorRuleRequestMismatch,
        },
      StatusRuleValidationException(error: final err) => switch (err) {
          InvalidStatusOperatorError(operatorName: final op, conditionName: final cond) =>
            l10n.errorStatusInvalidOperator(op, cond),
          EmptyStatusConditionValueError() => l10n.errorStatusEmptyValue,
        },
      RoleAutomationValidationException(error: final err) => switch (err) {
          EmptyRoleAssignmentError() => l10n.errorRoleAutoEmptyRoles,
          MissingTriggerTagError() => l10n.errorRoleAutoMissingTag,
        },
      _ => defaultMessage,
    };
  }
}