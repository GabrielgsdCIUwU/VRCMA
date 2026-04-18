import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/database_provider.dart';
import 'package:vrcma/domain/entities/automation/automation_log.dart';

part 'logs_provider.g.dart';

@riverpod
class AutomationLogs extends _$AutomationLogs {
  @override
  FutureOr<List<AutomationLog>> build() async {
    final repo = await ref.watch(logRepositoryProvider.future);
    final query = ref.watch(logSearchQueryProvider);
    return repo.getLogs(search: query.isEmpty ? null : query);
  }
}

@riverpod
class LogSearchQuery extends _$LogSearchQuery {
  @override
  String build() => '';
  
  void updateQuery(String query) => state = query;
}