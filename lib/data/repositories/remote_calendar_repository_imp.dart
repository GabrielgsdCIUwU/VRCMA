import 'package:vrchat_dart/vrchat_dart.dart' as vrchat;
import 'package:vrcma/data/mappers/remote_calendar_mapper.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/error/calendar_domain_exception.dart';
import 'package:vrcma/domain/entities/calendar/enums/calendar_event_platform.dart'
    as domain;
import 'package:vrcma/domain/repositories/i_remote_calendar_repository.dart';

class RemoteCalendarRepositoryImp implements IRemoteCalendarRepository {
  final vrchat.VrchatDart _vrcApi;

  RemoteCalendarRepositoryImp(this._vrcApi);

  @override
  Future<bool> verifyCreationPermissions(String userId, String groupId) async {
    try {
      final memberResponse = await _vrcApi.rawApi.getGroupsApi().getGroupMember(groupId: groupId, userId: userId);
      final member = memberResponse.data;
      if (member == null) return false;
      
      final memberRoleIds = member.roleIds;
      if (memberRoleIds == null || memberRoleIds.isEmpty) return false;

      final rolesResponse = await _vrcApi.rawApi.getGroupsApi().getGroupRoles(groupId: groupId);
      final groupRoles = rolesResponse.data;
      if (groupRoles == null || groupRoles.isEmpty) return false;

      for (final role in groupRoles) {
        if (memberRoleIds.contains(role.id)) {
          final permissions = role.permissions;
          if (permissions == null || permissions.isEmpty) continue;

          final hasRequiredPermission = permissions.any((permission) =>
              permission == vrchat.GroupPermissions.group_calendar_manage ||
              permission == vrchat.GroupPermissions.group_all);

          if (hasRequiredPermission) return true;
        }
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> createEvent({
    required String groupId,
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
  }) async {
    final request = RemoteCalendarMapper.mapToCreateRequest(
      title: title,
      startUtc: startUtc,
      endUtc: endUtc,
      description: description,
      category: category,
      accessType: accessType,
      platforms: platforms,
      languages: languages,
      tags: tags,
      sendCreationNotification: sendCreationNotification,
      roleIds: roleIds,
      hostEarlyJoinMinutes: hostEarlyJoinMinutes,
      guestEarlyJoinMinutes: guestEarlyJoinMinutes,
      closeInstanceAfterEndMinutes: closeInstanceAfterEndMinutes,
      usesInstanceOverflow: usesInstanceOverflow,
    );

    try {
      final response = await _vrcApi.rawApi.getCalendarApi().createGroupCalendarEvent(
        groupId: groupId,
        createCalendarEventRequest: request
      );

      final createdEvent = response.data;
      if (createdEvent == null) throw CalendarPublishException('API response payload empty.');

      return createdEvent.id;
    } catch (e) {
      throw CalendarPublishException(e.toString());
    }
  }

  @override
  Future<void> deleteEvent(String groupId, String eventId) async {
    try {
      await _vrcApi.rawApi.getCalendarApi().deleteGroupCalendarEvent(groupId: groupId, calendarId: eventId);
    } catch (e) {
      throw CalendarDeleteException(e.toString());
    }    
  }
}