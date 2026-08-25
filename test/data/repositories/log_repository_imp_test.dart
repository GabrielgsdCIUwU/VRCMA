import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vrcma/data/repositories/app_log_repository_imp.dart';
import 'package:vrcma/domain/entities/automation/status_automation.dart';
import 'package:vrcma/domain/entities/log/app_log.dart';

void main() {
  late Database db;
  late AppLogRepositoryImp repository;
  
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  
  setUp(() async {
    db = await databaseFactory.openDatabase(inMemoryDatabasePath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute('''
              CREATE TABLE app_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp TEXT NOT NULL,
                category TEXT NOT NULL,
                level TEXT NOT NULL,
                message TEXT NOT NULL,
                details TEXT,
                metadata TEXT
              )
            ''');
          },
        ));
    repository = AppLogRepositoryImp(db);
  });
  
  tearDown(() async {
    await db.close();
  });
  
  group('AppLogRepositoryImp - Persistence & Filtering Tests', () {
    final now = DateTime.now().toUtc();

    test('saveLog should successfully persist InvitationLogMetadata and retrieve it', () async {
      final log = AppLog(
        timestamp: now,
        category: LogCategory.invitation,
        severity: LogSeverity.info,
        message: '',
        metadata: const InvitationLogMetadata(
          senderId: 'usr_abc',
          senderName: 'Gabrielgsd',
          senderAvatarUrl: 'https://avatars.githubusercontent.com/u/104272301',
          action: InvitationActionOutcome.accepted,
          eventType: IncomingEventType.invite,
          profileName: 'Default Streamer Rule',
        ),
      );

      await repository.saveLog(log);

      final retrieved = await repository.getLogs(limit: 1);

      expect(retrieved.length, 1);
      final firstLog = retrieved.first;
      expect(firstLog.category, LogCategory.invitation);
      expect(firstLog.severity, LogSeverity.info);
      expect(firstLog.metadata, isA<InvitationLogMetadata>());

      final metadata = firstLog.metadata as InvitationLogMetadata;
      expect(metadata.senderId, 'usr_abc');
      expect(metadata.senderName, 'Gabrielgsd');
      expect(metadata.action, InvitationActionOutcome.accepted);
      expect(metadata.profileName, 'Default Streamer Rule');
    });

    test('saveLog should preserve timezone mappings converting local timestamps safely', () async {
      final localLog = AppLog(
        timestamp: DateTime(2026, 8, 7, 10),
        category: LogCategory.system,
        severity: LogSeverity.warning,
        message: 'System initialization warning',
        metadata: const SystemLogMetadata({'source': 'main_thread'})
      );

      await repository.saveLog(localLog);

      final retrieved = await repository.getLogs(limit: 1);
      expect(retrieved.length, 1);

      expect(retrieved.first.timestamp.toUtc(), localLog.timestamp.toUtc());
    });

    test('getLogs should filter correctly by LogCategory', () async {
      final invitationLog = AppLog(
        timestamp: now,
        category: LogCategory.invitation,
        severity: LogSeverity.info,
        message: '',
        metadata: const InvitationLogMetadata(
          senderId: '1',
          senderName: 'ª',
          senderAvatarUrl: '',
          action: InvitationActionOutcome.accepted,
          eventType: IncomingEventType.invite,
          profileName: 'Default',
        ),
      );

      final calendarLog = AppLog(
        timestamp: now.add(const Duration(seconds: 1)),
        category: LogCategory.calendar,
        severity: LogSeverity.info,
        message: '',
        metadata: const CalendarLogMetadata(ruleName: 'Weekly Event'),
      );

      await repository.saveLog(invitationLog);
      await repository.saveLog(calendarLog);

      final filtered = await repository.getLogs(category: LogCategory.calendar);

      expect(filtered.length, 1);
      expect(filtered.first.category, LogCategory.calendar);
      expect(filtered.first.metadata, isA<CalendarLogMetadata>());
    });

    test('getLogs should filter correctly by LogSeverity', () async {
      final infoLog = AppLog(
        timestamp: now,
        category: LogCategory.system,
        severity: LogSeverity.info,
        message: 'System running',
        metadata: const SystemLogMetadata(),
      );

      final errorLog = AppLog(
        timestamp: now.add(const Duration(seconds: 1)),
        category: LogCategory.system,
        severity: LogSeverity.error,
        message: 'Port bind failed',
        metadata: const SystemLogMetadata(),
      );

      await repository.saveLog(infoLog);
      await repository.saveLog(errorLog);

      final errors = await repository.getLogs(severity: LogSeverity.error);

      expect(errors.length, 1);
      expect(errors.first.severity, LogSeverity.error);
      expect(errors.first.message, 'Port bind failed');
    });

    test('getLogs should find logs matching search keyworkds in message, details or metadata fields', () async {
      final logWithSpecialDetails = AppLog(
        timestamp: now,
        category: LogCategory.status,
        severity: LogSeverity.info,
        message: '',
        details: 'Exception stack trace containing crash_report_identifier',
        metadata: const StatusLogMetadata(status: StatusType.joinMe, description: 'Template VRChatting'),
      );

      await repository.saveLog(logWithSpecialDetails);

      final matchDetails = await repository.getLogs(search: 'crash_report_identifier');
      final matchMetadata = await repository.getLogs(search: 'VRChatting');
      final noMatch = await repository.getLogs(search: 'UnknownPort');

      expect(matchDetails.length, 1);
      expect(matchMetadata.length, 1);
      expect(noMatch.isEmpty, isTrue);
    });

    test('clearAllLogs should physically purge all entries in app_logs table', () async {
      final log = AppLog(
        timestamp: now,
        category: LogCategory.system,
        severity: LogSeverity.info,
        message: 'Clearing test log',
        metadata: const SystemLogMetadata(),
      );

      await repository.saveLog(log);

      var initialCount = await repository.getLogs();
      expect(initialCount.isNotEmpty, isTrue);

      await repository.clearAllLogs();

      var afterClear = await repository.getLogs();
      expect(afterClear.isEmpty, isTrue);
    });
  });
}