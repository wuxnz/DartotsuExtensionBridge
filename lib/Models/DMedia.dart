import 'dart:convert';
import 'package:dartotsu_extension_bridge/Models/DEpisode.dart';

class DMedia {
  String? title;
  String? url;
  String? rawUrl;
  String? cover;
  String? description;
  String? author;
  String? artist;
  List<String>? genre;
  List<DEpisode>? episodes;

  DMedia({
    this.title,
    this.url,
    this.rawUrl,
    this.cover,
    this.description,
    this.author,
    this.artist,
    this.genre,
    this.episodes,
  });

  factory DMedia.fromJson(Map<String, dynamic> json) {
    String? _stringify(dynamic value) => value?.toString();

    List<DEpisode> _parseEpisodes(dynamic value) {
      if (value is List) {
        return value
            .map((e) {
              if (e is Map<String, dynamic>) {
                return DEpisode.fromJson(e);
              } else if (e is Map) {
                return DEpisode.fromJson(Map<String, dynamic>.from(e));
              }
              return null;
            })
            .whereType<DEpisode>()
            .toList();
      }
      return [];
    }

    final rawUrl = _stringify(json['url']);
    final sanitizedUrl = _CloudStreamUrlCodec.sanitize(rawUrl);

    return DMedia(
      title: _stringify(json['title']),
      url: sanitizedUrl,
      rawUrl: rawUrl,
      cover: _stringify(json['cover']),
      description: _stringify(json['description']),
      artist: _stringify(json['artist']),
      author: _stringify(json['author']),
      genre: json['genre'] != null
          ? List<String>.from(
              (json['genre'] as List).map((value) => value.toString()),
            )
          : [],
      episodes: _parseEpisodes(json['episodes']),
    );
  }

  factory DMedia.withUrl(String url) {
    final decoded = _CloudStreamUrlCodec.desanitize(url);
    return DMedia(
      title: '',
      url: _CloudStreamUrlCodec.sanitize(decoded),
      rawUrl: decoded,
      cover: '',
      description: '',
      artist: '',
      author: '',
      genre: [],
      episodes: [],
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'url': rawUrl ?? url,
    'cover': cover,
    'description': description,
    'author': author,
    'artist': artist,
    'genre': genre,
    'episodes': episodes?.map((e) => e.toJson()).toList(),
  };
}

class _CloudStreamUrlCodec {
  static const String prefix = 'csjson://';

  static String sanitize(String? raw) {
    final value = raw?.trim();
    if (value == null || value.isEmpty) return value ?? '';
    final firstChar = value[0];
    if (firstChar != '{' && firstChar != '[') {
      return value;
    }
    final encoded = base64Url.encode(utf8.encode(value));
    return '$prefix$encoded';
  }

  static String desanitize(String value) {
    if (value.startsWith(prefix)) {
      final payload = value.substring(prefix.length);
      try {
        return utf8.decode(base64Url.decode(payload));
      } catch (_) {
        return value;
      }
    }
    return value;
  }
}
