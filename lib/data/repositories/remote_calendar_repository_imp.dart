import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:vrchat_dart/vrchat_dart.dart' as vrchat;
import 'package:vrcma/data/mappers/remote_calendar_mapper.dart';
import 'package:vrcma/domain/entities/calendar/enums/calendar_event_platform.dart'
as domain;
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/remote_calendar_event.dart';
import 'package:vrcma/domain/error/calendar_domain_exception.dart';
import 'package:vrcma/domain/repositories/i_remote_calendar_repository.dart';

/// VRChat HTTP API implementation of [IRemoteCalendarRepository].
class RemoteCalendarRepositoryImp implements IRemoteCalendarRepository {
  static const int _defaultRateLimitMinutes = 45;

  final vrchat.VrchatDart _vrcApi;

  RemoteCalendarRepositoryImp(this._vrcApi);

  @override
  Future<bool> verifyCreationPermissions(String userId, String groupId) async {
    try {
      final groupResponse =
      await _vrcApi.rawApi.getGroupsApi().getGroup(groupId: groupId);
      final group = groupResponse.data;
      if (group != null && group.ownerId == userId) {
        return true;
      }

      return await _hasCalendarRolePermission(userId, groupId);
    } catch (error, stackTrace) {
      debugPrint('Error inside verifyCreationPermissions: $error\n$stackTrace');
      return false;
    }
  }

  @override
  Future<List<RemoteCalendarEvent>> getUpcomingGroupEvents(String groupId) async {
    final collected = <RemoteCalendarEvent>[];
    int offset = 0;
    const int pageSize = 60;

    try {
      while (true) {
        final response = await _vrcApi.rawApi
            .getCalendarApi()
            .getGroupCalendarEvents(groupId: groupId, n: pageSize, offset: offset);

        final page = response.data;
        final pageResults = page?.results;
        if (page == null || pageResults == null || pageResults.isEmpty) {
          break;
        }

        _collectActiveEvents(pageResults, collected);
        if (page.hasNext != true) break;

        offset += pageSize;
      }
      return collected;
    } on DioException catch (dioError) {
      _throwMappedDioError(dioError);
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
      final response = await _vrcApi.rawApi
          .getCalendarApi()
          .createGroupCalendarEvent(
        groupId: groupId,
        createCalendarEventRequest: request,
      );

      final createdEvent = response.data;
      if (createdEvent == null) {
        throw CalendarPublishException('API response payload empty.');
      }

      return createdEvent.id;
    } on DioException catch (dioError) {
      _throwMappedDioError(dioError);
    } catch (error) {
      if (error is CalendarPublishException) rethrow;
      throw CalendarPublishException(error.toString());
    }
  }

  @override
  Future<void> deleteEvent(String groupId, String eventId) async {
    try {
      await _vrcApi.rawApi.getCalendarApi().deleteGroupCalendarEvent(
        groupId: groupId,
        calendarId: eventId,
      );
    } catch (error) {
      throw CalendarDeleteException(error.toString());
    }
  }

  Future<bool> _hasCalendarRolePermission(String userId, String groupId) async {
    final memberResponse = await _vrcApi.rawApi
        .getGroupsApi()
        .getGroupMember(groupId: groupId, userId: userId);
    final memberRoleIds = memberResponse.data?.roleIds;
    if (memberRoleIds == null || memberRoleIds.isEmpty) return false;

    final rolesResponse =
    await _vrcApi.rawApi.getGroupsApi().getGroupRoles(groupId: groupId);
    final groupRoles = rolesResponse.data;
    if (groupRoles == null || groupRoles.isEmpty) return false;

    return groupRoles.any(
          (role) =>
      memberRoleIds.contains(role.id) && _roleGrantsCalendarManage(role),
    );
  }

  bool _roleGrantsCalendarManage(vrchat.GroupRole role) {
    final permissions = role.permissions;
    if (permissions == null || permissions.isEmpty) return false;

    return permissions.any(
          (permission) =>
      permission == vrchat.GroupPermissions.group_calendar_manage ||
          permission == vrchat.GroupPermissions.group_all,
    );
  }

  void _collectActiveEvents(
      Iterable<vrchat.CalendarEvent> source,
      List<RemoteCalendarEvent> destination,
      ) {
    for (final event in source) {
      if (event.deletedAt != null) continue;

      destination.add(
        RemoteCalendarEvent(
          id: event.id,
          title: event.title,
          startsAtUtc: event.startsAt.toUtc(),
          endsAtUtc: event.endsAt.toUtc(),
        ),
      );
    }
  }

  Never _throwMappedDioError(DioException dioError) {
    if (dioError.response?.statusCode == 429) {
      final retryHeader = dioError.response?.headers.value('Retry-After');
      final retrySeconds = int.tryParse(retryHeader ?? '');
      final minutes = retrySeconds != null
          ? (retrySeconds / 60).ceil().clamp(1, 120)
          : _defaultRateLimitMinutes;
      throw CalendarRateLimitException(minutes);
    }

    throw CalendarPublishException(dioError.message ?? dioError.toString());
  }
}