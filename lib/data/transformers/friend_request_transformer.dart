import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/data/mappers/vrc_image_mapper.dart';
import 'package:vrcma/data/transformers/vrc_event_transformer.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';

class FriendRequestTransformer implements VrcEventTransformer<FriendRequestReceivedEvent> {
  @override
  bool canHandle(VrcStreamingEvent event) {
    if (event is! NotificationReceivedEvent) return false;

    return event.notification.type == NotificationType.friendRequest;
  }

  @override
  Future<FriendRequestReceivedEvent?> transform(
    VrcStreamingEvent event,
    Future<User?> Function(String userId) getEnrichedUser,
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
      avatarUrl:  avatarUrl,
    );
  }
}