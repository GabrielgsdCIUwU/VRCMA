import 'package:equatable/equatable.dart';

class FilterProfile extends Equatable{
  final int? id;
  final String name;
  final List<String> allowedRoles;
  final List<String> targetLanguages;
  
  final bool isActive;
  final bool isLanguageFilterEnabled;

  const FilterProfile({
    this.id,
    required this.name,
    required this.allowedRoles,
    required this.targetLanguages,
    this.isActive = false,
    this.isLanguageFilterEnabled = false,
});

  @override
  List<Object?> get props => [id, name, allowedRoles, targetLanguages, isActive, isLanguageFilterEnabled];

}