import 'package:vrchat_dart/vrchat_dart.dart' as vrchat;
import 'package:vrcma/domain/entities/calendar/enums/calendar_event_platform.dart' as domain;
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';

/// Maps domain calendar concepts to VRChat API concrete contracts.
class RemoteCalendarMapper {
  static vrchat.CalendarEventAccess mapAccessType(GroupEventAccessType domainAccess) {
    switch (domainAccess) {
      case GroupEventAccessType.public:
        return vrchat.CalendarEventAccess.public;
      
      case GroupEventAccessType.group:
        return vrchat.CalendarEventAccess.group;
    }
  }

  static vrchat.CalendarEventCategory mapCategory(GroupEventCategory domainCategory) {
    return vrchat.CalendarEventCategory.values.firstWhere(
      (sdkEnum) => sdkEnum.name.toLowerCase() == domainCategory.name.toLowerCase(),
      orElse: () => vrchat.CalendarEventCategory.other,
    );
  }

  static vrchat.CalendarEventPlatform mapPlatform(domain.CalendarEventPlatform domainPlatform) {
    return vrchat.CalendarEventPlatform.values.firstWhere(
      (sdkEnum) => sdkEnum.name.toLowerCase() == domainPlatform.name.toLowerCase(),
      orElse: () => vrchat.CalendarEventPlatform.standalonewindows,
    );
  }

  static vrchat.CreateCalendarEventRequest mapToCreateRequest({
    required String title,
    required DateTime startUtc,
    required DateTime endUtc,
    required String description,
    required GroupEventCategory category,
    required GroupEventAccessType accessType,
    required List<domain.CalendarEventPlatform> platforms,
    required List<String> languages,
    required List<String> tags,
    required bool sendCreationNotification,
    List<String>? roleIds,
    int? hostEarlyJoinMinutes,
    int? guestEarlyJoinMinutes,
    int? closeInstanceAfterEndMinutes,
    bool? usesInstanceOverflow,
  }) {
    return vrchat.CreateCalendarEventRequest(
      title: title,
      description: description,
      startsAt: startUtc,
      endsAt: endUtc,
      accessType: mapAccessType(accessType),
      category: mapCategory(category),
      platforms: platforms.map(mapPlatform).toList(),
      languages: languages,
      tags: tags,
      sendCreationNotification: sendCreationNotification,
      roleIds: roleIds,
      hostEarlyJoinMinutes: hostEarlyJoinMinutes,
      guestEarlyJoinMinutes: guestEarlyJoinMinutes,
      closeInstanceAfterEndMinutes: closeInstanceAfterEndMinutes,
      usesInstanceOverflow: usesInstanceOverflow,
      isDraft: false,
      featured: false,
      parentId: null,
    );
  }
}