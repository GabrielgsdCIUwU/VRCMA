import 'package:flutter_test/flutter_test.dart';
import 'package:vrcma/domain/entities/automation/vrc_message.dart';
import 'package:vrcma/domain/error/domain_exception.dart';

void main() {
  group('CustomMessage Domain Entity Validation', () {
    final DateTime now = DateTime.now();

    test('should instantiate successfully with valid parameters', () {
      final message = CustomMessage(
        content: 'Hallo!',
        type: VrcMessageType.invite,
        slotIndex: 5,
        lastUpdated: now,
      );

      expect(message.content, 'Hallo!');
      expect(message.isActive, isTrue);
    });

    test('should throw MessageValidationException if content exceeds max length', () {
      final longContent = 'A' * (CustomMessage.maxCharacters + 1);

      expect(
        () => CustomMessage(content: longContent, type: VrcMessageType.request, lastUpdated: now),
        throwsA(isA<MessageValidationException>().having(
              (e) => e.error, 'error', isA<MessageTooLongValidationError>(),
        )),
      );
    });

    test('should throw MessageValidationException if content is empty', () {
      expect(
        () => CustomMessage(content: '  ', type: VrcMessageType.response, lastUpdated: now),
        throwsA(isA<MessageValidationException>().having(
          (e) => e.error, 'error', isA<MessageEmptyValidationError>()
        )),
      );
    });

    test('should throw MessageValidationException if slot index is out of bounds', () {
      expect(
        () => CustomMessage(content: 'Valid', type: VrcMessageType.invite, slotIndex: -1, lastUpdated: now),
        throwsA(isA<MessageValidationException>()),
      );

      expect(
        () => CustomMessage(content: 'Valid', type: VrcMessageType.invite, slotIndex: 20, lastUpdated: now),
        throwsA(isA<MessageValidationException>()),
      );
    });

    test('isActive should return false if slotIndex is null', () {
      final message = CustomMessage(
        content: 'Draft message',
        type: VrcMessageType.invite,
        slotIndex: null,
        lastUpdated: now
      );

      expect(message.isActive, isFalse);
    });
  });
}