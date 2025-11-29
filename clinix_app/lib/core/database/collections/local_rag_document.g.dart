// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_rag_document.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalRAGDocumentCollection on Isar {
  IsarCollection<LocalRAGDocument> get localRAGDocuments => this.collection();
}

const LocalRAGDocumentSchema = CollectionSchema(
  name: r'LocalRAGDocument',
  id: 6891798941322824545,
  properties: {
    r'addedAt': PropertySchema(
      id: 0,
      name: r'addedAt',
      type: IsarType.dateTime,
    ),
    r'characterCount': PropertySchema(
      id: 1,
      name: r'characterCount',
      type: IsarType.long,
    ),
    r'chunkCount': PropertySchema(
      id: 2,
      name: r'chunkCount',
      type: IsarType.long,
    ),
    r'contentHash': PropertySchema(
      id: 3,
      name: r'contentHash',
      type: IsarType.string,
    ),
    r'documentId': PropertySchema(
      id: 4,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'documentType': PropertySchema(
      id: 5,
      name: r'documentType',
      type: IsarType.string,
      enumMap: _LocalRAGDocumentdocumentTypeEnumValueMap,
    ),
    r'fullContent': PropertySchema(
      id: 6,
      name: r'fullContent',
      type: IsarType.string,
    ),
    r'isSystemDocument': PropertySchema(
      id: 7,
      name: r'isSystemDocument',
      type: IsarType.bool,
    ),
    r'language': PropertySchema(
      id: 8,
      name: r'language',
      type: IsarType.string,
    ),
    r'originalFilePath': PropertySchema(
      id: 9,
      name: r'originalFilePath',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 10,
      name: r'priority',
      type: IsarType.long,
    ),
    r'source': PropertySchema(
      id: 11,
      name: r'source',
      type: IsarType.string,
    ),
    r'tags': PropertySchema(
      id: 12,
      name: r'tags',
      type: IsarType.stringList,
    ),
    r'title': PropertySchema(
      id: 13,
      name: r'title',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 14,
      name: r'updatedAt',
      type: IsarType.dateTime,
    ),
    r'version': PropertySchema(
      id: 15,
      name: r'version',
      type: IsarType.string,
    )
  },
  estimateSize: _localRAGDocumentEstimateSize,
  serialize: _localRAGDocumentSerialize,
  deserialize: _localRAGDocumentDeserialize,
  deserializeProp: _localRAGDocumentDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'addedAt': IndexSchema(
      id: -8595779697745674092,
      name: r'addedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'addedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _localRAGDocumentGetId,
  getLinks: _localRAGDocumentGetLinks,
  attach: _localRAGDocumentAttach,
  version: '3.1.0+1',
);

int _localRAGDocumentEstimateSize(
  LocalRAGDocument object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.contentHash;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.documentId.length * 3;
  bytesCount += 3 + object.documentType.name.length * 3;
  bytesCount += 3 + object.fullContent.length * 3;
  bytesCount += 3 + object.language.length * 3;
  {
    final value = object.originalFilePath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.source.length * 3;
  bytesCount += 3 + object.tags.length * 3;
  {
    for (var i = 0; i < object.tags.length; i++) {
      final value = object.tags[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.title.length * 3;
  {
    final value = object.version;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _localRAGDocumentSerialize(
  LocalRAGDocument object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.addedAt);
  writer.writeLong(offsets[1], object.characterCount);
  writer.writeLong(offsets[2], object.chunkCount);
  writer.writeString(offsets[3], object.contentHash);
  writer.writeString(offsets[4], object.documentId);
  writer.writeString(offsets[5], object.documentType.name);
  writer.writeString(offsets[6], object.fullContent);
  writer.writeBool(offsets[7], object.isSystemDocument);
  writer.writeString(offsets[8], object.language);
  writer.writeString(offsets[9], object.originalFilePath);
  writer.writeLong(offsets[10], object.priority);
  writer.writeString(offsets[11], object.source);
  writer.writeStringList(offsets[12], object.tags);
  writer.writeString(offsets[13], object.title);
  writer.writeDateTime(offsets[14], object.updatedAt);
  writer.writeString(offsets[15], object.version);
}

LocalRAGDocument _localRAGDocumentDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalRAGDocument();
  object.addedAt = reader.readDateTime(offsets[0]);
  object.characterCount = reader.readLong(offsets[1]);
  object.chunkCount = reader.readLong(offsets[2]);
  object.contentHash = reader.readStringOrNull(offsets[3]);
  object.documentId = reader.readString(offsets[4]);
  object.documentType = _LocalRAGDocumentdocumentTypeValueEnumMap[
          reader.readStringOrNull(offsets[5])] ??
      RAGDocumentType.medicalGuideline;
  object.fullContent = reader.readString(offsets[6]);
  object.id = id;
  object.isSystemDocument = reader.readBool(offsets[7]);
  object.language = reader.readString(offsets[8]);
  object.originalFilePath = reader.readStringOrNull(offsets[9]);
  object.priority = reader.readLong(offsets[10]);
  object.source = reader.readString(offsets[11]);
  object.tags = reader.readStringList(offsets[12]) ?? [];
  object.title = reader.readString(offsets[13]);
  object.updatedAt = reader.readDateTime(offsets[14]);
  object.version = reader.readStringOrNull(offsets[15]);
  return object;
}

P _localRAGDocumentDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readLong(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (_LocalRAGDocumentdocumentTypeValueEnumMap[
              reader.readStringOrNull(offset)] ??
          RAGDocumentType.medicalGuideline) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readBool(offset)) as P;
    case 8:
      return (reader.readString(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    case 11:
      return (reader.readString(offset)) as P;
    case 12:
      return (reader.readStringList(offset) ?? []) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readDateTime(offset)) as P;
    case 15:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LocalRAGDocumentdocumentTypeEnumValueMap = {
  r'medicalGuideline': r'medicalGuideline',
  r'drugReference': r'drugReference',
  r'symptomReference': r'symptomReference',
  r'emergencyProtocol': r'emergencyProtocol',
  r'patientHistory': r'patientHistory',
  r'localContext': r'localContext',
  r'custom': r'custom',
};
const _LocalRAGDocumentdocumentTypeValueEnumMap = {
  r'medicalGuideline': RAGDocumentType.medicalGuideline,
  r'drugReference': RAGDocumentType.drugReference,
  r'symptomReference': RAGDocumentType.symptomReference,
  r'emergencyProtocol': RAGDocumentType.emergencyProtocol,
  r'patientHistory': RAGDocumentType.patientHistory,
  r'localContext': RAGDocumentType.localContext,
  r'custom': RAGDocumentType.custom,
};

Id _localRAGDocumentGetId(LocalRAGDocument object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localRAGDocumentGetLinks(LocalRAGDocument object) {
  return [];
}

void _localRAGDocumentAttach(
    IsarCollection<dynamic> col, Id id, LocalRAGDocument object) {
  object.id = id;
}

extension LocalRAGDocumentByIndex on IsarCollection<LocalRAGDocument> {
  Future<LocalRAGDocument?> getByDocumentId(String documentId) {
    return getByIndex(r'documentId', [documentId]);
  }

  LocalRAGDocument? getByDocumentIdSync(String documentId) {
    return getByIndexSync(r'documentId', [documentId]);
  }

  Future<bool> deleteByDocumentId(String documentId) {
    return deleteByIndex(r'documentId', [documentId]);
  }

  bool deleteByDocumentIdSync(String documentId) {
    return deleteByIndexSync(r'documentId', [documentId]);
  }

  Future<List<LocalRAGDocument?>> getAllByDocumentId(
      List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'documentId', values);
  }

  List<LocalRAGDocument?> getAllByDocumentIdSync(
      List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'documentId', values);
  }

  Future<int> deleteAllByDocumentId(List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'documentId', values);
  }

  int deleteAllByDocumentIdSync(List<String> documentIdValues) {
    final values = documentIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'documentId', values);
  }

  Future<Id> putByDocumentId(LocalRAGDocument object) {
    return putByIndex(r'documentId', object);
  }

  Id putByDocumentIdSync(LocalRAGDocument object, {bool saveLinks = true}) {
    return putByIndexSync(r'documentId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByDocumentId(List<LocalRAGDocument> objects) {
    return putAllByIndex(r'documentId', objects);
  }

  List<Id> putAllByDocumentIdSync(List<LocalRAGDocument> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'documentId', objects, saveLinks: saveLinks);
  }
}

extension LocalRAGDocumentQueryWhereSort
    on QueryBuilder<LocalRAGDocument, LocalRAGDocument, QWhere> {
  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhere> anyAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'addedAt'),
      );
    });
  }
}

extension LocalRAGDocumentQueryWhere
    on QueryBuilder<LocalRAGDocument, LocalRAGDocument, QWhereClause> {
  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause>
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

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause> idBetween(
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

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause>
      documentIdEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause>
      documentIdNotEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause>
      addedAtEqualTo(DateTime addedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'addedAt',
        value: [addedAt],
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause>
      addedAtNotEqualTo(DateTime addedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addedAt',
              lower: [],
              upper: [addedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addedAt',
              lower: [addedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addedAt',
              lower: [addedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'addedAt',
              lower: [],
              upper: [addedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause>
      addedAtGreaterThan(
    DateTime addedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'addedAt',
        lower: [addedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause>
      addedAtLessThan(
    DateTime addedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'addedAt',
        lower: [],
        upper: [addedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterWhereClause>
      addedAtBetween(
    DateTime lowerAddedAt,
    DateTime upperAddedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'addedAt',
        lower: [lowerAddedAt],
        includeLower: includeLower,
        upper: [upperAddedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LocalRAGDocumentQueryFilter
    on QueryBuilder<LocalRAGDocument, LocalRAGDocument, QFilterCondition> {
  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      addedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      addedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      addedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'addedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      addedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'addedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      characterCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'characterCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      characterCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'characterCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      characterCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'characterCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      characterCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'characterCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      chunkCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chunkCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      chunkCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chunkCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      chunkCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chunkCount',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      chunkCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chunkCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'contentHash',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'contentHash',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentHash',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'contentHash',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'contentHash',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentHash',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      contentHashIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'contentHash',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentTypeEqualTo(
    RAGDocumentType value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentTypeGreaterThan(
    RAGDocumentType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentTypeLessThan(
    RAGDocumentType value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentTypeBetween(
    RAGDocumentType lower,
    RAGDocumentType upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentType',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentTypeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentTypeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentTypeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentType',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentTypeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentType',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentTypeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentType',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      documentTypeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentType',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      fullContentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      fullContentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fullContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      fullContentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fullContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      fullContentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fullContent',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      fullContentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fullContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      fullContentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fullContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      fullContentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fullContent',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      fullContentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fullContent',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      fullContentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fullContent',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      fullContentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fullContent',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
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

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
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

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
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

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      isSystemDocumentEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSystemDocument',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      languageEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      languageGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      languageLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      languageBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'language',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      languageStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      languageEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      languageContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'language',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      languageMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'language',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      languageIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      languageIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'language',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'originalFilePath',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'originalFilePath',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'originalFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'originalFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'originalFilePath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'originalFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'originalFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'originalFilePath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'originalFilePath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'originalFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      originalFilePathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'originalFilePath',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      priorityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      priorityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      priorityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      priorityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      sourceEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      sourceGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      sourceLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      sourceBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      sourceContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      sourceMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'tags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'tags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'tags',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      tagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'tags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      titleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      titleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      updatedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'version',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'version',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'version',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'version',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'version',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'version',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterFilterCondition>
      versionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'version',
        value: '',
      ));
    });
  }
}

extension LocalRAGDocumentQueryObject
    on QueryBuilder<LocalRAGDocument, LocalRAGDocument, QFilterCondition> {}

extension LocalRAGDocumentQueryLinks
    on QueryBuilder<LocalRAGDocument, LocalRAGDocument, QFilterCondition> {}

extension LocalRAGDocumentQuerySortBy
    on QueryBuilder<LocalRAGDocument, LocalRAGDocument, QSortBy> {
  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByCharacterCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterCount', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByCharacterCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterCount', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByChunkCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkCount', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByChunkCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkCount', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByDocumentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentType', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByDocumentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentType', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByFullContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullContent', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByFullContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullContent', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByIsSystemDocument() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystemDocument', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByIsSystemDocumentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystemDocument', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByOriginalFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalFilePath', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByOriginalFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalFilePath', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      sortByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension LocalRAGDocumentQuerySortThenBy
    on QueryBuilder<LocalRAGDocument, LocalRAGDocument, QSortThenBy> {
  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByAddedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'addedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByCharacterCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterCount', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByCharacterCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'characterCount', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByChunkCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkCount', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByChunkCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkCount', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByContentHash() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByContentHashDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentHash', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByDocumentType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentType', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByDocumentTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentType', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByFullContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullContent', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByFullContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fullContent', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByIsSystemDocument() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystemDocument', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByIsSystemDocumentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSystemDocument', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByLanguage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByLanguageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'language', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByOriginalFilePath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalFilePath', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByOriginalFilePathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'originalFilePath', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByVersion() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QAfterSortBy>
      thenByVersionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'version', Sort.desc);
    });
  }
}

extension LocalRAGDocumentQueryWhereDistinct
    on QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct> {
  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByAddedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'addedAt');
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByCharacterCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'characterCount');
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByChunkCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chunkCount');
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByContentHash({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentHash', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByDocumentId({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByDocumentType({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentType', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByFullContent({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fullContent', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByIsSystemDocument() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSystemDocument');
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByLanguage({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'language', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByOriginalFilePath({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'originalFilePath',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority');
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct> distinctByTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tags');
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct>
      distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }

  QueryBuilder<LocalRAGDocument, LocalRAGDocument, QDistinct> distinctByVersion(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'version', caseSensitive: caseSensitive);
    });
  }
}

extension LocalRAGDocumentQueryProperty
    on QueryBuilder<LocalRAGDocument, LocalRAGDocument, QQueryProperty> {
  QueryBuilder<LocalRAGDocument, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalRAGDocument, DateTime, QQueryOperations> addedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'addedAt');
    });
  }

  QueryBuilder<LocalRAGDocument, int, QQueryOperations>
      characterCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'characterCount');
    });
  }

  QueryBuilder<LocalRAGDocument, int, QQueryOperations> chunkCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chunkCount');
    });
  }

  QueryBuilder<LocalRAGDocument, String?, QQueryOperations>
      contentHashProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentHash');
    });
  }

  QueryBuilder<LocalRAGDocument, String, QQueryOperations>
      documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<LocalRAGDocument, RAGDocumentType, QQueryOperations>
      documentTypeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentType');
    });
  }

  QueryBuilder<LocalRAGDocument, String, QQueryOperations>
      fullContentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fullContent');
    });
  }

  QueryBuilder<LocalRAGDocument, bool, QQueryOperations>
      isSystemDocumentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSystemDocument');
    });
  }

  QueryBuilder<LocalRAGDocument, String, QQueryOperations> languageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'language');
    });
  }

  QueryBuilder<LocalRAGDocument, String?, QQueryOperations>
      originalFilePathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'originalFilePath');
    });
  }

  QueryBuilder<LocalRAGDocument, int, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<LocalRAGDocument, String, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<LocalRAGDocument, List<String>, QQueryOperations>
      tagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tags');
    });
  }

  QueryBuilder<LocalRAGDocument, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<LocalRAGDocument, DateTime, QQueryOperations>
      updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }

  QueryBuilder<LocalRAGDocument, String?, QQueryOperations> versionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'version');
    });
  }
}

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLocalRAGChunkCollection on Isar {
  IsarCollection<LocalRAGChunk> get localRAGChunks => this.collection();
}

const LocalRAGChunkSchema = CollectionSchema(
  name: r'LocalRAGChunk',
  id: -1126366744396878362,
  properties: {
    r'chunkIndex': PropertySchema(
      id: 0,
      name: r'chunkIndex',
      type: IsarType.long,
    ),
    r'content': PropertySchema(
      id: 1,
      name: r'content',
      type: IsarType.string,
    ),
    r'contentLength': PropertySchema(
      id: 2,
      name: r'contentLength',
      type: IsarType.long,
    ),
    r'documentId': PropertySchema(
      id: 3,
      name: r'documentId',
      type: IsarType.string,
    ),
    r'embedding': PropertySchema(
      id: 4,
      name: r'embedding',
      type: IsarType.doubleList,
    ),
    r'embeddingGeneratedAt': PropertySchema(
      id: 5,
      name: r'embeddingGeneratedAt',
      type: IsarType.dateTime,
    ),
    r'embeddingJson': PropertySchema(
      id: 6,
      name: r'embeddingJson',
      type: IsarType.string,
    ),
    r'embeddingModel': PropertySchema(
      id: 7,
      name: r'embeddingModel',
      type: IsarType.string,
    ),
    r'endPosition': PropertySchema(
      id: 8,
      name: r'endPosition',
      type: IsarType.long,
    ),
    r'sectionTitle': PropertySchema(
      id: 9,
      name: r'sectionTitle',
      type: IsarType.string,
    ),
    r'startPosition': PropertySchema(
      id: 10,
      name: r'startPosition',
      type: IsarType.long,
    )
  },
  estimateSize: _localRAGChunkEstimateSize,
  serialize: _localRAGChunkSerialize,
  deserialize: _localRAGChunkDeserialize,
  deserializeProp: _localRAGChunkDeserializeProp,
  idName: r'id',
  indexes: {
    r'documentId': IndexSchema(
      id: 4187168439921340405,
      name: r'documentId',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'documentId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _localRAGChunkGetId,
  getLinks: _localRAGChunkGetLinks,
  attach: _localRAGChunkAttach,
  version: '3.1.0+1',
);

int _localRAGChunkEstimateSize(
  LocalRAGChunk object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.content.length * 3;
  bytesCount += 3 + object.documentId.length * 3;
  {
    final value = object.embedding;
    if (value != null) {
      bytesCount += 3 + value.length * 8;
    }
  }
  {
    final value = object.embeddingJson;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.embeddingModel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.sectionTitle;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _localRAGChunkSerialize(
  LocalRAGChunk object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.chunkIndex);
  writer.writeString(offsets[1], object.content);
  writer.writeLong(offsets[2], object.contentLength);
  writer.writeString(offsets[3], object.documentId);
  writer.writeDoubleList(offsets[4], object.embedding);
  writer.writeDateTime(offsets[5], object.embeddingGeneratedAt);
  writer.writeString(offsets[6], object.embeddingJson);
  writer.writeString(offsets[7], object.embeddingModel);
  writer.writeLong(offsets[8], object.endPosition);
  writer.writeString(offsets[9], object.sectionTitle);
  writer.writeLong(offsets[10], object.startPosition);
}

LocalRAGChunk _localRAGChunkDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = LocalRAGChunk();
  object.chunkIndex = reader.readLong(offsets[0]);
  object.content = reader.readString(offsets[1]);
  object.documentId = reader.readString(offsets[3]);
  object.embedding = reader.readDoubleList(offsets[4]);
  object.embeddingGeneratedAt = reader.readDateTimeOrNull(offsets[5]);
  object.embeddingJson = reader.readStringOrNull(offsets[6]);
  object.embeddingModel = reader.readStringOrNull(offsets[7]);
  object.endPosition = reader.readLong(offsets[8]);
  object.id = id;
  object.sectionTitle = reader.readStringOrNull(offsets[9]);
  object.startPosition = reader.readLong(offsets[10]);
  return object;
}

P _localRAGChunkDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readDoubleList(offset)) as P;
    case 5:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readStringOrNull(offset)) as P;
    case 8:
      return (reader.readLong(offset)) as P;
    case 9:
      return (reader.readStringOrNull(offset)) as P;
    case 10:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _localRAGChunkGetId(LocalRAGChunk object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _localRAGChunkGetLinks(LocalRAGChunk object) {
  return [];
}

void _localRAGChunkAttach(
    IsarCollection<dynamic> col, Id id, LocalRAGChunk object) {
  object.id = id;
}

extension LocalRAGChunkQueryWhereSort
    on QueryBuilder<LocalRAGChunk, LocalRAGChunk, QWhere> {
  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LocalRAGChunkQueryWhere
    on QueryBuilder<LocalRAGChunk, LocalRAGChunk, QWhereClause> {
  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterWhereClause> idNotEqualTo(
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

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterWhereClause> idBetween(
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

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterWhereClause>
      documentIdEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'documentId',
        value: [documentId],
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterWhereClause>
      documentIdNotEqualTo(String documentId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [documentId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'documentId',
              lower: [],
              upper: [documentId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension LocalRAGChunkQueryFilter
    on QueryBuilder<LocalRAGChunk, LocalRAGChunk, QFilterCondition> {
  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      chunkIndexEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'chunkIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      chunkIndexGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'chunkIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      chunkIndexLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'chunkIndex',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      chunkIndexBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'chunkIndex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'content',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'content',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'content',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'content',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentLengthEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'contentLength',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentLengthGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'contentLength',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentLengthLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'contentLength',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      contentLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'contentLength',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      documentIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      documentIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      documentIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      documentIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'documentId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      documentIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      documentIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      documentIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'documentId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      documentIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'documentId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      documentIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      documentIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'documentId',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'embedding',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'embedding',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embedding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embedding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embedding',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embedding',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'embedding',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingGeneratedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'embeddingGeneratedAt',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingGeneratedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'embeddingGeneratedAt',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingGeneratedAtEqualTo(DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embeddingGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingGeneratedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embeddingGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingGeneratedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embeddingGeneratedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingGeneratedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embeddingGeneratedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'embeddingJson',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'embeddingJson',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embeddingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embeddingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embeddingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embeddingJson',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'embeddingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'embeddingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'embeddingJson',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'embeddingJson',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embeddingJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingJsonIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'embeddingJson',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'embeddingModel',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'embeddingModel',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embeddingModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'embeddingModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'embeddingModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'embeddingModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'embeddingModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'embeddingModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'embeddingModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'embeddingModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'embeddingModel',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      embeddingModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'embeddingModel',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      endPositionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      endPositionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      endPositionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      endPositionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endPosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
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

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition> idBetween(
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

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'sectionTitle',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'sectionTitle',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'sectionTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'sectionTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'sectionTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'sectionTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      sectionTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'sectionTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      startPositionEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      startPositionGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      startPositionLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startPosition',
        value: value,
      ));
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterFilterCondition>
      startPositionBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startPosition',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LocalRAGChunkQueryObject
    on QueryBuilder<LocalRAGChunk, LocalRAGChunk, QFilterCondition> {}

extension LocalRAGChunkQueryLinks
    on QueryBuilder<LocalRAGChunk, LocalRAGChunk, QFilterCondition> {}

extension LocalRAGChunkQuerySortBy
    on QueryBuilder<LocalRAGChunk, LocalRAGChunk, QSortBy> {
  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> sortByChunkIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkIndex', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByChunkIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkIndex', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> sortByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> sortByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByContentLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentLength', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByContentLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentLength', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> sortByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByEmbeddingGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByEmbeddingGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByEmbeddingJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingJson', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByEmbeddingJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingJson', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByEmbeddingModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingModel', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByEmbeddingModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingModel', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> sortByEndPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endPosition', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByEndPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endPosition', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortBySectionTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectionTitle', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortBySectionTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectionTitle', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByStartPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startPosition', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      sortByStartPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startPosition', Sort.desc);
    });
  }
}

extension LocalRAGChunkQuerySortThenBy
    on QueryBuilder<LocalRAGChunk, LocalRAGChunk, QSortThenBy> {
  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> thenByChunkIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkIndex', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByChunkIndexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'chunkIndex', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> thenByContent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> thenByContentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'content', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByContentLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentLength', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByContentLengthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'contentLength', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> thenByDocumentId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByDocumentIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'documentId', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByEmbeddingGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingGeneratedAt', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByEmbeddingGeneratedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingGeneratedAt', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByEmbeddingJson() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingJson', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByEmbeddingJsonDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingJson', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByEmbeddingModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingModel', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByEmbeddingModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'embeddingModel', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> thenByEndPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endPosition', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByEndPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endPosition', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenBySectionTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectionTitle', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenBySectionTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'sectionTitle', Sort.desc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByStartPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startPosition', Sort.asc);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QAfterSortBy>
      thenByStartPositionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startPosition', Sort.desc);
    });
  }
}

extension LocalRAGChunkQueryWhereDistinct
    on QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct> {
  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct> distinctByChunkIndex() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'chunkIndex');
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct> distinctByContent(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'content', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct>
      distinctByContentLength() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'contentLength');
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct> distinctByDocumentId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'documentId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct> distinctByEmbedding() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embedding');
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct>
      distinctByEmbeddingGeneratedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embeddingGeneratedAt');
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct> distinctByEmbeddingJson(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embeddingJson',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct>
      distinctByEmbeddingModel({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'embeddingModel',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct>
      distinctByEndPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endPosition');
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct> distinctBySectionTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'sectionTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<LocalRAGChunk, LocalRAGChunk, QDistinct>
      distinctByStartPosition() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startPosition');
    });
  }
}

extension LocalRAGChunkQueryProperty
    on QueryBuilder<LocalRAGChunk, LocalRAGChunk, QQueryProperty> {
  QueryBuilder<LocalRAGChunk, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<LocalRAGChunk, int, QQueryOperations> chunkIndexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'chunkIndex');
    });
  }

  QueryBuilder<LocalRAGChunk, String, QQueryOperations> contentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'content');
    });
  }

  QueryBuilder<LocalRAGChunk, int, QQueryOperations> contentLengthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'contentLength');
    });
  }

  QueryBuilder<LocalRAGChunk, String, QQueryOperations> documentIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'documentId');
    });
  }

  QueryBuilder<LocalRAGChunk, List<double>?, QQueryOperations>
      embeddingProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embedding');
    });
  }

  QueryBuilder<LocalRAGChunk, DateTime?, QQueryOperations>
      embeddingGeneratedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embeddingGeneratedAt');
    });
  }

  QueryBuilder<LocalRAGChunk, String?, QQueryOperations>
      embeddingJsonProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embeddingJson');
    });
  }

  QueryBuilder<LocalRAGChunk, String?, QQueryOperations>
      embeddingModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'embeddingModel');
    });
  }

  QueryBuilder<LocalRAGChunk, int, QQueryOperations> endPositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endPosition');
    });
  }

  QueryBuilder<LocalRAGChunk, String?, QQueryOperations>
      sectionTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'sectionTitle');
    });
  }

  QueryBuilder<LocalRAGChunk, int, QQueryOperations> startPositionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startPosition');
    });
  }
}
