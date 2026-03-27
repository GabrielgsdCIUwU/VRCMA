import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vrcma/core/database/database_service.dart';
import 'package:vrcma/data/datasources/local/profile_local_datasource.dart';

part 'database_provider.g.dart';

@riverpod
Future<Database> database(Ref ref) async {
  return await DatabaseService().database;
}

@riverpod
Future<IProfileLocalDataSource> profileLocalDataSource(Ref ref) async {
  final db = await ref.watch(databaseProvider.future);
  return ProfileLocalDataSourceImpl(db);
}