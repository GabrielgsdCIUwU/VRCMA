import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/calendar/enums/instance_region.dart';
import 'package:vrcma/domain/entities/social/vrc_instance.dart';

void main() {
  group('VrcInstance Parser Logic', () {
    test('should identify non-resolvable standard states correctly', () {
      final offline = VrcInstance.parse('offline');
      final private = VrcInstance.parse('private');
      final traveling = VrcInstance.parse('traveling');

      expect(private.isPrivate, isTrue);
      expect(traveling.isTraveling, isTrue);
      expect(offline.isOffline, isTrue);
      expect(offline.isResolvableWorld, isFalse);
    });

    test('should parse standard public world string', () {
      final instance = VrcInstance.parse('wrld_12345-abcde:67890');

      expect(instance.worldId, 'wrld_12345-abcde');
      expect(instance.instanceId, '67890');
      expect(instance.accessType, InstanceAccessType.public);
      expect(instance.region, InstanceRegion.us);
      expect(instance.isResolvableWorld, isTrue);
    });

    test('should parse Friends+ instances correctly', () {
      final instance = VrcInstance.parse('wrld_abc:123~hidden(usr_host)');

      expect(instance.accessType, InstanceAccessType.friendsPlus);
    });

    test('should parse Invite+ instances correctly', () {
      final instance = VrcInstance.parse('wrld_abc:123~private(usr_host)~canRequestInvite');

      expect(instance.accessType, InstanceAccessType.invitePlus);
    });

    test('should parse Group instances with specific access types and region', () {
      final instance = VrcInstance.parse('wrld_x:1~group(grp_123)~groupAccessType(plus)~region(eu)');

      expect(instance.accessType, InstanceAccessType.groupPlus);
      expect(instance.region, InstanceRegion.eu);
    });

    test('should retieve values from the internal LRU cache for repeated locations', () {
      const location = 'wrld_cache:1~region(jp)';

      final instance1 = VrcInstance.parse(location);
      final instance2 = VrcInstance.parse(location);

      expect(identical(instance1, instance2), isTrue);
      expect(instance2.region, InstanceRegion.jp);
    });
  });
}