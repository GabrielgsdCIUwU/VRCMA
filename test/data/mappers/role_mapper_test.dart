import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/data/mappers/role_mapper.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';

void main() {
  group('RoleMapper', () {
    final mapper = RoleMapper();

    test('fromDatabaseMap should parse SQL row to Role Entity', () {
      final row = {'id': 99, 'name': 'Moderator'};

      final result = mapper.fromDatabaseMap(row);

      expect(result.id, 99);
      expect(result.name, 'Moderator');
    });

    test('toDatabaseMap should serialize Role Entity to SQL map', () {
      const entity = Role(id: 7, name: 'VIP');

      final result = mapper.toDatabaseMap(entity);

      expect(result['id'], 7);
      expect(result['name'], 'VIP');
    });
  });
}