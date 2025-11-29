// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_symptom.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalSymptomCollection on Isar {
  IsarCollection<LocalSymptom> get localSymptoms => this.collection();
}

const LocalSymptomSchema = CollectionSchema(
  name: r'LocalSymptom',
  id: 9129303616661163177,
  properties: {
    r'bodyLocation': PropertySchema(
      id: 0,
      name: r'bodyLocation',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'durationDescription': PropertySchema(
      id: 2,
      name: r'durationDescription',
      type: IsarType.string,
    ),
    r'durationHours': PropertySchema(
      id: 3,
      name: r'durationHours',
      type: IsarType.long,
    ),
    r'imageUrl': PropertySchema(
      id: 4,
      name: r'imageUrl',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 5,
      name: r'notes',
      type: IsarType.string,
    ),
    r'onsetTime': PropertySchema(
      id: 6,
      name: r'onsetTime',
      type: IsarType.dateTime,
    ),
    r'progression': PropertySchema(
      id: 7,
      name: r'progression',
      type: IsarType.string,
    ),
    r'recordedAt': PropertySchema(
      id: 8,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'sessionId': PropertySchema(
      id: 9,
      name: r'sessionId',
      type: IsarType.long,
    ),
    r'severity': PropertySchema(
      id: 10,
      name: r'severity',
      type: IsarType.long,
    ),
    r'severityDescription': PropertySchema(
      id: 11,
      name: r'severityDescription',
      type: IsarType.string,
    ),
    r'symptomCode': PropertySchema(
      id: 12,
      name: r'symptomCode',
      type: IsarType.string,
    )
  },
  estimateSize: _localSymptomEstimateSize,
  serialize: _localSymptomSerialize,
  deserialize: _localSymptomDeserialize,
  deserializeProp: _localSymptomDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionId',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _localSymptomGetId,
  getLinks: _localSymptomGetLinks,
  attach: _localSymptomAttach,
  version: '3.1.0+1',
);

int _localSymptomEstimateSize(
  LocalSymptom object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.bodyLocation;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.description.length * 3;
  bytesCount += 3 + object.durationDescription.length * 3;
  {
    final value = object.imageUrl;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.progression;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.severityDescription.length * 3;
  {
    final value = object.symptomCode;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _localSymptomSerialize(
  LocalSymptom object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.bodyLocation);
  writer.writeString(offsets[1], object.description);
  writer.writeString(offsets[2], object.durationDescription);
  writer.writeLong(offsets[3], object.durationHours);
  writer.writeString(offsets[4], object.imageUrl);
  writer.writeString(offsets[5], object.notes);
  writer.writeDateTime(offsets[6], object.onsetTime);
  writer.writeString(offsets[7], object.progression);
  writer.writeDateTime(offsets[8], object.recordedAt);
  writer.writeLong(offsets[9], object.sessionId);
  writer.writeLong(offsets[10], object.severity);
  writer.writeString(offsets[11], object.severityDescription);
  writer.writeString(offsets[12], object.symptomCode);
}

LocalSymptom _localSymptomDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalSymptom();
  object.bodyLocation = reader.readStringOrNull(offsets[0]);
  object.description = reader.readString(offsets[1]);
  object.durationHours = reader.readLongOrNull(offsets[3]);
  object.id = id;
  object.imageUrl = reader.readStringOrNull(offsets[4]);
  object.notes = reader.readStringOrNull(offsets[5]);
  object.onsetTime = reader.readDateTimeOrNull(offsets[6]);
  object.progression = reader.readStringOrNull(offsets[7]);
  object.recordedAt = reader.readDateTime(offsets[8]);
  object.sessionId = reader.readLong(offsets[9]);
  object.severity = reader.readLongOrNull(offsets[10]);
  object.symptomCode = reader.readStringOrNull(offsets[12]);
  return object;
}

P _localSymptomDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readDateTime(offset)) as P;
    case 9:
      return (reader.readLong(offset)) as P;
    case 10:
      return (reader.readLongOrNull(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localSymptomGetId(LocalSymptom object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localSymptomGetLinks(LocalSymptom object) {
  return [];
}

void _localSymptomAttach(
    IsarCollection<dynamic> col, Id id, LocalSymptom object) {
  object.id = id;
}

extension LocalSymptomQueryWhereSort
    on QueryBuilder<LocalSymptom, LocalSymptom, QWhere> {
  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhere> anySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sessionId'),
      );
    });
  }
}

extension LocalSymptomQueryWhere
    on QueryBuilder<LocalSymptom, LocalSymptom, QWhereClause> {
  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhereClause> idNotEqualTo(
      Id id) {
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

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhereClause> sessionIdEqualTo(
      int sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhereClause>
      sessionIdNotEqualTo(int sessionId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [sessionId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionId',
              lower: [],
              upper: [sessionId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhereClause>
      sessionIdGreaterThan(
    int sessionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId',
        lower: [sessionId],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhereClause> sessionIdLessThan(
    int sessionId, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId',
        lower: [],
        upper: [sessionId],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterWhereClause> sessionIdBetween(
    int lowerSessionId,
    int upperSessionId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionId',
        lower: [lowerSessionId],
        includeLower: includeLower,
        upper: [upperSessionId],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LocalSymptomQueryFilter
    on QueryBuilder<LocalSymptom, LocalSymptom, QFilterCondition> {
  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bodyLocation',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bodyLocation',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodyLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bodyLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bodyLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bodyLocation',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bodyLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bodyLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bodyLocation',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bodyLocation',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bodyLocation',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      bodyLocationIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bodyLocation',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      descriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      descriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      descriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      descriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      descriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      descriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationDescriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationDescriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationDescriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationDescriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationDescription',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationDescriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'durationDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationDescriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'durationDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationDescriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'durationDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationDescriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'durationDescription',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationDescriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationDescriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'durationDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationHoursIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'durationHours',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationHoursIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'durationHours',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationHoursEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'durationHours',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationHoursGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'durationHours',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationHoursLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'durationHours',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      durationHoursBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'durationHours',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imageUrl',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imageUrl',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imageUrl',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imageUrl',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      imageUrlIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imageUrl',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition> notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition> notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition> notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition> notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      onsetTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'onsetTime',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      onsetTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'onsetTime',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      onsetTimeEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'onsetTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      onsetTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'onsetTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      onsetTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'onsetTime',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      onsetTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'onsetTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'progression',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'progression',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progression',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'progression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'progression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'progression',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'progression',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progression',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      progressionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'progression',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      recordedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      recordedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      recordedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      recordedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      sessionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      sessionIdGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      sessionIdLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      sessionIdBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'severity',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'severity',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'severity',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'severity',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'severity',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'severity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityDescriptionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'severityDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityDescriptionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'severityDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityDescriptionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'severityDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityDescriptionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'severityDescription',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityDescriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'severityDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityDescriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'severityDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityDescriptionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'severityDescription',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityDescriptionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'severityDescription',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityDescriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'severityDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      severityDescriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'severityDescription',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'symptomCode',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'symptomCode',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symptomCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'symptomCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'symptomCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'symptomCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'symptomCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'symptomCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'symptomCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'symptomCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'symptomCode',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterFilterCondition>
      symptomCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'symptomCode',
        value: '',
      ));
    });
  }
}

extension LocalSymptomQueryObject
    on QueryBuilder<LocalSymptom, LocalSymptom, QFilterCondition> {}

extension LocalSymptomQueryLinks
    on QueryBuilder<LocalSymptom, LocalSymptom, QFilterCondition> {}

extension LocalSymptomQuerySortBy
    on QueryBuilder<LocalSymptom, LocalSymptom, QSortBy> {
  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByBodyLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyLocation', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      sortByBodyLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyLocation', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      sortByDurationDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDescription', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      sortByDurationDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDescription', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByDurationHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHours', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      sortByDurationHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHours', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByOnsetTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onsetTime', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByOnsetTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onsetTime', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByProgression() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progression', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      sortByProgressionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progression', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortBySeverityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      sortBySeverityDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severityDescription', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      sortBySeverityDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severityDescription', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> sortBySymptomCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomCode', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      sortBySymptomCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomCode', Sort.desc);
    });
  }
}

extension LocalSymptomQuerySortThenBy
    on QueryBuilder<LocalSymptom, LocalSymptom, QSortThenBy> {
  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByBodyLocation() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyLocation', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      thenByBodyLocationDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bodyLocation', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      thenByDurationDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDescription', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      thenByDurationDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationDescription', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByDurationHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHours', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      thenByDurationHoursDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'durationHours', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByImageUrl() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByImageUrlDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imageUrl', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByOnsetTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onsetTime', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByOnsetTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'onsetTime', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByProgression() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progression', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      thenByProgressionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progression', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenBySeverityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severity', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      thenBySeverityDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severityDescription', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      thenBySeverityDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'severityDescription', Sort.desc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy> thenBySymptomCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomCode', Sort.asc);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QAfterSortBy>
      thenBySymptomCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'symptomCode', Sort.desc);
    });
  }
}

extension LocalSymptomQueryWhereDistinct
    on QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> {
  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> distinctByBodyLocation(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bodyLocation', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct>
      distinctByDurationDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationDescription',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct>
      distinctByDurationHours() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'durationHours');
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> distinctByImageUrl(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imageUrl', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> distinctByOnsetTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'onsetTime');
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> distinctByProgression(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progression', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> distinctBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId');
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> distinctBySeverity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'severity');
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct>
      distinctBySeverityDescription({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'severityDescription',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalSymptom, LocalSymptom, QDistinct> distinctBySymptomCode(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'symptomCode', caseSensitive: caseSensitive);
    });
  }
}

extension LocalSymptomQueryProperty
    on QueryBuilder<LocalSymptom, LocalSymptom, QQueryProperty> {
  QueryBuilder<LocalSymptom, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalSymptom, String?, QQueryOperations> bodyLocationProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bodyLocation');
    });
  }

  QueryBuilder<LocalSymptom, String, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<LocalSymptom, String, QQueryOperations>
      durationDescriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationDescription');
    });
  }

  QueryBuilder<LocalSymptom, int?, QQueryOperations> durationHoursProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'durationHours');
    });
  }

  QueryBuilder<LocalSymptom, String?, QQueryOperations> imageUrlProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imageUrl');
    });
  }

  QueryBuilder<LocalSymptom, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<LocalSymptom, DateTime?, QQueryOperations> onsetTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'onsetTime');
    });
  }

  QueryBuilder<LocalSymptom, String?, QQueryOperations> progressionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progression');
    });
  }

  QueryBuilder<LocalSymptom, DateTime, QQueryOperations> recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<LocalSymptom, int, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<LocalSymptom, int?, QQueryOperations> severityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'severity');
    });
  }

  QueryBuilder<LocalSymptom, String, QQueryOperations>
      severityDescriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'severityDescription');
    });
  }

  QueryBuilder<LocalSymptom, String?, QQueryOperations> symptomCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'symptomCode');
    });
  }
}
