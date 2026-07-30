import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:vrcma/core/di/network_provider.dart';

import '../../helpers/fake_path_provider.dart';

void _deleteDirectoryIfExists(String? path) {
  if (path == null) return;
  final dir = Directory(path);
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late FakePathProvider fakePathProvider;
  late String expectedCookiePath;
  late String? desktopUserdataDir;
  
  setUp(() {
    fakePathProvider = FakePathProvider();
    PathProviderPlatform.instance = fakePathProvider;
    expectedCookiePath = p.join('.support', '.cookies');
    desktopUserdataDir = null;
  });
  
  tearDown(() {
    _deleteDirectoryIfExists(expectedCookiePath);
    _deleteDirectoryIfExists(desktopUserdataDir);
    _deleteDirectoryIfExists('.documents');
    _deleteDirectoryIfExists('.support');
  });
  
  group('Network DI Core Tests', () {
    test('cookieJarProvider should initialize and create the .cookies directory', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final jar = await container.read(cookieJarProvider.future);
      
      expect(jar, isNotNull);
      
      final cookieDir = Directory(expectedCookiePath);
      expect(
          cookieDir.existsSync(),
          true,
          reason: '.cookies directory should exist at: $expectedCookiePath'
      );
    });
  });
}