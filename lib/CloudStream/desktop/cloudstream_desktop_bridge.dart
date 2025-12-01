import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'cloudstream_desktop_bundle_parser.dart';
import 'cloudstream_desktop_config.dart';
import 'cloudstream_desktop_plugin_store.dart';
import 'cloudstream_desktop_telemetry.dart';
import 'dex/dex_plugin_service.dart';
import 'js/cloudstream_js_plugin_service.dart';
import 'js/cloudstream_js_storage.dart';

/// Desktop implementation of the CloudStream extension bridge.
///
/// This class provides a pure Dart implementation of CloudStream plugin management
/// for Linux and Windows platforms. It handles:
/// - Plugin installation (downloading and extracting bundles)
/// - Plugin metadata storage
/// - Plugin listing and status queries
/// - JS plugin execution via QuickJS
/// - DEX plugin execution via dex2jar + JRE (experimental)
///
/// **Capabilities:**
/// - Full plugin management (install, list, uninstall)
/// - JS plugin execution for search, load, loadLinks
/// - DEX plugin execution (requires JRE + dex2jar)
///
/// **Limitations:**
/// - DEX execution requires external tools (JRE, dex2jar)
class CloudStreamDesktopBridge {
  static const String channelName = 'cloudstreamExtensionBridge';

  final CloudStreamDesktopPluginStore _pluginStore;
  final CloudStreamDesktopBundleParser _bundleParser;
  late final CloudStreamJsPluginService _jsPluginService;
  late final DexPluginService _dexPluginService;

  bool _isInitialized = false;
  int _loadedPluginCount = 0;
  int _jsPluginCount = 0;
  int _dexPluginCount = 0;
  final int _extractorCount = 0;

  CloudStreamDesktopBridge()
    : _pluginStore = CloudStreamDesktopPluginStore(),
      _bundleParser = CloudStreamDesktopBundleParser() {
    _jsPluginService = CloudStreamJsPluginService(_pluginStore);
    _dexPluginService = DexPluginService(_pluginStore);
  }

  /// Get JS execution enabled state from config.
  bool get _jsExecutionEnabled => cloudstreamConfig.enableDesktopJsPlugins;

  /// Get DEX execution enabled state from config.
  bool get _dexExecutionEnabled => cloudstreamConfig.enableDesktopDexPlugins;

  /// Initialize the desktop bridge.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _pluginStore.initialize();

      // Count JS-executable plugins
      if (_jsExecutionEnabled) {
        final executablePlugins = await _jsPluginService.getExecutablePlugins();
        _jsPluginCount = executablePlugins.length;
        debugPrint('Found $_jsPluginCount JS-executable plugins');
      }

      // Initialize DEX runtime if enabled
      if (_dexExecutionEnabled) {
        final dexAvailable = await _dexPluginService.initialize();
        if (dexAvailable) {
          final dexPlugins = await _dexPluginService.getExecutablePlugins();
          _dexPluginCount = dexPlugins.length;
          debugPrint('Found $_dexPluginCount DEX-executable plugins');
        } else {
          debugPrint('DEX runtime not available');
        }
      }

      _isInitialized = true;
      debugPrint(
        'CloudStreamDesktopBridge initialized '
        '(JS: $_jsExecutionEnabled, DEX: $_dexExecutionEnabled)',
      );
    } catch (e) {
      debugPrint('Failed to initialize CloudStreamDesktopBridge: $e');
      rethrow;
    }
  }

  /// Enable or disable JS plugin execution.
  void setJsExecutionEnabled(bool enabled) {
    cloudstreamConfig.enableDesktopJsPlugins = enabled;
    if (!enabled) {
      _jsPluginService.disposeAll();
    }
    cloudstreamTelemetry.recordRuntimeInit(
      'js',
      metadata: {'enabled': enabled},
    );
  }

  /// Enable or disable DEX plugin execution (experimental).
  Future<void> setDexExecutionEnabled(bool enabled) async {
    cloudstreamConfig.enableDesktopDexPlugins = enabled;
    if (enabled && !_dexPluginService.isInitialized) {
      await _dexPluginService.initialize();
    } else if (!enabled) {
      await _dexPluginService.shutdown();
    }
    cloudstreamTelemetry.recordRuntimeInit(
      'dex',
      metadata: {'enabled': enabled},
    );
  }

  /// Check if JS execution is enabled.
  bool get isJsExecutionEnabled => _jsExecutionEnabled;

  /// Check if DEX execution is enabled.
  bool get isDexExecutionEnabled => _dexExecutionEnabled;

  /// Check if DEX runtime is available.
  bool get isDexRuntimeAvailable => _dexPluginService.isAvailable;

  /// Get the capabilities of this desktop bridge.
  ///
  /// Returns a map with capability flags that can be used by the UI
  /// to determine what features are available.
  Map<String, dynamic> getCapabilities() => {
    'platform': Platform.operatingSystem,
    'isInitialized': _isInitialized,
    'canExecuteJs': _jsExecutionEnabled,
    'canExecuteDex': _dexExecutionEnabled && isDexRuntimeAvailable,
    'canUseExtractors': false, // Extractors require Android DEX
    'jsPluginCount': _jsPluginCount,
    'dexPluginCount': _dexPluginCount,
    'totalPluginCount': _loadedPluginCount,
  };

  /// Handle a method call from the platform channel.
  Future<dynamic> handleMethodCall(MethodCall call) async {
    debugPrint('CloudStreamDesktopBridge: ${call.method}');

    switch (call.method) {
      case 'initializePlugins':
        return _initializePlugins();

      case 'getPluginStatus':
        return _getPluginStatus();

      case 'getCapabilities':
        return getCapabilities();

      case 'installCloudStreamPlugin':
        return _installCloudStreamPlugin(call.arguments);

      case 'uninstallCloudStreamPlugin':
        return _uninstallCloudStreamPlugin(call.arguments);

      case 'listInstalledCloudStreamPlugins':
        return _listInstalledCloudStreamPlugins();

      case 'getInstalledAnimeExtensions':
        return _getInstalledExtensions(1);
      case 'getInstalledMangaExtensions':
        return _getInstalledExtensions(0);
      case 'getInstalledNovelExtensions':
        return _getInstalledExtensions(2);
      case 'getInstalledMovieExtensions':
        return _getInstalledExtensions(3);
      case 'getInstalledTvShowExtensions':
        return _getInstalledExtensions(4);
      case 'getInstalledCartoonExtensions':
        return _getInstalledExtensions(5);
      case 'getInstalledDocumentaryExtensions':
        return _getInstalledExtensions(6);
      case 'getInstalledLivestreamExtensions':
        return _getInstalledExtensions(7);
      case 'getInstalledNsfwExtensions':
        return _getInstalledExtensions(8);

      case 'cloudstream:reloadPlugins':
        return _reloadPlugins();

      default:
        // Check for cloudstream:* API methods
        if (call.method.startsWith('cloudstream:')) {
          return _handleCloudStreamApiCall(call);
        }
        throw PlatformException(
          code: 'NOT_IMPLEMENTED',
          message: 'Method ${call.method} not implemented on desktop',
        );
    }
  }

  /// Initialize all plugins.
  Future<Map<String, dynamic>> _initializePlugins() async {
    await initialize();

    try {
      final plugins = await _pluginStore.listPlugins();
      _loadedPluginCount = plugins
          .where((p) => p.status == CloudStreamDesktopPluginStatus.installed)
          .length;

      // Count JS-executable plugins
      final executablePlugins = _jsExecutionEnabled
          ? await _jsPluginService.getExecutablePlugins()
          : <String>[];
      _jsPluginCount = executablePlugins.length;

      debugPrint(
        'Desktop: Found $_loadedPluginCount installed plugins, '
        '$_jsPluginCount JS-executable',
      );

      return {
        'success': true,
        'loadedCount': _loadedPluginCount,
        'jsExecutableCount': _jsPluginCount,
        'extractorCount': _extractorCount,
        'platform': Platform.operatingSystem,
        'jsExecutionEnabled': _jsExecutionEnabled,
        'capabilities': {
          'canExecuteJs': _jsExecutionEnabled,
          'canExecuteDex': false,
          'canUseExtractors': false,
        },
      };
    } catch (e) {
      debugPrint('Error initializing plugins: $e');
      return {
        'success': false,
        'error': e.toString(),
        'loadedCount': 0,
        'extractorCount': 0,
      };
    }
  }

  /// Get the current plugin status.
  Future<Map<String, dynamic>> _getPluginStatus() async {
    await initialize();

    final plugins = await _pluginStore.listPlugins();
    final loadedPlugins = <Map<String, dynamic>>[];

    for (final p in plugins) {
      if (p.status != CloudStreamDesktopPluginStatus.installed) continue;

      final canExecute =
          _jsExecutionEnabled &&
          await _jsPluginService.canExecutePlugin(p.internalName);

      loadedPlugins.add({
        'id': p.internalName,
        'name': p.displayName ?? p.internalName,
        'lang': p.lang,
        'version': p.version,
        'canExecute': canExecute,
        'executionType': canExecute ? 'js' : 'none',
      });
    }

    return {
      'isInitialized': _isInitialized,
      'registeredPluginCount': plugins.length,
      'jsExecutableCount': _jsPluginCount,
      'extractorCount': _extractorCount,
      'loadedPlugins': loadedPlugins,
      'platform': Platform.operatingSystem,
      'jsExecutionEnabled': _jsExecutionEnabled,
    };
  }

  /// Install a CloudStream plugin.
  Future<Map<String, dynamic>> _installCloudStreamPlugin(
    dynamic arguments,
  ) async {
    await initialize();

    final args = arguments as Map<Object?, Object?>?;
    if (args == null) {
      throw PlatformException(
        code: 'INVALID_ARGS',
        message: 'Expected metadata map',
      );
    }

    final metadataPayload =
        (args['metadata'] as Map<Object?, Object?>?) ?? args;
    final repoKey = args['repoKey']?.toString();

    // Parse metadata
    final metadataMap = metadataPayload.map(
      (k, v) => MapEntry(k.toString(), v),
    );

    final internalName = metadataMap['internalName']?.toString();
    if (internalName == null || internalName.isEmpty) {
      throw PlatformException(
        code: 'INVALID_METADATA',
        message: 'internalName is required',
      );
    }

    final downloadUrl = metadataMap['downloadUrl']?.toString();
    if (downloadUrl == null || downloadUrl.isEmpty) {
      throw PlatformException(
        code: 'MISSING_URL',
        message: 'Plugin downloadUrl is required',
      );
    }

    try {
      final extension = _inferBundleExtension(downloadUrl);

      // Download the bundle
      final bundlePath = await _pluginStore.resolveBundlePath(
        repoKey,
        internalName,
        extension: extension,
      );
      await _bundleParser.downloadBundle(downloadUrl, bundlePath);

      // Extract the bundle
      final pluginDir = await _pluginStore.resolvePluginDirectory(
        repoKey,
        internalName,
      );
      final extractResult = await _bundleParser.extractBundle(
        bundlePath,
        pluginDir,
      );

      // Parse tvTypes from manifest or metadata
      final manifestTvTypes = extractResult.manifest?.tvTypes ?? [];
      final metadataTvTypes =
          (metadataMap['tvTypes'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
      final resolvedTvTypes = manifestTvTypes.isNotEmpty
          ? manifestTvTypes
          : metadataTvTypes;

      // Parse itemTypes
      final metadataItemTypes =
          (metadataMap['itemTypes'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          [];
      final resolvedItemTypes = _resolveItemTypes(
        metadataItemTypes,
        resolvedTvTypes,
      );

      // Create and save metadata
      final metadata = CloudStreamDesktopPluginMetadata(
        internalName: internalName,
        displayName:
            metadataMap['name']?.toString() ??
            extractResult.manifest?.name ??
            internalName,
        repoUrl: repoKey,
        pluginListUrl: metadataMap['pluginListUrl']?.toString(),
        downloadUrl: downloadUrl,
        version:
            extractResult.manifest?.version?.toString() ??
            metadataMap['version']?.toString(),
        tvTypes: resolvedTvTypes,
        lang:
            metadataMap['lang']?.toString() ?? extractResult.manifest?.language,
        isNsfw: metadataMap['isNsfw'] as bool? ?? false,
        itemTypes: resolvedItemTypes,
        localPath: pluginDir.path,
        iconUrl:
            metadataMap['iconUrl']?.toString() ??
            extractResult.manifest?.iconUrl,
        hasJsCode: extractResult.isJsPlugin,
        hasDexCode: extractResult.isDexPlugin,
      );

      final saved = await _pluginStore.upsertPlugin(metadata);

      debugPrint('Installed plugin: $internalName (desktop)');

      return {
        ...saved.toMetadataPayload(),
        'loaded': false, // Desktop cannot execute plugins
        'canExecute': extractResult.isJsPlugin,
        'isDexPlugin': extractResult.isDexPlugin,
        'isJsPlugin': extractResult.isJsPlugin,
      };
    } catch (e) {
      debugPrint('Failed to install plugin $internalName: $e');
      throw PlatformException(code: 'INSTALL_FAILED', message: e.toString());
    }
  }

  String _inferBundleExtension(String url) {
    final uri = Uri.tryParse(url);
    final pathLower = uri?.path.toLowerCase() ?? '';

    if (pathLower.endsWith('.zip')) {
      return 'zip';
    }

    if (pathLower.endsWith('.cs3') ||
        pathLower.endsWith('.cs') ||
        pathLower.endsWith('.csplugin')) {
      return 'cs3';
    }

    if (pathLower.endsWith('.apk')) {
      throw PlatformException(
        code: 'UNSUPPORTED_BUNDLE',
        message:
            'APK-based CloudStream plugins can only be installed on Android.',
      );
    }

    final formatParam = uri?.queryParameters['format']?.toLowerCase();
    if (formatParam != null && (formatParam == 'zip' || formatParam == 'cs3')) {
      return formatParam;
    }

    debugPrint(
      'Unable to determine plugin bundle extension for $url, defaulting to cs3',
    );
    return 'cs3';
  }

  /// Uninstall a CloudStream plugin.
  Future<bool> _uninstallCloudStreamPlugin(dynamic arguments) async {
    await initialize();

    final args = arguments as Map<Object?, Object?>?;
    if (args == null) {
      throw PlatformException(
        code: 'INVALID_ARGS',
        message: 'Expected map with internalName',
      );
    }

    final internalName = (args['internalName'] ?? args['sourceId'])?.toString();
    if (internalName == null || internalName.isEmpty) {
      throw PlatformException(
        code: 'MISSING_ID',
        message: 'internalName/sourceId is required',
      );
    }

    try {
      final removed = await _pluginStore.removePlugin(internalName);
      debugPrint('Uninstalled plugin: $internalName (removed: $removed)');
      return removed;
    } catch (e) {
      debugPrint('Failed to uninstall plugin $internalName: $e');
      throw PlatformException(code: 'UNINSTALL_FAILED', message: e.toString());
    }
  }

  /// List all installed CloudStream plugins.
  Future<List<Map<String, dynamic>>> _listInstalledCloudStreamPlugins() async {
    await initialize();

    try {
      final plugins = await _pluginStore.listPlugins();
      return plugins.map((p) => p.toMetadataPayload()).toList();
    } catch (e) {
      debugPrint('Failed to list plugins: $e');
      return [];
    }
  }

  /// Get installed extensions for a specific item type.
  Future<List<Map<String, dynamic>>> _getInstalledExtensions(
    int itemType,
  ) async {
    await initialize();

    try {
      final plugins = await _pluginStore.listPlugins();
      final results = <Map<String, dynamic>>[];

      for (final p in plugins) {
        if (p.status != CloudStreamDesktopPluginStatus.installed) continue;
        if (!p.matchesItemType(itemType)) continue;

        // Check if plugin can be executed (has JS code)
        final canExecute =
            _jsExecutionEnabled &&
            await _jsPluginService.canExecutePlugin(p.internalName);

        final payload = p.toInstalledSourcePayload(itemType);
        payload['isExecutableOnDesktop'] = canExecute;
        results.add(payload);
      }

      return results;
    } catch (e) {
      debugPrint('Failed to get installed extensions for type $itemType: $e');
      return [];
    }
  }

  /// Reload all plugins.
  Future<Map<String, dynamic>> _reloadPlugins() async {
    await initialize();

    final plugins = await _pluginStore.listPlugins();
    _loadedPluginCount = plugins
        .where((p) => p.status == CloudStreamDesktopPluginStatus.installed)
        .length;

    return {'success': true, 'reloadedCount': _loadedPluginCount};
  }

  /// Handle CloudStream API calls (search, load, etc.).
  ///
  /// On desktop, JS plugins can be executed via QuickJS.
  /// DEX plugins will return errors as they cannot be executed.
  Future<dynamic> _handleCloudStreamApiCall(MethodCall call) async {
    final method = call.method.replaceFirst('cloudstream:', '');
    final args = call.arguments as Map<Object?, Object?>?;

    debugPrint('CloudStream API call (desktop): $method');

    // Extract common parameters
    final sourceId = args?['sourceId']?.toString();

    switch (method) {
      case 'search':
        return _handleSearch(args, sourceId);

      case 'getPopular':
        return _handleGetPopular(args, sourceId);

      case 'getLatestUpdates':
        return _handleGetLatestUpdates(args, sourceId);

      case 'getDetail':
        return _handleGetDetail(args, sourceId);

      case 'getVideoList':
        return _handleGetVideoList(args, sourceId);

      case 'loadLinks':
        return _handleLoadLinks(args, sourceId);

      case 'getLoadedPlugins':
        return _handleGetLoadedPlugins();

      case 'getPageList':
        return _handleGetPageList(args, sourceId);

      case 'getNovelContent':
        return _handleGetNovelContent(args, sourceId);

      case 'getPreference':
        return _handleGetPreference(args, sourceId);

      case 'setPreference':
        return _handleSetPreference(args, sourceId);

      case 'extract':
      case 'extractWithExtractor':
      case 'listExtractors':
        // Extractor functionality requires DEX - not supported on desktop
        return {
          'success': false,
          'error': 'Extractors require DEX execution (Android-only)',
          'links': <Map<String, dynamic>>[],
          'subtitles': <Map<String, dynamic>>[],
        };

      default:
        throw PlatformException(
          code: 'NOT_IMPLEMENTED',
          message: 'CloudStream API method $method not implemented on desktop',
        );
    }
  }

  /// Handle search API call.
  Future<Map<String, dynamic>> _handleSearch(
    Map<Object?, Object?>? args,
    String? sourceId,
  ) async {
    if (sourceId == null || sourceId.isEmpty) {
      return {'success': false, 'error': 'sourceId is required', 'list': []};
    }

    final query = args?['query']?.toString() ?? '';
    final page = (args?['page'] as num?)?.toInt() ?? 1;
    final stopwatch = cloudstreamTelemetry.startMethodCall(sourceId, 'search');

    if (!_jsExecutionEnabled) {
      cloudstreamTelemetry.recordMethodCall(
        sourceId,
        'search',
        stopwatch,
        false,
        error: 'JS execution is disabled',
      );
      return {
        'success': false,
        'error': 'JS execution is disabled',
        'list': [],
      };
    }

    // Check if plugin can be executed
    if (!await _jsPluginService.canExecutePlugin(sourceId)) {
      cloudstreamTelemetry.recordMethodCall(
        sourceId,
        'search',
        stopwatch,
        false,
        error: 'No JS code available',
      );
      return {
        'success': false,
        'error':
            'Plugin $sourceId has no JS code (DEX-only plugins not supported)',
        'list': [],
      };
    }

    final result = await _jsPluginService.search(sourceId, query, page);
    cloudstreamTelemetry.recordMethodCall(
      sourceId,
      'search',
      stopwatch,
      result.error == null,
      error: result.error,
      metadata: {
        'query': query,
        'page': page,
        'resultCount': result.items.length,
      },
    );

    return {
      'success': result.error == null,
      'hasNextPage': result.hasNextPage,
      'list': result.items.map((e) => e.toJson()).toList(),
      if (result.error != null) 'error': result.error,
    };
  }

  /// Handle getPopular API call.
  Future<Map<String, dynamic>> _handleGetPopular(
    Map<Object?, Object?>? args,
    String? sourceId,
  ) async {
    if (sourceId == null || sourceId.isEmpty) {
      return {'success': false, 'error': 'sourceId is required', 'list': []};
    }

    final page = (args?['page'] as num?)?.toInt() ?? 1;

    if (!_jsExecutionEnabled) {
      return {
        'success': false,
        'error': 'JS execution is disabled',
        'list': [],
      };
    }

    if (!await _jsPluginService.canExecutePlugin(sourceId)) {
      return {
        'success': false,
        'error': 'Plugin $sourceId has no JS code',
        'list': [],
      };
    }

    final result = await _jsPluginService.getPopular(sourceId, page);
    return {
      'success': result.error == null,
      'hasNextPage': result.hasNextPage,
      'list': result.items.map((e) => e.toJson()).toList(),
      if (result.error != null) 'error': result.error,
    };
  }

  /// Handle getLatestUpdates API call.
  Future<Map<String, dynamic>> _handleGetLatestUpdates(
    Map<Object?, Object?>? args,
    String? sourceId,
  ) async {
    // For now, use getPopular as fallback
    return _handleGetPopular(args, sourceId);
  }

  /// Handle getDetail API call.
  Future<Map<String, dynamic>> _handleGetDetail(
    Map<Object?, Object?>? args,
    String? sourceId,
  ) async {
    if (sourceId == null || sourceId.isEmpty) {
      return {'success': false, 'error': 'sourceId is required'};
    }

    final mediaMap = args?['media'] as Map<Object?, Object?>?;
    final url = mediaMap?['url']?.toString();

    if (url == null || url.isEmpty) {
      return {'success': false, 'error': 'media.url is required'};
    }

    if (!_jsExecutionEnabled) {
      return {'success': false, 'error': 'JS execution is disabled'};
    }

    if (!await _jsPluginService.canExecutePlugin(sourceId)) {
      return {'success': false, 'error': 'Plugin $sourceId has no JS code'};
    }

    final result = await _jsPluginService.load(sourceId, url);
    return {'success': result.error == null, ...result.toJson()};
  }

  /// Handle getVideoList API call.
  Future<Map<String, dynamic>> _handleGetVideoList(
    Map<Object?, Object?>? args,
    String? sourceId,
  ) async {
    return _handleLoadLinks(args, sourceId);
  }

  /// Handle loadLinks API call.
  Future<Map<String, dynamic>> _handleLoadLinks(
    Map<Object?, Object?>? args,
    String? sourceId,
  ) async {
    if (sourceId == null || sourceId.isEmpty) {
      return {
        'success': false,
        'error': 'sourceId is required',
        'videos': [],
        'subtitles': [],
      };
    }

    final episodeMap = args?['episode'] as Map<Object?, Object?>?;
    final episodeUrl = episodeMap?['url']?.toString();

    if (episodeUrl == null || episodeUrl.isEmpty) {
      return {
        'success': false,
        'error': 'episode.url is required',
        'videos': [],
        'subtitles': [],
      };
    }

    if (!_jsExecutionEnabled) {
      return {
        'success': false,
        'error': 'JS execution is disabled',
        'videos': [],
        'subtitles': [],
      };
    }

    if (!await _jsPluginService.canExecutePlugin(sourceId)) {
      return {
        'success': false,
        'error': 'Plugin $sourceId has no JS code',
        'videos': [],
        'subtitles': [],
      };
    }

    final result = await _jsPluginService.loadLinks(sourceId, episodeUrl);
    return {
      'success': result.error == null,
      'videos': result.videos.map((e) => e.toJson()).toList(),
      'subtitles': result.subtitles.map((e) => e.toJson()).toList(),
      if (result.error != null) 'error': result.error,
    };
  }

  /// Handle getPageList API call (for manga/novel).
  Future<Map<String, dynamic>> _handleGetPageList(
    Map<Object?, Object?>? args,
    String? sourceId,
  ) async {
    if (sourceId == null || sourceId.isEmpty) {
      return {'success': false, 'error': 'sourceId is required', 'pages': []};
    }

    final episodeMap = args?['episode'] as Map<Object?, Object?>?;
    final episodeUrl = episodeMap?['url']?.toString();

    if (episodeUrl == null || episodeUrl.isEmpty) {
      return {
        'success': false,
        'error': 'episode.url is required',
        'pages': [],
      };
    }

    if (!_jsExecutionEnabled) {
      return {
        'success': false,
        'error': 'JS execution is disabled',
        'pages': [],
      };
    }

    if (!await _jsPluginService.canExecutePlugin(sourceId)) {
      return {
        'success': false,
        'error': 'Plugin $sourceId has no JS code',
        'pages': [],
      };
    }

    // TODO: Implement getPageList in JS plugin service
    return {
      'success': false,
      'error': 'getPageList not yet implemented for JS plugins',
      'pages': [],
    };
  }

  /// Handle getNovelContent API call.
  Future<String?> _handleGetNovelContent(
    Map<Object?, Object?>? args,
    String? sourceId,
  ) async {
    if (sourceId == null || sourceId.isEmpty) {
      return null;
    }

    final chapterId = args?['chapterId']?.toString();
    if (chapterId == null || chapterId.isEmpty) {
      return null;
    }

    if (!_jsExecutionEnabled) {
      return null;
    }

    if (!await _jsPluginService.canExecutePlugin(sourceId)) {
      return null;
    }

    // TODO: Implement getNovelContent in JS plugin service
    return null;
  }

  /// Handle getPreference API call.
  Future<List<Map<String, dynamic>>> _handleGetPreference(
    Map<Object?, Object?>? args,
    String? sourceId,
  ) async {
    if (sourceId == null || sourceId.isEmpty) {
      return [];
    }

    // Get all preferences for this plugin from storage
    try {
      final allPrefs = await cloudstreamJsStorage.getAll(sourceId);
      return allPrefs.entries
          .map((e) => {'key': e.key, 'value': e.value})
          .toList();
    } catch (e) {
      debugPrint('Failed to get preferences for $sourceId: $e');
      return [];
    }
  }

  /// Handle setPreference API call.
  Future<bool> _handleSetPreference(
    Map<Object?, Object?>? args,
    String? sourceId,
  ) async {
    if (sourceId == null || sourceId.isEmpty) {
      return false;
    }

    final key = args?['key']?.toString();
    if (key == null || key.isEmpty) {
      return false;
    }

    final value = args?['value'];

    try {
      await cloudstreamJsStorage.set(sourceId, key, value);
      return true;
    } catch (e) {
      debugPrint('Failed to set preference $key for $sourceId: $e');
      return false;
    }
  }

  /// Handle getLoadedPlugins API call.
  Future<List<Map<String, dynamic>>> _handleGetLoadedPlugins() async {
    await initialize();

    final plugins = await _pluginStore.listPlugins();
    final result = <Map<String, dynamic>>[];

    for (final plugin in plugins) {
      if (plugin.status != CloudStreamDesktopPluginStatus.installed) continue;

      final canExecute =
          _jsExecutionEnabled &&
          await _jsPluginService.canExecutePlugin(plugin.internalName);

      result.add({
        'id': plugin.internalName,
        'name': plugin.displayName ?? plugin.internalName,
        'lang': plugin.lang,
        'version': plugin.version,
        'canExecute': canExecute,
        'executionType': canExecute ? 'js' : 'none',
      });
    }

    return result;
  }

  /// Resolve item types from metadata and tvTypes.
  List<int> _resolveItemTypes(
    List<int> metadataItemTypes,
    List<String> tvTypes,
  ) {
    if (metadataItemTypes.isNotEmpty) {
      return metadataItemTypes;
    }

    // Map tvTypes to item type indices
    final itemTypes = <int>{};

    for (final tvType in tvTypes) {
      final lower = tvType.toLowerCase();

      if (['anime', 'animemovie', 'ova'].contains(lower)) {
        itemTypes.add(1); // anime
      }
      if (['manga'].contains(lower)) {
        itemTypes.add(0); // manga
      }
      if (['audiobook', 'audio', 'podcast'].contains(lower)) {
        itemTypes.add(2); // novel
      }
      if (['movie', 'animemovie', 'torrent'].contains(lower)) {
        itemTypes.add(3); // movie
      }
      if (['tvseries', 'asiandrama'].contains(lower)) {
        itemTypes.add(4); // tvShow
      }
      if (['cartoon'].contains(lower)) {
        itemTypes.add(5); // cartoon
      }
      if (['documentary'].contains(lower)) {
        itemTypes.add(6); // documentary
      }
      if (['live'].contains(lower)) {
        itemTypes.add(7); // livestream
      }
      if (['nsfw'].contains(lower)) {
        itemTypes.add(8); // nsfw
      }
    }

    return itemTypes.toList();
  }
}

/// Singleton instance of the desktop bridge.
CloudStreamDesktopBridge? _desktopBridgeInstance;

/// Get or create the desktop bridge instance.
CloudStreamDesktopBridge getDesktopBridge() {
  _desktopBridgeInstance ??= CloudStreamDesktopBridge();
  return _desktopBridgeInstance!;
}

/// Set up the desktop platform channel handler.
void setupDesktopCloudStreamChannel() {
  if (!Platform.isLinux && !Platform.isWindows) {
    return;
  }

  const channel = MethodChannel(CloudStreamDesktopBridge.channelName);
  final bridge = getDesktopBridge();

  channel.setMethodCallHandler((call) async {
    try {
      return await bridge.handleMethodCall(call);
    } on PlatformException {
      rethrow;
    } catch (e) {
      throw PlatformException(code: 'UNKNOWN_ERROR', message: e.toString());
    }
  });

  debugPrint('Desktop CloudStream channel handler registered');
}
