import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';

void main() {
  group('AppLog Entity Tests', () {
    final timestamp = DateTime.utc(2026, 8, 25, 13, 41);

    test('should maintain value equality when all properties match', () {
      const metadata = SystemLogMetadata({'subsystem': 'baterry_poller'});

      final log1 = AppLog(
        id: 1,
        timestamp: timestamp,
        category: LogCategory.system,
        severity: LogSeverity.info,
        message: 'Poller started',
        details: null,
        metadata: metadata
      );

      final log2 = AppLog(
        id: 1,
        timestamp: timestamp,
        category: LogCategory.system,
        severity: LogSeverity.info,
        message: 'Poller started',
        details: null,
        metadata: metadata,
      );

      expect(log1, equals(log2));
      expect(log1.hashCode, equals(log2.hashCode));
    });

    test('should differenciate logs when properties vary', () {
      const metadata = SystemLogMetadata();

      final log1 = AppLog(
        id: 1,
        timestamp: timestamp,
        category: LogCategory.system,
        severity: LogSeverity.info,
        message: 'Message A',
        metadata: metadata,
      );

      final log2 = AppLog(
        id: 1,
        timestamp: timestamp,
        category: LogCategory.system,
        severity: LogSeverity.warning,
        message: 'Message B',
        metadata: metadata,
      );

      expect(log1, isNot(equals(log2)));
    });
  });

  group('LogMetadata Polymorphic Hierarchy & Serialization Tests', () {
    test('InvitationLogMetadata serialization and deserialization roundtrip', () {
      const original = InvitationLogMetadata(
        senderId: 'usr_123',
        senderName: 'Gabrielgsd',
        senderAvatarUrl: 'https://avatars.githubusercontent.com/u/104272301',
        action: InvitationActionOutcome.accepted,
        eventType: IncomingEventType.request,
        profileName: 'Default Profile',
        matchedRoleName: 'VIP',
      );

      final json = original.toJson();
      final restored = InvitationLogMetadata.fromJson(json);

      expect(restored, equals(original));
      expect(restored.senderId, 'usr_123');
      expect(restored.action, InvitationActionOutcome.accepted);
      expect(restored.eventType, IncomingEventType.request);
    });

    test('StatusLogMetadata serialization and deserialization roundtrip', () {
      const original = StatusLogMetadata(
        profileId: 42,
        status: StatusType.joinMe,
        description: 'Journalism'
      );

      final json = original.toJson();
      final restored = StatusLogMetadata.fromJson(json);

      expect(restored, equals(original));
      expect(restored.profileId, 42);
      expect(restored.status, StatusType.joinMe);
    });

    test('CalendarLogMetadata serialization and deserialization roundtrip', () {
      final occurrence = DateTime.utc(2026, 8, 29, 17);
      final original = CalendarLogMetadata(
        ruleId: 5,
        ruleName: 'Weekly Chill <>< Meetup',
        eventId: 'cal_event_32',
        occurrenceUtc: occurrence,
        groupId: 'grp_52bf6a2e-4bb9-4e20-84ef-206b21218970',
      );

      final json = original.toJson();
      final restored = CalendarLogMetadata.fromJson(json);

      expect(restored, equals(original));
      expect(restored.occurrenceUtc, occurrence);
      expect(restored.groupId, 'grp_52bf6a2e-4bb9-4e20-84ef-206b21218970');
    });

    test('SocialLogMetadata serialization and deserialization roundtrip', () {
      const original = SocialLogMetadata(
        targetUserId: 'usr_friend_1',
        targetUserName: 'Jaimito',
        assignedRoleNames: ['Moderator', 'VIP'],
        trigger: SocialAssignmentTrigger.tagMatch,
      );

      final json = original.toJson();
      final restored = SocialLogMetadata.fromJson(json);

      expect(restored, equals(original));
      expect(restored.assignedRoleNames, containsAll(['Moderator', 'VIP']));
      expect(restored.trigger, SocialAssignmentTrigger.tagMatch);
    });

    test('AuthLogMetadata serialization and deserialization roundtrip', () {
      const original = AuthLogMetadata(
        userId: 'usr_me',
        displayName: 'Owner',
        event: AuthLogEvent.loginSuccess,
      );

      final json = original.toJson();
      final restored = AuthLogMetadata.fromJson(json);

      expect(restored, equals(original));
      expect(restored.event, AuthLogEvent.loginSuccess);
    });

    test('SystemLogMetadata serialization and deserialization roundtrip', () {
      const original = SystemLogMetadata({'key': 'value', 'code': 200});

      final json = original.toJson();
      final restored = SystemLogMetadata.fromJson(json);

      expect(restored, equals(original));
    });

    test('LogMetadata.fromJson factory correctly resolves metadata type by category', () {
      final invitationJson = {
        'senderId': 'usr_1',
        'senderName': 'Test',
        'senderAvatarUrl': '',
        'action': 'accepted',
        'eventType': 'invite',
        'profileName': 'Profile 1',
      };

      final metadata = LogMetadata.fromJson(LogCategory.invitation, invitationJson);
      expect(metadata, isA<InvitationLogMetadata>());
    });
  });

  group('Log Enums Parsing & Fallback Tests', () {
    test('LogCategory.fromString parses valid values and falls back safely to system', () {
      expect(LogCategory.fromString('invitation'), LogCategory.invitation);
      expect(LogCategory.fromString('status'), LogCategory.status);
      expect(LogCategory.fromString('calendar'), LogCategory.calendar);
      expect(LogCategory.fromString('social'), LogCategory.social);
      expect(LogCategory.fromString('auth'), LogCategory.auth);
      expect(LogCategory.fromString('system'), LogCategory.system);
      expect(LogCategory.fromString('unknown_category'), LogCategory.system);
    });

    test('LogSeverity.fromString parses valid values and falls back to info', () {
      expect(LogSeverity.fromString('info'), LogSeverity.info);
      expect(LogSeverity.fromString('warning'), LogSeverity.warning);
      expect(LogSeverity.fromString('error'), LogSeverity.error);
      expect(LogSeverity.fromString('unrecognized'), LogSeverity.info);
    });

    test('InvitationActionOutcome.fromString parses valid values and falls back to ignored', () {
      expect(InvitationActionOutcome.fromString('accepted'), InvitationActionOutcome.accepted);
      expect(InvitationActionOutcome.fromString('rejected'), InvitationActionOutcome.rejected);
      expect(InvitationActionOutcome.fromString('ignored'), InvitationActionOutcome.ignored);
      expect(InvitationActionOutcome.fromString('other'), InvitationActionOutcome.ignored);
    });
  });
}