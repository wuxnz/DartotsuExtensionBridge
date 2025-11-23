// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Settings.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetBridgeSettingsCollection on Isar {
  IsarCollection<BridgeSettings> get bridgeSettings => this.collection();
}

const BridgeSettingsSchema = CollectionSchema(
  name: r'BridgeSettings',
  id: 8010510632874811587,
  properties: {
    r'aniyomiAnimeExtensions': PropertySchema(
      id: 0,
      name: r'aniyomiAnimeExtensions',
      type: IsarType.stringList,
    ),
    r'aniyomiMangaExtensions': PropertySchema(
      id: 1,
      name: r'aniyomiMangaExtensions',
      type: IsarType.stringList,
    ),
    r'cloudstreamAnimeExtensions': PropertySchema(
      id: 2,
      name: r'cloudstreamAnimeExtensions',
      type: IsarType.stringList,
    ),
    r'cloudstreamCartoonExtensions': PropertySchema(
      id: 3,
      name: r'cloudstreamCartoonExtensions',
      type: IsarType.stringList,
    ),
    r'cloudstreamDocumentaryExtensions': PropertySchema(
      id: 4,
      name: r'cloudstreamDocumentaryExtensions',
      type: IsarType.stringList,
    ),
    r'cloudstreamLivestreamExtensions': PropertySchema(
      id: 5,
      name: r'cloudstreamLivestreamExtensions',
      type: IsarType.stringList,
    ),
    r'cloudstreamMangaExtensions': PropertySchema(
      id: 6,
      name: r'cloudstreamMangaExtensions',
      type: IsarType.stringList,
    ),
    r'cloudstreamMovieExtensions': PropertySchema(
      id: 7,
      name: r'cloudstreamMovieExtensions',
      type: IsarType.stringList,
    ),
    r'cloudstreamNovelExtensions': PropertySchema(
      id: 8,
      name: r'cloudstreamNovelExtensions',
      type: IsarType.stringList,
    ),
    r'cloudstreamNsfwExtensions': PropertySchema(
      id: 9,
      name: r'cloudstreamNsfwExtensions',
      type: IsarType.stringList,
    ),
    r'cloudstreamTvShowExtensions': PropertySchema(
      id: 10,
      name: r'cloudstreamTvShowExtensions',
      type: IsarType.stringList,
    ),
    r'currentManager': PropertySchema(
      id: 11,
      name: r'currentManager',
      type: IsarType.string,
    ),
    r'lnreaderNovelExtensions': PropertySchema(
      id: 12,
      name: r'lnreaderNovelExtensions',
      type: IsarType.stringList,
    ),
    r'mangayomiAnimeExtensions': PropertySchema(
      id: 13,
      name: r'mangayomiAnimeExtensions',
      type: IsarType.stringList,
    ),
    r'mangayomiMangaExtensions': PropertySchema(
      id: 14,
      name: r'mangayomiMangaExtensions',
      type: IsarType.stringList,
    ),
    r'mangayomiNovelExtensions': PropertySchema(
      id: 15,
      name: r'mangayomiNovelExtensions',
      type: IsarType.stringList,
    ),
    r'sortedAnimeExtensions': PropertySchema(
      id: 16,
      name: r'sortedAnimeExtensions',
      type: IsarType.stringList,
    ),
    r'sortedMangaExtensions': PropertySchema(
      id: 17,
      name: r'sortedMangaExtensions',
      type: IsarType.stringList,
    ),
    r'sortedNovelExtensions': PropertySchema(
      id: 18,
      name: r'sortedNovelExtensions',
      type: IsarType.stringList,
    ),
  },

  estimateSize: _bridgeSettingsEstimateSize,
  serialize: _bridgeSettingsSerialize,
  deserialize: _bridgeSettingsDeserialize,
  deserializeProp: _bridgeSettingsDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},

  getId: _bridgeSettingsGetId,
  getLinks: _bridgeSettingsGetLinks,
  attach: _bridgeSettingsAttach,
  version: '3.3.0',
);

int _bridgeSettingsEstimateSize(
  BridgeSettings object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aniyomiAnimeExtensions.length * 3;
  {
    for (var i = 0; i < object.aniyomiAnimeExtensions.length; i++) {
      final value = object.aniyomiAnimeExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.aniyomiMangaExtensions.length * 3;
  {
    for (var i = 0; i < object.aniyomiMangaExtensions.length; i++) {
      final value = object.aniyomiMangaExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.cloudstreamAnimeExtensions.length * 3;
  {
    for (var i = 0; i < object.cloudstreamAnimeExtensions.length; i++) {
      final value = object.cloudstreamAnimeExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.cloudstreamCartoonExtensions.length * 3;
  {
    for (var i = 0; i < object.cloudstreamCartoonExtensions.length; i++) {
      final value = object.cloudstreamCartoonExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.cloudstreamDocumentaryExtensions.length * 3;
  {
    for (var i = 0; i < object.cloudstreamDocumentaryExtensions.length; i++) {
      final value = object.cloudstreamDocumentaryExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.cloudstreamLivestreamExtensions.length * 3;
  {
    for (var i = 0; i < object.cloudstreamLivestreamExtensions.length; i++) {
      final value = object.cloudstreamLivestreamExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.cloudstreamMangaExtensions.length * 3;
  {
    for (var i = 0; i < object.cloudstreamMangaExtensions.length; i++) {
      final value = object.cloudstreamMangaExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.cloudstreamMovieExtensions.length * 3;
  {
    for (var i = 0; i < object.cloudstreamMovieExtensions.length; i++) {
      final value = object.cloudstreamMovieExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.cloudstreamNovelExtensions.length * 3;
  {
    for (var i = 0; i < object.cloudstreamNovelExtensions.length; i++) {
      final value = object.cloudstreamNovelExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.cloudstreamNsfwExtensions.length * 3;
  {
    for (var i = 0; i < object.cloudstreamNsfwExtensions.length; i++) {
      final value = object.cloudstreamNsfwExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.cloudstreamTvShowExtensions.length * 3;
  {
    for (var i = 0; i < object.cloudstreamTvShowExtensions.length; i++) {
      final value = object.cloudstreamTvShowExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.currentManager;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.lnreaderNovelExtensions.length * 3;
  {
    for (var i = 0; i < object.lnreaderNovelExtensions.length; i++) {
      final value = object.lnreaderNovelExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.mangayomiAnimeExtensions.length * 3;
  {
    for (var i = 0; i < object.mangayomiAnimeExtensions.length; i++) {
      final value = object.mangayomiAnimeExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.mangayomiMangaExtensions.length * 3;
  {
    for (var i = 0; i < object.mangayomiMangaExtensions.length; i++) {
      final value = object.mangayomiMangaExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.mangayomiNovelExtensions.length * 3;
  {
    for (var i = 0; i < object.mangayomiNovelExtensions.length; i++) {
      final value = object.mangayomiNovelExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.sortedAnimeExtensions.length * 3;
  {
    for (var i = 0; i < object.sortedAnimeExtensions.length; i++) {
      final value = object.sortedAnimeExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.sortedMangaExtensions.length * 3;
  {
    for (var i = 0; i < object.sortedMangaExtensions.length; i++) {
      final value = object.sortedMangaExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.sortedNovelExtensions.length * 3;
  {
    for (var i = 0; i < object.sortedNovelExtensions.length; i++) {
      final value = object.sortedNovelExtensions[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _bridgeSettingsSerialize(
  BridgeSettings object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeStringList(offsets[0], object.aniyomiAnimeExtensions);
  writer.writeStringList(offsets[1], object.aniyomiMangaExtensions);
  writer.writeStringList(offsets[2], object.cloudstreamAnimeExtensions);
  writer.writeStringList(offsets[3], object.cloudstreamCartoonExtensions);
  writer.writeStringList(offsets[4], object.cloudstreamDocumentaryExtensions);
  writer.writeStringList(offsets[5], object.cloudstreamLivestreamExtensions);
  writer.writeStringList(offsets[6], object.cloudstreamMangaExtensions);
  writer.writeStringList(offsets[7], object.cloudstreamMovieExtensions);
  writer.writeStringList(offsets[8], object.cloudstreamNovelExtensions);
  writer.writeStringList(offsets[9], object.cloudstreamNsfwExtensions);
  writer.writeStringList(offsets[10], object.cloudstreamTvShowExtensions);
  writer.writeString(offsets[11], object.currentManager);
  writer.writeStringList(offsets[12], object.lnreaderNovelExtensions);
  writer.writeStringList(offsets[13], object.mangayomiAnimeExtensions);
  writer.writeStringList(offsets[14], object.mangayomiMangaExtensions);
  writer.writeStringList(offsets[15], object.mangayomiNovelExtensions);
  writer.writeStringList(offsets[16], object.sortedAnimeExtensions);
  writer.writeStringList(offsets[17], object.sortedMangaExtensions);
  writer.writeStringList(offsets[18], object.sortedNovelExtensions);
}

BridgeSettings _bridgeSettingsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = BridgeSettings(
    aniyomiAnimeExtensions: reader.readStringList(offsets[0]) ?? const [],
    aniyomiMangaExtensions: reader.readStringList(offsets[1]) ?? const [],
    cloudstreamAnimeExtensions: reader.readStringList(offsets[2]) ?? const [],
    cloudstreamCartoonExtensions: reader.readStringList(offsets[3]) ?? const [],
    cloudstreamDocumentaryExtensions:
        reader.readStringList(offsets[4]) ?? const [],
    cloudstreamLivestreamExtensions:
        reader.readStringList(offsets[5]) ?? const [],
    cloudstreamMangaExtensions: reader.readStringList(offsets[6]) ?? const [],
    cloudstreamMovieExtensions: reader.readStringList(offsets[7]) ?? const [],
    cloudstreamNovelExtensions: reader.readStringList(offsets[8]) ?? const [],
    cloudstreamNsfwExtensions: reader.readStringList(offsets[9]) ?? const [],
    cloudstreamTvShowExtensions: reader.readStringList(offsets[10]) ?? const [],
    currentManager: reader.readStringOrNull(offsets[11]),
    lnreaderNovelExtensions: reader.readStringList(offsets[12]) ?? const [],
    mangayomiAnimeExtensions: reader.readStringList(offsets[13]) ?? const [],
    mangayomiMangaExtensions: reader.readStringList(offsets[14]) ?? const [],
    mangayomiNovelExtensions: reader.readStringList(offsets[15]) ?? const [],
    sortedAnimeExtensions: reader.readStringList(offsets[16]) ?? const [],
    sortedMangaExtensions: reader.readStringList(offsets[17]) ?? const [],
    sortedNovelExtensions: reader.readStringList(offsets[18]) ?? const [],
  );
  object.id = id;
  return object;
}

P _bridgeSettingsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringList(offset) ?? const []) as P;
    case 1:
      return (reader.readStringList(offset) ?? const []) as P;
    case 2:
      return (reader.readStringList(offset) ?? const []) as P;
    case 3:
      return (reader.readStringList(offset) ?? const []) as P;
    case 4:
      return (reader.readStringList(offset) ?? const []) as P;
    case 5:
      return (reader.readStringList(offset) ?? const []) as P;
    case 6:
      return (reader.readStringList(offset) ?? const []) as P;
    case 7:
      return (reader.readStringList(offset) ?? const []) as P;
    case 8:
      return (reader.readStringList(offset) ?? const []) as P;
    case 9:
      return (reader.readStringList(offset) ?? const []) as P;
    case 10:
      return (reader.readStringList(offset) ?? const []) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? const []) as P;
    case 13:
      return (reader.readStringList(offset) ?? const []) as P;
    case 14:
      return (reader.readStringList(offset) ?? const []) as P;
    case 15:
      return (reader.readStringList(offset) ?? const []) as P;
    case 16:
      return (reader.readStringList(offset) ?? const []) as P;
    case 17:
      return (reader.readStringList(offset) ?? const []) as P;
    case 18:
      return (reader.readStringList(offset) ?? const []) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _bridgeSettingsGetId(BridgeSettings object) {
  return object.id ?? Isar.autoIncrement;
}

List<IsarLinkBase<dynamic>> _bridgeSettingsGetLinks(BridgeSettings object) {
  return [];
}

void _bridgeSettingsAttach(
  IsarCollection<dynamic> col,
  Id id,
  BridgeSettings object,
) {
  object.id = id;
}

extension BridgeSettingsQueryWhereSort
    on QueryBuilder<BridgeSettings, BridgeSettings, QWhere> {
  QueryBuilder<BridgeSettings, BridgeSettings, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension BridgeSettingsQueryWhere
    on QueryBuilder<BridgeSettings, BridgeSettings, QWhereClause> {
  QueryBuilder<BridgeSettings, BridgeSettings, QAfterWhereClause> idEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(lower: id, upper: id));
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterWhereClause> idNotEqualTo(
    Id id,
  ) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterWhereClause> idGreaterThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterWhereClause> idLessThan(
    Id id, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.between(
          lower: lowerId,
          includeLower: includeLower,
          upper: upperId,
          includeUpper: includeUpper,
        ),
      );
    });
  }
}

extension BridgeSettingsQueryFilter
    on QueryBuilder<BridgeSettings, BridgeSettings, QFilterCondition> {
  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aniyomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aniyomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aniyomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aniyomiAnimeExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'aniyomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'aniyomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'aniyomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'aniyomiAnimeExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aniyomiAnimeExtensions', value: ''),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'aniyomiAnimeExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aniyomiAnimeExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aniyomiAnimeExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aniyomiAnimeExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aniyomiAnimeExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aniyomiAnimeExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiAnimeExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aniyomiAnimeExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'aniyomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'aniyomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'aniyomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'aniyomiMangaExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'aniyomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'aniyomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'aniyomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'aniyomiMangaExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'aniyomiMangaExtensions', value: ''),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'aniyomiMangaExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aniyomiMangaExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'aniyomiMangaExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aniyomiMangaExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aniyomiMangaExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aniyomiMangaExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  aniyomiMangaExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'aniyomiMangaExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudstreamAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudstreamAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudstreamAnimeExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cloudstreamAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cloudstreamAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cloudstreamAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cloudstreamAnimeExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamAnimeExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'cloudstreamAnimeExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamAnimeExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cloudstreamAnimeExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamAnimeExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamAnimeExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamAnimeExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamAnimeExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamAnimeExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamCartoonExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudstreamCartoonExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudstreamCartoonExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudstreamCartoonExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cloudstreamCartoonExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cloudstreamCartoonExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cloudstreamCartoonExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cloudstreamCartoonExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamCartoonExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'cloudstreamCartoonExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamCartoonExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamCartoonExtensions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamCartoonExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamCartoonExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamCartoonExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamCartoonExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamCartoonExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamDocumentaryExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudstreamDocumentaryExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudstreamDocumentaryExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudstreamDocumentaryExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cloudstreamDocumentaryExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cloudstreamDocumentaryExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cloudstreamDocumentaryExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cloudstreamDocumentaryExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamDocumentaryExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'cloudstreamDocumentaryExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamDocumentaryExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamDocumentaryExtensions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamDocumentaryExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamDocumentaryExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamDocumentaryExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamDocumentaryExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamDocumentaryExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamLivestreamExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudstreamLivestreamExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudstreamLivestreamExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudstreamLivestreamExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cloudstreamLivestreamExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cloudstreamLivestreamExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cloudstreamLivestreamExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cloudstreamLivestreamExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamLivestreamExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'cloudstreamLivestreamExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamLivestreamExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamLivestreamExtensions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamLivestreamExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamLivestreamExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamLivestreamExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamLivestreamExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamLivestreamExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudstreamMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudstreamMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudstreamMangaExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cloudstreamMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cloudstreamMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cloudstreamMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cloudstreamMangaExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamMangaExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'cloudstreamMangaExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamMangaExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cloudstreamMangaExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamMangaExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamMangaExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamMangaExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMangaExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamMangaExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamMovieExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudstreamMovieExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudstreamMovieExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudstreamMovieExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cloudstreamMovieExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cloudstreamMovieExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cloudstreamMovieExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cloudstreamMovieExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamMovieExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'cloudstreamMovieExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamMovieExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cloudstreamMovieExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamMovieExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamMovieExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamMovieExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamMovieExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamMovieExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudstreamNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudstreamNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudstreamNovelExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cloudstreamNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cloudstreamNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cloudstreamNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cloudstreamNovelExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamNovelExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'cloudstreamNovelExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamNovelExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cloudstreamNovelExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamNovelExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamNovelExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamNovelExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNovelExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamNovelExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamNsfwExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudstreamNsfwExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudstreamNsfwExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudstreamNsfwExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cloudstreamNsfwExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cloudstreamNsfwExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cloudstreamNsfwExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cloudstreamNsfwExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamNsfwExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'cloudstreamNsfwExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamNsfwExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cloudstreamNsfwExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamNsfwExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamNsfwExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamNsfwExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamNsfwExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamNsfwExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamTvShowExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'cloudstreamTvShowExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'cloudstreamTvShowExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'cloudstreamTvShowExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'cloudstreamTvShowExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'cloudstreamTvShowExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'cloudstreamTvShowExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'cloudstreamTvShowExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'cloudstreamTvShowExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'cloudstreamTvShowExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamTvShowExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'cloudstreamTvShowExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamTvShowExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamTvShowExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamTvShowExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  cloudstreamTvShowExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'cloudstreamTvShowExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'currentManager'),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'currentManager'),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerEqualTo(String? value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'currentManager',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'currentManager',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'currentManager',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'currentManager',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'currentManager',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'currentManager',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'currentManager',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'currentManager',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'currentManager', value: ''),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  currentManagerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(property: r'currentManager', value: ''),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  idIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNull(property: r'id'),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  idIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const FilterCondition.isNotNull(property: r'id'),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition> idEqualTo(
    Id? value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'id', value: value),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  idGreaterThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  idLessThan(Id? value, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'id',
          value: value,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition> idBetween(
    Id? lower,
    Id? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'id',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lnreaderNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'lnreaderNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'lnreaderNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'lnreaderNovelExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'lnreaderNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'lnreaderNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'lnreaderNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'lnreaderNovelExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'lnreaderNovelExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'lnreaderNovelExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lnreaderNovelExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'lnreaderNovelExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lnreaderNovelExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lnreaderNovelExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lnreaderNovelExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  lnreaderNovelExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'lnreaderNovelExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mangayomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mangayomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mangayomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mangayomiAnimeExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mangayomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mangayomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mangayomiAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mangayomiAnimeExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mangayomiAnimeExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'mangayomiAnimeExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiAnimeExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mangayomiAnimeExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiAnimeExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiAnimeExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiAnimeExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiAnimeExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiAnimeExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mangayomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mangayomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mangayomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mangayomiMangaExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mangayomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mangayomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mangayomiMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mangayomiMangaExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mangayomiMangaExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'mangayomiMangaExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiMangaExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mangayomiMangaExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiMangaExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiMangaExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiMangaExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiMangaExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiMangaExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mangayomiNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'mangayomiNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'mangayomiNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'mangayomiNovelExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'mangayomiNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'mangayomiNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'mangayomiNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'mangayomiNovelExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'mangayomiNovelExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'mangayomiNovelExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiNovelExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'mangayomiNovelExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiNovelExtensions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiNovelExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiNovelExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  mangayomiNovelExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'mangayomiNovelExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sortedAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortedAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortedAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortedAnimeExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sortedAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sortedAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sortedAnimeExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sortedAnimeExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortedAnimeExtensions', value: ''),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'sortedAnimeExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedAnimeExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sortedAnimeExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sortedAnimeExtensions', 0, false, 999999, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedAnimeExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedAnimeExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedAnimeExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedAnimeExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sortedMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortedMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortedMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortedMangaExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sortedMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sortedMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sortedMangaExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sortedMangaExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortedMangaExtensions', value: ''),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'sortedMangaExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedMangaExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sortedMangaExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sortedMangaExtensions', 0, false, 999999, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedMangaExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedMangaExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedMangaExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedMangaExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(
          property: r'sortedNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          include: include,
          property: r'sortedNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.lessThan(
          include: include,
          property: r'sortedNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.between(
          property: r'sortedNovelExtensions',
          lower: lower,
          includeLower: includeLower,
          upper: upper,
          includeUpper: includeUpper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.startsWith(
          property: r'sortedNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.endsWith(
          property: r'sortedNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsElementContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.contains(
          property: r'sortedNovelExtensions',
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsElementMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.matches(
          property: r'sortedNovelExtensions',
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.equalTo(property: r'sortedNovelExtensions', value: ''),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        FilterCondition.greaterThan(
          property: r'sortedNovelExtensions',
          value: '',
        ),
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedNovelExtensions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sortedNovelExtensions', 0, true, 0, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(r'sortedNovelExtensions', 0, false, 999999, true);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsLengthLessThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedNovelExtensions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsLengthGreaterThan(int length, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedNovelExtensions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterFilterCondition>
  sortedNovelExtensionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'sortedNovelExtensions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }
}

extension BridgeSettingsQueryObject
    on QueryBuilder<BridgeSettings, BridgeSettings, QFilterCondition> {}

extension BridgeSettingsQueryLinks
    on QueryBuilder<BridgeSettings, BridgeSettings, QFilterCondition> {}

extension BridgeSettingsQuerySortBy
    on QueryBuilder<BridgeSettings, BridgeSettings, QSortBy> {
  QueryBuilder<BridgeSettings, BridgeSettings, QAfterSortBy>
  sortByCurrentManager() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentManager', Sort.asc);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterSortBy>
  sortByCurrentManagerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentManager', Sort.desc);
    });
  }
}

extension BridgeSettingsQuerySortThenBy
    on QueryBuilder<BridgeSettings, BridgeSettings, QSortThenBy> {
  QueryBuilder<BridgeSettings, BridgeSettings, QAfterSortBy>
  thenByCurrentManager() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentManager', Sort.asc);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterSortBy>
  thenByCurrentManagerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'currentManager', Sort.desc);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }
}

extension BridgeSettingsQueryWhereDistinct
    on QueryBuilder<BridgeSettings, BridgeSettings, QDistinct> {
  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByAniyomiAnimeExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aniyomiAnimeExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByAniyomiMangaExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aniyomiMangaExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByCloudstreamAnimeExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudstreamAnimeExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByCloudstreamCartoonExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudstreamCartoonExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByCloudstreamDocumentaryExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudstreamDocumentaryExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByCloudstreamLivestreamExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudstreamLivestreamExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByCloudstreamMangaExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudstreamMangaExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByCloudstreamMovieExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudstreamMovieExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByCloudstreamNovelExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudstreamNovelExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByCloudstreamNsfwExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudstreamNsfwExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByCloudstreamTvShowExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cloudstreamTvShowExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByCurrentManager({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(
        r'currentManager',
        caseSensitive: caseSensitive,
      );
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByLnreaderNovelExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lnreaderNovelExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByMangayomiAnimeExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mangayomiAnimeExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByMangayomiMangaExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mangayomiMangaExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctByMangayomiNovelExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mangayomiNovelExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctBySortedAnimeExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortedAnimeExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctBySortedMangaExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortedMangaExtensions');
    });
  }

  QueryBuilder<BridgeSettings, BridgeSettings, QDistinct>
  distinctBySortedNovelExtensions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sortedNovelExtensions');
    });
  }
}

extension BridgeSettingsQueryProperty
    on QueryBuilder<BridgeSettings, BridgeSettings, QQueryProperty> {
  QueryBuilder<BridgeSettings, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  aniyomiAnimeExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aniyomiAnimeExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  aniyomiMangaExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aniyomiMangaExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  cloudstreamAnimeExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudstreamAnimeExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  cloudstreamCartoonExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudstreamCartoonExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  cloudstreamDocumentaryExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudstreamDocumentaryExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  cloudstreamLivestreamExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudstreamLivestreamExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  cloudstreamMangaExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudstreamMangaExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  cloudstreamMovieExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudstreamMovieExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  cloudstreamNovelExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudstreamNovelExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  cloudstreamNsfwExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudstreamNsfwExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  cloudstreamTvShowExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cloudstreamTvShowExtensions');
    });
  }

  QueryBuilder<BridgeSettings, String?, QQueryOperations>
  currentManagerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentManager');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  lnreaderNovelExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lnreaderNovelExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  mangayomiAnimeExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangayomiAnimeExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  mangayomiMangaExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangayomiMangaExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  mangayomiNovelExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mangayomiNovelExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  sortedAnimeExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortedAnimeExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  sortedMangaExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortedMangaExtensions');
    });
  }

  QueryBuilder<BridgeSettings, List<String>, QQueryOperations>
  sortedNovelExtensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sortedNovelExtensions');
    });
  }
}
