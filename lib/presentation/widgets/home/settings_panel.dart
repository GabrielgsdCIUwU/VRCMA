import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/l10n/arb/app_localizations.dart';
import 'package:vrcma/core/l10n/l10n_extension.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/domain/entities/theme/app_theme_color.dart';
import 'package:vrcma/presentation/extensions/enum_extensions.dart';
import 'package:vrcma/presentation/state/app_settings_provider.dart';
import 'package:vrcma/presentation/state/background_service_provider.dart';
import 'package:vrcma/presentation/state/locale_provider.dart';

extension LocaleDisplayName on Locale {
  String get nativeDisplayName {
    switch (languageCode) {
      case 'es':
        return 'Español';
      
      case 'en':
        return 'English';
      
      default:
        return languageCode.toUpperCase();
    }
  }
}

class SettingsPanel extends ConsumerWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appThemeModeProvider);
    final themeColor = ref.watch(appThemeColorStateProvider);
    final locale = ref.watch(appLocaleProvider);
    final isMobile = Platform.isAndroid || Platform.isIOS;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(context, context.l10n.sectionGeneralSettings),
          _buildCard(
            context,
            children: [
              ListTile(
                leading: const Icon(Icons.palette_outlined),
                title: Text(context.l10n.themeModeLabel),
                subtitle: Text(_getThemeModeName(context, themeMode)),
                trailing: DropdownButton<ThemeMode>(
                  value: themeMode,
                  underline: const SizedBox(),
                  onChanged: (mode) {
                    if (mode != null) {
                      ref.read(appThemeModeProvider.notifier).setThemeMode(mode);
                    }
                  },
                  items: ThemeMode.values.map((mode) {
                    return DropdownMenuItem(
                      value: mode,
                      child: Text(_getThemeModeName(context, mode)),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.color_lens_outlined, color: themeColor.getMaterialColor),
                title: Text(context.l10n.themeSeedColorLabel),
                subtitle: Text(themeColor.getLozalizedName(context)),
                trailing: DropdownButton<AppThemeColor>(
                  value: themeColor,
                  underline: const SizedBox(),
                  onChanged: (color) {
                    if (color != null) {
                      ref.read(appThemeColorStateProvider.notifier).setThemeColor(color);
                    }
                  },
                  items: AppThemeColor.values.map((colorItem) {
                    return DropdownMenuItem(
                      value: colorItem,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: colorItem.getMaterialColor, size: 16),
                          const SizedBox(width: 8),
                          Text(colorItem.getLozalizedName(context)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: Text(context.l10n.languageLabel),
                subtitle: Text(locale.nativeDisplayName),
                trailing: DropdownButton<Locale>(
                  value: locale,
                  underline: const SizedBox(),
                  onChanged: (loc) {
                    if (loc != null) {
                      ref.read(appLocaleProvider.notifier).changeLocale(loc);
                    }
                  },
                  items: AppLocalizations.supportedLocales.map((supportedLocale) {
                    return DropdownMenuItem(
                      value: supportedLocale,
                      child: Text(supportedLocale.nativeDisplayName),
                    );
                  }).toList(),
                ),
              ),
              if (isMobile) ...[
                const Divider(height: 1),
                _buildBackgroundServiceTile(context, ref),
              ],
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionHeader(context, context.l10n.diagnosticTitle),
          _buildCard(
            context,
            children: [
              ListTile(
                leading: const Icon(Icons.cleaning_services_outlined),
                title: Text(context.l10n.clearCacheLabel),
                subtitle: Text(context.l10n.clearCacheDesc),
                onTap: () => _handleClearCaches(context, ref),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: context.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildBackgroundServiceTile(BuildContext context, WidgetRef ref) {
    final bgToggleAsync = ref.watch(backgroundServiceToggleProvider);
    return bgToggleAsync.when(
      data: (isEnabled) => SwitchListTile(
        secondary: const Icon(Icons.cloud_sync_outlined),
        title: Text(context.l10n.bgAutomationTitle),
        subtitle: Text(context.l10n.bgAutomationDesc),
        value: isEnabled,
        onChanged: (value) {
          ref.read(backgroundServiceToggleProvider.notifier).toggle(value);
        },
      ),
      loading: () => const ListTile(
        leading: Icon(Icons.cloud_sync_outlined),
        title: LinearProgressIndicator(),
      ),
      error: (_, _) => ListTile(
        leading: Icon(Icons.error_outline, color: context.colorScheme.error),
        title: Text(context.l10n.nativeBackgroundRuntimeFail),
      ),
    );
  }

  String _getThemeModeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return context.l10n.themeModeSystem;
      case ThemeMode.light:
        return context.l10n.themeModeLight;
      case ThemeMode.dark:
        return context.l10n.themeModeDark;
    }
  }

  void _handleClearCaches(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.toastCacheCleared),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
