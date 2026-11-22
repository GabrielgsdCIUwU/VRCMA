import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';
import 'package:vrcma/domain/services/app_logger.dart';
import 'package:vrcma/domain/usecases/automation/process_friend_automations_use_case.dart';

import '../../../helpers/test_mocks.mocks.dart';

void main() {
  group('ProcessFriendAutomationsUseCase Tests', () {
    late MockILocalSocialRepository mockSocialRepository;
    late MockIAppLogRepository mockLogRepository;
    late AppLogger logger;
    late ProcessFriendAutomationsUseCase useCase;

    setUp(() {
      mockSocialRepository = MockILocalSocialRepository();
      mockLogRepository = MockIAppLogRepository();
      logger = AppLogger(mockLogRepository);

      when(mockLogRepository.saveLog(any)).thenAnswer((_) async {});

      useCase = ProcessFriendAutomationsUseCase(
        localSocialRepository: mockSocialRepository,
        logger: logger,
      );
    });

    test('should assign roles to new friends matching the trigger type and log the action', () async {
      const roleVip = Role(id: 10, name: 'VIP');

      const automation = RoleAutomation(
        id: 1,
        trigger: AutomationTrigger.newFriend,
        roles: [roleVip],
      );

      final apiFriendsList = [
        const VrcUser(id: 'usr_already_friend', displayName: 'Old Buddy', tags: []),
        const VrcUser(id: 'usr_new_friend', displayName: 'New Buddy', tags: []),
      ];

      when(mockSocialRepository.getRoleAutomations())
          .thenAnswer((_) async => [automation]);

      when(mockSocialRepository.getKnownUserIds())
          .thenAnswer((_) async => ['usr_already_friend']);

      when(mockSocialRepository.getAllAvailableRoles())
          .thenAnswer((_) async => [roleVip]);

      when(mockSocialRepository.assignMultipleRoles(any))
          .thenAnswer((_) async {});

      when(mockSocialRepository.saveKnownUsers(any))
          .thenAnswer((_) async {});

      await useCase.execute(apiFriendsList);

      final VerificationResult verification = verify(mockSocialRepository.assignMultipleRoles(captureAny));
      final Map<String, Set<int>> capturedRoles = verification.captured.single as Map<String, Set<int>>;

      expect(capturedRoles.containsKey('usr_new_friend'), isTrue);
      expect(capturedRoles['usr_new_friend'], contains(roleVip.id));
      expect(capturedRoles.containsKey('usr_already_friend'), isFalse);

      verify(mockSocialRepository.saveKnownUsers(apiFriendsList)).called(1);
      verify(mockLogRepository.saveLog(any)).called(1);
    });

    test('should assign roles to friends matching VRChat Tag identifier values', () async {
      const roleStaff = Role(id: 20, name: 'Staff');

      const automation = RoleAutomation(
        id: 2,
        trigger: AutomationTrigger.hasTag,
        targetValue: 'admin_moderator',
        roles: [roleStaff],
      );

      final apiFriendsList = [
        const VrcUser(id: 'usr_mod', displayName: 'Moderator User', tags: ['admin_moderator']),
        const VrcUser(id: 'usr_normal', displayName: 'Normal User', tags: ['language_eng']),
      ];

      when(mockSocialRepository.getRoleAutomations())
          .thenAnswer((_) async => [automation]);

      when(mockSocialRepository.getKnownUserIds())
          .thenAnswer((_) async => []);

      when(mockSocialRepository.getAllAvailableRoles())
          .thenAnswer((_) async => [roleStaff]);

      when(mockSocialRepository.assignMultipleRoles(any))
          .thenAnswer((_) async {});

      when(mockSocialRepository.saveKnownUsers(any))
          .thenAnswer((_) async {});

      await useCase.execute(apiFriendsList);

      final VerificationResult verification = verify(mockSocialRepository.assignMultipleRoles(captureAny));
      final Map<String, Set<int>> capturedRoles = verification.captured.single as Map<String, Set<int>>;

      expect(capturedRoles.containsKey('usr_mod'), isTrue);
      expect(capturedRoles['usr_mod'], contains(roleStaff.id));
      expect(capturedRoles.containsKey('usr_normal'), isFalse);

      verify(mockSocialRepository.saveKnownUsers(apiFriendsList)).called(1);
      verify(mockLogRepository.saveLog(any)).called(1);
    });
  });
}