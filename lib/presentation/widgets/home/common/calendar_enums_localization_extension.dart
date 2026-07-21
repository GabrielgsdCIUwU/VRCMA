import 'package:flutter/widgets.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';

extension RecurrenceTypeL10n on RecurrenceType {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case RecurrenceType.once:
        return context.l10n.calRecurrenceOnce;
      
      case RecurrenceType.daily:
        return context.l10n.calRecurrenceDaily;
      
      case RecurrenceType.weekly:
        return context.l10n.calRecurrenceWeekly;
      
      case RecurrenceType.monthly:
        return context.l10n.calRecurrenceMonthly;
    }
  }
}

extension GroupEventCategoryL10n on GroupEventCategory {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case GroupEventCategory.arts:
        return context.l10n.calCategoryArts;
      
      case GroupEventCategory.avatars:
        return context.l10n.calCategoryAvatars;
      
      case GroupEventCategory.dance:
        return context.l10n.calCategoryDance;
      
      case GroupEventCategory.education:
        return context.l10n.calCategoryEducation;
      
      case GroupEventCategory.exploration:
        return context.l10n.calCategoryExploration;
      
      case GroupEventCategory.film_media:
        return context.l10n.calCategoryFilmMedia;
      
      case GroupEventCategory.gaming:
        return context.l10n.calCategoryGaming;
      
      case GroupEventCategory.hangout:
        return context.l10n.calCategoryHangout;
      
      case GroupEventCategory.music:
        return context.l10n.calCategoryMusic;
      
      case GroupEventCategory.performance:
        return context.l10n.calCategoryPerformance;
      
      case GroupEventCategory.roleplaying:
        return context.l10n.calCategoryRoleplaying;
      
      case GroupEventCategory.wellness:
        return context.l10n.calCategoryWellness;
      
      case GroupEventCategory.other:
        return context.l10n.calCategoryOther;
    }
  }
}

extension GroupEventAccessTypeL10n on GroupEventAccessType {
  String toLocalizedString(BuildContext context) {
    switch (this) {
      case GroupEventAccessType.public:
        return context.l10n.accessPublic;
      
      case GroupEventAccessType.group:
        return context.l10n.accessGroup;
    }
  }
}