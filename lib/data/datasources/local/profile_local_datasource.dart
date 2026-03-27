import 'package:sqflite/sqflite.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';

abstract class IProfileLocalDataSource {
  Future<int> saveProfile(FilterProfile profile);
  Future<List<FilterProfile>> getProfiles();
  Future<void> deleteProfile(int id);
}

class ProfileLocalDataSourceImpl implements IProfileLocalDataSource {
  final Database _db;

  ProfileLocalDataSourceImpl(this._db);

  @override
  Future<int> saveProfile(FilterProfile profile) async {
    return await _db.insert(
      'profiles',
      {
        'name': profile.name,
        'allowed_roles': profile.allowedRoles.join(','),
        'target_languages': profile.targetLanguages.join(','),
        'is_language_filter_enabled': profile.isLanguageFilterEnabled ? 1 : 0,
        'is_active': profile.isActive ? 1 : 0
      },
      conflictAlgorithm: ConflictAlgorithm.replace
    );
  }

  @override
  Future<List<FilterProfile>> getProfiles() async {
    final List<Map<String, dynamic>> maps = await _db.query('profiles');
    return List.generate(maps.length, (i) {
      return FilterProfile(
        id: maps[i]['id'],
        name: maps[i]['name'],
        allowedRoles: (maps[i]['allowed_roles'] as String).split(','),
        targetLanguages: (maps[i]['target_languages'] as String).split(','),
        isActive: maps[i]['is_active'] == 1
      );
    });
  }

  @override
  Future<void> deleteProfile(int id) async {
    await _db.delete('profiles', where: 'id = ?', whereArgs: [id]);
  }
}

