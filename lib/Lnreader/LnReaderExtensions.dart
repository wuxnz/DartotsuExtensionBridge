import 'dart:convert';

import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:dartotsu_extension_bridge/Mangayomi/Models/Source.dart';
import 'package:dartotsu_extension_bridge/extension_bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:isar_community/isar.dart';

/// LnReader extension manager that handles JavaScript-based light novel plugins
///
/// Unlike APK-based extensions (Aniyomi, CloudStream), LnReader plugins are
/// distributed as JavaScript source code that executes in a QuickJS runtime.
/// This class manages plugin lifecycle, repository fetching, and persistence.
class LnReaderExtensions extends Extension {
  LnReaderExtensions() {
    initialize();
  }

  bool _isHttpUrl(String value) {
    return value.startsWith('http://') || value.startsWith('https://');
  }

  // Store unmodified available list for later use (e.g., when uninstalling)
  final Rx<List<Source>> availableNovelExtensionsUnmodified = Rx([]);

  // Content type support flags (Requirement 2.2)
  @override
  bool get supportsAnime => false;

  @override
  bool get supportsManga => false;

  @override
  bool get supportsNovel => true;

  @override
  bool get supportsMovie => false;

  @override
  bool get supportsTvShow => false;

  @override
  bool get supportsCartoon => false;

  @override
  bool get supportsDocumentary => false;

  @override
  bool get supportsLivestream => false;

  @override
  bool get supportsNsfw => false;

  @override
  Future<void> initialize() async {
    if (isInitialized.value) return;

    try {
      // Load installed extensions from database
      await getInstalledNovelExtensions();

      // Load repository URLs from Isar database and fetch available extensions
      final settings = isar.bridgeSettings.getSync(26);
      if (settings != null) {
        final repos = settings.lnreaderNovelExtensions;
        if (repos.isNotEmpty) {
          await Future.wait([fetchAvailableNovelExtensions(repos)]);
        }
      }

      debugPrint('LnReader extension bridge initialized successfully');
    } catch (e) {
      // If isar is not initialized (e.g., in tests), just mark as initialized
      // without loading data (similar to CloudStream pattern)
      debugPrint('LnReader initialization error (non-fatal): $e');
    }

    isInitialized.value = true;
  }

  @override
  Future<List<Source>> fetchAvailableNovelExtensions(
    List<String>? repos,
  ) async {
    try {
      // Persist repository URLs to Isar database
      final settings = isar.bridgeSettings.getSync(26)!;
      settings.lnreaderNovelExtensions = repos ?? [];
      isar.writeTxnSync(() => isar.bridgeSettings.putSync(settings));

      // If no repositories provided, return empty list (Requirement 3.4)
      if (repos == null || repos.isEmpty) {
        availableNovelExtensions.value = [];
        debugPrint('No repositories configured for novel extensions');
        return [];
      }

      // Fetch plugins from all repositories (Requirement 3.1)
      final allSources = <Source>[];

      for (final repoUrl in repos) {
        try {
          // Network operation with error handling (Requirement 3.3)
          final response = await http.get(Uri.parse(repoUrl));

          if (response.statusCode == 200) {
            final decoded = json.decode(response.body);
            final List<dynamic> pluginsJson;
            if (decoded is List) {
              pluginsJson = decoded;
            } else if (decoded is Map<String, dynamic>) {
              final plugins = decoded['plugins'];
              pluginsJson = plugins is List ? plugins : const [];
            } else {
              pluginsJson = const [];
            }

            // Parse plugins using compute isolate for performance
            final sources = await compute(parsePlugins, {
              'pluginsJson': pluginsJson,
              'repoUrl': repoUrl,
            });

            allSources.addAll(sources);
            debugPrint(
              'Successfully fetched ${sources.length} plugins from $repoUrl',
            );
          } else {
            // Include HTTP status code in error message (Requirement 3.3)
            debugPrint(
              'Failed to fetch from $repoUrl: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          // Log network errors with context (Requirement 3.3)
          debugPrint('Error fetching from $repoUrl: $e');
          // Continue with other repositories even if one fails
        }
      }

      // Filter out already installed extensions
      final installedIds = installedNovelExtensions.value
          .map((e) => e.id)
          .toSet();
      final filteredSources = allSources
          .where((s) => !installedIds.contains(s.id))
          .toList();

      // Store unmodified list for later use (e.g., when uninstalling)
      availableNovelExtensionsUnmodified.value = filteredSources;

      // Update reactive list (Requirement 3.4)
      availableNovelExtensions.value = filteredSources;

      debugPrint(
        'Fetched ${filteredSources.length} available novel extensions',
      );
      return filteredSources;
    } catch (e) {
      // Log errors with context and preserve state (Requirement 3.3)
      debugPrint('Error in fetchAvailableNovelExtensions: $e');
      return [];
    }
  }

  /// Static method to parse plugin JSON in an isolate
  /// This is used with compute() for better performance
  /// Made public for testing purposes
  static List<Source> parsePlugins(Map<String, dynamic> data) {
    final List<dynamic> pluginsJson = data['pluginsJson'];
    final String repoUrl = data['repoUrl'];

    return pluginsJson
        .map((pluginJson) {
          try {
            if (pluginJson is! Map) {
              return Source(id: '', name: '');
            }

            final pluginMap = Map<String, dynamic>.from(pluginJson);

            // Extract plugin metadata (Requirement 3.2, 3.5)
            final id = pluginMap['id'] as String;
            final name = pluginMap['name'] as String;
            final version = pluginMap['version'] as String;
            final lang = pluginMap['lang'] as String;
            final icon = (pluginMap['iconUrl'] ?? pluginMap['icon']) as String?;
            final site = pluginMap['site'] as String;
            final codeOrUrl =
                (pluginMap['code'] ?? pluginMap['url']) as String?;

            if (icon == null || icon.trim().isEmpty) {
              return Source(id: '', name: '');
            }
            if (codeOrUrl == null || codeOrUrl.trim().isEmpty) {
              return Source(id: '', name: '');
            }

            // Create Source object with LnReader-specific fields
            return Source(
              id: id,
              name: name,
              version: version,
              lang: lang,
              iconUrl: icon,
              baseUrl: site,
              itemType: ItemType.novel,
              extensionType: ExtensionType.lnreader,
              repo: repoUrl,
              hasUpdate: false,
              // Store the compiled JavaScript code in apkUrl field temporarily
              // This will be moved to a dedicated sourceCode field in task 5
              apkUrl: codeOrUrl,
            );
          } catch (e) {
            debugPrint('Failed to parse plugin: $e');
            // Return a placeholder that will be filtered out
            return Source(id: '', name: '');
          }
        })
        .where((s) => s.id?.isNotEmpty ?? false)
        .toList();
  }

  @override
  Future<List<Source>> getInstalledNovelExtensions() async {
    try {
      final installed = await isar.mSources
          .filter()
          .itemTypeEqualTo(ItemType.novel)
          .sourceCodeLanguageEqualTo(SourceCodeLanguage.lnreader)
          .isAddedEqualTo(true)
          .findAll();

      final sources = installed
          .where((entry) => (entry.sourceId ?? '').trim().isNotEmpty)
          .map(
            (entry) => Source(
              id: entry.sourceId,
              name: entry.name,
              version: entry.version,
              versionLast: entry.versionLast,
              lang: entry.lang,
              iconUrl: entry.iconUrl,
              baseUrl: entry.baseUrl,
              apkUrl: entry.sourceCode,
              repo: entry.repo,
              itemType: ItemType.novel,
              extensionType: ExtensionType.lnreader,
              isNsfw: entry.isNsfw,
              hasUpdate: false,
            ),
          )
          .toList();

      installedNovelExtensions.value = sources;
      return sources;
    } catch (e) {
      debugPrint('Error loading installed LnReader plugins: $e');
      return installedNovelExtensions.value;
    }
  }

  @override
  Future<void> installSource(Source source) async {
    try {
      // Validate source has required fields (Requirement 4.1)
      if (source.id?.trim().isEmpty ?? true) {
        throw Exception('Plugin ID is required for installation');
      }

      final payload = source.apkUrl?.trim() ?? '';
      if (payload.isEmpty) {
        throw Exception('Plugin source code is required for installation');
      }

      String? sourceCodeUrl;
      String sourceCode;
      if (_isHttpUrl(payload)) {
        sourceCodeUrl = payload;
        final response = await http.get(Uri.parse(payload));
        if (response.statusCode != 200) {
          throw Exception(
            'Failed to fetch plugin source code: HTTP ${response.statusCode}',
          );
        }
        sourceCode = response.body;
      } else {
        sourceCode = payload;
      }

      debugPrint('Installing LnReader plugin: ${source.name} (${source.id})');

      // Check if plugin is already installed (Requirement 4.3)
      final alreadyInstalled = installedNovelExtensions.value.any(
        (s) => s.id == source.id,
      );

      if (alreadyInstalled) {
        debugPrint('Plugin ${source.id} is already installed, skipping');
        return; // Prevent duplicate installations
      }

      // Create MSource object with plugin data (Requirement 4.1, 4.5)
      final mSource = MSource(
        sourceId: source.id,
        pluginId: source.id, // Store plugin identifier
        name: source.name,
        version: source.version,
        lang: source.lang,
        iconUrl: source.iconUrl,
        baseUrl: source.baseUrl,
        sourceCode: sourceCode,
        sourceCodeUrl: sourceCodeUrl,
        itemType: ItemType.novel,
        isAdded: true,
        isActive: true,
        repo: source.repo,
        sourceCodeLanguage: SourceCodeLanguage.lnreader,
      );

      // Store plugin in Isar database (Requirement 4.1)
      await isar.writeTxnSync(() async => isar.mSources.putSync(mSource));

      debugPrint('Successfully stored plugin ${source.id} in database');

      // Add plugin to installed list (Requirement 4.2)
      final currentInstalled = List<Source>.from(
        installedNovelExtensions.value,
      );

      final storedSource = Source(
        id: source.id,
        name: source.name,
        version: source.version,
        lang: source.lang,
        iconUrl: source.iconUrl,
        baseUrl: source.baseUrl,
        apkUrl: sourceCode,
        repo: source.repo,
        itemType: ItemType.novel,
        extensionType: ExtensionType.lnreader,
        hasUpdate: false,
      );
      currentInstalled.add(storedSource);
      installedNovelExtensions.value = currentInstalled;

      // Remove from available list
      final currentAvailable = availableNovelExtensions.value
          .where((s) => s.id != source.id)
          .toList();
      availableNovelExtensions.value = currentAvailable;

      // Also remove from unmodified list
      availableNovelExtensionsUnmodified.value =
          availableNovelExtensionsUnmodified.value
              .where((s) => s.id != source.id)
              .toList();

      debugPrint('Successfully installed plugin: ${source.name}');
    } catch (e) {
      // Handle installation errors (Requirement 4.4)
      debugPrint('Error installing plugin ${source.name}: $e');
      rethrow;
    }
  }

  @override
  Future<void> uninstallSource(Source source) async {
    try {
      // Validate source has required fields (Requirement 12.1)
      if (source.id?.trim().isEmpty ?? true) {
        throw Exception('Plugin ID is required for uninstallation');
      }

      debugPrint('Uninstalling LnReader plugin: ${source.name} (${source.id})');

      // Remove plugin from database (Requirement 12.2)
      // We need to find and delete the MSource entry from the database
      // Since the Isar query API has limitations in this context, we'll use a transaction
      // to query and delete in one operation
      try {
        await isar.writeTxn(() async {
          // Query for the plugin by sourceId
          final mSource = await isar.mSources
              .filter()
              .sourceIdEqualTo(source.id)
              .findFirst();

          if (mSource != null && mSource.id != null) {
            // Delete the found entry
            await isar.mSources.delete(mSource.id!);
            debugPrint(
              'Successfully removed plugin ${source.id} from database',
            );
          } else {
            debugPrint('Plugin ${source.id} not found in database');
          }
        });
      } catch (e) {
        debugPrint('Error removing plugin from database: $e');
        // Continue with list removal even if database deletion fails
      }

      // Remove plugin from installed list (Requirement 12.1)
      final currentInstalled = installedNovelExtensions.value
          .where((s) => s.id != source.id)
          .toList();
      installedNovelExtensions.value = currentInstalled;

      // Add back to available list if it exists in unmodified available list
      final availablePlugin = availableNovelExtensionsUnmodified.value
          .firstWhere((s) => s.id == source.id, orElse: () => Source(id: ''));

      if (availablePlugin.id?.isNotEmpty ?? false) {
        final currentAvailable = List<Source>.from(
          availableNovelExtensions.value,
        );
        currentAvailable.add(availablePlugin);
        availableNovelExtensions.value = currentAvailable;
      }

      // Update UI reactively (Requirement 12.4)
      debugPrint('Successfully uninstalled plugin: ${source.name}');
    } catch (e) {
      // Handle uninstallation errors (Requirement 12.3)
      debugPrint('Error uninstalling plugin ${source.name}: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateSource(Source source) async {
    try {
      // Validate source has required fields (Requirement 11.1)
      if (source.id?.trim().isEmpty ?? true) {
        throw Exception('Plugin ID is required for update');
      }

      debugPrint('Updating LnReader plugin: ${source.name} (${source.id})');

      // Find the installed plugin to preserve its state in case of failure (Requirement 11.3)
      final installedPlugin = installedNovelExtensions.value.firstWhere(
        (s) => s.id == source.id,
        orElse: () => Source(id: '', name: ''),
      );

      if (installedPlugin.id?.isEmpty ?? true) {
        throw Exception('Plugin ${source.id} is not installed');
      }

      // Fetch latest plugin version from repository (Requirement 11.1)
      // The source parameter should already contain the latest version data from checkForUpdates
      // But we need to ensure we have the latest source code
      String? latestSourceCode = (source.apkName?.trim().isNotEmpty ?? false)
          ? source.apkName?.trim()
          : source.apkUrl?.trim();
      String? latestVersion = source.versionLast ?? source.version;
      String? latestSourceCodeUrl;

      if (latestSourceCode?.trim().isNotEmpty ?? false) {
        if (_isHttpUrl(latestSourceCode!)) {
          latestSourceCodeUrl = latestSourceCode;
          final response = await http.get(Uri.parse(latestSourceCode));
          if (response.statusCode != 200) {
            throw Exception(
              'Failed to fetch plugin source code: HTTP ${response.statusCode}',
            );
          }
          latestSourceCode = response.body;
        }
      }

      // If source code is not provided, we need to fetch it from the repository
      if (latestSourceCode?.trim().isEmpty ?? true) {
        // Fetch from repository
        if (source.repo?.trim().isEmpty ?? true) {
          throw Exception('Repository URL is required to fetch latest version');
        }

        try {
          final response = await http.get(Uri.parse(source.repo!));
          if (response.statusCode == 200) {
            final decoded = json.decode(response.body);
            final List<dynamic> pluginsJson;
            if (decoded is List) {
              pluginsJson = decoded;
            } else if (decoded is Map<String, dynamic>) {
              final plugins = decoded['plugins'];
              pluginsJson = plugins is List ? plugins : const [];
            } else {
              pluginsJson = const [];
            }

            // Find the matching plugin
            final pluginJson = pluginsJson
                .whereType<Map<String, dynamic>>()
                .cast<Map<String, dynamic>?>()
                .firstWhere((p) => p?['id'] == source.id, orElse: () => null);

            if (pluginJson != null) {
              final codeOrUrl =
                  (pluginJson['code'] ?? pluginJson['url']) as String?;
              latestSourceCode = codeOrUrl;
              latestVersion = pluginJson['version'] as String?;

              if (latestSourceCode?.trim().isNotEmpty ?? false) {
                if (_isHttpUrl(latestSourceCode!)) {
                  latestSourceCodeUrl = latestSourceCode;
                  final codeResponse = await http.get(
                    Uri.parse(latestSourceCode),
                  );
                  if (codeResponse.statusCode != 200) {
                    throw Exception(
                      'Failed to fetch plugin source code: HTTP ${codeResponse.statusCode}',
                    );
                  }
                  latestSourceCode = codeResponse.body;
                }
              }
            } else {
              throw Exception('Plugin ${source.id} not found in repository');
            }
          } else {
            throw Exception(
              'Failed to fetch from repository: HTTP ${response.statusCode}',
            );
          }
        } catch (e) {
          // Preserve existing plugin on failure (Requirement 11.3)
          debugPrint('Error fetching latest version from repository: $e');
          rethrow;
        }
      }

      if (latestSourceCode?.trim().isEmpty ?? true) {
        throw Exception('Latest source code not available for update');
      }

      debugPrint(
        'Updating plugin ${source.id} from ${installedPlugin.version} to $latestVersion',
      );

      // Create updated MSource object (Requirement 11.2)
      final updatedMSource = MSource(
        sourceId: source.id,
        pluginId: source.id,
        name: source.name ?? installedPlugin.name,
        version: latestVersion,
        lang: source.lang ?? installedPlugin.lang,
        iconUrl: source.iconUrl ?? installedPlugin.iconUrl,
        baseUrl: source.baseUrl ?? installedPlugin.baseUrl,
        sourceCode: latestSourceCode,
        sourceCodeUrl: latestSourceCodeUrl,
        itemType: ItemType.novel,
        isAdded: true,
        isActive: true,
        repo: source.repo ?? installedPlugin.repo,
        sourceCodeLanguage: SourceCodeLanguage.lnreader,
      );

      // Replace old plugin data with new version in database (Requirement 11.2)
      // Use putSync which will insert the new version
      await isar.writeTxnSync(
        () async => isar.mSources.putSync(updatedMSource),
      );

      debugPrint('Successfully updated plugin ${source.id} in database');

      // Update installed list with new version (Requirement 11.2)
      final updatedList = installedNovelExtensions.value.map((s) {
        if (s.id == source.id) {
          // Create updated source with new version and clear hasUpdate flag (Requirement 11.4)
          return Source(
            id: s.id,
            name: source.name ?? s.name,
            version: latestVersion,
            lang: source.lang ?? s.lang,
            iconUrl: source.iconUrl ?? s.iconUrl,
            baseUrl: source.baseUrl ?? s.baseUrl,
            apkUrl: latestSourceCode,
            apkName: '',
            repo: source.repo ?? s.repo,
            itemType: ItemType.novel,
            extensionType: ExtensionType.lnreader,
            hasUpdate: false, // Clear update flag (Requirement 11.4)
          );
        }
        return s;
      }).toList();

      installedNovelExtensions.value = updatedList;

      debugPrint('Successfully updated plugin: ${source.name}');
    } catch (e) {
      // Preserve existing plugin on failure (Requirement 11.3)
      debugPrint('Error updating plugin ${source.name}: $e');
      rethrow;
    }
  }

  /// Check for updates for installed extensions (Requirement 10.1, 10.2, 10.3, 10.4)
  ///
  /// Compares installed plugin versions with available plugin versions and sets
  /// the hasUpdate flag on plugins that have newer versions available.
  ///
  /// This method:
  /// 1. Creates a map of available plugins indexed by plugin ID
  /// 2. Iterates through installed plugins
  /// 3. Compares versions using compareVersions()
  /// 4. Sets hasUpdate flag when a newer version is available
  /// 5. Handles version comparison errors gracefully
  Future<void> checkForUpdates(ItemType type) async {
    try {
      // Only check for novel type (LnReader only supports novels)
      if (type != ItemType.novel) {
        return;
      }

      // Build map of available extensions indexed by plugin ID (Requirement 10.1)
      final availableMap = {
        for (var s in availableNovelExtensions.value) s.id: s,
      };

      // Also include unmodified available list (for plugins that were filtered out)
      for (var s in availableNovelExtensionsUnmodified.value) {
        if (s.id != null) {
          availableMap[s.id] = s;
        }
      }

      // Iterate through installed extensions and compare versions (Requirement 10.1)
      final updated = installedNovelExtensions.value.map((installed) {
        final available = availableMap[installed.id];

        // Check if there's a matching available plugin with a newer version
        if (available != null &&
            installed.version != null &&
            available.version != null) {
          try {
            // Compare versions (Requirement 10.2)
            final comparison = compareVersions(
              installed.version!,
              available.version!,
            );

            // Set hasUpdate flag if available version is newer (Requirement 10.2)
            if (comparison < 0) {
              debugPrint(
                'Update available for ${installed.name}: ${installed.version} -> ${available.version}',
              );
              return Source(
                id: installed.id,
                name: installed.name,
                version: installed.version,
                versionLast: available.version,
                lang: installed.lang,
                iconUrl: installed.iconUrl,
                baseUrl: installed.baseUrl,
                apkUrl: installed.apkUrl,
                apkName: available.apkUrl,
                repo: installed.repo,
                itemType: ItemType.novel,
                extensionType: ExtensionType.lnreader,
                hasUpdate: true,
              );
            } else {
              // No update available (Requirement 10.3)
              return installed
                ..hasUpdate = false
                ..versionLast = null
                ..apkName = '';
            }
          } catch (e) {
            // Handle version comparison errors gracefully (Requirement 10.4)
            debugPrint('Error comparing versions for ${installed.name}: $e');
            return installed..hasUpdate = false;
          }
        }

        // No matching available plugin or missing version info
        return installed
          ..hasUpdate = false
          ..versionLast = null
          ..apkName = '';
      }).toList();

      // Update the reactive list
      installedNovelExtensions.value = updated;

      // Log summary
      final updatesCount = updated.where((s) => s.hasUpdate == true).length;
      if (updatesCount > 0) {
        debugPrint('Found $updatesCount updates for novel extensions');
      } else {
        debugPrint('No updates found for novel extensions');
      }
    } catch (e) {
      // Handle errors gracefully (Requirement 10.4)
      debugPrint('Error checking for updates for $type: $e');
    }
  }
}
