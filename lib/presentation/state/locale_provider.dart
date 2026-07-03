import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'locale_provider.g.dart';

@riverpod
class AppLocale extends _$AppLocale {
  static const _prefKey = 'selected_locale_code';

  @override
  Locale build() {
    final systemLocale = PlatformDispatcher.instance.locale;
    final savedCode = _getSavedLocaleCode();

    if (savedCode != null) {
      return Locale(savedCode);
    }

    if (systemLocale.languageCode == 'es') {
      return const Locale('es');
    }
    return const Locale('en');
  }

  String? _getSavedLocaleCode() {
    return null;
  }

  Future<void> changeLocale(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, locale.languageCode);
  }
}