import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';

part 'logs_provider.g.dart';

@riverpod
class AppLogs extends _$AppLogs {
  @override
  FutureOr<List<AppLog>> build() async {
    final repo = await ref.watch(appLogRepositoryProvider.future);
    final query = ref.watch(logSearchQueryProvider);
    final category = ref.watch(logCategoryFilterProvider);
    final severity = ref.watch(logSeverityFilterProvider);

    return repo.getLogs(
      search: query.isEmpty ? null : query,
      category: category,
      severity: severity
    );
  }

  Future<void> clearLogs() async {
    state = const AsyncLoading();
    final repo = await ref.read(appLogRepositoryProvider.future);
    await repo.clearAllLogs();
    ref.invalidateSelf();
  }
}

@riverpod
class LogSearchQuery extends _$LogSearchQuery {
  @override
  String build() => '';
  
  void updateQuery(String query) => state = query;
}

@riverpod
class LogCategoryFilter extends _$LogCategoryFilter {
  @override
  LogCategory? build() => null;

  void setCategory(LogCategory? category) => state = category;
}

@riverpod
class LogSeverityFilter extends _$LogSeverityFilter {
  @override
  LogSeverity? build() => null;
  
  void setSeverity(LogSeverity? severity) => state = severity;
}