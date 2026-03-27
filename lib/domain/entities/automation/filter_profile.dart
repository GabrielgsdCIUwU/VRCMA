import 'package:equatable/equatable.dart';

class FilterProfile extends Equatable{
  final int? id;
  final String name;
  final List<String> allowedRoles;
  final List<String> targetLanguages;
  final bool isActive;

  const FilterProfile({
    this.id,
    required this.name,
    required this.allowedRoles,
    required this.targetLanguages,
    this.isActive = false
});

  @override
  List<Object?> get props => [id, name, allowedRoles, targetLanguages, isActive];

}