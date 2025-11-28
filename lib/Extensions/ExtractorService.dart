import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

/// Shared extractor service that provides access to CloudStream extractors
/// for all extension bridges (Aniyomi, Lnreader, etc.).
///
/// This service allows other bridges to leverage CloudStream's extensive
/// collection of video extractors without duplicating implementation.
///
/// Usage from other bridges:
/// ```dart
/// // Check if extractors are available
/// if (await ExtractorService().isInitialized) {
///   final result = await ExtractorService().extract(url);
///   // handle result
/// } else {
///   // Show error: CloudStream extractors not available
/// }
/// ```
class ExtractorService {
  static const _platform = MethodChannel('cloudstreamExtensionBridge');

  /// Singleton instance
  static final ExtractorService _instance = ExtractorService._internal();
  factory ExtractorService() => _instance;
  ExtractorService._internal();

  /// Observable initialization status
  final Rx<bool> _isInitialized = Rx(false);

  /// Observable error state
  final Rx<String?> lastError = Rx(null);

  /// Check if the extractor service is initialized and ready to use.
  Future<bool> get isInitialized async {
    if (_isInitialized.value) return true;

    // Try to check status from native side
    try {
      final result = await _platform.invokeMethod('getPluginStatus');
      final status = Map<String, dynamic>.from(result as Map);
      _isInitialized.value = status['isInitialized'] == true;
      return _isInitialized.value;
    } catch (e) {
      debugPrint('ExtractorService: Failed to check initialization status: $e');
      return false;
    }
  }

  /// Get the number of available extractors.
  /// Returns 0 if not initialized.
  Future<int> get extractorCount async {
    try {
      final result = await _platform.invokeMethod('getPluginStatus');
      final status = Map<String, dynamic>.from(result as Map);
      return status['extractorCount'] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Initialize the extractor service.
  /// This is typically called automatically by CloudStreamExtensions.initialize().
  Future<bool> initialize() async {
    try {
      final result = await _platform.invokeMethod('initializePlugins');
      final resultMap = Map<String, dynamic>.from(result as Map);
      _isInitialized.value = resultMap['success'] == true;
      return _isInitialized.value;
    } catch (e) {
      debugPrint('ExtractorService: Failed to initialize: $e');
      lastError.value = e.toString();
      return false;
    }
  }

  /// Extract video links from a URL using CloudStream extractors.
  ///
  /// This method automatically finds the appropriate extractor based on the URL
  /// and returns the extracted video links and subtitles.
  ///
  /// Example usage:
  /// ```dart
  /// final result = await ExtractorService().extract(
  ///   'https://example.com/video/123',
  ///   referer: 'https://example.com',
  /// );
  /// if (result.success) {
  ///   for (final link in result.links) {
  ///     print('Found video: ${link.url} (${link.quality}p)');
  ///   }
  /// }
  /// ```
  Future<ExtractorResult> extract(String url, {String? referer}) async {
    try {
      final result = await _platform.invokeMethod('cloudstream:extract', {
        'url': url,
        'referer': referer,
      });

      return ExtractorResult.fromJson(Map<String, dynamic>.from(result as Map));
    } catch (e) {
      debugPrint('ExtractorService.extract error: $e');
      return ExtractorResult(
        success: false,
        links: [],
        subtitles: [],
        error: e.toString(),
      );
    }
  }

  /// Extract video links using a specific extractor by name.
  ///
  /// Use this when you know which extractor should handle the URL.
  /// Get available extractor names from [listExtractors].
  Future<ExtractorResult> extractWithExtractor(
    String extractorName,
    String url, {
    String? referer,
  }) async {
    try {
      final result = await _platform.invokeMethod(
        'cloudstream:extractWithExtractor',
        {'extractorName': extractorName, 'url': url, 'referer': referer},
      );

      return ExtractorResult.fromJson(Map<String, dynamic>.from(result as Map));
    } catch (e) {
      debugPrint('ExtractorService.extractWithExtractor error: $e');
      return ExtractorResult(
        success: false,
        links: [],
        subtitles: [],
        error: e.toString(),
      );
    }
  }

  /// List all available extractors.
  ///
  /// Returns information about each extractor including name, main URL,
  /// and whether it requires a referer.
  Future<List<ExtractorInfo>> listExtractors() async {
    try {
      final result = await _platform.invokeMethod('cloudstream:listExtractors');
      return (result as List)
          .map((e) => ExtractorInfo.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      debugPrint('ExtractorService.listExtractors error: $e');
      return [];
    }
  }

  /// Check if an extractor exists for a given URL.
  ///
  /// This is useful to determine if CloudStream extractors can handle
  /// a particular video URL before attempting extraction.
  Future<bool> hasExtractorForUrl(String url) async {
    final extractors = await listExtractors();
    final lowerUrl = url.toLowerCase();

    for (final extractor in extractors) {
      final mainUrl = extractor.mainUrl
          .replaceAll('https://', '')
          .replaceAll('http://', '');
      if (lowerUrl.contains(mainUrl)) {
        return true;
      }
    }
    return false;
  }

  /// Find extractors that might handle a given URL.
  Future<List<ExtractorInfo>> findExtractorsForUrl(String url) async {
    final extractors = await listExtractors();
    final lowerUrl = url.toLowerCase();

    return extractors.where((extractor) {
      final mainUrl = extractor.mainUrl
          .replaceAll('https://', '')
          .replaceAll('http://', '');
      return lowerUrl.contains(mainUrl);
    }).toList();
  }

  /// Get the count of available extractors.
  Future<int> getExtractorCount() async {
    final extractors = await listExtractors();
    return extractors.length;
  }
}

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

  Map<String, dynamic> toJson() => {
    'success': success,
    'links': links.map((e) => e.toJson()).toList(),
    'subtitles': subtitles.map((e) => e.toJson()).toList(),
    'error': error,
  };

  /// Check if extraction was successful and has at least one link.
  bool get hasLinks => success && links.isNotEmpty;

  /// Get the best quality link (highest quality value).
  ExtractedLink? get bestQualityLink {
    if (links.isEmpty) return null;
    return links.reduce((a, b) => a.quality > b.quality ? a : b);
  }

  /// Get links sorted by quality (highest first).
  List<ExtractedLink> get linksByQuality {
    final sorted = List<ExtractedLink>.from(links);
    sorted.sort((a, b) => b.quality.compareTo(a.quality));
    return sorted;
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

  Map<String, dynamic> toJson() => {
    'source': source,
    'name': name,
    'url': url,
    'referer': referer,
    'quality': quality,
    'headers': headers,
    'extractorData': extractorData,
    'type': type,
    'isM3u8': isM3u8,
    'isDash': isDash,
  };

  /// Get quality as a display string (e.g., "1080p", "720p").
  String get qualityString => quality > 0 ? '${quality}p' : 'Unknown';

  /// Check if this is an HLS stream.
  bool get isHls => isM3u8 || type == 'M3U8';

  /// Check if this is a DASH stream.
  bool get isDashStream => isDash || type == 'DASH';

  /// Check if this is a direct video file.
  bool get isDirectVideo => type == 'VIDEO' && !isM3u8 && !isDash;
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

  Map<String, dynamic> toJson() => {'lang': lang, 'url': url};
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

  Map<String, dynamic> toJson() => {
    'name': name,
    'mainUrl': mainUrl,
    'requiresReferer': requiresReferer,
    'sourcePlugin': sourcePlugin,
  };

  /// Check if this extractor is from a plugin (vs built-in).
  bool get isFromPlugin => sourcePlugin != null && sourcePlugin!.isNotEmpty;
}
