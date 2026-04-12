import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/data/mappers/vrc_image_mapper.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

class AutomationRepositoryImp implements IAutomationRepository {
  final VrchatDart _vrcApi;
  
  AutomationRepositoryImp(this._vrcApi);
  
  @override
  Stream<InvitationType> watchInvitations() {
    return _vrcApi.streaming.vrcEventStream
        .where((event) => event is NotificationReceivedEvent)
        .cast<NotificationReceivedEvent>()
        .where((event) =>
          event.notification.type == NotificationType.invite ||
          event.notification.type == NotificationType.requestInvite)
        .asyncMap((event) async {
          try {
            final notification = event.notification;
            final userResponse = await _vrcApi.rawApi.getUsersApi()
                .getUser(userId: notification.senderUserId);

            var userData = userResponse.data;
            
            final avatarUrl = userData == null
              ? ''
              : VrcImageMapper.mapAvatarUrl(
                profilePic: userData.profilePicOverrideThumbnail,
                thumbnail: userData.currentAvatarThumbnailImageUrl,
                currentAvatar: userData.currentAvatarImageUrl,
              );

            if (notification.type == NotificationType.requestInvite) {
              return RequestInvite(
                id: notification.id,
                senderId: notification.senderUserId,
                senderName: userData?.displayName ?? notification.senderUserId,
                senderTags: userData?.tags ?? [],
                avatarUrl: avatarUrl,
              );
            }
            return InviteReceived(
              id: notification.id,
              senderId: notification.senderUserId,
              senderName: userData?.displayName ?? notification.senderUserId,
              senderTags: userData?.tags ?? [],
              avatarUrl: avatarUrl,
            );
          } catch (e) {
            debugPrint("DEBUG: Error asyncMap: $e");
            rethrow;
          }
    });
  }
  @override
  Future<void> acceptRequestInvitation(RequestInvite requestInvite, int? slot) async {
    await _safeApiCall(() async {
      final response = await _vrcApi.rawApi.getAuthenticationApi().getCurrentUser();
      final currentUser = response.data;

      if (currentUser == null) return;

      final presence = currentUser.presence;
      final world = presence?.world;
      final instanceId = presence?.instance;

      if (presence == null || world == null || world == 'offline' || world.isEmpty) return;


      await _vrcApi.rawApi.getInviteApi().inviteUser(
          userId: requestInvite.senderId,
          inviteRequest: InviteRequest(
              instanceId: "$world:$instanceId",
              messageSlot: slot
          )
      );  
    });
    
    await dismissNotification(requestInvite);
  }
  
  @override
  Future<void> acceptInvitation(InviteReceived invite) async {
    //! VRChat doesn't allow to accept invitations by API, so we just dismiss them for now.
    await dismissNotification(invite);
  }
  
  @override
  Future<void> rejectNotificationWithMessage(InvitationType notification, int slot) async {
    await _safeApiCall(() async {
      await _vrcApi.rawApi.getInviteApi().respondInvite(
          notificationId: notification.id,
          inviteResponse: InviteResponse(responseSlot: slot)
      );
    });
  }
  
  @override
  Future<void> dismissNotification(InvitationType notification) async {
    await _safeApiCall(() async {
      await _vrcApi.rawApi.getNotificationsApi().deleteNotification(
          notificationId: notification.id
      );  
    });
  }
  
  @override
  Future<void> updateVrcMessageSlot({required String userId, required String messageType, required int slot, required String content, required VrcMessageType type}) async {
    try {
      final vrcType = _mapInternalToVrcType(type);

      await _vrcApi.rawApi.getInviteApi().updateInviteMessage(
        userId: userId,
        messageType: vrcType,
        slot: slot,
        updateInviteMessageRequest: UpdateInviteMessageRequest(
            message: content),
      );
    } catch (e) {
      debugPrint("VRChat API Error (Update Slot): $e");
      rethrow;
    }
  }
  
  @override
  Future<List<VrcRemoteMessage>> getRemoteVrcMessages(String userId, VrcMessageType type) async {
    final vrcType = _mapInternalToVrcType(type);
    
    final response = await _vrcApi.rawApi.getInviteApi().getInviteMessages(
        userId: userId,
        messageType: vrcType,
    );
    
    return response.data?.map((m) => VrcRemoteMessage(
      slot: m.slot,
      content: m.message,
      type: type,
      lastUpdated: m.updatedAt
    )).toList() ?? [];
  }
  
  InviteMessageType _mapInternalToVrcType(VrcMessageType type) {
    switch (type) {
      case VrcMessageType.invite: return InviteMessageType.message;
      case VrcMessageType.response: return InviteMessageType.response;
      case VrcMessageType.request: return InviteMessageType.request;
      case VrcMessageType.requestResponse: return InviteMessageType.requestResponse;
    }
  }

  Future<void> _safeApiCall(Future<dynamic> Function() call) async {
    try {
      await call();
    } catch (e) {
      if (e.toString().contains("CheckedFromJsonException") ||
          e.toString().contains("created_at")) {
        //* Inconsistent data, ignore for now
        return;
      }
      rethrow;
    }
  }
}