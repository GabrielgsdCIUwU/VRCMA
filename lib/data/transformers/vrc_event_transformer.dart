import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/data/mappers/vrc_image_mapper.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';

/// Callback signature used by transformers to enrich a notification sender profile.
typedef EnrichedUserLoader = Future<UserResponse?> Function(String userId);

/// Base contract for converting raw VRChat WebSocket payloads into domain events.
abstract class VrcEventTransformer<T extends VrcAutomationEvent> {
  /// Determines whether this transformer handles [event].
  bool canHandle(Object event);

  /// Converts [event] into a domain automation event using [getEnrichedUser].
  Future<T?> transform(
      Object event,
      EnrichedUserLoader getEnrichedUser,
      );
}

/// Transforms incoming friend request notifications into [FriendRequestReceivedEvent].
class FriendRequestTransformer
    implements VrcEventTransformer<FriendRequestReceivedEvent> {
  @override
  bool canHandle(Object event) {
    if (event is WebsocketNotificationUnknown) {
      return event.type == 'friendRequest';
    }
    if (event is NotificationV2) {
      return event.type.toString() == 'friendRequest';
    }
    return false;
  }

  @override
  Future<FriendRequestReceivedEvent?> transform(
      Object event,
      EnrichedUserLoader getEnrichedUser,
      ) async {
    final ids = _extractIds(event);
    if (ids == null || ids.senderId.isEmpty) return null;

    final sender = await _loadSenderInfo(ids.senderId, getEnrichedUser);
    return FriendRequestReceivedEvent(
      id: ids.notificationId,
      senderId: ids.senderId,
      senderName: sender.displayName,
      senderTags: sender.tags,
      avatarUrl: sender.avatarUrl,
    );
  }

  ({String notificationId, String senderId})? _extractIds(Object event) {
    if (event is WebsocketNotificationUnknown) {
      return (notificationId: event.id, senderId: event.senderUserId);
    }
    if (event is NotificationV2) {
      return (notificationId: event.id, senderId: event.senderUserId);
    }
    return null;
  }
}

/// Transforms incoming invite notifications into [InviteReceivedEvent].
class InviteReceivedTransformer
    implements VrcEventTransformer<InviteReceivedEvent> {
  @override
  bool canHandle(Object event) => event is WebsocketNotificationDetailInvite;

  @override
  Future<InviteReceivedEvent?> transform(
      Object event,
      EnrichedUserLoader getEnrichedUser,
      ) async {
    final invite = event as WebsocketNotificationDetailInvite;
    if (invite.senderUserId.isEmpty) return null;

    final sender = await _loadSenderInfo(invite.senderUserId, getEnrichedUser);
    return InviteReceivedEvent(
      id: invite.id,
      senderId: invite.senderUserId,
      senderName: sender.displayName,
      senderTags: sender.tags,
      avatarUrl: sender.avatarUrl,
    );
  }
}

/// Transforms incoming request-invite notifications into [RequestInviteEvent].
class RequestReceivedTransformer
    implements VrcEventTransformer<RequestInviteEvent> {
  @override
  bool canHandle(Object event) =>
      event is WebsocketNotificationDetailRequestInvite;

  @override
  Future<RequestInviteEvent?> transform(
      Object event,
      EnrichedUserLoader getEnrichedUser,
      ) async {
    final request = event as WebsocketNotificationDetailRequestInvite;
    if (request.senderUserId.isEmpty) return null;

    final sender = await _loadSenderInfo(request.senderUserId, getEnrichedUser);
    return RequestInviteEvent(
      id: request.id,
      senderId: request.senderUserId,
      senderName: sender.displayName,
      senderTags: sender.tags,
      avatarUrl: sender.avatarUrl,
    );
  }
}

/// Transforms current-user profile updates into [UserProfileUpdatedEvent].
class UserProfileUpdatedTransformer
    implements VrcEventTransformer<UserProfileUpdatedEvent> {
  @override
  bool canHandle(Object event) => event is WebsocketUserUpdate;

  @override
  Future<UserProfileUpdatedEvent?> transform(
      Object event,
      EnrichedUserLoader getEnrichedUser,
      ) async {
    final update = event as WebsocketUserUpdate;
    final user = update.user;

    return UserProfileUpdatedEvent(
      userId: user.id,
      displayName: user.displayName,
      status: user.status.value,
      statusDescription: user.statusDescription,
    );
  }
}

/// Transforms current-user location transitions into [UserLocationUpdatedEvent].
class UserLocationTransformer
    implements VrcEventTransformer<UserLocationUpdatedEvent> {
  @override
  bool canHandle(Object event) => event is WebsocketUserLocation;

  @override
  Future<UserLocationUpdatedEvent?> transform(
      Object event,
      EnrichedUserLoader getEnrichedUser,
      ) async {
    final locationEvent = event as WebsocketUserLocation;
    return UserLocationUpdatedEvent(
      userId: locationEvent.userId,
      location: locationEvent.location,
    );
  }
}

Future<({String displayName, List<String> tags, String avatarUrl})>
_loadSenderInfo(
    String senderId,
    EnrichedUserLoader getEnrichedUser,
    ) async {
  final userData = await getEnrichedUser(senderId);
  if (userData == null) {
    return (displayName: senderId, tags: const <String>[], avatarUrl: '');
  }

  final avatarUrl = VrcImageMapper.mapAvatarUrl(
    userIcon: userData.iconUrl,
    thumbnail: userData.currentAvatarThumbnailImageUrl,
    currentAvatar: userData.currentAvatarImageUrl,
  );

  return (
  displayName: userData.displayName,
  tags: userData.tags,
  avatarUrl: avatarUrl,
  );
}