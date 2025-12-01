import 'dart:io';

import 'package:dartotsu_extension_bridge/Models/DEpisode.dart';
import 'package:dartotsu_extension_bridge/Models/DMedia.dart';
import 'package:dartotsu_extension_bridge/Models/Page.dart';
import 'package:dartotsu_extension_bridge/Models/Pages.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:dartotsu_extension_bridge/Models/SourcePreference.dart';
import 'package:dartotsu_extension_bridge/Models/Video.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../Extensions/SourceMethods.dart';
import 'desktop/cloudstream_desktop_channel_handler.dart';

/// CloudStream-specific implementation of SourceMethods interface.
///
/// This class handles communication with CloudStream extensions loaded via
/// DexClassLoader. It uses platform channels to invoke native methods that
/// interact with the CloudStream MainAPI implementations through the
/// CloudStreamApiRouter.
class CloudStreamSourceMethods implements SourceMethods {
  static const platform = MethodChannel('cloudstreamExtensionBridge');

  @override
  Source source;

  CloudStreamSourceMethods(this.source);

  /// Helper to determine content type based on source itemType
  bool get isAnime => source.itemType?.index == 1;
  bool get isManga => source.itemType?.index == 0;
  bool get isNovel => source.itemType?.index == 2;

  /// Invoke a CloudStream method, routing to desktop bridge on Linux/Windows.
  Future<dynamic> _invokeCloudStreamMethod(
    String method, [
    dynamic arguments,
  ]) async {
    if (Platform.isLinux || Platform.isWindows) {
      final handler = CloudStreamDesktopChannelHandler.instance;
      if (!handler.isSetup) {
        await handler.setup();
      }
      return handler.bridge.handleMethodCall(MethodCall(method, arguments));
    }
    return platform.invokeMethod(method, arguments);
  }

  @override
  Future<Pages> getPopular(int page) async {
    try {
      // Use the new cloudstream: prefixed method for loaded plugins
      final result = await _invokeCloudStreamMethod('cloudstream:getPopular', {
        'sourceId': source.id,
        'itemType': source.itemType?.index ?? 1,
        'page': page,
      });

      return await compute(
        Pages.fromJson,
        Map<String, dynamic>.from(result as Map),
      );
    } catch (e) {
      debugPrint('Error getting popular content: $e');
      return Pages(hasNextPage: false, list: []);
    }
  }

  @override
  Future<Pages> getLatestUpdates(int page) async {
    try {
      final result = await _invokeCloudStreamMethod(
        'cloudstream:getLatestUpdates',
        {
          'sourceId': source.id,
          'itemType': source.itemType?.index ?? 1,
          'page': page,
        },
      );

      return await compute(
        Pages.fromJson,
        Map<String, dynamic>.from(result as Map),
      );
    } catch (e) {
      debugPrint('Error getting latest updates: $e');
      return Pages(hasNextPage: false, list: []);
    }
  }

  @override
  Future<Pages> search(String query, int page, List<dynamic> filters) async {
    try {
      final result = await _invokeCloudStreamMethod('cloudstream:search', {
        'sourceId': source.id,
        'itemType': source.itemType?.index ?? 1,
        'query': query,
        'page': page,
        'filters': filters,
      });

      return await compute(
        Pages.fromJson,
        Map<String, dynamic>.from(result as Map),
      );
    } catch (e) {
      debugPrint('Error searching: $e');
      return Pages(hasNextPage: false, list: []);
    }
  }

  @override
  Future<DMedia> getDetail(DMedia media) async {
    try {
      final result = await _invokeCloudStreamMethod('cloudstream:getDetail', {
        'sourceId': source.id,
        'itemType': source.itemType?.index ?? 1,
        'media': {
          'title': media.title,
          'url': media.url,
          'thumbnail_url': media.cover,
          'description': media.description,
          'author': media.author,
          'artist': media.artist,
          'genre': media.genre,
        },
      });

      return await compute(
        DMedia.fromJson,
        Map<String, dynamic>.from(result as Map),
      );
    } catch (e) {
      debugPrint('Error getting detail: $e');
      rethrow;
    }
  }

  @override
  Future<List<Video>> getVideoList(DEpisode episode) async {
    try {
      final result = await _invokeCloudStreamMethod(
        'cloudstream:getVideoList',
        {
          'sourceId': source.id,
          'itemType': source.itemType?.index ?? 1,
          'episode': {
            'name': episode.name,
            'url': episode.url,
            'date_upload': episode.dateUpload,
            'description': episode.description,
            'episode_number': episode.episodeNumber,
            'scanlator': episode.scanlator,
          },
        },
      );

      // Handle the new response format with videos and subtitles
      if (result is Map) {
        final resultMap = Map<String, dynamic>.from(result);
        final videos = resultMap['videos'] as List? ?? [];
        return await compute(_parseVideos, List<dynamic>.from(videos));
      }

      return await compute(_parseVideos, List<dynamic>.from(result));
    } catch (e) {
      debugPrint('Error getting video list: $e');
      return [];
    }
  }

  @override
  Future<List<PageUrl>> getPageList(DEpisode episode) async {
    try {
      final result = await _invokeCloudStreamMethod('cloudstream:getPageList', {
        'sourceId': source.id,
        'itemType': source.itemType?.index ?? 1,
        'episode': {
          'name': episode.name,
          'url': episode.url,
          'date_upload': episode.dateUpload,
          'description': episode.description,
          'episode_number': episode.episodeNumber,
          'scanlator': episode.scanlator,
        },
      });

      return await compute(_parsePageUrls, List<dynamic>.from(result));
    } catch (e) {
      debugPrint('Error getting page list: $e');
      return [];
    }
  }

  @override
  Future<String?> getNovelContent(String chapterTitle, String chapterId) async {
    try {
      final result =
          await _invokeCloudStreamMethod('cloudstream:getNovelContent', {
            'sourceId': source.id,
            'itemType': source.itemType?.index ?? 2,
            'chapterTitle': chapterTitle,
            'chapterId': chapterId,
          });

      return result as String?;
    } catch (e) {
      debugPrint('Error getting novel content: $e');
      return null;
    }
  }

  @override
  Future<List<SourcePreference>> getPreference() async {
    try {
      final result = await _invokeCloudStreamMethod(
        'cloudstream:getPreference',
        {'sourceId': source.id, 'itemType': source.itemType?.index ?? 1},
      );

      if (result == null) return const [];
      if (result is String) return const [];

      return List<dynamic>.from(result)
          .map((e) => _mapToSourcePreference(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint('Error getting preferences: $e');
      return const [];
    }
  }

  @override
  Future<bool> setPreference(SourcePreference pref, dynamic value) async {
    try {
      final result =
          await _invokeCloudStreamMethod('cloudstream:setPreference', {
            'sourceId': source.id,
            'itemType': source.itemType?.index ?? 1,
            'key': pref.key,
            'value': value,
          });

      return result as bool? ?? false;
    } catch (e) {
      debugPrint('Error setting preference: $e');
      return false;
    }
  }

  /// Extract video links from a URL using CloudStream extractors.
  /// This is useful when the video URL needs to be processed by an extractor.
  Future<List<Video>> extractVideos(String url, {String? referer}) async {
    try {
      final result = await _invokeCloudStreamMethod('cloudstream:extract', {
        'url': url,
        'referer': referer,
      });

      final resultMap = Map<String, dynamic>.from(result as Map);
      if (resultMap['success'] != true) {
        debugPrint('Extraction failed: ${resultMap['error']}');
        return [];
      }

      final links = resultMap['links'] as List? ?? [];
      return links.map((link) {
        final linkMap = Map<String, dynamic>.from(link);
        return Video(
          linkMap['name'] as String? ?? 'Unknown',
          linkMap['url'] as String? ?? '',
          '${linkMap['quality'] ?? 0}p',
          headers: (linkMap['headers'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), v.toString()),
          ),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error extracting videos: $e');
      return [];
    }
  }

  /// Parse video list from dynamic data
  static List<Video> _parseVideos(List<dynamic> list) {
    return list
        .map((e) => Video.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Parse page URL list from dynamic data
  static List<PageUrl> _parsePageUrls(List<dynamic> list) {
    return list
        .map((e) => PageUrl.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Map JSON data to SourcePreference object
  static SourcePreference _mapToSourcePreference(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    switch (type) {
      case 'checkbox':
        return SourcePreference(
          key: json['key'],
          type: type,
          checkBoxPreference: CheckBoxPreference(
            title: json['title'],
            summary: json['summary'],
            value: json['value'],
          ),
        );

      case 'switch':
        return SourcePreference(
          key: json['key'],
          type: type,
          switchPreferenceCompat: SwitchPreferenceCompat(
            title: json['title'],
            summary: json['summary'],
            value: json['value'],
          ),
        );

      case 'list':
        final entries = (json['entries'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final entryValues = (json['entryValues'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final valueIndex = entryValues?.indexOf(
          json['value']?.toString() ?? '',
        );

        return SourcePreference(
          key: json['key'],
          type: type,
          listPreference: ListPreference(
            title: json['title'],
            summary: json['summary'],
            entries: entries,
            entryValues: entryValues,
            valueIndex: valueIndex != -1 ? valueIndex : 0,
          ),
        );

      case 'multi_select':
        final entries = (json['entries'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final entryValues = (json['entryValues'] as List?)
            ?.map((e) => e.toString())
            .toList();
        final values =
            (json['value'] as List?)?.map((e) => e.toString()).toList() ?? [];

        return SourcePreference(
          key: json['key'],
          type: type,
          multiSelectListPreference: MultiSelectListPreference(
            title: json['title'],
            summary: json['summary'],
            entries: entries,
            entryValues: entryValues,
            values: values,
          ),
        );

      case 'text':
        return SourcePreference(
          key: json['key'],
          type: type,
          editTextPreference: EditTextPreference(
            title: json['title'],
            summary: json['summary'],
            value: json['value']?.toString(),
          ),
        );

      default:
        return SourcePreference(key: json['key']);
    }
  }
}
