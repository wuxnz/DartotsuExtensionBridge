import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Metadata for an installed Aniyomi plugin.
class AniyomiPluginMetadata {
  final String packageName;
  final String name;
  final String version;
  final String lang;
  final bool isNsfw;
  final String? iconPath;
  final String? apkPath;
  final String? jarPath;
  final int libVersion;
  final List<AniyomiSourceInfo> sources;
  final DateTime installedAt;
  final DateTime? updatedAt;
  final bool isAnime;
  final bool hasUpdate;
  final bool isObsolete;
  final bool isUnofficial;

  AniyomiPluginMetadata({
    required this.packageName,
    required this.name,
    required this.version,
    required this.lang,
    this.isNsfw = false,
    this.iconPath,
    this.apkPath,
    this.jarPath,
    this.libVersion = 0,
    this.sources = const [],
    DateTime? installedAt,
    this.updatedAt,
    this.isAnime = true,
    this.hasUpdate = false,
    this.isObsolete = false,
    this.isUnofficial = false,
  }) : installedAt = installedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'packageName': packageName,
    'name': name,
    'version': version,
    'lang': lang,
    'isNsfw': isNsfw,
    'iconPath': iconPath,
    'apkPath': apkPath,
    'jarPath': jarPath,
    'libVersion': libVersion,
    'sources': sources.map((s) => s.toJson()).toList(),
    'installedAt': installedAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isAnime': isAnime,
    'hasUpdate': hasUpdate,
    'isObsolete': isObsolete,
    'isUnofficial': isUnofficial,
  };

  factory AniyomiPluginMetadata.fromJson(Map<String, dynamic> json) {
    return AniyomiPluginMetadata(
      packageName: json['packageName'] as String,
      name: json['name'] as String,
      version: json['version'] as String,
      lang: json['lang'] as String? ?? 'en',
      isNsfw: json['isNsfw'] as bool? ?? false,
      iconPath: json['iconPath'] as String?,
      apkPath: json['apkPath'] as String?,
      jarPath: json['jarPath'] as String?,
      libVersion: json['libVersion'] as int? ?? 0,
      sources:
          (json['sources'] as List<dynamic>?)
              ?.map(
                (s) => AniyomiSourceInfo.fromJson(s as Map<String, dynamic>),
              )
              .toList() ??
          [],
      installedAt: json['installedAt'] != null
          ? DateTime.parse(json['installedAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isAnime: json['isAnime'] as bool? ?? true,
      hasUpdate: json['hasUpdate'] as bool? ?? false,
      isObsolete: json['isObsolete'] as bool? ?? false,
      isUnofficial: json['isUnofficial'] as bool? ?? false,
    );
  }

  AniyomiPluginMetadata copyWith({
    String? packageName,
    String? name,
    String? version,
    String? lang,
    bool? isNsfw,
    String? iconPath,
    String? apkPath,
    String? jarPath,
    int? libVersion,
    List<AniyomiSourceInfo>? sources,
    DateTime? installedAt,
    DateTime? updatedAt,
    bool? isAnime,
    bool? hasUpdate,
    bool? isObsolete,
    bool? isUnofficial,
  }) {
    return AniyomiPluginMetadata(
      packageName: packageName ?? this.packageName,
      name: name ?? this.name,
      version: version ?? this.version,
      lang: lang ?? this.lang,
      isNsfw: isNsfw ?? this.isNsfw,
      iconPath: iconPath ?? this.iconPath,
      apkPath: apkPath ?? this.apkPath,
      jarPath: jarPath ?? this.jarPath,
      libVersion: libVersion ?? this.libVersion,
      sources: sources ?? this.sources,
      installedAt: installedAt ?? this.installedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isAnime: isAnime ?? this.isAnime,
      hasUpdate: hasUpdate ?? this.hasUpdate,
      isObsolete: isObsolete ?? this.isObsolete,
      isUnofficial: isUnofficial ?? this.isUnofficial,
    );
  }
}

/// Information about a source within an Aniyomi plugin.
class AniyomiSourceInfo {
  final String name;
  final String lang;
  final int id;
  final String? baseUrl;

  AniyomiSourceInfo({
    required this.name,
    required this.lang,
    required this.id,
    this.baseUrl,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'lang': lang,
    'id': id,
    'baseUrl': baseUrl,
  };

  factory AniyomiSourceInfo.fromJson(Map<String, dynamic> json) {
    return AniyomiSourceInfo(
      name: json['name'] as String,
      lang: json['lang'] as String,
      id: json['id'] as int,
      baseUrl: json['baseUrl'] as String?,
    );
  }
}

/// Available extension from repository index.
class AniyomiAvailableExtension {
  final String name;
  final String packageName;
  final String apkName;
  final String lang;
  final int code;
  final String version;
  final bool isNsfw;
  final String? iconUrl;
  final String repoUrl;
  final List<AniyomiSourceInfo> sources;
  final bool isAnime;

  AniyomiAvailableExtension({
    required this.name,
    required this.packageName,
    required this.apkName,
    required this.lang,
    required this.code,
    required this.version,
    this.isNsfw = false,
    this.iconUrl,
    required this.repoUrl,
    this.sources = const [],
    this.isAnime = true,
  });

  String get apkUrl {
    final baseUrl = repoUrl.endsWith('/') ? repoUrl : '$repoUrl/';
    return '$baseUrl$apkName';
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'packageName': packageName,
    'apkName': apkName,
    'lang': lang,
    'code': code,
    'version': version,
    'isNsfw': isNsfw,
    'iconUrl': iconUrl,
    'repoUrl': repoUrl,
    'sources': sources.map((s) => s.toJson()).toList(),
    'isAnime': isAnime,
  };

  factory AniyomiAvailableExtension.fromJson(
    Map<String, dynamic> json,
    String repoUrl, {
    bool isAnime = true,
  }) {
    return AniyomiAvailableExtension(
      name: json['name'] as String,
      packageName: json['pkg'] as String,
      apkName: json['apk'] as String,
      lang: json['lang'] as String,
      code: json['code'] as int,
      version: json['version'] as String,
      isNsfw: (json['nsfw'] as int?) == 1,
      iconUrl: json['iconUrl'] as String?,
      repoUrl: repoUrl,
      sources:
          (json['sources'] as List<dynamic>?)
              ?.map(
                (s) => AniyomiSourceInfo.fromJson(s as Map<String, dynamic>),
              )
              .toList() ??
          [],
      isAnime: isAnime,
    );
  }
}

/// Desktop plugin store for Aniyomi extensions.
///
/// Manages plugin metadata storage, installation tracking, and file paths.
class AniyomiDesktopPluginStore {
  static const String _metadataFileName = 'aniyomi_plugins.json';
  static const String _pluginsDirName = 'aniyomi_plugins';

  Directory? _rootDir;
  final Map<String, AniyomiPluginMetadata> _plugins = {};
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
  int get pluginCount => _plugins.length;

  /// Initialize the plugin store.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final appDir = await getApplicationSupportDirectory();
      _rootDir = Directory(
        path.join(appDir.path, Platform.operatingSystem, _pluginsDirName),
      );

      if (!await _rootDir!.exists()) {
        await _rootDir!.create(recursive: true);
      }

      await _loadMetadata();
      _isInitialized = true;
      debugPrint(
        'AniyomiDesktopPluginStore initialized: ${_plugins.length} plugins',
      );
    } catch (e) {
      debugPrint('Failed to initialize AniyomiDesktopPluginStore: $e');
      rethrow;
    }
  }

  /// Get the root directory for plugins.
  Directory get rootDir {
    if (_rootDir == null) {
      throw StateError('Plugin store not initialized');
    }
    return _rootDir!;
  }

  /// Get the metadata file path.
  File get _metadataFile => File(path.join(rootDir.path, _metadataFileName));

  /// Load metadata from disk.
  Future<void> _loadMetadata() async {
    try {
      if (await _metadataFile.exists()) {
        final content = await _metadataFile.readAsString();
        final json = jsonDecode(content) as Map<String, dynamic>;
        final plugins = json['plugins'] as List<dynamic>? ?? [];

        _plugins.clear();
        for (final p in plugins) {
          final metadata = AniyomiPluginMetadata.fromJson(
            p as Map<String, dynamic>,
          );
          _plugins[metadata.packageName] = metadata;
        }
      }
    } catch (e) {
      debugPrint('Error loading Aniyomi plugin metadata: $e');
      _plugins.clear();
    }
  }

  /// Save metadata to disk.
  Future<void> _saveMetadata() async {
    try {
      final json = {
        'version': 1,
        'updatedAt': DateTime.now().toIso8601String(),
        'plugins': _plugins.values.map((p) => p.toJson()).toList(),
      };
      await _metadataFile.writeAsString(
        const JsonEncoder.withIndent('  ').convert(json),
      );
    } catch (e) {
      debugPrint('Error saving Aniyomi plugin metadata: $e');
    }
  }

  /// List all installed plugins.
  List<AniyomiPluginMetadata> listPlugins() => _plugins.values.toList();

  /// List anime plugins.
  List<AniyomiPluginMetadata> listAnimePlugins() =>
      _plugins.values.where((p) => p.isAnime).toList();

  /// List manga plugins.
  List<AniyomiPluginMetadata> listMangaPlugins() =>
      _plugins.values.where((p) => !p.isAnime).toList();

  /// Get a plugin by package name.
  AniyomiPluginMetadata? getPlugin(String packageName) => _plugins[packageName];

  /// Check if a plugin is installed.
  bool isInstalled(String packageName) => _plugins.containsKey(packageName);

  /// Add or update a plugin.
  Future<void> upsertPlugin(AniyomiPluginMetadata metadata) async {
    _plugins[metadata.packageName] = metadata;
    await _saveMetadata();
  }

  /// Remove a plugin.
  Future<bool> removePlugin(String packageName) async {
    final removed = _plugins.remove(packageName);
    if (removed != null) {
      await _saveMetadata();

      // Clean up plugin files
      final pluginDir = getPluginDirectory(packageName);
      if (await pluginDir.exists()) {
        await pluginDir.delete(recursive: true);
      }

      return true;
    }
    return false;
  }

  /// Get the directory for a specific plugin.
  Directory getPluginDirectory(String packageName) {
    return Directory(path.join(rootDir.path, packageName));
  }

  /// Get the APK path for a plugin.
  String getApkPath(String packageName) {
    return path.join(getPluginDirectory(packageName).path, 'extension.apk');
  }

  /// Get the JAR path for a plugin.
  String getJarPath(String packageName) {
    return path.join(getPluginDirectory(packageName).path, 'classes.jar');
  }

  /// Get the icon path for a plugin.
  String getIconPath(String packageName) {
    return path.join(getPluginDirectory(packageName).path, 'icon.png');
  }

  /// Get the preferences path for a plugin.
  String getPreferencesPath(String packageName) {
    return path.join(getPluginDirectory(packageName).path, 'preferences.json');
  }

  /// Mark a plugin as having an update available.
  Future<void> markHasUpdate(String packageName, bool hasUpdate) async {
    final plugin = _plugins[packageName];
    if (plugin != null) {
      _plugins[packageName] = plugin.copyWith(hasUpdate: hasUpdate);
      await _saveMetadata();
    }
  }

  /// Get plugins that have updates available.
  List<AniyomiPluginMetadata> getPluginsWithUpdates() =>
      _plugins.values.where((p) => p.hasUpdate).toList();
}
