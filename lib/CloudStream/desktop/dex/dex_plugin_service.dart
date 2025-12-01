import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../cloudstream_desktop_plugin_store.dart';
import 'dex_runtime_interface.dart';
import 'host_api_shims.dart';
import 'jre_dex_runtime.dart';

/// Service for executing CloudStream DEX plugins on desktop.
///
/// This service manages the DEX runtime lifecycle and provides methods
/// for executing plugin operations (search, load, loadLinks, etc.).
class DexPluginService {
  final CloudStreamDesktopPluginStore _pluginStore;

  DexRuntime? _runtime;
  DexRuntimeConfig _config = const DexRuntimeConfig();
  final Map<String, HostApiShims> _hostShims = {};

  bool _isInitialized = false;
  bool _isAvailable = false;

  DexPluginService(this._pluginStore);

  /// Check if DEX execution is available on this system.
  bool get isAvailable => _isAvailable;

  /// Check if the service is initialized.
  bool get isInitialized => _isInitialized;

  /// Get the current DEX runtime type.
  DexRuntimeType get dexRuntimeType => _runtime?.type ?? DexRuntimeType.none;

  /// Initialize the DEX plugin service.
  Future<bool> initialize({DexRuntimeConfig? config}) async {
    if (_isInitialized) return _isAvailable;

    if (config != null) {
      _config = config;
    }

    try {
      // Detect available runtime
      final availableType = await DexRuntimeFactory.detectAvailableRuntime();

      if (availableType == DexRuntimeType.none) {
        debugPrint('No DEX runtime available');
        _isInitialized = true;
        _isAvailable = false;
        return false;
      }

      // Create runtime based on type
      _runtime = _createRuntime(availableType);

      // Initialize runtime
      final result = await _runtime!.initialize(_config);

      if (!result.success) {
        debugPrint('DEX runtime initialization failed: ${result.error}');
        _runtime = null;
        _isInitialized = true;
        _isAvailable = false;
        return false;
      }

      _isInitialized = true;
      _isAvailable = true;
      debugPrint('DEX plugin service initialized with ${availableType.name}');
      return true;
    } catch (e) {
      debugPrint('DEX plugin service initialization error: $e');
      _isInitialized = true;
      _isAvailable = false;
      return false;
    }
  }

  /// Create a runtime instance based on type.
  DexRuntime _createRuntime(DexRuntimeType type) {
    switch (type) {
      case DexRuntimeType.dex2jarJre:
        return JreDexRuntime();
      case DexRuntimeType.graalvm:
        // TODO: Implement GraalVM runtime
        throw UnimplementedError('GraalVM runtime not yet implemented');
      case DexRuntimeType.embeddedDalvik:
        // TODO: Implement embedded Dalvik
        throw UnimplementedError('Embedded Dalvik not yet implemented');
      case DexRuntimeType.none:
        throw StateError('Cannot create runtime for type: none');
    }
  }

  /// Get runtime status and diagnostics.
  Future<DexRuntimeStatus> getStatus() async {
    if (_runtime == null) {
      return DexRuntimeStatus(
        isAvailable: false,
        type: DexRuntimeType.none,
        diagnostics: {'error': 'Runtime not initialized'},
      );
    }
    return _runtime!.getStatus();
  }

  /// Check if a plugin has DEX code that can be executed.
  Future<bool> canExecutePlugin(String pluginId) async {
    if (!_isAvailable) return false;

    final metadata = await _pluginStore.getPlugin(pluginId);
    if (metadata == null) return false;

    final localPath = metadata.localPath;
    if (localPath == null) return false;

    // Check for DEX file in plugin directory
    final pluginDir = Directory(localPath);
    if (!await pluginDir.exists()) return false;

    await for (final entity in pluginDir.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.dex')) {
        return true;
      }
    }

    return false;
  }

  /// Load a plugin for execution.
  Future<bool> loadPlugin(String pluginId) async {
    if (!_isAvailable || _runtime == null) {
      debugPrint('Cannot load plugin: DEX runtime not available');
      return false;
    }

    if (_runtime!.isPluginLoaded(pluginId)) {
      return true;
    }

    final metadata = await _pluginStore.getPlugin(pluginId);
    if (metadata == null) {
      debugPrint('Plugin not found: $pluginId');
      return false;
    }

    final localPath = metadata.localPath;
    if (localPath == null) {
      debugPrint('Plugin has no local path: $pluginId');
      return false;
    }

    // Find DEX file
    final dexPath = await _findDexFile(localPath);
    if (dexPath == null) {
      debugPrint('No DEX file found for plugin: $pluginId');
      return false;
    }

    // Find plugin class name from manifest
    final className = await _findPluginClassName(localPath);
    if (className == null) {
      debugPrint('Could not determine plugin class name: $pluginId');
      return false;
    }

    // Initialize host API shims for this plugin
    final shims = HostApiShims(pluginId);
    await shims.initialize();
    _hostShims[pluginId] = shims;

    // Load plugin
    final result = await _runtime!.loadPlugin(
      dexPath: dexPath,
      pluginClassName: className,
      pluginId: pluginId,
    );

    if (!result.success) {
      debugPrint('Failed to load plugin $pluginId: ${result.error}');
      _hostShims.remove(pluginId)?.dispose();
      return false;
    }

    debugPrint('Plugin loaded: $pluginId');
    return true;
  }

  /// Unload a plugin.
  Future<void> unloadPlugin(String pluginId) async {
    if (_runtime != null) {
      await _runtime!.unloadPlugin(pluginId);
    }

    final shims = _hostShims.remove(pluginId);
    await shims?.dispose();
  }

  /// Search for content using a plugin.
  Future<DexSearchResult> search(
    String pluginId,
    String query,
    int page,
  ) async {
    if (!await _ensurePluginLoaded(pluginId)) {
      return DexSearchResult(error: 'Plugin not available');
    }

    final result = await _runtime!.callMethod(
      pluginId: pluginId,
      methodName: 'search',
      args: [query, page],
    );

    if (!result.success) {
      return DexSearchResult(error: result.error);
    }

    return DexSearchResult.fromJson(result.data!);
  }

  /// Get popular content from a plugin.
  Future<DexSearchResult> getPopular(String pluginId, int page) async {
    if (!await _ensurePluginLoaded(pluginId)) {
      return DexSearchResult(error: 'Plugin not available');
    }

    final result = await _runtime!.callMethod(
      pluginId: pluginId,
      methodName: 'getMainPage',
      args: [page, null],
    );

    if (!result.success) {
      return DexSearchResult(error: result.error);
    }

    return DexSearchResult.fromJson(result.data!);
  }

  /// Load detail information for a media item.
  Future<DexDetailResult> load(String pluginId, String url) async {
    if (!await _ensurePluginLoaded(pluginId)) {
      return DexDetailResult(error: 'Plugin not available');
    }

    final result = await _runtime!.callMethod(
      pluginId: pluginId,
      methodName: 'load',
      args: [url],
    );

    if (!result.success) {
      return DexDetailResult(error: result.error);
    }

    return DexDetailResult.fromJson(result.data!);
  }

  /// Load video links for an episode.
  Future<DexVideoResult> loadLinks(String pluginId, String episodeUrl) async {
    if (!await _ensurePluginLoaded(pluginId)) {
      return DexVideoResult(error: 'Plugin not available');
    }

    final result = await _runtime!.callMethod(
      pluginId: pluginId,
      methodName: 'loadLinks',
      args: [episodeUrl, false],
    );

    if (!result.success) {
      return DexVideoResult(error: result.error);
    }

    return DexVideoResult.fromJson(result.data!);
  }

  /// Ensure a plugin is loaded before calling methods.
  Future<bool> _ensurePluginLoaded(String pluginId) async {
    if (!_isAvailable || _runtime == null) return false;

    if (_runtime!.isPluginLoaded(pluginId)) return true;

    return loadPlugin(pluginId);
  }

  /// Find DEX file in plugin directory.
  Future<String?> _findDexFile(String pluginDir) async {
    final dir = Directory(pluginDir);
    if (!await dir.exists()) return null;

    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        final name = path.basename(entity.path).toLowerCase();
        if (name == 'classes.dex' || name.endsWith('.dex')) {
          return entity.path;
        }
      }
    }

    return null;
  }

  /// Find plugin class name from manifest.
  Future<String?> _findPluginClassName(String pluginDir) async {
    final manifestFile = File(path.join(pluginDir, 'manifest.json'));
    if (!await manifestFile.exists()) {
      // Try to find it recursively
      final dir = Directory(pluginDir);
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File && path.basename(entity.path) == 'manifest.json') {
          return _parseManifestClassName(entity.path);
        }
      }
      return null;
    }
    return _parseManifestClassName(manifestFile.path);
  }

  /// Parse plugin class name from manifest file.
  Future<String?> _parseManifestClassName(String manifestPath) async {
    try {
      final file = File(manifestPath);
      final content = await file.readAsString();
      // Simple JSON parsing - look for pluginClassName field
      final match = RegExp(
        r'"pluginClassName"\s*:\s*"([^"]+)"',
      ).firstMatch(content);
      return match?.group(1);
    } catch (e) {
      debugPrint('Error parsing manifest: $e');
      return null;
    }
  }

  /// Get list of plugins with DEX execution capability.
  Future<List<String>> getExecutablePlugins() async {
    if (!_isAvailable) return [];

    final plugins = await _pluginStore.listPlugins();
    final executable = <String>[];

    for (final plugin in plugins) {
      if (await canExecutePlugin(plugin.internalName)) {
        executable.add(plugin.internalName);
      }
    }

    return executable;
  }

  /// Shutdown the service and release resources.
  Future<void> shutdown() async {
    // Dispose all host shims
    for (final shims in _hostShims.values) {
      await shims.dispose();
    }
    _hostShims.clear();

    // Shutdown runtime
    if (_runtime != null) {
      await _runtime!.shutdown();
      _runtime = null;
    }

    _isInitialized = false;
    _isAvailable = false;
  }
}

/// Result of a DEX search operation.
class DexSearchResult {
  final bool hasNextPage;
  final List<Map<String, dynamic>> items;
  final String? error;

  DexSearchResult({
    this.hasNextPage = false,
    this.items = const [],
    this.error,
  });

  factory DexSearchResult.fromJson(Map<String, dynamic> json) {
    return DexSearchResult(
      hasNextPage:
          json['hasNextPage'] as bool? ?? json['hasNext'] as bool? ?? false,
      items:
          (json['list'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'hasNextPage': hasNextPage,
    'list': items,
    if (error != null) 'error': error,
  };
}

/// Result of a DEX detail load operation.
class DexDetailResult {
  final Map<String, dynamic>? data;
  final String? error;

  DexDetailResult({this.data, this.error});

  factory DexDetailResult.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('error')) {
      return DexDetailResult(error: json['error'] as String?);
    }
    return DexDetailResult(data: json);
  }

  Map<String, dynamic> toJson() => data ?? {'error': error};
}

/// Result of a DEX video links operation.
class DexVideoResult {
  final List<Map<String, dynamic>> videos;
  final List<Map<String, dynamic>> subtitles;
  final String? error;

  DexVideoResult({
    this.videos = const [],
    this.subtitles = const [],
    this.error,
  });

  factory DexVideoResult.fromJson(Map<String, dynamic> json) {
    return DexVideoResult(
      videos:
          (json['videos'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      subtitles:
          (json['subtitles'] as List<dynamic>?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'videos': videos,
    'subtitles': subtitles,
    if (error != null) 'error': error,
  };
}
