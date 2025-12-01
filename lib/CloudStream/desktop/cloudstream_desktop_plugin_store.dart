import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Metadata for a CloudStream plugin stored on desktop.
class CloudStreamDesktopPluginMetadata {
  final String internalName;
  final String? displayName;
  final String? repoUrl;
  final String? pluginListUrl;
  final String? downloadUrl;
  final String? version;
  final List<String> tvTypes;
  final String? lang;
  final bool isNsfw;
  final List<int> itemTypes;
  final String? localPath;
  final int? lastUpdated;
  final CloudStreamDesktopPluginStatus status;
  final String? iconUrl;

  /// Whether this plugin has JS code that can be executed on desktop.
  /// If false, the plugin is DEX-only and requires Android.
  final bool hasJsCode;

  /// Whether this plugin has DEX code (Android bytecode).
  final bool hasDexCode;

  CloudStreamDesktopPluginMetadata({
    required this.internalName,
    this.displayName,
    this.repoUrl,
    this.pluginListUrl,
    this.downloadUrl,
    this.version,
    this.tvTypes = const [],
    this.lang,
    this.isNsfw = false,
    this.itemTypes = const [],
    this.localPath,
    this.lastUpdated,
    this.status = CloudStreamDesktopPluginStatus.installed,
    this.iconUrl,
    this.hasJsCode = false,
    this.hasDexCode = false,
  });

  factory CloudStreamDesktopPluginMetadata.fromJson(Map<String, dynamic> json) {
    return CloudStreamDesktopPluginMetadata(
      internalName: json['internalName'] as String,
      displayName: json['displayName'] as String? ?? json['name'] as String?,
      repoUrl: json['repoUrl'] as String?,
      pluginListUrl: json['pluginListUrl'] as String?,
      downloadUrl: json['downloadUrl'] as String?,
      version: json['version'] as String?,
      tvTypes:
          (json['tvTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      lang: json['lang'] as String?,
      isNsfw: json['isNsfw'] as bool? ?? false,
      itemTypes:
          (json['itemTypes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [],
      localPath: json['localPath'] as String?,
      lastUpdated: json['lastUpdated'] as int?,
      status: CloudStreamDesktopPluginStatus.fromString(
        json['status'] as String?,
      ),
      iconUrl: json['iconUrl'] as String?,
      hasJsCode: json['hasJsCode'] as bool? ?? false,
      hasDexCode: json['hasDexCode'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'internalName': internalName,
      'displayName': displayName,
      'name': displayName,
      'repoUrl': repoUrl,
      'pluginListUrl': pluginListUrl,
      'downloadUrl': downloadUrl,
      'version': version,
      'tvTypes': tvTypes,
      'lang': lang,
      'isNsfw': isNsfw,
      'itemTypes': itemTypes,
      'localPath': localPath,
      'lastUpdated': lastUpdated,
      'status': status.name,
      'iconUrl': iconUrl,
      'hasJsCode': hasJsCode,
      'hasDexCode': hasDexCode,
    };
  }

  CloudStreamDesktopPluginMetadata copyWith({
    String? internalName,
    String? displayName,
    String? repoUrl,
    String? pluginListUrl,
    String? downloadUrl,
    String? version,
    List<String>? tvTypes,
    String? lang,
    bool? isNsfw,
    List<int>? itemTypes,
    String? localPath,
    int? lastUpdated,
    CloudStreamDesktopPluginStatus? status,
    String? iconUrl,
    bool? hasJsCode,
    bool? hasDexCode,
  }) {
    return CloudStreamDesktopPluginMetadata(
      internalName: internalName ?? this.internalName,
      displayName: displayName ?? this.displayName,
      repoUrl: repoUrl ?? this.repoUrl,
      pluginListUrl: pluginListUrl ?? this.pluginListUrl,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      version: version ?? this.version,
      tvTypes: tvTypes ?? this.tvTypes,
      lang: lang ?? this.lang,
      isNsfw: isNsfw ?? this.isNsfw,
      itemTypes: itemTypes ?? this.itemTypes,
      localPath: localPath ?? this.localPath,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      status: status ?? this.status,
      iconUrl: iconUrl ?? this.iconUrl,
      hasJsCode: hasJsCode ?? this.hasJsCode,
      hasDexCode: hasDexCode ?? this.hasDexCode,
    );
  }

  /// Check if this plugin matches the given item type.
  bool matchesItemType(int itemType) {
    return itemTypes.isEmpty || itemTypes.contains(itemType);
  }

  /// Convert to installed source payload format for Flutter.
  Map<String, dynamic> toInstalledSourcePayload(int itemType) {
    return {
      'id': internalName,
      'name': displayName ?? internalName,
      'lang': lang,
      'isNsfw': isNsfw,
      'iconUrl': iconUrl,
      'version': version,
      'itemType': itemType,
      'repo': repoUrl,
      'hasUpdate': false,
      'isObsolete': status == CloudStreamDesktopPluginStatus.disabled,
      'extensionType': 2, // ExtensionType.cloudstream index
      'localPath': localPath,
      'hasJsCode': hasJsCode,
      'hasDexCode': hasDexCode,
      // isExecutableOnDesktop is set by the bridge after checking JS service
    };
  }

  /// Convert to metadata payload format for Flutter.
  Map<String, dynamic> toMetadataPayload() {
    return {
      'internalName': internalName,
      'name': displayName,
      'repoUrl': repoUrl,
      'pluginListUrl': pluginListUrl,
      'downloadUrl': downloadUrl,
      'version': version,
      'tvTypes': tvTypes,
      'lang': lang,
      'isNsfw': isNsfw,
      'itemTypes': itemTypes,
      'localPath': localPath,
      'lastUpdated': lastUpdated,
      'status': status.name,
      'iconUrl': iconUrl,
    };
  }
}

enum CloudStreamDesktopPluginStatus {
  installed,
  disabled;

  static CloudStreamDesktopPluginStatus fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'disabled':
        return CloudStreamDesktopPluginStatus.disabled;
      default:
        return CloudStreamDesktopPluginStatus.installed;
    }
  }
}

/// Desktop implementation of CloudStream plugin store.
///
/// This class manages plugin metadata storage on desktop platforms (Linux/Windows).
/// It stores plugin metadata in a JSON file and manages the plugin directory structure.
///
/// Note: On desktop, plugins are stored as metadata only. The actual plugin execution
/// requires a JavaScript runtime (QuickJS) for JS-based plugins, as DEX files cannot
/// be executed outside of Android.
class CloudStreamDesktopPluginStore {
  static const String _metadataFileName = 'plugins.json';
  static const String _pluginsDirName = 'cloudstream_plugins';

  Directory? _rootDir;
  bool _isInitialized = false;

  /// Initialize the plugin store.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final appDir = await getApplicationDocumentsDirectory();
      final platformDir = Platform.isLinux ? 'linux' : 'windows';
      _rootDir = Directory(
        path.join(appDir.path, 'Aniya', platformDir, _pluginsDirName),
      );

      if (!await _rootDir!.exists()) {
        await _rootDir!.create(recursive: true);
      }

      _isInitialized = true;
      debugPrint(
        'CloudStreamDesktopPluginStore initialized at ${_rootDir!.path}',
      );
    } catch (e) {
      debugPrint('Failed to initialize CloudStreamDesktopPluginStore: $e');
      rethrow;
    }
  }

  /// Get the root directory for plugin storage.
  Directory get rootDir {
    if (!_isInitialized || _rootDir == null) {
      throw StateError('CloudStreamDesktopPluginStore not initialized');
    }
    return _rootDir!;
  }

  /// Get the metadata file.
  File get _metadataFile => File(path.join(rootDir.path, _metadataFileName));

  /// List all installed plugins.
  Future<List<CloudStreamDesktopPluginMetadata>> listPlugins() async {
    await initialize();

    if (!await _metadataFile.exists()) {
      return [];
    }

    try {
      final content = await _metadataFile.readAsString();
      final List<dynamic> jsonList = json.decode(content);
      return jsonList
          .map(
            (e) => CloudStreamDesktopPluginMetadata.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Failed to read plugin metadata: $e');
      return [];
    }
  }

  /// Insert or update a plugin.
  Future<CloudStreamDesktopPluginMetadata> upsertPlugin(
    CloudStreamDesktopPluginMetadata metadata,
  ) async {
    await initialize();

    final plugins = await listPlugins();
    final existingIndex = plugins.indexWhere(
      (p) => p.internalName == metadata.internalName,
    );

    final updated = metadata.copyWith(
      lastUpdated:
          metadata.lastUpdated ?? DateTime.now().millisecondsSinceEpoch,
    );

    if (existingIndex >= 0) {
      plugins[existingIndex] = updated;
    } else {
      plugins.add(updated);
    }

    await _writeMetadata(plugins);
    return updated;
  }

  /// Remove a plugin.
  Future<bool> removePlugin(String internalName) async {
    await initialize();

    final plugins = await listPlugins();
    final initialCount = plugins.length;
    plugins.removeWhere((p) => p.internalName == internalName);

    if (plugins.length != initialCount) {
      await _writeMetadata(plugins);
      await _deletePluginDirectory(internalName);
      return true;
    }

    return false;
  }

  /// Get a specific plugin by internal name.
  Future<CloudStreamDesktopPluginMetadata?> getPlugin(
    String internalName,
  ) async {
    final plugins = await listPlugins();
    return plugins.cast<CloudStreamDesktopPluginMetadata?>().firstWhere(
      (p) => p?.internalName == internalName,
      orElse: () => null,
    );
  }

  /// Resolve the plugin directory for a given plugin.
  Future<Directory> resolvePluginDirectory(
    String? repoKey,
    String internalName,
  ) async {
    await initialize();

    final repoSegment = repoKey != null
        ? _sanitizeDirectoryName(repoKey)
        : 'manual';
    final pluginDir = Directory(
      path.join(
        rootDir.path,
        repoSegment,
        _sanitizeDirectoryName(internalName),
      ),
    );

    if (!await pluginDir.exists()) {
      await pluginDir.create(recursive: true);
    }

    return pluginDir;
  }

  /// Resolve the bundle path for downloading a plugin.
  Future<File> resolveBundlePath(
    String? repoKey,
    String internalName, {
    String extension = 'cs3',
  }) async {
    await initialize();

    final repoSegment = repoKey != null
        ? _sanitizeDirectoryName(repoKey)
        : 'manual';
    final bundlesDir = Directory(
      path.join(rootDir.path, 'bundles', repoSegment),
    );

    if (!await bundlesDir.exists()) {
      await bundlesDir.create(recursive: true);
    }

    return File(
      path.join(
        bundlesDir.path,
        '${_sanitizeFileName(internalName)}.$extension',
      ),
    );
  }

  /// Write metadata to file.
  Future<void> _writeMetadata(
    List<CloudStreamDesktopPluginMetadata> plugins,
  ) async {
    final jsonList = plugins.map((p) => p.toJson()).toList();
    await _metadataFile.writeAsString(
      const JsonEncoder.withIndent('  ').convert(jsonList),
    );
  }

  /// Delete a plugin's directory.
  Future<void> _deletePluginDirectory(String internalName) async {
    final sanitizedName = _sanitizeDirectoryName(internalName);

    // Search in all repo directories
    await for (final entity in rootDir.list()) {
      if (entity is Directory) {
        final targetDir = Directory(path.join(entity.path, sanitizedName));
        if (await targetDir.exists()) {
          await targetDir.delete(recursive: true);
          debugPrint('Deleted plugin directory: ${targetDir.path}');
        }
      }
    }
  }

  /// Sanitize a string for use as a directory name.
  String _sanitizeDirectoryName(String raw) {
    return raw
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9._-]'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '')
        .ifEmpty('plugin');
  }

  /// Sanitize a string for use as a file name.
  String _sanitizeFileName(String raw) {
    return raw.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
  }
}

extension _StringExtension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
