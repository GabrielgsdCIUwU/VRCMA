import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/auth/vrc_user.dart';
void main() {
  group('VrcUser Entity Tests', () {
    test('Should support value equality (Equatable)', () {
      const user1 = VrcUser(
        id: 'usr_1',
        displayName: '<><',
        tags: ['language_en'],
        status: 'active'
      );
      
      const user2 = VrcUser(
          id: 'usr_1',
          displayName: '<><',
          tags: ['language_en'],
          status: 'active'
      );
      
      expect(user1, equals(user2));
      expect(user1.hashCode, equals(user2.hashCode));
    });
    
    test('Should be different if ID or any property changes', () {
      const user1 = VrcUser(id: 'usr_1', displayName: 'Cookies For Fish :3', tags: []);
      const user2 = VrcUser(id: 'usr_2', displayName: 'Cookies For Fish :3', tags: []);
      
      expect(user1, isNot(equals(user2)));
      expect(user1.hashCode, isNot(equals(user2.hashCode)));
    });
  });
}