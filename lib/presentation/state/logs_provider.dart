import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';

part 'logs_provider.g.dart';

@riverpod
class AppLogs extends _$AppLogs {
  StreamSubscription<void>? _subscription;
  @override
  FutureOr<List<AppLog>> build() async {
    final repo = await ref.watch(appLogRepositoryProvider.future);
    final query = ref.watch(logSearchQueryProvider).trim().toLowerCase();
    final category = ref.watch(logCategoryFilterProvider);
    final severity = ref.watch(logSeverityFilterProvider);

    _subscription?.cancel();
    _subscription = repo.watchLogs().listen((_) {
      ref.invalidateSelf();
    });
    
    ref.onDispose(() {
      _subscription?.cancel();
    });
    
    final rawLogs = await repo.getLogs(
      category: category,
      severity: severity,
    );
    
    if (query.isEmpty) {
      return rawLogs;
    }
    
    return rawLogs.where((log) => _matchesSearch(log, query)).toList();
  }

  Future<void> clearLogs() async {
    state = const AsyncLoading();
    final repo = await ref.read(appLogRepositoryProvider.future);
    await repo.clearAllLogs();
    ref.invalidateSelf();
  }

  bool _matchesSearch(AppLog log, String query) {
    if (log.message.isNotEmpty && log.message.toLowerCase().contains(query)) {
      return true;
    }
    if (log.details != null && log.details!.toLowerCase().contains(query)) {
      return true;
    }

    final meta = log.metadata;
    return switch (meta) {
      CalendarLogMetadata() =>
      meta.ruleName.toLowerCase().contains(query) ||
          (meta.eventTitle?.toLowerCase().contains(query) ?? false) ||
          (meta.groupId?.toLowerCase().contains(query) ?? false) ||
          (meta.eventId?.toLowerCase().contains(query) ?? false),

      StatusLogMetadata() =>
      (meta.profileName?.toLowerCase().contains(query) ?? false) ||
          meta.description.toLowerCase().contains(query) ||
          meta.status.name.toLowerCase().contains(query),

      InvitationLogMetadata() =>
      meta.senderName.toLowerCase().contains(query) ||
          meta.senderId.toLowerCase().contains(query) ||
          meta.profileName.toLowerCase().contains(query) ||
          (meta.matchedRoleName?.toLowerCase().contains(query) ?? false),

      SocialLogMetadata() =>
      meta.targetUserName.toLowerCase().contains(query) ||
          meta.targetUserId.toLowerCase().contains(query) ||
          meta.assignedRoleNames.any((r) => r.toLowerCase().contains(query)),

      AuthLogMetadata() =>
      meta.displayName.toLowerCase().contains(query) ||
          meta.userId.toLowerCase().contains(query),

      SystemLogMetadata() =>
          meta.data.values.any((v) => v.toString().toLowerCase().contains(query)),
    };
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