import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vrcma/data/repositories/local_social_repository_imp.dart';

void main() {
  late Database db;
  late LocalSocialRepositoryImp repository;
  
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
              CREATE TABLE roles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE
              )
          ''');
          await db.execute('''
              CREATE TABLE friend_roles (
                vrc_user_id TEXT NOT NULL,
                role_id INTEGER NOT NULL,
                PRIMARY KEY (vrc_user_id, role_id)
              )
            ''');
        },
      ));
    repository = LocalSocialRepositoryImp(db);
  });
  
  tearDown(() async {
    await db.close();
  });
  
  group('LocalSocialRepositoryImp - Roles Tests', () {
    test('createRole should insert role and getAllAvailableRoles should retrieve it', () async {
      final roleId = await repository.createRole('VIP');
      final roles = await repository.getAllAvailableRoles();
      
      expect(roleId, isA<int>());
      expect(roles.length, 1);
      expect(roles.first.name, 'VIP');
      expect(roles.first.id, roleId);
    });
    
    test('createRole should throw specific error if role name already exists', () async {
      await repository.createRole('Admin');
      
      expect(
        () async => await repository.createRole('Admin'),
        throwsA(isA<String>().having((e) => e, 'message', contains('already exists'))),
      );
    });
    
    test('deleteRole should remove the role from database', () async {
      final roleId = await repository.createRole('Guest');
      
      await repository.deleteRole(roleId);
      final roles = await repository.getAllAvailableRoles();
      
      expect(roles.isEmpty, true);
    });
    
    test('assignRoleToUser and getRolesForUser should map relationships correctly', () async {
      final roleId1 = await repository.createRole('VIP');
      final roleId2 = await repository.createRole('Close Friend');
      const userId = 'usr_123';
      
      await repository.assignRoleToUser(userId, roleId1);
      await repository.assignRoleToUser(userId, roleId2);
      
      final userRoles = await repository.getRolesForUser(userId);
      
      expect(userRoles.length, 2);
      final roleNames = userRoles.map((r) => r.name).toList();
      expect(roleNames, containsAll(['VIP', 'Close Friend']));
    });
    
    test('getMemberCountForRole should return exact number of assigned users', () async {
      final roleId = await repository.createRole('Streamer');
      await repository.assignRoleToUser('usr_1', roleId);
      await repository.assignRoleToUser('usr_2', roleId);
      
      final count = await repository.getMemberCountForRole(roleId);
      
      expect(count, 2);
    });
    
    test('syncRoleMembers should replace old users with new set (Transaction Test)', () async {
      final roleId = await repository.createRole('VIP');
      await repository.assignRoleToUser('usr_old_1', roleId);
      await repository.assignRoleToUser('usr_old_2', roleId);
      
      final newUsers = {'usr_new_1', 'usr_new_2', 'usr_new_3'};
      await repository.syncRoleMembers(roleId, newUsers);
      
      final members = await repository.getUserIdsByRole(roleId);
      
      expect(members.length, 3);
      expect(members, containsAll(newUsers));
      expect(members.contains('usr_old_1'), false);
    });
  });
}