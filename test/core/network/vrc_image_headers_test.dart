import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vrcma/core/di/network_provider.dart';
import 'package:vrcma/presentation/state/auth_provider.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../../helpers/test_mocks.mocks.dart';

void main() {
  late MockCookieJar mockCookieJar;
  
  setUp(() {
    mockCookieJar = MockCookieJar();
  });
  
  test('vrcImageHeadersProvider should build correctly the Cookie string', () async {
    final container = ProviderContainer(
      overrides: [
        cookieJarProvider.overrideWith((ref) => mockCookieJar)
      ]
    );
    
    final testCookies = [
      Cookie('auth', 'secret_token'),
      Cookie('twoFactorAuth', 'verified_cookies_for_fish')
    ];
    
    when(mockCookieJar.loadForRequest(any))
      .thenAnswer((_) async => testCookies);
    
    final headers = await container.read(
      vrcImageHeadersProvider('https://api.vrchat.cloud/image.png').future
    );
    
    expect(headers['User-Agent'], contains('VRCMA'));
    expect(headers['Cookie'], 'auth=secret_token; twoFactorAuth=verified_cookies_for_fish');
    
    container.dispose();
  });
}