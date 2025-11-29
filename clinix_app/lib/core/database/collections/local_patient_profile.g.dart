// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_patient_profile.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalPatientProfileCollection on Isar {
  IsarCollection<LocalPatientProfile> get localPatientProfiles =>
      this.collection();
}

const LocalPatientProfileSchema = CollectionSchema(
  name: r'LocalPatientProfile',
  id: -1948395318158559026,
  properties: {
    r'age': PropertySchema(
      id: 0,
      name: r'age',
      type: IsarType.long,
    ),
    r'allergies': PropertySchema(
      id: 1,
      name: r'allergies',
      type: IsarType.stringList,
    ),
    r'bloodType': PropertySchema(
      id: 2,
      name: r'bloodType',
      type: IsarType.string,
    ),
    r'chronicConditions': PropertySchema(
      id: 3,
      name: r'chronicConditions',
      type: IsarType.stringList,
    ),
    r'consentGiven': PropertySchema(
      id: 4,
      name: r'consentGiven',
      type: IsarType.bool,
    ),
    r'consentTimestamp': PropertySchema(
      id: 5,
      name: r'consentTimestamp',
      type: IsarType.dateTime,
    ),
    r'currentMedications': PropertySchema(
      id: 6,
      name: r'currentMedications',
      type: IsarType.stringList,
    ),
    r'dateOfBirth': PropertySchema(
      id: 7,
      name: r'dateOfBirth',
      type: IsarType.dateTime,
    ),
    r'emergencyContactName': PropertySchema(
      id: 8,
      name: r'emergencyContactName',
      type: IsarType.string,
    ),
    r'emergencyContactPhone': PropertySchema(
      id: 9,
      name: r'emergencyContactPhone',
      type: IsarType.string,
    ),
    r'fullName': PropertySchema(
      id: 10,
      name: r'fullName',
      type: IsarType.string,
    ),
    r'gender': PropertySchema(
      id: 11,
      name: r'gender',
      type: IsarType.string,
    ),
    r'hasMinimalInfo': PropertySchema(
      id: 12,
      name: r'hasMinimalInfo',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 13,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'preferredLanguage': PropertySchema(
      id: 14,
      name: r'preferredLanguage',
      type: IsarType.string,
    )
  },
  estimateSize: _localPatientProfileEstimateSize,
  serialize: _localPatientProfileSerialize,
  deserialize: _localPatientProfileDeserialize,
  deserializeProp: _localPatientProfileDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _localPatientProfileGetId,
  getLinks: _localPatientProfileGetLinks,
  attach: _localPatientProfileAttach,
  version: '3.1.0+1',
);

int _localPatientProfileEstimateSize(
  LocalPatientProfile object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final list = object.allergies;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.bloodType;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final list = object.chronicConditions;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final list = object.currentMedications;
    if (list != null) {
      bytesCount += 3 + list.length * 3;
      {
        for (var i = 0; i < list.length; i++) {
          final value = list[i];
          bytesCount += value.length * 3;
        }
      }
    }
  }
  {
    final value = object.emergencyContactName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.emergencyContactPhone;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fullName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.gender;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.preferredLanguage;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _localPatientProfileSerialize(
  LocalPatientProfile object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.age);
  writer.writeStringList(offsets[1], object.allergies);
  writer.writeString(offsets[2], object.bloodType);
  writer.writeStringList(offsets[3], object.chronicConditions);
  writer.writeBool(offsets[4], object.consentGiven);
  writer.writeDateTime(offsets[5], object.consentTimestamp);
  writer.writeStringList(offsets[6], object.currentMedications);
  writer.writeDateTime(offsets[7], object.dateOfBirth);
  writer.writeString(offsets[8], object.emergencyContactName);
  writer.writeString(offsets[9], object.emergencyContactPhone);
  writer.writeString(offsets[10], object.fullName);
  writer.writeString(offsets[11], object.gender);
  writer.writeBool(offsets[12], object.hasMinimalInfo);
  writer.writeDateTime(offsets[13], object.lastUpdated);
  writer.writeString(offsets[14], object.preferredLanguage);
}

LocalPatientProfile _localPatientProfileDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalPatientProfile();
  object.allergies = reader.readStringList(offsets[1]);
  object.bloodType = reader.readStringOrNull(offsets[2]);
  object.chronicConditions = reader.readStringList(offsets[3]);
  object.consentGiven = reader.readBool(offsets[4]);
  object.consentTimestamp = reader.readDateTimeOrNull(offsets[5]);
  object.currentMedications = reader.readStringList(offsets[6]);
  object.dateOfBirth = reader.readDateTimeOrNull(offsets[7]);
  object.emergencyContactName = reader.readStringOrNull(offsets[8]);
  object.emergencyContactPhone = reader.readStringOrNull(offsets[9]);
  object.fullName = reader.readStringOrNull(offsets[10]);
  object.gender = reader.readStringOrNull(offsets[11]);
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[13]);
  object.preferredLanguage = reader.readStringOrNull(offsets[14]);
  return object;
}

P _localPatientProfileDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset)) as P;
    case 2:
      return (reader.readStringOrNull(offset)) as P;
    case 3:
      return (reader.readStringList(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringList(offset)) as P;
    case 7:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 8:
      return (reader.readStringOrNull(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readStringOrNull(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readBool(offset)) as P;
    case 13:
      return (reader.readDateTime(offset)) as P;
    case 14:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localPatientProfileGetId(LocalPatientProfile object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localPatientProfileGetLinks(
    LocalPatientProfile object) {
  return [];
}

void _localPatientProfileAttach(
    IsarCollection<dynamic> col, Id id, LocalPatientProfile object) {
  object.id = id;
}

extension LocalPatientProfileQueryWhereSort
    on QueryBuilder<LocalPatientProfile, LocalPatientProfile, QWhere> {
  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalPatientProfileQueryWhere
    on QueryBuilder<LocalPatientProfile, LocalPatientProfile, QWhereClause> {
  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterWhereClause>
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

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterWhereClause>
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
}

extension LocalPatientProfileQueryFilter on QueryBuilder<LocalPatientProfile,
    LocalPatientProfile, QFilterCondition> {
  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      ageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'age',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      ageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'age',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      ageEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      ageGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      ageLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'age',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      ageBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'age',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'allergies',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'allergies',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'allergies',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'allergies',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'allergies',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'allergies',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'allergies',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allergies',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allergies',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allergies',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allergies',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allergies',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      allergiesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'allergies',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'bloodType',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'bloodType',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'bloodType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'bloodType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'bloodType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'bloodType',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      bloodTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'bloodType',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'chronicConditions',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'chronicConditions',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chronicConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chronicConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chronicConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chronicConditions',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'chronicConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'chronicConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'chronicConditions',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'chronicConditions',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chronicConditions',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'chronicConditions',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chronicConditions',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chronicConditions',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chronicConditions',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chronicConditions',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chronicConditions',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      chronicConditionsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'chronicConditions',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      consentGivenEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consentGiven',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      consentTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'consentTimestamp',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      consentTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'consentTimestamp',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      consentTimestampEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consentTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      consentTimestampGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consentTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      consentTimestampLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consentTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      consentTimestampBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consentTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'currentMedications',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'currentMedications',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentMedications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'currentMedications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'currentMedications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'currentMedications',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'currentMedications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'currentMedications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsElementContains(String value,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'currentMedications',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsElementMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'currentMedications',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'currentMedications',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'currentMedications',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currentMedications',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currentMedications',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currentMedications',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currentMedications',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currentMedications',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      currentMedicationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'currentMedications',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      dateOfBirthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dateOfBirth',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      dateOfBirthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dateOfBirth',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      dateOfBirthEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      dateOfBirthGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      dateOfBirthLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'dateOfBirth',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      dateOfBirthBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'dateOfBirth',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'emergencyContactName',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'emergencyContactName',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emergencyContactName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emergencyContactName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emergencyContactName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyContactName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emergencyContactName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'emergencyContactPhone',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'emergencyContactPhone',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'emergencyContactPhone',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'emergencyContactPhone',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneMatches(String pattern,
          {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'emergencyContactPhone',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'emergencyContactPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      emergencyContactPhoneIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'emergencyContactPhone',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fullName',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fullName',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      fullNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullName',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gender',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gender',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gender',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gender',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      genderIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gender',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      hasMinimalInfoEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'hasMinimalInfo',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
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

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
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

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
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

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'preferredLanguage',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'preferredLanguage',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'preferredLanguage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'preferredLanguage',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'preferredLanguage',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'preferredLanguage',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterFilterCondition>
      preferredLanguageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'preferredLanguage',
        value: '',
      ));
    });
  }
}

extension LocalPatientProfileQueryObject on QueryBuilder<LocalPatientProfile,
    LocalPatientProfile, QFilterCondition> {}

extension LocalPatientProfileQueryLinks on QueryBuilder<LocalPatientProfile,
    LocalPatientProfile, QFilterCondition> {}

extension LocalPatientProfileQuerySortBy
    on QueryBuilder<LocalPatientProfile, LocalPatientProfile, QSortBy> {
  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByBloodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByBloodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByConsentGiven() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consentGiven', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByConsentGivenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consentGiven', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByConsentTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consentTimestamp', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByConsentTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consentTimestamp', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByEmergencyContactName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactName', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByEmergencyContactNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactName', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByEmergencyContactPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactPhone', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByEmergencyContactPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactPhone', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByHasMinimalInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMinimalInfo', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByHasMinimalInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMinimalInfo', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByPreferredLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLanguage', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      sortByPreferredLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLanguage', Sort.desc);
    });
  }
}

extension LocalPatientProfileQuerySortThenBy
    on QueryBuilder<LocalPatientProfile, LocalPatientProfile, QSortThenBy> {
  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByAgeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'age', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByBloodType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByBloodTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'bloodType', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByConsentGiven() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consentGiven', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByConsentGivenDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consentGiven', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByConsentTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consentTimestamp', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByConsentTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consentTimestamp', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByDateOfBirthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'dateOfBirth', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByEmergencyContactName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactName', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByEmergencyContactNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactName', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByEmergencyContactPhone() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactPhone', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByEmergencyContactPhoneDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'emergencyContactPhone', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByFullName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByFullNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullName', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByGender() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByGenderDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gender', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByHasMinimalInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMinimalInfo', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByHasMinimalInfoDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'hasMinimalInfo', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByPreferredLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLanguage', Sort.asc);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QAfterSortBy>
      thenByPreferredLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'preferredLanguage', Sort.desc);
    });
  }
}

extension LocalPatientProfileQueryWhereDistinct
    on QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct> {
  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByAge() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'age');
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByAllergies() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'allergies');
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByBloodType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'bloodType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByChronicConditions() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chronicConditions');
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByConsentGiven() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consentGiven');
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByConsentTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consentTimestamp');
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByCurrentMedications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'currentMedications');
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByDateOfBirth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'dateOfBirth');
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByEmergencyContactName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emergencyContactName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByEmergencyContactPhone({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'emergencyContactPhone',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByFullName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByGender({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gender', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByHasMinimalInfo() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'hasMinimalInfo');
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<LocalPatientProfile, LocalPatientProfile, QDistinct>
      distinctByPreferredLanguage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'preferredLanguage',
          caseSensitive: caseSensitive);
    });
  }
}

extension LocalPatientProfileQueryProperty
    on QueryBuilder<LocalPatientProfile, LocalPatientProfile, QQueryProperty> {
  QueryBuilder<LocalPatientProfile, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalPatientProfile, int?, QQueryOperations> ageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'age');
    });
  }

  QueryBuilder<LocalPatientProfile, List<String>?, QQueryOperations>
      allergiesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'allergies');
    });
  }

  QueryBuilder<LocalPatientProfile, String?, QQueryOperations>
      bloodTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'bloodType');
    });
  }

  QueryBuilder<LocalPatientProfile, List<String>?, QQueryOperations>
      chronicConditionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chronicConditions');
    });
  }

  QueryBuilder<LocalPatientProfile, bool, QQueryOperations>
      consentGivenProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consentGiven');
    });
  }

  QueryBuilder<LocalPatientProfile, DateTime?, QQueryOperations>
      consentTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consentTimestamp');
    });
  }

  QueryBuilder<LocalPatientProfile, List<String>?, QQueryOperations>
      currentMedicationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'currentMedications');
    });
  }

  QueryBuilder<LocalPatientProfile, DateTime?, QQueryOperations>
      dateOfBirthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dateOfBirth');
    });
  }

  QueryBuilder<LocalPatientProfile, String?, QQueryOperations>
      emergencyContactNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emergencyContactName');
    });
  }

  QueryBuilder<LocalPatientProfile, String?, QQueryOperations>
      emergencyContactPhoneProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'emergencyContactPhone');
    });
  }

  QueryBuilder<LocalPatientProfile, String?, QQueryOperations>
      fullNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullName');
    });
  }

  QueryBuilder<LocalPatientProfile, String?, QQueryOperations>
      genderProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gender');
    });
  }

  QueryBuilder<LocalPatientProfile, bool, QQueryOperations>
      hasMinimalInfoProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'hasMinimalInfo');
    });
  }

  QueryBuilder<LocalPatientProfile, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<LocalPatientProfile, String?, QQueryOperations>
      preferredLanguageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'preferredLanguage');
    });
  }
}
