import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';
import 'package:vrcma/domain/usecases/automation/automation_processor.dart';

import '../../../helpers/test_mocks.mocks.dart';

void main() {
  late AutomationProcessor processor;
  late MockIAutomationRepository mockIAutomationRepository;
  late MockILocalSocialRepository mockILocalSocialRepository;
  late MockIProfileRepository mockIProfileRepository;
  late MockILogRepository mockILogRepository;
  late MockProcessInvitationUseCase mockProcessInvitationUseCase;

  setUp(() {
    mockIAutomationRepository = MockIAutomationRepository();
    mockILocalSocialRepository = MockILocalSocialRepository();
    mockIProfileRepository = MockIProfileRepository();
    mockILogRepository = MockILogRepository();
    mockProcessInvitationUseCase = MockProcessInvitationUseCase();

    processor = AutomationProcessor(
      automationRepository: mockIAutomationRepository,
      localSocialRepository: mockILocalSocialRepository,
      profileRepository: mockIProfileRepository,
      logRepository: mockILogRepository,
      useCase: mockProcessInvitationUseCase,
    );
  });

  group("AutomationProcessor - Orchestration Tests", () {
    const activeProfile = FilterProfile(
      id: 1,
      name: "Main Profile",
      isActive: true,
    );
    const mockRole = Role(id: 1, name: "VIP");

    final mockRequest = RequestInvite(
      id: "req_1",
      senderId: "user_1",
      senderName: "<><",
      senderTags: const [],
      avatarUrl:
          'https://tenor.com/view/trout-trout-gang-thumbs-up-funny-animal-awesome-gif-25706215',
    );

    test("Should stop execution if there is no active profile", () async {
      when(mockIProfileRepository.getProfiles()).thenAnswer((_) async => []);

      await processor.process(mockRequest);

      verify(mockIProfileRepository.getProfiles()).called(1);
      verifyNever(mockILocalSocialRepository.getRolesForUser(any));
      verifyNever(
        mockProcessInvitationUseCase.execute(
          request: anyNamed("request"),
          profile: anyNamed("profile"),
          userAssignedRoles: anyNamed("userAssignedRoles"),
        ),
      );
    });

    test(
      "Should record IGNORED log if the Use Case returns null (no matching rule)",
      () async {
        when(
          mockIProfileRepository.getProfiles(),
        ).thenAnswer((_) async => [activeProfile]);
        when(
          mockILocalSocialRepository.getRolesForUser(mockRequest.senderId),
        ).thenAnswer((_) async => [mockRole]);
        when(
          mockProcessInvitationUseCase.execute(
            request: mockRequest,
            profile: activeProfile,
            userAssignedRoles: const [mockRole],
          ),
        ).thenReturn(null);

        when(
          mockILogRepository.saveLog(
            vrcUserId: anyNamed("vrcUserId"),
            displayName: anyNamed("displayName"),
            avatarUrl: anyNamed("avatarUrl"),
            invitationType: anyNamed("invitationType"),
            action: anyNamed("action"),
            appliedRule: anyNamed("appliedRule"),
          ),
        ).thenAnswer((_) async => {});

        await processor.process(mockRequest);

        verify(
          mockILogRepository.saveLog(
            vrcUserId: mockRequest.senderId,
            displayName: mockRequest.senderName,
            avatarUrl: mockRequest.avatarUrl,
            invitationType: "REQUEST",
            action: "IGNORED",
            appliedRule: "Main Profile (No matching rule)",
          ),
        ).called(1);
        verifyNever(
          mockIAutomationRepository.acceptRequestInvitation(any, any),
        );
      },
    );

    test(
      "Should accept invitation and save ACCEPTED log when Use Case returns ACCEPT",
      () async {
        when(
          mockIProfileRepository.getProfiles(),
        ).thenAnswer((_) async => [activeProfile]);
        when(
          mockILocalSocialRepository.getRolesForUser(mockRequest.senderId),
        ).thenAnswer((_) async => [mockRole]);
        when(
          mockProcessInvitationUseCase.execute(
            request: mockRequest,
            profile: activeProfile,
            userAssignedRoles: anyNamed("userAssignedRoles"),
          ),
        ).thenReturn(RuleAction.accept);

        when(
          mockIAutomationRepository.acceptRequestInvitation(mockRequest, null),
        ).thenAnswer((_) async => {});
        when(
          mockILogRepository.saveLog(
            vrcUserId: anyNamed("vrcUserId"),
            displayName: anyNamed("displayName"),
            avatarUrl: anyNamed("avatarUrl"),
            invitationType: anyNamed("invitationType"),
            action: anyNamed("action"),
            appliedRule: anyNamed("appliedRule"),
          ),
        ).thenAnswer((_) async => {});

        await processor.process(mockRequest);

        verify(
          mockIAutomationRepository.acceptRequestInvitation(mockRequest, null),
        ).called(1);
        verify(
          mockILogRepository.saveLog(
            vrcUserId: mockRequest.senderId,
            displayName: mockRequest.senderName,
            avatarUrl: mockRequest.avatarUrl,
            invitationType: 'REQUEST',
            action: 'ACCEPTED',
            appliedRule: 'Main Profile (Profile Match)',
          ),
        ).called(1);
      },
    );

    test(
      "Should reject invitation and save REJECTED log when Use Case returns REJECT",
      () async {
        when(
          mockIProfileRepository.getProfiles(),
        ).thenAnswer((_) async => [activeProfile]);
        when(
          mockILocalSocialRepository.getRolesForUser(mockRequest.senderId),
        ).thenAnswer((_) async => []);
        when(
          mockProcessInvitationUseCase.execute(
            request: mockRequest,
            profile: activeProfile,
            userAssignedRoles: anyNamed("userAssignedRoles"),
          ),
        ).thenReturn(RuleAction.reject);

        when(
          mockIAutomationRepository.rejectNotificationWithMessage(
            mockRequest,
            0,
          ),
        ).thenAnswer((_) async => {});
        when(
          mockILogRepository.saveLog(
            vrcUserId: anyNamed('vrcUserId'),
            displayName: anyNamed('displayName'),
            avatarUrl: anyNamed('avatarUrl'),
            invitationType: anyNamed('invitationType'),
            action: anyNamed('action'),
            appliedRule: anyNamed('appliedRule'),
          ),
        ).thenAnswer((_) async => {});

        await processor.process(mockRequest);

        verify(
          mockIAutomationRepository.rejectNotificationWithMessage(
            mockRequest,
            0,
          ),
        ).called(1);
        verify(
          mockILogRepository.saveLog(
            vrcUserId: mockRequest.senderId,
            displayName: mockRequest.senderName,
            avatarUrl: mockRequest.avatarUrl,
            invitationType: 'REQUEST',
            action: 'REJECTED',
            appliedRule: 'Main Profile (Profile Match)',
          ),
        ).called(1);
      },
    );
  });
}
