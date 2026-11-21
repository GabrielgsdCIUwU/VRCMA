import 'package:flutter_test/flutter_test.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/data/transformers/vrc_event_transformer.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';

class _FakeInviteDetails extends Fake implements NotificationDetailInvite {}

class _FakeRequestInviteDetails extends Fake
    implements NotificationDetailRequestInvite {}

void main() {
  group('VrcEventTransformers Payload Extraction', () {
    final mockUser = UserResponse(
      id: 'usr_123',
      displayName: 'EnrichedUser',
      tags: ['system_trust_veteran'],
      currentAvatarThumbnailImageUrl: 'https://cdn.vrchat.com/pic.png',
      currentAvatarImageUrl: '',
      developerType: DeveloperType.none,
      lastPlatform: '',
      dateJoined: DateTime.now(),
      friendKey: '',
      isFriend: false,
      lastLogin: DateTime.now().toIso8601String(),
      state: UserState.active,
      status: UserStatus.active,
      statusDescription: '',
      ageVerificationStatus: AgeVerificationStatus.verified,
      ageVerified: true,
      allowAvatarCopying: false,
      pronouns: '',
    );

    Future<UserResponse?> mockGetEnrichedUser(String id) async =>
        id == 'usr_123' ? mockUser : null;

    test('FriendRequestTransformer should map WebsocketNotificationUnknown friendRequest', () async {
      final transformer = FriendRequestTransformer();
      final event = WebsocketNotificationUnknown(
        id: 'not_001',
        senderUserId: 'usr_123',
        type: 'friendRequest',
        createdAt: DateTime.now(),
        message: '',
      );

      expect(transformer.canHandle(event), isTrue);

      final result = await transformer.transform(event, mockGetEnrichedUser);

      expect(result, isA<FriendRequestReceivedEvent>());
      expect(result?.senderId, 'usr_123');
      expect(result?.senderName, 'EnrichedUser');
      expect(result?.avatarUrl, 'https://cdn.vrchat.com/pic.png');
      expect(result?.senderTags, contains('system_trust_veteran'));
    });

    test('InviteReceivedTransformer should fallback safely if user enrichment fails', () async {
      final transformer = InviteReceivedTransformer();
      final event = WebsocketNotificationDetailInvite(
        id: 'not_002',
        senderUserId: 'usr_unknown',
        type: WebsocketNotificationDetailInviteTypeEnum.invite,
        createdAt: DateTime.now(),
        message: '',
        details: _FakeInviteDetails(),
      );

      expect(transformer.canHandle(event), isTrue);

      final result = await transformer.transform(event, mockGetEnrichedUser);

      expect(result, isA<InviteReceivedEvent>());
      expect(result?.senderName, 'usr_unknown');
      expect(result?.avatarUrl, isEmpty);
      expect(result?.senderTags, isEmpty);
    });

    test('RequestReceivedTransformer should handle only request-invite payloads', () {
      final transformer = RequestReceivedTransformer();
      final inviteEvent = WebsocketNotificationDetailInvite(
        id: 'not_err',
        senderUserId: 'usr_1',
        type: WebsocketNotificationDetailInviteTypeEnum.invite,
        createdAt: DateTime.now(),
        message: '',
        details: _FakeInviteDetails(),
      );
      final requestEvent = WebsocketNotificationDetailRequestInvite(
        id: 'not_ok',
        senderUserId: 'usr_1',
        type: WebsocketNotificationDetailRequestInviteTypeEnum.requestInvite,
        createdAt: DateTime.now(),
        message: '',
        details: _FakeRequestInviteDetails(),
      );

      expect(transformer.canHandle(inviteEvent), isFalse);
      expect(transformer.canHandle(requestEvent), isTrue);
    });
  });
}