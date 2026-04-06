import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:vrcma/core/di/network_provider.dart';

import '../../helpers/fake_path_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late FakePathProvider fakePathProvider;
  
  setUp(() {
    fakePathProvider = FakePathProvider();
    PathProviderPlatform.instance = fakePathProvider;
  });
  
  tearDown(() {
    final dir = Directory('.documents');
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });
  
  group('Network DI Core Tests', () {
    test('cookieJarProvider should initialize and create the .cookies directory', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      
      final jar = await container.read(cookieJarProvider.future);
      
      expect(jar, isNotNull);
      
      final cookieDir = Directory('.documents/.cookies');
      expect(cookieDir.existsSync(), true);
    });
  });
}