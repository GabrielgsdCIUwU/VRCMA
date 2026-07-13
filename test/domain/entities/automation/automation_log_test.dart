import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/automation_log.dart';

void main() {
  group("AutomationLog Entity Tests", () {
    final testTimestamp = DateTime(2026, 4, 5, 12, 0, 0);
    
    test("Should support value equality (Equatable)", () {
      final log1 = AutomationLog(
        id: 1,
        timestamp: testTimestamp,
        senderId: "user_1",
        senderName: "<><",
        senderAvatarUrl: "https://c.tenor.com/tVdFKACn2PoAAAAd/smg4-mario.gif",
        invitationType: LogEventType.request,
        action: LogActionOutcome.accepted,
        profileName: "Main Safe Profile",
        matchedRoleName: "VIP",
      );
      
      final log2 = AutomationLog(
        id: 1,
        timestamp: testTimestamp,
        senderId: "user_1",
        senderName: "<><",
        senderAvatarUrl: "https://c.tenor.com/tVdFKACn2PoAAAAd/smg4-mario.gif",
        invitationType: LogEventType.request,
        action: LogActionOutcome.accepted,
        profileName: "Main Safe Profile",
        matchedRoleName: "VIP",
      );
      expect(log1, equals(log2));
      expect(log1.hashCode, equals(log2.hashCode));
    });
    
    test("Should be different if any property changes", () {
      final log1 = AutomationLog(
        id: 1,
        timestamp: testTimestamp,
        senderId: "user_1",
        senderName: "<><",
        senderAvatarUrl: "https://c.tenor.com/tVdFKACn2PoAAAAd/smg4-mario.gif",
        invitationType: LogEventType.request,
        action: LogActionOutcome.accepted,
        profileName: "Main Profile",
        matchedRoleName: "VIP",
      );

      final log2 = AutomationLog(
        id: 2,
        timestamp: testTimestamp,
        senderId: "user_1",
        senderName: "<><",
        senderAvatarUrl: "https://c.tenor.com/tVdFKACn2PoAAAAd/smg4-mario.gif",
        invitationType: LogEventType.request,
        action: LogActionOutcome.rejected,
        profileName: "Main Profile",
        matchedRoleName: "VIP",
      );
      expect(log1, isNot(equals(log2)));
    });
    
    test("Should initialize correctly with optional id as null", () {
      final log = AutomationLog(
        timestamp: testTimestamp,
        senderId: "user_1",
        senderName: "Cookies For Fish :3",
        senderAvatarUrl: "https://preview.redd.it/el-mundo-resumido-en-una-imagen-v0-8wyqey53t04g1.png?width=1080&crop=smart&auto=webp&s=fb3a685bb3ac397ee7397a8ba0efed332e60616a",
        invitationType: LogEventType.invite,
        action: LogActionOutcome.ignored,
        profileName: "Main Profile",
        matchedRoleName: "Default",
      );
      
      expect(log.id, isNull);
      expect(log.senderName, "Cookies For Fish :3");
      expect(log.timestamp, testTimestamp);
    });
  });
}