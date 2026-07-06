import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/data/transformers/vrc_event_transformer.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';

class AutomationRepositoryImp implements IAutomationRepository {
  final VrchatDart _vrcApi;
  final List<VrcEventTransformer> _transformers;

  final Map<String, (User, DateTime)> _userCache = {};
  static const Duration _cacheExpirationLimit = Duration(hours: 1);
  
  AutomationRepositoryImp(this._vrcApi, this._transformers);

  Future<User?> _getEnrichedUser(String userId) async {
    final now = DateTime.now();
    if (_userCache.containsKey(userId)) {
      final (cachedUser, cachedTime) = _userCache[userId]!;
      if (now.difference(cachedTime) < _cacheExpirationLimit) {
        return cachedUser;
      }
    }

    try {
      final response = await _vrcApi.rawApi.getUsersApi().getUser(userId: userId);
      final userData = response.data;
      if (userData != null) {
        _userCache[userId] = (userData, now);
        return userData;
      }
    } catch (e) {
      debugPrint("Error fetching user data from API: $e");
    }
    return null;
  }
  
  @override
  Stream<VrcAutomationEvent> watchAutomationEvents() {
    return _vrcApi.streaming.vrcEventStream
        .asyncMap((vrcEvent) async {
          for (final transfromer in _transformers) {
            if (transfromer.canHandle(vrcEvent)) {
              return await transfromer.transform(vrcEvent, _getEnrichedUser);
            }
          }
          return null;
        })
        .where((event) => event != null)
        .cast<VrcAutomationEvent>();
  }
  @override
  Future<void> acceptRequestInvitation(RequestInviteEvent requestInvite, int? slot) async {
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
  Future<void> acceptInvitation(InviteReceivedEvent invite) async {
    //! VRChat doesn't allow to accept invitations by API, so we just dismiss them for now.
    await dismissNotification(invite);
  }

  @override
  Future<void> acceptFriendRequest(FriendRequestReceivedEvent request) async {
    await _safeApiCall(() async {
      await _vrcApi.rawApi.getNotificationsApi().acceptFriendRequest(notificationId: request.id);
    });
  }
  
  @override
  Future<void> rejectNotificationWithMessage(IncomingUserEvent notification, int slot) async {
    await _safeApiCall(() async {
      await _vrcApi.rawApi.getInviteApi().respondInvite(
          notificationId: notification.id,
          inviteResponse: InviteResponse(responseSlot: slot)
      );
    });
  }
  
  @override
  Future<void> dismissNotification(IncomingUserEvent notification) async {
    await _safeApiCall(() async {
      await _vrcApi.rawApi.getNotificationsApi().deleteNotification(
          notificationId: notification.id
      );  
    });
  }
  
  @override
  Future<Either<Failure, void>> updateVrcMessageSlot({required String userId, required String messageType, required int slot, required String content, required VrcMessageType type}) async {
    try {
      final vrcType = _mapInternalToVrcType(type);

      await _vrcApi.rawApi.getInviteApi().updateInviteMessage(
        userId: userId,
        messageType: vrcType,
        slot: slot,
        updateInviteMessageRequest: UpdateInviteMessageRequest(
            message: content),
      );
      return const Right(null);
    } catch (e) {
      if (e.toString().contains("429")) {
       return const Left(RateLimitFailure(60));
      }
      debugPrint("VRChat API Error (Update Slot): $e");
      return Left(ApiFailure(e.toString()));
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