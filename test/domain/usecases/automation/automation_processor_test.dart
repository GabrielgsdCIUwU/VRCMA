import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/usecases/automation/automation_processor.dart';
import 'package:vrcma/domain/usecases/automation/handlers/automation_handler.dart';
import 'package:vrcma/domain/usecases/automation/process_invitation_use_case.dart';

import '../../../helpers/test_mocks.mocks.dart';

void main() {
  late AutomationProcessor processor;
  late MockIAutomationRepository mockAutomationRepo;
  late MockILocalSocialRepository mockLocalSocialRepo;
  late MockIProfileRepository mockProfileRepo;
  late MockILogRepository mockLogRepo;
  late MockProcessInvitationUseCase mockUseCase;
  late MockMessageSlotManager mockSlotManager;
  
  const currentUserId = 'usr_9876';

  final requestEvent = RequestInviteEvent(
    id: 'not_123',
    senderId: 'usr_123',
    senderName: 'TestUser',
    senderTags: const ['system_trust_veteran'],
    avatarUrl: 'http://avatar.url',
  );

  final inviteEvent = InviteReceivedEvent(
    id: 'not_456',
    senderId: 'usr_456',
    senderName: 'TestUser2',
    senderTags: const ['system_trust_basic'],
    avatarUrl: 'http://avatar2.url',
  );

  final friendRequestEvent = const FriendRequestReceivedEvent(
    id: 'not_789',
    senderId: 'usr_789',
    senderName: 'EBoy',
    senderTags: [],
    avatarUrl: 'https://average.vrchat/player.png',
  );

  final role = Role(id: 1, name: 'Trusted User');

  final message = CustomMessage(
      id: 1,
      content: 'Welcome!',
      type: VrcMessageType.request,
      lastUpdated: DateTime.now()
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
    mockLogRepo = MockILogRepository();
    mockUseCase = MockProcessInvitationUseCase();
    mockSlotManager = MockMessageSlotManager();

    final List<AutomationEventHandler> handlers = [
      InvitationAutomationHandler(
        automationRepository: mockAutomationRepo,
        localSocialRepository: mockLocalSocialRepo,
        profileRepository: mockProfileRepo,
        logRepository: mockLogRepo,
        useCase: mockUseCase,
        currentUserId: currentUserId,
        slotManager: mockSlotManager,
      ),
      FriendRequestAutomationHandler(
        automationRepository: mockAutomationRepo,
        localSocialRepository: mockLocalSocialRepo,
        profileRepository: mockProfileRepo,
        logRepository: mockLogRepo,
        useCase: mockUseCase,
      ),
    ];

    processor = AutomationProcessor(handlers);

    when(mockLogRepo.saveLog(
      vrcUserId: anyNamed('vrcUserId'),
      displayName: anyNamed('displayName'),
      avatarUrl: anyNamed('avatarUrl'),
      invitationType: anyNamed('invitationType'),
      action: anyNamed('action'),
      appliedRule: anyNamed('appliedRule'),
    )).thenAnswer((_) async {});
  });

  group('AutomationProcessor Pipeline & Handlers Integration', () {

    test('should abort execution if no active profile exists', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => []);

      await processor.process(requestEvent);

      verify(mockProfileRepo.getProfiles());
      verifyNoMoreInteractions(mockLocalSocialRepo);
      verifyNoMoreInteractions(mockUseCase);
    });

    test('should log IGNORED and abort if no rule matches (useCase returns null)', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(requestEvent.senderId)).thenAnswer((_) async => []);

      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(null);

      await processor.process(requestEvent);

      verify(mockLogRepo.saveLog(
        vrcUserId: requestEvent.senderId,
        displayName: requestEvent.senderName,
        avatarUrl: requestEvent.avatarUrl,
        invitationType: 'REQUEST',
        action: 'IGNORED',
        appliedRule: profile.name,
      ));
      verifyNever(mockSlotManager.prepareSlotForMessage(any, any));
      verifyNever(mockAutomationRepo.acceptRequestInvitation(any, any));
    });

    test('should prepare slot and ACCEPT RequestInvite when rule matches', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(requestEvent.senderId)).thenAnswer((_) async => []);

      final tResult = ProcessInvitationResult(action: RuleAction.accept, rule: rule);
      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(tResult);

      when(mockSlotManager.prepareSlotForMessage(currentUserId, message))
          .thenAnswer((_) async => 3);

      when(mockAutomationRepo.acceptRequestInvitation(requestEvent, 3))
          .thenAnswer((_) async {});

      await processor.process(requestEvent);

      verify(mockSlotManager.prepareSlotForMessage(currentUserId, message)).called(1);
      verify(mockAutomationRepo.acceptRequestInvitation(requestEvent, 3)).called(1);
      verify(mockLogRepo.saveLog(
        vrcUserId: requestEvent.senderId,
        displayName: requestEvent.senderName,
        avatarUrl: requestEvent.avatarUrl,
        invitationType: 'REQUEST',
        action: 'ACCEPTED',
        appliedRule: '${profile.name}:${rule.role.name}',
      )).called(1);
    });

    test('should prepare slot and REJECT with message when decision is reject and has message', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(requestEvent.senderId)).thenAnswer((_) async => []);

      final rejectRule = rule.copyWith(action: RuleAction.reject);
      final result = ProcessInvitationResult(action: RuleAction.reject, rule: rejectRule);

      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(result);

      when(mockSlotManager.prepareSlotForMessage(currentUserId, message))
          .thenAnswer((_) async => 5);

      when(mockAutomationRepo.rejectNotificationWithMessage(requestEvent, 5))
          .thenAnswer((_) async {});

      await processor.process(requestEvent);

      verify(mockSlotManager.prepareSlotForMessage(currentUserId, message));
      verify(mockAutomationRepo.rejectNotificationWithMessage(requestEvent, 5));
      verify(mockLogRepo.saveLog(
        vrcUserId: requestEvent.senderId,
        displayName: requestEvent.senderName,
        avatarUrl: requestEvent.avatarUrl,
        invitationType: 'REQUEST',
        action: 'REJECTED',
        appliedRule: '${profile.name}:${rule.role.name}',
      ));
    });

    test('should dismiss notification without message when REJECT decision has NO message', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(requestEvent.senderId)).thenAnswer((_) async => []);

      final ruleNoMsg = rule.copyWith(
          action: RuleAction.reject,
          requestResponseMessage: () => null
      );
      final result = ProcessInvitationResult(action: RuleAction.reject, rule: ruleNoMsg);

      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(result);

      when(mockAutomationRepo.dismissNotification(requestEvent)).thenAnswer((_) async {});

      await processor.process(requestEvent);

      verifyNever(mockSlotManager.prepareSlotForMessage(any, any));
      verify(mockAutomationRepo.dismissNotification(requestEvent));
    });

    test('should ACCEPT InviteReceived (call acceptInvitation) when decision is accept', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(inviteEvent.senderId)).thenAnswer((_) async => []);

      final result = ProcessInvitationResult(action: RuleAction.accept, rule: rule);
      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(result);

      when(mockAutomationRepo.acceptInvitation(inviteEvent)).thenAnswer((_) async {});

      await processor.process(inviteEvent);

      verify(mockAutomationRepo.acceptInvitation(inviteEvent));
      verify(mockLogRepo.saveLog(
        vrcUserId: inviteEvent.senderId,
        displayName: inviteEvent.senderName,
        avatarUrl: inviteEvent.avatarUrl,
        invitationType: 'INVITE',
        action: 'ACCEPTED',
        appliedRule: '${profile.name}:${rule.role.name}',
      ));
    });

    test('should dismiss friend requests directly when rule evaluate returns reject action', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(friendRequestEvent.senderId)).thenAnswer((_) async => []);

      final result = ProcessInvitationResult(action: RuleAction.reject, rule: rule);
      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(result);

      when(mockAutomationRepo.dismissNotification(friendRequestEvent)).thenAnswer((_) async {});

      await processor.process(friendRequestEvent);

      verify(mockAutomationRepo.dismissNotification(friendRequestEvent)).called(1);
      verify(mockLogRepo.saveLog(
        vrcUserId: friendRequestEvent.senderId,
        displayName: friendRequestEvent.senderName,
        avatarUrl: friendRequestEvent.avatarUrl,
        invitationType: 'FRIEND_REQUEST',
        action: 'REJECTED',
        appliedRule: '${profile.name}:${rule.role.name}',
      )).called(1);
    });

    test('should dispatch acceptFriendRequest on FriendRequestReceivedEvent', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [profile]);
      when(mockLocalSocialRepo.getRolesForUser(friendRequestEvent.senderId)).thenAnswer((_) async => []);

      final result = ProcessInvitationResult(action: RuleAction.accept, rule: rule);
      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(result);

      when(mockAutomationRepo.acceptFriendRequest(friendRequestEvent)).thenAnswer((_) async {});

      await processor.process(friendRequestEvent);

      verify(mockAutomationRepo.acceptFriendRequest(friendRequestEvent)).called(1);
    });
  });
}
