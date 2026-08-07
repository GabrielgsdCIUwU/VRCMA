import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';
import 'package:vrcma/domain/repositories/i_app_log_repository.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_status_repository.dart';
import 'package:vrcma/domain/usecases/automation/status/coordinate_status_automation_use_case.dart';
import 'package:vrcma/domain/usecases/automation/status/evaluate_status_use_case.dart';

@GenerateMocks([IStatusRepository, IAutomationRepository, EvaluateStatusUseCase, IAppLogRepository])
import 'coordinate_status_automation_use_case_test.mocks.dart';

void main() {
  late MockIStatusRepository mockStatusRepo;
  late MockIAutomationRepository mockAutomationRepo;
  late MockIAppLogRepository mockLogRepo;
  late MockEvaluateStatusUseCase mockEvaluateUseCase;
  late CoordinateStatusAutomationUseCase useCase;

  setUp(() {
    mockStatusRepo = MockIStatusRepository();
    mockAutomationRepo = MockIAutomationRepository();
    mockLogRepo = MockIAppLogRepository();
    mockEvaluateUseCase = MockEvaluateStatusUseCase();

    useCase = CoordinateStatusAutomationUseCase(
      statusRepository: mockStatusRepo,
      automationRepository: mockAutomationRepo,
      logRepository: mockLogRepo,
      evaluateStatusUseCase: mockEvaluateUseCase,
    );
  });

  group('CoordinateStatusAutomationUseCase', () {
    final profile = StatusProfile(
      id: 1,
      name: 'Dynamic Profile',
      fallbackStatus: StatusType.active,
      lastAppliedStatus: StatusType.active,
      lastAppliedMessage: 'Old Message',
      isActive: true,
    );

    final context = StatusContext(
      worldName: 'Home',
      worldId: 'wrld_1',
      population: 10,
      instanceType: InstanceAccessType.friends,
      batteryLevel: 100,
      isCharging: false,
      timestamp: DateTime.now(),
    );

    test('should abort execution and return Right(null) when evaluated status matches last applied state', () async {
      final evaluation = EvaluateStatusResult(status: StatusType.active, message: 'Old Message');

      when(mockEvaluateUseCase.execute(profile: profile, context: context))
        .thenAnswer((_) async => evaluation);
      
      final result = await useCase.execute(activeProfile: profile, currentContext: context);

      expect(result.isRight(), isTrue);
      verifyNever(mockAutomationRepo.updateRemoteStatus(status: anyNamed('status'), description: anyNamed('description')));
      verifyNever(mockStatusRepo.updateLastAppliedStatus(any, any, any));
      verifyNever(mockLogRepo.saveLog(any));
    });

    test('should update remote status and local database when evaluation yields new state', () async {
      final evaluation = EvaluateStatusResult(status: StatusType.joinMe, message: 'New Message');

      when(mockEvaluateUseCase.execute(profile: profile, context: context))
        .thenAnswer((_) async => evaluation);
      
      when(mockAutomationRepo.updateRemoteStatus(status: StatusType.joinMe, description: 'New Message'))
        .thenAnswer((_) async => const Right(null));
      
      when(mockStatusRepo.updateLastAppliedStatus(1, StatusType.joinMe, 'New Message'))
        .thenAnswer((_) async => const Right(null));
      
      final result = await useCase.execute(activeProfile: profile, currentContext: context);

      expect(result.isRight(), isTrue);
      verify(mockAutomationRepo.updateRemoteStatus(status: StatusType.joinMe, description: 'New Message')).called(1);
      verify(mockStatusRepo.updateLastAppliedStatus(1, StatusType.joinMe, 'New Message')).called(1);
      verify(mockLogRepo.saveLog(any)).called(1);
    });

    test('should return Failure and halt local update when remote API update fails', () async {
      final evaluation = EvaluateStatusResult(status: StatusType.busy, message: 'Do Not Disturb');
      final failure = ApiFailure('VRChat API Error');

      when(mockEvaluateUseCase.execute(profile: profile, context: context))
        .thenAnswer((_) async => evaluation);
      
      when(mockAutomationRepo.updateRemoteStatus(status: StatusType.busy, description: 'Do Not Disturb'))
        .thenAnswer((_) async => Left(failure));
      
      final result = await useCase.execute(activeProfile: profile, currentContext: context);

      expect(result.isLeft(), isTrue);
      verify(mockAutomationRepo.updateRemoteStatus(status: StatusType.busy, description: 'Do Not Disturb')).called(1);
      verifyNever(mockStatusRepo.updateLastAppliedStatus(any, any, any));
      verify(mockLogRepo.saveLog(any)).called(1);
    });
  });
}