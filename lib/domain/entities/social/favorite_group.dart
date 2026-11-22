import 'package:equatable/equatable.dart';

class FavoriteGroup extends Equatable {
  final String id;
  final String name;
  final List<String> friendIds;
  
  const FavoriteGroup({
    required this.id,
    required this.name,
    this.friendIds = const [],
  });
  
  @override
  List<Object?> get props => [id, name, friendIds];
}