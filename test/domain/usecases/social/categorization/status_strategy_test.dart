import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/entities/social/friend_group_category.dart';
import 'package:vrcma/domain/usecases/social/categorization/status_strategy.dart';

void main() {
  group('StatusStrategy', () {
    final activeUser = VrcUser(id: '1', displayName: 'ActiveUser', status: 'active', tags: [], location: 'wrld_123');
    final offlineUser = VrcUser(id: '2', displayName: 'OfflineUser', status: 'offline', tags: [], location: 'offline');
    final busyUser = VrcUser(id: '3', displayName: 'BusyUser', status: 'busy', tags: [], location: 'wrld_456');
    
    test('Should return a valid FriendGroupCategory when condition matches', () {
      final strategy = StatusStrategy(
        id: 'online',
        title: 'Online Friends',
        iconType: CategoryIconType.online,
        condition: (u) => u.status == 'active',
      );
      
      final accountedIds = <String>{};
      
      final result = strategy.execute(
        friends: [activeUser, offlineUser, busyUser],
        accountedIds: accountedIds,
        contextData: {},
      );
      
      expect(result, isNotNull);
      expect(result!.id, 'online');
      expect(result.friends.length, 1);
      expect(result.friends.first.id, '1');
      expect(accountedIds.contains('1'), true);
    });
    
    test('Should return null if no friends match the condition', () {
      final strategy = StatusStrategy(
        id: 'join_me',
        title: 'Join Me',
        iconType: CategoryIconType.joinMe,
        condition: (u) => u.status == 'join me',
      );
      
      final result = strategy.execute(
        friends: [activeUser, offlineUser],
        accountedIds: <String>{},
        contextData: {},
      );
      
      expect(result, isNull);
    });
    
    test('Should ignore friends that are already in accountedIds', () {
      final strategy = StatusStrategy(
        id: 'busy',
        title: 'Busy',
        iconType: CategoryIconType.busy,
        condition: (u) => u.status == 'busy',
      );
      
      final accountedIds = <String>{'3'};
      
      final result = strategy.execute(
        friends: [busyUser],
        accountedIds: accountedIds,
        contextData: {},
      );
      
      expect(result, isNull);
    });
  });
}