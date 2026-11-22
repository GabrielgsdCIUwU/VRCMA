import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/usecases/messages/sync_messages_use_case.dart';

import '../../../helpers/test_mocks.mocks.dart';

void main() {
  late SyncMessagesUseCase useCase;
  late MockIAutomationRepository mockRemoteRepo;
  late MockIMessageRepository mockLocalRepo;
  
  setUp(() {
    mockRemoteRepo = MockIAutomationRepository();
    mockLocalRepo = MockIMessageRepository();
    useCase = SyncMessagesUseCase(mockRemoteRepo, mockLocalRepo);
  });
  
  group('SyncMessagesUseCase', () {
    const userId = 'usr_123';
    
    test('Should async remote messages and update local slots successfully', () async {
      final remoteMessages = [
        VrcRemoteMessage(slot: 0, content: 'Hello!', type: VrcMessageType.invite, lastUpdated: DateTime.now()),
        VrcRemoteMessage(slot: 1, content: 'New message', type: VrcMessageType.invite, lastUpdated: DateTime.now()),
      ];
      
      final localMessages = [
        CustomMessage(id: 1, content: 'Hello!', type: VrcMessageType.invite, slotIndex: null, lastUpdated: DateTime.now()),
      ];
      
      when(mockRemoteRepo.getRemoteVrcMessages(userId, VrcMessageType.invite))
        .thenAnswer((_) async => remoteMessages);
      
      when(mockLocalRepo.getMessagesByType(VrcMessageType.invite))
        .thenAnswer((_) async => localMessages);
      
      for (var type in VrcMessageType.values.where((t) => t != VrcMessageType.invite)) {
        when(mockRemoteRepo.getRemoteVrcMessages(userId, type)).thenAnswer((_) async => []);
        when(mockLocalRepo.getMessagesByType(type)).thenAnswer((_) async => []);
      }
      
      when(mockLocalRepo.updateSlot(any, any, any)).thenAnswer((_) async {});
      when(mockLocalRepo.saveMessage(any)).thenAnswer((_) async => 2);
      
      final result = await useCase.execute(userId);
      
      result.fold(
          (failure) => fail('Test failed with error: ${failure.message}'),
          (success) => expect(true, true),
      );
      
      expect(result.isRight(), true);
      
      verify(mockLocalRepo.updateSlot(1, 0, VrcMessageType.invite)).called(1);
      
      verify(mockLocalRepo.saveMessage(argThat(
        isA<CustomMessage>()
            .having((m) => m.content, 'content', 'New message')
            .having((m) => m.slotIndex, 'slotIndex', 1)
      ))).called(1);
    });
    
    test('Should return SyncFailure when an exception occurs', () async {
      when(mockRemoteRepo.getRemoteVrcMessages(any, any))
          .thenThrow(Exception('API Timeout'));
      
      final result = await useCase.execute(userId);
      
      expect(result.isLeft(), true);
      result.fold(
          (failure) => expect(failure.message, contains('API Timeout')),
          (_) => fail('Should have returned a failure'),
      );
    });
  });
}