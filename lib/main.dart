import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:vrcma/core/theme/vrc_theme.dart';
import 'package:vrcma/core/l10n/arb/app_localizations.dart';
import 'package:vrcma/presentation/state/locale_provider.dart';
import 'package:vrcma/presentation/pages/home_page.dart';
import 'package:vrcma/presentation/pages/login_page.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'core/services/background_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  //! Support SQLite on Desktop else DATABASE DOESN'T LOAD
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  } else if (Platform.isAndroid || Platform.isIOS) {
    await initializeBackgroundService();
  }
  
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final appLocale = ref.watch(appLocaleProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VRCMA',
      scaffoldMessengerKey: scaffoldMessengerKey,
      locale: appLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          brightness: Brightness.dark
        ),
        useMaterial3: true,
        extensions: const [
          VrcSemanticColors(
            invite: Colors.blueAccent,
            request: Colors.orangeAccent,
            response: Colors.greenAccent,
            requestResponse: Colors.purpleAccent,
            statusOnline: Colors.greenAccent,
            statusJoinMe: Colors.blueAccent,
            statusAskMe: Colors.orangeAccent,
            statusBusy: Colors.redAccent,
            statusOffline: Colors.grey,
            success: Colors.green,
            error: Colors.redAccent,
          )
        ],
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        )
      ),
      home: authState.when(
        data: (user) => user == null ? const LoginPage() : const HomePage(),
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (_, _) => const LoginPage()
      ),
    );
  }
}