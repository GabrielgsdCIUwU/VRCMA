import 'package:equatable/equatable.dart';
import 'package:vrcma/domain/error/domain_exception.dart';

enum VrcMessageType {
  invite,
  response,
  request,
  requestResponse;

  String get value => name;
  
  static VrcMessageType fromString(String val) {
    return VrcMessageType.values.firstWhere(
        (e) => e.name == val,
        orElse: () => VrcMessageType.invite,
    );
  }
}

class CustomMessage extends Equatable {
  final int? id;
  final String content;
  final VrcMessageType type;
  final int? slotIndex;
  final DateTime lastUpdated;

  CustomMessage({
    this.id,
    required this.content,
    required this.type,
    this.slotIndex,
    required this.lastUpdated,
  }) {
    if (content.trim().isEmpty) {
      throw MessageValidationException(const MessageEmptyValidationError());
    }

    if (content.length > maxCharacters) {
      throw MessageValidationException(
        MessageTooLongValidationError(actualLength: content.length, maxLength: maxCharacters)
      );
    }

    if (slotIndex != null && (slotIndex! < 0 || slotIndex! >= maxSlots)) {
      throw MessageValidationException(
        InvalidSlotIndexValidationError(slotIndex!)
      );
    }
  }

  static const int maxCharacters = 64;
  static const int maxSlots = 12;

  bool get isValidLength => content.length <= maxCharacters;
  bool get isActive => slotIndex != null;

  @override
  List<Object?> get props => [id, content, type, slotIndex, lastUpdated];
}

class VrcRemoteMessage {
  final int slot;
  final String content;
  final VrcMessageType type;
  final DateTime lastUpdated;
  
  const VrcRemoteMessage({
    required this.slot,
    required this.content,
    required this.type,
    required this.lastUpdated,
  });
}