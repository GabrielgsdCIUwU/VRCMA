import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vrcma/core/database/database_service.dart';
import 'package:vrcma/data/repositories/automation_repository_imp.dart';
import 'package:vrcma/data/repositories/log_repository_imp.dart';
import 'package:vrcma/data/repositories/message_repository_imp.dart';
import 'package:vrcma/data/repositories/profile_repository_imp.dart';
import 'package:vrcma/data/repositories/local_social_repository_imp.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/repositories/i_automation_repository.dart';
import 'package:vrcma/domain/repositories/i_local_social_repository.dart';
import 'package:vrcma/domain/repositories/i_log_repository.dart';
import 'package:vrcma/domain/repositories/i_message_repository.dart';
import 'package:vrcma/domain/repositories/i_profile_repository.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

part 'database_provider.g.dart';

@riverpod
Future<Database> database(Ref ref) async {
  return await DatabaseService().database;
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
Future<List<Role>> allAvailableRoles(Ref ref) async {
  final repo = await ref.watch(localSocialRepositoryProvider.future);
  final roles = await repo.getAllAvailableRoles();
  return roles;
}

@riverpod
Future<ILogRepository> logRepository(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return LogRepositoryImp(db);
}

@riverpod
Future<IMessageRepository> messageRepository(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return MessageRepositoryImp(db);
}

@riverpod
Future<IAutomationRepository> automationRepository(Ref ref) async {
  final api = await ref.watch(vrcApiProvider.future);
  return AutomationRepositoryImp(api);
}