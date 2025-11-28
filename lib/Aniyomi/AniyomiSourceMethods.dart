import 'package:dartotsu_extension_bridge/Models/DEpisode.dart';
import 'package:dartotsu_extension_bridge/Models/DMedia.dart';

import 'package:dartotsu_extension_bridge/Models/Pages.dart';

import 'package:dartotsu_extension_bridge/Models/Source.dart';

import 'package:dartotsu_extension_bridge/Models/Video.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../Extensions/SourceMethods.dart';
import '../Extensions/ExtractorService.dart';
import '../Models/Page.dart';
import '../Models/SourcePreference.dart';

class AniyomiSourceMethods implements SourceMethods {
  static const platform = MethodChannel('aniyomiExtensionBridge');

  @override
  Source source;

  AniyomiSourceMethods(this.source);

  bool get isAnime => source.itemType?.index == 1;

  @override
  Future<DMedia> getDetail(DMedia media) async {
    final result = await platform.invokeMethod('getDetail', {
      'sourceId': source.id,
      'isAnime': isAnime,
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
  }

  @override
  Future<Pages> getLatestUpdates(int page) async {
    final result = await platform.invokeMethod('getLatestUpdates', {
      'sourceId': source.id,
      'isAnime': isAnime,
      'page': page,
    });

    return await compute(
      Pages.fromJson,
      Map<String, dynamic>.from(result as Map),
    );
  }

  @override
  Future<Pages> getPopular(int page) async {
    final result = await platform.invokeMethod('getPopular', {
      'sourceId': source.id,
      'isAnime': isAnime,
      'page': page,
    });

    return await compute(
      Pages.fromJson,
      Map<String, dynamic>.from(result as Map),
    );
  }

  @override
  Future<List<Video>> getVideoList(DEpisode episode) async {
    final result = await platform.invokeMethod('getVideoList', {
      'sourceId': source.id,
      'isAnime': isAnime,
      'episode': {
        'name': episode.name,
        'url': episode.url,
        'date_upload': episode.dateUpload,
        'description': episode.description,
        'episode_number': episode.episodeNumber,
        'scanlator': episode.scanlator,
      },
    });

    return await compute(parseVideos, List<dynamic>.from(result));
  }

  @override
  Future<List<PageUrl>> getPageList(DEpisode episode) async {
    final result = await platform.invokeMethod('getPageList', {
      'sourceId': source.id,
      'isAnime': isAnime,
      'episode': {
        'name': episode.name,
        'url': episode.url,
        'date_upload': episode.dateUpload,
        'description': episode.description,
        'episode_number': episode.episodeNumber,
        'scanlator': episode.scanlator,
      },
    });

    return compute(parsePageUrls, List<dynamic>.from(result));
  }

  @override
  Future<Pages> search(String query, int page, List filters) async {
    final result = await platform.invokeMethod('search', {
      'sourceId': source.id,
      'isAnime': isAnime,
      'query': query,
      'page': page,
    });

    return await compute(
      Pages.fromJson,
      Map<String, dynamic>.from(result as Map),
    );
  }

  List<Video> parseVideos(List<dynamic> list) {
    return list
        .map((e) => Video.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  List<PageUrl> parsePageUrls(List<dynamic> list) {
    return list
        .map((e) => PageUrl.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Future<String?> getNovelContent(String chapterTitle, String chapterId) {
    throw UnimplementedError();
  }

  @override
  Future<List<SourcePreference>> getPreference() async {
    final result = await platform.invokeMethod("getPreference", {
      'sourceId': source.id,
      'isAnime': isAnime,
    });

    if (result == null) return const [];

    if (result is String) return const [];

    return List<dynamic>.from(
      result,
    ).map((e) => mapToSourcePreference(Map<String, dynamic>.from(e))).toList();
  }

  @override
  Future<bool> setPreference(SourcePreference pref, dynamic value) async {
    final result = await platform.invokeMethod('saveSourcePreference', {
      'sourceId': source.id,
      'key': pref.key,
      'value': value,
    });
    return result;
  }
}

SourcePreference mapToSourcePreference(Map<String, dynamic> json) {
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
      final valueIndex = entryValues?.indexOf(json['value']?.toString() ?? '');
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

/// Extension to add CloudStream extractor support to AniyomiSourceMethods.
///
/// This allows Aniyomi sources to use CloudStream's extensive extractor library
/// when the native Aniyomi extractors don't support a particular video host.
extension CloudStreamExtractorSupport on AniyomiSourceMethods {
  /// Extract video links using CloudStream extractors.
  ///
  /// Use this when the native Aniyomi extraction fails or when you know
  /// the video host is better supported by CloudStream extractors.
  ///
  /// Example:
  /// ```dart
  /// final videos = await sourceMethods.getVideoList(episode);
  /// if (videos.isEmpty) {
  ///   // Try CloudStream extractors as fallback
  ///   final csVideos = await sourceMethods.extractWithCloudStream(videoUrl);
  ///   videos.addAll(csVideos);
  /// }
  /// ```
  Future<List<Video>> extractWithCloudStream(
    String url, {
    String? referer,
  }) async {
    try {
      final extractor = ExtractorService();

      // Check if CloudStream extractors are available
      if (!await extractor.isInitialized) {
        debugPrint('CloudStream extractors not initialized');
        return [];
      }

      final result = await extractor.extract(url, referer: referer);

      if (!result.success) {
        debugPrint('CloudStream extraction failed: ${result.error}');
        return [];
      }

      // Convert ExtractedLink to Video
      return result.links.map((link) {
        return Video(
          link.name,
          link.url,
          link.qualityString,
          headers: link.headers,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error using CloudStream extractors: $e');
      return [];
    }
  }

  /// Check if CloudStream has an extractor for the given URL.
  Future<bool> hasCloudStreamExtractor(String url) async {
    return ExtractorService().hasExtractorForUrl(url);
  }
}
