import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/usecases/automation/automation_processor.dart';
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
  
  const tCurrentUserId = 'usr_9876';

  final tRequestInvite = RequestInvite(
    id: 'not_123',
    senderId: 'usr_123',
    senderName: 'TestUser',
    senderTags: const ['system_trust_veteran'],
    avatarUrl: 'http://avatar.url',
  );

  final tInviteReceived = InviteReceived(
    id: 'not_456',
    senderId: 'usr_456',
    senderName: 'TestUser2',
    senderTags: const ['system_trust_basic'],
    avatarUrl: 'http://avatar2.url',
  );

  final tRole = Role(id: 1, name: 'Trusted User');

  final tMessage = CustomMessage(
      id: 1,
      content: 'Welcome!',
      type: VrcMessageType.request,
      lastUpdated: DateTime.now()
  );

  final tRule = ProfileRule(
    id: 1,
    role: tRole,
    priority: 0,
    action: RuleAction.accept,
    requestResponseMessage: tMessage,
  );

  final tProfile = FilterProfile(
    id: 1,
    name: 'Main Profile',
    isActive: true,
    rules: [tRule],
  );

  setUp(() {
    mockAutomationRepo = MockIAutomationRepository();
    mockLocalSocialRepo = MockILocalSocialRepository();
    mockProfileRepo = MockIProfileRepository();
    mockLogRepo = MockILogRepository();
    mockUseCase = MockProcessInvitationUseCase();
    mockSlotManager = MockMessageSlotManager();

    processor = AutomationProcessor(
      automationRepository: mockAutomationRepo,
      localSocialRepository: mockLocalSocialRepo,
      profileRepository: mockProfileRepo,
      logRepository: mockLogRepo,
      useCase: mockUseCase,
      slotManager: mockSlotManager,
      currentUserId: tCurrentUserId,
    );

    when(mockLogRepo.saveLog(
      vrcUserId: anyNamed('vrcUserId'),
      displayName: anyNamed('displayName'),
      avatarUrl: anyNamed('avatarUrl'),
      invitationType: anyNamed('invitationType'),
      action: anyNamed('action'),
      appliedRule: anyNamed('appliedRule'),
    )).thenAnswer((_) async {});
  });

  group('AutomationProcessor', () {

    test('should abort execution if no active profile exists', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => []);

      await processor.process(tRequestInvite);

      verify(mockProfileRepo.getProfiles());
      verifyNoMoreInteractions(mockLocalSocialRepo);
      verifyNoMoreInteractions(mockUseCase);
    });

    test('should log IGNORED and abort if no rule matches (useCase returns null)', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [tProfile]);
      when(mockLocalSocialRepo.getRolesForUser(tRequestInvite.senderId)).thenAnswer((_) async => []);

      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(null);

      await processor.process(tRequestInvite);

      verify(mockLogRepo.saveLog(
        vrcUserId: tRequestInvite.senderId,
        displayName: tRequestInvite.senderName,
        avatarUrl: tRequestInvite.avatarUrl,
        invitationType: 'REQUEST',
        action: 'IGNORED',
        appliedRule: '${tProfile.name} (No matching rule)',
      ));
      verifyNever(mockSlotManager.prepareSlotForMessage(any, any));
      verifyNever(mockAutomationRepo.acceptRequestInvitation(any, any));
    });

    test('should prepare slot and ACCEPT RequestInvite when rule matches', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [tProfile]);
      when(mockLocalSocialRepo.getRolesForUser(tRequestInvite.senderId)).thenAnswer((_) async => []);

      final tResult = ProcessInvitationResult(action: RuleAction.accept, rule: tRule);
      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(tResult);

      when(mockSlotManager.prepareSlotForMessage(tCurrentUserId, tMessage))
          .thenAnswer((_) async => 3);

      when(mockAutomationRepo.acceptRequestInvitation(tRequestInvite, 3))
          .thenAnswer((_) async {});

      await processor.process(tRequestInvite);

      verify(mockSlotManager.prepareSlotForMessage(tCurrentUserId, tMessage)).called(1);
      verify(mockAutomationRepo.acceptRequestInvitation(tRequestInvite, 3)).called(1);
      verify(mockLogRepo.saveLog(
        vrcUserId: tRequestInvite.senderId,
        displayName: tRequestInvite.senderName,
        avatarUrl: tRequestInvite.avatarUrl,
        invitationType: 'REQUEST',
        action: 'ACCEPTED',
        appliedRule: '${tProfile.name} (Match: ${tRule.role.name})',
      )).called(1);
    });

    test('should prepare slot and REJECT with message when decision is reject and has message', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [tProfile]);
      when(mockLocalSocialRepo.getRolesForUser(tRequestInvite.senderId)).thenAnswer((_) async => []);

      final rejectRule = tRule.copyWith(action: RuleAction.reject);
      final tResult = ProcessInvitationResult(action: RuleAction.reject, rule: rejectRule);

      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(tResult);

      when(mockSlotManager.prepareSlotForMessage(tCurrentUserId, tMessage))
          .thenAnswer((_) async => 5);

      when(mockAutomationRepo.rejectNotificationWithMessage(tRequestInvite, 5))
          .thenAnswer((_) async {});

      await processor.process(tRequestInvite);

      verify(mockSlotManager.prepareSlotForMessage(tCurrentUserId, tMessage));
      verify(mockAutomationRepo.rejectNotificationWithMessage(tRequestInvite, 5));
      verify(mockLogRepo.saveLog(
        vrcUserId: tRequestInvite.senderId,
        displayName: tRequestInvite.senderName,
        avatarUrl: tRequestInvite.avatarUrl,
        invitationType: 'REQUEST',
        action: 'REJECTED',
        appliedRule: '${tProfile.name} (Match: ${tRule.role.name})',
      ));
    });

    test('should dismiss notification without message when REJECT decision has NO message', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [tProfile]);
      when(mockLocalSocialRepo.getRolesForUser(tRequestInvite.senderId)).thenAnswer((_) async => []);

      final ruleNoMsg = tRule.copyWith(
          action: RuleAction.reject,
          requestResponseMessage: () => null
      );
      final tResult = ProcessInvitationResult(action: RuleAction.reject, rule: ruleNoMsg);

      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(tResult);

      when(mockAutomationRepo.dismissNotification(tRequestInvite)).thenAnswer((_) async {});

      await processor.process(tRequestInvite);

      verifyNever(mockSlotManager.prepareSlotForMessage(any, any));
      verify(mockAutomationRepo.dismissNotification(tRequestInvite));
    });

    test('should ACCEPT InviteReceived (call acceptInvitation) when decision is accept', () async {
      when(mockProfileRepo.getProfiles()).thenAnswer((_) async => [tProfile]);
      when(mockLocalSocialRepo.getRolesForUser(tInviteReceived.senderId)).thenAnswer((_) async => []);

      final tResult = ProcessInvitationResult(action: RuleAction.accept, rule: tRule);
      when(mockUseCase.execute(
        request: anyNamed('request'),
        profile: anyNamed('profile'),
        userAssignedRoles: anyNamed('userAssignedRoles'),
      )).thenReturn(tResult);

      when(mockAutomationRepo.acceptInvitation(tInviteReceived)).thenAnswer((_) async {});

      await processor.process(tInviteReceived);

      verify(mockAutomationRepo.acceptInvitation(tInviteReceived));
      verify(mockLogRepo.saveLog(
        vrcUserId: tInviteReceived.senderId,
        displayName: tInviteReceived.senderName,
        avatarUrl: tInviteReceived.avatarUrl,
        invitationType: 'INVITE',
        action: 'ACCEPTED',
        appliedRule: '${tProfile.name} (Match: ${tRule.role.name})',
      ));
    });
  });
}
