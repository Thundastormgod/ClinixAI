// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_triage_result.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalTriageResultCollection on Isar {
  IsarCollection<LocalTriageResult> get localTriageResults => this.collection();
}

const LocalTriageResultSchema = CollectionSchema(
  name: r'LocalTriageResult',
  id: 2354071776516932239,
  properties: {
    r'aiModelVersion': PropertySchema(
      id: 0,
      name: r'aiModelVersion',
      type: IsarType.string,
    ),
    r'confidenceScore': PropertySchema(
      id: 1,
      name: r'confidenceScore',
      type: IsarType.double,
    ),
    r'createdAt': PropertySchema(
      id: 2,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'differentialDiagnosesJson': PropertySchema(
      id: 3,
      name: r'differentialDiagnosesJson',
      type: IsarType.string,
    ),
    r'disclaimer': PropertySchema(
      id: 4,
      name: r'disclaimer',
      type: IsarType.string,
    ),
    r'escalatedToCloud': PropertySchema(
      id: 5,
      name: r'escalatedToCloud',
      type: IsarType.bool,
    ),
    r'followUpRequired': PropertySchema(
      id: 6,
      name: r'followUpRequired',
      type: IsarType.bool,
    ),
    r'glyphSignal': PropertySchema(
      id: 7,
      name: r'glyphSignal',
      type: IsarType.string,
    ),
    r'primaryAssessment': PropertySchema(
      id: 8,
      name: r'primaryAssessment',
      type: IsarType.string,
    ),
    r'recommendedAction': PropertySchema(
      id: 9,
      name: r'recommendedAction',
      type: IsarType.string,
    ),
    r'sessionId': PropertySchema(
      id: 10,
      name: r'sessionId',
      type: IsarType.long,
    ),
    r'sourceAttributionsJson': PropertySchema(
      id: 11,
      name: r'sourceAttributionsJson',
      type: IsarType.string,
    ),
    r'urgencyDisplayText': PropertySchema(
      id: 12,
      name: r'urgencyDisplayText',
      type: IsarType.string,
    ),
    r'urgencyLevel': PropertySchema(
      id: 13,
      name: r'urgencyLevel',
      type: IsarType.string,
      enumMap: _LocalTriageResulturgencyLevelEnumValueMap,
    )
  },
  estimateSize: _localTriageResultEstimateSize,
  serialize: _localTriageResultSerialize,
  deserialize: _localTriageResultDeserialize,
  deserializeProp: _localTriageResultDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionId': IndexSchema(
      id: 6949518585047923839,
      name: r'sessionId',
      unique: true,
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
  getId: _localTriageResultGetId,
  getLinks: _localTriageResultGetLinks,
  attach: _localTriageResultAttach,
  version: '3.1.0+1',
);

int _localTriageResultEstimateSize(
  LocalTriageResult object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.aiModelVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.differentialDiagnosesJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.disclaimer.length * 3;
  {
    final value = object.glyphSignal;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.primaryAssessment.length * 3;
  bytesCount += 3 + object.recommendedAction.length * 3;
  {
    final value = object.sourceAttributionsJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.urgencyDisplayText.length * 3;
  bytesCount += 3 + object.urgencyLevel.name.length * 3;
  return bytesCount;
}

void _localTriageResultSerialize(
  LocalTriageResult object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiModelVersion);
  writer.writeDouble(offsets[1], object.confidenceScore);
  writer.writeDateTime(offsets[2], object.createdAt);
  writer.writeString(offsets[3], object.differentialDiagnosesJson);
  writer.writeString(offsets[4], object.disclaimer);
  writer.writeBool(offsets[5], object.escalatedToCloud);
  writer.writeBool(offsets[6], object.followUpRequired);
  writer.writeString(offsets[7], object.glyphSignal);
  writer.writeString(offsets[8], object.primaryAssessment);
  writer.writeString(offsets[9], object.recommendedAction);
  writer.writeLong(offsets[10], object.sessionId);
  writer.writeString(offsets[11], object.sourceAttributionsJson);
  writer.writeString(offsets[12], object.urgencyDisplayText);
  writer.writeString(offsets[13], object.urgencyLevel.name);
}

LocalTriageResult _localTriageResultDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalTriageResult();
  object.aiModelVersion = reader.readStringOrNull(offsets[0]);
  object.confidenceScore = reader.readDouble(offsets[1]);
  object.createdAt = reader.readDateTime(offsets[2]);
  object.differentialDiagnosesJson = reader.readStringOrNull(offsets[3]);
  object.disclaimer = reader.readString(offsets[4]);
  object.escalatedToCloud = reader.readBool(offsets[5]);
  object.followUpRequired = reader.readBool(offsets[6]);
  object.glyphSignal = reader.readStringOrNull(offsets[7]);
  object.id = id;
  object.primaryAssessment = reader.readString(offsets[8]);
  object.recommendedAction = reader.readString(offsets[9]);
  object.sessionId = reader.readLong(offsets[10]);
  object.sourceAttributionsJson = reader.readStringOrNull(offsets[11]);
  object.urgencyLevel = _LocalTriageResulturgencyLevelValueEnumMap[
          reader.readStringOrNull(offsets[13])] ??
      UrgencyLevel.critical;
  return object;
}

P _localTriageResultDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readBool(offset)) as P;
    case 6:
      return (reader.readBool(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readString(offset)) as P;
    case 13:
      return (_LocalTriageResulturgencyLevelValueEnumMap[
              reader.readStringOrNull(offset)] ??
          UrgencyLevel.critical) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LocalTriageResulturgencyLevelEnumValueMap = {
  r'critical': r'critical',
  r'urgent': r'urgent',
  r'standard': r'standard',
  r'nonUrgent': r'nonUrgent',
};
const _LocalTriageResulturgencyLevelValueEnumMap = {
  r'critical': UrgencyLevel.critical,
  r'urgent': UrgencyLevel.urgent,
  r'standard': UrgencyLevel.standard,
  r'nonUrgent': UrgencyLevel.nonUrgent,
};

Id _localTriageResultGetId(LocalTriageResult object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localTriageResultGetLinks(
    LocalTriageResult object) {
  return [];
}

void _localTriageResultAttach(
    IsarCollection<dynamic> col, Id id, LocalTriageResult object) {
  object.id = id;
}

extension LocalTriageResultByIndex on IsarCollection<LocalTriageResult> {
  Future<LocalTriageResult?> getBySessionId(int sessionId) {
    return getByIndex(r'sessionId', [sessionId]);
  }

  LocalTriageResult? getBySessionIdSync(int sessionId) {
    return getByIndexSync(r'sessionId', [sessionId]);
  }

  Future<bool> deleteBySessionId(int sessionId) {
    return deleteByIndex(r'sessionId', [sessionId]);
  }

  bool deleteBySessionIdSync(int sessionId) {
    return deleteByIndexSync(r'sessionId', [sessionId]);
  }

  Future<List<LocalTriageResult?>> getAllBySessionId(
      List<int> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionId', values);
  }

  List<LocalTriageResult?> getAllBySessionIdSync(List<int> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionId', values);
  }

  Future<int> deleteAllBySessionId(List<int> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionId', values);
  }

  int deleteAllBySessionIdSync(List<int> sessionIdValues) {
    final values = sessionIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionId', values);
  }

  Future<Id> putBySessionId(LocalTriageResult object) {
    return putByIndex(r'sessionId', object);
  }

  Id putBySessionIdSync(LocalTriageResult object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionId(List<LocalTriageResult> objects) {
    return putAllByIndex(r'sessionId', objects);
  }

  List<Id> putAllBySessionIdSync(List<LocalTriageResult> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sessionId', objects, saveLinks: saveLinks);
  }
}

extension LocalTriageResultQueryWhereSort
    on QueryBuilder<LocalTriageResult, LocalTriageResult, QWhere> {
  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhere>
      anySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sessionId'),
      );
    });
  }
}

extension LocalTriageResultQueryWhere
    on QueryBuilder<LocalTriageResult, LocalTriageResult, QWhereClause> {
  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhereClause>
      idBetween(
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhereClause>
      sessionIdEqualTo(int sessionId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionId',
        value: [sessionId],
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhereClause>
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhereClause>
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhereClause>
      sessionIdLessThan(
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterWhereClause>
      sessionIdBetween(
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

extension LocalTriageResultQueryFilter
    on QueryBuilder<LocalTriageResult, LocalTriageResult, QFilterCondition> {
  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'aiModelVersion',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'aiModelVersion',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiModelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiModelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiModelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiModelVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiModelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiModelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiModelVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiModelVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiModelVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      aiModelVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiModelVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      confidenceScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'confidenceScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      confidenceScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'confidenceScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      confidenceScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'confidenceScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      confidenceScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'confidenceScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'differentialDiagnosesJson',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'differentialDiagnosesJson',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'differentialDiagnosesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'differentialDiagnosesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'differentialDiagnosesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'differentialDiagnosesJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'differentialDiagnosesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'differentialDiagnosesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'differentialDiagnosesJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'differentialDiagnosesJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'differentialDiagnosesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      differentialDiagnosesJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'differentialDiagnosesJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      disclaimerEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disclaimer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      disclaimerGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'disclaimer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      disclaimerLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'disclaimer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      disclaimerBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'disclaimer',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      disclaimerStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'disclaimer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      disclaimerEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'disclaimer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      disclaimerContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'disclaimer',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      disclaimerMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'disclaimer',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      disclaimerIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'disclaimer',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      disclaimerIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'disclaimer',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      escalatedToCloudEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'escalatedToCloud',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      followUpRequiredEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'followUpRequired',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'glyphSignal',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'glyphSignal',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'glyphSignal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'glyphSignal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'glyphSignal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'glyphSignal',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'glyphSignal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'glyphSignal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'glyphSignal',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'glyphSignal',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'glyphSignal',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      glyphSignalIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'glyphSignal',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      primaryAssessmentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryAssessment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      primaryAssessmentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryAssessment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      primaryAssessmentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryAssessment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      primaryAssessmentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryAssessment',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      primaryAssessmentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'primaryAssessment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      primaryAssessmentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'primaryAssessment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      primaryAssessmentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'primaryAssessment',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      primaryAssessmentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'primaryAssessment',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      primaryAssessmentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryAssessment',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      primaryAssessmentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'primaryAssessment',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      recommendedActionEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendedAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      recommendedActionGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recommendedAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      recommendedActionLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recommendedAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      recommendedActionBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recommendedAction',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      recommendedActionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'recommendedAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      recommendedActionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'recommendedAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      recommendedActionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'recommendedAction',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      recommendedActionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'recommendedAction',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      recommendedActionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recommendedAction',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      recommendedActionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'recommendedAction',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sessionIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionId',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
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

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sourceAttributionsJson',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sourceAttributionsJson',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceAttributionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sourceAttributionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sourceAttributionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sourceAttributionsJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sourceAttributionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sourceAttributionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sourceAttributionsJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sourceAttributionsJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sourceAttributionsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      sourceAttributionsJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sourceAttributionsJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyDisplayTextEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urgencyDisplayText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyDisplayTextGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'urgencyDisplayText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyDisplayTextLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'urgencyDisplayText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyDisplayTextBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'urgencyDisplayText',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyDisplayTextStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'urgencyDisplayText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyDisplayTextEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'urgencyDisplayText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyDisplayTextContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'urgencyDisplayText',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyDisplayTextMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'urgencyDisplayText',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyDisplayTextIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urgencyDisplayText',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyDisplayTextIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'urgencyDisplayText',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyLevelEqualTo(
    UrgencyLevel value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urgencyLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyLevelGreaterThan(
    UrgencyLevel value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'urgencyLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyLevelLessThan(
    UrgencyLevel value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'urgencyLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyLevelBetween(
    UrgencyLevel lower,
    UrgencyLevel upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'urgencyLevel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyLevelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'urgencyLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyLevelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'urgencyLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyLevelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'urgencyLevel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyLevelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'urgencyLevel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyLevelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'urgencyLevel',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterFilterCondition>
      urgencyLevelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'urgencyLevel',
        value: '',
      ));
    });
  }
}

extension LocalTriageResultQueryObject
    on QueryBuilder<LocalTriageResult, LocalTriageResult, QFilterCondition> {}

extension LocalTriageResultQueryLinks
    on QueryBuilder<LocalTriageResult, LocalTriageResult, QFilterCondition> {}

extension LocalTriageResultQuerySortBy
    on QueryBuilder<LocalTriageResult, LocalTriageResult, QSortBy> {
  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByAiModelVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModelVersion', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByAiModelVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModelVersion', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByConfidenceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceScore', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByConfidenceScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceScore', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByDifferentialDiagnosesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'differentialDiagnosesJson', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByDifferentialDiagnosesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'differentialDiagnosesJson', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByDisclaimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disclaimer', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByDisclaimerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disclaimer', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByEscalatedToCloud() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'escalatedToCloud', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByEscalatedToCloudDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'escalatedToCloud', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByFollowUpRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpRequired', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByFollowUpRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpRequired', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByGlyphSignal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glyphSignal', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByGlyphSignalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glyphSignal', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByPrimaryAssessment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryAssessment', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByPrimaryAssessmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryAssessment', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByRecommendedAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendedAction', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByRecommendedActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendedAction', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortBySourceAttributionsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceAttributionsJson', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortBySourceAttributionsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceAttributionsJson', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByUrgencyDisplayText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyDisplayText', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByUrgencyDisplayTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyDisplayText', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByUrgencyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyLevel', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      sortByUrgencyLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyLevel', Sort.desc);
    });
  }
}

extension LocalTriageResultQuerySortThenBy
    on QueryBuilder<LocalTriageResult, LocalTriageResult, QSortThenBy> {
  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByAiModelVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModelVersion', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByAiModelVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModelVersion', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByConfidenceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceScore', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByConfidenceScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'confidenceScore', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByDifferentialDiagnosesJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'differentialDiagnosesJson', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByDifferentialDiagnosesJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'differentialDiagnosesJson', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByDisclaimer() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disclaimer', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByDisclaimerDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'disclaimer', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByEscalatedToCloud() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'escalatedToCloud', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByEscalatedToCloudDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'escalatedToCloud', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByFollowUpRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpRequired', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByFollowUpRequiredDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'followUpRequired', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByGlyphSignal() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glyphSignal', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByGlyphSignalDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'glyphSignal', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByPrimaryAssessment() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryAssessment', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByPrimaryAssessmentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryAssessment', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByRecommendedAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendedAction', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByRecommendedActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recommendedAction', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenBySessionIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionId', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenBySourceAttributionsJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceAttributionsJson', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenBySourceAttributionsJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sourceAttributionsJson', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByUrgencyDisplayText() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyDisplayText', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByUrgencyDisplayTextDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyDisplayText', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByUrgencyLevel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyLevel', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QAfterSortBy>
      thenByUrgencyLevelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'urgencyLevel', Sort.desc);
    });
  }
}

extension LocalTriageResultQueryWhereDistinct
    on QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct> {
  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByAiModelVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiModelVersion',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByConfidenceScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'confidenceScore');
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByDifferentialDiagnosesJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'differentialDiagnosesJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByDisclaimer({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'disclaimer', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByEscalatedToCloud() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'escalatedToCloud');
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByFollowUpRequired() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'followUpRequired');
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByGlyphSignal({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'glyphSignal', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByPrimaryAssessment({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryAssessment',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByRecommendedAction({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recommendedAction',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctBySessionId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionId');
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctBySourceAttributionsJson({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sourceAttributionsJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByUrgencyDisplayText({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urgencyDisplayText',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageResult, LocalTriageResult, QDistinct>
      distinctByUrgencyLevel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'urgencyLevel', caseSensitive: caseSensitive);
    });
  }
}

extension LocalTriageResultQueryProperty
    on QueryBuilder<LocalTriageResult, LocalTriageResult, QQueryProperty> {
  QueryBuilder<LocalTriageResult, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalTriageResult, String?, QQueryOperations>
      aiModelVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiModelVersion');
    });
  }

  QueryBuilder<LocalTriageResult, double, QQueryOperations>
      confidenceScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'confidenceScore');
    });
  }

  QueryBuilder<LocalTriageResult, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<LocalTriageResult, String?, QQueryOperations>
      differentialDiagnosesJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'differentialDiagnosesJson');
    });
  }

  QueryBuilder<LocalTriageResult, String, QQueryOperations>
      disclaimerProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'disclaimer');
    });
  }

  QueryBuilder<LocalTriageResult, bool, QQueryOperations>
      escalatedToCloudProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'escalatedToCloud');
    });
  }

  QueryBuilder<LocalTriageResult, bool, QQueryOperations>
      followUpRequiredProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'followUpRequired');
    });
  }

  QueryBuilder<LocalTriageResult, String?, QQueryOperations>
      glyphSignalProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'glyphSignal');
    });
  }

  QueryBuilder<LocalTriageResult, String, QQueryOperations>
      primaryAssessmentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryAssessment');
    });
  }

  QueryBuilder<LocalTriageResult, String, QQueryOperations>
      recommendedActionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recommendedAction');
    });
  }

  QueryBuilder<LocalTriageResult, int, QQueryOperations> sessionIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionId');
    });
  }

  QueryBuilder<LocalTriageResult, String?, QQueryOperations>
      sourceAttributionsJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sourceAttributionsJson');
    });
  }

  QueryBuilder<LocalTriageResult, String, QQueryOperations>
      urgencyDisplayTextProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urgencyDisplayText');
    });
  }

  QueryBuilder<LocalTriageResult, UrgencyLevel, QQueryOperations>
      urgencyLevelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'urgencyLevel');
    });
  }
}
