import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vrcma/data/repositories/local_social_repository_imp.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/automation/filter_profile.dart';
import 'package:vrcma/domain/entities/automation/role_automation.dart';
import 'package:vrcma/domain/error/domain_exception.dart';

void main() {
  late Database db;
  late LocalSocialRepositoryImp repository;
  
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });
  
  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
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
          await db.execute('''
              CREATE TABLE role_automations (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                trigger_type TEXT NOT NULL,
                target_value TEXT
              )
          ''');
          await db.execute('''
              CREATE TABLE automation_assigned_roles (
                automation_id INTEGER NOT NULL,
                role_id INTEGER NOT NULL,
                PRIMARY KEY (automation_id, role_id)
              )
          ''');
          await db.execute('''
              CREATE TABLE vrc_users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL UNIQUE,
                display_name TEXT NOT NULL,
                avatar_url TEXT,
                last_updated TEXT NOT NULL
              )
          ''');
        },
      ),
    );
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
        throwsA(isA<DuplicateRoleException>().having((e) => e.roleName, 'roleName', 'Admin')),
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
      
      await repository.saveKnownUsers(const [VrcUser(id: userId, displayName: 'Test', tags: [])]);
      
      await repository.assignRoleToUser(userId, roleId1);
      await repository.assignRoleToUser(userId, roleId2);
      
      final userRoles = await repository.getRolesForUser(userId);
      
      expect(userRoles.length, 2);
      final roleNames = userRoles.map((r) => r.name).toList();
      expect(roleNames, containsAll(['VIP', 'Close Friend']));
    });
    
    test('getMemberCountForRole should return exact number of assigned users', () async {
      final roleId = await repository.createRole('Streamer');

      await repository.saveKnownUsers(const [
        VrcUser(id: 'usr_1', displayName: 'Test1', tags: []),
        VrcUser(id: 'usr_2', displayName: 'Test2', tags: [])
      ]);

      await repository.assignRoleToUser('usr_1', roleId);
      await repository.assignRoleToUser('usr_2', roleId);
      
      final count = await repository.getMemberCountForRole(roleId);
      
      expect(count, 2);
    });
    
    test('syncRoleMembers should replace old users with new set (Transaction Test)', () async {
      final roleId = await repository.createRole('VIP');

      await repository.saveKnownUsers(const [
        VrcUser(id: 'usr_old_1', displayName: 'Old1', tags: []),
        VrcUser(id: 'usr_old_2', displayName: 'Old2', tags: []),
        VrcUser(id: 'usr_new_1', displayName: 'New1', tags: []),
        VrcUser(id: 'usr_new_2', displayName: 'New2', tags: []),
        VrcUser(id: 'usr_new_3', displayName: 'New3', tags: []),
      ]);

      await repository.assignRoleToUser('usr_old_1', roleId);
      await repository.assignRoleToUser('usr_old_2', roleId);
      
      final newUsers = {'usr_new_1', 'usr_new_2', 'usr_new_3'};
      await repository.syncRoleMembers(roleId, newUsers);
      
      final members = await repository.getUserIdsByRole(roleId);
      
      expect(members.length, 3);
      expect(members, containsAll(newUsers));
      expect(members.contains('usr_old_1'), false);
    });

    test('saveRoleAutomation and getRoleAutomations should persist automation rules correctly', () async {
      final roleId = await repository.createRole('VIP');
      final role = Role(id: roleId, name: 'VIP');

      final automation = RoleAutomation(
        trigger: AutomationTrigger.hasTag,
        targetValue: 'system_supporter',
        roles: [role],
      );

      await repository.saveRoleAutomation(automation);

      final automations = await repository.getRoleAutomations();
      expect(automations.length, 1);
      expect(automations.first.trigger, AutomationTrigger.hasTag);
      expect(automations.first.targetValue, 'system_supporter');
      expect(automations.first.roles.first.id, roleId);
    });

    test('saveKnownUsers should insert and perform conflict updates', () async {
      final users = [
        const VrcUser(id: 'usr_one', displayName: 'One', tags: [], avatarUrl: 'url1'),
      ];

      await repository.saveKnownUsers(users);

      final knownIds = await repository.getKnownUserIds();
      expect(knownIds, contains('usr_one'));
    });

    test('assignMultipleRoles should map associations efficiently', () async {
      final roleId = await repository.createRole('Moderator');

      await repository.saveKnownUsers(const [
        VrcUser(id: 'usr_user1', displayName: 'Mod', tags: []),
      ]);

      final assigments = {
        'usr_user1': {roleId},
      };

      await repository.assignMultipleRoles(assigments);

      final userRoles = await repository.getRolesForUser('usr_user1');
      expect(userRoles.map((r) => r.id), contains(roleId));
    });
  });
}