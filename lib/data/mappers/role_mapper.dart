import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/mappers/i_database_mapper.dart';

class RoleMapper implements IDatabaseMapper<Role> {
  @override
  Role fromDatabaseMap(Map<String, dynamic> row) {
    return Role(
      id: row['id'] as int,
      name: row['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toDatabaseMap(Role role) {
    return {
      'id': role.id,
      'name': role.name
    };
  }
}