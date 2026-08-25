import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vrcma/core/database/database_service.dart';
import 'package:vrcma/data/repositories/calendar_automation_repository_imp.dart';
import 'package:vrcma/data/repositories/configuration_repository_imp.dart';
import 'package:vrcma/data/repositories/app_log_repository_imp.dart';
import 'package:vrcma/data/repositories/message_repository_imp.dart';
import 'package:vrcma/data/repositories/profile_repository_imp.dart';
import 'package:vrcma/data/repositories/local_social_repository_imp.dart';
import 'package:vrcma/data/repositories/status_repository_imp.dart';
import 'package:vrcma/domain/repositories/i_configuration_repository.dart';
import 'package:vrcma/domain/repositories/i_local_calendar_repository.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';
import 'package:vrcma/domain/repositories/i_app_log_repository.dart';
import 'package:vrcma/domain/repositories/i_message_repository.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';
import 'package:vrcma/domain/repositories/i_status_repository.dart';
import 'package:vrcma/domain/repositories/i_group_permission_cache_repository.dart';
import 'package:vrcma/data/repositories/group_permission_cache_repository_imp.dart';

part 'local_storage_provider.g.dart';

@riverpod
Future<Database> database(Ref ref) async {
  return await DatabaseService().database;
}

@riverpod
Future<IConfigurationRepository> configurationRepository(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return ConfigurationRepositoryImp(db);
}

@riverpod
Future<IProfileRepository> profileRepository(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return ProfileRepositoryImp(db);
}

@riverpod
Future<ILocalSocialRepository> localSocialRepository(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return LocalSocialRepositoryImp(db);
}

@riverpod
Future<IAppLogRepository> appLogRepository(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return AppLogRepositoryImp(db);
}

@riverpod
Future<IMessageRepository> messageRepository(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return MessageRepositoryImp(db);
}

@riverpod
Future<IStatusRepository> statusRepository(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return StatusRepositoryImp(db);
}

@riverpod
Future<ILocalCalendarRepository> localCalendarRepository(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return CalendarAutomationRepositoryImp(db);
}

@riverpod
Future<IGroupPermissionCacheRepository> groupPermissionCacheRepository(Ref ref) async {
  final dbService = DatabaseService();
  return GroupPermissionCacheRepositoryImp(dbService);
}
