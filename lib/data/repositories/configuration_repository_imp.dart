import 'package:sqflite/sqflite.dart';
import 'package:vrcma/domain/repositories/i_configuration_repository.dart';

class ConfigurationRepositoryImp implements IConfigurationRepository {
  final Database _db;

  ConfigurationRepositoryImp(this._db);

  @override
  Future<String?> getString(String key) async {
    final List<Map<String, dynamic>> results = await _db.query(
      'app_configurations',
      columns: ['config_value'],
      where: 'config_key = ?',
      whereArgs: [key],
    );

    if (results.isEmpty) return null;
    return results.first['config_value'] as String?;
  }

  @override
  Future<void> setString(String key, String value) async {
    await _db.insert(
      'app_configurations',
      {
        'config_key': key,
        'config_value': value,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<bool?> getBool(String key) async {
    final String? valStr = await getString(key);
    if (valStr == null) return null;
    return valStr.toLowerCase() == 'true' || valStr == '1';
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await setString(key, value.toString());
  }
}