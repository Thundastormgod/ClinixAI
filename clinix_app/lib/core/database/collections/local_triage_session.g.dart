// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_triage_session.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalTriageSessionCollection on Isar {
  IsarCollection<LocalTriageSession> get localTriageSessions =>
      this.collection();
}

const LocalTriageSessionSchema = CollectionSchema(
  name: r'LocalTriageSession',
  id: 8569050516657552889,
  properties: {
    r'appVersion': PropertySchema(
      id: 0,
      name: r'appVersion',
      type: IsarType.string,
    ),
    r'deviceId': PropertySchema(
      id: 1,
      name: r'deviceId',
      type: IsarType.string,
    ),
    r'deviceModel': PropertySchema(
      id: 2,
      name: r'deviceModel',
      type: IsarType.string,
    ),
    r'isSynced': PropertySchema(
      id: 3,
      name: r'isSynced',
      type: IsarType.bool,
    ),
    r'lastSyncError': PropertySchema(
      id: 4,
      name: r'lastSyncError',
      type: IsarType.string,
    ),
    r'locationLat': PropertySchema(
      id: 5,
      name: r'locationLat',
      type: IsarType.double,
    ),
    r'locationLng': PropertySchema(
      id: 6,
      name: r'locationLng',
      type: IsarType.double,
    ),
    r'processingMode': PropertySchema(
      id: 7,
      name: r'processingMode',
      type: IsarType.string,
      enumMap: _LocalTriageSessionprocessingModeEnumValueMap,
    ),
    r'sessionEnd': PropertySchema(
      id: 8,
      name: r'sessionEnd',
      type: IsarType.dateTime,
    ),
    r'sessionStart': PropertySchema(
      id: 9,
      name: r'sessionStart',
      type: IsarType.dateTime,
    ),
    r'sessionUuid': PropertySchema(
      id: 10,
      name: r'sessionUuid',
      type: IsarType.string,
    ),
    r'syncRetryCount': PropertySchema(
      id: 11,
      name: r'syncRetryCount',
      type: IsarType.long,
    ),
    r'syncedAt': PropertySchema(
      id: 12,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'userNotes': PropertySchema(
      id: 13,
      name: r'userNotes',
      type: IsarType.string,
    )
  },
  estimateSize: _localTriageSessionEstimateSize,
  serialize: _localTriageSessionSerialize,
  deserialize: _localTriageSessionDeserialize,
  deserializeProp: _localTriageSessionDeserializeProp,
  idName: r'id',
  indexes: {
    r'sessionUuid': IndexSchema(
      id: 1105448749916514119,
      name: r'sessionUuid',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionUuid',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'sessionStart': IndexSchema(
      id: 1168785810076091146,
      name: r'sessionStart',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'sessionStart',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'isSynced': IndexSchema(
      id: -39763503327887510,
      name: r'isSynced',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isSynced',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _localTriageSessionGetId,
  getLinks: _localTriageSessionGetLinks,
  attach: _localTriageSessionAttach,
  version: '3.1.0+1',
);

int _localTriageSessionEstimateSize(
  LocalTriageSession object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.appVersion;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.deviceId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.deviceModel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.lastSyncError;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.processingMode.name.length * 3;
  bytesCount += 3 + object.sessionUuid.length * 3;
  {
    final value = object.userNotes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _localTriageSessionSerialize(
  LocalTriageSession object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.appVersion);
  writer.writeString(offsets[1], object.deviceId);
  writer.writeString(offsets[2], object.deviceModel);
  writer.writeBool(offsets[3], object.isSynced);
  writer.writeString(offsets[4], object.lastSyncError);
  writer.writeDouble(offsets[5], object.locationLat);
  writer.writeDouble(offsets[6], object.locationLng);
  writer.writeString(offsets[7], object.processingMode.name);
  writer.writeDateTime(offsets[8], object.sessionEnd);
  writer.writeDateTime(offsets[9], object.sessionStart);
  writer.writeString(offsets[10], object.sessionUuid);
  writer.writeLong(offsets[11], object.syncRetryCount);
  writer.writeDateTime(offsets[12], object.syncedAt);
  writer.writeString(offsets[13], object.userNotes);
}

LocalTriageSession _localTriageSessionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalTriageSession();
  object.appVersion = reader.readStringOrNull(offsets[0]);
  object.deviceId = reader.readStringOrNull(offsets[1]);
  object.deviceModel = reader.readStringOrNull(offsets[2]);
  object.id = id;
  object.isSynced = reader.readBool(offsets[3]);
  object.lastSyncError = reader.readStringOrNull(offsets[4]);
  object.locationLat = reader.readDoubleOrNull(offsets[5]);
  object.locationLng = reader.readDoubleOrNull(offsets[6]);
  object.processingMode = _LocalTriageSessionprocessingModeValueEnumMap[
          reader.readStringOrNull(offsets[7])] ??
      ProcessingMode.local;
  object.sessionEnd = reader.readDateTimeOrNull(offsets[8]);
  object.sessionStart = reader.readDateTime(offsets[9]);
  object.sessionUuid = reader.readString(offsets[10]);
  object.syncRetryCount = reader.readLong(offsets[11]);
  object.syncedAt = reader.readDateTimeOrNull(offsets[12]);
  object.userNotes = reader.readStringOrNull(offsets[13]);
  return object;
}

P _localTriageSessionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (_LocalTriageSessionprocessingModeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          ProcessingMode.local) as P;
    case 8:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 9:
      return (reader.readDateTime(offset)) as P;
    case 10:
      return (reader.readString(offset)) as P;
    case 11:
      return (reader.readLong(offset)) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LocalTriageSessionprocessingModeEnumValueMap = {
  r'local': r'local',
  r'cloud': r'cloud',
  r'hybrid': r'hybrid',
  r'pendingSync': r'pendingSync',
};
const _LocalTriageSessionprocessingModeValueEnumMap = {
  r'local': ProcessingMode.local,
  r'cloud': ProcessingMode.cloud,
  r'hybrid': ProcessingMode.hybrid,
  r'pendingSync': ProcessingMode.pendingSync,
};

Id _localTriageSessionGetId(LocalTriageSession object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localTriageSessionGetLinks(
    LocalTriageSession object) {
  return [];
}

void _localTriageSessionAttach(
    IsarCollection<dynamic> col, Id id, LocalTriageSession object) {
  object.id = id;
}

extension LocalTriageSessionByIndex on IsarCollection<LocalTriageSession> {
  Future<LocalTriageSession?> getBySessionUuid(String sessionUuid) {
    return getByIndex(r'sessionUuid', [sessionUuid]);
  }

  LocalTriageSession? getBySessionUuidSync(String sessionUuid) {
    return getByIndexSync(r'sessionUuid', [sessionUuid]);
  }

  Future<bool> deleteBySessionUuid(String sessionUuid) {
    return deleteByIndex(r'sessionUuid', [sessionUuid]);
  }

  bool deleteBySessionUuidSync(String sessionUuid) {
    return deleteByIndexSync(r'sessionUuid', [sessionUuid]);
  }

  Future<List<LocalTriageSession?>> getAllBySessionUuid(
      List<String> sessionUuidValues) {
    final values = sessionUuidValues.map((e) => [e]).toList();
    return getAllByIndex(r'sessionUuid', values);
  }

  List<LocalTriageSession?> getAllBySessionUuidSync(
      List<String> sessionUuidValues) {
    final values = sessionUuidValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'sessionUuid', values);
  }

  Future<int> deleteAllBySessionUuid(List<String> sessionUuidValues) {
    final values = sessionUuidValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'sessionUuid', values);
  }

  int deleteAllBySessionUuidSync(List<String> sessionUuidValues) {
    final values = sessionUuidValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'sessionUuid', values);
  }

  Future<Id> putBySessionUuid(LocalTriageSession object) {
    return putByIndex(r'sessionUuid', object);
  }

  Id putBySessionUuidSync(LocalTriageSession object, {bool saveLinks = true}) {
    return putByIndexSync(r'sessionUuid', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySessionUuid(List<LocalTriageSession> objects) {
    return putAllByIndex(r'sessionUuid', objects);
  }

  List<Id> putAllBySessionUuidSync(List<LocalTriageSession> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'sessionUuid', objects, saveLinks: saveLinks);
  }
}

extension LocalTriageSessionQueryWhereSort
    on QueryBuilder<LocalTriageSession, LocalTriageSession, QWhere> {
  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhere>
      anySessionStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'sessionStart'),
      );
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhere>
      anyIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isSynced'),
      );
    });
  }
}

extension LocalTriageSessionQueryWhere
    on QueryBuilder<LocalTriageSession, LocalTriageSession, QWhereClause> {
  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
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

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
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

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      sessionUuidEqualTo(String sessionUuid) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionUuid',
        value: [sessionUuid],
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      sessionUuidNotEqualTo(String sessionUuid) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionUuid',
              lower: [],
              upper: [sessionUuid],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionUuid',
              lower: [sessionUuid],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionUuid',
              lower: [sessionUuid],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionUuid',
              lower: [],
              upper: [sessionUuid],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      sessionStartEqualTo(DateTime sessionStart) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'sessionStart',
        value: [sessionStart],
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      sessionStartNotEqualTo(DateTime sessionStart) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionStart',
              lower: [],
              upper: [sessionStart],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionStart',
              lower: [sessionStart],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionStart',
              lower: [sessionStart],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'sessionStart',
              lower: [],
              upper: [sessionStart],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      sessionStartGreaterThan(
    DateTime sessionStart, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionStart',
        lower: [sessionStart],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      sessionStartLessThan(
    DateTime sessionStart, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionStart',
        lower: [],
        upper: [sessionStart],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      sessionStartBetween(
    DateTime lowerSessionStart,
    DateTime upperSessionStart, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'sessionStart',
        lower: [lowerSessionStart],
        includeLower: includeLower,
        upper: [upperSessionStart],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      isSyncedEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isSynced',
        value: [isSynced],
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterWhereClause>
      isSyncedNotEqualTo(bool isSynced) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [isSynced],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isSynced',
              lower: [],
              upper: [isSynced],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LocalTriageSessionQueryFilter
    on QueryBuilder<LocalTriageSession, LocalTriageSession, QFilterCondition> {
  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'appVersion',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'appVersion',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'appVersion',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'appVersion',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'appVersion',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'appVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      appVersionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'appVersion',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deviceId',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deviceId',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'deviceModel',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'deviceModel',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'deviceModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'deviceModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'deviceModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'deviceModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'deviceModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'deviceModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'deviceModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'deviceModel',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      deviceModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'deviceModel',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
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

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
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

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
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

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      isSyncedEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSynced',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastSyncError',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastSyncError',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastSyncError',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastSyncError',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastSyncError',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastSyncError',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      lastSyncErrorIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastSyncError',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLatIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationLat',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLatIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationLat',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLatEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationLat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLatGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationLat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLatLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationLat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLatBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationLat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLngIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'locationLng',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLngIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'locationLng',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLngEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'locationLng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLngGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'locationLng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLngLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'locationLng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      locationLngBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'locationLng',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      processingModeEqualTo(
    ProcessingMode value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      processingModeGreaterThan(
    ProcessingMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'processingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      processingModeLessThan(
    ProcessingMode value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'processingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      processingModeBetween(
    ProcessingMode lower,
    ProcessingMode upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'processingMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      processingModeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'processingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      processingModeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'processingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      processingModeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'processingMode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      processingModeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'processingMode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      processingModeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'processingMode',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      processingModeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'processingMode',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionEndIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sessionEnd',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionEndIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sessionEnd',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionEndEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionEndGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionEndLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionEnd',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionEndBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionEnd',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionStartEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionStart',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionStartGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionStart',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionStartLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionStart',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionStartBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionStart',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionUuidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionUuidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sessionUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionUuidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sessionUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionUuidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sessionUuid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionUuidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sessionUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionUuidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sessionUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionUuidContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sessionUuid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionUuidMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sessionUuid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionUuidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sessionUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      sessionUuidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sessionUuid',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      syncRetryCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncRetryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      syncRetryCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncRetryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      syncRetryCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncRetryCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      syncRetryCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncRetryCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      syncedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      syncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      syncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      syncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'userNotes',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'userNotes',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'userNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'userNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'userNotes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'userNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'userNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'userNotes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'userNotes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'userNotes',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterFilterCondition>
      userNotesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'userNotes',
        value: '',
      ));
    });
  }
}

extension LocalTriageSessionQueryObject
    on QueryBuilder<LocalTriageSession, LocalTriageSession, QFilterCondition> {}

extension LocalTriageSessionQueryLinks
    on QueryBuilder<LocalTriageSession, LocalTriageSession, QFilterCondition> {}

extension LocalTriageSessionQuerySortBy
    on QueryBuilder<LocalTriageSession, LocalTriageSession, QSortBy> {
  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByAppVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByAppVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByDeviceModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceModel', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByDeviceModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceModel', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByLastSyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByLocationLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLat', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByLocationLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLat', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByLocationLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLng', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByLocationLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLng', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByProcessingMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingMode', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByProcessingModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingMode', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortBySessionEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionEnd', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortBySessionEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionEnd', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortBySessionStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionStart', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortBySessionStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionStart', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortBySessionUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionUuid', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortBySessionUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionUuid', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortBySyncRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncRetryCount', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortBySyncRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncRetryCount', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByUserNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNotes', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      sortByUserNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNotes', Sort.desc);
    });
  }
}

extension LocalTriageSessionQuerySortThenBy
    on QueryBuilder<LocalTriageSession, LocalTriageSession, QSortThenBy> {
  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByAppVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByAppVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'appVersion', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByDeviceId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByDeviceIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceId', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByDeviceModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceModel', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByDeviceModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'deviceModel', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByIsSyncedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSynced', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByLastSyncError() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByLastSyncErrorDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastSyncError', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByLocationLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLat', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByLocationLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLat', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByLocationLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLng', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByLocationLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'locationLng', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByProcessingMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingMode', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByProcessingModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'processingMode', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenBySessionEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionEnd', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenBySessionEndDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionEnd', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenBySessionStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionStart', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenBySessionStartDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionStart', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenBySessionUuid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionUuid', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenBySessionUuidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sessionUuid', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenBySyncRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncRetryCount', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenBySyncRetryCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncRetryCount', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByUserNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNotes', Sort.asc);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QAfterSortBy>
      thenByUserNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'userNotes', Sort.desc);
    });
  }
}

extension LocalTriageSessionQueryWhereDistinct
    on QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct> {
  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctByAppVersion({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'appVersion', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctByDeviceId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctByDeviceModel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'deviceModel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctByIsSynced() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSynced');
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctByLastSyncError({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastSyncError',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctByLocationLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationLat');
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctByLocationLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'locationLng');
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctByProcessingMode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'processingMode',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctBySessionEnd() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionEnd');
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctBySessionStart() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionStart');
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctBySessionUuid({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sessionUuid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctBySyncRetryCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncRetryCount');
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<LocalTriageSession, LocalTriageSession, QDistinct>
      distinctByUserNotes({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'userNotes', caseSensitive: caseSensitive);
    });
  }
}

extension LocalTriageSessionQueryProperty
    on QueryBuilder<LocalTriageSession, LocalTriageSession, QQueryProperty> {
  QueryBuilder<LocalTriageSession, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalTriageSession, String?, QQueryOperations>
      appVersionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'appVersion');
    });
  }

  QueryBuilder<LocalTriageSession, String?, QQueryOperations>
      deviceIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceId');
    });
  }

  QueryBuilder<LocalTriageSession, String?, QQueryOperations>
      deviceModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'deviceModel');
    });
  }

  QueryBuilder<LocalTriageSession, bool, QQueryOperations> isSyncedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSynced');
    });
  }

  QueryBuilder<LocalTriageSession, String?, QQueryOperations>
      lastSyncErrorProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastSyncError');
    });
  }

  QueryBuilder<LocalTriageSession, double?, QQueryOperations>
      locationLatProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationLat');
    });
  }

  QueryBuilder<LocalTriageSession, double?, QQueryOperations>
      locationLngProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'locationLng');
    });
  }

  QueryBuilder<LocalTriageSession, ProcessingMode, QQueryOperations>
      processingModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'processingMode');
    });
  }

  QueryBuilder<LocalTriageSession, DateTime?, QQueryOperations>
      sessionEndProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionEnd');
    });
  }

  QueryBuilder<LocalTriageSession, DateTime, QQueryOperations>
      sessionStartProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionStart');
    });
  }

  QueryBuilder<LocalTriageSession, String, QQueryOperations>
      sessionUuidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sessionUuid');
    });
  }

  QueryBuilder<LocalTriageSession, int, QQueryOperations>
      syncRetryCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncRetryCount');
    });
  }

  QueryBuilder<LocalTriageSession, DateTime?, QQueryOperations>
      syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<LocalTriageSession, String?, QQueryOperations>
      userNotesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'userNotes');
    });
  }
}
