import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';
import 'package:vrcma/presentation/state/logs_provider.dart';

import '../helpers/test_mocks.mocks.dart';

void main() {
  late MockIAppLogRepository mockAppLogRepository;

  setUp(() {
    mockAppLogRepository = MockIAppLogRepository();
  });

  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        appLogRepositoryProvider.overrideWith((ref) => mockAppLogRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('Logs Presentation State Providers - Interactive Flow Tests', () {
    final dummyLogs = [
      AppLog(
        id: 1,
        timestamp: DateTime.now(),
        category: LogCategory.calendar,
        severity: LogSeverity.info,
        message: '',
        metadata: const CalendarLogMetadata(ruleName: 'Weekly event'),
      )
    ];

    test('AppLogs should initially fetch log database with empty default filters', () async {
      when(mockAppLogRepository.getLogs(
        search: null,
        category: null,
        severity: null,
      )).thenAnswer((_) async => dummyLogs);

      final container = createContainer();

      final state = await container.read(appLogsProvider.future);

      expect(state, equals(dummyLogs));
      verify(mockAppLogRepository.getLogs(search: null, category: null, severity: null)).called(1);
    });

    test('Updating search query should trigger getLogs evaluation with updated string parameter', () async {
      when(mockAppLogRepository.getLogs(
        search: 'crash',
        category: null,
        severity: null
      )).thenAnswer((_) async => []);

      when(mockAppLogRepository.getLogs(
        search: null,
        category: null,
        severity: null,
      )).thenAnswer((_) async => dummyLogs);

      final container = createContainer();

      await container.read(appLogsProvider.future);

      container.read(logSearchQueryProvider.notifier).updateQuery('crash');

      final filteredState = await container.read(appLogsProvider.future);

      expect(filteredState, equals([]));
      verify(mockAppLogRepository.getLogs(search: 'crash', category: null, severity:  null)).called(1);
    });

    test('Updating category filter should rebuild logs list requesting only that category', () async {
      when(mockAppLogRepository.getLogs(
        search: null,
        category: LogCategory.calendar,
        severity: null,
      )).thenAnswer((_) async => dummyLogs);

      when(mockAppLogRepository.getLogs(
        search: null,
        category: null,
        severity: null,
      )).thenAnswer((_) async => []);

      final container = createContainer();
      
      await container.read(appLogsProvider.future);

      container.read(logCategoryFilterProvider.notifier).setCategory(LogCategory.calendar);

      final filteredState = await container.read(appLogsProvider.future);

      expect(filteredState, equals(dummyLogs));
      verify(mockAppLogRepository.getLogs(search: null, category: LogCategory.calendar, severity: null)).called(1);
    });

    test('Updating severity filter should rebuild logs list requesting only that severity', () async {
      when(mockAppLogRepository.getLogs(
        search: null,
        category: null,
        severity: LogSeverity.info,
      )).thenAnswer((_) async => dummyLogs);

      when(mockAppLogRepository.getLogs(
        search: null,
        category: null,
        severity: null
      )).thenAnswer((_) async => []);

      final container = createContainer();

      await container.read(appLogsProvider.future);

      container.read(logSeverityFilterProvider.notifier).setSeverity(LogSeverity.info);

      final filteredState = await container.read(appLogsProvider.future);

      expect(filteredState, equals(dummyLogs));
      verify(mockAppLogRepository.getLogs(search: null, category: null, severity: LogSeverity.info)).called(1);
    });

    test('Calling clearLogs should execute physical purge and invalidate state providers', () async {
      when(mockAppLogRepository.clearAllLogs()).thenAnswer((_) async => {});
      when(mockAppLogRepository.getLogs(
        search: null,
        category: null,
        severity: null,
      )).thenAnswer((_) async => <AppLog>[]);

      final container = createContainer();

      await container.read(appLogsProvider.future);

      await container.read(appLogsProvider.notifier).clearLogs();

      verify(mockAppLogRepository.clearAllLogs()).called(1);

      final stateAfterPurge = await container.read(appLogsProvider.future);
      expect(stateAfterPurge.isEmpty, isTrue);
    });
  });
}