import 'package:flutter_test/flutter_test.dart';
import 'package:vrchat_dart/vrchat_dart.dart';
import 'package:vrcma/data/transformers/vrc_event_transformer.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';

void main() {
  group('VrcEventTransformers Payload Extraction', () {
    final mockUser = User(
      id: 'usr_123',
      displayName: 'EnrichedUser',
      tags: ['system_trust_veteran'],
      profilePicOverrideThumbnail: 'https://cdn.vrchat.com/pic.png',
      currentAvatarThumbnailImageUrl: '', currentAvatarImageUrl: '', developerType: DeveloperType.none, lastPlatform: '', profilePicOverride: '', allowAvatarCopying: false, bio: '', bioLinks: [], dateJoined: DateTime.now(), friendKey: '', isFriend: false, lastActivity: '', lastLogin: DateTime.now().toIso8601String(), state: UserState.active, status: UserStatus.active, statusDescription: '', ageVerificationStatus: AgeVerificationStatus.verified, ageVerified: true, currentAvatarTags: [], pronouns: '', userIcon: '',
    );

    Future<User?> mockGetEnrichedUser(String id) async => id == 'usr_123' ? mockUser : null;

    test('FriendRequestTransformer should correctly map NotificationReceivedEvent', () async {
      final transformer = FriendRequestTransformer();
      final notification = Notification(
        id: 'not_001',
        senderUserId: 'usr_123',
        type: NotificationType.friendRequest,
        createdAt: DateTime.now(), details: '', message: '', receiverUserId: '', senderUsername: '',
      );

      final event = NotificationReceivedEvent(notification: notification);

      expect(transformer.canHandle(event), isTrue);

      final result = await transformer.transform(event, mockGetEnrichedUser);

      expect(result, isA<FriendRequestReceivedEvent>());
      expect(result?.senderId, 'usr_123');
      expect(result?.senderName, 'EnrichedUser');
      expect(result?.avatarUrl, 'https://cdn.vrchat.com/pic.png');
      expect(result?.senderTags, contains('system_trust_veteran'));
    });

    test('InviteReceivedTransformer should safely fallback if user enrichment fails', () async {
      final transformer = InviteReceivedTransformer();
      final notification = Notification(
        id: 'not_002',
        senderUserId: 'usr_unknown',
        type: NotificationType.invite,
        createdAt: DateTime.now(), details: '', message: '', receiverUserId: '', senderUsername: '',
      );

      final event = NotificationReceivedEvent(notification: notification);

      expect(transformer.canHandle(event), isTrue);

      final result = await transformer.transform(event, mockGetEnrichedUser);

      expect(result, isA<InviteReceivedEvent>());
      expect(result?.senderName, 'usr_unknown');
      expect(result?.avatarUrl, isEmpty);
      expect(result?.senderTags, isEmpty);
    });

    test('Transformers should reject handling unrelated events', () {
      final transformer = RequestReceivedTransformer();
      final notification = Notification(
        id: 'not_err',
        senderUserId: 'usr_1',
        type: NotificationType.invite,
        createdAt: DateTime.now(),
        details: '',
        message: '',
        receiverUserId: '',
        senderUsername: '',
      );
      final event = NotificationReceivedEvent(notification: notification);

      expect(transformer.canHandle(event), isFalse);
    });
  });
}