import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

/// Mock实现用于测试
class MockPathProvider extends PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return './test/temp';
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return './test/app_support';
  }

  @override
  Future<String?> getLibraryPath() async {
    return './test/library';
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return './test/documents';
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return './test/external_storage';
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return ['./test/external_cache'];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return ['./test/external_storage'];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return './test/downloads';
  }
}