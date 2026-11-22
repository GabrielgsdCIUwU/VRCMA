import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/vrc_automation_event.dart';

void main() {
  group('VRCAutomationEvent Hierarchy Tests', () {
    test('RequestInviteEvent should establish accurate super-class inheritance properties', () {
      const event = RequestInviteEvent(
        id: 'notif_1',
        senderId: 'user_1',
        senderName: 'ª',
        senderTags: ['language_eng'],
        //! OMG I DID IT TO MYSELF
        avatarUrl: 'https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExaWtzNzZ3ZHN2b3kyeDVmMzd5ZnE2MHNxZzBiZWFuYTg1MHgyYnU3dyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/Ju7l5y9osyymQ/giphy.gif'
      );

      expect(event, isA<IncomingUserEvent>());
      expect(event, isA<VrcAutomationEvent>());
      expect(event.senderName, 'ª');
    });

    test('Events of different types should be strictly non-equal', () {
      const inviteEvent = InviteReceivedEvent(
        id: '1', senderId: '1', senderName: 'A', senderTags: [], avatarUrl: 'https://tenor.com/view/trout-trout-gang-thumbs-up-funny-animal-awesome-gif-25706215'
      );

      const requestEvent = RequestInviteEvent(
        id: '1', senderId: '1', senderName: 'A', senderTags: [], avatarUrl: 'https://tenor.com/view/trout-trout-gang-thumbs-up-funny-animal-awesome-gif-25706215'
      );

      expect(inviteEvent, isNot(equals(requestEvent)));
    });
  });
}