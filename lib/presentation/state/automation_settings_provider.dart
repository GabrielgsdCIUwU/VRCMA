import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'automation_settings_provider.g.dart';

@riverpod
class AutomationPanelSections extends _$AutomationPanelSections {
  @override
  Set<String> build() {
    return {};
  }

  void toggle(String sectionId) {
    if (state.contains(sectionId)) {
      state = {...state}..remove(sectionId);
    } else {
      state = {...state}..add(sectionId);
    }
  }

  void expand(String sectionId) {
    if (state.contains(sectionId)) {
      state = {...state}..remove(sectionId);
    }
  }
}