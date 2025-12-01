import 'package:dartotsu_extension_bridge/ExtensionManager.dart'
    show ExtensionType;

class Source {
  String? id;

  String? name;

  String? baseUrl;

  String? lang;

  bool? isNsfw;

  String? iconUrl;

  String? version;

  String? versionLast;

  ItemType? itemType;

  bool? isObsolete;

  String? repo;

  bool? hasUpdate;

  String? apkUrl;

  String? apkName;

  ExtensionType? extensionType;

  /// CloudStream tvTypes from plugin manifest (e.g., ['Anime', 'Movie', 'TvSeries'])
  /// Used to compute all applicable ItemTypes for cross-category plugin support.
  List<String>? tvTypes;

  /// Whether this source can be executed on desktop platforms.
  /// For CloudStream: true if plugin has JS code, false if DEX-only.
  /// For other extension types: typically true on their supported platforms.
  bool? isExecutableOnDesktop;

  Source({
    this.id = '',
    this.name = '',
    this.baseUrl = '',
    this.lang = '',
    this.iconUrl = '',
    this.isNsfw = false,
    this.version = "0.0.1",
    this.versionLast = "0.0.1",
    this.itemType = ItemType.manga,
    this.isObsolete = false,
    this.repo,
    this.hasUpdate = false,
    this.extensionType = ExtensionType.mangayomi,
    this.apkUrl = '',
    this.apkName = '',
    this.tvTypes,
    this.isExecutableOnDesktop,
  });

  Source.fromJson(Map<String, dynamic> json) {
    baseUrl = json['baseUrl'];
    iconUrl = json['iconUrl'];
    apkUrl = json['apkUrl'];
    apkName = json['apkName'];
    id = json['id'].toString();
    itemType = ItemType.values[json['itemType'] ?? 0];
    isNsfw = json['isNsfw'];
    lang = json['lang'];
    name = json['name'];
    version = json['version'];
    versionLast = json['versionLast'];
    isObsolete = json['isObsolete'];
    repo = json['repo'];
    hasUpdate = json['hasUpdate'] ?? false;
    extensionType = ExtensionType.values[json['extensionType'] ?? 0];
    tvTypes = (json['tvTypes'] as List?)?.map((e) => e.toString()).toList();
    isExecutableOnDesktop = json['isExecutableOnDesktop'] as bool?;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'baseUrl': baseUrl,
    'apkUrl': apkUrl,
    'apkName': apkName,
    'lang': lang,
    'iconUrl': iconUrl,
    'isNsfw': isNsfw,
    'version': version,
    'versionLast': versionLast,
    'itemType': itemType?.index ?? 0,
    'isObsolete': isObsolete,
    'repo': repo,
    'hasUpdate': hasUpdate,
    'extensionType': extensionType?.index ?? 0,
    'tvTypes': tvTypes,
    'isExecutableOnDesktop': isExecutableOnDesktop,
  };
}

enum ItemType {
  manga,
  anime,
  novel,
  movie,
  tvShow,
  cartoon,
  documentary,
  livestream,
  nsfw;

  @override
  String toString() {
    switch (this) {
      case ItemType.manga:
        return 'Manga';
      case ItemType.anime:
        return 'Anime';
      case ItemType.novel:
        return 'Novel';
      case ItemType.movie:
        return 'Movie';
      case ItemType.tvShow:
        return 'TV Show';
      case ItemType.cartoon:
        return 'Cartoon';
      case ItemType.documentary:
        return 'Documentary';
      case ItemType.livestream:
        return 'Livestream';
      case ItemType.nsfw:
        return 'NSFW';
    }
  }
}
