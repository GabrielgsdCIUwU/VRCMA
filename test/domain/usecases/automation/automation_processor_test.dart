import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';
import 'package:vrcma/domain/services/app_logger.dart';
import 'package:vrcma/domain/usecases/automation/automation_processor.dart';
import 'package:vrcma/domain/usecases/automation/handlers/automation_handler.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';

import '../../../helpers/test_mocks.mocks.dart';

void main() {
  late AutomationProcessor processor;
  late MockIAutomationRepository mockAutomationRepo;
  late MockILocalSocialRepository mockLocalSocialRepo;
  late MockIProfileRepository mockProfileRepo;
  late MockIAppLogRepository mockLogRepo;
  late MockProcessInvitationUseCase mockUseCase;
  late MockMessageSlotManager mockSlotManager;

  const currentUserId = 'usr_9876';

  const requestEvent = RequestInviteEvent(
    id: 'not_123',
    senderId: 'usr_123',
    senderName: 'TestUser',
    senderTags: ['system_trust_veteran'],
    avatarUrl: 'http://avatar.url',
  );

  const inviteEvent = InviteReceivedEvent(
    id: 'not_456',
    senderId: 'usr_456',
    senderName: 'TestUser2',
    senderTags: ['system_trust_basic'],
    avatarUrl: 'http://avatar2.url',
  );

  const friendRequestEvent = FriendRequestReceivedEvent(
    id: 'not_789',
    senderId: 'usr_789',
    senderName: 'EBoy',
    senderTags: [],
    avatarUrl: 'https://average.vrchat/player.png',
  );

  const role = Role(id: 1, name: 'Trusted User');

  final message = CustomMessage(
    id: 1,
    content: 'Welcome!',
    type: VrcMessageType.invite,
    lastUpdated: DateTime.now(),
  );

  final rule = ProfileRule(
    id: 1,
    role: role,
    priority: 0,
    action: RuleAction.accept,
    requestResponseMessage: message,
  );

  final profile = FilterProfile(
    id: 1,
    name: 'Main Profile',
    isActive: true,
    rules: [rule],
  );

  setUp(() {
    mockAutomationRepo = MockIAutomationRepository();
    mockLocalSocialRepo = MockILocalSocialRepository();
    mockProfileRepo = MockIProfileRepository();
    mockLogRepo = MockIAppLogRepository();
    mockUseCase = MockProcessInvitationUseCase();
    mockSlotManager = MockMessageSlotManager();

    final List<AutomationEventHandler> handlers = [
      InvitationAutomationHandler(
        automationRepository: mockAutomationRepo,
        localSocialRepository: mockLocalSocialRepo,
        profileRepository: mockProfileRepo,
        logger: AppLogger(mockLogRepo),
        useCase: mockUseCase,
        currentUserId: currentUserId,
        slotManager: mockSlotManager,
      ),
      FriendRequestAutomationHandler(
        automationRepository: mockAutomationRepo,
        localSocialRepository: mockLocalSocialRepo,
        profileRepository: mockProfileRepo,
        logger: AppLogger(mockLogRepo),
        useCase: mockUseCase,
      ),
    ];

    processor = AutomationProcessor(handlers);

    when(mockLogRepo.saveLog(any)).thenAnswer((_) async {});
  });

  group('AutomationProcessor Pipeline & Handlers Integration', () {
    test('should abort execution if no active profile exists', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => []);

      await processor.process(requestEvent);

      verify(mockProfileRepo.getProfiles());
      verifyNoMoreInteractions(mockLocalSocialRepo);
      verifyNoMoreInteractions(mockUseCase);
    });

    test('should log IGNORED and abort if no rule matches', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(requestEvent.senderId)).thenAnswer((_) async => []);

      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(null);

      await processor.process(requestEvent);

      final capturedLog = verify(mockLogRepo.saveLog(captureAny)).captured.single as AppLog;
      expect(capturedLog.category, LogCategory.invitation);
      expect(capturedLog.metadata, isA<InvitationLogMetadata>());

      final meta = capturedLog.metadata as InvitationLogMetadata;
      expect(meta.action, InvitationActionOutcome.ignored);
      expect(meta.senderId, requestEvent.senderId);

      verifyNever(mockSlotManager.prepareSlotForMessage(any, any));
      verifyNever(mockAutomationRepo.acceptRequestInvitation(any, any));
    });

    test('should prepare slot and ACCEPT RequestInvite when rule matches', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(requestEvent.senderId)).thenAnswer((_) async => []);

      final tDecision = MatchedRuleDecision(action: RuleAction.accept, rule: rule);
      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(tDecision);

      when(mockSlotManager.prepareSlotForMessage(currentUserId, message))
          .thenAnswer((_) async => 3);

      when(mockAutomationRepo.acceptRequestInvitation(requestEvent, 3))
          .thenAnswer((_) async {});

      await processor.process(requestEvent);

      verify(mockSlotManager.prepareSlotForMessage(currentUserId, message)).called(1);
      verify(mockAutomationRepo.acceptRequestInvitation(requestEvent, 3)).called(1);

      final capturedLog = verify(mockLogRepo.saveLog(captureAny)).captured.single as AppLog;
      expect(capturedLog.category, LogCategory.invitation);
      expect(capturedLog.severity, LogSeverity.info);

      final meta = capturedLog.metadata as InvitationLogMetadata;
      expect(meta.action, InvitationActionOutcome.accepted);
      expect(meta.senderId, requestEvent.senderId);
    });

    test('should prepare slot and REJECT with message when decision is reject and contains message', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(requestEvent.senderId)).thenAnswer((_) async => []);

      final rejectMessage = CustomMessage(
        id: 2,
        content: 'Rejected',
        type: VrcMessageType.requestResponse,
        lastUpdated: DateTime.now(),
      );

      final rejectRule = rule.copyWith(
        action: RuleAction.reject,
        requestResponseMessage: () => rejectMessage,
      );
      final decision = MatchedRuleDecision(action: RuleAction.reject, rule: rejectRule);

      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(decision);

      when(mockSlotManager.prepareSlotForMessage(currentUserId, rejectMessage))
          .thenAnswer((_) async => 5);

      when(mockAutomationRepo.rejectNotificationWithMessage(requestEvent, 5))
          .thenAnswer((_) async {});

      await processor.process(requestEvent);

      verify(mockSlotManager.prepareSlotForMessage(currentUserId, rejectMessage));
      verify(mockAutomationRepo.rejectNotificationWithMessage(requestEvent, 5));

      final capturedLog = verify(mockLogRepo.saveLog(captureAny)).captured.single as AppLog;
      expect(capturedLog.category, LogCategory.invitation);
      expect(capturedLog.severity, LogSeverity.warning);

      final meta = capturedLog.metadata as InvitationLogMetadata;
      expect(meta.action, InvitationActionOutcome.rejected);
      expect(meta.senderId, requestEvent.senderId);
    });

    test('should dismiss notification without message when REJECT decision has no message', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(requestEvent.senderId)).thenAnswer((_) async => []);

      final ruleNoMsg = rule.copyWith(
        action: RuleAction.reject,
        requestResponseMessage: () => null,
      );
      final decision = MatchedRuleDecision(action: RuleAction.reject, rule: ruleNoMsg);

      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(decision);

      when(mockAutomationRepo.dismissNotification(requestEvent)).thenAnswer((_) async {});

      await processor.process(requestEvent);

      verifyNever(mockSlotManager.prepareSlotForMessage(any, any));
      verify(mockAutomationRepo.dismissNotification(requestEvent));
    });

    test('should ACCEPT InviteReceived when decision is accept', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(inviteEvent.senderId)).thenAnswer((_) async => []);

      final decision = MatchedRuleDecision(action: RuleAction.accept, rule: rule);
      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(decision);

      when(mockAutomationRepo.acceptInvitation(inviteEvent)).thenAnswer((_) async {});

      await processor.process(inviteEvent);

      verify(mockAutomationRepo.acceptInvitation(inviteEvent));

      final capturedLog = verify(mockLogRepo.saveLog(captureAny)).captured.single as AppLog;
      expect(capturedLog.category, LogCategory.invitation);

      final meta = capturedLog.metadata as InvitationLogMetadata;
      expect(meta.action, InvitationActionOutcome.accepted);
      expect(meta.senderId, inviteEvent.senderId);
    });

    test('should dismiss friend requests directly when rule decision returns reject action', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(friendRequestEvent.senderId)).thenAnswer((_) async => []);

      final decision = MatchedRuleDecision(action: RuleAction.reject, rule: rule);
      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(decision);

      when(mockAutomationRepo.dismissNotification(friendRequestEvent)).thenAnswer((_) async {});

      await processor.process(friendRequestEvent);

      verify(mockAutomationRepo.dismissNotification(friendRequestEvent)).called(1);

      final capturedLog = verify(mockLogRepo.saveLog(captureAny)).captured.single as AppLog;
      expect(capturedLog.category, LogCategory.invitation);
      expect(capturedLog.severity, LogSeverity.warning);

      final meta = capturedLog.metadata as InvitationLogMetadata;
      expect(meta.action, InvitationActionOutcome.rejected);
      expect(meta.senderId, friendRequestEvent.senderId);
    });

    test('should dispatch acceptFriendRequest on FriendRequestReceivedEvent when accepted', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(friendRequestEvent.senderId)).thenAnswer((_) async => []);

      final decision = MatchedRuleDecision(action: RuleAction.accept, rule: rule);
      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(decision);

      when(mockAutomationRepo.acceptFriendRequest(friendRequestEvent)).thenAnswer((_) async {});

      await processor.process(friendRequestEvent);

      verify(mockAutomationRepo.acceptFriendRequest(friendRequestEvent)).called(1);
    });
  });
}
