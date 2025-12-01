import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import 'aniyomi_desktop_plugin_store.dart';

/// Result of APK extraction.
class ApkExtractionResult {
  final bool success;
  final String? error;
  final String? dexPath;
  final String? iconPath;
  final ApkManifestInfo? manifest;

  ApkExtractionResult({
    required this.success,
    this.error,
    this.dexPath,
    this.iconPath,
    this.manifest,
  });

  factory ApkExtractionResult.failure(String error) =>
      ApkExtractionResult(success: false, error: error);

  factory ApkExtractionResult.ok({
    required String dexPath,
    String? iconPath,
    ApkManifestInfo? manifest,
  }) => ApkExtractionResult(
    success: true,
    dexPath: dexPath,
    iconPath: iconPath,
    manifest: manifest,
  );
}

/// Parsed AndroidManifest.xml information.
class ApkManifestInfo {
  final String packageName;
  final String? versionName;
  final int? versionCode;
  final String? label;
  final Map<String, String> metadata;

  ApkManifestInfo({
    required this.packageName,
    this.versionName,
    this.versionCode,
    this.label,
    this.metadata = const {},
  });

  @override
  String toString() =>
      'ApkManifestInfo(package=$packageName, version=$versionName, code=$versionCode)';
}

/// Extracts and parses Aniyomi APK bundles for desktop execution.
///
/// APK files are ZIP archives containing:
/// - classes.dex: Compiled Dalvik bytecode
/// - AndroidManifest.xml: Package metadata (binary XML)
/// - res/: Resources including icons
class AniyomiApkExtractor {
  /// Extract an APK file to the specified output directory.
  ///
  /// Returns extraction result with paths to extracted files.
  Future<ApkExtractionResult> extractApk(
    String apkPath,
    String outputDir,
  ) async {
    try {
      final apkFile = File(apkPath);
      if (!await apkFile.exists()) {
        return ApkExtractionResult.failure('APK file not found: $apkPath');
      }

      final outputDirectory = Directory(outputDir);
      if (!await outputDirectory.exists()) {
        await outputDirectory.create(recursive: true);
      }

      // Read APK as ZIP
      final bytes = await apkFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      String? dexPath;
      String? iconPath;
      ApkManifestInfo? manifest;

      for (final file in archive) {
        final filename = file.name;

        if (file.isFile) {
          // Extract classes.dex
          if (filename == 'classes.dex') {
            dexPath = path.join(outputDir, 'classes.dex');
            await File(dexPath).writeAsBytes(file.content as List<int>);
            debugPrint('Extracted DEX: $dexPath');
          }

          // Extract icon (prefer highest resolution)
          if (_isIconFile(filename)) {
            final candidatePath = path.join(outputDir, 'icon.png');
            // Only overwrite if this is a higher resolution icon
            if (iconPath == null || _isHigherResolution(filename, iconPath)) {
              await File(candidatePath).writeAsBytes(file.content as List<int>);
              iconPath = candidatePath;
              debugPrint('Extracted icon: $iconPath');
            }
          }

          // Parse AndroidManifest.xml
          if (filename == 'AndroidManifest.xml') {
            try {
              manifest = _parseManifest(file.content as List<int>);
              debugPrint('Parsed manifest: $manifest');
            } catch (e) {
              debugPrint('Failed to parse manifest: $e');
              // Try to extract package name from APK filename as fallback
            }
          }
        }
      }

      if (dexPath == null) {
        return ApkExtractionResult.failure('No classes.dex found in APK');
      }

      return ApkExtractionResult.ok(
        dexPath: dexPath,
        iconPath: iconPath,
        manifest: manifest,
      );
    } catch (e) {
      return ApkExtractionResult.failure('APK extraction failed: $e');
    }
  }

  /// Check if a file path is an icon file.
  bool _isIconFile(String filename) {
    return filename.contains('mipmap') &&
        filename.contains('ic_launcher') &&
        filename.endsWith('.png');
  }

  /// Check if a new icon path is higher resolution than existing.
  bool _isHigherResolution(String newPath, String existingPath) {
    const resolutions = ['xxxhdpi', 'xxhdpi', 'xhdpi', 'hdpi', 'mdpi', 'ldpi'];

    int getResolutionIndex(String p) {
      for (int i = 0; i < resolutions.length; i++) {
        if (p.contains(resolutions[i])) return i;
      }
      return resolutions.length;
    }

    return getResolutionIndex(newPath) < getResolutionIndex(existingPath);
  }

  /// Parse AndroidManifest.xml (binary XML format).
  ///
  /// Android's binary XML format is complex. This is a simplified parser
  /// that extracts key attributes. For full parsing, consider using
  /// a dedicated library.
  ApkManifestInfo? _parseManifest(List<int> bytes) {
    // Android binary XML starts with magic number 0x00080003
    if (bytes.length < 8) return null;

    // Try to find package name in the binary data
    // This is a simplified approach - full parsing would require
    // implementing the AXML format parser

    String? packageName;
    String? versionName;
    int? versionCode;

    // Look for string patterns in the binary data
    final content = String.fromCharCodes(bytes);

    // Try to extract package name (usually appears as a string)
    final packageMatch = RegExp(
      r'eu\.kanade\.tachiyomi\.[a-z.]+',
    ).firstMatch(content);
    if (packageMatch != null) {
      packageName = packageMatch.group(0);
    }

    // If we couldn't parse the binary XML, return null
    // The caller should fall back to extracting info from the APK filename
    if (packageName == null) {
      return null;
    }

    return ApkManifestInfo(
      packageName: packageName,
      versionName: versionName,
      versionCode: versionCode,
    );
  }

  /// Extract package info from APK filename as fallback.
  ///
  /// Aniyomi APK names follow the pattern:
  /// tachiyomi-{lang}.{name}-v{version}.apk
  AniyomiPluginMetadata? parseApkFilename(String filename) {
    // Pattern: tachiyomi-en.example-v1.0.0.apk
    final match = RegExp(
      r'tachiyomi-([a-z]{2,3})\.([a-zA-Z0-9]+)-v([\d.]+)\.apk',
    ).firstMatch(filename);

    if (match == null) return null;

    final lang = match.group(1)!;
    final name = match.group(2)!;
    final version = match.group(3)!;

    return AniyomiPluginMetadata(
      packageName: 'eu.kanade.tachiyomi.animeextension.$lang.$name',
      name: name,
      version: version,
      lang: lang,
    );
  }

  /// Download and extract an APK from URL.
  Future<ApkExtractionResult> downloadAndExtract(
    String apkUrl,
    String outputDir,
  ) async {
    try {
      // Download APK
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(apkUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        return ApkExtractionResult.failure(
          'Failed to download APK: HTTP ${response.statusCode}',
        );
      }

      // Save to temp file
      final tempDir = Directory.systemTemp;
      final tempApk = File(
        path.join(
          tempDir.path,
          'aniyomi_${DateTime.now().millisecondsSinceEpoch}.apk',
        ),
      );

      final sink = tempApk.openWrite();
      await response.pipe(sink);
      await sink.close();

      // Extract
      final result = await extractApk(tempApk.path, outputDir);

      // Clean up temp file
      await tempApk.delete();

      return result;
    } catch (e) {
      return ApkExtractionResult.failure('Download failed: $e');
    }
  }
}

/// Parse Aniyomi repository index.
class AniyomiRepoIndexParser {
  /// Fetch and parse repository index.
  Future<List<AniyomiAvailableExtension>> fetchIndex(
    String repoUrl, {
    bool isAnime = true,
  }) async {
    try {
      final indexUrl = repoUrl.endsWith('index.min.json')
          ? repoUrl
          : '${repoUrl.trimRight().replaceAll(RegExp(r'/+$'), '')}/index.min.json';

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(indexUrl));
      final response = await request.close();

      if (response.statusCode != 200) {
        debugPrint('Failed to fetch index: HTTP ${response.statusCode}');
        return [];
      }

      final content = await response
          .transform(const SystemEncoding().decoder)
          .join();
      final List<dynamic> json = await compute(_parseJson, content);

      final baseUrl = repoUrl.endsWith('index.min.json')
          ? repoUrl.replaceAll('index.min.json', 'apk/')
          : '${repoUrl.trimRight().replaceAll(RegExp(r'/+$'), '')}/apk/';

      return json
          .map(
            (e) => AniyomiAvailableExtension.fromJson(
              e as Map<String, dynamic>,
              baseUrl,
              isAnime: isAnime,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error fetching Aniyomi index: $e');
      return [];
    }
  }

  static List<dynamic> _parseJson(String content) {
    if (content.isEmpty || !content.trimLeft().startsWith('[')) {
      return [];
    }
    try {
      return List<dynamic>.from(jsonDecode(content) as List);
    } catch (_) {
      return [];
    }
  }
}
