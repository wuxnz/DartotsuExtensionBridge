import 'dart:io';

import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final tempDir = await Directory.systemTemp.createTemp('test_docs_');
    return tempDir.path;
  }

  @override
  Future<String?> getTemporaryPath() async {
    final tempDir = await Directory.systemTemp.createTemp('test_temp_');
    return tempDir.path;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    final tempDir = await Directory.systemTemp.createTemp('test_support_');
    return tempDir.path;
  }

  @override
  Future<String?> getApplicationCachePath() async {
    final tempDir = await Directory.systemTemp.createTemp('test_cache_');
    return tempDir.path;
  }

  @override
  Future<String?> getDownloadsPath() async {
    final tempDir = await Directory.systemTemp.createTemp('test_downloads_');
    return tempDir.path;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return null;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return null;
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return null;
  }

  @override
  Future<String?> getLibraryPath() async {
    final tempDir = await Directory.systemTemp.createTemp('test_library_');
    return tempDir.path;
  }
}
