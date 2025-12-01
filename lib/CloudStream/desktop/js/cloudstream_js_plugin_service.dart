import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

import '../cloudstream_desktop_config.dart';
import '../cloudstream_desktop_plugin_store.dart';
import '../cloudstream_desktop_telemetry.dart';
import 'cloudstream_js_runtime.dart';

/// Result of a search operation.
class CloudStreamSearchResult {
  final bool hasNextPage;
  final List<CloudStreamSearchItem> items;
  final String? error;

  CloudStreamSearchResult({
    this.hasNextPage = false,
    this.items = const [],
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'hasNextPage': hasNextPage,
    'list': items.map((e) => e.toJson()).toList(),
    if (error != null) 'error': error,
  };
}

/// A search result item.
class CloudStreamSearchItem {
  final String name;
  final String url;
  final String? posterUrl;
  final String? type;

  CloudStreamSearchItem({
    required this.name,
    required this.url,
    this.posterUrl,
    this.type,
  });

  factory CloudStreamSearchItem.fromJson(Map<String, dynamic> json) {
    return CloudStreamSearchItem(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      posterUrl: json['posterUrl'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': name,
    'url': url,
    'thumbnail_url': posterUrl,
    'type': type,
  };
}

/// Detail information for a media item.
class CloudStreamDetailResult {
  final String name;
  final String url;
  final String? posterUrl;
  final String? description;
  final String? type;
  final int? year;
  final double? score;
  final List<String>? tags;
  final String? duration;
  final List<CloudStreamEpisode> episodes;
  final String? error;

  CloudStreamDetailResult({
    required this.name,
    required this.url,
    this.posterUrl,
    this.description,
    this.type,
    this.year,
    this.score,
    this.tags,
    this.duration,
    this.episodes = const [],
    this.error,
  });

  factory CloudStreamDetailResult.fromJson(Map<String, dynamic> json) {
    return CloudStreamDetailResult(
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      posterUrl: json['posterUrl'] as String?,
      description: json['plot'] as String? ?? json['description'] as String?,
      type: json['type'] as String?,
      year: json['year'] as int?,
      score: (json['score'] as num?)?.toDouble(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      duration: json['duration'] as String?,
      episodes:
          (json['episodes'] as List<dynamic>?)
              ?.map(
                (e) => CloudStreamEpisode.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [],
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': name,
    'url': url,
    'thumbnail_url': posterUrl,
    'description': description,
    'type': type,
    'year': year,
    'score': score,
    'tags': tags,
    'duration': duration,
    'episodes': episodes.map((e) => e.toJson()).toList(),
    if (error != null) 'error': error,
  };
}

/// An episode/chapter.
class CloudStreamEpisode {
  final String name;
  final String url;
  final int? episodeNumber;
  final int? season;
  final String? posterUrl;
  final String? description;
  final int? date;

  CloudStreamEpisode({
    required this.name,
    required this.url,
    this.episodeNumber,
    this.season,
    this.posterUrl,
    this.description,
    this.date,
  });

  factory CloudStreamEpisode.fromJson(Map<String, dynamic> json) {
    return CloudStreamEpisode(
      name: json['name'] as String? ?? '',
      url: json['data'] as String? ?? json['url'] as String? ?? '',
      episodeNumber: json['episode'] as int? ?? json['episode_number'] as int?,
      season: json['season'] as int?,
      posterUrl: json['posterUrl'] as String?,
      description: json['description'] as String?,
      date: json['date'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'episode_number': episodeNumber,
    'season': season,
    'thumbnail_url': posterUrl,
    'description': description,
    'date_upload': date,
  };
}

/// Video link result.
class CloudStreamVideoResult {
  final List<CloudStreamVideoLink> videos;
  final List<CloudStreamSubtitle> subtitles;
  final String? error;

  CloudStreamVideoResult({
    this.videos = const [],
    this.subtitles = const [],
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'videos': videos.map((e) => e.toJson()).toList(),
    'subtitles': subtitles.map((e) => e.toJson()).toList(),
    if (error != null) 'error': error,
  };
}

/// A video link.
class CloudStreamVideoLink {
  final String url;
  final String name;
  final String source;
  final String referer;
  final int quality;
  final bool isM3u8;
  final bool isDash;
  final Map<String, String> headers;

  CloudStreamVideoLink({
    required this.url,
    required this.name,
    required this.source,
    this.referer = '',
    this.quality = -1,
    this.isM3u8 = false,
    this.isDash = false,
    this.headers = const {},
  });

  factory CloudStreamVideoLink.fromJson(Map<String, dynamic> json) {
    return CloudStreamVideoLink(
      url: json['url'] as String? ?? '',
      name: json['name'] as String? ?? '',
      source: json['source'] as String? ?? '',
      referer: json['referer'] as String? ?? '',
      quality: json['quality'] as int? ?? -1,
      isM3u8: json['isM3u8'] as bool? ?? false,
      isDash: json['isDash'] as bool? ?? false,
      headers:
          (json['headers'] as Map<dynamic, dynamic>?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'name': name,
    'source': source,
    'referer': referer,
    'quality': quality,
    'isM3u8': isM3u8,
    'isDash': isDash,
    'headers': headers,
  };
}

/// A subtitle file.
class CloudStreamSubtitle {
  final String lang;
  final String url;

  CloudStreamSubtitle({required this.lang, required this.url});

  factory CloudStreamSubtitle.fromJson(Map<String, dynamic> json) {
    return CloudStreamSubtitle(
      lang: json['lang'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'lang': lang, 'url': url};
}

/// Service for executing CloudStream JS plugins.
///
/// This service manages the lifecycle of JS plugin runtimes and provides
/// methods for executing plugin operations (search, load, loadLinks, etc.).
class CloudStreamJsPluginService {
  final CloudStreamDesktopPluginStore _pluginStore;
  final Map<String, CloudStreamJsRuntime> _runtimes = {};
  final Map<String, String> _pluginCodeCache = {};

  CloudStreamJsPluginService(this._pluginStore);

  /// Check if a plugin has JS code that can be executed.
  Future<bool> canExecutePlugin(String pluginId) async {
    final metadata = await _pluginStore.getPlugin(pluginId);
    if (metadata == null) return false;

    final localPath = metadata.localPath;
    if (localPath == null) return false;

    // Check for JS files in the plugin directory
    final pluginDir = Directory(localPath);
    if (!await pluginDir.exists()) return false;

    await for (final entity in pluginDir.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.js')) {
        return true;
      }
    }

    return false;
  }

  /// Get or create a runtime for a plugin.
  Future<CloudStreamJsRuntime?> _getRuntime(String pluginId) async {
    // Return cached runtime if available
    if (_runtimes.containsKey(pluginId)) {
      return _runtimes[pluginId];
    }

    // Load plugin code
    final code = await _loadPluginCode(pluginId);
    if (code == null) {
      debugPrint('No JS code found for plugin: $pluginId');
      return null;
    }

    // Get plugin metadata for config
    final metadata = await _pluginStore.getPlugin(pluginId);
    final config = <String, dynamic>{
      'name': metadata?.displayName ?? pluginId,
      'lang': metadata?.lang ?? 'en',
      'mainUrl': '', // TODO: Extract from manifest
    };

    // Create and initialize runtime
    final runtime = CloudStreamJsRuntime(
      pluginId: pluginId,
      pluginCode: code,
      pluginConfig: config,
    );

    try {
      await runtime.initialize();
      _runtimes[pluginId] = runtime;
      return runtime;
    } catch (e) {
      debugPrint('Failed to initialize runtime for $pluginId: $e');
      runtime.dispose();
      return null;
    }
  }

  /// Load the JS code for a plugin.
  Future<String?> _loadPluginCode(String pluginId) async {
    // Check cache first
    if (_pluginCodeCache.containsKey(pluginId)) {
      return _pluginCodeCache[pluginId];
    }

    final metadata = await _pluginStore.getPlugin(pluginId);
    if (metadata == null) return null;

    final localPath = metadata.localPath;
    if (localPath == null) return null;

    final pluginDir = Directory(localPath);
    if (!await pluginDir.exists()) return null;

    // Find and concatenate all JS files
    final jsFiles = <File>[];
    await for (final entity in pluginDir.list(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.js')) {
        jsFiles.add(entity);
      }
    }

    if (jsFiles.isEmpty) return null;

    // Sort to ensure consistent loading order (main.js first if exists)
    jsFiles.sort((a, b) {
      final aName = path.basename(a.path).toLowerCase();
      final bName = path.basename(b.path).toLowerCase();
      if (aName == 'main.js') return -1;
      if (bName == 'main.js') return 1;
      if (aName == 'index.js') return -1;
      if (bName == 'index.js') return 1;
      return aName.compareTo(bName);
    });

    // Concatenate all JS code
    final buffer = StringBuffer();
    for (final file in jsFiles) {
      try {
        final content = await file.readAsString();
        buffer.writeln('// File: ${path.basename(file.path)}');
        buffer.writeln(content);
        buffer.writeln();
      } catch (e) {
        debugPrint('Error reading JS file ${file.path}: $e');
      }
    }

    final code = buffer.toString();
    if (code.isNotEmpty) {
      _pluginCodeCache[pluginId] = code;
    }

    return code.isEmpty ? null : code;
  }

  /// Search for content using a plugin.
  Future<CloudStreamSearchResult> search(
    String pluginId,
    String query,
    int page,
  ) async {
    final stopwatch = cloudstreamTelemetry.startMethodCall(pluginId, 'search');

    final runtime = await _getRuntime(pluginId);
    if (runtime == null) {
      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'search',
        stopwatch,
        false,
        error: 'Plugin not available or has no JS code',
      );
      return CloudStreamSearchResult(
        error: 'Plugin not available or has no JS code',
      );
    }

    try {
      // Apply timeout from config
      final timeout = Duration(seconds: cloudstreamConfig.jsTimeoutSeconds);
      final result = await runtime
          .callPluginMethod('search', [query, page])
          .timeout(
            timeout,
            onTimeout: () {
              throw TimeoutException(
                'Search timed out after ${timeout.inSeconds}s',
              );
            },
          );

      if (result.containsKey('error')) {
        cloudstreamTelemetry.recordMethodCall(
          pluginId,
          'search',
          stopwatch,
          false,
          error: result['error'] as String?,
        );
        return CloudStreamSearchResult(error: result['error'] as String?);
      }

      final items =
          (result['list'] as List<dynamic>?)
              ?.map(
                (e) => CloudStreamSearchItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [];

      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'search',
        stopwatch,
        true,
        metadata: {'resultCount': items.length, 'query': query, 'page': page},
      );

      return CloudStreamSearchResult(
        hasNextPage: result['hasNext'] as bool? ?? false,
        items: items,
      );
    } catch (e) {
      debugPrint('Search error for $pluginId: $e');
      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'search',
        stopwatch,
        false,
        error: e.toString(),
      );
      return CloudStreamSearchResult(error: e.toString());
    }
  }

  /// Get popular content from a plugin.
  Future<CloudStreamSearchResult> getPopular(String pluginId, int page) async {
    final stopwatch = cloudstreamTelemetry.startMethodCall(
      pluginId,
      'getPopular',
    );

    final runtime = await _getRuntime(pluginId);
    if (runtime == null) {
      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'getPopular',
        stopwatch,
        false,
        error: 'Plugin not available or has no JS code',
      );
      return CloudStreamSearchResult(
        error: 'Plugin not available or has no JS code',
      );
    }

    try {
      final timeout = Duration(seconds: cloudstreamConfig.jsTimeoutSeconds);
      final result = await runtime
          .callPluginMethod('getMainPage', [page, null])
          .timeout(
            timeout,
            onTimeout: () {
              throw TimeoutException(
                'getPopular timed out after ${timeout.inSeconds}s',
              );
            },
          );

      if (result.containsKey('error')) {
        cloudstreamTelemetry.recordMethodCall(
          pluginId,
          'getPopular',
          stopwatch,
          false,
          error: result['error'] as String?,
        );
        return CloudStreamSearchResult(error: result['error'] as String?);
      }

      final items =
          (result['list'] as List<dynamic>?)
              ?.map(
                (e) => CloudStreamSearchItem.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [];

      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'getPopular',
        stopwatch,
        true,
        metadata: {'resultCount': items.length, 'page': page},
      );

      return CloudStreamSearchResult(
        hasNextPage: result['hasNext'] as bool? ?? false,
        items: items,
      );
    } catch (e) {
      debugPrint('GetPopular error for $pluginId: $e');
      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'getPopular',
        stopwatch,
        false,
        error: e.toString(),
      );
      return CloudStreamSearchResult(error: e.toString());
    }
  }

  /// Load detail information for a media item.
  Future<CloudStreamDetailResult> load(String pluginId, String url) async {
    final stopwatch = cloudstreamTelemetry.startMethodCall(pluginId, 'load');

    final runtime = await _getRuntime(pluginId);
    if (runtime == null) {
      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'load',
        stopwatch,
        false,
        error: 'Plugin not available or has no JS code',
      );
      return CloudStreamDetailResult(
        name: '',
        url: url,
        error: 'Plugin not available or has no JS code',
      );
    }

    try {
      final timeout = Duration(seconds: cloudstreamConfig.jsTimeoutSeconds);
      final result = await runtime
          .callPluginMethod('load', [url])
          .timeout(
            timeout,
            onTimeout: () {
              throw TimeoutException(
                'load timed out after ${timeout.inSeconds}s',
              );
            },
          );

      if (result.containsKey('error')) {
        cloudstreamTelemetry.recordMethodCall(
          pluginId,
          'load',
          stopwatch,
          false,
          error: result['error'] as String?,
        );
        return CloudStreamDetailResult(
          name: '',
          url: url,
          error: result['error'] as String?,
        );
      }

      final detail = CloudStreamDetailResult.fromJson(result);
      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'load',
        stopwatch,
        true,
        metadata: {'episodeCount': detail.episodes.length},
      );
      return detail;
    } catch (e) {
      debugPrint('Load error for $pluginId: $e');
      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'load',
        stopwatch,
        false,
        error: e.toString(),
      );
      return CloudStreamDetailResult(name: '', url: url, error: e.toString());
    }
  }

  /// Load video links for an episode.
  Future<CloudStreamVideoResult> loadLinks(
    String pluginId,
    String episodeUrl,
  ) async {
    final stopwatch = cloudstreamTelemetry.startMethodCall(
      pluginId,
      'loadLinks',
    );

    final runtime = await _getRuntime(pluginId);
    if (runtime == null) {
      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'loadLinks',
        stopwatch,
        false,
        error: 'Plugin not available or has no JS code',
      );
      return CloudStreamVideoResult(
        error: 'Plugin not available or has no JS code',
      );
    }

    try {
      final timeout = Duration(seconds: cloudstreamConfig.jsTimeoutSeconds);
      // CloudStream uses callbacks for loadLinks, but we'll adapt to return format
      final result = await runtime
          .callPluginMethod('loadLinks', [episodeUrl, false])
          .timeout(
            timeout,
            onTimeout: () {
              throw TimeoutException(
                'loadLinks timed out after ${timeout.inSeconds}s',
              );
            },
          );

      if (result.containsKey('error')) {
        cloudstreamTelemetry.recordMethodCall(
          pluginId,
          'loadLinks',
          stopwatch,
          false,
          error: result['error'] as String?,
        );
        return CloudStreamVideoResult(error: result['error'] as String?);
      }

      final videos =
          (result['videos'] as List<dynamic>?)
              ?.map(
                (e) => CloudStreamVideoLink.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [];

      final subtitles =
          (result['subtitles'] as List<dynamic>?)
              ?.map(
                (e) => CloudStreamSubtitle.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ),
              )
              .toList() ??
          [];

      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'loadLinks',
        stopwatch,
        true,
        metadata: {
          'videoCount': videos.length,
          'subtitleCount': subtitles.length,
        },
      );

      return CloudStreamVideoResult(videos: videos, subtitles: subtitles);
    } catch (e) {
      debugPrint('LoadLinks error for $pluginId: $e');
      cloudstreamTelemetry.recordMethodCall(
        pluginId,
        'loadLinks',
        stopwatch,
        false,
        error: e.toString(),
      );
      return CloudStreamVideoResult(error: e.toString());
    }
  }

  /// Dispose of a specific plugin's runtime.
  void disposePlugin(String pluginId) {
    final runtime = _runtimes.remove(pluginId);
    runtime?.dispose();
    _pluginCodeCache.remove(pluginId);
  }

  /// Dispose of all runtimes.
  void disposeAll() {
    for (final runtime in _runtimes.values) {
      runtime.dispose();
    }
    _runtimes.clear();
    _pluginCodeCache.clear();
  }

  /// Get the list of plugins with JS execution capability.
  Future<List<String>> getExecutablePlugins() async {
    final plugins = await _pluginStore.listPlugins();
    final executable = <String>[];

    for (final plugin in plugins) {
      if (await canExecutePlugin(plugin.internalName)) {
        executable.add(plugin.internalName);
      }
    }

    return executable;
  }
}
