// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $RoutesTable extends Routes with TableInfo<$RoutesTable, SavedRoute> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<int> distanceMeters = GeneratedColumn<int>(
    'distance_meters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, distanceMeters, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routes';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedRoute> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavedRoute map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedRoute(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_meters'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RoutesTable createAlias(String alias) {
    return $RoutesTable(attachedDatabase, alias);
  }
}

class SavedRoute extends DataClass implements Insertable<SavedRoute> {
  final int id;
  final String name;
  final int? distanceMeters;
  final DateTime createdAt;
  const SavedRoute({
    required this.id,
    required this.name,
    this.distanceMeters,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || distanceMeters != null) {
      map['distance_meters'] = Variable<int>(distanceMeters);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RoutesCompanion toCompanion(bool nullToAbsent) {
    return RoutesCompanion(
      id: Value(id),
      name: Value(name),
      distanceMeters: distanceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceMeters),
      createdAt: Value(createdAt),
    );
  }

  factory SavedRoute.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedRoute(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      distanceMeters: serializer.fromJson<int?>(json['distanceMeters']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'distanceMeters': serializer.toJson<int?>(distanceMeters),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavedRoute copyWith({
    int? id,
    String? name,
    Value<int?> distanceMeters = const Value.absent(),
    DateTime? createdAt,
  }) => SavedRoute(
    id: id ?? this.id,
    name: name ?? this.name,
    distanceMeters: distanceMeters.present
        ? distanceMeters.value
        : this.distanceMeters,
    createdAt: createdAt ?? this.createdAt,
  );
  SavedRoute copyWithCompanion(RoutesCompanion data) {
    return SavedRoute(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedRoute(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, distanceMeters, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedRoute &&
          other.id == this.id &&
          other.name == this.name &&
          other.distanceMeters == this.distanceMeters &&
          other.createdAt == this.createdAt);
}

class RoutesCompanion extends UpdateCompanion<SavedRoute> {
  final Value<int> id;
  final Value<String> name;
  final Value<int?> distanceMeters;
  final Value<DateTime> createdAt;
  const RoutesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RoutesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.distanceMeters = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<SavedRoute> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? distanceMeters,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RoutesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int?>? distanceMeters,
    Value<DateTime>? createdAt,
  }) {
    return RoutesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<int>(distanceMeters.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BikesTable extends Bikes with TableInfo<$BikesTable, Bike> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BikesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(BikeType.mountain),
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nicknameMeta = const VerificationMeta(
    'nickname',
  );
  @override
  late final GeneratedColumn<String> nickname = GeneratedColumn<String>(
    'nickname',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _odometerBaselineMetersMeta =
      const VerificationMeta('odometerBaselineMeters');
  @override
  late final GeneratedColumn<int> odometerBaselineMeters = GeneratedColumn<int>(
    'odometer_baseline_meters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _odometerBaselineAtMeta =
      const VerificationMeta('odometerBaselineAt');
  @override
  late final GeneratedColumn<DateTime> odometerBaselineAt =
      GeneratedColumn<DateTime>(
        'odometer_baseline_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        clientDefault: DateTime.now,
      );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    brand,
    model,
    nickname,
    photoPath,
    odometerBaselineMeters,
    odometerBaselineAt,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bikes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bike> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('nickname')) {
      context.handle(
        _nicknameMeta,
        nickname.isAcceptableOrUnknown(data['nickname']!, _nicknameMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('odometer_baseline_meters')) {
      context.handle(
        _odometerBaselineMetersMeta,
        odometerBaselineMeters.isAcceptableOrUnknown(
          data['odometer_baseline_meters']!,
          _odometerBaselineMetersMeta,
        ),
      );
    }
    if (data.containsKey('odometer_baseline_at')) {
      context.handle(
        _odometerBaselineAtMeta,
        odometerBaselineAt.isAcceptableOrUnknown(
          data['odometer_baseline_at']!,
          _odometerBaselineAtMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bike map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bike(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      nickname: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nickname'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      odometerBaselineMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_baseline_meters'],
      )!,
      odometerBaselineAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}odometer_baseline_at'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BikesTable createAlias(String alias) {
    return $BikesTable(attachedDatabase, alias);
  }
}

class Bike extends DataClass implements Insertable<Bike> {
  final int id;
  final String type;
  final String brand;
  final String model;
  final String? nickname;
  final String? photoPath;
  final int odometerBaselineMeters;
  final DateTime odometerBaselineAt;
  final bool isArchived;
  final DateTime createdAt;
  const Bike({
    required this.id,
    required this.type,
    required this.brand,
    required this.model,
    this.nickname,
    this.photoPath,
    required this.odometerBaselineMeters,
    required this.odometerBaselineAt,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['brand'] = Variable<String>(brand);
    map['model'] = Variable<String>(model);
    if (!nullToAbsent || nickname != null) {
      map['nickname'] = Variable<String>(nickname);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    map['odometer_baseline_meters'] = Variable<int>(odometerBaselineMeters);
    map['odometer_baseline_at'] = Variable<DateTime>(odometerBaselineAt);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BikesCompanion toCompanion(bool nullToAbsent) {
    return BikesCompanion(
      id: Value(id),
      type: Value(type),
      brand: Value(brand),
      model: Value(model),
      nickname: nickname == null && nullToAbsent
          ? const Value.absent()
          : Value(nickname),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      odometerBaselineMeters: Value(odometerBaselineMeters),
      odometerBaselineAt: Value(odometerBaselineAt),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory Bike.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bike(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      brand: serializer.fromJson<String>(json['brand']),
      model: serializer.fromJson<String>(json['model']),
      nickname: serializer.fromJson<String?>(json['nickname']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      odometerBaselineMeters: serializer.fromJson<int>(
        json['odometerBaselineMeters'],
      ),
      odometerBaselineAt: serializer.fromJson<DateTime>(
        json['odometerBaselineAt'],
      ),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'brand': serializer.toJson<String>(brand),
      'model': serializer.toJson<String>(model),
      'nickname': serializer.toJson<String?>(nickname),
      'photoPath': serializer.toJson<String?>(photoPath),
      'odometerBaselineMeters': serializer.toJson<int>(odometerBaselineMeters),
      'odometerBaselineAt': serializer.toJson<DateTime>(odometerBaselineAt),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Bike copyWith({
    int? id,
    String? type,
    String? brand,
    String? model,
    Value<String?> nickname = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    int? odometerBaselineMeters,
    DateTime? odometerBaselineAt,
    bool? isArchived,
    DateTime? createdAt,
  }) => Bike(
    id: id ?? this.id,
    type: type ?? this.type,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    nickname: nickname.present ? nickname.value : this.nickname,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    odometerBaselineMeters:
        odometerBaselineMeters ?? this.odometerBaselineMeters,
    odometerBaselineAt: odometerBaselineAt ?? this.odometerBaselineAt,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  Bike copyWithCompanion(BikesCompanion data) {
    return Bike(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      nickname: data.nickname.present ? data.nickname.value : this.nickname,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      odometerBaselineMeters: data.odometerBaselineMeters.present
          ? data.odometerBaselineMeters.value
          : this.odometerBaselineMeters,
      odometerBaselineAt: data.odometerBaselineAt.present
          ? data.odometerBaselineAt.value
          : this.odometerBaselineAt,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bike(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('nickname: $nickname, ')
          ..write('photoPath: $photoPath, ')
          ..write('odometerBaselineMeters: $odometerBaselineMeters, ')
          ..write('odometerBaselineAt: $odometerBaselineAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    brand,
    model,
    nickname,
    photoPath,
    odometerBaselineMeters,
    odometerBaselineAt,
    isArchived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bike &&
          other.id == this.id &&
          other.type == this.type &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.nickname == this.nickname &&
          other.photoPath == this.photoPath &&
          other.odometerBaselineMeters == this.odometerBaselineMeters &&
          other.odometerBaselineAt == this.odometerBaselineAt &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class BikesCompanion extends UpdateCompanion<Bike> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> brand;
  final Value<String> model;
  final Value<String?> nickname;
  final Value<String?> photoPath;
  final Value<int> odometerBaselineMeters;
  final Value<DateTime> odometerBaselineAt;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  const BikesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.nickname = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.odometerBaselineMeters = const Value.absent(),
    this.odometerBaselineAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BikesCompanion.insert({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    required String brand,
    required String model,
    this.nickname = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.odometerBaselineMeters = const Value.absent(),
    this.odometerBaselineAt = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : brand = Value(brand),
       model = Value(model);
  static Insertable<Bike> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<String>? nickname,
    Expression<String>? photoPath,
    Expression<int>? odometerBaselineMeters,
    Expression<DateTime>? odometerBaselineAt,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (nickname != null) 'nickname': nickname,
      if (photoPath != null) 'photo_path': photoPath,
      if (odometerBaselineMeters != null)
        'odometer_baseline_meters': odometerBaselineMeters,
      if (odometerBaselineAt != null)
        'odometer_baseline_at': odometerBaselineAt,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BikesCompanion copyWith({
    Value<int>? id,
    Value<String>? type,
    Value<String>? brand,
    Value<String>? model,
    Value<String?>? nickname,
    Value<String?>? photoPath,
    Value<int>? odometerBaselineMeters,
    Value<DateTime>? odometerBaselineAt,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
  }) {
    return BikesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      nickname: nickname ?? this.nickname,
      photoPath: photoPath ?? this.photoPath,
      odometerBaselineMeters:
          odometerBaselineMeters ?? this.odometerBaselineMeters,
      odometerBaselineAt: odometerBaselineAt ?? this.odometerBaselineAt,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (nickname.present) {
      map['nickname'] = Variable<String>(nickname.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (odometerBaselineMeters.present) {
      map['odometer_baseline_meters'] = Variable<int>(
        odometerBaselineMeters.value,
      );
    }
    if (odometerBaselineAt.present) {
      map['odometer_baseline_at'] = Variable<DateTime>(
        odometerBaselineAt.value,
      );
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BikesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('nickname: $nickname, ')
          ..write('photoPath: $photoPath, ')
          ..write('odometerBaselineMeters: $odometerBaselineMeters, ')
          ..write('odometerBaselineAt: $odometerBaselineAt, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RidesTable extends Rides with TableInfo<$RidesTable, Ride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RidesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pausedDurationSecondsMeta =
      const VerificationMeta('pausedDurationSeconds');
  @override
  late final GeneratedColumn<int> pausedDurationSeconds = GeneratedColumn<int>(
    'paused_duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pausedAtMeta = const VerificationMeta(
    'pausedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pausedAt = GeneratedColumn<DateTime>(
    'paused_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _distanceMetersMeta = const VerificationMeta(
    'distanceMeters',
  );
  @override
  late final GeneratedColumn<int> distanceMeters = GeneratedColumn<int>(
    'distance_meters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _elevationGainMetersMeta =
      const VerificationMeta('elevationGainMeters');
  @override
  late final GeneratedColumn<double> elevationGainMeters =
      GeneratedColumn<double>(
        'elevation_gain_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _averageSpeedMetersPerSecondMeta =
      const VerificationMeta('averageSpeedMetersPerSecond');
  @override
  late final GeneratedColumn<double> averageSpeedMetersPerSecond =
      GeneratedColumn<double>(
        'average_speed_meters_per_second',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _maxSpeedMetersPerSecondMeta =
      const VerificationMeta('maxSpeedMetersPerSecond');
  @override
  late final GeneratedColumn<double> maxSpeedMetersPerSecond =
      GeneratedColumn<double>(
        'max_speed_meters_per_second',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RideStatus.recording),
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routes (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _bikeIdMeta = const VerificationMeta('bikeId');
  @override
  late final GeneratedColumn<int> bikeId = GeneratedColumn<int>(
    'bike_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bikes (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    startedAt,
    finishedAt,
    durationSeconds,
    pausedDurationSeconds,
    pausedAt,
    distanceMeters,
    elevationGainMeters,
    averageSpeedMetersPerSecond,
    maxSpeedMetersPerSecond,
    status,
    routeId,
    bikeId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rides';
  @override
  VerificationContext validateIntegrity(
    Insertable<Ride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('paused_duration_seconds')) {
      context.handle(
        _pausedDurationSecondsMeta,
        pausedDurationSeconds.isAcceptableOrUnknown(
          data['paused_duration_seconds']!,
          _pausedDurationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('paused_at')) {
      context.handle(
        _pausedAtMeta,
        pausedAt.isAcceptableOrUnknown(data['paused_at']!, _pausedAtMeta),
      );
    }
    if (data.containsKey('distance_meters')) {
      context.handle(
        _distanceMetersMeta,
        distanceMeters.isAcceptableOrUnknown(
          data['distance_meters']!,
          _distanceMetersMeta,
        ),
      );
    }
    if (data.containsKey('elevation_gain_meters')) {
      context.handle(
        _elevationGainMetersMeta,
        elevationGainMeters.isAcceptableOrUnknown(
          data['elevation_gain_meters']!,
          _elevationGainMetersMeta,
        ),
      );
    }
    if (data.containsKey('average_speed_meters_per_second')) {
      context.handle(
        _averageSpeedMetersPerSecondMeta,
        averageSpeedMetersPerSecond.isAcceptableOrUnknown(
          data['average_speed_meters_per_second']!,
          _averageSpeedMetersPerSecondMeta,
        ),
      );
    }
    if (data.containsKey('max_speed_meters_per_second')) {
      context.handle(
        _maxSpeedMetersPerSecondMeta,
        maxSpeedMetersPerSecond.isAcceptableOrUnknown(
          data['max_speed_meters_per_second']!,
          _maxSpeedMetersPerSecondMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    }
    if (data.containsKey('bike_id')) {
      context.handle(
        _bikeIdMeta,
        bikeId.isAcceptableOrUnknown(data['bike_id']!, _bikeIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Ride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Ride(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      ),
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      pausedDurationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paused_duration_seconds'],
      )!,
      pausedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paused_at'],
      ),
      distanceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_meters'],
      )!,
      elevationGainMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}elevation_gain_meters'],
      ),
      averageSpeedMetersPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}average_speed_meters_per_second'],
      ),
      maxSpeedMetersPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_speed_meters_per_second'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_id'],
      ),
      bikeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bike_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RidesTable createAlias(String alias) {
    return $RidesTable(attachedDatabase, alias);
  }
}

class Ride extends DataClass implements Insertable<Ride> {
  final int id;
  final String? title;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final int durationSeconds;
  final int pausedDurationSeconds;
  final DateTime? pausedAt;
  final int distanceMeters;
  final double? elevationGainMeters;
  final double? averageSpeedMetersPerSecond;
  final double? maxSpeedMetersPerSecond;
  final String status;
  final int? routeId;
  final int? bikeId;
  final DateTime createdAt;
  const Ride({
    required this.id,
    this.title,
    required this.startedAt,
    this.finishedAt,
    required this.durationSeconds,
    required this.pausedDurationSeconds,
    this.pausedAt,
    required this.distanceMeters,
    this.elevationGainMeters,
    this.averageSpeedMetersPerSecond,
    this.maxSpeedMetersPerSecond,
    required this.status,
    this.routeId,
    this.bikeId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<DateTime>(finishedAt);
    }
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['paused_duration_seconds'] = Variable<int>(pausedDurationSeconds);
    if (!nullToAbsent || pausedAt != null) {
      map['paused_at'] = Variable<DateTime>(pausedAt);
    }
    map['distance_meters'] = Variable<int>(distanceMeters);
    if (!nullToAbsent || elevationGainMeters != null) {
      map['elevation_gain_meters'] = Variable<double>(elevationGainMeters);
    }
    if (!nullToAbsent || averageSpeedMetersPerSecond != null) {
      map['average_speed_meters_per_second'] = Variable<double>(
        averageSpeedMetersPerSecond,
      );
    }
    if (!nullToAbsent || maxSpeedMetersPerSecond != null) {
      map['max_speed_meters_per_second'] = Variable<double>(
        maxSpeedMetersPerSecond,
      );
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || routeId != null) {
      map['route_id'] = Variable<int>(routeId);
    }
    if (!nullToAbsent || bikeId != null) {
      map['bike_id'] = Variable<int>(bikeId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RidesCompanion toCompanion(bool nullToAbsent) {
    return RidesCompanion(
      id: Value(id),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      startedAt: Value(startedAt),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      durationSeconds: Value(durationSeconds),
      pausedDurationSeconds: Value(pausedDurationSeconds),
      pausedAt: pausedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(pausedAt),
      distanceMeters: Value(distanceMeters),
      elevationGainMeters: elevationGainMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(elevationGainMeters),
      averageSpeedMetersPerSecond:
          averageSpeedMetersPerSecond == null && nullToAbsent
          ? const Value.absent()
          : Value(averageSpeedMetersPerSecond),
      maxSpeedMetersPerSecond: maxSpeedMetersPerSecond == null && nullToAbsent
          ? const Value.absent()
          : Value(maxSpeedMetersPerSecond),
      status: Value(status),
      routeId: routeId == null && nullToAbsent
          ? const Value.absent()
          : Value(routeId),
      bikeId: bikeId == null && nullToAbsent
          ? const Value.absent()
          : Value(bikeId),
      createdAt: Value(createdAt),
    );
  }

  factory Ride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Ride(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      pausedDurationSeconds: serializer.fromJson<int>(
        json['pausedDurationSeconds'],
      ),
      pausedAt: serializer.fromJson<DateTime?>(json['pausedAt']),
      distanceMeters: serializer.fromJson<int>(json['distanceMeters']),
      elevationGainMeters: serializer.fromJson<double?>(
        json['elevationGainMeters'],
      ),
      averageSpeedMetersPerSecond: serializer.fromJson<double?>(
        json['averageSpeedMetersPerSecond'],
      ),
      maxSpeedMetersPerSecond: serializer.fromJson<double?>(
        json['maxSpeedMetersPerSecond'],
      ),
      status: serializer.fromJson<String>(json['status']),
      routeId: serializer.fromJson<int?>(json['routeId']),
      bikeId: serializer.fromJson<int?>(json['bikeId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String?>(title),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'pausedDurationSeconds': serializer.toJson<int>(pausedDurationSeconds),
      'pausedAt': serializer.toJson<DateTime?>(pausedAt),
      'distanceMeters': serializer.toJson<int>(distanceMeters),
      'elevationGainMeters': serializer.toJson<double?>(elevationGainMeters),
      'averageSpeedMetersPerSecond': serializer.toJson<double?>(
        averageSpeedMetersPerSecond,
      ),
      'maxSpeedMetersPerSecond': serializer.toJson<double?>(
        maxSpeedMetersPerSecond,
      ),
      'status': serializer.toJson<String>(status),
      'routeId': serializer.toJson<int?>(routeId),
      'bikeId': serializer.toJson<int?>(bikeId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Ride copyWith({
    int? id,
    Value<String?> title = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> finishedAt = const Value.absent(),
    int? durationSeconds,
    int? pausedDurationSeconds,
    Value<DateTime?> pausedAt = const Value.absent(),
    int? distanceMeters,
    Value<double?> elevationGainMeters = const Value.absent(),
    Value<double?> averageSpeedMetersPerSecond = const Value.absent(),
    Value<double?> maxSpeedMetersPerSecond = const Value.absent(),
    String? status,
    Value<int?> routeId = const Value.absent(),
    Value<int?> bikeId = const Value.absent(),
    DateTime? createdAt,
  }) => Ride(
    id: id ?? this.id,
    title: title.present ? title.value : this.title,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    pausedDurationSeconds: pausedDurationSeconds ?? this.pausedDurationSeconds,
    pausedAt: pausedAt.present ? pausedAt.value : this.pausedAt,
    distanceMeters: distanceMeters ?? this.distanceMeters,
    elevationGainMeters: elevationGainMeters.present
        ? elevationGainMeters.value
        : this.elevationGainMeters,
    averageSpeedMetersPerSecond: averageSpeedMetersPerSecond.present
        ? averageSpeedMetersPerSecond.value
        : this.averageSpeedMetersPerSecond,
    maxSpeedMetersPerSecond: maxSpeedMetersPerSecond.present
        ? maxSpeedMetersPerSecond.value
        : this.maxSpeedMetersPerSecond,
    status: status ?? this.status,
    routeId: routeId.present ? routeId.value : this.routeId,
    bikeId: bikeId.present ? bikeId.value : this.bikeId,
    createdAt: createdAt ?? this.createdAt,
  );
  Ride copyWithCompanion(RidesCompanion data) {
    return Ride(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      pausedDurationSeconds: data.pausedDurationSeconds.present
          ? data.pausedDurationSeconds.value
          : this.pausedDurationSeconds,
      pausedAt: data.pausedAt.present ? data.pausedAt.value : this.pausedAt,
      distanceMeters: data.distanceMeters.present
          ? data.distanceMeters.value
          : this.distanceMeters,
      elevationGainMeters: data.elevationGainMeters.present
          ? data.elevationGainMeters.value
          : this.elevationGainMeters,
      averageSpeedMetersPerSecond: data.averageSpeedMetersPerSecond.present
          ? data.averageSpeedMetersPerSecond.value
          : this.averageSpeedMetersPerSecond,
      maxSpeedMetersPerSecond: data.maxSpeedMetersPerSecond.present
          ? data.maxSpeedMetersPerSecond.value
          : this.maxSpeedMetersPerSecond,
      status: data.status.present ? data.status.value : this.status,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      bikeId: data.bikeId.present ? data.bikeId.value : this.bikeId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Ride(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pausedDurationSeconds: $pausedDurationSeconds, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('averageSpeedMetersPerSecond: $averageSpeedMetersPerSecond, ')
          ..write('maxSpeedMetersPerSecond: $maxSpeedMetersPerSecond, ')
          ..write('status: $status, ')
          ..write('routeId: $routeId, ')
          ..write('bikeId: $bikeId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    startedAt,
    finishedAt,
    durationSeconds,
    pausedDurationSeconds,
    pausedAt,
    distanceMeters,
    elevationGainMeters,
    averageSpeedMetersPerSecond,
    maxSpeedMetersPerSecond,
    status,
    routeId,
    bikeId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Ride &&
          other.id == this.id &&
          other.title == this.title &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.pausedDurationSeconds == this.pausedDurationSeconds &&
          other.pausedAt == this.pausedAt &&
          other.distanceMeters == this.distanceMeters &&
          other.elevationGainMeters == this.elevationGainMeters &&
          other.averageSpeedMetersPerSecond ==
              this.averageSpeedMetersPerSecond &&
          other.maxSpeedMetersPerSecond == this.maxSpeedMetersPerSecond &&
          other.status == this.status &&
          other.routeId == this.routeId &&
          other.bikeId == this.bikeId &&
          other.createdAt == this.createdAt);
}

class RidesCompanion extends UpdateCompanion<Ride> {
  final Value<int> id;
  final Value<String?> title;
  final Value<DateTime> startedAt;
  final Value<DateTime?> finishedAt;
  final Value<int> durationSeconds;
  final Value<int> pausedDurationSeconds;
  final Value<DateTime?> pausedAt;
  final Value<int> distanceMeters;
  final Value<double?> elevationGainMeters;
  final Value<double?> averageSpeedMetersPerSecond;
  final Value<double?> maxSpeedMetersPerSecond;
  final Value<String> status;
  final Value<int?> routeId;
  final Value<int?> bikeId;
  final Value<DateTime> createdAt;
  const RidesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.pausedDurationSeconds = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.averageSpeedMetersPerSecond = const Value.absent(),
    this.maxSpeedMetersPerSecond = const Value.absent(),
    this.status = const Value.absent(),
    this.routeId = const Value.absent(),
    this.bikeId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RidesCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    required DateTime startedAt,
    this.finishedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.pausedDurationSeconds = const Value.absent(),
    this.pausedAt = const Value.absent(),
    this.distanceMeters = const Value.absent(),
    this.elevationGainMeters = const Value.absent(),
    this.averageSpeedMetersPerSecond = const Value.absent(),
    this.maxSpeedMetersPerSecond = const Value.absent(),
    this.status = const Value.absent(),
    this.routeId = const Value.absent(),
    this.bikeId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<Ride> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<int>? durationSeconds,
    Expression<int>? pausedDurationSeconds,
    Expression<DateTime>? pausedAt,
    Expression<int>? distanceMeters,
    Expression<double>? elevationGainMeters,
    Expression<double>? averageSpeedMetersPerSecond,
    Expression<double>? maxSpeedMetersPerSecond,
    Expression<String>? status,
    Expression<int>? routeId,
    Expression<int>? bikeId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (pausedDurationSeconds != null)
        'paused_duration_seconds': pausedDurationSeconds,
      if (pausedAt != null) 'paused_at': pausedAt,
      if (distanceMeters != null) 'distance_meters': distanceMeters,
      if (elevationGainMeters != null)
        'elevation_gain_meters': elevationGainMeters,
      if (averageSpeedMetersPerSecond != null)
        'average_speed_meters_per_second': averageSpeedMetersPerSecond,
      if (maxSpeedMetersPerSecond != null)
        'max_speed_meters_per_second': maxSpeedMetersPerSecond,
      if (status != null) 'status': status,
      if (routeId != null) 'route_id': routeId,
      if (bikeId != null) 'bike_id': bikeId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RidesCompanion copyWith({
    Value<int>? id,
    Value<String?>? title,
    Value<DateTime>? startedAt,
    Value<DateTime?>? finishedAt,
    Value<int>? durationSeconds,
    Value<int>? pausedDurationSeconds,
    Value<DateTime?>? pausedAt,
    Value<int>? distanceMeters,
    Value<double?>? elevationGainMeters,
    Value<double?>? averageSpeedMetersPerSecond,
    Value<double?>? maxSpeedMetersPerSecond,
    Value<String>? status,
    Value<int?>? routeId,
    Value<int?>? bikeId,
    Value<DateTime>? createdAt,
  }) {
    return RidesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      pausedDurationSeconds:
          pausedDurationSeconds ?? this.pausedDurationSeconds,
      pausedAt: pausedAt ?? this.pausedAt,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      elevationGainMeters: elevationGainMeters ?? this.elevationGainMeters,
      averageSpeedMetersPerSecond:
          averageSpeedMetersPerSecond ?? this.averageSpeedMetersPerSecond,
      maxSpeedMetersPerSecond:
          maxSpeedMetersPerSecond ?? this.maxSpeedMetersPerSecond,
      status: status ?? this.status,
      routeId: routeId ?? this.routeId,
      bikeId: bikeId ?? this.bikeId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (pausedDurationSeconds.present) {
      map['paused_duration_seconds'] = Variable<int>(
        pausedDurationSeconds.value,
      );
    }
    if (pausedAt.present) {
      map['paused_at'] = Variable<DateTime>(pausedAt.value);
    }
    if (distanceMeters.present) {
      map['distance_meters'] = Variable<int>(distanceMeters.value);
    }
    if (elevationGainMeters.present) {
      map['elevation_gain_meters'] = Variable<double>(
        elevationGainMeters.value,
      );
    }
    if (averageSpeedMetersPerSecond.present) {
      map['average_speed_meters_per_second'] = Variable<double>(
        averageSpeedMetersPerSecond.value,
      );
    }
    if (maxSpeedMetersPerSecond.present) {
      map['max_speed_meters_per_second'] = Variable<double>(
        maxSpeedMetersPerSecond.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (bikeId.present) {
      map['bike_id'] = Variable<int>(bikeId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RidesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('pausedDurationSeconds: $pausedDurationSeconds, ')
          ..write('pausedAt: $pausedAt, ')
          ..write('distanceMeters: $distanceMeters, ')
          ..write('elevationGainMeters: $elevationGainMeters, ')
          ..write('averageSpeedMetersPerSecond: $averageSpeedMetersPerSecond, ')
          ..write('maxSpeedMetersPerSecond: $maxSpeedMetersPerSecond, ')
          ..write('status: $status, ')
          ..write('routeId: $routeId, ')
          ..write('bikeId: $bikeId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RideTrackPointsTable extends RideTrackPoints
    with TableInfo<$RideTrackPointsTable, RideTrackPoint> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RideTrackPointsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rideIdMeta = const VerificationMeta('rideId');
  @override
  late final GeneratedColumn<int> rideId = GeneratedColumn<int>(
    'ride_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rides (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMetersMeta = const VerificationMeta(
    'altitudeMeters',
  );
  @override
  late final GeneratedColumn<double> altitudeMeters = GeneratedColumn<double>(
    'altitude_meters',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _horizontalAccuracyMetersMeta =
      const VerificationMeta('horizontalAccuracyMeters');
  @override
  late final GeneratedColumn<double> horizontalAccuracyMeters =
      GeneratedColumn<double>(
        'horizontal_accuracy_meters',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _speedMetersPerSecondMeta =
      const VerificationMeta('speedMetersPerSecond');
  @override
  late final GeneratedColumn<double> speedMetersPerSecond =
      GeneratedColumn<double>(
        'speed_meters_per_second',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rideId,
    sequence,
    latitude,
    longitude,
    altitudeMeters,
    horizontalAccuracyMeters,
    speedMetersPerSecond,
    recordedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ride_track_points';
  @override
  VerificationContext validateIntegrity(
    Insertable<RideTrackPoint> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ride_id')) {
      context.handle(
        _rideIdMeta,
        rideId.isAcceptableOrUnknown(data['ride_id']!, _rideIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rideIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude_meters')) {
      context.handle(
        _altitudeMetersMeta,
        altitudeMeters.isAcceptableOrUnknown(
          data['altitude_meters']!,
          _altitudeMetersMeta,
        ),
      );
    }
    if (data.containsKey('horizontal_accuracy_meters')) {
      context.handle(
        _horizontalAccuracyMetersMeta,
        horizontalAccuracyMeters.isAcceptableOrUnknown(
          data['horizontal_accuracy_meters']!,
          _horizontalAccuracyMetersMeta,
        ),
      );
    }
    if (data.containsKey('speed_meters_per_second')) {
      context.handle(
        _speedMetersPerSecondMeta,
        speedMetersPerSecond.isAcceptableOrUnknown(
          data['speed_meters_per_second']!,
          _speedMetersPerSecondMeta,
        ),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_recordedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {rideId, sequence},
  ];
  @override
  RideTrackPoint map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RideTrackPoint(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rideId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ride_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitudeMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}altitude_meters'],
      ),
      horizontalAccuracyMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}horizontal_accuracy_meters'],
      ),
      speedMetersPerSecond: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed_meters_per_second'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
    );
  }

  @override
  $RideTrackPointsTable createAlias(String alias) {
    return $RideTrackPointsTable(attachedDatabase, alias);
  }
}

class RideTrackPoint extends DataClass implements Insertable<RideTrackPoint> {
  final int id;
  final int rideId;
  final int sequence;
  final double latitude;
  final double longitude;
  final double? altitudeMeters;
  final double? horizontalAccuracyMeters;
  final double? speedMetersPerSecond;
  final DateTime recordedAt;
  const RideTrackPoint({
    required this.id,
    required this.rideId,
    required this.sequence,
    required this.latitude,
    required this.longitude,
    this.altitudeMeters,
    this.horizontalAccuracyMeters,
    this.speedMetersPerSecond,
    required this.recordedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ride_id'] = Variable<int>(rideId);
    map['sequence'] = Variable<int>(sequence);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitudeMeters != null) {
      map['altitude_meters'] = Variable<double>(altitudeMeters);
    }
    if (!nullToAbsent || horizontalAccuracyMeters != null) {
      map['horizontal_accuracy_meters'] = Variable<double>(
        horizontalAccuracyMeters,
      );
    }
    if (!nullToAbsent || speedMetersPerSecond != null) {
      map['speed_meters_per_second'] = Variable<double>(speedMetersPerSecond);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    return map;
  }

  RideTrackPointsCompanion toCompanion(bool nullToAbsent) {
    return RideTrackPointsCompanion(
      id: Value(id),
      rideId: Value(rideId),
      sequence: Value(sequence),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitudeMeters: altitudeMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(altitudeMeters),
      horizontalAccuracyMeters: horizontalAccuracyMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(horizontalAccuracyMeters),
      speedMetersPerSecond: speedMetersPerSecond == null && nullToAbsent
          ? const Value.absent()
          : Value(speedMetersPerSecond),
      recordedAt: Value(recordedAt),
    );
  }

  factory RideTrackPoint.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RideTrackPoint(
      id: serializer.fromJson<int>(json['id']),
      rideId: serializer.fromJson<int>(json['rideId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitudeMeters: serializer.fromJson<double?>(json['altitudeMeters']),
      horizontalAccuracyMeters: serializer.fromJson<double?>(
        json['horizontalAccuracyMeters'],
      ),
      speedMetersPerSecond: serializer.fromJson<double?>(
        json['speedMetersPerSecond'],
      ),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rideId': serializer.toJson<int>(rideId),
      'sequence': serializer.toJson<int>(sequence),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitudeMeters': serializer.toJson<double?>(altitudeMeters),
      'horizontalAccuracyMeters': serializer.toJson<double?>(
        horizontalAccuracyMeters,
      ),
      'speedMetersPerSecond': serializer.toJson<double?>(speedMetersPerSecond),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
    };
  }

  RideTrackPoint copyWith({
    int? id,
    int? rideId,
    int? sequence,
    double? latitude,
    double? longitude,
    Value<double?> altitudeMeters = const Value.absent(),
    Value<double?> horizontalAccuracyMeters = const Value.absent(),
    Value<double?> speedMetersPerSecond = const Value.absent(),
    DateTime? recordedAt,
  }) => RideTrackPoint(
    id: id ?? this.id,
    rideId: rideId ?? this.rideId,
    sequence: sequence ?? this.sequence,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitudeMeters: altitudeMeters.present
        ? altitudeMeters.value
        : this.altitudeMeters,
    horizontalAccuracyMeters: horizontalAccuracyMeters.present
        ? horizontalAccuracyMeters.value
        : this.horizontalAccuracyMeters,
    speedMetersPerSecond: speedMetersPerSecond.present
        ? speedMetersPerSecond.value
        : this.speedMetersPerSecond,
    recordedAt: recordedAt ?? this.recordedAt,
  );
  RideTrackPoint copyWithCompanion(RideTrackPointsCompanion data) {
    return RideTrackPoint(
      id: data.id.present ? data.id.value : this.id,
      rideId: data.rideId.present ? data.rideId.value : this.rideId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitudeMeters: data.altitudeMeters.present
          ? data.altitudeMeters.value
          : this.altitudeMeters,
      horizontalAccuracyMeters: data.horizontalAccuracyMeters.present
          ? data.horizontalAccuracyMeters.value
          : this.horizontalAccuracyMeters,
      speedMetersPerSecond: data.speedMetersPerSecond.present
          ? data.speedMetersPerSecond.value
          : this.speedMetersPerSecond,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RideTrackPoint(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('sequence: $sequence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitudeMeters: $altitudeMeters, ')
          ..write('horizontalAccuracyMeters: $horizontalAccuracyMeters, ')
          ..write('speedMetersPerSecond: $speedMetersPerSecond, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rideId,
    sequence,
    latitude,
    longitude,
    altitudeMeters,
    horizontalAccuracyMeters,
    speedMetersPerSecond,
    recordedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RideTrackPoint &&
          other.id == this.id &&
          other.rideId == this.rideId &&
          other.sequence == this.sequence &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitudeMeters == this.altitudeMeters &&
          other.horizontalAccuracyMeters == this.horizontalAccuracyMeters &&
          other.speedMetersPerSecond == this.speedMetersPerSecond &&
          other.recordedAt == this.recordedAt);
}

class RideTrackPointsCompanion extends UpdateCompanion<RideTrackPoint> {
  final Value<int> id;
  final Value<int> rideId;
  final Value<int> sequence;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<double?> altitudeMeters;
  final Value<double?> horizontalAccuracyMeters;
  final Value<double?> speedMetersPerSecond;
  final Value<DateTime> recordedAt;
  const RideTrackPointsCompanion({
    this.id = const Value.absent(),
    this.rideId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitudeMeters = const Value.absent(),
    this.horizontalAccuracyMeters = const Value.absent(),
    this.speedMetersPerSecond = const Value.absent(),
    this.recordedAt = const Value.absent(),
  });
  RideTrackPointsCompanion.insert({
    this.id = const Value.absent(),
    required int rideId,
    required int sequence,
    required double latitude,
    required double longitude,
    this.altitudeMeters = const Value.absent(),
    this.horizontalAccuracyMeters = const Value.absent(),
    this.speedMetersPerSecond = const Value.absent(),
    required DateTime recordedAt,
  }) : rideId = Value(rideId),
       sequence = Value(sequence),
       latitude = Value(latitude),
       longitude = Value(longitude),
       recordedAt = Value(recordedAt);
  static Insertable<RideTrackPoint> custom({
    Expression<int>? id,
    Expression<int>? rideId,
    Expression<int>? sequence,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<double>? altitudeMeters,
    Expression<double>? horizontalAccuracyMeters,
    Expression<double>? speedMetersPerSecond,
    Expression<DateTime>? recordedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rideId != null) 'ride_id': rideId,
      if (sequence != null) 'sequence': sequence,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitudeMeters != null) 'altitude_meters': altitudeMeters,
      if (horizontalAccuracyMeters != null)
        'horizontal_accuracy_meters': horizontalAccuracyMeters,
      if (speedMetersPerSecond != null)
        'speed_meters_per_second': speedMetersPerSecond,
      if (recordedAt != null) 'recorded_at': recordedAt,
    });
  }

  RideTrackPointsCompanion copyWith({
    Value<int>? id,
    Value<int>? rideId,
    Value<int>? sequence,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<double?>? altitudeMeters,
    Value<double?>? horizontalAccuracyMeters,
    Value<double?>? speedMetersPerSecond,
    Value<DateTime>? recordedAt,
  }) {
    return RideTrackPointsCompanion(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      sequence: sequence ?? this.sequence,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitudeMeters: altitudeMeters ?? this.altitudeMeters,
      horizontalAccuracyMeters:
          horizontalAccuracyMeters ?? this.horizontalAccuracyMeters,
      speedMetersPerSecond: speedMetersPerSecond ?? this.speedMetersPerSecond,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rideId.present) {
      map['ride_id'] = Variable<int>(rideId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitudeMeters.present) {
      map['altitude_meters'] = Variable<double>(altitudeMeters.value);
    }
    if (horizontalAccuracyMeters.present) {
      map['horizontal_accuracy_meters'] = Variable<double>(
        horizontalAccuracyMeters.value,
      );
    }
    if (speedMetersPerSecond.present) {
      map['speed_meters_per_second'] = Variable<double>(
        speedMetersPerSecond.value,
      );
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RideTrackPointsCompanion(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('sequence: $sequence, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitudeMeters: $altitudeMeters, ')
          ..write('horizontalAccuracyMeters: $horizontalAccuracyMeters, ')
          ..write('speedMetersPerSecond: $speedMetersPerSecond, ')
          ..write('recordedAt: $recordedAt')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceTemplatesTable extends MaintenanceTemplates
    with TableInfo<$MaintenanceTemplatesTable, MaintenanceTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bikeTypeMeta = const VerificationMeta(
    'bikeType',
  );
  @override
  late final GeneratedColumn<String> bikeType = GeneratedColumn<String>(
    'bike_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceNameMeta = const VerificationMeta(
    'serviceName',
  );
  @override
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
    'service_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intervalMetersMeta = const VerificationMeta(
    'intervalMeters',
  );
  @override
  late final GeneratedColumn<int> intervalMeters = GeneratedColumn<int>(
    'interval_meters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    bikeType,
    serviceName,
    intervalMeters,
    isEnabled,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('bike_type')) {
      context.handle(
        _bikeTypeMeta,
        bikeType.isAcceptableOrUnknown(data['bike_type']!, _bikeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_bikeTypeMeta);
    }
    if (data.containsKey('service_name')) {
      context.handle(
        _serviceNameMeta,
        serviceName.isAcceptableOrUnknown(
          data['service_name']!,
          _serviceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceNameMeta);
    }
    if (data.containsKey('interval_meters')) {
      context.handle(
        _intervalMetersMeta,
        intervalMeters.isAcceptableOrUnknown(
          data['interval_meters']!,
          _intervalMetersMeta,
        ),
      );
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {bikeType, serviceName},
  ];
  @override
  MaintenanceTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceTemplate(
      bikeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bike_type'],
      )!,
      serviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_name'],
      )!,
      intervalMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_meters'],
      ),
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MaintenanceTemplatesTable createAlias(String alias) {
    return $MaintenanceTemplatesTable(attachedDatabase, alias);
  }
}

class MaintenanceTemplate extends DataClass
    implements Insertable<MaintenanceTemplate> {
  final String bikeType;
  final String serviceName;
  final int? intervalMeters;
  final bool isEnabled;
  final DateTime updatedAt;
  const MaintenanceTemplate({
    required this.bikeType,
    required this.serviceName,
    this.intervalMeters,
    required this.isEnabled,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['bike_type'] = Variable<String>(bikeType);
    map['service_name'] = Variable<String>(serviceName);
    if (!nullToAbsent || intervalMeters != null) {
      map['interval_meters'] = Variable<int>(intervalMeters);
    }
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MaintenanceTemplatesCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceTemplatesCompanion(
      bikeType: Value(bikeType),
      serviceName: Value(serviceName),
      intervalMeters: intervalMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalMeters),
      isEnabled: Value(isEnabled),
      updatedAt: Value(updatedAt),
    );
  }

  factory MaintenanceTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceTemplate(
      bikeType: serializer.fromJson<String>(json['bikeType']),
      serviceName: serializer.fromJson<String>(json['serviceName']),
      intervalMeters: serializer.fromJson<int?>(json['intervalMeters']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bikeType': serializer.toJson<String>(bikeType),
      'serviceName': serializer.toJson<String>(serviceName),
      'intervalMeters': serializer.toJson<int?>(intervalMeters),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MaintenanceTemplate copyWith({
    String? bikeType,
    String? serviceName,
    Value<int?> intervalMeters = const Value.absent(),
    bool? isEnabled,
    DateTime? updatedAt,
  }) => MaintenanceTemplate(
    bikeType: bikeType ?? this.bikeType,
    serviceName: serviceName ?? this.serviceName,
    intervalMeters: intervalMeters.present
        ? intervalMeters.value
        : this.intervalMeters,
    isEnabled: isEnabled ?? this.isEnabled,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MaintenanceTemplate copyWithCompanion(MaintenanceTemplatesCompanion data) {
    return MaintenanceTemplate(
      bikeType: data.bikeType.present ? data.bikeType.value : this.bikeType,
      serviceName: data.serviceName.present
          ? data.serviceName.value
          : this.serviceName,
      intervalMeters: data.intervalMeters.present
          ? data.intervalMeters.value
          : this.intervalMeters,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceTemplate(')
          ..write('bikeType: $bikeType, ')
          ..write('serviceName: $serviceName, ')
          ..write('intervalMeters: $intervalMeters, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(bikeType, serviceName, intervalMeters, isEnabled, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceTemplate &&
          other.bikeType == this.bikeType &&
          other.serviceName == this.serviceName &&
          other.intervalMeters == this.intervalMeters &&
          other.isEnabled == this.isEnabled &&
          other.updatedAt == this.updatedAt);
}

class MaintenanceTemplatesCompanion
    extends UpdateCompanion<MaintenanceTemplate> {
  final Value<String> bikeType;
  final Value<String> serviceName;
  final Value<int?> intervalMeters;
  final Value<bool> isEnabled;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MaintenanceTemplatesCompanion({
    this.bikeType = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.intervalMeters = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaintenanceTemplatesCompanion.insert({
    required String bikeType,
    required String serviceName,
    this.intervalMeters = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : bikeType = Value(bikeType),
       serviceName = Value(serviceName);
  static Insertable<MaintenanceTemplate> custom({
    Expression<String>? bikeType,
    Expression<String>? serviceName,
    Expression<int>? intervalMeters,
    Expression<bool>? isEnabled,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bikeType != null) 'bike_type': bikeType,
      if (serviceName != null) 'service_name': serviceName,
      if (intervalMeters != null) 'interval_meters': intervalMeters,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaintenanceTemplatesCompanion copyWith({
    Value<String>? bikeType,
    Value<String>? serviceName,
    Value<int?>? intervalMeters,
    Value<bool>? isEnabled,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MaintenanceTemplatesCompanion(
      bikeType: bikeType ?? this.bikeType,
      serviceName: serviceName ?? this.serviceName,
      intervalMeters: intervalMeters ?? this.intervalMeters,
      isEnabled: isEnabled ?? this.isEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bikeType.present) {
      map['bike_type'] = Variable<String>(bikeType.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    if (intervalMeters.present) {
      map['interval_meters'] = Variable<int>(intervalMeters.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceTemplatesCompanion(')
          ..write('bikeType: $bikeType, ')
          ..write('serviceName: $serviceName, ')
          ..write('intervalMeters: $intervalMeters, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaintenanceEventsTable extends MaintenanceEvents
    with TableInfo<$MaintenanceEventsTable, MaintenanceEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaintenanceEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _bikeIdMeta = const VerificationMeta('bikeId');
  @override
  late final GeneratedColumn<int> bikeId = GeneratedColumn<int>(
    'bike_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES bikes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _serviceNameMeta = const VerificationMeta(
    'serviceName',
  );
  @override
  late final GeneratedColumn<String> serviceName = GeneratedColumn<String>(
    'service_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servicedAtMeta = const VerificationMeta(
    'servicedAt',
  );
  @override
  late final GeneratedColumn<DateTime> servicedAt = GeneratedColumn<DateTime>(
    'serviced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _odometerMetersMeta = const VerificationMeta(
    'odometerMeters',
  );
  @override
  late final GeneratedColumn<int> odometerMeters = GeneratedColumn<int>(
    'odometer_meters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serviceIntervalMetersMeta =
      const VerificationMeta('serviceIntervalMeters');
  @override
  late final GeneratedColumn<int> serviceIntervalMeters = GeneratedColumn<int>(
    'service_interval_meters',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    bikeId,
    serviceName,
    servicedAt,
    odometerMeters,
    serviceIntervalMeters,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'maintenance_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<MaintenanceEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bike_id')) {
      context.handle(
        _bikeIdMeta,
        bikeId.isAcceptableOrUnknown(data['bike_id']!, _bikeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bikeIdMeta);
    }
    if (data.containsKey('service_name')) {
      context.handle(
        _serviceNameMeta,
        serviceName.isAcceptableOrUnknown(
          data['service_name']!,
          _serviceNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_serviceNameMeta);
    }
    if (data.containsKey('serviced_at')) {
      context.handle(
        _servicedAtMeta,
        servicedAt.isAcceptableOrUnknown(data['serviced_at']!, _servicedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_servicedAtMeta);
    }
    if (data.containsKey('odometer_meters')) {
      context.handle(
        _odometerMetersMeta,
        odometerMeters.isAcceptableOrUnknown(
          data['odometer_meters']!,
          _odometerMetersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_odometerMetersMeta);
    }
    if (data.containsKey('service_interval_meters')) {
      context.handle(
        _serviceIntervalMetersMeta,
        serviceIntervalMeters.isAcceptableOrUnknown(
          data['service_interval_meters']!,
          _serviceIntervalMetersMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MaintenanceEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MaintenanceEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      bikeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bike_id'],
      )!,
      serviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_name'],
      )!,
      servicedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}serviced_at'],
      )!,
      odometerMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}odometer_meters'],
      )!,
      serviceIntervalMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}service_interval_meters'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $MaintenanceEventsTable createAlias(String alias) {
    return $MaintenanceEventsTable(attachedDatabase, alias);
  }
}

class MaintenanceEvent extends DataClass
    implements Insertable<MaintenanceEvent> {
  final int id;
  final int bikeId;
  final String serviceName;
  final DateTime servicedAt;
  final int odometerMeters;
  final int? serviceIntervalMeters;
  final String? notes;
  const MaintenanceEvent({
    required this.id,
    required this.bikeId,
    required this.serviceName,
    required this.servicedAt,
    required this.odometerMeters,
    this.serviceIntervalMeters,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bike_id'] = Variable<int>(bikeId);
    map['service_name'] = Variable<String>(serviceName);
    map['serviced_at'] = Variable<DateTime>(servicedAt);
    map['odometer_meters'] = Variable<int>(odometerMeters);
    if (!nullToAbsent || serviceIntervalMeters != null) {
      map['service_interval_meters'] = Variable<int>(serviceIntervalMeters);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  MaintenanceEventsCompanion toCompanion(bool nullToAbsent) {
    return MaintenanceEventsCompanion(
      id: Value(id),
      bikeId: Value(bikeId),
      serviceName: Value(serviceName),
      servicedAt: Value(servicedAt),
      odometerMeters: Value(odometerMeters),
      serviceIntervalMeters: serviceIntervalMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceIntervalMeters),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory MaintenanceEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MaintenanceEvent(
      id: serializer.fromJson<int>(json['id']),
      bikeId: serializer.fromJson<int>(json['bikeId']),
      serviceName: serializer.fromJson<String>(json['serviceName']),
      servicedAt: serializer.fromJson<DateTime>(json['servicedAt']),
      odometerMeters: serializer.fromJson<int>(json['odometerMeters']),
      serviceIntervalMeters: serializer.fromJson<int?>(
        json['serviceIntervalMeters'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bikeId': serializer.toJson<int>(bikeId),
      'serviceName': serializer.toJson<String>(serviceName),
      'servicedAt': serializer.toJson<DateTime>(servicedAt),
      'odometerMeters': serializer.toJson<int>(odometerMeters),
      'serviceIntervalMeters': serializer.toJson<int?>(serviceIntervalMeters),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  MaintenanceEvent copyWith({
    int? id,
    int? bikeId,
    String? serviceName,
    DateTime? servicedAt,
    int? odometerMeters,
    Value<int?> serviceIntervalMeters = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => MaintenanceEvent(
    id: id ?? this.id,
    bikeId: bikeId ?? this.bikeId,
    serviceName: serviceName ?? this.serviceName,
    servicedAt: servicedAt ?? this.servicedAt,
    odometerMeters: odometerMeters ?? this.odometerMeters,
    serviceIntervalMeters: serviceIntervalMeters.present
        ? serviceIntervalMeters.value
        : this.serviceIntervalMeters,
    notes: notes.present ? notes.value : this.notes,
  );
  MaintenanceEvent copyWithCompanion(MaintenanceEventsCompanion data) {
    return MaintenanceEvent(
      id: data.id.present ? data.id.value : this.id,
      bikeId: data.bikeId.present ? data.bikeId.value : this.bikeId,
      serviceName: data.serviceName.present
          ? data.serviceName.value
          : this.serviceName,
      servicedAt: data.servicedAt.present
          ? data.servicedAt.value
          : this.servicedAt,
      odometerMeters: data.odometerMeters.present
          ? data.odometerMeters.value
          : this.odometerMeters,
      serviceIntervalMeters: data.serviceIntervalMeters.present
          ? data.serviceIntervalMeters.value
          : this.serviceIntervalMeters,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceEvent(')
          ..write('id: $id, ')
          ..write('bikeId: $bikeId, ')
          ..write('serviceName: $serviceName, ')
          ..write('servicedAt: $servicedAt, ')
          ..write('odometerMeters: $odometerMeters, ')
          ..write('serviceIntervalMeters: $serviceIntervalMeters, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    bikeId,
    serviceName,
    servicedAt,
    odometerMeters,
    serviceIntervalMeters,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MaintenanceEvent &&
          other.id == this.id &&
          other.bikeId == this.bikeId &&
          other.serviceName == this.serviceName &&
          other.servicedAt == this.servicedAt &&
          other.odometerMeters == this.odometerMeters &&
          other.serviceIntervalMeters == this.serviceIntervalMeters &&
          other.notes == this.notes);
}

class MaintenanceEventsCompanion extends UpdateCompanion<MaintenanceEvent> {
  final Value<int> id;
  final Value<int> bikeId;
  final Value<String> serviceName;
  final Value<DateTime> servicedAt;
  final Value<int> odometerMeters;
  final Value<int?> serviceIntervalMeters;
  final Value<String?> notes;
  const MaintenanceEventsCompanion({
    this.id = const Value.absent(),
    this.bikeId = const Value.absent(),
    this.serviceName = const Value.absent(),
    this.servicedAt = const Value.absent(),
    this.odometerMeters = const Value.absent(),
    this.serviceIntervalMeters = const Value.absent(),
    this.notes = const Value.absent(),
  });
  MaintenanceEventsCompanion.insert({
    this.id = const Value.absent(),
    required int bikeId,
    required String serviceName,
    required DateTime servicedAt,
    required int odometerMeters,
    this.serviceIntervalMeters = const Value.absent(),
    this.notes = const Value.absent(),
  }) : bikeId = Value(bikeId),
       serviceName = Value(serviceName),
       servicedAt = Value(servicedAt),
       odometerMeters = Value(odometerMeters);
  static Insertable<MaintenanceEvent> custom({
    Expression<int>? id,
    Expression<int>? bikeId,
    Expression<String>? serviceName,
    Expression<DateTime>? servicedAt,
    Expression<int>? odometerMeters,
    Expression<int>? serviceIntervalMeters,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bikeId != null) 'bike_id': bikeId,
      if (serviceName != null) 'service_name': serviceName,
      if (servicedAt != null) 'serviced_at': servicedAt,
      if (odometerMeters != null) 'odometer_meters': odometerMeters,
      if (serviceIntervalMeters != null)
        'service_interval_meters': serviceIntervalMeters,
      if (notes != null) 'notes': notes,
    });
  }

  MaintenanceEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? bikeId,
    Value<String>? serviceName,
    Value<DateTime>? servicedAt,
    Value<int>? odometerMeters,
    Value<int?>? serviceIntervalMeters,
    Value<String?>? notes,
  }) {
    return MaintenanceEventsCompanion(
      id: id ?? this.id,
      bikeId: bikeId ?? this.bikeId,
      serviceName: serviceName ?? this.serviceName,
      servicedAt: servicedAt ?? this.servicedAt,
      odometerMeters: odometerMeters ?? this.odometerMeters,
      serviceIntervalMeters:
          serviceIntervalMeters ?? this.serviceIntervalMeters,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bikeId.present) {
      map['bike_id'] = Variable<int>(bikeId.value);
    }
    if (serviceName.present) {
      map['service_name'] = Variable<String>(serviceName.value);
    }
    if (servicedAt.present) {
      map['serviced_at'] = Variable<DateTime>(servicedAt.value);
    }
    if (odometerMeters.present) {
      map['odometer_meters'] = Variable<int>(odometerMeters.value);
    }
    if (serviceIntervalMeters.present) {
      map['service_interval_meters'] = Variable<int>(
        serviceIntervalMeters.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaintenanceEventsCompanion(')
          ..write('id: $id, ')
          ..write('bikeId: $bikeId, ')
          ..write('serviceName: $serviceName, ')
          ..write('servicedAt: $servicedAt, ')
          ..write('odometerMeters: $odometerMeters, ')
          ..write('serviceIntervalMeters: $serviceIntervalMeters, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $RouteMatchSuggestionsTable extends RouteMatchSuggestions
    with TableInfo<$RouteMatchSuggestionsTable, RouteMatchSuggestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RouteMatchSuggestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _rideIdMeta = const VerificationMeta('rideId');
  @override
  late final GeneratedColumn<int> rideId = GeneratedColumn<int>(
    'ride_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES rides (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _routeIdMeta = const VerificationMeta(
    'routeId',
  );
  @override
  late final GeneratedColumn<int> routeId = GeneratedColumn<int>(
    'route_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES routes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _similarityScoreMeta = const VerificationMeta(
    'similarityScore',
  );
  @override
  late final GeneratedColumn<double> similarityScore = GeneratedColumn<double>(
    'similarity_score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _distanceDifferenceMetersMeta =
      const VerificationMeta('distanceDifferenceMeters');
  @override
  late final GeneratedColumn<int> distanceDifferenceMeters =
      GeneratedColumn<int>(
        'distance_difference_meters',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(RouteSuggestionStatus.pending),
  );
  static const VerificationMeta _suggestedAtMeta = const VerificationMeta(
    'suggestedAt',
  );
  @override
  late final GeneratedColumn<DateTime> suggestedAt = GeneratedColumn<DateTime>(
    'suggested_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    rideId,
    routeId,
    similarityScore,
    distanceDifferenceMeters,
    status,
    suggestedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'route_match_suggestions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RouteMatchSuggestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ride_id')) {
      context.handle(
        _rideIdMeta,
        rideId.isAcceptableOrUnknown(data['ride_id']!, _rideIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rideIdMeta);
    }
    if (data.containsKey('route_id')) {
      context.handle(
        _routeIdMeta,
        routeId.isAcceptableOrUnknown(data['route_id']!, _routeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_routeIdMeta);
    }
    if (data.containsKey('similarity_score')) {
      context.handle(
        _similarityScoreMeta,
        similarityScore.isAcceptableOrUnknown(
          data['similarity_score']!,
          _similarityScoreMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_similarityScoreMeta);
    }
    if (data.containsKey('distance_difference_meters')) {
      context.handle(
        _distanceDifferenceMetersMeta,
        distanceDifferenceMeters.isAcceptableOrUnknown(
          data['distance_difference_meters']!,
          _distanceDifferenceMetersMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('suggested_at')) {
      context.handle(
        _suggestedAtMeta,
        suggestedAt.isAcceptableOrUnknown(
          data['suggested_at']!,
          _suggestedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {rideId, routeId},
  ];
  @override
  RouteMatchSuggestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RouteMatchSuggestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      rideId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ride_id'],
      )!,
      routeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}route_id'],
      )!,
      similarityScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}similarity_score'],
      )!,
      distanceDifferenceMeters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distance_difference_meters'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      suggestedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}suggested_at'],
      )!,
    );
  }

  @override
  $RouteMatchSuggestionsTable createAlias(String alias) {
    return $RouteMatchSuggestionsTable(attachedDatabase, alias);
  }
}

class RouteMatchSuggestion extends DataClass
    implements Insertable<RouteMatchSuggestion> {
  final int id;
  final int rideId;
  final int routeId;
  final double similarityScore;
  final int? distanceDifferenceMeters;
  final String status;
  final DateTime suggestedAt;
  const RouteMatchSuggestion({
    required this.id,
    required this.rideId,
    required this.routeId,
    required this.similarityScore,
    this.distanceDifferenceMeters,
    required this.status,
    required this.suggestedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ride_id'] = Variable<int>(rideId);
    map['route_id'] = Variable<int>(routeId);
    map['similarity_score'] = Variable<double>(similarityScore);
    if (!nullToAbsent || distanceDifferenceMeters != null) {
      map['distance_difference_meters'] = Variable<int>(
        distanceDifferenceMeters,
      );
    }
    map['status'] = Variable<String>(status);
    map['suggested_at'] = Variable<DateTime>(suggestedAt);
    return map;
  }

  RouteMatchSuggestionsCompanion toCompanion(bool nullToAbsent) {
    return RouteMatchSuggestionsCompanion(
      id: Value(id),
      rideId: Value(rideId),
      routeId: Value(routeId),
      similarityScore: Value(similarityScore),
      distanceDifferenceMeters: distanceDifferenceMeters == null && nullToAbsent
          ? const Value.absent()
          : Value(distanceDifferenceMeters),
      status: Value(status),
      suggestedAt: Value(suggestedAt),
    );
  }

  factory RouteMatchSuggestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RouteMatchSuggestion(
      id: serializer.fromJson<int>(json['id']),
      rideId: serializer.fromJson<int>(json['rideId']),
      routeId: serializer.fromJson<int>(json['routeId']),
      similarityScore: serializer.fromJson<double>(json['similarityScore']),
      distanceDifferenceMeters: serializer.fromJson<int?>(
        json['distanceDifferenceMeters'],
      ),
      status: serializer.fromJson<String>(json['status']),
      suggestedAt: serializer.fromJson<DateTime>(json['suggestedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'rideId': serializer.toJson<int>(rideId),
      'routeId': serializer.toJson<int>(routeId),
      'similarityScore': serializer.toJson<double>(similarityScore),
      'distanceDifferenceMeters': serializer.toJson<int?>(
        distanceDifferenceMeters,
      ),
      'status': serializer.toJson<String>(status),
      'suggestedAt': serializer.toJson<DateTime>(suggestedAt),
    };
  }

  RouteMatchSuggestion copyWith({
    int? id,
    int? rideId,
    int? routeId,
    double? similarityScore,
    Value<int?> distanceDifferenceMeters = const Value.absent(),
    String? status,
    DateTime? suggestedAt,
  }) => RouteMatchSuggestion(
    id: id ?? this.id,
    rideId: rideId ?? this.rideId,
    routeId: routeId ?? this.routeId,
    similarityScore: similarityScore ?? this.similarityScore,
    distanceDifferenceMeters: distanceDifferenceMeters.present
        ? distanceDifferenceMeters.value
        : this.distanceDifferenceMeters,
    status: status ?? this.status,
    suggestedAt: suggestedAt ?? this.suggestedAt,
  );
  RouteMatchSuggestion copyWithCompanion(RouteMatchSuggestionsCompanion data) {
    return RouteMatchSuggestion(
      id: data.id.present ? data.id.value : this.id,
      rideId: data.rideId.present ? data.rideId.value : this.rideId,
      routeId: data.routeId.present ? data.routeId.value : this.routeId,
      similarityScore: data.similarityScore.present
          ? data.similarityScore.value
          : this.similarityScore,
      distanceDifferenceMeters: data.distanceDifferenceMeters.present
          ? data.distanceDifferenceMeters.value
          : this.distanceDifferenceMeters,
      status: data.status.present ? data.status.value : this.status,
      suggestedAt: data.suggestedAt.present
          ? data.suggestedAt.value
          : this.suggestedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RouteMatchSuggestion(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('routeId: $routeId, ')
          ..write('similarityScore: $similarityScore, ')
          ..write('distanceDifferenceMeters: $distanceDifferenceMeters, ')
          ..write('status: $status, ')
          ..write('suggestedAt: $suggestedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    rideId,
    routeId,
    similarityScore,
    distanceDifferenceMeters,
    status,
    suggestedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RouteMatchSuggestion &&
          other.id == this.id &&
          other.rideId == this.rideId &&
          other.routeId == this.routeId &&
          other.similarityScore == this.similarityScore &&
          other.distanceDifferenceMeters == this.distanceDifferenceMeters &&
          other.status == this.status &&
          other.suggestedAt == this.suggestedAt);
}

class RouteMatchSuggestionsCompanion
    extends UpdateCompanion<RouteMatchSuggestion> {
  final Value<int> id;
  final Value<int> rideId;
  final Value<int> routeId;
  final Value<double> similarityScore;
  final Value<int?> distanceDifferenceMeters;
  final Value<String> status;
  final Value<DateTime> suggestedAt;
  const RouteMatchSuggestionsCompanion({
    this.id = const Value.absent(),
    this.rideId = const Value.absent(),
    this.routeId = const Value.absent(),
    this.similarityScore = const Value.absent(),
    this.distanceDifferenceMeters = const Value.absent(),
    this.status = const Value.absent(),
    this.suggestedAt = const Value.absent(),
  });
  RouteMatchSuggestionsCompanion.insert({
    this.id = const Value.absent(),
    required int rideId,
    required int routeId,
    required double similarityScore,
    this.distanceDifferenceMeters = const Value.absent(),
    this.status = const Value.absent(),
    this.suggestedAt = const Value.absent(),
  }) : rideId = Value(rideId),
       routeId = Value(routeId),
       similarityScore = Value(similarityScore);
  static Insertable<RouteMatchSuggestion> custom({
    Expression<int>? id,
    Expression<int>? rideId,
    Expression<int>? routeId,
    Expression<double>? similarityScore,
    Expression<int>? distanceDifferenceMeters,
    Expression<String>? status,
    Expression<DateTime>? suggestedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rideId != null) 'ride_id': rideId,
      if (routeId != null) 'route_id': routeId,
      if (similarityScore != null) 'similarity_score': similarityScore,
      if (distanceDifferenceMeters != null)
        'distance_difference_meters': distanceDifferenceMeters,
      if (status != null) 'status': status,
      if (suggestedAt != null) 'suggested_at': suggestedAt,
    });
  }

  RouteMatchSuggestionsCompanion copyWith({
    Value<int>? id,
    Value<int>? rideId,
    Value<int>? routeId,
    Value<double>? similarityScore,
    Value<int?>? distanceDifferenceMeters,
    Value<String>? status,
    Value<DateTime>? suggestedAt,
  }) {
    return RouteMatchSuggestionsCompanion(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      routeId: routeId ?? this.routeId,
      similarityScore: similarityScore ?? this.similarityScore,
      distanceDifferenceMeters:
          distanceDifferenceMeters ?? this.distanceDifferenceMeters,
      status: status ?? this.status,
      suggestedAt: suggestedAt ?? this.suggestedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (rideId.present) {
      map['ride_id'] = Variable<int>(rideId.value);
    }
    if (routeId.present) {
      map['route_id'] = Variable<int>(routeId.value);
    }
    if (similarityScore.present) {
      map['similarity_score'] = Variable<double>(similarityScore.value);
    }
    if (distanceDifferenceMeters.present) {
      map['distance_difference_meters'] = Variable<int>(
        distanceDifferenceMeters.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (suggestedAt.present) {
      map['suggested_at'] = Variable<DateTime>(suggestedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RouteMatchSuggestionsCompanion(')
          ..write('id: $id, ')
          ..write('rideId: $rideId, ')
          ..write('routeId: $routeId, ')
          ..write('similarityScore: $similarityScore, ')
          ..write('distanceDifferenceMeters: $distanceDifferenceMeters, ')
          ..write('status: $status, ')
          ..write('suggestedAt: $suggestedAt')
          ..write(')'))
        .toString();
  }
}

class $RiderProfilesTable extends RiderProfiles
    with TableInfo<$RiderProfilesTable, RiderProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RiderProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    clientDefault: DateTime.now,
  );
  @override
  List<GeneratedColumn> get $columns => [id, displayName, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rider_profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<RiderProfile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RiderProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RiderProfile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $RiderProfilesTable createAlias(String alias) {
    return $RiderProfilesTable(attachedDatabase, alias);
  }
}

class RiderProfile extends DataClass implements Insertable<RiderProfile> {
  final int id;
  final String displayName;
  final DateTime updatedAt;
  const RiderProfile({
    required this.id,
    required this.displayName,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  RiderProfilesCompanion toCompanion(bool nullToAbsent) {
    return RiderProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      updatedAt: Value(updatedAt),
    );
  }

  factory RiderProfile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RiderProfile(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  RiderProfile copyWith({int? id, String? displayName, DateTime? updatedAt}) =>
      RiderProfile(
        id: id ?? this.id,
        displayName: displayName ?? this.displayName,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  RiderProfile copyWithCompanion(RiderProfilesCompanion data) {
    return RiderProfile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RiderProfile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RiderProfile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.updatedAt == this.updatedAt);
}

class RiderProfilesCompanion extends UpdateCompanion<RiderProfile> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<DateTime> updatedAt;
  const RiderProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  RiderProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    this.updatedAt = const Value.absent(),
  }) : displayName = Value(displayName);
  static Insertable<RiderProfile> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  RiderProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<DateTime>? updatedAt,
  }) {
    return RiderProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RiderProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $RoutesTable routes = $RoutesTable(this);
  late final $BikesTable bikes = $BikesTable(this);
  late final $RidesTable rides = $RidesTable(this);
  late final $RideTrackPointsTable rideTrackPoints = $RideTrackPointsTable(
    this,
  );
  late final $MaintenanceTemplatesTable maintenanceTemplates =
      $MaintenanceTemplatesTable(this);
  late final $MaintenanceEventsTable maintenanceEvents =
      $MaintenanceEventsTable(this);
  late final $RouteMatchSuggestionsTable routeMatchSuggestions =
      $RouteMatchSuggestionsTable(this);
  late final $RiderProfilesTable riderProfiles = $RiderProfilesTable(this);
  late final Index ridesStartedAtIdx = Index(
    'rides_started_at_idx',
    'CREATE INDEX rides_started_at_idx ON rides (started_at)',
  );
  late final Index ridesBikeStatusStartedAtIdx = Index(
    'rides_bike_status_started_at_idx',
    'CREATE INDEX rides_bike_status_started_at_idx ON rides (bike_id, status, started_at)',
  );
  late final Index rideTrackPointsRideRecordedAtIdx = Index(
    'ride_track_points_ride_recorded_at_idx',
    'CREATE INDEX ride_track_points_ride_recorded_at_idx ON ride_track_points (ride_id, recorded_at)',
  );
  late final Index bikesArchivedIdx = Index(
    'bikes_archived_idx',
    'CREATE INDEX bikes_archived_idx ON bikes (is_archived)',
  );
  late final Index maintenanceTemplatesTypeEnabledIdx = Index(
    'maintenance_templates_type_enabled_idx',
    'CREATE INDEX maintenance_templates_type_enabled_idx ON maintenance_templates (bike_type, is_enabled)',
  );
  late final Index maintenanceBikeServiceDateIdx = Index(
    'maintenance_bike_service_date_idx',
    'CREATE INDEX maintenance_bike_service_date_idx ON maintenance_events (bike_id, service_name, serviced_at)',
  );
  late final Index routeSuggestionsRideStatusIdx = Index(
    'route_suggestions_ride_status_idx',
    'CREATE INDEX route_suggestions_ride_status_idx ON route_match_suggestions (ride_id, status)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    routes,
    bikes,
    rides,
    rideTrackPoints,
    maintenanceTemplates,
    maintenanceEvents,
    routeMatchSuggestions,
    riderProfiles,
    ridesStartedAtIdx,
    ridesBikeStatusStartedAtIdx,
    rideTrackPointsRideRecordedAtIdx,
    bikesArchivedIdx,
    maintenanceTemplatesTypeEnabledIdx,
    maintenanceBikeServiceDateIdx,
    routeSuggestionsRideStatusIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rides', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bikes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rides', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rides',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('ride_track_points', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bikes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('maintenance_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'rides',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('route_match_suggestions', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'routes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('route_match_suggestions', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$RoutesTableCreateCompanionBuilder = RoutesCompanion Function({
  Value<int> id,
  required String name,
  Value<int?> distanceMeters,
  Value<DateTime> createdAt,
});
typedef $$RoutesTableUpdateCompanionBuilder = RoutesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int?> distanceMeters,
  Value<DateTime> createdAt,
});

final class $$RoutesTableReferences
    extends BaseReferences<_$AppDatabase, $RoutesTable, SavedRoute> {
  $$RoutesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RidesTable, List<Ride>> _ridesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rides,
    aliasName: 'routes__id__rides__route_id',
  );

  $$RidesTableProcessedTableManager get ridesRefs {
    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.routeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ridesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RouteMatchSuggestionsTable,
    List<RouteMatchSuggestion>
  >
  _routeMatchSuggestionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routeMatchSuggestions,
        aliasName: 'routes__id__route_match_suggestions__route_id',
      );

  $$RouteMatchSuggestionsTableProcessedTableManager
  get routeMatchSuggestionsRefs {
    final manager = $$RouteMatchSuggestionsTableTableManager(
      $_db,
      $_db.routeMatchSuggestions,
    ).filter((f) => f.routeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routeMatchSuggestionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RoutesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ridesRefs(
    Expression<bool> Function($$RidesTableFilterComposer f) f,
  ) {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routeMatchSuggestionsRefs(
    Expression<bool> Function($$RouteMatchSuggestionsTableFilterComposer f) f,
  ) {
    final $$RouteMatchSuggestionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routeMatchSuggestions,
          getReferencedColumn: (t) => t.routeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RouteMatchSuggestionsTableFilterComposer(
                $db: $db,
                $table: $db.routeMatchSuggestions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutesTable> {
  $$RoutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> ridesRefs<T extends Object>(
    Expression<T> Function($$RidesTableAnnotationComposer a) f,
  ) {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.routeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routeMatchSuggestionsRefs<T extends Object>(
    Expression<T> Function($$RouteMatchSuggestionsTableAnnotationComposer a) f,
  ) {
    final $$RouteMatchSuggestionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routeMatchSuggestions,
          getReferencedColumn: (t) => t.routeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RouteMatchSuggestionsTableAnnotationComposer(
                $db: $db,
                $table: $db.routeMatchSuggestions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RoutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutesTable,
          SavedRoute,
          $$RoutesTableFilterComposer,
          $$RoutesTableOrderingComposer,
          $$RoutesTableAnnotationComposer,
          $$RoutesTableCreateCompanionBuilder,
          $$RoutesTableUpdateCompanionBuilder,
          (SavedRoute, $$RoutesTableReferences),
          SavedRoute,
          PrefetchHooks Function({
            bool ridesRefs,
            bool routeMatchSuggestionsRefs,
          })
        > {
  $$RoutesTableTableManager(_$AppDatabase db, $RoutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> distanceMeters = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RoutesCompanion(
                id: id,
                name: name,
                distanceMeters: distanceMeters,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<int?> distanceMeters = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RoutesCompanion.insert(
                id: id,
                name: name,
                distanceMeters: distanceMeters,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutesTable, SavedRoute>(table),
                  $$RoutesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ridesRefs = false, routeMatchSuggestionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ridesRefs) db.rides,
                    if (routeMatchSuggestionsRefs) db.routeMatchSuggestions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ridesRefs)
                        await $_getPrefetchedData<
                          SavedRoute,
                          $RoutesTable,
                          Ride
                        >(
                          currentTable: table,
                          referencedTable: $$RoutesTableReferences
                              ._ridesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutesTableReferences(db, table, p0).ridesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routeMatchSuggestionsRefs)
                        await $_getPrefetchedData<
                          SavedRoute,
                          $RoutesTable,
                          RouteMatchSuggestion
                        >(
                          currentTable: table,
                          referencedTable: $$RoutesTableReferences
                              ._routeMatchSuggestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RoutesTableReferences(
                                db,
                                table,
                                p0,
                              ).routeMatchSuggestionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.routeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RoutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutesTable,
      SavedRoute,
      $$RoutesTableFilterComposer,
      $$RoutesTableOrderingComposer,
      $$RoutesTableAnnotationComposer,
      $$RoutesTableCreateCompanionBuilder,
      $$RoutesTableUpdateCompanionBuilder,
      (SavedRoute, $$RoutesTableReferences),
      SavedRoute,
      PrefetchHooks Function({bool ridesRefs, bool routeMatchSuggestionsRefs})
    >;
typedef $$BikesTableCreateCompanionBuilder = BikesCompanion Function({
  Value<int> id,
  Value<String> type,
  required String brand,
  required String model,
  Value<String?> nickname,
  Value<String?> photoPath,
  Value<int> odometerBaselineMeters,
  Value<DateTime> odometerBaselineAt,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
});
typedef $$BikesTableUpdateCompanionBuilder = BikesCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<String> brand,
  Value<String> model,
  Value<String?> nickname,
  Value<String?> photoPath,
  Value<int> odometerBaselineMeters,
  Value<DateTime> odometerBaselineAt,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
});

final class $$BikesTableReferences
    extends BaseReferences<_$AppDatabase, $BikesTable, Bike> {
  $$BikesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RidesTable, List<Ride>> _ridesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.rides,
    aliasName: 'bikes__id__rides__bike_id',
  );

  $$RidesTableProcessedTableManager get ridesRefs {
    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.bikeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_ridesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MaintenanceEventsTable, List<MaintenanceEvent>>
  _maintenanceEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.maintenanceEvents,
        aliasName: 'bikes__id__maintenance_events__bike_id',
      );

  $$MaintenanceEventsTableProcessedTableManager get maintenanceEventsRefs {
    final manager = $$MaintenanceEventsTableTableManager(
      $_db,
      $_db.maintenanceEvents,
    ).filter((f) => f.bikeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _maintenanceEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BikesTableFilterComposer extends Composer<_$AppDatabase, $BikesTable> {
  $$BikesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometerBaselineMeters => $composableBuilder(
    column: $table.odometerBaselineMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get odometerBaselineAt => $composableBuilder(
    column: $table.odometerBaselineAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> ridesRefs(
    Expression<bool> Function($$RidesTableFilterComposer f) f,
  ) {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.bikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> maintenanceEventsRefs(
    Expression<bool> Function($$MaintenanceEventsTableFilterComposer f) f,
  ) {
    final $$MaintenanceEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.maintenanceEvents,
      getReferencedColumn: (t) => t.bikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MaintenanceEventsTableFilterComposer(
            $db: $db,
            $table: $db.maintenanceEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BikesTableOrderingComposer
    extends Composer<_$AppDatabase, $BikesTable> {
  $$BikesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nickname => $composableBuilder(
    column: $table.nickname,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometerBaselineMeters => $composableBuilder(
    column: $table.odometerBaselineMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get odometerBaselineAt => $composableBuilder(
    column: $table.odometerBaselineAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BikesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BikesTable> {
  $$BikesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get nickname =>
      $composableBuilder(column: $table.nickname, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<int> get odometerBaselineMeters => $composableBuilder(
    column: $table.odometerBaselineMeters,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get odometerBaselineAt => $composableBuilder(
    column: $table.odometerBaselineAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> ridesRefs<T extends Object>(
    Expression<T> Function($$RidesTableAnnotationComposer a) f,
  ) {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.bikeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> maintenanceEventsRefs<T extends Object>(
    Expression<T> Function($$MaintenanceEventsTableAnnotationComposer a) f,
  ) {
    final $$MaintenanceEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.maintenanceEvents,
          getReferencedColumn: (t) => t.bikeId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MaintenanceEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.maintenanceEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BikesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BikesTable,
          Bike,
          $$BikesTableFilterComposer,
          $$BikesTableOrderingComposer,
          $$BikesTableAnnotationComposer,
          $$BikesTableCreateCompanionBuilder,
          $$BikesTableUpdateCompanionBuilder,
          (Bike, $$BikesTableReferences),
          Bike,
          PrefetchHooks Function({bool ridesRefs, bool maintenanceEventsRefs})
        > {
  $$BikesTableTableManager(_$AppDatabase db, $BikesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BikesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BikesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BikesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<String?> nickname = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> odometerBaselineMeters = const Value.absent(),
                Value<DateTime> odometerBaselineAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BikesCompanion(
                id: id,
                type: type,
                brand: brand,
                model: model,
                nickname: nickname,
                photoPath: photoPath,
                odometerBaselineMeters: odometerBaselineMeters,
                odometerBaselineAt: odometerBaselineAt,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                required String brand,
                required String model,
                Value<String?> nickname = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<int> odometerBaselineMeters = const Value.absent(),
                Value<DateTime> odometerBaselineAt = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BikesCompanion.insert(
                id: id,
                type: type,
                brand: brand,
                model: model,
                nickname: nickname,
                photoPath: photoPath,
                odometerBaselineMeters: odometerBaselineMeters,
                odometerBaselineAt: odometerBaselineAt,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BikesTable, Bike>(table),
                  $$BikesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({ridesRefs = false, maintenanceEventsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (ridesRefs) db.rides,
                    if (maintenanceEventsRefs) db.maintenanceEvents,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (ridesRefs)
                        await $_getPrefetchedData<Bike, $BikesTable, Ride>(
                          currentTable: table,
                          referencedTable: $$BikesTableReferences
                              ._ridesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BikesTableReferences(db, table, p0).ridesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bikeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (maintenanceEventsRefs)
                        await $_getPrefetchedData<
                          Bike,
                          $BikesTable,
                          MaintenanceEvent
                        >(
                          currentTable: table,
                          referencedTable: $$BikesTableReferences
                              ._maintenanceEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BikesTableReferences(
                                db,
                                table,
                                p0,
                              ).maintenanceEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.bikeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BikesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BikesTable,
      Bike,
      $$BikesTableFilterComposer,
      $$BikesTableOrderingComposer,
      $$BikesTableAnnotationComposer,
      $$BikesTableCreateCompanionBuilder,
      $$BikesTableUpdateCompanionBuilder,
      (Bike, $$BikesTableReferences),
      Bike,
      PrefetchHooks Function({bool ridesRefs, bool maintenanceEventsRefs})
    >;
typedef $$RidesTableCreateCompanionBuilder = RidesCompanion Function({
  Value<int> id,
  Value<String?> title,
  required DateTime startedAt,
  Value<DateTime?> finishedAt,
  Value<int> durationSeconds,
  Value<int> pausedDurationSeconds,
  Value<DateTime?> pausedAt,
  Value<int> distanceMeters,
  Value<double?> elevationGainMeters,
  Value<double?> averageSpeedMetersPerSecond,
  Value<double?> maxSpeedMetersPerSecond,
  Value<String> status,
  Value<int?> routeId,
  Value<int?> bikeId,
  Value<DateTime> createdAt,
});
typedef $$RidesTableUpdateCompanionBuilder = RidesCompanion Function({
  Value<int> id,
  Value<String?> title,
  Value<DateTime> startedAt,
  Value<DateTime?> finishedAt,
  Value<int> durationSeconds,
  Value<int> pausedDurationSeconds,
  Value<DateTime?> pausedAt,
  Value<int> distanceMeters,
  Value<double?> elevationGainMeters,
  Value<double?> averageSpeedMetersPerSecond,
  Value<double?> maxSpeedMetersPerSecond,
  Value<String> status,
  Value<int?> routeId,
  Value<int?> bikeId,
  Value<DateTime> createdAt,
});

final class $$RidesTableReferences
    extends BaseReferences<_$AppDatabase, $RidesTable, Ride> {
  $$RidesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $RoutesTable _routeIdTable(_$AppDatabase db) =>
      db.routes.createAlias('rides__route_id__routes__id');

  $$RoutesTableProcessedTableManager? get routeId {
    final $_column = $_itemColumn<int>('route_id');
    if ($_column == null) return null;
    final manager = $$RoutesTableTableManager(
      $_db,
      $_db.routes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $BikesTable _bikeIdTable(_$AppDatabase db) =>
      db.bikes.createAlias('rides__bike_id__bikes__id');

  $$BikesTableProcessedTableManager? get bikeId {
    final $_column = $_itemColumn<int>('bike_id');
    if ($_column == null) return null;
    final manager = $$BikesTableTableManager(
      $_db,
      $_db.bikes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bikeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$RideTrackPointsTable, List<RideTrackPoint>>
  _rideTrackPointsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.rideTrackPoints,
    aliasName: 'rides__id__ride_track_points__ride_id',
  );

  $$RideTrackPointsTableProcessedTableManager get rideTrackPointsRefs {
    final manager = $$RideTrackPointsTableTableManager(
      $_db,
      $_db.rideTrackPoints,
    ).filter((f) => f.rideId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _rideTrackPointsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $RouteMatchSuggestionsTable,
    List<RouteMatchSuggestion>
  >
  _routeMatchSuggestionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.routeMatchSuggestions,
        aliasName: 'rides__id__route_match_suggestions__ride_id',
      );

  $$RouteMatchSuggestionsTableProcessedTableManager
  get routeMatchSuggestionsRefs {
    final manager = $$RouteMatchSuggestionsTableTableManager(
      $_db,
      $_db.routeMatchSuggestions,
    ).filter((f) => f.rideId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _routeMatchSuggestionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RidesTableFilterComposer extends Composer<_$AppDatabase, $RidesTable> {
  $$RidesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pausedDurationSeconds => $composableBuilder(
    column: $table.pausedDurationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get averageSpeedMetersPerSecond => $composableBuilder(
    column: $table.averageSpeedMetersPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxSpeedMetersPerSecond => $composableBuilder(
    column: $table.maxSpeedMetersPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RoutesTableFilterComposer get routeId {
    final $$RoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableFilterComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BikesTableFilterComposer get bikeId {
    final $$BikesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableFilterComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> rideTrackPointsRefs(
    Expression<bool> Function($$RideTrackPointsTableFilterComposer f) f,
  ) {
    final $$RideTrackPointsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rideTrackPoints,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RideTrackPointsTableFilterComposer(
            $db: $db,
            $table: $db.rideTrackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> routeMatchSuggestionsRefs(
    Expression<bool> Function($$RouteMatchSuggestionsTableFilterComposer f) f,
  ) {
    final $$RouteMatchSuggestionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routeMatchSuggestions,
          getReferencedColumn: (t) => t.rideId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RouteMatchSuggestionsTableFilterComposer(
                $db: $db,
                $table: $db.routeMatchSuggestions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RidesTableOrderingComposer
    extends Composer<_$AppDatabase, $RidesTable> {
  $$RidesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pausedDurationSeconds => $composableBuilder(
    column: $table.pausedDurationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pausedAt => $composableBuilder(
    column: $table.pausedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get averageSpeedMetersPerSecond => $composableBuilder(
    column: $table.averageSpeedMetersPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxSpeedMetersPerSecond => $composableBuilder(
    column: $table.maxSpeedMetersPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RoutesTableOrderingComposer get routeId {
    final $$RoutesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableOrderingComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BikesTableOrderingComposer get bikeId {
    final $$BikesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableOrderingComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RidesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RidesTable> {
  $$RidesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pausedDurationSeconds => $composableBuilder(
    column: $table.pausedDurationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get pausedAt =>
      $composableBuilder(column: $table.pausedAt, builder: (column) => column);

  GeneratedColumn<int> get distanceMeters => $composableBuilder(
    column: $table.distanceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get elevationGainMeters => $composableBuilder(
    column: $table.elevationGainMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get averageSpeedMetersPerSecond => $composableBuilder(
    column: $table.averageSpeedMetersPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxSpeedMetersPerSecond => $composableBuilder(
    column: $table.maxSpeedMetersPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$RoutesTableAnnotationComposer get routeId {
    final $$RoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$BikesTableAnnotationComposer get bikeId {
    final $$BikesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableAnnotationComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> rideTrackPointsRefs<T extends Object>(
    Expression<T> Function($$RideTrackPointsTableAnnotationComposer a) f,
  ) {
    final $$RideTrackPointsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.rideTrackPoints,
      getReferencedColumn: (t) => t.rideId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RideTrackPointsTableAnnotationComposer(
            $db: $db,
            $table: $db.rideTrackPoints,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> routeMatchSuggestionsRefs<T extends Object>(
    Expression<T> Function($$RouteMatchSuggestionsTableAnnotationComposer a) f,
  ) {
    final $$RouteMatchSuggestionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.routeMatchSuggestions,
          getReferencedColumn: (t) => t.rideId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RouteMatchSuggestionsTableAnnotationComposer(
                $db: $db,
                $table: $db.routeMatchSuggestions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$RidesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RidesTable,
          Ride,
          $$RidesTableFilterComposer,
          $$RidesTableOrderingComposer,
          $$RidesTableAnnotationComposer,
          $$RidesTableCreateCompanionBuilder,
          $$RidesTableUpdateCompanionBuilder,
          (Ride, $$RidesTableReferences),
          Ride,
          PrefetchHooks Function({
            bool routeId,
            bool bikeId,
            bool rideTrackPointsRefs,
            bool routeMatchSuggestionsRefs,
          })
        > {
  $$RidesTableTableManager(_$AppDatabase db, $RidesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RidesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RidesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RidesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> pausedDurationSeconds = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<int> distanceMeters = const Value.absent(),
                Value<double?> elevationGainMeters = const Value.absent(),
                Value<double?> averageSpeedMetersPerSecond =
                    const Value.absent(),
                Value<double?> maxSpeedMetersPerSecond = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> routeId = const Value.absent(),
                Value<int?> bikeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RidesCompanion(
                id: id,
                title: title,
                startedAt: startedAt,
                finishedAt: finishedAt,
                durationSeconds: durationSeconds,
                pausedDurationSeconds: pausedDurationSeconds,
                pausedAt: pausedAt,
                distanceMeters: distanceMeters,
                elevationGainMeters: elevationGainMeters,
                averageSpeedMetersPerSecond: averageSpeedMetersPerSecond,
                maxSpeedMetersPerSecond: maxSpeedMetersPerSecond,
                status: status,
                routeId: routeId,
                bikeId: bikeId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> title = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> pausedDurationSeconds = const Value.absent(),
                Value<DateTime?> pausedAt = const Value.absent(),
                Value<int> distanceMeters = const Value.absent(),
                Value<double?> elevationGainMeters = const Value.absent(),
                Value<double?> averageSpeedMetersPerSecond =
                    const Value.absent(),
                Value<double?> maxSpeedMetersPerSecond = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> routeId = const Value.absent(),
                Value<int?> bikeId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RidesCompanion.insert(
                id: id,
                title: title,
                startedAt: startedAt,
                finishedAt: finishedAt,
                durationSeconds: durationSeconds,
                pausedDurationSeconds: pausedDurationSeconds,
                pausedAt: pausedAt,
                distanceMeters: distanceMeters,
                elevationGainMeters: elevationGainMeters,
                averageSpeedMetersPerSecond: averageSpeedMetersPerSecond,
                maxSpeedMetersPerSecond: maxSpeedMetersPerSecond,
                status: status,
                routeId: routeId,
                bikeId: bikeId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RidesTable, Ride>(table),
                  $$RidesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                routeId = false,
                bikeId = false,
                rideTrackPointsRefs = false,
                routeMatchSuggestionsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (rideTrackPointsRefs) db.rideTrackPoints,
                    if (routeMatchSuggestionsRefs) db.routeMatchSuggestions,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (routeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.routeId,
                            referencedTable: $$RidesTableReferences
                                ._routeIdTable(db),
                            referencedColumn: $$RidesTableReferences
                                ._routeIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (bikeId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bikeId,
                            referencedTable: $$RidesTableReferences
                                ._bikeIdTable(db),
                            referencedColumn: $$RidesTableReferences
                                ._bikeIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (rideTrackPointsRefs)
                        await $_getPrefetchedData<
                          Ride,
                          $RidesTable,
                          RideTrackPoint
                        >(
                          currentTable: table,
                          referencedTable: $$RidesTableReferences
                              ._rideTrackPointsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RidesTableReferences(
                                db,
                                table,
                                p0,
                              ).rideTrackPointsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rideId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (routeMatchSuggestionsRefs)
                        await $_getPrefetchedData<
                          Ride,
                          $RidesTable,
                          RouteMatchSuggestion
                        >(
                          currentTable: table,
                          referencedTable: $$RidesTableReferences
                              ._routeMatchSuggestionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RidesTableReferences(
                                db,
                                table,
                                p0,
                              ).routeMatchSuggestionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.rideId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RidesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RidesTable,
      Ride,
      $$RidesTableFilterComposer,
      $$RidesTableOrderingComposer,
      $$RidesTableAnnotationComposer,
      $$RidesTableCreateCompanionBuilder,
      $$RidesTableUpdateCompanionBuilder,
      (Ride, $$RidesTableReferences),
      Ride,
      PrefetchHooks Function({
        bool routeId,
        bool bikeId,
        bool rideTrackPointsRefs,
        bool routeMatchSuggestionsRefs,
      })
    >;
typedef $$RideTrackPointsTableCreateCompanionBuilder =
    RideTrackPointsCompanion Function({
      Value<int> id,
      required int rideId,
      required int sequence,
      required double latitude,
      required double longitude,
      Value<double?> altitudeMeters,
      Value<double?> horizontalAccuracyMeters,
      Value<double?> speedMetersPerSecond,
      required DateTime recordedAt,
    });
typedef $$RideTrackPointsTableUpdateCompanionBuilder =
    RideTrackPointsCompanion Function({
      Value<int> id,
      Value<int> rideId,
      Value<int> sequence,
      Value<double> latitude,
      Value<double> longitude,
      Value<double?> altitudeMeters,
      Value<double?> horizontalAccuracyMeters,
      Value<double?> speedMetersPerSecond,
      Value<DateTime> recordedAt,
    });

final class $$RideTrackPointsTableReferences
    extends
        BaseReferences<_$AppDatabase, $RideTrackPointsTable, RideTrackPoint> {
  $$RideTrackPointsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RidesTable _rideIdTable(_$AppDatabase db) =>
      db.rides.createAlias('ride_track_points__ride_id__rides__id');

  $$RidesTableProcessedTableManager get rideId {
    final $_column = $_itemColumn<int>('ride_id')!;

    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rideIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RideTrackPointsTableFilterComposer
    extends Composer<_$AppDatabase, $RideTrackPointsTable> {
  $$RideTrackPointsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get horizontalAccuracyMeters => $composableBuilder(
    column: $table.horizontalAccuracyMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get speedMetersPerSecond => $composableBuilder(
    column: $table.speedMetersPerSecond,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RidesTableFilterComposer get rideId {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RideTrackPointsTableOrderingComposer
    extends Composer<_$AppDatabase, $RideTrackPointsTable> {
  $$RideTrackPointsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get horizontalAccuracyMeters => $composableBuilder(
    column: $table.horizontalAccuracyMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get speedMetersPerSecond => $composableBuilder(
    column: $table.speedMetersPerSecond,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RidesTableOrderingComposer get rideId {
    final $$RidesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableOrderingComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RideTrackPointsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RideTrackPointsTable> {
  $$RideTrackPointsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<double> get altitudeMeters => $composableBuilder(
    column: $table.altitudeMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get horizontalAccuracyMeters => $composableBuilder(
    column: $table.horizontalAccuracyMeters,
    builder: (column) => column,
  );

  GeneratedColumn<double> get speedMetersPerSecond => $composableBuilder(
    column: $table.speedMetersPerSecond,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  $$RidesTableAnnotationComposer get rideId {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RideTrackPointsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RideTrackPointsTable,
          RideTrackPoint,
          $$RideTrackPointsTableFilterComposer,
          $$RideTrackPointsTableOrderingComposer,
          $$RideTrackPointsTableAnnotationComposer,
          $$RideTrackPointsTableCreateCompanionBuilder,
          $$RideTrackPointsTableUpdateCompanionBuilder,
          (RideTrackPoint, $$RideTrackPointsTableReferences),
          RideTrackPoint,
          PrefetchHooks Function({bool rideId})
        > {
  $$RideTrackPointsTableTableManager(
    _$AppDatabase db,
    $RideTrackPointsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RideTrackPointsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RideTrackPointsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RideTrackPointsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rideId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<double?> altitudeMeters = const Value.absent(),
                Value<double?> horizontalAccuracyMeters = const Value.absent(),
                Value<double?> speedMetersPerSecond = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
              }) => RideTrackPointsCompanion(
                id: id,
                rideId: rideId,
                sequence: sequence,
                latitude: latitude,
                longitude: longitude,
                altitudeMeters: altitudeMeters,
                horizontalAccuracyMeters: horizontalAccuracyMeters,
                speedMetersPerSecond: speedMetersPerSecond,
                recordedAt: recordedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rideId,
                required int sequence,
                required double latitude,
                required double longitude,
                Value<double?> altitudeMeters = const Value.absent(),
                Value<double?> horizontalAccuracyMeters = const Value.absent(),
                Value<double?> speedMetersPerSecond = const Value.absent(),
                required DateTime recordedAt,
              }) => RideTrackPointsCompanion.insert(
                id: id,
                rideId: rideId,
                sequence: sequence,
                latitude: latitude,
                longitude: longitude,
                altitudeMeters: altitudeMeters,
                horizontalAccuracyMeters: horizontalAccuracyMeters,
                speedMetersPerSecond: speedMetersPerSecond,
                recordedAt: recordedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RideTrackPointsTable, RideTrackPoint>(table),
                  $$RideTrackPointsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rideId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rideId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.rideId,
                        referencedTable: $$RideTrackPointsTableReferences
                            ._rideIdTable(db),
                        referencedColumn: $$RideTrackPointsTableReferences
                            ._rideIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RideTrackPointsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RideTrackPointsTable,
      RideTrackPoint,
      $$RideTrackPointsTableFilterComposer,
      $$RideTrackPointsTableOrderingComposer,
      $$RideTrackPointsTableAnnotationComposer,
      $$RideTrackPointsTableCreateCompanionBuilder,
      $$RideTrackPointsTableUpdateCompanionBuilder,
      (RideTrackPoint, $$RideTrackPointsTableReferences),
      RideTrackPoint,
      PrefetchHooks Function({bool rideId})
    >;
typedef $$MaintenanceTemplatesTableCreateCompanionBuilder =
    MaintenanceTemplatesCompanion Function({
      required String bikeType,
      required String serviceName,
      Value<int?> intervalMeters,
      Value<bool> isEnabled,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$MaintenanceTemplatesTableUpdateCompanionBuilder =
    MaintenanceTemplatesCompanion Function({
      Value<String> bikeType,
      Value<String> serviceName,
      Value<int?> intervalMeters,
      Value<bool> isEnabled,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MaintenanceTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceTemplatesTable> {
  $$MaintenanceTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get bikeType => $composableBuilder(
    column: $table.bikeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalMeters => $composableBuilder(
    column: $table.intervalMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaintenanceTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceTemplatesTable> {
  $$MaintenanceTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get bikeType => $composableBuilder(
    column: $table.bikeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalMeters => $composableBuilder(
    column: $table.intervalMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaintenanceTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceTemplatesTable> {
  $$MaintenanceTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get bikeType =>
      $composableBuilder(column: $table.bikeType, builder: (column) => column);

  GeneratedColumn<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalMeters => $composableBuilder(
    column: $table.intervalMeters,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MaintenanceTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceTemplatesTable,
          MaintenanceTemplate,
          $$MaintenanceTemplatesTableFilterComposer,
          $$MaintenanceTemplatesTableOrderingComposer,
          $$MaintenanceTemplatesTableAnnotationComposer,
          $$MaintenanceTemplatesTableCreateCompanionBuilder,
          $$MaintenanceTemplatesTableUpdateCompanionBuilder,
          (
            MaintenanceTemplate,
            BaseReferences<
              _$AppDatabase,
              $MaintenanceTemplatesTable,
              MaintenanceTemplate
            >,
          ),
          MaintenanceTemplate,
          PrefetchHooks Function()
        > {
  $$MaintenanceTemplatesTableTableManager(
    _$AppDatabase db,
    $MaintenanceTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceTemplatesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MaintenanceTemplatesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> bikeType = const Value.absent(),
                Value<String> serviceName = const Value.absent(),
                Value<int?> intervalMeters = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenanceTemplatesCompanion(
                bikeType: bikeType,
                serviceName: serviceName,
                intervalMeters: intervalMeters,
                isEnabled: isEnabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bikeType,
                required String serviceName,
                Value<int?> intervalMeters = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaintenanceTemplatesCompanion.insert(
                bikeType: bikeType,
                serviceName: serviceName,
                intervalMeters: intervalMeters,
                isEnabled: isEnabled,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MaintenanceTemplatesTable, MaintenanceTemplate>(
                    table,
                  ),
                  BaseReferences<
                    _$AppDatabase,
                    $MaintenanceTemplatesTable,
                    MaintenanceTemplate
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaintenanceTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceTemplatesTable,
      MaintenanceTemplate,
      $$MaintenanceTemplatesTableFilterComposer,
      $$MaintenanceTemplatesTableOrderingComposer,
      $$MaintenanceTemplatesTableAnnotationComposer,
      $$MaintenanceTemplatesTableCreateCompanionBuilder,
      $$MaintenanceTemplatesTableUpdateCompanionBuilder,
      (
        MaintenanceTemplate,
        BaseReferences<
          _$AppDatabase,
          $MaintenanceTemplatesTable,
          MaintenanceTemplate
        >,
      ),
      MaintenanceTemplate,
      PrefetchHooks Function()
    >;
typedef $$MaintenanceEventsTableCreateCompanionBuilder =
    MaintenanceEventsCompanion Function({
      Value<int> id,
      required int bikeId,
      required String serviceName,
      required DateTime servicedAt,
      required int odometerMeters,
      Value<int?> serviceIntervalMeters,
      Value<String?> notes,
    });
typedef $$MaintenanceEventsTableUpdateCompanionBuilder =
    MaintenanceEventsCompanion Function({
      Value<int> id,
      Value<int> bikeId,
      Value<String> serviceName,
      Value<DateTime> servicedAt,
      Value<int> odometerMeters,
      Value<int?> serviceIntervalMeters,
      Value<String?> notes,
    });

final class $$MaintenanceEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MaintenanceEventsTable,
          MaintenanceEvent
        > {
  $$MaintenanceEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BikesTable _bikeIdTable(_$AppDatabase db) =>
      db.bikes.createAlias('maintenance_events__bike_id__bikes__id');

  $$BikesTableProcessedTableManager get bikeId {
    final $_column = $_itemColumn<int>('bike_id')!;

    final manager = $$BikesTableTableManager(
      $_db,
      $_db.bikes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bikeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MaintenanceEventsTableFilterComposer
    extends Composer<_$AppDatabase, $MaintenanceEventsTable> {
  $$MaintenanceEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get servicedAt => $composableBuilder(
    column: $table.servicedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get odometerMeters => $composableBuilder(
    column: $table.odometerMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get serviceIntervalMeters => $composableBuilder(
    column: $table.serviceIntervalMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$BikesTableFilterComposer get bikeId {
    final $$BikesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableFilterComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaintenanceEventsTable> {
  $$MaintenanceEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get servicedAt => $composableBuilder(
    column: $table.servicedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get odometerMeters => $composableBuilder(
    column: $table.odometerMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get serviceIntervalMeters => $composableBuilder(
    column: $table.serviceIntervalMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$BikesTableOrderingComposer get bikeId {
    final $$BikesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableOrderingComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaintenanceEventsTable> {
  $$MaintenanceEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get serviceName => $composableBuilder(
    column: $table.serviceName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get servicedAt => $composableBuilder(
    column: $table.servicedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get odometerMeters => $composableBuilder(
    column: $table.odometerMeters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get serviceIntervalMeters => $composableBuilder(
    column: $table.serviceIntervalMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$BikesTableAnnotationComposer get bikeId {
    final $$BikesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bikeId,
      referencedTable: $db.bikes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BikesTableAnnotationComposer(
            $db: $db,
            $table: $db.bikes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MaintenanceEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MaintenanceEventsTable,
          MaintenanceEvent,
          $$MaintenanceEventsTableFilterComposer,
          $$MaintenanceEventsTableOrderingComposer,
          $$MaintenanceEventsTableAnnotationComposer,
          $$MaintenanceEventsTableCreateCompanionBuilder,
          $$MaintenanceEventsTableUpdateCompanionBuilder,
          (MaintenanceEvent, $$MaintenanceEventsTableReferences),
          MaintenanceEvent,
          PrefetchHooks Function({bool bikeId})
        > {
  $$MaintenanceEventsTableTableManager(
    _$AppDatabase db,
    $MaintenanceEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaintenanceEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaintenanceEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaintenanceEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> bikeId = const Value.absent(),
                Value<String> serviceName = const Value.absent(),
                Value<DateTime> servicedAt = const Value.absent(),
                Value<int> odometerMeters = const Value.absent(),
                Value<int?> serviceIntervalMeters = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => MaintenanceEventsCompanion(
                id: id,
                bikeId: bikeId,
                serviceName: serviceName,
                servicedAt: servicedAt,
                odometerMeters: odometerMeters,
                serviceIntervalMeters: serviceIntervalMeters,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int bikeId,
                required String serviceName,
                required DateTime servicedAt,
                required int odometerMeters,
                Value<int?> serviceIntervalMeters = const Value.absent(),
                Value<String?> notes = const Value.absent(),
              }) => MaintenanceEventsCompanion.insert(
                id: id,
                bikeId: bikeId,
                serviceName: serviceName,
                servicedAt: servicedAt,
                odometerMeters: odometerMeters,
                serviceIntervalMeters: serviceIntervalMeters,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MaintenanceEventsTable, MaintenanceEvent>(table),
                  $$MaintenanceEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bikeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bikeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bikeId,
                        referencedTable: $$MaintenanceEventsTableReferences
                            ._bikeIdTable(db),
                        referencedColumn: $$MaintenanceEventsTableReferences
                            ._bikeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MaintenanceEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MaintenanceEventsTable,
      MaintenanceEvent,
      $$MaintenanceEventsTableFilterComposer,
      $$MaintenanceEventsTableOrderingComposer,
      $$MaintenanceEventsTableAnnotationComposer,
      $$MaintenanceEventsTableCreateCompanionBuilder,
      $$MaintenanceEventsTableUpdateCompanionBuilder,
      (MaintenanceEvent, $$MaintenanceEventsTableReferences),
      MaintenanceEvent,
      PrefetchHooks Function({bool bikeId})
    >;
typedef $$RouteMatchSuggestionsTableCreateCompanionBuilder =
    RouteMatchSuggestionsCompanion Function({
      Value<int> id,
      required int rideId,
      required int routeId,
      required double similarityScore,
      Value<int?> distanceDifferenceMeters,
      Value<String> status,
      Value<DateTime> suggestedAt,
    });
typedef $$RouteMatchSuggestionsTableUpdateCompanionBuilder =
    RouteMatchSuggestionsCompanion Function({
      Value<int> id,
      Value<int> rideId,
      Value<int> routeId,
      Value<double> similarityScore,
      Value<int?> distanceDifferenceMeters,
      Value<String> status,
      Value<DateTime> suggestedAt,
    });

final class $$RouteMatchSuggestionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RouteMatchSuggestionsTable,
          RouteMatchSuggestion
        > {
  $$RouteMatchSuggestionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $RidesTable _rideIdTable(_$AppDatabase db) =>
      db.rides.createAlias('route_match_suggestions__ride_id__rides__id');

  $$RidesTableProcessedTableManager get rideId {
    final $_column = $_itemColumn<int>('ride_id')!;

    final manager = $$RidesTableTableManager(
      $_db,
      $_db.rides,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_rideIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RoutesTable _routeIdTable(_$AppDatabase db) =>
      db.routes.createAlias('route_match_suggestions__route_id__routes__id');

  $$RoutesTableProcessedTableManager get routeId {
    final $_column = $_itemColumn<int>('route_id')!;

    final manager = $$RoutesTableTableManager(
      $_db,
      $_db.routes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_routeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RouteMatchSuggestionsTableFilterComposer
    extends Composer<_$AppDatabase, $RouteMatchSuggestionsTable> {
  $$RouteMatchSuggestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get similarityScore => $composableBuilder(
    column: $table.similarityScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distanceDifferenceMeters => $composableBuilder(
    column: $table.distanceDifferenceMeters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get suggestedAt => $composableBuilder(
    column: $table.suggestedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$RidesTableFilterComposer get rideId {
    final $$RidesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableFilterComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutesTableFilterComposer get routeId {
    final $$RoutesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableFilterComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteMatchSuggestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RouteMatchSuggestionsTable> {
  $$RouteMatchSuggestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get similarityScore => $composableBuilder(
    column: $table.similarityScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distanceDifferenceMeters => $composableBuilder(
    column: $table.distanceDifferenceMeters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get suggestedAt => $composableBuilder(
    column: $table.suggestedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$RidesTableOrderingComposer get rideId {
    final $$RidesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableOrderingComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutesTableOrderingComposer get routeId {
    final $$RoutesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableOrderingComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteMatchSuggestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RouteMatchSuggestionsTable> {
  $$RouteMatchSuggestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get similarityScore => $composableBuilder(
    column: $table.similarityScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distanceDifferenceMeters => $composableBuilder(
    column: $table.distanceDifferenceMeters,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get suggestedAt => $composableBuilder(
    column: $table.suggestedAt,
    builder: (column) => column,
  );

  $$RidesTableAnnotationComposer get rideId {
    final $$RidesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.rideId,
      referencedTable: $db.rides,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RidesTableAnnotationComposer(
            $db: $db,
            $table: $db.rides,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RoutesTableAnnotationComposer get routeId {
    final $$RoutesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.routeId,
      referencedTable: $db.routes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RoutesTableAnnotationComposer(
            $db: $db,
            $table: $db.routes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RouteMatchSuggestionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RouteMatchSuggestionsTable,
          RouteMatchSuggestion,
          $$RouteMatchSuggestionsTableFilterComposer,
          $$RouteMatchSuggestionsTableOrderingComposer,
          $$RouteMatchSuggestionsTableAnnotationComposer,
          $$RouteMatchSuggestionsTableCreateCompanionBuilder,
          $$RouteMatchSuggestionsTableUpdateCompanionBuilder,
          (RouteMatchSuggestion, $$RouteMatchSuggestionsTableReferences),
          RouteMatchSuggestion,
          PrefetchHooks Function({bool rideId, bool routeId})
        > {
  $$RouteMatchSuggestionsTableTableManager(
    _$AppDatabase db,
    $RouteMatchSuggestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RouteMatchSuggestionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RouteMatchSuggestionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RouteMatchSuggestionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> rideId = const Value.absent(),
                Value<int> routeId = const Value.absent(),
                Value<double> similarityScore = const Value.absent(),
                Value<int?> distanceDifferenceMeters = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> suggestedAt = const Value.absent(),
              }) => RouteMatchSuggestionsCompanion(
                id: id,
                rideId: rideId,
                routeId: routeId,
                similarityScore: similarityScore,
                distanceDifferenceMeters: distanceDifferenceMeters,
                status: status,
                suggestedAt: suggestedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int rideId,
                required int routeId,
                required double similarityScore,
                Value<int?> distanceDifferenceMeters = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> suggestedAt = const Value.absent(),
              }) => RouteMatchSuggestionsCompanion.insert(
                id: id,
                rideId: rideId,
                routeId: routeId,
                similarityScore: similarityScore,
                distanceDifferenceMeters: distanceDifferenceMeters,
                status: status,
                suggestedAt: suggestedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $RouteMatchSuggestionsTable,
                    RouteMatchSuggestion
                  >(table),
                  $$RouteMatchSuggestionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({rideId = false, routeId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (rideId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.rideId,
                        referencedTable: $$RouteMatchSuggestionsTableReferences
                            ._rideIdTable(db),
                        referencedColumn: $$RouteMatchSuggestionsTableReferences
                            ._rideIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (routeId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.routeId,
                        referencedTable: $$RouteMatchSuggestionsTableReferences
                            ._routeIdTable(db),
                        referencedColumn: $$RouteMatchSuggestionsTableReferences
                            ._routeIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RouteMatchSuggestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RouteMatchSuggestionsTable,
      RouteMatchSuggestion,
      $$RouteMatchSuggestionsTableFilterComposer,
      $$RouteMatchSuggestionsTableOrderingComposer,
      $$RouteMatchSuggestionsTableAnnotationComposer,
      $$RouteMatchSuggestionsTableCreateCompanionBuilder,
      $$RouteMatchSuggestionsTableUpdateCompanionBuilder,
      (RouteMatchSuggestion, $$RouteMatchSuggestionsTableReferences),
      RouteMatchSuggestion,
      PrefetchHooks Function({bool rideId, bool routeId})
    >;
typedef $$RiderProfilesTableCreateCompanionBuilder =
    RiderProfilesCompanion Function({
      Value<int> id,
      required String displayName,
      Value<DateTime> updatedAt,
    });
typedef $$RiderProfilesTableUpdateCompanionBuilder =
    RiderProfilesCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<DateTime> updatedAt,
    });

class $$RiderProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $RiderProfilesTable> {
  $$RiderProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RiderProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $RiderProfilesTable> {
  $$RiderProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RiderProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RiderProfilesTable> {
  $$RiderProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$RiderProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RiderProfilesTable,
          RiderProfile,
          $$RiderProfilesTableFilterComposer,
          $$RiderProfilesTableOrderingComposer,
          $$RiderProfilesTableAnnotationComposer,
          $$RiderProfilesTableCreateCompanionBuilder,
          $$RiderProfilesTableUpdateCompanionBuilder,
          (
            RiderProfile,
            BaseReferences<_$AppDatabase, $RiderProfilesTable, RiderProfile>,
          ),
          RiderProfile,
          PrefetchHooks Function()
        > {
  $$RiderProfilesTableTableManager(_$AppDatabase db, $RiderProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RiderProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RiderProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RiderProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RiderProfilesCompanion(
                id: id,
                displayName: displayName,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                Value<DateTime> updatedAt = const Value.absent(),
              }) => RiderProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RiderProfilesTable, RiderProfile>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RiderProfilesTable,
                    RiderProfile
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RiderProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RiderProfilesTable,
      RiderProfile,
      $$RiderProfilesTableFilterComposer,
      $$RiderProfilesTableOrderingComposer,
      $$RiderProfilesTableAnnotationComposer,
      $$RiderProfilesTableCreateCompanionBuilder,
      $$RiderProfilesTableUpdateCompanionBuilder,
      (
        RiderProfile,
        BaseReferences<_$AppDatabase, $RiderProfilesTable, RiderProfile>,
      ),
      RiderProfile,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$RoutesTableTableManager get routes =>
      $$RoutesTableTableManager(_db, _db.routes);
  $$BikesTableTableManager get bikes =>
      $$BikesTableTableManager(_db, _db.bikes);
  $$RidesTableTableManager get rides =>
      $$RidesTableTableManager(_db, _db.rides);
  $$RideTrackPointsTableTableManager get rideTrackPoints =>
      $$RideTrackPointsTableTableManager(_db, _db.rideTrackPoints);
  $$MaintenanceTemplatesTableTableManager get maintenanceTemplates =>
      $$MaintenanceTemplatesTableTableManager(_db, _db.maintenanceTemplates);
  $$MaintenanceEventsTableTableManager get maintenanceEvents =>
      $$MaintenanceEventsTableTableManager(_db, _db.maintenanceEvents);
  $$RouteMatchSuggestionsTableTableManager get routeMatchSuggestions =>
      $$RouteMatchSuggestionsTableTableManager(_db, _db.routeMatchSuggestions);
  $$RiderProfilesTableTableManager get riderProfiles =>
      $$RiderProfilesTableTableManager(_db, _db.riderProfiles);
}
