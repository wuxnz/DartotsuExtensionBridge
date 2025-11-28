import 'package:dartotsu_extension_bridge/CloudStream/CloudStreamExtensions.dart'
    hide ExtractorResult, ExtractedLink, ExtractedSubtitle, ExtractorInfo;
import 'package:dartotsu_extension_bridge/Extensions/ExtractorService.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CloudStream Plugin Loader & Registry Tests', () {
    late MethodChannel channel;
    late List<MethodCall> methodCalls;

    setUp(() {
      channel = const MethodChannel('cloudstreamExtensionBridge');
      methodCalls = [];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            methodCalls.add(methodCall);

            switch (methodCall.method) {
              case 'initializePlugins':
                return {
                  'success': true,
                  'loadedCount': 3,
                  'extractorCount': 150,
                };

              case 'getPluginStatus':
                return {
                  'isInitialized': true,
                  'registeredPluginCount': 3,
                  'extractorCount': 150,
                  'loadedPlugins': [
                    {
                      'id': 'TestPlugin1',
                      'name': 'Test Plugin 1',
                      'mainUrl': 'https://example1.com',
                      'lang': 'en',
                    },
                    {
                      'id': 'TestPlugin2',
                      'name': 'Test Plugin 2',
                      'mainUrl': 'https://example2.com',
                      'lang': 'es',
                    },
                  ],
                };

              case 'listInstalledCloudStreamPlugins':
                return [
                  {
                    'internalName': 'TestPlugin1',
                    'version': '1.0.0',
                    'lang': 'en',
                    'isNsfw': false,
                  },
                  {
                    'internalName': 'TestPlugin2',
                    'version': '2.0.0',
                    'lang': 'es',
                    'isNsfw': false,
                  },
                ];

              case 'installCloudStreamPlugin':
                final args = methodCall.arguments as Map;
                final metadata = args['metadata'] as Map;
                return {
                  'internalName': metadata['internalName'],
                  'version': metadata['version'] ?? '1.0.0',
                  'localPath': '/data/plugins/${metadata['internalName']}',
                  'loaded': true,
                };

              case 'uninstallCloudStreamPlugin':
                return true;

              case 'cloudstream:getLoadedPlugins':
                return [
                  {
                    'id': 'TestPlugin1',
                    'name': 'Test Plugin 1',
                    'mainUrl': 'https://example1.com',
                    'lang': 'en',
                    'hasMainPage': true,
                    'hasQuickSearch': false,
                    'supportedTypes': ['Movie', 'TvSeries'],
                  },
                ];

              // Default handlers for extension list methods
              case 'getInstalledAnimeExtensions':
              case 'getInstalledMangaExtensions':
              case 'getInstalledNovelExtensions':
              case 'getInstalledMovieExtensions':
              case 'getInstalledTvShowExtensions':
              case 'getInstalledCartoonExtensions':
              case 'getInstalledDocumentaryExtensions':
              case 'getInstalledLivestreamExtensions':
              case 'getInstalledNsfwExtensions':
                return <dynamic>[];

              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('initializePlugins returns correct status', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 50));

      final result = await extension.initializePlugins();

      expect(result['success'], isTrue);
      expect(result['loadedCount'], equals(3));
      expect(result['extractorCount'], equals(150));
      expect(methodCalls.any((c) => c.method == 'initializePlugins'), isTrue);
    });

    test('refreshPluginStatus updates pluginStatus observable', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 50));

      final status = await extension.refreshPluginStatus();

      expect(status['isInitialized'], isTrue);
      expect(status['registeredPluginCount'], equals(3));
      expect(extension.pluginStatus.value['isInitialized'], isTrue);
    });

    test('listInstalledCloudStreamPlugins returns plugin list', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 50));

      final plugins = await extension.listInstalledCloudStreamPlugins();

      expect(plugins.length, equals(2));
      expect(plugins[0]['internalName'], equals('TestPlugin1'));
      expect(plugins[1]['internalName'], equals('TestPlugin2'));
    });

    test(
      'installCloudStreamPlugin calls platform with correct metadata',
      () async {
        final extension = CloudStreamExtensions();
        await Future.delayed(const Duration(milliseconds: 50));

        final result = await extension.installCloudStreamPlugin(
          internalName: 'NewPlugin',
          downloadUrl: 'https://example.com/plugin.cs3',
          repoUrl: 'https://repo.example.com',
          version: '1.0.0',
          lang: 'en',
        );

        expect(result, isNotNull);
        expect(result!['internalName'], equals('NewPlugin'));
        expect(result['loaded'], isTrue);

        final installCall = methodCalls.firstWhere(
          (c) => c.method == 'installCloudStreamPlugin',
        );
        final args = installCall.arguments as Map;
        final metadata = args['metadata'] as Map;
        expect(metadata['internalName'], equals('NewPlugin'));
        expect(
          metadata['downloadUrl'],
          equals('https://example.com/plugin.cs3'),
        );
      },
    );

    test('uninstallCloudStreamPlugin returns success', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 50));

      final result = await extension.uninstallCloudStreamPlugin('TestPlugin1');

      expect(result, isTrue);
      expect(
        methodCalls.any(
          (c) =>
              c.method == 'uninstallCloudStreamPlugin' &&
              (c.arguments as Map)['internalName'] == 'TestPlugin1',
        ),
        isTrue,
      );
    });

    test('getLoadedPlugins returns loaded plugin info', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 50));

      final plugins = await extension.getLoadedPlugins();

      expect(plugins.length, equals(1));
      expect(plugins[0]['id'], equals('TestPlugin1'));
      expect(plugins[0]['hasMainPage'], isTrue);
    });

    test('isLoading state is managed correctly during operations', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(extension.isLoading.value, isFalse);

      // Start an operation
      final future = extension.initializePlugins();
      // Note: In real async, isLoading would be true here
      await future;

      expect(extension.isLoading.value, isFalse);
    });

    test('lastError is cleared on successful operation', () async {
      final extension = CloudStreamExtensions();
      await Future.delayed(const Duration(milliseconds: 50));

      // Set a previous error
      extension.lastError.value = 'Previous error';

      await extension.initializePlugins();

      expect(extension.lastError.value, isNull);
    });
  });

  group('CloudStream Extractor Service Tests', () {
    late MethodChannel channel;
    late List<MethodCall> methodCalls;

    setUp(() {
      channel = const MethodChannel('cloudstreamExtensionBridge');
      methodCalls = [];

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
            methodCalls.add(methodCall);

            switch (methodCall.method) {
              case 'cloudstream:extract':
                return {
                  'success': true,
                  'links': [
                    {
                      'source': 'TestExtractor',
                      'name': 'Test Video',
                      'url': 'https://example.com/video.mp4',
                      'referer': 'https://example.com',
                      'quality': 1080,
                      'headers': <String, String>{},
                      'type': 'VIDEO',
                      'isM3u8': false,
                      'isDash': false,
                    },
                    {
                      'source': 'TestExtractor',
                      'name': 'Test Video 720p',
                      'url': 'https://example.com/video_720.mp4',
                      'referer': 'https://example.com',
                      'quality': 720,
                      'headers': <String, String>{},
                      'type': 'VIDEO',
                      'isM3u8': false,
                      'isDash': false,
                    },
                  ],
                  'subtitles': [
                    {'lang': 'English', 'url': 'https://example.com/subs.vtt'},
                  ],
                  'error': null,
                };

              case 'cloudstream:extractWithExtractor':
                final args = methodCall.arguments as Map;
                return {
                  'success': true,
                  'links': [
                    {
                      'source': args['extractorName'],
                      'name': 'Extracted Video',
                      'url': 'https://example.com/extracted.mp4',
                      'referer': args['referer'] ?? '',
                      'quality': 1080,
                      'headers': <String, String>{},
                      'type': 'VIDEO',
                      'isM3u8': false,
                      'isDash': false,
                    },
                  ],
                  'subtitles': <Map<String, dynamic>>[],
                  'error': null,
                };

              case 'cloudstream:listExtractors':
                return [
                  {
                    'name': 'Mp4Upload',
                    'mainUrl': 'https://mp4upload.com',
                    'requiresReferer': true,
                    'sourcePlugin': null,
                  },
                  {
                    'name': 'StreamTape',
                    'mainUrl': 'https://streamtape.com',
                    'requiresReferer': false,
                    'sourcePlugin': null,
                  },
                  {
                    'name': 'CustomExtractor',
                    'mainUrl': 'https://custom.example.com',
                    'requiresReferer': true,
                    'sourcePlugin': 'CustomPlugin',
                  },
                ];

              default:
                return null;
            }
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('ExtractorService.extract returns links and subtitles', () async {
      final service = ExtractorService();

      final result = await service.extract(
        'https://example.com/video/123',
        referer: 'https://example.com',
      );

      expect(result.success, isTrue);
      expect(result.links.length, equals(2));
      expect(result.subtitles.length, equals(1));
      expect(result.error, isNull);

      expect(result.links[0].quality, equals(1080));
      expect(result.links[1].quality, equals(720));
      expect(result.subtitles[0].lang, equals('English'));
    });

    test(
      'ExtractorService.extractWithExtractor uses specified extractor',
      () async {
        final service = ExtractorService();

        final result = await service.extractWithExtractor(
          'Mp4Upload',
          'https://mp4upload.com/video/abc',
          referer: 'https://example.com',
        );

        expect(result.success, isTrue);
        expect(result.links.length, equals(1));
        expect(result.links[0].source, equals('Mp4Upload'));

        final extractCall = methodCalls.firstWhere(
          (c) => c.method == 'cloudstream:extractWithExtractor',
        );
        expect(
          (extractCall.arguments as Map)['extractorName'],
          equals('Mp4Upload'),
        );
      },
    );

    test('ExtractorService.listExtractors returns extractor info', () async {
      final service = ExtractorService();

      final extractors = await service.listExtractors();

      expect(extractors.length, equals(3));
      expect(extractors[0].name, equals('Mp4Upload'));
      expect(extractors[0].requiresReferer, isTrue);
      expect(extractors[2].isFromPlugin, isTrue);
    });

    test('ExtractorResult.bestQualityLink returns highest quality', () async {
      final service = ExtractorService();

      final result = await service.extract('https://example.com/video');

      expect(result.bestQualityLink, isNotNull);
      expect(result.bestQualityLink!.quality, equals(1080));
    });

    test('ExtractorResult.linksByQuality returns sorted list', () async {
      final service = ExtractorService();

      final result = await service.extract('https://example.com/video');
      final sorted = result.linksByQuality;

      expect(sorted.length, equals(2));
      expect(sorted[0].quality, equals(1080));
      expect(sorted[1].quality, equals(720));
    });

    test('ExtractedLink.qualityString formats correctly', () {
      final link = ExtractedLink(
        source: 'Test',
        name: 'Test',
        url: 'https://example.com',
        referer: '',
        quality: 1080,
        type: 'VIDEO',
        isM3u8: false,
        isDash: false,
      );

      expect(link.qualityString, equals('1080p'));
    });

    test('ExtractedLink type helpers work correctly', () {
      final videoLink = ExtractedLink(
        source: 'Test',
        name: 'Test',
        url: 'https://example.com',
        referer: '',
        quality: 1080,
        type: 'VIDEO',
        isM3u8: false,
        isDash: false,
      );

      final hlsLink = ExtractedLink(
        source: 'Test',
        name: 'Test',
        url: 'https://example.com',
        referer: '',
        quality: 1080,
        type: 'M3U8',
        isM3u8: true,
        isDash: false,
      );

      final dashLink = ExtractedLink(
        source: 'Test',
        name: 'Test',
        url: 'https://example.com',
        referer: '',
        quality: 1080,
        type: 'DASH',
        isM3u8: false,
        isDash: true,
      );

      expect(videoLink.isDirectVideo, isTrue);
      expect(videoLink.isHls, isFalse);
      expect(hlsLink.isHls, isTrue);
      expect(dashLink.isDashStream, isTrue);
    });

    test('hasExtractorForUrl returns true for matching URL', () async {
      final service = ExtractorService();

      final hasExtractor = await service.hasExtractorForUrl(
        'https://mp4upload.com/video/123',
      );

      expect(hasExtractor, isTrue);
    });

    test('hasExtractorForUrl returns false for unknown URL', () async {
      final service = ExtractorService();

      final hasExtractor = await service.hasExtractorForUrl(
        'https://unknown-site.com/video',
      );

      expect(hasExtractor, isFalse);
    });

    test('findExtractorsForUrl returns matching extractors', () async {
      final service = ExtractorService();

      final extractors = await service.findExtractorsForUrl(
        'https://streamtape.com/v/abc123',
      );

      expect(extractors.length, equals(1));
      expect(extractors[0].name, equals('StreamTape'));
    });

    test('getExtractorCount returns correct count', () async {
      final service = ExtractorService();

      final count = await service.getExtractorCount();

      expect(count, equals(3));
    });
  });

  group('CloudStream Extractor Models Tests', () {
    test('ExtractorResult.fromJson parses correctly', () {
      final json = {
        'success': true,
        'links': [
          {
            'source': 'Test',
            'name': 'Video',
            'url': 'https://example.com/video.mp4',
            'referer': 'https://example.com',
            'quality': 720,
            'headers': {'Authorization': 'Bearer token'},
            'type': 'VIDEO',
            'isM3u8': false,
            'isDash': false,
          },
        ],
        'subtitles': [
          {'lang': 'en', 'url': 'https://example.com/subs.vtt'},
        ],
        'error': null,
      };

      final result = ExtractorResult.fromJson(json);

      expect(result.success, isTrue);
      expect(result.links.length, equals(1));
      expect(result.links[0].headers['Authorization'], equals('Bearer token'));
      expect(result.subtitles.length, equals(1));
    });

    test('ExtractorResult.toJson serializes correctly', () {
      final result = ExtractorResult(
        success: true,
        links: [
          ExtractedLink(
            source: 'Test',
            name: 'Video',
            url: 'https://example.com/video.mp4',
            referer: 'https://example.com',
            quality: 720,
            type: 'VIDEO',
            isM3u8: false,
            isDash: false,
          ),
        ],
        subtitles: [
          ExtractedSubtitle(lang: 'en', url: 'https://example.com/subs.vtt'),
        ],
      );

      final json = result.toJson();

      expect(json['success'], isTrue);
      expect((json['links'] as List).length, equals(1));
      expect((json['subtitles'] as List).length, equals(1));
    });

    test('ExtractorInfo.fromJson parses plugin source correctly', () {
      final json = {
        'name': 'CustomExtractor',
        'mainUrl': 'https://custom.com',
        'requiresReferer': true,
        'sourcePlugin': 'MyPlugin',
      };

      final info = ExtractorInfo.fromJson(json);

      expect(info.name, equals('CustomExtractor'));
      expect(info.isFromPlugin, isTrue);
      expect(info.sourcePlugin, equals('MyPlugin'));
    });

    test('ExtractorResult.hasLinks returns correct value', () {
      final withLinks = ExtractorResult(
        success: true,
        links: [
          ExtractedLink(
            source: 'Test',
            name: 'Video',
            url: 'https://example.com',
            referer: '',
            quality: 720,
            type: 'VIDEO',
            isM3u8: false,
            isDash: false,
          ),
        ],
        subtitles: [],
      );

      final withoutLinks = ExtractorResult(
        success: true,
        links: [],
        subtitles: [],
      );

      final failed = ExtractorResult(
        success: false,
        links: [],
        subtitles: [],
        error: 'Failed',
      );

      expect(withLinks.hasLinks, isTrue);
      expect(withoutLinks.hasLinks, isFalse);
      expect(failed.hasLinks, isFalse);
    });
  });
}
