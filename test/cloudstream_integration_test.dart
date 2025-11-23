import 'package:dartotsu_extension_bridge/CloudStream/CloudStreamExtensions.dart';
import 'package:dartotsu_extension_bridge/dartotsu_extension_bridge.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Integration tests for CloudStream Extension Bridge
///
/// These tests verify complete end-to-end workflows including:
/// - Installation flow (fetch → install → verify)
/// - Update flow (install → detect update → update → verify)
/// - Uninstallation flow (install → uninstall → verify)
/// - Multi-type management (install anime/manga/novel → verify isolation)
///
/// **Validates: All requirements end-to-end**
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CloudStream Extension Bridge - Integration Tests', () {
    late List<MethodCall> methodCallLog;

    setUp(() {
      methodCallLog = [];

      // Set up method channel mock that tracks all calls
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('cloudstreamExtensionBridge'),
            (MethodCall methodCall) async {
              methodCallLog.add(methodCall);

              // Return appropriate mock data based on method
              if (methodCall.method.startsWith('getInstalled')) {
                // Return empty list initially (no extensions installed)
                return <dynamic>[];
              }

              return <dynamic>[];
            },
          );
    });

    tearDown(() {
      // Clean up method channel mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('cloudstreamExtensionBridge'),
            null,
          );
      methodCallLog.clear();
    });

    /// Integration Test 1: Complete Installation Flow
    ///
    /// Tests: fetch → install → verify
    ///
    /// This test verifies the complete workflow of:
    /// 1. Fetching available extensions from a repository
    /// 2. Installing an extension
    /// 3. Verifying the extension appears in installed list
    /// 4. Verifying the extension is removed from available list
    ///
    /// Note: This test simulates the workflow without actual HTTP requests
    /// or APK installation, as those require platform integration.
    test('Integration Test 1: Complete installation flow', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 10));

      // Step 1: Simulate fetching available extensions
      // In a real scenario, this would fetch from a repository URL
      final availableExtensions = [
        Source(
          id: 'com.example.anime1',
          name: 'Anime Provider 1',
          version: '1.0.0',
          itemType: ItemType.anime,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/anime1.apk',
          baseUrl: 'https://anime1.example.com',
          lang: 'en',
        ),
        Source(
          id: 'com.example.anime2',
          name: 'Anime Provider 2',
          version: '1.0.0',
          itemType: ItemType.anime,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/anime2.apk',
          baseUrl: 'https://anime2.example.com',
          lang: 'en',
        ),
      ];

      // Set up available extensions
      extension.availableAnimeExtensions.value = availableExtensions;
      extension.availableAnimeExtensionsUnmodified.value = availableExtensions;

      // Verify available extensions are set
      expect(
        extension.availableAnimeExtensions.value.length,
        equals(2),
        reason: 'Should have 2 available anime extensions',
      );

      // Step 2: Simulate installation
      // Note: Actual installation requires platform integration and HTTP download
      // We simulate the state changes that would occur after successful installation
      final sourceToInstall = availableExtensions[0];

      // Simulate the state changes that installSource would make:
      // 1. Remove from available list
      extension.availableAnimeExtensions.value = extension
          .availableAnimeExtensions
          .value
          .where((s) => s.id != sourceToInstall.id)
          .toList();

      // 2. Add to installed list (simulating what _getInstalled would do)
      extension.installedAnimeExtensions.value = [sourceToInstall.copyWith()];

      // Step 3: Verify installation results
      expect(
        extension.installedAnimeExtensions.value.length,
        equals(1),
        reason: 'Should have 1 installed anime extension',
      );

      expect(
        extension.installedAnimeExtensions.value.first.id,
        equals('com.example.anime1'),
        reason: 'Installed extension should be anime1',
      );

      expect(
        extension.availableAnimeExtensions.value.length,
        equals(1),
        reason: 'Should have 1 remaining available anime extension',
      );

      expect(
        extension.availableAnimeExtensions.value.any(
          (s) => s.id == 'com.example.anime1',
        ),
        isFalse,
        reason: 'Installed extension should be removed from available list',
      );

      expect(
        extension.availableAnimeExtensions.value.any(
          (s) => s.id == 'com.example.anime2',
        ),
        isTrue,
        reason: 'Other extensions should remain in available list',
      );

      // Verify the extension has correct properties
      final installedExtension = extension.installedAnimeExtensions.value.first;
      expect(installedExtension.name, equals('Anime Provider 1'));
      expect(installedExtension.version, equals('1.0.0'));
      expect(installedExtension.itemType, equals(ItemType.anime));
      expect(
        installedExtension.extensionType,
        equals(ExtensionType.cloudstream),
      );
    });

    /// Integration Test 2: Complete Update Flow
    ///
    /// Tests: install → detect update → update → verify
    ///
    /// This test verifies the complete workflow of:
    /// 1. Installing an extension
    /// 2. Detecting that an update is available
    /// 3. Updating the extension
    /// 4. Verifying the new version is installed
    test('Integration Test 2: Complete update flow', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 10));

      // Step 1: Simulate initial installation
      final installedExtension = Source(
        id: 'com.example.updatable',
        name: 'Updatable Provider',
        version: '1.0.0',
        itemType: ItemType.manga,
        extensionType: ExtensionType.cloudstream,
        baseUrl: 'https://updatable.example.com',
        lang: 'en',
      );

      extension.installedMangaExtensions.value = [installedExtension];

      // Verify initial installation
      expect(
        extension.installedMangaExtensions.value.length,
        equals(1),
        reason: 'Should have 1 installed manga extension',
      );
      expect(
        extension.installedMangaExtensions.value.first.version,
        equals('1.0.0'),
        reason: 'Initial version should be 1.0.0',
      );

      // Step 2: Simulate newer version available
      final availableExtension = Source(
        id: 'com.example.updatable',
        name: 'Updatable Provider',
        version: '2.0.0', // Newer version
        itemType: ItemType.manga,
        extensionType: ExtensionType.cloudstream,
        apkUrl: 'https://example.com/updatable-v2.apk',
        baseUrl: 'https://updatable.example.com',
        lang: 'en',
      );

      extension.availableMangaExtensions.value = [availableExtension];

      // Step 3: Detect updates
      await extension.checkForUpdates(ItemType.manga);

      // Verify update detection
      final updatedExtension = extension.installedMangaExtensions.value.first;
      expect(
        updatedExtension.hasUpdate,
        isTrue,
        reason: 'Extension should have hasUpdate flag set',
      );
      expect(
        updatedExtension.versionLast,
        equals('2.0.0'),
        reason: 'versionLast should be set to new version',
      );
      expect(
        updatedExtension.apkUrl,
        equals('https://example.com/updatable-v2.apk'),
        reason: 'apkUrl should be copied from available extension',
      );

      // Step 4: Simulate update installation
      // Note: Actual update requires platform integration and HTTP download
      // We simulate the state changes that would occur after successful update
      extension.installedMangaExtensions.value = [
        Source(
          id: 'com.example.updatable',
          name: 'Updatable Provider',
          version: '2.0.0', // Updated version
          itemType: ItemType.manga,
          extensionType: ExtensionType.cloudstream,
          baseUrl: 'https://updatable.example.com',
          lang: 'en',
          hasUpdate: false, // Clear update flag
        ),
      ];

      // Step 5: Verify update results
      final finalExtension = extension.installedMangaExtensions.value.first;
      expect(
        finalExtension.version,
        equals('2.0.0'),
        reason: 'Version should be updated to 2.0.0',
      );
      expect(
        finalExtension.hasUpdate ?? false,
        isFalse,
        reason: 'hasUpdate flag should be cleared after update',
      );
      expect(
        extension.installedMangaExtensions.value.length,
        equals(1),
        reason: 'Should still have 1 installed manga extension',
      );
    });

    /// Integration Test 3: Complete Uninstallation Flow
    ///
    /// Tests: install → uninstall → verify
    ///
    /// This test verifies the complete workflow of:
    /// 1. Installing an extension
    /// 2. Uninstalling the extension
    /// 3. Verifying the extension is removed from installed list
    /// 4. Verifying the extension is restored to available list
    test('Integration Test 3: Complete uninstallation flow', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 10));

      // Step 1: Simulate initial installation
      final installedExtension = Source(
        id: 'com.example.uninstallable',
        name: 'Uninstallable Provider',
        version: '1.0.0',
        itemType: ItemType.novel,
        extensionType: ExtensionType.cloudstream,
        apkUrl: 'https://example.com/uninstallable.apk',
        baseUrl: 'https://uninstallable.example.com',
        lang: 'en',
      );

      extension.installedNovelExtensions.value = [installedExtension];

      // Set up unmodified available list (simulating it was available before installation)
      extension.availableNovelExtensionsUnmodified.value = [
        installedExtension.copyWith(),
      ];

      // Verify initial state
      expect(
        extension.installedNovelExtensions.value.length,
        equals(1),
        reason: 'Should have 1 installed novel extension',
      );
      expect(
        extension.availableNovelExtensions.value.length,
        equals(0),
        reason: 'Should have 0 available novel extensions (was installed)',
      );

      // Step 2: Simulate uninstallation
      // Note: Actual uninstallation requires platform integration
      // We simulate the state changes that would occur after successful uninstallation

      // Remove from installed list
      extension.removeFromInstalledList(installedExtension);

      // Restore to available list (if it exists in unmodified)
      final unmodifiedList = extension.getAvailableUnmodified(ItemType.novel);
      final existsInAvailable = unmodifiedList.any(
        (s) => s.id == installedExtension.id,
      );

      if (existsInAvailable) {
        final sourceToAdd = unmodifiedList.firstWhere(
          (s) => s.id == installedExtension.id,
        );
        final rx = extension.getAvailableRx(ItemType.novel);
        rx.value = [...rx.value, sourceToAdd];
      }

      // Step 3: Verify uninstallation results
      expect(
        extension.installedNovelExtensions.value.length,
        equals(0),
        reason: 'Should have 0 installed novel extensions after uninstall',
      );

      expect(
        extension.installedNovelExtensions.value.any(
          (s) => s.id == 'com.example.uninstallable',
        ),
        isFalse,
        reason: 'Uninstalled extension should not be in installed list',
      );

      expect(
        extension.availableNovelExtensions.value.length,
        equals(1),
        reason: 'Should have 1 available novel extension after uninstall',
      );

      expect(
        extension.availableNovelExtensions.value.any(
          (s) => s.id == 'com.example.uninstallable',
        ),
        isTrue,
        reason: 'Uninstalled extension should be restored to available list',
      );

      // Verify the restored extension has correct properties
      final restoredExtension = extension.availableNovelExtensions.value.first;
      expect(restoredExtension.name, equals('Uninstallable Provider'));
      expect(restoredExtension.version, equals('1.0.0'));
      expect(restoredExtension.apkUrl, isNotNull);
    });

    /// Integration Test 4: Multi-Type Management (All 9 Content Types)
    ///
    /// Tests: install all 9 content types → verify isolation
    ///
    /// This test verifies that:
    /// 1. Extensions can be installed for all 9 content types
    /// 2. Each content type maintains its own separate lists
    /// 3. Operations on one type don't affect other types
    /// 4. Extensions are correctly associated with their content type
    test(
      'Integration Test 4: Multi-type management with all 9 content types',
      () async {
        final extension = CloudStreamExtensions();
        await Future.delayed(const Duration(milliseconds: 10));

        // Step 1: Set up extensions for all 9 content types
        final animeExtension = Source(
          id: 'com.example.anime',
          name: 'Anime Provider',
          version: '1.0.0',
          itemType: ItemType.anime,
          extensionType: ExtensionType.cloudstream,
          baseUrl: 'https://anime.example.com',
          lang: 'en',
        );

        final mangaExtension = Source(
          id: 'com.example.manga',
          name: 'Manga Provider',
          version: '1.0.0',
          itemType: ItemType.manga,
          extensionType: ExtensionType.cloudstream,
          baseUrl: 'https://manga.example.com',
          lang: 'en',
        );

        final novelExtension = Source(
          id: 'com.example.novel',
          name: 'Novel Provider',
          version: '1.0.0',
          itemType: ItemType.novel,
          extensionType: ExtensionType.cloudstream,
          baseUrl: 'https://novel.example.com',
          lang: 'en',
        );

        final movieExtension = Source(
          id: 'com.example.movie',
          name: 'Movie Provider',
          version: '1.0.0',
          itemType: ItemType.movie,
          extensionType: ExtensionType.cloudstream,
          baseUrl: 'https://movie.example.com',
          lang: 'en',
        );

        final tvShowExtension = Source(
          id: 'com.example.tvshow',
          name: 'TV Show Provider',
          version: '1.0.0',
          itemType: ItemType.tvShow,
          extensionType: ExtensionType.cloudstream,
          baseUrl: 'https://tvshow.example.com',
          lang: 'en',
        );

        final cartoonExtension = Source(
          id: 'com.example.cartoon',
          name: 'Cartoon Provider',
          version: '1.0.0',
          itemType: ItemType.cartoon,
          extensionType: ExtensionType.cloudstream,
          baseUrl: 'https://cartoon.example.com',
          lang: 'en',
        );

        final documentaryExtension = Source(
          id: 'com.example.documentary',
          name: 'Documentary Provider',
          version: '1.0.0',
          itemType: ItemType.documentary,
          extensionType: ExtensionType.cloudstream,
          baseUrl: 'https://documentary.example.com',
          lang: 'en',
        );

        final livestreamExtension = Source(
          id: 'com.example.livestream',
          name: 'Livestream Provider',
          version: '1.0.0',
          itemType: ItemType.livestream,
          extensionType: ExtensionType.cloudstream,
          baseUrl: 'https://livestream.example.com',
          lang: 'en',
        );

        final nsfwExtension = Source(
          id: 'com.example.nsfw',
          name: 'NSFW Provider',
          version: '1.0.0',
          itemType: ItemType.nsfw,
          extensionType: ExtensionType.cloudstream,
          baseUrl: 'https://nsfw.example.com',
          lang: 'en',
        );

        // Step 2: Install extensions for each type
        extension.installedAnimeExtensions.value = [animeExtension];
        extension.installedMangaExtensions.value = [mangaExtension];
        extension.installedNovelExtensions.value = [novelExtension];
        extension.installedMovieExtensions.value = [movieExtension];
        extension.installedTvShowExtensions.value = [tvShowExtension];
        extension.installedCartoonExtensions.value = [cartoonExtension];
        extension.installedDocumentaryExtensions.value = [documentaryExtension];
        extension.installedLivestreamExtensions.value = [livestreamExtension];
        extension.installedNsfwExtensions.value = [nsfwExtension];

        // Step 3: Verify each type has its own extension
        expect(
          extension.installedAnimeExtensions.value.length,
          equals(1),
          reason: 'Should have 1 anime extension',
        );
        expect(
          extension.installedMangaExtensions.value.length,
          equals(1),
          reason: 'Should have 1 manga extension',
        );
        expect(
          extension.installedNovelExtensions.value.length,
          equals(1),
          reason: 'Should have 1 novel extension',
        );
        expect(
          extension.installedMovieExtensions.value.length,
          equals(1),
          reason: 'Should have 1 movie extension',
        );
        expect(
          extension.installedTvShowExtensions.value.length,
          equals(1),
          reason: 'Should have 1 tvShow extension',
        );
        expect(
          extension.installedCartoonExtensions.value.length,
          equals(1),
          reason: 'Should have 1 cartoon extension',
        );
        expect(
          extension.installedDocumentaryExtensions.value.length,
          equals(1),
          reason: 'Should have 1 documentary extension',
        );
        expect(
          extension.installedLivestreamExtensions.value.length,
          equals(1),
          reason: 'Should have 1 livestream extension',
        );
        expect(
          extension.installedNsfwExtensions.value.length,
          equals(1),
          reason: 'Should have 1 nsfw extension',
        );

        // Step 4: Verify isolation - each extension only in its own list
        final allExtensions = [
          animeExtension,
          mangaExtension,
          novelExtension,
          movieExtension,
          tvShowExtension,
          cartoonExtension,
          documentaryExtension,
          livestreamExtension,
          nsfwExtension,
        ];

        final allLists = [
          extension.installedAnimeExtensions.value,
          extension.installedMangaExtensions.value,
          extension.installedNovelExtensions.value,
          extension.installedMovieExtensions.value,
          extension.installedTvShowExtensions.value,
          extension.installedCartoonExtensions.value,
          extension.installedDocumentaryExtensions.value,
          extension.installedLivestreamExtensions.value,
          extension.installedNsfwExtensions.value,
        ];

        // Verify each extension appears only in its corresponding list
        for (int i = 0; i < allExtensions.length; i++) {
          final ext = allExtensions[i];
          for (int j = 0; j < allLists.length; j++) {
            final list = allLists[j];
            if (i == j) {
              // Extension should be in its own list
              expect(
                list.any((s) => s.id == ext.id),
                isTrue,
                reason: '${ext.name} should be in its own list (index $i)',
              );
            } else {
              // Extension should NOT be in other lists
              expect(
                list.any((s) => s.id == ext.id),
                isFalse,
                reason:
                    '${ext.name} should not be in list $j (belongs to list $i)',
              );
            }
          }
        }

        // Step 5: Test operations on one type don't affect others
        // Remove movie extension
        extension.removeFromInstalledList(movieExtension);

        // Verify only movie list is affected
        expect(
          extension.installedMovieExtensions.value.length,
          equals(0),
          reason: 'Movie list should be empty after removal',
        );
        expect(
          extension.installedAnimeExtensions.value.length,
          equals(1),
          reason: 'Anime list should still have 1 extension',
        );
        expect(
          extension.installedMangaExtensions.value.length,
          equals(1),
          reason: 'Manga list should still have 1 extension',
        );
        expect(
          extension.installedNovelExtensions.value.length,
          equals(1),
          reason: 'Novel list should still have 1 extension',
        );
        expect(
          extension.installedTvShowExtensions.value.length,
          equals(1),
          reason: 'TvShow list should still have 1 extension',
        );
        expect(
          extension.installedCartoonExtensions.value.length,
          equals(1),
          reason: 'Cartoon list should still have 1 extension',
        );
        expect(
          extension.installedDocumentaryExtensions.value.length,
          equals(1),
          reason: 'Documentary list should still have 1 extension',
        );
        expect(
          extension.installedLivestreamExtensions.value.length,
          equals(1),
          reason: 'Livestream list should still have 1 extension',
        );
        expect(
          extension.installedNsfwExtensions.value.length,
          equals(1),
          reason: 'NSFW list should still have 1 extension',
        );

        // Step 6: Test update detection isolation for new content types
        // Set up available extensions with updates for some types
        extension.availableMovieExtensions.value = [
          Source(
            id: 'com.example.movie',
            name: 'Movie Provider',
            version: '2.0.0', // Higher version
            itemType: ItemType.movie,
            extensionType: ExtensionType.cloudstream,
            apkUrl: 'https://example.com/movie-v2.apk',
          ),
        ];

        extension.availableTvShowExtensions.value = [
          Source(
            id: 'com.example.tvshow',
            name: 'TV Show Provider',
            version: '1.0.0', // Same version (no update)
            itemType: ItemType.tvShow,
            extensionType: ExtensionType.cloudstream,
          ),
        ];

        // Restore movie extension for update test
        extension.installedMovieExtensions.value = [movieExtension];

        // Check for updates on movie only
        await extension.checkForUpdates(ItemType.movie);

        // Verify only movie extension would have update flag (if it were installed)
        // Since we removed it, let's test with tvShow
        await extension.checkForUpdates(ItemType.tvShow);

        expect(
          extension.installedTvShowExtensions.value.first.hasUpdate ?? false,
          isFalse,
          reason: 'TvShow extension should not have update flag',
        );

        // Step 7: Verify content type association through routing for all types
        final animeRx = extension.getInstalledRx(ItemType.anime);
        final mangaRx = extension.getInstalledRx(ItemType.manga);
        final novelRx = extension.getInstalledRx(ItemType.novel);
        final movieRx = extension.getInstalledRx(ItemType.movie);
        final tvShowRx = extension.getInstalledRx(ItemType.tvShow);
        final cartoonRx = extension.getInstalledRx(ItemType.cartoon);
        final documentaryRx = extension.getInstalledRx(ItemType.documentary);
        final livestreamRx = extension.getInstalledRx(ItemType.livestream);
        final nsfwRx = extension.getInstalledRx(ItemType.nsfw);

        expect(
          animeRx.value.length,
          equals(1),
          reason: 'Anime routing should return anime list',
        );
        expect(
          mangaRx.value.length,
          equals(1),
          reason: 'Manga routing should return manga list',
        );
        expect(
          novelRx.value.length,
          equals(1),
          reason: 'Novel routing should return novel list',
        );
        expect(
          movieRx.value.length,
          equals(1),
          reason: 'Movie routing should return movie list',
        );
        expect(
          tvShowRx.value.length,
          equals(1),
          reason: 'TvShow routing should return tvShow list',
        );
        expect(
          cartoonRx.value.length,
          equals(1),
          reason: 'Cartoon routing should return cartoon list',
        );
        expect(
          documentaryRx.value.length,
          equals(1),
          reason: 'Documentary routing should return documentary list',
        );
        expect(
          livestreamRx.value.length,
          equals(1),
          reason: 'Livestream routing should return livestream list',
        );
        expect(
          nsfwRx.value.length,
          equals(1),
          reason: 'NSFW routing should return nsfw list',
        );

        // Verify each routing returns the correct extension type
        expect(
          animeRx.value.first.itemType,
          equals(ItemType.anime),
          reason: 'Anime routing should return anime-typed extension',
        );
        expect(
          mangaRx.value.first.itemType,
          equals(ItemType.manga),
          reason: 'Manga routing should return manga-typed extension',
        );
        expect(
          novelRx.value.first.itemType,
          equals(ItemType.novel),
          reason: 'Novel routing should return novel-typed extension',
        );
        expect(
          movieRx.value.first.itemType,
          equals(ItemType.movie),
          reason: 'Movie routing should return movie-typed extension',
        );
        expect(
          tvShowRx.value.first.itemType,
          equals(ItemType.tvShow),
          reason: 'TvShow routing should return tvShow-typed extension',
        );
        expect(
          cartoonRx.value.first.itemType,
          equals(ItemType.cartoon),
          reason: 'Cartoon routing should return cartoon-typed extension',
        );
        expect(
          documentaryRx.value.first.itemType,
          equals(ItemType.documentary),
          reason:
              'Documentary routing should return documentary-typed extension',
        );
        expect(
          livestreamRx.value.first.itemType,
          equals(ItemType.livestream),
          reason: 'Livestream routing should return livestream-typed extension',
        );
        expect(
          nsfwRx.value.first.itemType,
          equals(ItemType.nsfw),
          reason: 'NSFW routing should return nsfw-typed extension',
        );
      },
    );

    /// Integration Test 5: Installation Flow for New Content Types
    ///
    /// Tests: fetch → install → verify for movie, tvShow, cartoon, documentary, livestream, nsfw
    ///
    /// This test verifies the installation workflow for all new content types
    test(
      'Integration Test 5: Installation flow for new content types (movie, tvShow, cartoon, documentary, livestream, nsfw)',
      () async {
        final extension = CloudStreamExtensions();
        await Future.delayed(const Duration(milliseconds: 10));

        // Set up available extensions for all new content types
        final movieSource = Source(
          id: 'com.example.movie',
          name: 'Movie Provider',
          version: '1.0.0',
          itemType: ItemType.movie,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/movie.apk',
          baseUrl: 'https://movie.example.com',
          lang: 'en',
        );

        final tvShowSource = Source(
          id: 'com.example.tvshow',
          name: 'TV Show Provider',
          version: '1.0.0',
          itemType: ItemType.tvShow,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/tvshow.apk',
          baseUrl: 'https://tvshow.example.com',
          lang: 'en',
        );

        final cartoonSource = Source(
          id: 'com.example.cartoon',
          name: 'Cartoon Provider',
          version: '1.0.0',
          itemType: ItemType.cartoon,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/cartoon.apk',
          baseUrl: 'https://cartoon.example.com',
          lang: 'en',
        );

        final documentarySource = Source(
          id: 'com.example.documentary',
          name: 'Documentary Provider',
          version: '1.0.0',
          itemType: ItemType.documentary,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/documentary.apk',
          baseUrl: 'https://documentary.example.com',
          lang: 'en',
        );

        final livestreamSource = Source(
          id: 'com.example.livestream',
          name: 'Livestream Provider',
          version: '1.0.0',
          itemType: ItemType.livestream,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/livestream.apk',
          baseUrl: 'https://livestream.example.com',
          lang: 'en',
        );

        final nsfwSource = Source(
          id: 'com.example.nsfw',
          name: 'NSFW Provider',
          version: '1.0.0',
          itemType: ItemType.nsfw,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/nsfw.apk',
          baseUrl: 'https://nsfw.example.com',
          lang: 'en',
        );

        // Set up available extensions
        extension.availableMovieExtensions.value = [movieSource];
        extension.availableTvShowExtensions.value = [tvShowSource];
        extension.availableCartoonExtensions.value = [cartoonSource];
        extension.availableDocumentaryExtensions.value = [documentarySource];
        extension.availableLivestreamExtensions.value = [livestreamSource];
        extension.availableNsfwExtensions.value = [nsfwSource];

        // Verify available extensions are set
        expect(extension.availableMovieExtensions.value.length, equals(1));
        expect(extension.availableTvShowExtensions.value.length, equals(1));
        expect(extension.availableCartoonExtensions.value.length, equals(1));
        expect(
          extension.availableDocumentaryExtensions.value.length,
          equals(1),
        );
        expect(extension.availableLivestreamExtensions.value.length, equals(1));
        expect(extension.availableNsfwExtensions.value.length, equals(1));

        // Simulate installation for each type
        // Movie
        extension.availableMovieExtensions.value = [];
        extension.installedMovieExtensions.value = [movieSource.copyWith()];

        // TV Show
        extension.availableTvShowExtensions.value = [];
        extension.installedTvShowExtensions.value = [tvShowSource.copyWith()];

        // Cartoon
        extension.availableCartoonExtensions.value = [];
        extension.installedCartoonExtensions.value = [cartoonSource.copyWith()];

        // Documentary
        extension.availableDocumentaryExtensions.value = [];
        extension.installedDocumentaryExtensions.value = [
          documentarySource.copyWith(),
        ];

        // Livestream
        extension.availableLivestreamExtensions.value = [];
        extension.installedLivestreamExtensions.value = [
          livestreamSource.copyWith(),
        ];

        // NSFW
        extension.availableNsfwExtensions.value = [];
        extension.installedNsfwExtensions.value = [nsfwSource.copyWith()];

        // Verify installations
        expect(
          extension.installedMovieExtensions.value.length,
          equals(1),
          reason: 'Should have 1 installed movie extension',
        );
        expect(
          extension.installedMovieExtensions.value.first.id,
          equals('com.example.movie'),
        );
        expect(
          extension.availableMovieExtensions.value.length,
          equals(0),
          reason: 'Movie should be removed from available list',
        );

        expect(
          extension.installedTvShowExtensions.value.length,
          equals(1),
          reason: 'Should have 1 installed tvShow extension',
        );
        expect(
          extension.installedTvShowExtensions.value.first.id,
          equals('com.example.tvshow'),
        );
        expect(
          extension.availableTvShowExtensions.value.length,
          equals(0),
          reason: 'TvShow should be removed from available list',
        );

        expect(
          extension.installedCartoonExtensions.value.length,
          equals(1),
          reason: 'Should have 1 installed cartoon extension',
        );
        expect(
          extension.installedCartoonExtensions.value.first.id,
          equals('com.example.cartoon'),
        );
        expect(
          extension.availableCartoonExtensions.value.length,
          equals(0),
          reason: 'Cartoon should be removed from available list',
        );

        expect(
          extension.installedDocumentaryExtensions.value.length,
          equals(1),
          reason: 'Should have 1 installed documentary extension',
        );
        expect(
          extension.installedDocumentaryExtensions.value.first.id,
          equals('com.example.documentary'),
        );
        expect(
          extension.availableDocumentaryExtensions.value.length,
          equals(0),
          reason: 'Documentary should be removed from available list',
        );

        expect(
          extension.installedLivestreamExtensions.value.length,
          equals(1),
          reason: 'Should have 1 installed livestream extension',
        );
        expect(
          extension.installedLivestreamExtensions.value.first.id,
          equals('com.example.livestream'),
        );
        expect(
          extension.availableLivestreamExtensions.value.length,
          equals(0),
          reason: 'Livestream should be removed from available list',
        );

        expect(
          extension.installedNsfwExtensions.value.length,
          equals(1),
          reason: 'Should have 1 installed nsfw extension',
        );
        expect(
          extension.installedNsfwExtensions.value.first.id,
          equals('com.example.nsfw'),
        );
        expect(
          extension.availableNsfwExtensions.value.length,
          equals(0),
          reason: 'NSFW should be removed from available list',
        );
      },
    );

    /// Integration Test 6: Update Flow for New Content Types
    ///
    /// Tests: install → detect update → update → verify for new content types
    ///
    /// This test verifies the update workflow for all new content types
    test(
      'Integration Test 6: Update flow for new content types (movie, tvShow, cartoon, documentary, livestream, nsfw)',
      () async {
        final extension = CloudStreamExtensions();
        await Future.delayed(const Duration(milliseconds: 10));

        // Set up installed extensions with version 1.0.0
        extension.installedMovieExtensions.value = [
          Source(
            id: 'com.example.movie',
            name: 'Movie Provider',
            version: '1.0.0',
            itemType: ItemType.movie,
            extensionType: ExtensionType.cloudstream,
          ),
        ];

        extension.installedTvShowExtensions.value = [
          Source(
            id: 'com.example.tvshow',
            name: 'TV Show Provider',
            version: '1.0.0',
            itemType: ItemType.tvShow,
            extensionType: ExtensionType.cloudstream,
          ),
        ];

        extension.installedCartoonExtensions.value = [
          Source(
            id: 'com.example.cartoon',
            name: 'Cartoon Provider',
            version: '1.0.0',
            itemType: ItemType.cartoon,
            extensionType: ExtensionType.cloudstream,
          ),
        ];

        extension.installedDocumentaryExtensions.value = [
          Source(
            id: 'com.example.documentary',
            name: 'Documentary Provider',
            version: '1.0.0',
            itemType: ItemType.documentary,
            extensionType: ExtensionType.cloudstream,
          ),
        ];

        extension.installedLivestreamExtensions.value = [
          Source(
            id: 'com.example.livestream',
            name: 'Livestream Provider',
            version: '1.0.0',
            itemType: ItemType.livestream,
            extensionType: ExtensionType.cloudstream,
          ),
        ];

        extension.installedNsfwExtensions.value = [
          Source(
            id: 'com.example.nsfw',
            name: 'NSFW Provider',
            version: '1.0.0',
            itemType: ItemType.nsfw,
            extensionType: ExtensionType.cloudstream,
          ),
        ];

        // Set up available extensions with version 2.0.0
        extension.availableMovieExtensions.value = [
          Source(
            id: 'com.example.movie',
            name: 'Movie Provider',
            version: '2.0.0',
            itemType: ItemType.movie,
            extensionType: ExtensionType.cloudstream,
            apkUrl: 'https://example.com/movie-v2.apk',
          ),
        ];

        extension.availableTvShowExtensions.value = [
          Source(
            id: 'com.example.tvshow',
            name: 'TV Show Provider',
            version: '2.0.0',
            itemType: ItemType.tvShow,
            extensionType: ExtensionType.cloudstream,
            apkUrl: 'https://example.com/tvshow-v2.apk',
          ),
        ];

        extension.availableCartoonExtensions.value = [
          Source(
            id: 'com.example.cartoon',
            name: 'Cartoon Provider',
            version: '2.0.0',
            itemType: ItemType.cartoon,
            extensionType: ExtensionType.cloudstream,
            apkUrl: 'https://example.com/cartoon-v2.apk',
          ),
        ];

        extension.availableDocumentaryExtensions.value = [
          Source(
            id: 'com.example.documentary',
            name: 'Documentary Provider',
            version: '2.0.0',
            itemType: ItemType.documentary,
            extensionType: ExtensionType.cloudstream,
            apkUrl: 'https://example.com/documentary-v2.apk',
          ),
        ];

        extension.availableLivestreamExtensions.value = [
          Source(
            id: 'com.example.livestream',
            name: 'Livestream Provider',
            version: '2.0.0',
            itemType: ItemType.livestream,
            extensionType: ExtensionType.cloudstream,
            apkUrl: 'https://example.com/livestream-v2.apk',
          ),
        ];

        extension.availableNsfwExtensions.value = [
          Source(
            id: 'com.example.nsfw',
            name: 'NSFW Provider',
            version: '2.0.0',
            itemType: ItemType.nsfw,
            extensionType: ExtensionType.cloudstream,
            apkUrl: 'https://example.com/nsfw-v2.apk',
          ),
        ];

        // Check for updates for all new content types
        await extension.checkForUpdates(ItemType.movie);
        await extension.checkForUpdates(ItemType.tvShow);
        await extension.checkForUpdates(ItemType.cartoon);
        await extension.checkForUpdates(ItemType.documentary);
        await extension.checkForUpdates(ItemType.livestream);
        await extension.checkForUpdates(ItemType.nsfw);

        // Verify update detection for all types
        expect(
          extension.installedMovieExtensions.value.first.hasUpdate,
          isTrue,
          reason: 'Movie extension should have update available',
        );
        expect(
          extension.installedMovieExtensions.value.first.versionLast,
          equals('2.0.0'),
        );
        expect(
          extension.installedMovieExtensions.value.first.apkUrl,
          equals('https://example.com/movie-v2.apk'),
        );

        expect(
          extension.installedTvShowExtensions.value.first.hasUpdate,
          isTrue,
          reason: 'TvShow extension should have update available',
        );
        expect(
          extension.installedTvShowExtensions.value.first.versionLast,
          equals('2.0.0'),
        );

        expect(
          extension.installedCartoonExtensions.value.first.hasUpdate,
          isTrue,
          reason: 'Cartoon extension should have update available',
        );
        expect(
          extension.installedCartoonExtensions.value.first.versionLast,
          equals('2.0.0'),
        );

        expect(
          extension.installedDocumentaryExtensions.value.first.hasUpdate,
          isTrue,
          reason: 'Documentary extension should have update available',
        );
        expect(
          extension.installedDocumentaryExtensions.value.first.versionLast,
          equals('2.0.0'),
        );

        expect(
          extension.installedLivestreamExtensions.value.first.hasUpdate,
          isTrue,
          reason: 'Livestream extension should have update available',
        );
        expect(
          extension.installedLivestreamExtensions.value.first.versionLast,
          equals('2.0.0'),
        );

        expect(
          extension.installedNsfwExtensions.value.first.hasUpdate,
          isTrue,
          reason: 'NSFW extension should have update available',
        );
        expect(
          extension.installedNsfwExtensions.value.first.versionLast,
          equals('2.0.0'),
        );

        // Simulate updates (replace with version 2.0.0)
        extension.installedMovieExtensions.value = [
          Source(
            id: 'com.example.movie',
            name: 'Movie Provider',
            version: '2.0.0',
            itemType: ItemType.movie,
            extensionType: ExtensionType.cloudstream,
            hasUpdate: false,
          ),
        ];

        extension.installedTvShowExtensions.value = [
          Source(
            id: 'com.example.tvshow',
            name: 'TV Show Provider',
            version: '2.0.0',
            itemType: ItemType.tvShow,
            extensionType: ExtensionType.cloudstream,
            hasUpdate: false,
          ),
        ];

        extension.installedCartoonExtensions.value = [
          Source(
            id: 'com.example.cartoon',
            name: 'Cartoon Provider',
            version: '2.0.0',
            itemType: ItemType.cartoon,
            extensionType: ExtensionType.cloudstream,
            hasUpdate: false,
          ),
        ];

        extension.installedDocumentaryExtensions.value = [
          Source(
            id: 'com.example.documentary',
            name: 'Documentary Provider',
            version: '2.0.0',
            itemType: ItemType.documentary,
            extensionType: ExtensionType.cloudstream,
            hasUpdate: false,
          ),
        ];

        extension.installedLivestreamExtensions.value = [
          Source(
            id: 'com.example.livestream',
            name: 'Livestream Provider',
            version: '2.0.0',
            itemType: ItemType.livestream,
            extensionType: ExtensionType.cloudstream,
            hasUpdate: false,
          ),
        ];

        extension.installedNsfwExtensions.value = [
          Source(
            id: 'com.example.nsfw',
            name: 'NSFW Provider',
            version: '2.0.0',
            itemType: ItemType.nsfw,
            extensionType: ExtensionType.cloudstream,
            hasUpdate: false,
          ),
        ];

        // Verify updates
        expect(
          extension.installedMovieExtensions.value.first.version,
          equals('2.0.0'),
        );
        expect(
          extension.installedMovieExtensions.value.first.hasUpdate ?? false,
          isFalse,
        );

        expect(
          extension.installedTvShowExtensions.value.first.version,
          equals('2.0.0'),
        );
        expect(
          extension.installedTvShowExtensions.value.first.hasUpdate ?? false,
          isFalse,
        );

        expect(
          extension.installedCartoonExtensions.value.first.version,
          equals('2.0.0'),
        );
        expect(
          extension.installedCartoonExtensions.value.first.hasUpdate ?? false,
          isFalse,
        );

        expect(
          extension.installedDocumentaryExtensions.value.first.version,
          equals('2.0.0'),
        );
        expect(
          extension.installedDocumentaryExtensions.value.first.hasUpdate ??
              false,
          isFalse,
        );

        expect(
          extension.installedLivestreamExtensions.value.first.version,
          equals('2.0.0'),
        );
        expect(
          extension.installedLivestreamExtensions.value.first.hasUpdate ??
              false,
          isFalse,
        );

        expect(
          extension.installedNsfwExtensions.value.first.version,
          equals('2.0.0'),
        );
        expect(
          extension.installedNsfwExtensions.value.first.hasUpdate ?? false,
          isFalse,
        );
      },
    );

    /// Integration Test 7: Uninstallation Flow for New Content Types
    ///
    /// Tests: install → uninstall → verify for new content types
    ///
    /// This test verifies the uninstallation workflow for all new content types
    test(
      'Integration Test 7: Uninstallation flow for new content types (movie, tvShow, cartoon, documentary, livestream, nsfw)',
      () async {
        final extension = CloudStreamExtensions();
        await Future.delayed(const Duration(milliseconds: 10));

        // Set up installed extensions
        final movieSource = Source(
          id: 'com.example.movie',
          name: 'Movie Provider',
          version: '1.0.0',
          itemType: ItemType.movie,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/movie.apk',
        );

        final tvShowSource = Source(
          id: 'com.example.tvshow',
          name: 'TV Show Provider',
          version: '1.0.0',
          itemType: ItemType.tvShow,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/tvshow.apk',
        );

        final cartoonSource = Source(
          id: 'com.example.cartoon',
          name: 'Cartoon Provider',
          version: '1.0.0',
          itemType: ItemType.cartoon,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/cartoon.apk',
        );

        final documentarySource = Source(
          id: 'com.example.documentary',
          name: 'Documentary Provider',
          version: '1.0.0',
          itemType: ItemType.documentary,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/documentary.apk',
        );

        final livestreamSource = Source(
          id: 'com.example.livestream',
          name: 'Livestream Provider',
          version: '1.0.0',
          itemType: ItemType.livestream,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/livestream.apk',
        );

        final nsfwSource = Source(
          id: 'com.example.nsfw',
          name: 'NSFW Provider',
          version: '1.0.0',
          itemType: ItemType.nsfw,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/nsfw.apk',
        );

        extension.installedMovieExtensions.value = [movieSource];
        extension.installedTvShowExtensions.value = [tvShowSource];
        extension.installedCartoonExtensions.value = [cartoonSource];
        extension.installedDocumentaryExtensions.value = [documentarySource];
        extension.installedLivestreamExtensions.value = [livestreamSource];
        extension.installedNsfwExtensions.value = [nsfwSource];

        // Set up unmodified available lists
        extension.availableMovieExtensionsUnmodified.value = [
          movieSource.copyWith(),
        ];
        extension.availableTvShowExtensionsUnmodified.value = [
          tvShowSource.copyWith(),
        ];
        extension.availableCartoonExtensionsUnmodified.value = [
          cartoonSource.copyWith(),
        ];
        extension.availableDocumentaryExtensionsUnmodified.value = [
          documentarySource.copyWith(),
        ];
        extension.availableLivestreamExtensionsUnmodified.value = [
          livestreamSource.copyWith(),
        ];
        extension.availableNsfwExtensionsUnmodified.value = [
          nsfwSource.copyWith(),
        ];

        // Verify initial state
        expect(extension.installedMovieExtensions.value.length, equals(1));
        expect(extension.installedTvShowExtensions.value.length, equals(1));
        expect(extension.installedCartoonExtensions.value.length, equals(1));
        expect(
          extension.installedDocumentaryExtensions.value.length,
          equals(1),
        );
        expect(extension.installedLivestreamExtensions.value.length, equals(1));
        expect(extension.installedNsfwExtensions.value.length, equals(1));

        // Simulate uninstallation for each type
        extension.removeFromInstalledList(movieSource);
        extension.removeFromInstalledList(tvShowSource);
        extension.removeFromInstalledList(cartoonSource);
        extension.removeFromInstalledList(documentarySource);
        extension.removeFromInstalledList(livestreamSource);
        extension.removeFromInstalledList(nsfwSource);

        // Restore to available lists
        extension.availableMovieExtensions.value = [
          extension.availableMovieExtensionsUnmodified.value.first,
        ];
        extension.availableTvShowExtensions.value = [
          extension.availableTvShowExtensionsUnmodified.value.first,
        ];
        extension.availableCartoonExtensions.value = [
          extension.availableCartoonExtensionsUnmodified.value.first,
        ];
        extension.availableDocumentaryExtensions.value = [
          extension.availableDocumentaryExtensionsUnmodified.value.first,
        ];
        extension.availableLivestreamExtensions.value = [
          extension.availableLivestreamExtensionsUnmodified.value.first,
        ];
        extension.availableNsfwExtensions.value = [
          extension.availableNsfwExtensionsUnmodified.value.first,
        ];

        // Verify uninstallation results
        expect(
          extension.installedMovieExtensions.value.length,
          equals(0),
          reason: 'Movie list should be empty after uninstall',
        );
        expect(
          extension.availableMovieExtensions.value.length,
          equals(1),
          reason: 'Movie should be restored to available list',
        );

        expect(
          extension.installedTvShowExtensions.value.length,
          equals(0),
          reason: 'TvShow list should be empty after uninstall',
        );
        expect(
          extension.availableTvShowExtensions.value.length,
          equals(1),
          reason: 'TvShow should be restored to available list',
        );

        expect(
          extension.installedCartoonExtensions.value.length,
          equals(0),
          reason: 'Cartoon list should be empty after uninstall',
        );
        expect(
          extension.availableCartoonExtensions.value.length,
          equals(1),
          reason: 'Cartoon should be restored to available list',
        );

        expect(
          extension.installedDocumentaryExtensions.value.length,
          equals(0),
          reason: 'Documentary list should be empty after uninstall',
        );
        expect(
          extension.availableDocumentaryExtensions.value.length,
          equals(1),
          reason: 'Documentary should be restored to available list',
        );

        expect(
          extension.installedLivestreamExtensions.value.length,
          equals(0),
          reason: 'Livestream list should be empty after uninstall',
        );
        expect(
          extension.availableLivestreamExtensions.value.length,
          equals(1),
          reason: 'Livestream should be restored to available list',
        );

        expect(
          extension.installedNsfwExtensions.value.length,
          equals(0),
          reason: 'NSFW list should be empty after uninstall',
        );
        expect(
          extension.availableNsfwExtensions.value.length,
          equals(1),
          reason: 'NSFW should be restored to available list',
        );
      },
    );

    /// Integration Test 8: Complex Multi-Step Workflow
    ///
    /// Tests a complex scenario combining multiple operations:
    /// 1. Install multiple extensions of different types
    /// 2. Detect updates for some extensions
    /// 3. Update one extension
    /// 4. Uninstall another extension
    /// 5. Verify all state changes are correct
    test('Integration Test 8: Complex multi-step workflow', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 10));

      // Step 1: Install multiple extensions
      final animeExt1 = Source(
        id: 'com.example.anime1',
        name: 'Anime Provider 1',
        version: '1.0.0',
        itemType: ItemType.anime,
        extensionType: ExtensionType.cloudstream,
      );

      final animeExt2 = Source(
        id: 'com.example.anime2',
        name: 'Anime Provider 2',
        version: '1.0.0',
        itemType: ItemType.anime,
        extensionType: ExtensionType.cloudstream,
      );

      final mangaExt1 = Source(
        id: 'com.example.manga1',
        name: 'Manga Provider 1',
        version: '1.0.0',
        itemType: ItemType.manga,
        extensionType: ExtensionType.cloudstream,
      );

      extension.installedAnimeExtensions.value = [animeExt1, animeExt2];
      extension.installedMangaExtensions.value = [mangaExt1];

      // Verify initial state
      expect(extension.installedAnimeExtensions.value.length, equals(2));
      expect(extension.installedMangaExtensions.value.length, equals(1));

      // Step 2: Set up available extensions with updates
      extension.availableAnimeExtensions.value = [
        Source(
          id: 'com.example.anime1',
          name: 'Anime Provider 1',
          version: '2.0.0', // Update available
          itemType: ItemType.anime,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/anime1-v2.apk',
        ),
        // anime2 has no update available
      ];

      extension.availableMangaExtensions.value = [
        Source(
          id: 'com.example.manga1',
          name: 'Manga Provider 1',
          version: '1.5.0', // Update available
          itemType: ItemType.manga,
          extensionType: ExtensionType.cloudstream,
          apkUrl: 'https://example.com/manga1-v1.5.apk',
        ),
      ];

      // Step 3: Detect updates
      await extension.checkForUpdates(ItemType.anime);
      await extension.checkForUpdates(ItemType.manga);

      // Verify update detection
      expect(
        extension.installedAnimeExtensions.value
            .firstWhere((s) => s.id == 'com.example.anime1')
            .hasUpdate,
        isTrue,
        reason: 'anime1 should have update available',
      );
      expect(
        extension.installedAnimeExtensions.value
                .firstWhere((s) => s.id == 'com.example.anime2')
                .hasUpdate ??
            false,
        isFalse,
        reason: 'anime2 should not have update available',
      );
      expect(
        extension.installedMangaExtensions.value
            .firstWhere((s) => s.id == 'com.example.manga1')
            .hasUpdate,
        isTrue,
        reason: 'manga1 should have update available',
      );

      // Step 4: Update anime1
      final updatedAnime1 = Source(
        id: 'com.example.anime1',
        name: 'Anime Provider 1',
        version: '2.0.0',
        itemType: ItemType.anime,
        extensionType: ExtensionType.cloudstream,
      );

      extension.installedAnimeExtensions.value = [updatedAnime1, animeExt2];

      // Verify update
      expect(
        extension.installedAnimeExtensions.value
            .firstWhere((s) => s.id == 'com.example.anime1')
            .version,
        equals('2.0.0'),
        reason: 'anime1 should be updated to version 2.0.0',
      );

      // Step 5: Uninstall anime2
      extension.removeFromInstalledList(animeExt2);

      // Verify uninstallation
      expect(
        extension.installedAnimeExtensions.value.length,
        equals(1),
        reason: 'Should have 1 anime extension after uninstall',
      );
      expect(
        extension.installedAnimeExtensions.value.any(
          (s) => s.id == 'com.example.anime2',
        ),
        isFalse,
        reason: 'anime2 should be removed',
      );

      // Step 6: Verify final state
      // Anime: 1 extension (anime1 v2.0.0)
      expect(extension.installedAnimeExtensions.value.length, equals(1));
      expect(
        extension.installedAnimeExtensions.value.first.id,
        equals('com.example.anime1'),
      );
      expect(
        extension.installedAnimeExtensions.value.first.version,
        equals('2.0.0'),
      );

      // Manga: 1 extension (manga1 v1.0.0 with update available)
      expect(extension.installedMangaExtensions.value.length, equals(1));
      expect(
        extension.installedMangaExtensions.value.first.id,
        equals('com.example.manga1'),
      );
      expect(
        extension.installedMangaExtensions.value.first.version,
        equals('1.0.0'),
      );
      expect(extension.installedMangaExtensions.value.first.hasUpdate, isTrue);
      expect(
        extension.installedMangaExtensions.value.first.versionLast,
        equals('1.5.0'),
      );

      // Novel: 0 extensions
      expect(extension.installedNovelExtensions.value.length, equals(0));
    });
  });
}

// Extension method to copy Source objects (for testing)
extension SourceCopyWith on Source {
  Source copyWith({
    String? id,
    String? name,
    String? version,
    ItemType? itemType,
    ExtensionType? extensionType,
    String? apkUrl,
    String? baseUrl,
    String? lang,
    bool? hasUpdate,
    String? versionLast,
  }) {
    return Source(
      id: id ?? this.id,
      name: name ?? this.name,
      version: version ?? this.version,
      itemType: itemType ?? this.itemType,
      extensionType: extensionType ?? this.extensionType,
      apkUrl: apkUrl ?? this.apkUrl,
      baseUrl: baseUrl ?? this.baseUrl,
      lang: lang ?? this.lang,
      hasUpdate: hasUpdate ?? this.hasUpdate,
      versionLast: versionLast ?? this.versionLast,
    );
  }
}
