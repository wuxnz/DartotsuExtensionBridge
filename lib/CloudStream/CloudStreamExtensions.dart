import 'dart:convert';
import 'dart:io';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:http/http.dart' as http;
import 'package:install_plugin/install_plugin.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

const _megaProviderInternalName = 'megaprovider';
const _megaRepoListUrl =
    'https://raw.githubusercontent.com/recloudstream/cs-repos/master/repos-db.json';

class CloudStreamExtensionGroup {
  CloudStreamExtensionGroup({
    required this.id,
    required this.name,
    required this.itemType,
    required this.repoUrl,
    required this.pluginListUrl,
    this.repoName,
    required this.pluginCount,
  });

  final String id;
  final String name;
  final ItemType itemType;
  final String repoUrl;
  final String pluginListUrl;
  final String? repoName;
  final int pluginCount;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'itemType': itemType.index,
    'repoUrl': repoUrl,
    'pluginListUrl': pluginListUrl,
    'repoName': repoName,
    'pluginCount': pluginCount,
  };
}

class _PluginListEntry {
  const _PluginListEntry({required this.url, this.displayName});

  final String url;
  final String? displayName;
}

class CloudStreamGroupInstallResult {
  CloudStreamGroupInstallResult({
    required this.group,
    required this.installed,
    required this.failures,
  });

  final CloudStreamExtensionGroup group;
  final List<String> installed;
  final Map<String, String> failures;

  bool get isSuccess => failures.isEmpty;
}

class CloudStreamExtensions extends Extension {
  CloudStreamExtensions() {
    initialize();
  }

  static const platform = MethodChannel('cloudstreamExtensionBridge');

  final Rx<List<Source>> availableAnimeExtensionsUnmodified = Rx([]);
  final Rx<List<Source>> availableMangaExtensionsUnmodified = Rx([]);
  final Rx<List<Source>> availableNovelExtensionsUnmodified = Rx([]);
  final Rx<List<Source>> availableMovieExtensionsUnmodified = Rx([]);
  final Rx<List<Source>> availableTvShowExtensionsUnmodified = Rx([]);
  final Rx<List<Source>> availableCartoonExtensionsUnmodified = Rx([]);
  final Rx<List<Source>> availableDocumentaryExtensionsUnmodified = Rx([]);
  final Rx<List<Source>> availableLivestreamExtensionsUnmodified = Rx([]);
  final Rx<List<Source>> availableNsfwExtensionsUnmodified = Rx([]);

  /// Plugin status from native layer
  final Rx<Map<String, dynamic>> pluginStatus = Rx({});

  /// Loading state for UI feedback
  final Rx<bool> isLoading = Rx(false);

  /// Error state for UI feedback
  final Rx<String?> lastError = Rx(null);

  final Map<ItemType, Rx<List<CloudStreamExtensionGroup>>> _availableGroups = {
    for (final type in ItemType.values) type: Rx(<CloudStreamExtensionGroup>[]),
  };

  final Map<String, List<Source>> _groupSources = {};
  List<String>? _cachedMegaRepoUrls;

  @override
  bool get supportsAnime => true;

  @override
  bool get supportsManga => true;

  @override
  bool get supportsNovel => true;

  @override
  bool get supportsMovie => true;

  @override
  bool get supportsTvShow => true;

  @override
  bool get supportsCartoon => true;

  @override
  bool get supportsDocumentary => true;

  @override
  bool get supportsLivestream => true;

  @override
  bool get supportsNsfw => true;

  @override
  Future<void> initialize() async {
    if (isInitialized.value) return;

    try {
      // Initialize native plugin registry first
      await initializePlugins();

      // Refresh plugin status for UI
      await refreshPluginStatus();

      // Load repository URLs from Isar database
      final settings = isar.bridgeSettings.getSync(26);

      if (settings != null) {
        // Fetch installed and available extensions concurrently
        await Future.wait([
          // Get installed extensions for all content types
          getInstalledAnimeExtensions(),
          getInstalledMangaExtensions(),
          getInstalledNovelExtensions(),
          getInstalledMovieExtensions(),
          getInstalledTvShowExtensions(),
          getInstalledCartoonExtensions(),
          getInstalledDocumentaryExtensions(),
          getInstalledLivestreamExtensions(),
          getInstalledNsfwExtensions(),
          // Fetch available extensions from repositories
          fetchAvailableAnimeExtensions(settings.cloudstreamAnimeExtensions),
          fetchAvailableMangaExtensions(settings.cloudstreamMangaExtensions),
          fetchAvailableNovelExtensions(settings.cloudstreamNovelExtensions),
          fetchAvailableMovieExtensions(settings.cloudstreamMovieExtensions),
          fetchAvailableTvShowExtensions(settings.cloudstreamTvShowExtensions),
          fetchAvailableCartoonExtensions(
            settings.cloudstreamCartoonExtensions,
          ),
          fetchAvailableDocumentaryExtensions(
            settings.cloudstreamDocumentaryExtensions,
          ),
          fetchAvailableLivestreamExtensions(
            settings.cloudstreamLivestreamExtensions,
          ),
          fetchAvailableNsfwExtensions(settings.cloudstreamNsfwExtensions),
        ]);

        debugPrint('CloudStream extension bridge initialized successfully');
      }
    } catch (e) {
      // If isar is not initialized (e.g., in tests), just mark as initialized
      // without loading data (Requirement 12.1, 12.4)
      debugPrint('CloudStream initialization error (non-fatal): $e');
    }

    isInitialized.value = true;
  }

  @override
  Future<List<Source>> fetchAvailableAnimeExtensions(List<String>? repos) =>
      _fetchAvailable(ItemType.anime, repos);

  @override
  Future<List<Source>> fetchAvailableMangaExtensions(List<String>? repos) =>
      _fetchAvailable(ItemType.manga, repos);

  @override
  Future<List<Source>> fetchAvailableNovelExtensions(List<String>? repos) =>
      _fetchAvailable(ItemType.novel, repos);

  @override
  Future<List<Source>> fetchAvailableMovieExtensions(List<String>? repos) =>
      _fetchAvailable(ItemType.movie, repos);

  @override
  Future<List<Source>> fetchAvailableTvShowExtensions(List<String>? repos) =>
      _fetchAvailable(ItemType.tvShow, repos);

  @override
  Future<List<Source>> fetchAvailableCartoonExtensions(List<String>? repos) =>
      _fetchAvailable(ItemType.cartoon, repos);

  @override
  Future<List<Source>> fetchAvailableDocumentaryExtensions(
    List<String>? repos,
  ) => _fetchAvailable(ItemType.documentary, repos);

  @override
  Future<List<Source>> fetchAvailableLivestreamExtensions(
    List<String>? repos,
  ) => _fetchAvailable(ItemType.livestream, repos);

  @override
  Future<List<Source>> fetchAvailableNsfwExtensions(List<String>? repos) =>
      _fetchAvailable(ItemType.nsfw, repos);

  /// Helper method to fetch available extensions for a specific content type
  ///
  /// This method:
  /// 1. Persists repository URLs to Isar database
  /// 2. Makes HTTP requests to each repository URL
  /// 3. Parses JSON responses into Source objects
  /// 4. Filters out already installed extensions
  /// 5. Updates the appropriate reactive list
  /// 6. Calls checkForUpdates to detect available updates
  Future<List<Source>> _fetchAvailable(
    ItemType type,
    List<String>? repos,
  ) async {
    try {
      _availableGroups[type]!.value = [];
      _groupSources.removeWhere(
        (key, value) => key.startsWith('${type.index}:'),
      );

      // Persist repository URLs to Isar database (Requirement 2.1)
      final settings = isar.bridgeSettings.getSync(26)!;

      switch (type) {
        case ItemType.anime:
          settings.cloudstreamAnimeExtensions = repos ?? [];
          break;
        case ItemType.manga:
          settings.cloudstreamMangaExtensions = repos ?? [];
          break;
        case ItemType.novel:
          settings.cloudstreamNovelExtensions = repos ?? [];
          break;
        case ItemType.movie:
          settings.cloudstreamMovieExtensions = repos ?? [];
          break;
        case ItemType.tvShow:
          settings.cloudstreamTvShowExtensions = repos ?? [];
          break;
        case ItemType.cartoon:
          settings.cloudstreamCartoonExtensions = repos ?? [];
          break;
        case ItemType.documentary:
          settings.cloudstreamDocumentaryExtensions = repos ?? [];
          break;
        case ItemType.livestream:
          settings.cloudstreamLivestreamExtensions = repos ?? [];
          break;
        case ItemType.nsfw:
          settings.cloudstreamNsfwExtensions = repos ?? [];
          break;
      }
      isar.writeTxnSync(() => isar.bridgeSettings.putSync(settings));

      // If no repositories provided, return empty list
      if (repos == null || repos.isEmpty) {
        getAvailableRx(type).value = [];
        debugPrint('No repositories configured for $type extensions');
        return [];
      }

      // Fetch extensions from all repositories (Requirement 2.2)
      final allSources = <Source>[];
      final visitedRepos = <String>{};

      for (final repoUrl in repos) {
        try {
          final sources = await _fetchSourcesForRepo(
            repoUrl,
            type,
            visitedRepos: visitedRepos,
          );
          allSources.addAll(sources);
        } catch (e) {
          debugPrint('Error fetching from $repoUrl: $e');
        }
      }

      // Filter out already installed extensions (Requirement 2.4)
      final installedIds = getInstalledRx(type).value.map((e) => e.id).toSet();
      final filteredSources = allSources
          .where((s) => !installedIds.contains(s.id))
          .fold<Map<String, Source>>({}, (map, source) {
            final key = '${source.id}_${type.index}';
            map[key] = source;
            return map;
          })
          .values
          .toList();

      // Store unmodified list for later use (e.g., when uninstalling)
      switch (type) {
        case ItemType.anime:
          availableAnimeExtensionsUnmodified.value = filteredSources;
          break;
        case ItemType.manga:
          availableMangaExtensionsUnmodified.value = filteredSources;
          break;
        case ItemType.novel:
          availableNovelExtensionsUnmodified.value = filteredSources;
          break;
        case ItemType.movie:
          availableMovieExtensionsUnmodified.value = filteredSources;
          break;
        case ItemType.tvShow:
          availableTvShowExtensionsUnmodified.value = filteredSources;
          break;
        case ItemType.cartoon:
          availableCartoonExtensionsUnmodified.value = filteredSources;
          break;
        case ItemType.documentary:
          availableDocumentaryExtensionsUnmodified.value = filteredSources;
          break;
        case ItemType.livestream:
          availableLivestreamExtensionsUnmodified.value = filteredSources;
          break;
        case ItemType.nsfw:
          availableNsfwExtensionsUnmodified.value = filteredSources;
          break;
      }

      // Update appropriate reactive list (Requirement 2.5)
      getAvailableRx(type).value = filteredSources;

      // Check for updates (Requirement 2.6)
      await checkForUpdates(type);

      debugPrint(
        'Fetched ${filteredSources.length} available $type extensions',
      );
      return filteredSources;
    } catch (e) {
      // Log errors with context (Requirement 12.5)
      debugPrint('Error in _fetchAvailable for $type: $e');
      return [];
    }
  }

  List<CloudStreamExtensionGroup> getAvailableGroups(ItemType type) =>
      _availableGroups[type]!.value;

  Rx<List<CloudStreamExtensionGroup>> getAvailableGroupsRx(ItemType type) =>
      _availableGroups[type]!;

  Future<CloudStreamGroupInstallResult> installExtensionGroup(
    CloudStreamExtensionGroup group, {
    bool continueOnError = true,
  }) async {
    final sources = _groupSources[group.id];
    if (sources == null || sources.isEmpty) {
      throw Exception('No sources cached for group ${group.name}');
    }

    final installed = <String>[];
    final failures = <String, String>{};

    for (final source in List<Source>.from(sources)) {
      try {
        await installSource(source);
        installed.add(source.name ?? source.id ?? 'unknown');
      } catch (e) {
        final key = source.name ?? source.id ?? 'unknown';
        failures[key] = e.toString();
        if (!continueOnError) {
          break;
        }
      }
    }

    return CloudStreamGroupInstallResult(
      group: group,
      installed: installed,
      failures: failures,
    );
  }

  Future<List<Source>> _fetchSourcesForRepo(
    String repoUrl,
    ItemType type, {
    Set<String>? visitedRepos,
  }) async {
    final visited = visitedRepos ?? <String>{};
    final normalizedUrl = repoUrl.trim();
    if (normalizedUrl.isEmpty) return [];
    if (!visited.add(normalizedUrl)) {
      return [];
    }

    final uri = Uri.tryParse(repoUrl);
    if (uri == null) {
      debugPrint('Invalid CloudStream repo URL: $repoUrl');
      return [];
    }

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      debugPrint('Failed to fetch from $repoUrl: HTTP ${response.statusCode}');
      return [];
    }

    final body = response.body;
    dynamic decoded;
    try {
      decoded = json.decode(body);
    } catch (e) {
      debugPrint('Invalid JSON from $repoUrl: $e');
      return [];
    }

    if (decoded is List) {
      return await compute(parseSources, {
        'jsonList': decoded,
        'type': type.index,
      });
    }

    if (decoded is Map<String, dynamic>) {
      final pluginLists = _normalizePluginLists(decoded['pluginLists']);

      if (pluginLists.isEmpty) {
        debugPrint(
          'Manifest at $repoUrl did not contain pluginLists; skipping.',
        );
        return [];
      }

      final List<Source> manifestSources = [];
      for (final entry in pluginLists) {
        final sources = await _fetchSourcesFromPluginList(
          entry.url,
          type,
          repoUrl,
          decoded['name']?.toString(),
          visited,
        );
        if (sources.isNotEmpty) {
          _registerExtensionGroup(
            type: type,
            repoUrl: repoUrl,
            pluginListUrl: entry.url,
            repoName: decoded['name']?.toString(),
            sources: sources,
            pluginListName: entry.displayName,
          );
          manifestSources.addAll(sources);
        }
      }
      return manifestSources;
    }

    debugPrint(
      'Unsupported payload from $repoUrl (${decoded.runtimeType}); skipping.',
    );
    return [];
  }

  Future<List<Source>> _fetchSourcesFromPluginList(
    String pluginListUrl,
    ItemType type,
    String repoUrl,
    String? repoName,
    Set<String> visitedRepos,
  ) async {
    final uri = Uri.tryParse(pluginListUrl);
    if (uri == null) {
      debugPrint('Invalid plugin list URL: $pluginListUrl');
      return [];
    }
    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        debugPrint(
          'Failed to fetch plugin list $pluginListUrl: HTTP ${response.statusCode}',
        );
        return [];
      }

      final decoded = json.decode(response.body);
      if (decoded is! List) {
        debugPrint('Plugin list $pluginListUrl is not an array.');
        return [];
      }

      final List<Source> sources = [];
      for (final entry in decoded) {
        if (entry is! Map) continue;
        final map = Map<String, dynamic>.from(entry);

        final bundleSources = await _maybeExpandPluginBundle(
          plugin: map,
          type: type,
          visitedRepos: visitedRepos,
        );
        if (bundleSources != null) {
          sources.addAll(bundleSources);
          continue;
        }

        final tvTypes = (map['tvTypes'] as List?)
            ?.map((e) => e?.toString())
            .whereType<String>()
            .toList();
        if (!_pluginMatchesType(tvTypes, type)) continue;

        final source = _mapPluginToSource(
          plugin: map,
          type: type,
          repoUrl: repoUrl,
          repoName: repoName,
        );
        if (source != null) {
          sources.add(source);
        }
      }
      return sources;
    } catch (e) {
      debugPrint('Error parsing plugin list $pluginListUrl: $e');
      return [];
    }
  }

  void _registerExtensionGroup({
    required ItemType type,
    required String repoUrl,
    required String pluginListUrl,
    required List<Source> sources,
    String? repoName,
    String? pluginListName,
  }) {
    if (sources.isEmpty) return;

    final id = _groupId(type, repoUrl, pluginListUrl);
    final name = _deriveGroupName(repoName, pluginListUrl, pluginListName);

    _groupSources[id] = List<Source>.from(sources);

    final groups =
        _availableGroups[type]!.value.where((group) => group.id != id).toList()
          ..add(
            CloudStreamExtensionGroup(
              id: id,
              name: name,
              itemType: type,
              repoUrl: repoUrl,
              pluginListUrl: pluginListUrl,
              repoName: repoName,
              pluginCount: sources.length,
            ),
          );

    _availableGroups[type]!.value = groups;
  }

  String _groupId(ItemType type, String repoUrl, String pluginListUrl) =>
      '${type.index}:${repoUrl.hashCode}:${pluginListUrl.hashCode}';

  String _deriveGroupName(
    String? repoName,
    String pluginListUrl,
    String? pluginListName,
  ) {
    if (pluginListName != null && pluginListName.isNotEmpty) {
      return pluginListName;
    }
    if (repoName != null && repoName.isNotEmpty) {
      final fileName = pluginListUrl.split('/').last;
      return '$repoName (${fileName.replaceAll('.json', '')})';
    }
    return pluginListUrl.split('/').last.replaceAll('.json', '');
  }

  List<_PluginListEntry> _normalizePluginLists(dynamic raw) {
    if (raw is! List) return const <_PluginListEntry>[];

    final entries = <_PluginListEntry>[];
    for (final entry in raw) {
      if (entry is String && entry.isNotEmpty) {
        entries.add(_PluginListEntry(url: entry));
      } else if (entry is Map) {
        final map = Map<String, dynamic>.from(entry);
        final url = map['url']?.toString();
        if (url == null || url.isEmpty) continue;
        final name = map['name']?.toString() ?? map['label']?.toString();
        entries.add(_PluginListEntry(url: url, displayName: name));
      }
    }
    return entries;
  }

  bool _pluginMatchesType(List<String>? tvTypes, ItemType type) {
    if (tvTypes == null || tvTypes.isEmpty) {
      // If plugin does not specify tvTypes, allow it for all tabs
      return true;
    }

    final matches = <ItemType, List<String>>{
      ItemType.anime: ['Anime', 'AnimeMovie', 'OVA'],
      ItemType.manga: ['Manga'],
      ItemType.novel: ['AudioBook', 'Audio', 'Podcast'],
      ItemType.movie: ['Movie', 'AnimeMovie', 'Torrent'],
      ItemType.tvShow: ['TvSeries', 'AsianDrama'],
      ItemType.cartoon: ['Cartoon'],
      ItemType.documentary: ['Documentary'],
      ItemType.livestream: ['Live'],
      ItemType.nsfw: ['NSFW'],
    };

    final allowed = matches[type];
    if (allowed == null) {
      return true;
    }

    return tvTypes.any((tvType) => allowed.contains(tvType));
  }

  Source? _mapPluginToSource({
    required Map<String, dynamic> plugin,
    required ItemType type,
    required String repoUrl,
    required String? repoName,
  }) {
    final url = plugin['url']?.toString();
    final internalName = plugin['internalName']?.toString();
    final name = plugin['name']?.toString();
    if (url == null || internalName == null || name == null) {
      return null;
    }

    // Extract tvTypes for cross-category plugin support
    final tvTypes = (plugin['tvTypes'] as List?)
        ?.map((e) => e?.toString())
        .whereType<String>()
        .toList();

    final data = <String, dynamic>{
      'id': internalName,
      'name': name,
      'lang': plugin['language'],
      'iconUrl': plugin['iconUrl'],
      'version': plugin['version']?.toString(),
      'versionLast': plugin['version']?.toString(),
      'itemType': type.index,
      'isNsfw': tvTypes?.contains('NSFW') ?? false,
      'apkUrl': url,
      'repo': repoUrl,
      'baseUrl': plugin['repositoryUrl'] ?? repoUrl,
      'extensionType': ExtensionType.cloudstream.index,
      'hasUpdate': false,
      'tvTypes': tvTypes,
    };

    // best-effort apk name for installer UI
    data['apkName'] = url.split('/').last;

    final source = Source.fromJson(data)
      ..extensionType = ExtensionType.cloudstream
      ..itemType = type
      ..tvTypes = tvTypes;

    if (repoName != null && repoName.isNotEmpty) {
      source.repo = repoName;
    }

    return source;
  }

  Future<List<Source>?> _maybeExpandPluginBundle({
    required Map<String, dynamic> plugin,
    required ItemType type,
    required Set<String> visitedRepos,
  }) async {
    final internalName = plugin['internalName']?.toString().toLowerCase();
    if (internalName != _megaProviderInternalName) {
      return null;
    }

    final repoUrls = await _getMegaRepoUrls();
    if (repoUrls.isEmpty) {
      return <Source>[];
    }

    final expanded = <Source>[];
    for (final repo in repoUrls) {
      expanded.addAll(
        await _fetchSourcesForRepo(repo, type, visitedRepos: visitedRepos),
      );
    }
    return expanded;
  }

  Future<List<String>> _getMegaRepoUrls() async {
    if (_cachedMegaRepoUrls != null) {
      return _cachedMegaRepoUrls!;
    }

    try {
      final response = await http.get(Uri.parse(_megaRepoListUrl));
      if (response.statusCode != 200) {
        debugPrint(
          'Failed to fetch Mega repo list: HTTP ${response.statusCode}',
        );
        return [];
      }

      final decoded = json.decode(response.body);
      if (decoded is! List) {
        debugPrint('Mega repo list was not an array.');
        return [];
      }

      final urls = <String>[];
      for (final entry in decoded) {
        if (entry is String) {
          urls.add(entry);
        } else if (entry is Map) {
          final url = entry['url']?.toString();
          if (url != null && url.isNotEmpty) {
            urls.add(url);
          }
        }
      }

      _cachedMegaRepoUrls = urls;
      return urls;
    } catch (e) {
      debugPrint('Error loading Mega repo list: $e');
      return [];
    }
  }

  /// Static method to parse JSON sources in an isolate
  /// This is used with compute() for better performance
  /// Made public for testing purposes
  static List<Source> parseSources(Map<String, dynamic> data) {
    final List<dynamic> jsonList = data['jsonList'];
    final int typeIndex = data['type'];
    final type = ItemType.values[typeIndex];

    return jsonList.map((json) {
      final source = Source.fromJson(json);
      // Set extensionType to cloudstream (Requirement 2.3)
      source.extensionType = ExtensionType.cloudstream;
      source.itemType = type;
      return source;
    }).toList();
  }

  /// Check for updates for installed extensions
  /// Compares installed versions with available versions
  Future<void> checkForUpdates(ItemType type) async {
    try {
      final availableMap = {for (var s in getAvailableRx(type).value) s.id: s};

      final updated = getInstalledRx(type).value.map((installed) {
        final available = availableMap[installed.id];
        if (available != null &&
            installed.version != null &&
            available.version != null &&
            compareVersions(installed.version!, available.version!) < 0) {
          return installed
            ..hasUpdate = true
            ..versionLast = available.version
            ..apkUrl = available.apkUrl;
        }
        return installed;
      }).toList();

      getInstalledRx(type).value = updated;

      final updatesCount = updated.where((s) => s.hasUpdate == true).length;
      if (updatesCount > 0) {
        debugPrint('Found $updatesCount updates for $type extensions');
      }
    } catch (e) {
      // Log errors with context (Requirement 12.5)
      debugPrint('Error checking for updates for $type: $e');
    }
  }

  @override
  Future<List<Source>> getInstalledAnimeExtensions() =>
      _getInstalled(ItemType.anime);

  @override
  Future<List<Source>> getInstalledMangaExtensions() =>
      _getInstalled(ItemType.manga);

  @override
  Future<List<Source>> getInstalledNovelExtensions() =>
      _getInstalled(ItemType.novel);

  @override
  Future<List<Source>> getInstalledMovieExtensions() =>
      _getInstalled(ItemType.movie);

  @override
  Future<List<Source>> getInstalledTvShowExtensions() =>
      _getInstalled(ItemType.tvShow);

  @override
  Future<List<Source>> getInstalledCartoonExtensions() =>
      _getInstalled(ItemType.cartoon);

  @override
  Future<List<Source>> getInstalledDocumentaryExtensions() =>
      _getInstalled(ItemType.documentary);

  @override
  Future<List<Source>> getInstalledLivestreamExtensions() =>
      _getInstalled(ItemType.livestream);

  @override
  Future<List<Source>> getInstalledNsfwExtensions() =>
      _getInstalled(ItemType.nsfw);

  /// Helper method to get installed extensions for a specific content type
  ///
  /// This method:
  /// 1. First tries to load from the native plugin registry
  /// 2. Falls back to legacy platform channel methods if registry is empty
  /// 3. Parses platform response using compute isolate for performance
  /// 4. Sets extensionType to cloudstream on all parsed Source objects
  /// 5. Updates appropriate reactive list based on content type
  /// 6. Calls checkForUpdates after updating installed list
  /// 7. Handles platform channel failures by returning empty list
  Future<List<Source>> _getInstalled(ItemType type) async {
    try {
      // First, try to load from the native plugin registry
      final pluginSources = await _loadFromPluginRegistry(type);

      if (pluginSources.isNotEmpty) {
        // Update appropriate reactive list
        getInstalledRx(type).value = pluginSources;

        // Check for updates
        await checkForUpdates(type);

        debugPrint(
          'Loaded ${pluginSources.length} installed $type extensions from plugin registry',
        );
        return pluginSources;
      }

      // Fall back to legacy platform channel methods
      // Log this for telemetry - if we're hitting this path frequently,
      // it indicates plugins aren't being properly registered in the store
      debugPrint(
        '[TELEMETRY] Falling back to legacy platform methods for $type extensions. '
        'Plugin registry returned 0 entries.',
      );
      final String methodName;
      switch (type) {
        case ItemType.anime:
          methodName = 'getInstalledAnimeExtensions';
          break;
        case ItemType.manga:
          methodName = 'getInstalledMangaExtensions';
          break;
        case ItemType.novel:
          methodName = 'getInstalledNovelExtensions';
          break;
        case ItemType.movie:
          methodName = 'getInstalledMovieExtensions';
          break;
        case ItemType.tvShow:
          methodName = 'getInstalledTvShowExtensions';
          break;
        case ItemType.cartoon:
          methodName = 'getInstalledCartoonExtensions';
          break;
        case ItemType.documentary:
          methodName = 'getInstalledDocumentaryExtensions';
          break;
        case ItemType.livestream:
          methodName = 'getInstalledLivestreamExtensions';
          break;
        case ItemType.nsfw:
          methodName = 'getInstalledNsfwExtensions';
          break;
      }

      // Load extensions from legacy platform channel
      final sources = await _loadExtensions(methodName, type);

      // Update appropriate reactive list
      getInstalledRx(type).value = sources;

      // Check for updates
      await checkForUpdates(type);

      // Log telemetry for legacy path results
      if (sources.isEmpty) {
        debugPrint(
          '[TELEMETRY] Legacy platform returned 0 extensions for $type. '
          'No CloudStream plugins installed via either path.',
        );
      } else {
        debugPrint(
          '[TELEMETRY] Legacy platform returned ${sources.length} extensions for $type. '
          'These may need migration to plugin store.',
        );
      }

      debugPrint(
        'Loaded ${sources.length} installed $type extensions from legacy platform',
      );
      return sources;
    } catch (e) {
      debugPrint('Error getting installed extensions for $type: $e');
      return [];
    }
  }

  /// Load installed extensions from the native plugin registry.
  /// Filters plugins by their itemTypes/tvTypes to match the requested type.
  Future<List<Source>> _loadFromPluginRegistry(ItemType type) async {
    try {
      final plugins = await listInstalledCloudStreamPlugins();
      if (plugins.isEmpty) return [];

      final sources = <Source>[];
      for (final plugin in plugins) {
        // Check if plugin matches the requested type
        if (!_pluginMetadataMatchesType(plugin, type)) continue;

        final source = _pluginMetadataToSource(plugin, type);
        if (source != null) {
          sources.add(source);
        }
      }

      return sources;
    } catch (e) {
      debugPrint('Error loading from plugin registry: $e');
      return [];
    }
  }

  /// Check if plugin metadata matches the requested item type.
  bool _pluginMetadataMatchesType(Map<String, dynamic> plugin, ItemType type) {
    final tvTypes = (plugin['tvTypes'] as List?)?.cast<String>();
    final itemTypes = (plugin['itemTypes'] as List?)?.cast<int>();

    // If itemTypes is specified, check directly
    if (itemTypes != null && itemTypes.isNotEmpty) {
      return itemTypes.contains(type.index);
    }

    // Fall back to tvTypes matching
    if (tvTypes == null || tvTypes.isEmpty) {
      // If no types specified, include in all tabs
      return true;
    }

    return _pluginMatchesType(tvTypes, type);
  }

  /// Convert plugin metadata from native store to Source object.
  Source? _pluginMetadataToSource(Map<String, dynamic> plugin, ItemType type) {
    final internalName = plugin['internalName']?.toString();
    if (internalName == null) return null;

    final data = <String, dynamic>{
      'id': internalName,
      'name': plugin['name'] ?? internalName,
      'lang': plugin['lang'],
      'iconUrl': plugin['iconUrl'],
      'version': plugin['version']?.toString(),
      'versionLast': plugin['version']?.toString(),
      'itemType': type.index,
      'isNsfw': plugin['isNsfw'] ?? false,
      'repo': plugin['repoUrl'],
      'baseUrl': plugin['repoUrl'],
      'localPath': plugin['localPath'],
      'extensionType': ExtensionType.cloudstream.index,
      'hasUpdate': false,
    };

    final source = Source.fromJson(data)
      ..extensionType = ExtensionType.cloudstream
      ..itemType = type;

    return source;
  }

  /// Helper method to handle platform channel communication
  ///
  /// This method:
  /// 1. Invokes the specified platform method
  /// 2. Parses the response using compute isolate for performance
  /// 3. Returns parsed Source objects with extensionType set to cloudstream
  Future<List<Source>> _loadExtensions(String methodName, ItemType type) async {
    try {
      // Invoke platform channel method (Requirement 10.1)
      final dynamic result = await platform.invokeMethod(methodName);

      // Handle null or empty response
      if (result == null) {
        debugPrint('Platform channel returned null for $methodName');
        return [];
      }

      // Parse response using compute isolate for performance (Requirement 10.7)
      final sources = await compute(_parseSources, {
        'jsonList': result as List<dynamic>,
        'type': type.index,
      });

      return sources;
    } catch (e) {
      // Handle platform channel failures (Requirement 10.6, 12.4)
      debugPrint('Platform channel error for $methodName: $e');
      return [];
    }
  }

  /// Static method to parse platform response in an isolate
  /// This is used with compute() for better performance
  /// Sets extensionType to cloudstream on all parsed Source objects (Requirement 3.2)
  static List<Source> _parseSources(Map<String, dynamic> data) {
    final List<dynamic> jsonList = data['jsonList'];
    final int typeIndex = data['type'];
    final type = ItemType.values[typeIndex];

    return jsonList.map((json) {
      // Convert to Map<String, dynamic> if needed
      final Map<String, dynamic> jsonMap = json is Map<String, dynamic>
          ? json
          : Map<String, dynamic>.from(json as Map);

      final source = Source.fromJson(jsonMap);
      // Set extensionType to cloudstream (Requirement 3.2)
      source.extensionType = ExtensionType.cloudstream;
      source.itemType = type;
      return source;
    }).toList();
  }

  @override
  Future<void> installSource(Source source) async {
    // Validate Source has non-empty apkUrl (Requirements 4.1, 4.2)
    if (source.apkUrl?.trim().isEmpty ?? true) {
      return Future.error('Source APK URL is required for installation.');
    }

    final uri = Uri.tryParse(source.apkUrl!.trim());
    if (uri == null) {
      return Future.error('Invalid extension URL.');
    }

    final fileName = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
    final lowerName = fileName.toLowerCase();

    // Check if this is a CloudStream plugin bundle (.cs3/.zip)
    final isPluginBundle =
        lowerName.endsWith('.cs3') || lowerName.endsWith('.zip');

    // Route CloudStream plugin bundles through the new native plugin store
    if (isPluginBundle) {
      await _installCloudStreamPluginBundle(source, uri, fileName);
      return;
    }

    // Legacy APK installation path (for backward compatibility)
    // This should only be used for non-CloudStream extensions
    await _installLegacyApk(source, uri, fileName);
  }

  /// Install a CloudStream plugin bundle (.cs3/.zip) through the native plugin store.
  Future<void> _installCloudStreamPluginBundle(
    Source source,
    Uri uri,
    String fileName,
  ) async {
    try {
      isLoading.value = true;
      lastError.value = null;

      final internalName =
          source.id ?? fileName.replaceAll(RegExp(r'\.(cs3|zip)$'), '');
      debugPrint(
        'Installing CloudStream plugin: ${source.name} ($internalName)',
      );

      // Compute all applicable itemTypes from tvTypes for cross-category support
      // This ensures a plugin with tvTypes ['Anime', 'Movie'] appears in both tabs
      final itemTypes = _computeItemTypesFromTvTypes(source.tvTypes);

      // If no itemTypes computed from tvTypes, fall back to current itemType
      final effectiveItemTypes = itemTypes.isNotEmpty
          ? itemTypes
          : (source.itemType != null ? [source.itemType!.index] : <int>[]);

      debugPrint(
        'Plugin ${source.name} itemTypes: $effectiveItemTypes (from tvTypes: ${source.tvTypes})',
      );

      // Call the new native plugin installer
      final result = await installCloudStreamPlugin(
        internalName: internalName,
        downloadUrl: source.apkUrl!,
        repoUrl: source.repo,
        version: source.version,
        tvTypes: source.tvTypes,
        lang: source.lang,
        isNsfw: source.isNsfw ?? false,
        itemTypes: effectiveItemTypes,
      );

      if (result == null) {
        throw Exception(lastError.value ?? 'Installation failed');
      }

      // Remove extension from available list on success
      _removeFromAvailableLists(source);

      // Refresh plugin status
      await refreshPluginStatus();

      debugPrint('Successfully installed CloudStream plugin: ${source.name}');
    } catch (e) {
      lastError.value = 'Failed to install plugin: $e';
      debugPrint('Error installing CloudStream plugin ${source.name}: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Compute all applicable ItemType indices from CloudStream tvTypes.
  ///
  /// Maps tvTypes like ['Anime', 'Movie', 'TvSeries'] to ItemType indices
  /// so plugins appear in all relevant category tabs.
  List<int> _computeItemTypesFromTvTypes(List<String>? tvTypes) {
    if (tvTypes == null || tvTypes.isEmpty) {
      return <int>[];
    }

    final itemTypes = <int>{};

    for (final type in ItemType.values) {
      if (_pluginMatchesType(tvTypes, type)) {
        itemTypes.add(type.index);
      }
    }

    return itemTypes.toList();
  }

  /// Legacy APK installation path (for backward compatibility with non-CloudStream extensions).
  Future<void> _installLegacyApk(
    Source source,
    Uri uri,
    String fileName,
  ) async {
    final lowerName = fileName.toLowerCase();
    if (!lowerName.endsWith('.apk')) {
      return Future.error(
        'The provided URL does not point to a supported extension file (.cs3/.zip/.apk).',
      );
    }

    File? apkFile;
    try {
      // Extract package name from apkUrl
      final packageName = fileName.isEmpty
          ? uri.host.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
          : fileName.replaceAll(RegExp(r'\.apk$'), '');
      debugPrint(
        'Installing legacy APK extension: ${source.name} ($packageName)',
      );

      // Download APK using http.get
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to download APK: HTTP ${response.statusCode}');
      }

      debugPrint(
        'Downloaded APK for ${source.name} (${response.bodyBytes.length} bytes)',
      );

      // Save APK to temporary directory
      final tempDir = await getTemporaryDirectory();
      apkFile = File(path.join(tempDir.path, '$packageName.apk'));
      await apkFile.writeAsBytes(response.bodyBytes);

      debugPrint('Saved APK to temporary file: ${apkFile.path}');

      // Call InstallPlugin.installApk
      final result = await InstallPlugin.installApk(
        apkFile.path,
        appId: packageName,
      );

      if (result['isSuccess'] != true) {
        throw Exception(
          'Installation failed: ${result['errorMessage'] ?? 'Unknown error'}',
        );
      }

      // Remove extension from available list on success
      _removeFromAvailableLists(source);

      // Refresh installed extensions list
      await _getInstalled(source.itemType!);

      debugPrint('Successfully installed legacy APK extension: ${source.name}');
    } catch (e) {
      debugPrint('Error installing legacy APK source ${source.name}: $e');
      rethrow;
    } finally {
      if (apkFile != null && await apkFile.exists()) {
        try {
          await apkFile.delete();
          debugPrint('Cleaned up temporary APK file: ${apkFile.path}');
        } catch (e) {
          debugPrint('Error deleting temporary APK file: $e');
        }
      }
    }
  }

  /// Helper to remove a source from all available lists.
  void _removeFromAvailableLists(Source source) {
    if (source.itemType == null) return;

    final rx = getAvailableRx(source.itemType!);
    rx.value = rx.value.where((s) => s.id != source.id).toList();

    // Also remove from unmodified list
    switch (source.itemType!) {
      case ItemType.anime:
        availableAnimeExtensionsUnmodified.value =
            availableAnimeExtensionsUnmodified.value
                .where((s) => s.id != source.id)
                .toList();
        break;
      case ItemType.manga:
        availableMangaExtensionsUnmodified.value =
            availableMangaExtensionsUnmodified.value
                .where((s) => s.id != source.id)
                .toList();
        break;
      case ItemType.novel:
        availableNovelExtensionsUnmodified.value =
            availableNovelExtensionsUnmodified.value
                .where((s) => s.id != source.id)
                .toList();
        break;
      case ItemType.movie:
        availableMovieExtensionsUnmodified.value =
            availableMovieExtensionsUnmodified.value
                .where((s) => s.id != source.id)
                .toList();
        break;
      case ItemType.tvShow:
        availableTvShowExtensionsUnmodified.value =
            availableTvShowExtensionsUnmodified.value
                .where((s) => s.id != source.id)
                .toList();
        break;
      case ItemType.cartoon:
        availableCartoonExtensionsUnmodified.value =
            availableCartoonExtensionsUnmodified.value
                .where((s) => s.id != source.id)
                .toList();
        break;
      case ItemType.documentary:
        availableDocumentaryExtensionsUnmodified.value =
            availableDocumentaryExtensionsUnmodified.value
                .where((s) => s.id != source.id)
                .toList();
        break;
      case ItemType.livestream:
        availableLivestreamExtensionsUnmodified.value =
            availableLivestreamExtensionsUnmodified.value
                .where((s) => s.id != source.id)
                .toList();
        break;
      case ItemType.nsfw:
        availableNsfwExtensionsUnmodified.value =
            availableNsfwExtensionsUnmodified.value
                .where((s) => s.id != source.id)
                .toList();
        break;
    }
  }

  @override
  Future<void> uninstallSource(Source source) async {
    // Validate Source has non-empty id (package name) (Requirements 5.1, 5.2)
    if (source.id?.trim().isEmpty ?? true) {
      throw Exception('Source ID is required for uninstallation');
    }

    try {
      debugPrint('Uninstalling extension: ${source.name} (${source.id})');

      // Check if this is a CloudStream plugin (installed via native plugin store)
      final isCloudStreamPlugin = await _isCloudStreamPlugin(source.id!);

      if (isCloudStreamPlugin) {
        // Use the new native plugin uninstaller
        await _uninstallCloudStreamPlugin(source);
        return;
      }

      // Legacy APK uninstallation path (for backward compatibility)
      await _uninstallLegacyApk(source);
    } catch (e) {
      debugPrint('Error uninstalling source ${source.name}: $e');
      rethrow;
    }
  }

  /// Check if a source is a CloudStream plugin (installed via native plugin store).
  Future<bool> _isCloudStreamPlugin(String sourceId) async {
    try {
      final plugins = await listInstalledCloudStreamPlugins();
      return plugins.any((p) => p['internalName'] == sourceId);
    } catch (e) {
      debugPrint('Error checking if $sourceId is CloudStream plugin: $e');
      return false;
    }
  }

  /// Uninstall a CloudStream plugin through the native plugin store.
  Future<void> _uninstallCloudStreamPlugin(Source source) async {
    try {
      isLoading.value = true;
      lastError.value = null;

      debugPrint(
        'Uninstalling CloudStream plugin: ${source.name} (${source.id})',
      );

      final success = await uninstallCloudStreamPlugin(source.id!);

      if (!success) {
        throw Exception(lastError.value ?? 'Uninstallation failed');
      }

      // Remove from installed list
      removeFromInstalledList(source);

      // Add extension back to available list if it exists in availableUnmodified
      _addBackToAvailableList(source);

      // Refresh plugin status
      await refreshPluginStatus();

      debugPrint('Successfully uninstalled CloudStream plugin: ${source.name}');
    } catch (e) {
      lastError.value = 'Failed to uninstall plugin: $e';
      debugPrint('Error uninstalling CloudStream plugin ${source.name}: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Legacy APK uninstallation path (for backward compatibility).
  Future<void> _uninstallLegacyApk(Source source) async {
    // Check if package is installed using DeviceApps.isAppInstalled
    final isInstalled = await _isPackageInstalled(source.id!);

    // If not installed, call removeFromInstalledList and return successfully
    if (!isInstalled) {
      removeFromInstalledList(source);
      debugPrint('Package ${source.id} not installed, removed from list');
      return;
    }

    // If installed, call DeviceApps.uninstallApp to initiate uninstallation
    final uninstallInitiated = await FlutterDeviceApps.uninstallApp(source.id!);

    if (!uninstallInitiated) {
      throw Exception('Failed to initiate uninstallation for ${source.id}');
    }

    debugPrint(
      'Uninstallation initiated for ${source.id}, waiting for completion...',
    );

    // Poll for up to 10 seconds (500ms intervals) to verify package removal
    bool packageRemoved = false;
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 500));

      final stillInstalled = await _isPackageInstalled(source.id!);
      if (!stillInstalled) {
        packageRemoved = true;
        break;
      }
    }

    if (!packageRemoved) {
      throw Exception('Uninstallation timed out or was cancelled by user');
    }

    // Remove from installed list
    removeFromInstalledList(source);

    // Add extension back to available list
    _addBackToAvailableList(source);

    debugPrint('Successfully uninstalled legacy APK extension: ${source.name}');
  }

  /// Helper to add a source back to available lists after uninstallation.
  void _addBackToAvailableList(Source source) {
    if (source.itemType == null) return;

    final unmodifiedList = getAvailableUnmodified(source.itemType!);
    final existsInAvailable = unmodifiedList.any((s) => s.id == source.id);

    if (existsInAvailable) {
      final sourceToAdd = unmodifiedList.firstWhere((s) => s.id == source.id);
      final rx = getAvailableRx(source.itemType!);
      rx.value = [...rx.value, sourceToAdd];
    }
  }

  /// Helper method to remove an extension from the installed list
  /// Updates the appropriate reactive list based on content type (Requirement 5.7)
  /// Made public for testing purposes
  void removeFromInstalledList(Source source) {
    final rx = getInstalledRx(source.itemType!);
    rx.value = rx.value.where((s) => s.id != source.id).toList();
  }

  /// Helper method to access unmodified available lists
  /// Returns the unmodified list for the specified content type (Requirement 5.8)
  List<Source> getAvailableUnmodified(ItemType type) {
    switch (type) {
      case ItemType.anime:
        return availableAnimeExtensionsUnmodified.value;
      case ItemType.manga:
        return availableMangaExtensionsUnmodified.value;
      case ItemType.novel:
        return availableNovelExtensionsUnmodified.value;
      case ItemType.movie:
        return availableMovieExtensionsUnmodified.value;
      case ItemType.tvShow:
        return availableTvShowExtensionsUnmodified.value;
      case ItemType.cartoon:
        return availableCartoonExtensionsUnmodified.value;
      case ItemType.documentary:
        return availableDocumentaryExtensionsUnmodified.value;
      case ItemType.livestream:
        return availableLivestreamExtensionsUnmodified.value;
      case ItemType.nsfw:
        return availableNsfwExtensionsUnmodified.value;
    }
  }

  @override
  Future<void> updateSource(Source source) async {
    // Validate Source has non-empty apkUrl (Requirements 6.1, 6.2)
    if (source.apkUrl?.trim().isEmpty ?? true) {
      return Future.error('Source APK URL is required for installation.');
    }

    File? apkFile;
    try {
      // Extract package name from apkUrl (Requirement 6.2)
      final packageName = source.apkUrl!.split('/').last.replaceAll('.apk', '');
      debugPrint(
        'Updating extension: ${source.name} ($packageName) to version ${source.versionLast}',
      );

      // Download new APK version using http.get (Requirement 6.3, 12.1)
      final response = await http.get(Uri.parse(source.apkUrl!));

      // Validate HTTP response status is 200 (Requirement 6.4, 12.2)
      if (response.statusCode != 200) {
        throw Exception('Failed to download APK: HTTP ${response.statusCode}');
      }

      debugPrint(
        'Downloaded update APK for ${source.name} (${response.bodyBytes.length} bytes)',
      );

      // Save APK to temporary directory (Requirement 6.5, 12.3)
      final tempDir = await getTemporaryDirectory();
      apkFile = File(path.join(tempDir.path, '$packageName.apk'));
      await apkFile.writeAsBytes(response.bodyBytes);

      debugPrint('Saved update APK to temporary file: ${apkFile.path}');

      // Call InstallPlugin.installApk to replace existing version (Requirement 6.6)
      final result = await InstallPlugin.installApk(
        apkFile.path,
        appId: packageName,
      );

      // Check installation result, throw exception if failed
      if (result['isSuccess'] != true) {
        throw Exception(
          'Update failed: ${result['errorMessage'] ?? 'Unknown error'}',
        );
      }

      // Refresh installed extensions list to reflect new version (Requirement 6.8)
      await _getInstalled(source.itemType!);

      debugPrint('Successfully updated extension: ${source.name}');
    } catch (e) {
      // Log errors with context (Requirement 12.5)
      debugPrint('Error updating source ${source.name}: $e');
      rethrow;
    } finally {
      // Delete temporary APK file after installation (Requirement 6.7, 12.3)
      if (apkFile != null && await apkFile.exists()) {
        try {
          await apkFile.delete();
          debugPrint('Cleaned up temporary update APK file: ${apkFile.path}');
        } catch (e) {
          debugPrint('Error deleting temporary update APK file: $e');
        }
      }
    }
  }

  Future<bool> _isPackageInstalled(String packageName) async {
    final appInfo = await FlutterDeviceApps.getApp(packageName);
    return appInfo != null;
  }

  // ============================================================
  // New Platform Methods for Plugin Management
  // ============================================================

  /// Initialize or reinitialize all plugins on the native side.
  /// Returns a map with success status, loaded count, and extractor count.
  Future<Map<String, dynamic>> initializePlugins() async {
    try {
      isLoading.value = true;
      lastError.value = null;

      final result = await platform.invokeMethod('initializePlugins');
      final resultMap = Map<String, dynamic>.from(result as Map);

      // Update plugin status
      await refreshPluginStatus();

      debugPrint(
        'Plugins initialized: ${resultMap['loadedCount']} plugins, ${resultMap['extractorCount']} extractors',
      );

      return resultMap;
    } catch (e) {
      lastError.value = 'Failed to initialize plugins: $e';
      debugPrint('Error initializing plugins: $e');
      return {'success': false, 'error': e.toString()};
    } finally {
      isLoading.value = false;
    }
  }

  /// Get the current plugin status from the native layer.
  Future<Map<String, dynamic>> refreshPluginStatus() async {
    try {
      final result = await platform.invokeMethod('getPluginStatus');
      final resultMap = Map<String, dynamic>.from(result as Map);
      pluginStatus.value = resultMap;
      return resultMap;
    } catch (e) {
      debugPrint('Error getting plugin status: $e');
      return {};
    }
  }

  /// List all installed CloudStream plugins from the native store.
  Future<List<Map<String, dynamic>>> listInstalledCloudStreamPlugins() async {
    try {
      final result = await platform.invokeMethod(
        'listInstalledCloudStreamPlugins',
      );
      return (result as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error listing installed plugins: $e');
      return [];
    }
  }

  /// Install a CloudStream plugin from a .cs3/.zip file.
  ///
  /// This method:
  /// 1. Downloads the plugin bundle
  /// 2. Extracts it to the plugin directory
  /// 3. Loads the plugin into the registry
  /// 4. Returns the installed plugin metadata
  Future<Map<String, dynamic>?> installCloudStreamPlugin({
    required String internalName,
    required String downloadUrl,
    String? repoUrl,
    String? version,
    List<String>? tvTypes,
    String? lang,
    bool isNsfw = false,
    List<int>? itemTypes,
  }) async {
    try {
      isLoading.value = true;
      lastError.value = null;

      final metadata = {
        'internalName': internalName,
        'downloadUrl': downloadUrl,
        'repoUrl': repoUrl,
        'version': version,
        'tvTypes': tvTypes ?? [],
        'lang': lang,
        'isNsfw': isNsfw,
        'itemTypes': itemTypes ?? [],
      };

      final result = await platform.invokeMethod('installCloudStreamPlugin', {
        'metadata': metadata,
        'repoKey': repoUrl,
      });

      final resultMap = Map<String, dynamic>.from(result as Map);

      // Refresh installed lists
      await _refreshAllInstalledLists();

      debugPrint(
        'Plugin installed: $internalName (loaded: ${resultMap['loaded']})',
      );
      return resultMap;
    } catch (e) {
      lastError.value = 'Failed to install plugin: $e';
      debugPrint('Error installing plugin $internalName: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Uninstall a CloudStream plugin.
  Future<bool> uninstallCloudStreamPlugin(String internalName) async {
    try {
      isLoading.value = true;
      lastError.value = null;

      final result = await platform.invokeMethod('uninstallCloudStreamPlugin', {
        'internalName': internalName,
      });

      // Refresh installed lists
      await _refreshAllInstalledLists();

      debugPrint('Plugin uninstalled: $internalName');
      return result as bool? ?? false;
    } catch (e) {
      lastError.value = 'Failed to uninstall plugin: $e';
      debugPrint('Error uninstalling plugin $internalName: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh all installed extension lists.
  Future<void> _refreshAllInstalledLists() async {
    await Future.wait([
      getInstalledAnimeExtensions(),
      getInstalledMangaExtensions(),
      getInstalledNovelExtensions(),
      getInstalledMovieExtensions(),
      getInstalledTvShowExtensions(),
      getInstalledCartoonExtensions(),
      getInstalledDocumentaryExtensions(),
      getInstalledLivestreamExtensions(),
      getInstalledNsfwExtensions(),
    ]);
  }

  // ============================================================
  // Extractor Service Methods
  // ============================================================

  /// Extract video links from a URL using CloudStream extractors.
  ///
  /// This can be called by other bridges (Aniyomi/Lnreader) to use
  /// CloudStream's extractor implementations.
  Future<ExtractorResult> extract(String url, {String? referer}) async {
    try {
      final result = await platform.invokeMethod('cloudstream:extract', {
        'url': url,
        'referer': referer,
      });

      return ExtractorResult.fromJson(Map<String, dynamic>.from(result as Map));
    } catch (e) {
      debugPrint('Error extracting from $url: $e');
      return ExtractorResult(
        success: false,
        links: [],
        subtitles: [],
        error: e.toString(),
      );
    }
  }

  /// Extract video links using a specific extractor by name.
  Future<ExtractorResult> extractWithExtractor(
    String extractorName,
    String url, {
    String? referer,
  }) async {
    try {
      final result = await platform.invokeMethod(
        'cloudstream:extractWithExtractor',
        {'extractorName': extractorName, 'url': url, 'referer': referer},
      );

      return ExtractorResult.fromJson(Map<String, dynamic>.from(result as Map));
    } catch (e) {
      debugPrint('Error extracting with $extractorName: $e');
      return ExtractorResult(
        success: false,
        links: [],
        subtitles: [],
        error: e.toString(),
      );
    }
  }

  /// List all available extractors.
  Future<List<ExtractorInfo>> listExtractors() async {
    try {
      final result = await platform.invokeMethod('cloudstream:listExtractors');
      return (result as List)
          .map((e) => ExtractorInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint('Error listing extractors: $e');
      return [];
    }
  }

  /// Get loaded plugins from the native registry.
  Future<List<Map<String, dynamic>>> getLoadedPlugins() async {
    try {
      final result = await platform.invokeMethod(
        'cloudstream:getLoadedPlugins',
      );
      return (result as List).map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      debugPrint('Error getting loaded plugins: $e');
      return [];
    }
  }
}

// ============================================================
// Extractor Result Models
// ============================================================

/// Result of an extraction operation.
class ExtractorResult {
  final bool success;
  final List<ExtractedLink> links;
  final List<ExtractedSubtitle> subtitles;
  final String? error;

  ExtractorResult({
    required this.success,
    required this.links,
    required this.subtitles,
    this.error,
  });

  factory ExtractorResult.fromJson(Map<String, dynamic> json) {
    return ExtractorResult(
      success: json['success'] as bool? ?? false,
      links:
          (json['links'] as List?)
              ?.map((e) => ExtractedLink.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      subtitles:
          (json['subtitles'] as List?)
              ?.map(
                (e) => ExtractedSubtitle.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          [],
      error: json['error'] as String?,
    );
  }
}

/// Extracted video link information.
class ExtractedLink {
  final String source;
  final String name;
  final String url;
  final String referer;
  final int quality;
  final Map<String, String> headers;
  final String? extractorData;
  final String type;
  final bool isM3u8;
  final bool isDash;

  ExtractedLink({
    required this.source,
    required this.name,
    required this.url,
    required this.referer,
    required this.quality,
    this.headers = const {},
    this.extractorData,
    required this.type,
    required this.isM3u8,
    required this.isDash,
  });

  factory ExtractedLink.fromJson(Map<String, dynamic> json) {
    return ExtractedLink(
      source: json['source'] as String? ?? '',
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      referer: json['referer'] as String? ?? '',
      quality: json['quality'] as int? ?? 0,
      headers:
          (json['headers'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ) ??
          {},
      extractorData: json['extractorData'] as String?,
      type: json['type'] as String? ?? 'VIDEO',
      isM3u8: json['isM3u8'] as bool? ?? false,
      isDash: json['isDash'] as bool? ?? false,
    );
  }
}

/// Extracted subtitle information.
class ExtractedSubtitle {
  final String lang;
  final String url;

  ExtractedSubtitle({required this.lang, required this.url});

  factory ExtractedSubtitle.fromJson(Map<String, dynamic> json) {
    return ExtractedSubtitle(
      lang: json['lang'] as String? ?? '',
      url: json['url'] as String? ?? '',
    );
  }
}

/// Information about an available extractor.
class ExtractorInfo {
  final String name;
  final String mainUrl;
  final bool requiresReferer;
  final String? sourcePlugin;

  ExtractorInfo({
    required this.name,
    required this.mainUrl,
    required this.requiresReferer,
    this.sourcePlugin,
  });

  factory ExtractorInfo.fromJson(Map<String, dynamic> json) {
    return ExtractorInfo(
      name: json['name'] as String? ?? '',
      mainUrl: json['mainUrl'] as String? ?? '',
      requiresReferer: json['requiresReferer'] as bool? ?? false,
      sourcePlugin: json['sourcePlugin'] as String?,
    );
  }
}
