import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/domain/entities/automation/automation_log.dart';

part 'logs_provider.g.dart';

@riverpod
class AutomationLogs extends _$AutomationLogs {
  @override
  FutureOr<List<AutomationLog>> build() async {
    final repo = await ref.watch(logRepositoryProvider.future);
    return repo.getLogs();
  }
}