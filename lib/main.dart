import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/presentation/pages/home_page.dart';
import 'package:vrcma/presentation/pages/login_page.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VRCMA',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
          brightness: Brightness.dark
        ),
        useMaterial3: true,
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