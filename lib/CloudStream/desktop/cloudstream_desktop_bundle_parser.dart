import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

/// Manifest structure for CloudStream plugins.
class CloudStreamPluginManifest {
  final String? name;
  final String? pluginClassName;
  final int? version;
  final bool? requiresResources;
  final List<String>? extractorClasses;
  final String? repositoryUrl;
  final List<String>? authors;
  final String? description;
  final List<String>? tvTypes;
  final String? language;
  final String? iconUrl;
  final int? status;

  CloudStreamPluginManifest({
    this.name,
    this.pluginClassName,
    this.version,
    this.requiresResources,
    this.extractorClasses,
    this.repositoryUrl,
    this.authors,
    this.description,
    this.tvTypes,
    this.language,
    this.iconUrl,
    this.status,
  });

  factory CloudStreamPluginManifest.fromJson(Map<String, dynamic> json) {
    return CloudStreamPluginManifest(
      name: json['name'] as String?,
      pluginClassName: json['pluginClassName'] as String?,
      version: json['version'] as int?,
      requiresResources: json['requiresResources'] as bool?,
      extractorClasses: (json['extractorClasses'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      repositoryUrl: json['repositoryUrl'] as String?,
      authors: (json['authors'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      description: json['description'] as String?,
      tvTypes: (json['tvTypes'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      language: json['language'] as String?,
      iconUrl: json['iconUrl'] as String?,
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pluginClassName': pluginClassName,
      'version': version,
      'requiresResources': requiresResources,
      'extractorClasses': extractorClasses,
      'repositoryUrl': repositoryUrl,
      'authors': authors,
      'description': description,
      'tvTypes': tvTypes,
      'language': language,
      'iconUrl': iconUrl,
      'status': status,
    };
  }
}

/// Result of extracting a CloudStream plugin bundle.
class CloudStreamBundleExtractResult {
  final Directory extractedDir;
  final CloudStreamPluginManifest? manifest;
  final File? dexFile;
  final List<File> jsFiles;
  final List<File> assetFiles;

  CloudStreamBundleExtractResult({
    required this.extractedDir,
    this.manifest,
    this.dexFile,
    this.jsFiles = const [],
    this.assetFiles = const [],
  });

  /// Whether this bundle contains executable content.
  bool get hasExecutableContent => dexFile != null || jsFiles.isNotEmpty;

  /// Whether this is a DEX-based plugin (Android-only).
  bool get isDexPlugin => dexFile != null;

  /// Whether this is a JS-based plugin (cross-platform).
  bool get isJsPlugin => jsFiles.isNotEmpty;
}

/// Parser for CloudStream plugin bundles (.cs3/.zip files).
///
/// This class handles:
/// - Downloading plugin bundles from URLs
/// - Extracting .cs3/.zip archives
/// - Parsing manifest.json files
/// - Identifying plugin content (DEX, JS, assets)
class CloudStreamDesktopBundleParser {
  static const String _manifestFileName = 'manifest.json';
  static const String _dexFileName = 'classes.dex';

  /// Download a plugin bundle from a URL.
  Future<File> downloadBundle(String url, File targetFile) async {
    debugPrint('Downloading plugin bundle from: $url');

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to download bundle: HTTP ${response.statusCode}',
        );
      }

      await targetFile.parent.create(recursive: true);
      await targetFile.writeAsBytes(response.bodyBytes);

      debugPrint(
        'Downloaded bundle to ${targetFile.path} (${response.bodyBytes.length} bytes)',
      );

      return targetFile;
    } catch (e) {
      debugPrint('Error downloading bundle: $e');
      rethrow;
    }
  }

  /// Extract a plugin bundle to a directory.
  Future<CloudStreamBundleExtractResult> extractBundle(
    File bundleFile,
    Directory targetDir,
  ) async {
    debugPrint('Extracting bundle ${bundleFile.path} to ${targetDir.path}');

    try {
      // Read the archive
      final bytes = await bundleFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      // Create target directory
      if (await targetDir.exists()) {
        await targetDir.delete(recursive: true);
      }
      await targetDir.create(recursive: true);

      // Extract all files
      for (final file in archive) {
        final filePath = path.join(targetDir.path, file.name);

        if (file.isFile) {
          final outFile = File(filePath);
          await outFile.parent.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        } else {
          await Directory(filePath).create(recursive: true);
        }
      }

      // Parse the extracted content
      final manifest = await _findAndParseManifest(targetDir);
      final dexFile = await _findDexFile(targetDir);
      final jsFiles = await _findJsFiles(targetDir);
      final assetFiles = await _findAssetFiles(targetDir);

      debugPrint(
        'Extracted bundle: manifest=${manifest != null}, '
        'dex=${dexFile != null}, js=${jsFiles.length}, assets=${assetFiles.length}',
      );

      return CloudStreamBundleExtractResult(
        extractedDir: targetDir,
        manifest: manifest,
        dexFile: dexFile,
        jsFiles: jsFiles,
        assetFiles: assetFiles,
      );
    } catch (e) {
      debugPrint('Error extracting bundle: $e');
      rethrow;
    }
  }

  /// Parse a manifest file directly.
  Future<CloudStreamPluginManifest?> parseManifest(File manifestFile) async {
    try {
      final content = await manifestFile.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;
      return CloudStreamPluginManifest.fromJson(json);
    } catch (e) {
      debugPrint('Error parsing manifest: $e');
      return null;
    }
  }

  /// Find and parse the manifest file in an extracted directory.
  Future<CloudStreamPluginManifest?> _findAndParseManifest(
    Directory dir,
  ) async {
    // Check root directory first
    final rootManifest = File(path.join(dir.path, _manifestFileName));
    if (await rootManifest.exists()) {
      return parseManifest(rootManifest);
    }

    // Search in subdirectories (max depth 2)
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && path.basename(entity.path) == _manifestFileName) {
        final depth =
            path.split(entity.path).length - path.split(dir.path).length;
        if (depth <= 2) {
          return parseManifest(entity);
        }
      }
    }

    return null;
  }

  /// Find the DEX file in an extracted directory.
  Future<File?> _findDexFile(Directory dir) async {
    // Check root directory first
    final rootDex = File(path.join(dir.path, _dexFileName));
    if (await rootDex.exists()) {
      return rootDex;
    }

    // Search in subdirectories (max depth 3)
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.dex')) {
        final depth =
            path.split(entity.path).length - path.split(dir.path).length;
        if (depth <= 3) {
          return entity;
        }
      }
    }

    return null;
  }

  /// Find JavaScript files in an extracted directory.
  Future<List<File>> _findJsFiles(Directory dir) async {
    final jsFiles = <File>[];

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.js')) {
        jsFiles.add(entity);
      }
    }

    return jsFiles;
  }

  /// Find asset files in an extracted directory.
  Future<List<File>> _findAssetFiles(Directory dir) async {
    final assetFiles = <File>[];
    final assetExtensions = ['.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp'];

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final ext = path.extension(entity.path).toLowerCase();
        if (assetExtensions.contains(ext)) {
          assetFiles.add(entity);
        }
      }
    }

    return assetFiles;
  }
}
