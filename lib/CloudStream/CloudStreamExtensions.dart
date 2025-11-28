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

      for (final repoUrl in repos) {
        try {
          final sources = await _fetchSourcesForRepo(repoUrl, type);
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

  Future<List<Source>> _fetchSourcesForRepo(
    String repoUrl,
    ItemType type,
  ) async {
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
      final pluginLists = (decoded['pluginLists'] as List?)
          ?.map((e) => e?.toString())
          .whereType<String>()
          .toList();

      if (pluginLists == null || pluginLists.isEmpty) {
        debugPrint(
          'Manifest at $repoUrl did not contain pluginLists; skipping.',
        );
        return [];
      }

      final List<Source> manifestSources = [];
      for (final pluginListUrl in pluginLists) {
        manifestSources.addAll(
          await _fetchSourcesFromPluginList(
            pluginListUrl,
            type,
            repoUrl,
            decoded['name']?.toString(),
          ),
        );
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

    final data = <String, dynamic>{
      'id': internalName,
      'name': name,
      'lang': plugin['language'],
      'iconUrl': plugin['iconUrl'],
      'version': plugin['version']?.toString(),
      'versionLast': plugin['version']?.toString(),
      'itemType': type.index,
      'isNsfw': (plugin['tvTypes'] as List?)?.contains('NSFW') ?? false,
      'apkUrl': url,
      'repo': repoUrl,
      'baseUrl': plugin['repositoryUrl'] ?? repoUrl,
      'extensionType': ExtensionType.cloudstream.index,
      'hasUpdate': false,
    };

    // best-effort apk name for installer UI
    data['apkName'] = url.split('/').last;

    final source = Source.fromJson(data)
      ..extensionType = ExtensionType.cloudstream
      ..itemType = type;

    if (repoName != null && repoName.isNotEmpty) {
      source.repo = repoName;
    }

    return source;
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
  /// 1. Invokes platform channel methods based on content type
  /// 2. Parses platform response using compute isolate for performance
  /// 3. Sets extensionType to cloudstream on all parsed Source objects
  /// 4. Updates appropriate reactive list based on content type
  /// 5. Calls checkForUpdates after updating installed list
  /// 6. Handles platform channel failures by returning empty list
  Future<List<Source>> _getInstalled(ItemType type) async {
    try {
      // Determine the platform method name based on content type (Requirements 10.2, 10.3, 10.4, 10.5, 10.6, 10.7, 10.8, 10.9, 10.10)
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

      // Load extensions from platform channel (Requirement 3.1)
      final sources = await _loadExtensions(methodName, type);

      // Update appropriate reactive list (Requirement 3.3)
      getInstalledRx(type).value = sources;

      // Check for updates (Requirement 3.4)
      await checkForUpdates(type);

      debugPrint('Loaded ${sources.length} installed $type extensions');
      return sources;
    } catch (e) {
      // Handle platform channel failures by returning empty list (Requirement 3.5, 10.6, 12.4)
      debugPrint('Error getting installed extensions for $type: $e');
      return [];
    }
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

    File? apkFile;
    try {
      // Extract package name from apkUrl (Requirement 4.2)
      final packageName = source.apkUrl!.split('/').last.replaceAll('.apk', '');
      debugPrint('Installing extension: ${source.name} ($packageName)');

      // Download APK using http.get (Requirement 4.3, 12.1)
      final response = await http.get(Uri.parse(source.apkUrl!));

      // Validate HTTP response status is 200 (Requirement 4.4, 12.2)
      if (response.statusCode != 200) {
        throw Exception('Failed to download APK: HTTP ${response.statusCode}');
      }

      debugPrint(
        'Downloaded APK for ${source.name} (${response.bodyBytes.length} bytes)',
      );

      // Save APK to temporary directory with package-based filename (Requirement 4.5, 12.3)
      final tempDir = await getTemporaryDirectory();
      apkFile = File(path.join(tempDir.path, '$packageName.apk'));
      await apkFile.writeAsBytes(response.bodyBytes);

      debugPrint('Saved APK to temporary file: ${apkFile.path}');

      // Call InstallPlugin.installApk with file path and package ID (Requirement 4.6)
      final result = await InstallPlugin.installApk(
        apkFile.path,
        appId: packageName,
      );

      // Check installation result, throw exception if failed (Requirement 4.7)
      if (result['isSuccess'] != true) {
        throw Exception(
          'Installation failed: ${result['errorMessage'] ?? 'Unknown error'}',
        );
      }

      // Remove extension from available list on success (Requirement 4.8)
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

      // Refresh installed extensions list for the content type (Requirement 4.9)
      await _getInstalled(source.itemType!);

      debugPrint('Successfully installed extension: ${source.name}');
    } catch (e) {
      // Log errors with context (Requirement 12.5)
      debugPrint('Error installing source ${source.name}: $e');
      rethrow;
    } finally {
      // Delete temporary APK file in finally block (Requirement 4.10, 12.3)
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

  @override
  Future<void> uninstallSource(Source source) async {
    // Validate Source has non-empty id (package name) (Requirements 5.1, 5.2)
    if (source.id?.trim().isEmpty ?? true) {
      throw Exception('Source ID is required for uninstallation');
    }

    try {
      debugPrint('Uninstalling extension: ${source.name} (${source.id})');

      // Check if package is installed using DeviceApps.isAppInstalled (Requirement 5.3)
      final isInstalled = await _isPackageInstalled(source.id!);

      // If not installed, call removeFromInstalledList and return successfully (Requirement 5.4)
      if (!isInstalled) {
        removeFromInstalledList(source);
        debugPrint('Package ${source.id} not installed, removed from list');
        return;
      }

      // If installed, call DeviceApps.uninstallApp to initiate uninstallation (Requirement 5.5)
      final uninstallInitiated = await FlutterDeviceApps.uninstallApp(
        source.id!,
      );

      if (!uninstallInitiated) {
        throw Exception('Failed to initiate uninstallation for ${source.id}');
      }

      debugPrint(
        'Uninstallation initiated for ${source.id}, waiting for completion...',
      );

      // Poll for up to 10 seconds (500ms intervals) to verify package removal (Requirement 5.6)
      bool packageRemoved = false;
      for (int i = 0; i < 20; i++) {
        // 20 iterations * 500ms = 10 seconds
        await Future.delayed(const Duration(milliseconds: 500));

        final stillInstalled = await _isPackageInstalled(source.id!);
        if (!stillInstalled) {
          packageRemoved = true;
          break;
        }
      }

      // Throw exception if uninstallation times out (Requirement 5.9)
      if (!packageRemoved) {
        throw Exception('Uninstallation timed out or was cancelled by user');
      }

      // Call removeFromInstalledList on successful removal (Requirement 5.7)
      removeFromInstalledList(source);

      // Add extension back to available list if it exists in availableUnmodified (Requirement 5.8)
      final unmodifiedList = getAvailableUnmodified(source.itemType!);
      final existsInAvailable = unmodifiedList.any((s) => s.id == source.id);

      if (existsInAvailable) {
        final sourceToAdd = unmodifiedList.firstWhere((s) => s.id == source.id);
        final rx = getAvailableRx(source.itemType!);
        rx.value = [...rx.value, sourceToAdd];
      }

      debugPrint('Successfully uninstalled extension: ${source.name}');
    } catch (e) {
      // Log errors with context (Requirement 12.5)
      debugPrint('Error uninstalling source ${source.name}: $e');
      rethrow;
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
}
