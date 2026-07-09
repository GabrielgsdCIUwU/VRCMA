import 'package:dartz/dartz.dart';
import 'package:vrcma/core/errors/failure.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/automation/status_context.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_status_repository.dart';
import 'package:vrcma/domain/usecases/automation/status/evaluate_status_use_case.dart';

class CoordinateStatusAutomationUseCase {
  final IStatusRepository _statusRepository;
  final IAutomationRepository _automationRepository;
  final EvaluateStatusUseCase _evaluateStatusUseCase;

  CoordinateStatusAutomationUseCase({
    required IStatusRepository statusRepository,
    required IAutomationRepository automationRepository,
    required EvaluateStatusUseCase evaluateStatusUseCase,
  }) : _statusRepository = statusRepository,
      _automationRepository = automationRepository,
      _evaluateStatusUseCase = evaluateStatusUseCase;
  
  /// Runs the complete status automation lifecycle for the current active profile.
  Future<Either<Failure, void>> execute({
    required StatusProfile activeProfile,
    required StatusContext currentContext,
  }) async {
    final evaluation = await _evaluateStatusUseCase.execute(profile: activeProfile, context: currentContext);

    final bool statusChanged = activeProfile.lastAppliedStatus != evaluation.status;
    final bool messageChanged = activeProfile.lastAppliedMessage != evaluation.message;

    if (!statusChanged && !messageChanged) {
      return const Right(null);
    }

    final updateResult = await _automationRepository.updateRemoteStatus(
      status: evaluation.status,
      description: evaluation.message,
    );

    return await updateResult.fold(
      (failure) => Left(failure),
      (_) async {
        await _statusRepository.updateLastAppliedStatus(
          activeProfile.id!,
          evaluation.status,
          evaluation.message,
        );
        return const Right(null);
      },
    );
  }
}