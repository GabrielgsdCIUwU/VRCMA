import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// This class mimics the behaviour of path_provider for unit tests.
/// It returns simple string instead of real system paths.
class FakePathProvider extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return '.temp';
  }
  
  @override
  Future<String?> getApplicationSupportPath() async {
    return '.support';
  }
  
  @override
  Future<String?> getLibraryPath() async {
    return '.library';
  }
  
  @override
  Future<String?> getApplicationDocumentsPath() async {
    return '.documents';
  }
  
  @override
  Future<String?> getExternalStoragePath() async {
    return '.external';
  }
  
  @override
  Future<List<String>?> getExternalCachePaths() async{
    return ['.external_storage'];
  }
  
  @override
  Future<String?> getDownloadsPath() async {
    return '.downloads';
  }
}