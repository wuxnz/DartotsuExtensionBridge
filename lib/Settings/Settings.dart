import 'package:isar_community/isar.dart';

part 'Settings.g.dart';

@collection
@Name("BridgeSettings")
class BridgeSettings {
  Id? id;
  String? currentManager;
  List<String> sortedAnimeExtensions;
  List<String> sortedMangaExtensions;
  List<String> sortedNovelExtensions;
  List<String> aniyomiAnimeExtensions;
  List<String> aniyomiMangaExtensions;

  List<String> mangayomiAnimeExtensions;
  List<String> mangayomiMangaExtensions;
  List<String> mangayomiNovelExtensions;

  List<String> cloudstreamAnimeExtensions;
  List<String> cloudstreamMangaExtensions;
  List<String> cloudstreamNovelExtensions;
  List<String> cloudstreamMovieExtensions;
  List<String> cloudstreamTvShowExtensions;
  List<String> cloudstreamCartoonExtensions;
  List<String> cloudstreamDocumentaryExtensions;
  List<String> cloudstreamLivestreamExtensions;
  List<String> cloudstreamNsfwExtensions;

  List<String> lnreaderNovelExtensions;

  BridgeSettings({
    this.currentManager,
    this.sortedAnimeExtensions = const [],
    this.sortedMangaExtensions = const [],
    this.sortedNovelExtensions = const [],
    this.aniyomiAnimeExtensions = const [],
    this.aniyomiMangaExtensions = const [],
    this.mangayomiAnimeExtensions = const [],
    this.mangayomiMangaExtensions = const [],
    this.mangayomiNovelExtensions = const [],
    this.cloudstreamAnimeExtensions = const [],
    this.cloudstreamMangaExtensions = const [],
    this.cloudstreamNovelExtensions = const [],
    this.cloudstreamMovieExtensions = const [],
    this.cloudstreamTvShowExtensions = const [],
    this.cloudstreamCartoonExtensions = const [],
    this.cloudstreamDocumentaryExtensions = const [],
    this.cloudstreamLivestreamExtensions = const [],
    this.cloudstreamNsfwExtensions = const [],
    this.lnreaderNovelExtensions = const [],
  });
}

@collection
@Name('CloudStreamPluginData')
class CloudStreamPluginData {
  Id id = Isar.autoIncrement;

  late String internalName;
  String? repoUrl;
  String? pluginListUrl;
  String? downloadUrl;
  String? version;

  List<String> tvTypes;
  String? lang;
  bool isNsfw;
  List<int> itemTypes;

  String? localPath;
  DateTime? lastUpdated;

  @Enumerated(EnumType.name)
  CloudStreamPluginStatus status;

  CloudStreamPluginData({
    required this.internalName,
    this.repoUrl,
    this.pluginListUrl,
    this.downloadUrl,
    this.version,
    this.tvTypes = const [],
    this.lang,
    this.isNsfw = false,
    this.itemTypes = const [],
    this.localPath,
    this.lastUpdated,
    this.status = CloudStreamPluginStatus.installed,
  });
}

enum CloudStreamPluginStatus { installed, disabled }
