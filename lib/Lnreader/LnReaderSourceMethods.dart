import 'package:dartotsu_extension_bridge/Models/DEpisode.dart';
import 'package:dartotsu_extension_bridge/Models/DMedia.dart';
import 'package:dartotsu_extension_bridge/Models/Page.dart';
import 'package:dartotsu_extension_bridge/Models/Pages.dart';
import 'package:dartotsu_extension_bridge/Models/Source.dart';
import 'package:dartotsu_extension_bridge/Models/SourcePreference.dart';
import 'package:dartotsu_extension_bridge/Models/Video.dart';
import 'package:flutter/foundation.dart';
import '../Extensions/SourceMethods.dart';
import '../Mangayomi/Eval/dart/model/m_manga.dart';
import '../Mangayomi/Eval/dart/model/m_chapter.dart';
import '../Mangayomi/Models/Source.dart' as mangayomi;
import 'service.dart';

/// LnReader-specific implementation of SourceMethods interface.
///
/// This class handles communication with LnReader JavaScript-based plugins
/// that execute in a QuickJS runtime. It delegates all operations to
/// LNReaderExtensionService and converts between Mangayomi models (MManga, MPages)
/// and DartotsuExtensionBridge models (DMedia, Pages).
class LnReaderSourceMethods implements SourceMethods {
  @override
  Source source;

  late final LNReaderExtensionService _service;

  LnReaderSourceMethods(this.source) {
    // Convert Source to MSource for the service
    final mSource = _convertToMSource(source);
    _service = LNReaderExtensionService(mSource);
  }

  /// Convert DartotsuExtensionBridge Source to Mangayomi MSource
  ///
  /// LNReaderExtensionService expects an MSource object, so we need to convert
  /// the Source object passed to this class. The source code is stored in the
  /// apkUrl field temporarily (as per task 5 implementation).
  mangayomi.MSource _convertToMSource(Source source) {
    return mangayomi.MSource(
      sourceId: source.id,
      pluginId: source.id,
      name: source.name,
      baseUrl: source.baseUrl,
      lang: source.lang,
      iconUrl: source.iconUrl,
      version: source.version,
      sourceCode: source.apkUrl, // Source code is stored in apkUrl field
      itemType: source.itemType ?? ItemType.novel,
      isAdded: true,
      isActive: true,
      repo: source.repo,
      sourceCodeLanguage: mangayomi.SourceCodeLanguage.lnreader,
    );
  }

  @override
  Future<Pages> getPopular(int page) async {
    try {
      final mPages = await _service.getPopular(page);
      return _convertMPagesToPages(mPages);
    } catch (e) {
      debugPrint('Error getting popular novels: $e');
      return Pages(hasNextPage: false, list: []);
    }
  }

  @override
  Future<Pages> getLatestUpdates(int page) async {
    try {
      final mPages = await _service.getLatestUpdates(page);
      return _convertMPagesToPages(mPages);
    } catch (e) {
      debugPrint('Error getting latest updates: $e');
      return Pages(hasNextPage: false, list: []);
    }
  }

  @override
  Future<Pages> search(String query, int page, List<dynamic> filters) async {
    try {
      final mPages = await _service.search(query, page, filters);
      return _convertMPagesToPages(mPages);
    } catch (e) {
      debugPrint('Error searching novels: $e');
      return Pages(hasNextPage: false, list: []);
    }
  }

  @override
  Future<DMedia> getDetail(DMedia media) async {
    try {
      final mManga = await _service.getDetail(media.url ?? '');
      return _convertMMangaToDMedia(mManga);
    } catch (e) {
      debugPrint('Error getting novel detail: $e');
      rethrow;
    }
  }

  @override
  Future<List<PageUrl>> getPageList(DEpisode episode) async {
    // LnReader doesn't support page-based content (manga/comics)
    return [];
  }

  @override
  Future<List<Video>> getVideoList(DEpisode episode) async {
    // LnReader doesn't support video content
    return [];
  }

  @override
  Future<String?> getNovelContent(String chapterTitle, String chapterId) async {
    try {
      final content = await _service.getHtmlContent(chapterTitle, chapterId);
      return content;
    } catch (e) {
      debugPrint('Error getting novel content: $e');
      return null;
    }
  }

  @override
  Future<List<SourcePreference>> getPreference() async {
    try {
      final prefs = _service.getSourcePreferences();
      return prefs.map((pref) => _convertToSourcePreference(pref)).toList();
    } catch (e) {
      debugPrint('Error getting preferences: $e');
      return const [];
    }
  }

  @override
  Future<bool> setPreference(SourcePreference pref, dynamic value) async {
    // LnReader plugins don't currently support setting preferences at runtime
    // This would require modifying the JavaScript runtime state
    debugPrint('Setting preferences not supported for LnReader plugins');
    return false;
  }

  /// Convert Mangayomi MPages to DartotsuExtensionBridge Pages
  Pages _convertMPagesToPages(dynamic mPages) {
    final list = (mPages.list as List)
        .map((mManga) => _convertMMangaToDMedia(mManga))
        .toList();
    return Pages(list: list, hasNextPage: mPages.hasNextPage);
  }

  /// Convert Mangayomi MManga to DartotsuExtensionBridge DMedia
  DMedia _convertMMangaToDMedia(MManga mManga) {
    final episodes = mManga.chapters
        ?.map((mChapter) => _convertMChapterToDEpisode(mChapter))
        .toList();

    return DMedia(
      title: mManga.name,
      url: mManga.link,
      cover: mManga.imageUrl,
      description: mManga.description,
      author: mManga.author,
      artist: mManga.artist,
      genre: mManga.genre,
      episodes: episodes,
    );
  }

  /// Convert Mangayomi MChapter to DartotsuExtensionBridge DEpisode
  DEpisode _convertMChapterToDEpisode(MChapter mChapter) {
    return DEpisode(
      url: mChapter.url,
      name: mChapter.name,
      dateUpload: mChapter.dateUpload,
      scanlator: mChapter.scanlator,
      thumbnail: mChapter.thumbnailUrl,
      description: mChapter.description,
      filler: mChapter.isFiller,
      episodeNumber: '', // LnReader chapters don't have episode numbers
    );
  }

  /// Convert Mangayomi SourcePreference to DartotsuExtensionBridge SourcePreference
  SourcePreference _convertToSourcePreference(dynamic mangayomiPref) {
    // The Mangayomi SourcePreference and DartotsuExtensionBridge SourcePreference
    // have the same structure, so we can pass through directly
    return mangayomiPref as SourcePreference;
  }
}
