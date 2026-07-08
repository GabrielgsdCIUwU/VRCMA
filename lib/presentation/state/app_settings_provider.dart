import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';

part 'app_settings_provider.g.dart';

enum AppRoute {
  dashboard,
  messages,
  logs,
  settings,
}

@riverpod
class AppThemeMode extends _$AppThemeMode {
  static const _prefKey = 'app_theme_mode';
  
  @override
  ThemeMode build() {
    _loadThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadThemeMode() async {
    try {
      final repo = await ref.watch(configurationRepositoryProvider.future);
      final savedMode = await repo.getString(_prefKey);
      if (savedMode != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.name == savedMode,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final repo = await ref.read(configurationRepositoryProvider.future);
    await repo.setString(_prefKey, mode.name);
  }
}

@riverpod
class FriendsPanelCollapsed extends _$FriendsPanelCollapsed {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void setCollapsed(bool value) => state = value;
}