import 'package:equatable/equatable.dart';

class VrcGroup extends Equatable {
  final String id;
  final String name;
  final String shortCode;
  
  const VrcGroup({
    required this.id,
    required this.name,
    required this.shortCode,
  });
  
  @override
  List<Object?> get props => [id, name, shortCode];
}