import 'package:flutter/cupertino.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';

extension CalendarL10nExtension on BuildContext {
  String get calHeader => l10n.calHeader;
  String get calSubheader => l10n.calSubheader;
  String get calBtnCreate => l10n.calBtnCreate;
  String get calEditorTitleNew => l10n.calEditorTitleNew;
  String get calEditorTitleEdit => l10n.calEditorTitleEdit;
  String get calFieldLabelName => l10n.calFieldLabelName;
  String get calFieldLabelGroupId => l10n.calFieldLabelGroupId;
  String get calFieldLabelTitle => l10n.calFieldLabelTitle;
  String get calFieldLabelDesc => l10n.calFieldLabelDesc;
  String get calFieldHintTitle => l10n.calFieldHintTitle;
  String get calSectionSchedule => l10n.calSectionSchedule;
  String get calFieldLabelTime => l10n.calFieldLabelTime;
  String get calFieldLabelDuration => l10n.calFieldLabelDuration;
  String get calFieldLabelTimezone => l10n.calFieldLabelTimezone;
  String get calSectionRecurrence => l10n.calSectionRecurrence;
  String get calSectionIncremental => l10n.calSectionIncremental;
  String get calSectionVrcMetadata => l10n.calSectionVrcMetadata;
  String get calFieldLabelHostEarly => l10n.calFieldLabelHostEarly;
  String get calFieldLabelGuestEarly => l10n.calFieldLabelGuestEarly;
  String get calFieldLabelCloseDelay => l10n.calFieldLabelCloseDelay;
  String get calFieldLabelOverflow => l10n.calFieldLabelOverflow;
  String get calToastSaved => l10n.calToastSaved;
  String get calConfirmDeleteTitle => l10n.calConfirmDeleteTitle;
  String get calConfirmDeleteContent => l10n.calConfirmDeleteContent;
  String get calMsgEmptyRules => l10n.calMsgEmptyRules;
}