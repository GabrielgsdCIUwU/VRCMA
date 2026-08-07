
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/calendar/calendar_automation_rule.dart';
import 'package:vrcma/domain/entities/calendar/calendar_occurrence_run.dart';
import 'package:vrcma/domain/entities/calendar/calendar_value_objects.dart';
import 'package:vrcma/domain/entities/calendar/enums/creation_strategy.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_access_type.dart';
import 'package:vrcma/domain/entities/calendar/enums/group_event_category.dart';
import 'package:vrcma/domain/entities/calendar/enums/recurrence_type.dart';
import 'package:vrcma/domain/services/calendar/event_title_resolver.dart';
import 'package:vrcma/domain/services/calendar/occurrence_calculator.dart';
import 'package:vrcma/domain/usecases/calendar/evaluate_and_generate_events_use_case.dart';

import '../../../helpers/test_mocks.mocks.dart';

void main() {
  group('EvaluateAndGenerateEventsUseCase Orchestration', () {
    late MockILocalCalendarRepository mockLocalRepo;
    late MockIRemoteCalendarRepository mockRemoteRepo;
    late MockIAppLogRepository mockLogRepo;
    late EvaluateAndGenerateEventsUseCase useCase;

    const dummyHost = VrcUser(id: '1', displayName: 'Host', tags: ['language_spa']);

    setUp(() {
      mockLocalRepo = MockILocalCalendarRepository();
      mockRemoteRepo = MockIRemoteCalendarRepository();
      mockLogRepo = MockIAppLogRepository();

      useCase = EvaluateAndGenerateEventsUseCase(
        localRepo: mockLocalRepo,
        remoteRepo: mockRemoteRepo,
        logRepo: mockLogRepo,
        calculator: OccurrenceCalculator(),
        titleResolver: EventTitleResolver(),
      );
    });

    test('should abort execution if there are no active rules', () async {
      when(mockLocalRepo.getActiveRules()).thenAnswer((_) async => []);

      await useCase.execute(hostUser: dummyHost);

      verify(mockLocalRepo.getActiveRules()).called(1);
      verifyZeroInteractions(mockRemoteRepo);
    });

    test('should process rules, create events on remote API and update local states', () async {
      final rule = CalendarAutomationRule(
        id: 1,
        name: 'Weekly Meetup',
        groupId: 'grp_1',
        titleTemplate: 'Meetup #{{incremental}}',
        category: GroupEventCategory.other,
        accessType: GroupEventAccessType.public,
        schedule: TimezoneSchedule(startTimeOfDay: '20:00', durationMinutes: 60, timezoneIana: 'UTC'),
        recurrence: const RecurrencePattern(type: RecurrenceType.daily),
        incrementalConfig: IncrementalConfig(isEnabled: true, currentValue: 5),
        strategy: CreationStrategy.lazy,
      );

      when(mockLocalRepo.getActiveRules()).thenAnswer((_) async => [rule]);
      when(mockLocalRepo.getPastRuns(1)).thenAnswer((_) async => []);

      when(mockRemoteRepo.createEvent(
        groupId: anyNamed('groupId'),
        title: anyNamed('title'),
        startUtc: anyNamed('startUtc'),
        endUtc: anyNamed('endUtc'),
        description: anyNamed('description'),
        category: anyNamed('category'),
        accessType: anyNamed('accessType'),
        platforms: anyNamed('platforms'),
        languages: anyNamed('languages'),
        tags: anyNamed('tags'),
        sendCreationNotification: anyNamed('sendCreationNotification'),
        roleIds: anyNamed('roleIds'),
        hostEarlyJoinMinutes: anyNamed('hostEarlyJoinMinutes'),
        guestEarlyJoinMinutes: anyNamed('guestEarlyJoinMinutes'),
        closeInstanceAfterEndMinutes: anyNamed('closeInstanceAfterEndMinutes'),
        usesInstanceOverflow: anyNamed('usesInstanceOverflow'),
      )).thenAnswer((_) async => 'vrc_evt_123');

      when(mockLocalRepo.saveOccurrenceRun(any)).thenAnswer((_) async {});
      when(mockLocalRepo.saveRule(any)).thenAnswer((_) async => 1);


      await useCase.execute(hostUser: dummyHost);

      verify(mockRemoteRepo.createEvent(
        groupId: 'grp_1',
        title: 'Meetup #5',
        startUtc: anyNamed('startUtc'),
        endUtc: anyNamed('endUtc'),
        description: '',
        category: GroupEventCategory.other,
        accessType: GroupEventAccessType.public,
        platforms: [],
        languages: ['spa'],
        tags: [],
        sendCreationNotification: false,
        roleIds: [],
        hostEarlyJoinMinutes: null,
        guestEarlyJoinMinutes: null,
        closeInstanceAfterEndMinutes: null,
        usesInstanceOverflow: false,
      )).called(1);

      final capturedRun = verify(mockLocalRepo.saveOccurrenceRun(captureAny)).captured.first as CalendarOccurrenceRun;
      expect(capturedRun.createdVrcEventId, 'vrc_evt_123');
      expect(capturedRun.automationId, 1);

      final capturedRule = verify(mockLocalRepo.saveRule(captureAny)).captured.first as CalendarAutomationRule;
      expect(capturedRule.incrementalConfig.currentValue, 6);
    });
  });
}