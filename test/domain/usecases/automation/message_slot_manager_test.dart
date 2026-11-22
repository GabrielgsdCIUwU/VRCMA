import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/usecases/automation/message_slot_manager.dart';

import '../../../helpers/test_mocks.mocks.dart';

void main() {
  late MockIMessageRepository mockMessageRepo;
  late MockIAutomationRepository mockAutomationRepo;
  late MessageSlotManager slotManager;

  const userId = 'usr_test';

  setUp(() {
    mockMessageRepo = MockIMessageRepository();
    mockAutomationRepo = MockIAutomationRepository();

    slotManager = MessageSlotManager(
      messageRepository: mockMessageRepo,
      automationRepository: mockAutomationRepo,
    );
  });

  group('MessageSlotManager - Prepare Slot Logic', () {
    final message = CustomMessage(
      id: 1,
      content: 'Want to chill?',
      type: VrcMessageType.invite,
      slotIndex: null,
      lastUpdated: DateTime(2026, 1, 1),
    );

    test('should return existing slot index if message is already active', () async {
      final activeMessage = CustomMessage(
        id: 2,
        content: 'Active',
        type: VrcMessageType.invite,
        slotIndex: 5,
        lastUpdated: DateTime.now(),
      );

      final result = await slotManager.prepareSlotForMessage(userId, activeMessage);

      expect(result, 5);
      verifyZeroInteractions(mockMessageRepo);
      verifyZeroInteractions(mockAutomationRepo);
    });

    test('should find the first empty slot when there are available spaces', () async {
      final activeSlots = [
        CustomMessage(id: 2, content: 'A', type: VrcMessageType.invite, slotIndex: 0, lastUpdated: DateTime.now()),
        CustomMessage(id: 3, content: 'B', type: VrcMessageType.invite, slotIndex: 1, lastUpdated: DateTime.now()),

        CustomMessage(id: 4, content: 'C', type: VrcMessageType.invite, slotIndex: 3, lastUpdated: DateTime.now()),
      ];

      when(mockMessageRepo.getActiveSlots(VrcMessageType.invite))
        .thenAnswer((_) async => activeSlots);
      when(mockAutomationRepo.updateVrcMessageSlot(
        userId: anyNamed('userId'),
        messageType: anyNamed('messageType'),
        slot: anyNamed('slot'),
        content: anyNamed('content'),
        type: anyNamed('type'),
      )).thenAnswer((_) async => const Right(null));

      final result = await slotManager.prepareSlotForMessage(userId, message);

      expect(result, 2);
      verify(mockAutomationRepo.updateVrcMessageSlot(
        userId: userId, messageType: 'invite', slot: 2, content: 'Want to chill?', type: VrcMessageType.invite
      )).called(1);
      verify(mockMessageRepo.updateSlot(1, 2, VrcMessageType.invite)).called(1);
    });

    test('should overwrite the oldest message slot when all 12 slots are full', () async {
      final oldDate = DateTime(2025, 1, 1);
      final activeSlots = List.generate(12, (index) => CustomMessage(
        id: index + 10,
        content: 'Msg',
        type: VrcMessageType.invite,
        slotIndex: index,
        lastUpdated: index == 7 ? oldDate : DateTime.now(),
      ));

      when(mockMessageRepo.getActiveSlots(VrcMessageType.invite))
        .thenAnswer((_) async => activeSlots);
      when(mockAutomationRepo.updateVrcMessageSlot(
        userId: anyNamed('userId'), 
        messageType: anyNamed('messageType'), 
        slot: anyNamed('slot'), 
        content: anyNamed('content'), 
        type: anyNamed('type'),
      )).thenAnswer((_) async => const Right(null));

      final result = await slotManager.prepareSlotForMessage(userId, message);

      expect(result, 7);
    });
  });
}