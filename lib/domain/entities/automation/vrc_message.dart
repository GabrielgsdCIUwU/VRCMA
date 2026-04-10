import 'package:equatable/equatable.dart';

enum VrcMessageType {
  invite,
  response,
  request,
  requestResponse;

  int get value {
    switch (this) {
      case VrcMessageType.invite:
        return 0;
      case VrcMessageType.response:
        return 1;
      case VrcMessageType.request:
        return 2;
      case VrcMessageType.requestResponse:
        return 3;
    }
  }
}

class CustomMessage extends Equatable {
  final int? id;
  final String content;
  final VrcMessageType type;
  final int? slotIndex;
  final DateTime lastUpdated;

  const CustomMessage({
    this.id,
    required this.content,
    required this.type,
    this.slotIndex,
    required this.lastUpdated,
  });

  static const int maxCharacters = 64;
  static const int maxSlots = 12;

  bool get isValidLength => content.length <= maxCharacters;
  bool get isActive => slotIndex != null;

  @override
  List<Object?> get props => [id, content, type, slotIndex, lastUpdated];
}