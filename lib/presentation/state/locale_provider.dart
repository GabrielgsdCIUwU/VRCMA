import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vrcma/core/di/local_storage_provider.dart';

part 'locale_provider.g.dart';

@riverpod
class AppLocale extends _$AppLocale {
  static const _prefKey = 'selected_locale_code';

  @override
  Locale build() {
    final systemLocale = PlatformDispatcher.instance.locale;
    _loadLocale();

    if (systemLocale.languageCode == 'es') {
      return const Locale('es');
    }
    return const Locale('en');
  }

  Future<void> _loadLocale() async {
    try {
      final repo = await ref.watch(configurationRepositoryProvider.future);
      final savedCode = await repo.getString(_prefKey);
      if (savedCode != null) {
        state = Locale(savedCode);
      }
    } catch (_) {}
  }

  Future<void> changeLocale(Locale locale) async {
    state = locale;
    final repo = await ref.read(configurationRepositoryProvider.future);
    await repo.setString(_prefKey, locale.languageCode);
  }
}