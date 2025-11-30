class DEpisode {
  String? url;
  String? name;
  String? dateUpload;
  String? scanlator;
  String? thumbnail;
  String? description;
  bool? filler;
  String episodeNumber;

  DEpisode({
    this.url,
    this.name,
    this.dateUpload,
    this.scanlator,
    this.thumbnail,
    this.description,
    this.filler,
    required this.episodeNumber,
  });

  factory DEpisode.fromJson(Map<String, dynamic> json) {
    double? episodeNum =
        double.tryParse(json['episodeNumber']?.toString() ?? '') ??
        double.tryParse(json['episode_number']?.toString() ?? '');

    String episodeStr;
    if (episodeNum != null) {
      episodeStr = episodeNum == episodeNum.toInt()
          ? episodeNum.toInt().toString()
          : episodeNum.toString();
    } else {
      episodeStr = '';
    }
    String? _stringify(dynamic value) => value?.toString();

    return DEpisode(
      url: _stringify(json['url']),
      name: _stringify(json['name']),
      dateUpload: _stringify(json['dateUpload'] ?? json['date_upload']),
      scanlator: _stringify(json['scanlator']),
      thumbnail: _stringify(json['thumbnail']),
      description: _stringify(json['description']),
      filler: json['filler'] is bool ? json['filler'] as bool : null,
      episodeNumber: episodeStr,
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'name': name,
    'dateUpload': dateUpload,
    'scanlator': scanlator,
    'thumbnail': thumbnail,
    'description': description,
    'filler': filler,
    'episodeNumber': episodeNumber,
  };
}
