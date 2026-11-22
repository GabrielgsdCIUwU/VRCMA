import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
import 'package:vrcma/domain/usecases/social/categorization/same_instance_strategy.dart';

void main() {
  group('SameInstanceStrategy', () {
    final strategy = SameInstanceStrategy();

    test('should group users in the exact same instance if count >= 2', () {
      final users = [
        const VrcUser(id: '1', displayName: 'Alice', tags: [], location: 'wrld_1:123'),
        const VrcUser(id: '2', displayName: 'Bob', tags: [], location: 'wrld_1:123'),
        const VrcUser(id: '3', displayName: 'Charlie', tags: [], location: 'wrld_2:999'),
      ];

      final accountedIds = <String>{};
      final contextData = {'worldNames': {'wrld_1': 'Cool World', 'wrld_2': 'Sad World'}};

      final result = strategy.execute(
        friends: users,
        accountedIds: accountedIds,
        contextData: contextData,
      );

      expect(result, isNotNull);
      expect(result!.subCategories.length, 1);

      final group = result.subCategories.first;
      expect(group.friends.length, 2);
      expect(group.friends.map((u) => u.displayName), containsAll(['Alice', 'Bob']));
      expect(accountedIds, containsAll(['1', '2']));
      expect(accountedIds.contains('3'), isFalse);
    });

    test('should return null if no instance meets the minimum user threshold', () {
      final users = [
        const VrcUser(id: '1', displayName: 'Alice', tags: [], location: 'wrld_1:111'),
        const VrcUser(id: '2', displayName: 'Bob', tags: [], location: 'wrld_2:222'),
      ];

      final result = strategy.execute(
        friends: users,
        accountedIds: <String>{},
        contextData: {'worldNames': <String, String>{}},
      );

      expect(result, isNull);
    });

    test('should ignore users in private, offline, or traveling states', () {
      final users = [
        const VrcUser(id: '1', displayName: 'A', tags: [], location: 'private'),
        const VrcUser(id: '2', displayName: 'B', tags: [], location: 'private'),
        const VrcUser(id: '3', displayName: 'C', tags: [], location: 'offline'),
        const VrcUser(id: '4', displayName: 'D', tags: [], location: 'traveling'),
      ];

      final result = strategy.execute(
        friends: users,
        accountedIds: <String>{},
        contextData: {'worldNames': <String, String>{}},
      );

      expect(result, isNull);
    });
  });
}