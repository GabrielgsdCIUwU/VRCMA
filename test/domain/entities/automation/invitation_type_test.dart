import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/invitation_type.dart';

void main() {
  group('InvitationType Entity Tests', () {
    test('RequestInvite should inherit correctly from InvitationType', () {
      const request = RequestInvite(
        id: 'notif_1',
        senderId: 'user_1',
        senderName: 'ª',
        senderTags: ['tag1'],
        avatarUrl: 'https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExaWtzNzZ3ZHN2b3kyeDVmMzd5ZnE2MHNxZzBiZWFuYTg1MHgyYnU3dyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/Ju7l5y9osyymQ/giphy.gif'
      );
      
      expect(request, isA<InvitationType>());
      expect(request.senderName, 'ª');
    });
    
    test('InviteReceived should be distinct from RequestInvite', () {
      const invite = InviteReceived(
        id: '1', senderId: '1', senderName: 'A', senderTags: [], avatarUrl: 'https://tenor.com/view/trout-trout-gang-thumbs-up-funny-animal-awesome-gif-25706215'
      );

      const request = RequestInvite(
          id: '1', senderId: '1', senderName: 'A', senderTags: [], avatarUrl: 'https://tenor.com/view/trout-trout-gang-thumbs-up-funny-animal-awesome-gif-25706215'
      );
      
      expect(invite, isNot(equals(request)));
    });
  });
}