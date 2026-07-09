import 'package:vrcma/data/mappers/vrc_image_mapper.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrchat_dart/vrchat_dart.dart';


abstract class VrcEventTransformer<T extends VrcAutomationEvent> {
  /// Determines if this transformer can map the incoming streaming event.
  bool canHandle(VrcStreamingEvent event);

  /// Converts the raw streaming event into a clean domain automation event.
  Future<T?> transform(
    VrcStreamingEvent event,
    Future<User?> Function(String userId) getEnrichedUser,
  );
}

class FriendRequestTransformer implements VrcEventTransformer<FriendRequestReceivedEvent> {
  @override
  bool canHandle(VrcStreamingEvent event) {
    return event is NotificationReceivedEvent &&
      event.notification.type == NotificationType.friendRequest;    
  }

  @override
  Future<FriendRequestReceivedEvent?> transform(
    VrcStreamingEvent event,
    Future<User?> Function(String) getEnrichedUser,
  ) async {
    final notificationEvent = event as NotificationReceivedEvent;
    final notification = notificationEvent.notification;
    final String senderId = notification.senderUserId;

    if (senderId.isEmpty) return null;

    final userData = await getEnrichedUser(senderId);
    final avatarUrl = userData == null
      ? ''
      : VrcImageMapper.mapAvatarUrl(
        profilePic: userData.profilePicOverrideThumbnail,
        thumbnail: userData.currentAvatarThumbnailImageUrl,
        currentAvatar: userData.currentAvatarImageUrl,
      );
    
    return FriendRequestReceivedEvent(
      id: notification.id,
      senderId: senderId,
      senderName: userData?.displayName ?? senderId,
      senderTags: userData?.tags ?? const [],
      avatarUrl: avatarUrl,
    );
  }
}

class InviteReceivedTransformer implements VrcEventTransformer<InviteReceivedEvent> {
  @override
  bool canHandle(VrcStreamingEvent event) {
    return event is NotificationReceivedEvent &&
      event.notification.type == NotificationType.invite;    
  }

  @override
  Future<InviteReceivedEvent?> transform(
    VrcStreamingEvent event,
    Future<User?> Function(String) getEnrichedUser,
  ) async {
    final notificationEvent = event as NotificationReceivedEvent;
    final notification = notificationEvent.notification;
    final String senderId = notification.senderUserId;

    if (senderId.isEmpty) return null;

    final userData = await getEnrichedUser(senderId);
    final avatarUrl = userData == null
      ? ''
      : VrcImageMapper.mapAvatarUrl(
        profilePic: userData.profilePicOverrideThumbnail,
        thumbnail: userData.currentAvatarThumbnailImageUrl,
        currentAvatar: userData.currentAvatarImageUrl,
      );
    
    return InviteReceivedEvent(
      id: notification.id,
      senderId: senderId,
      senderName: userData?.displayName ?? senderId,
      senderTags: userData?.tags ?? const [],
      avatarUrl: avatarUrl,
    );
  }
}

class RequestReceivedTransformer implements VrcEventTransformer<RequestInviteEvent> {
  @override
  bool canHandle(VrcStreamingEvent event) {
    return event is NotificationReceivedEvent &&
      event.notification.type == NotificationType.requestInvite;    
  }

  @override
  Future<RequestInviteEvent?> transform(
    VrcStreamingEvent event,
    Future<User?> Function(String) getEnrichedUser,
  ) async {
    final notificationEvent = event as NotificationReceivedEvent;
    final notification = notificationEvent.notification;
    final String senderId = notification.senderUserId;

    if (senderId.isEmpty) return null;

    final userData = await getEnrichedUser(senderId);
    final avatarUrl = userData == null
      ? ''
      : VrcImageMapper.mapAvatarUrl(
        profilePic: userData.profilePicOverrideThumbnail,
        thumbnail: userData.currentAvatarThumbnailImageUrl,
        currentAvatar: userData.currentAvatarImageUrl,
      );
    
    return RequestInviteEvent(
      id: notification.id,
      senderId: senderId,
      senderName: userData?.displayName ?? senderId,
      senderTags: userData?.tags ?? const [],
      avatarUrl: avatarUrl,
    );
  }
}