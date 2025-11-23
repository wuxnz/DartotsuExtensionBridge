import 'package:get/get.dart';

import '../Models/Source.dart';

abstract class Extension extends GetxController {
  var isInitialized = false.obs;

  bool get supportsAnime => true;
  bool get supportsManga => true;
  bool get supportsNovel => true;
  bool get supportsMovie => false;
  bool get supportsTvShow => false;
  bool get supportsCartoon => false;
  bool get supportsDocumentary => false;
  bool get supportsLivestream => false;
  bool get supportsNsfw => false;

  final Rx<List<Source>> installedAnimeExtensions = Rx([]);
  final Rx<List<Source>> installedMangaExtensions = Rx([]);
  final Rx<List<Source>> installedNovelExtensions = Rx([]);
  final Rx<List<Source>> installedMovieExtensions = Rx([]);
  final Rx<List<Source>> installedTvShowExtensions = Rx([]);
  final Rx<List<Source>> installedCartoonExtensions = Rx([]);
  final Rx<List<Source>> installedDocumentaryExtensions = Rx([]);
  final Rx<List<Source>> installedLivestreamExtensions = Rx([]);
  final Rx<List<Source>> installedNsfwExtensions = Rx([]);
  final Rx<List<Source>> availableAnimeExtensions = Rx([]);
  final Rx<List<Source>> availableMangaExtensions = Rx([]);
  final Rx<List<Source>> availableNovelExtensions = Rx([]);
  final Rx<List<Source>> availableMovieExtensions = Rx([]);
  final Rx<List<Source>> availableTvShowExtensions = Rx([]);
  final Rx<List<Source>> availableCartoonExtensions = Rx([]);
  final Rx<List<Source>> availableDocumentaryExtensions = Rx([]);
  final Rx<List<Source>> availableLivestreamExtensions = Rx([]);
  final Rx<List<Source>> availableNsfwExtensions = Rx([]);

  Future<List<Source>> getInstalledAnimeExtensions() => Future.value([]);

  Future<List<Source>> fetchAvailableAnimeExtensions(List<String>? repos) =>
      Future.value([]);

  Future<List<Source>> getInstalledMangaExtensions() => Future.value([]);

  Future<List<Source>> fetchAvailableMangaExtensions(List<String>? repos) =>
      Future.value([]);

  Future<List<Source>> getInstalledNovelExtensions() => Future.value([]);

  Future<List<Source>> fetchAvailableNovelExtensions(List<String>? repos) =>
      Future.value([]);

  Future<List<Source>> getInstalledMovieExtensions() => Future.value([]);

  Future<List<Source>> fetchAvailableMovieExtensions(List<String>? repos) =>
      Future.value([]);

  Future<List<Source>> getInstalledTvShowExtensions() => Future.value([]);

  Future<List<Source>> fetchAvailableTvShowExtensions(List<String>? repos) =>
      Future.value([]);

  Future<List<Source>> getInstalledCartoonExtensions() => Future.value([]);

  Future<List<Source>> fetchAvailableCartoonExtensions(List<String>? repos) =>
      Future.value([]);

  Future<List<Source>> getInstalledDocumentaryExtensions() => Future.value([]);

  Future<List<Source>> fetchAvailableDocumentaryExtensions(
    List<String>? repos,
  ) => Future.value([]);

  Future<List<Source>> getInstalledLivestreamExtensions() => Future.value([]);

  Future<List<Source>> fetchAvailableLivestreamExtensions(
    List<String>? repos,
  ) => Future.value([]);

  Future<List<Source>> getInstalledNsfwExtensions() => Future.value([]);

  Future<List<Source>> fetchAvailableNsfwExtensions(List<String>? repos) =>
      Future.value([]);

  Future<void> initialize();

  Future<void> installSource(Source source);

  Future<void> uninstallSource(Source source);

  Future<void> updateSource(Source source);

  Future<void> onRepoSaved(List<String> repoUrl, ItemType type) async {
    if (repoUrl.isEmpty) return;
    switch (type) {
      case ItemType.anime:
        await fetchAvailableAnimeExtensions(repoUrl);
        break;
      case ItemType.manga:
        await fetchAvailableMangaExtensions(repoUrl);
        break;
      case ItemType.novel:
        await fetchAvailableNovelExtensions(repoUrl);
        break;
      case ItemType.movie:
        await fetchAvailableMovieExtensions(repoUrl);
        break;
      case ItemType.tvShow:
        await fetchAvailableTvShowExtensions(repoUrl);
        break;
      case ItemType.cartoon:
        await fetchAvailableCartoonExtensions(repoUrl);
        break;
      case ItemType.documentary:
        await fetchAvailableDocumentaryExtensions(repoUrl);
        break;
      case ItemType.livestream:
        await fetchAvailableLivestreamExtensions(repoUrl);
        break;
      case ItemType.nsfw:
        await fetchAvailableNsfwExtensions(repoUrl);
        break;
    }
  }

  Rx<List<Source>> getSortedInstalledExtension(ItemType itemType) {
    switch (itemType) {
      case ItemType.anime:
        return installedAnimeExtensions;
      case ItemType.manga:
        return installedMangaExtensions;
      case ItemType.novel:
        return installedNovelExtensions;
      case ItemType.movie:
        return installedMovieExtensions;
      case ItemType.tvShow:
        return installedTvShowExtensions;
      case ItemType.cartoon:
        return installedCartoonExtensions;
      case ItemType.documentary:
        return installedDocumentaryExtensions;
      case ItemType.livestream:
        return installedLivestreamExtensions;
      case ItemType.nsfw:
        return installedNsfwExtensions;
    }
  }

  Rx<List<Source>> getAvailableRx(ItemType type) {
    switch (type) {
      case ItemType.anime:
        return availableAnimeExtensions;
      case ItemType.manga:
        return availableMangaExtensions;
      case ItemType.novel:
        return availableNovelExtensions;
      case ItemType.movie:
        return availableMovieExtensions;
      case ItemType.tvShow:
        return availableTvShowExtensions;
      case ItemType.cartoon:
        return availableCartoonExtensions;
      case ItemType.documentary:
        return availableDocumentaryExtensions;
      case ItemType.livestream:
        return availableLivestreamExtensions;
      case ItemType.nsfw:
        return availableNsfwExtensions;
    }
  }

  Rx<List<Source>> getInstalledRx(ItemType type) {
    switch (type) {
      case ItemType.anime:
        return installedAnimeExtensions;
      case ItemType.manga:
        return installedMangaExtensions;
      case ItemType.novel:
        return installedNovelExtensions;
      case ItemType.movie:
        return installedMovieExtensions;
      case ItemType.tvShow:
        return installedTvShowExtensions;
      case ItemType.cartoon:
        return installedCartoonExtensions;
      case ItemType.documentary:
        return installedDocumentaryExtensions;
      case ItemType.livestream:
        return installedLivestreamExtensions;
      case ItemType.nsfw:
        return installedNsfwExtensions;
    }
  }

  int compareVersions(String v1, String v2) {
    final a = v1.split('.').map(int.tryParse).toList();
    final b = v2.split('.').map(int.tryParse).toList();

    for (int i = 0; i < a.length || i < b.length; i++) {
      final n1 = i < a.length ? a[i] ?? 0 : 0;
      final n2 = i < b.length ? b[i] ?? 0 : 0;
      if (n1 != n2) return n1.compareTo(n2);
    }
    return 0;
  }
}
