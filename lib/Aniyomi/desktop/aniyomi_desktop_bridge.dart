import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import '../../CloudStream/desktop/dex/dex_plugin_service.dart';
import 'aniyomi_apk_extractor.dart';
import 'aniyomi_desktop_config.dart';
import 'aniyomi_desktop_plugin_store.dart';
import 'aniyomi_host_shims.dart';

/// Desktop implementation of the Aniyomi extension bridge.
///
/// This class provides a pure Dart implementation of Aniyomi plugin management
/// for Linux and Windows platforms. It handles:
/// - Plugin installation (downloading and extracting APK bundles)
/// - Plugin metadata storage
/// - Plugin listing and status queries
/// - DEX plugin execution via dex2jar + JRE
///
/// **Capabilities:**
/// - Full plugin management (install, list, uninstall)
/// - DEX plugin execution (requires JRE + dex2jar)
///
/// **Limitations:**
/// - Requires external tools (JRE, dex2jar)
/// - Some Android APIs may not be fully emulated
class AniyomiDesktopBridge {
  static const String channelName = 'aniyomiExtensionBridge';

  final AniyomiDesktopPluginStore _pluginStore;
  final AniyomiApkExtractor _apkExtractor;
  final AniyomiRepoIndexParser _indexParser;
  late final DexPluginService _dexPluginService;

  bool _isInitialized = false;
  int _loadedPluginCount = 0;

  // Cache for host shims per plugin
  final Map<String, AniyomiHostShims> _hostShims = {};

  // Cache for available extensions
  List<AniyomiAvailableExtension> _availableAnimeExtensions = [];
  List<AniyomiAvailableExtension> _availableMangaExtensions = [];

  AniyomiDesktopBridge()
    : _pluginStore = AniyomiDesktopPluginStore(),
      _apkExtractor = AniyomiApkExtractor(),
      _indexParser = AniyomiRepoIndexParser() {
    // Share the DEX plugin service with CloudStream
    _dexPluginService = DexPluginService(_createPluginStoreAdapter());
  }

  /// Create an adapter to use AniyomiDesktopPluginStore with DexPluginService.
  dynamic _createPluginStoreAdapter() {
    // For now, we'll create a separate instance
    // In the future, we could share the DEX runtime
    return null; // DexPluginService will create its own store
  }

  /// Initialize the desktop bridge.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _pluginStore.initialize();

      // Initialize DEX runtime if enabled
      if (aniyomiDesktopConfig.enableDesktopAniyomi) {
        await _dexPluginService.initialize();
      }

      _loadedPluginCount = _pluginStore.pluginCount;
      _isInitialized = true;

      debugPrint(
        'AniyomiDesktopBridge initialized: $_loadedPluginCount plugins',
      );
    } catch (e) {
      debugPrint('Failed to initialize AniyomiDesktopBridge: $e');
      rethrow;
    }
  }

  /// Check if DEX runtime is available.
  bool get isDexRuntimeAvailable => _dexPluginService.isAvailable;

  /// Check if Aniyomi desktop is enabled.
  bool get isEnabled => aniyomiDesktopConfig.enableDesktopAniyomi;

  /// Handle a method call from the platform channel.
  Future<dynamic> handleMethodCall(MethodCall call) async {
    debugPrint('AniyomiDesktopBridge: ${call.method}');

    switch (call.method) {
      case 'getInstalledAnimeExtensions':
        return _getInstalledExtensions(isAnime: true);

      case 'getInstalledMangaExtensions':
        return _getInstalledExtensions(isAnime: false);

      case 'fetchAnimeExtensions':
        return _fetchAvailableExtensions(call.arguments, isAnime: true);

      case 'fetchMangaExtensions':
        return _fetchAvailableExtensions(call.arguments, isAnime: false);

      case 'installExtension':
        return _installExtension(call.arguments);

      case 'uninstallExtension':
        return _uninstallExtension(call.arguments);

      case 'search':
        return _handleSearch(call.arguments);

      case 'getPopular':
        return _handleGetPopular(call.arguments);

      case 'getLatestUpdates':
        return _handleGetLatestUpdates(call.arguments);

      case 'getDetail':
        return _handleGetDetail(call.arguments);

      case 'getVideoList':
        return _handleGetVideoList(call.arguments);

      case 'getPageList':
        return _handleGetPageList(call.arguments);

      case 'getPreference':
        return _handleGetPreference(call.arguments);

      case 'saveSourcePreference':
        return _handleSavePreference(call.arguments);

      default:
        throw PlatformException(
          code: 'NOT_IMPLEMENTED',
          message: 'Aniyomi method ${call.method} not implemented on desktop',
        );
    }
  }

  /// Get installed extensions.
  Future<List<Map<String, dynamic>>> _getInstalledExtensions({
    required bool isAnime,
  }) async {
    final plugins = isAnime
        ? _pluginStore.listAnimePlugins()
        : _pluginStore.listMangaPlugins();

    return plugins
        .map(
          (p) => {
            'id': p.packageName,
            'name': p.name,
            'lang': p.lang,
            'isNsfw': p.isNsfw,
            'iconUrl': p.iconPath,
            'version': p.version,
            'libVersion': p.libVersion,
            'supportedLanguages': p.sources.map((s) => s.lang).toList(),
            'itemType': isAnime ? 1 : 0,
            'hasUpdate': p.hasUpdate,
            'isObsolete': p.isObsolete,
            'isUnofficial': p.isUnofficial,
          },
        )
        .toList();
  }

  /// Fetch available extensions from repositories.
  Future<List<Map<String, dynamic>>> _fetchAvailableExtensions(
    dynamic args, {
    required bool isAnime,
  }) async {
    final repos = (args as List<dynamic>?)?.cast<String>() ?? [];
    if (repos.isEmpty) return [];

    final extensions = <AniyomiAvailableExtension>[];

    for (final repo in repos) {
      final repoExtensions = await _indexParser.fetchIndex(
        repo,
        isAnime: isAnime,
      );
      extensions.addAll(repoExtensions);
    }

    // Cache for later use
    if (isAnime) {
      _availableAnimeExtensions = extensions;
    } else {
      _availableMangaExtensions = extensions;
    }

    return extensions
        .map(
          (e) => {
            'name': e.name,
            'id': e.packageName,
            'version': e.version,
            'libVersion': e.code,
            'supportedLanguages': e.sources.map((s) => s.lang).toList(),
            'lang': e.lang,
            'isNsfw': e.isNsfw,
            'apkName': e.apkName,
            'iconUrl': e.iconUrl,
            'itemType': isAnime ? 1 : 0,
          },
        )
        .toList();
  }

  /// Install an extension.
  Future<Map<String, dynamic>> _installExtension(dynamic args) async {
    final argsMap = args as Map<dynamic, dynamic>?;
    if (argsMap == null) {
      return {'success': false, 'error': 'Invalid arguments'};
    }

    final packageName = argsMap['packageName'] as String?;
    final apkUrl = argsMap['apkUrl'] as String?;
    final isAnime = argsMap['isAnime'] as bool? ?? true;

    if (packageName == null || apkUrl == null) {
      return {'success': false, 'error': 'Missing packageName or apkUrl'};
    }

    try {
      // Create plugin directory
      final pluginDir = _pluginStore.getPluginDirectory(packageName);
      await pluginDir.create(recursive: true);

      // Download and extract APK
      final result = await _apkExtractor.downloadAndExtract(
        apkUrl,
        pluginDir.path,
      );

      if (!result.success) {
        return {'success': false, 'error': result.error};
      }

      // Find extension info from cache
      final available = isAnime
          ? _availableAnimeExtensions.firstWhere(
              (e) => e.packageName == packageName,
              orElse: () => throw Exception('Extension not found in cache'),
            )
          : _availableMangaExtensions.firstWhere(
              (e) => e.packageName == packageName,
              orElse: () => throw Exception('Extension not found in cache'),
            );

      // Convert DEX to JAR
      final jarPath = _pluginStore.getJarPath(packageName);
      // TODO: Implement DEX to JAR conversion using shared CloudStream runtime

      // Save metadata
      final metadata = AniyomiPluginMetadata(
        packageName: packageName,
        name: available.name,
        version: available.version,
        lang: available.lang,
        isNsfw: available.isNsfw,
        iconPath: result.iconPath,
        apkPath: path.join(pluginDir.path, 'extension.apk'),
        jarPath: jarPath,
        libVersion: available.code,
        sources: available.sources,
        isAnime: isAnime,
      );

      await _pluginStore.upsertPlugin(metadata);
      _loadedPluginCount = _pluginStore.pluginCount;

      return {
        'success': true,
        'packageName': packageName,
        'name': available.name,
        'version': available.version,
      };
    } catch (e) {
      debugPrint('Failed to install extension: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Uninstall an extension.
  Future<Map<String, dynamic>> _uninstallExtension(dynamic args) async {
    final packageName = args as String?;
    if (packageName == null) {
      return {'success': false, 'error': 'Missing packageName'};
    }

    try {
      // Dispose host shims
      final shims = _hostShims.remove(packageName);
      await shims?.dispose();

      // Remove from store (also deletes files)
      final removed = await _pluginStore.removePlugin(packageName);
      _loadedPluginCount = _pluginStore.pluginCount;

      return {'success': removed, 'packageName': packageName};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  /// Get or create host shims for a plugin.
  Future<AniyomiHostShims> _getHostShims(String packageName) async {
    if (!_hostShims.containsKey(packageName)) {
      final plugin = _pluginStore.getPlugin(packageName);
      if (plugin == null) {
        throw Exception('Plugin not found: $packageName');
      }

      final shims = AniyomiHostShims(
        pluginId: packageName,
        pluginDir: _pluginStore.getPluginDirectory(packageName).path,
      );
      await shims.initialize();
      _hostShims[packageName] = shims;
    }
    return _hostShims[packageName]!;
  }

  /// Handle search request.
  Future<Map<String, dynamic>> _handleSearch(dynamic args) async {
    final argsMap = args as Map<dynamic, dynamic>?;
    if (argsMap == null) {
      return {'list': [], 'hasNextPage': false, 'error': 'Invalid arguments'};
    }

    final sourceId = argsMap['sourceId'] as String?;
    final query = argsMap['query'] as String?;
    // final page = argsMap['page'] as int? ?? 1; // TODO: Use when DEX execution is implemented

    if (sourceId == null || query == null) {
      return {'list': [], 'hasNextPage': false, 'error': 'Missing parameters'};
    }

    if (!isDexRuntimeAvailable) {
      return {
        'list': [],
        'hasNextPage': false,
        'error': 'DEX runtime not available. Install JRE and dex2jar.',
      };
    }

    // TODO: Implement actual DEX execution
    // For now, return empty results
    return {
      'list': [],
      'hasNextPage': false,
      'error': 'DEX execution not yet implemented',
    };
  }

  /// Handle getPopular request.
  Future<Map<String, dynamic>> _handleGetPopular(dynamic args) async {
    final argsMap = args as Map<dynamic, dynamic>?;
    if (argsMap == null) {
      return {'list': [], 'hasNextPage': false, 'error': 'Invalid arguments'};
    }

    final sourceId = argsMap['sourceId'] as String?;
    // final page = argsMap['page'] as int? ?? 1; // TODO: Use when DEX execution is implemented

    if (sourceId == null) {
      return {'list': [], 'hasNextPage': false, 'error': 'Missing sourceId'};
    }

    if (!isDexRuntimeAvailable) {
      return {
        'list': [],
        'hasNextPage': false,
        'error': 'DEX runtime not available',
      };
    }

    // TODO: Implement actual DEX execution
    return {
      'list': [],
      'hasNextPage': false,
      'error': 'DEX execution not yet implemented',
    };
  }

  /// Handle getLatestUpdates request.
  Future<Map<String, dynamic>> _handleGetLatestUpdates(dynamic args) async {
    final argsMap = args as Map<dynamic, dynamic>?;
    if (argsMap == null) {
      return {'list': [], 'hasNextPage': false, 'error': 'Invalid arguments'};
    }

    final sourceId = argsMap['sourceId'] as String?;
    // final page = argsMap['page'] as int? ?? 1; // TODO: Use when DEX execution is implemented

    if (sourceId == null) {
      return {'list': [], 'hasNextPage': false, 'error': 'Missing sourceId'};
    }

    if (!isDexRuntimeAvailable) {
      return {
        'list': [],
        'hasNextPage': false,
        'error': 'DEX runtime not available',
      };
    }

    // TODO: Implement actual DEX execution
    return {
      'list': [],
      'hasNextPage': false,
      'error': 'DEX execution not yet implemented',
    };
  }

  /// Handle getDetail request.
  Future<Map<String, dynamic>> _handleGetDetail(dynamic args) async {
    final argsMap = args as Map<dynamic, dynamic>?;
    if (argsMap == null) {
      return {'error': 'Invalid arguments'};
    }

    final sourceId = argsMap['sourceId'] as String?;
    final media = argsMap['media'] as Map<dynamic, dynamic>?;

    if (sourceId == null || media == null) {
      return {'error': 'Missing parameters'};
    }

    if (!isDexRuntimeAvailable) {
      return {'error': 'DEX runtime not available'};
    }

    // TODO: Implement actual DEX execution
    return {'error': 'DEX execution not yet implemented'};
  }

  /// Handle getVideoList request.
  Future<List<Map<String, dynamic>>> _handleGetVideoList(dynamic args) async {
    final argsMap = args as Map<dynamic, dynamic>?;
    if (argsMap == null) return [];

    final sourceId = argsMap['sourceId'] as String?;
    final episode = argsMap['episode'] as Map<dynamic, dynamic>?;

    if (sourceId == null || episode == null) return [];

    if (!isDexRuntimeAvailable) {
      debugPrint('DEX runtime not available for getVideoList');
      return [];
    }

    // TODO: Implement actual DEX execution
    return [];
  }

  /// Handle getPageList request.
  Future<List<Map<String, dynamic>>> _handleGetPageList(dynamic args) async {
    final argsMap = args as Map<dynamic, dynamic>?;
    if (argsMap == null) return [];

    final sourceId = argsMap['sourceId'] as String?;
    final episode = argsMap['episode'] as Map<dynamic, dynamic>?;

    if (sourceId == null || episode == null) return [];

    if (!isDexRuntimeAvailable) {
      debugPrint('DEX runtime not available for getPageList');
      return [];
    }

    // TODO: Implement actual DEX execution
    return [];
  }

  /// Handle getPreference request.
  Future<List<Map<String, dynamic>>> _handleGetPreference(dynamic args) async {
    final argsMap = args as Map<dynamic, dynamic>?;
    if (argsMap == null) return [];

    final sourceId = argsMap['sourceId'] as String?;
    if (sourceId == null) return [];

    try {
      final shims = await _getHostShims(sourceId);
      final prefs = shims.sharedPreferences.getAll();

      // Convert to preference format
      return prefs.entries.map((e) {
        final value = e.value;
        String type;
        if (value is bool) {
          type = 'switch';
        } else if (value is List) {
          type = 'multi_select';
        } else {
          type = 'text';
        }

        return {'key': e.key, 'type': type, 'value': value};
      }).toList();
    } catch (e) {
      debugPrint('Error getting preferences: $e');
      return [];
    }
  }

  /// Handle saveSourcePreference request.
  Future<bool> _handleSavePreference(dynamic args) async {
    final argsMap = args as Map<dynamic, dynamic>?;
    if (argsMap == null) return false;

    final sourceId = argsMap['sourceId'] as String?;
    final key = argsMap['key'] as String?;
    final value = argsMap['value'];

    if (sourceId == null || key == null) return false;

    try {
      final shims = await _getHostShims(sourceId);

      if (value is bool) {
        await shims.sharedPreferences.setBool(key, value);
      } else if (value is int) {
        await shims.sharedPreferences.setInt(key, value);
      } else if (value is double) {
        await shims.sharedPreferences.setFloat(key, value);
      } else if (value is String) {
        await shims.sharedPreferences.setString(key, value);
      } else if (value is List) {
        await shims.sharedPreferences.setStringSet(
          key,
          value.map((e) => e.toString()).toSet(),
        );
      }

      await shims.sharedPreferences.save();
      return true;
    } catch (e) {
      debugPrint('Error saving preference: $e');
      return false;
    }
  }

  /// Get capabilities of this bridge.
  Map<String, dynamic> getCapabilities() => {
    'platform': Platform.operatingSystem,
    'isInitialized': _isInitialized,
    'isEnabled': isEnabled,
    'dexRuntimeAvailable': isDexRuntimeAvailable,
    'canExecutePlugins': isDexRuntimeAvailable && isEnabled,
    'pluginCount': _loadedPluginCount,
    'supportsPluginManagement': true,
    'supportsSearch': isDexRuntimeAvailable,
    'supportsPlayback': isDexRuntimeAvailable,
  };
}

/// Global bridge instance.
AniyomiDesktopBridge? _aniyomiDesktopBridge;

/// Get the Aniyomi desktop bridge instance.
AniyomiDesktopBridge getAniyomiDesktopBridge() {
  _aniyomiDesktopBridge ??= AniyomiDesktopBridge();
  return _aniyomiDesktopBridge!;
}

/// Check if Aniyomi desktop is available.
bool get isAniyomiDesktopAvailable =>
    (Platform.isLinux || Platform.isWindows) &&
    aniyomiDesktopConfig.enableDesktopAniyomi;
