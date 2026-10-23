// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $StoresTable extends Stores with TableInfo<$StoresTable, StoreRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoresTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _binMeta = const VerificationMeta('bin');
  @override
  late final GeneratedColumn<String> bin = GeneratedColumn<String>(
    'bin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, bin, address];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stores';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoreRow> instance, {
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
    if (data.containsKey('bin')) {
      context.handle(
        _binMeta,
        bin.isAcceptableOrUnknown(data['bin']!, _binMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoreRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoreRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bin'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
    );
  }

  @override
  $StoresTable createAlias(String alias) {
    return $StoresTable(attachedDatabase, alias);
  }
}

class StoreRow extends DataClass implements Insertable<StoreRow> {
  final int id;
  final String name;
  final String? bin;
  final String? address;
  const StoreRow({
    required this.id,
    required this.name,
    this.bin,
    this.address,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || bin != null) {
      map['bin'] = Variable<String>(bin);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    return map;
  }

  StoresCompanion toCompanion(bool nullToAbsent) {
    return StoresCompanion(
      id: Value(id),
      name: Value(name),
      bin: bin == null && nullToAbsent ? const Value.absent() : Value(bin),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
    );
  }

  factory StoreRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoreRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bin: serializer.fromJson<String?>(json['bin']),
      address: serializer.fromJson<String?>(json['address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'bin': serializer.toJson<String?>(bin),
      'address': serializer.toJson<String?>(address),
    };
  }

  StoreRow copyWith({
    int? id,
    String? name,
    Value<String?> bin = const Value.absent(),
    Value<String?> address = const Value.absent(),
  }) => StoreRow(
    id: id ?? this.id,
    name: name ?? this.name,
    bin: bin.present ? bin.value : this.bin,
    address: address.present ? address.value : this.address,
  );
  StoreRow copyWithCompanion(StoresCompanion data) {
    return StoreRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bin: data.bin.present ? data.bin.value : this.bin,
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoreRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bin: $bin, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, bin, address);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoreRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.bin == this.bin &&
          other.address == this.address);
}

class StoresCompanion extends UpdateCompanion<StoreRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> bin;
  final Value<String?> address;
  const StoresCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bin = const Value.absent(),
    this.address = const Value.absent(),
  });
  StoresCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.bin = const Value.absent(),
    this.address = const Value.absent(),
  }) : name = Value(name);
  static Insertable<StoreRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? bin,
    Expression<String>? address,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bin != null) 'bin': bin,
      if (address != null) 'address': address,
    });
  }

  StoresCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? bin,
    Value<String?>? address,
  }) {
    return StoresCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bin: bin ?? this.bin,
      address: address ?? this.address,
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
    if (bin.present) {
      map['bin'] = Variable<String>(bin.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoresCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bin: $bin, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
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
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    icon,
    isBuiltIn,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
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
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final int id;
  final String name;
  final int color;
  final String icon;
  final bool isBuiltIn;
  final int sortOrder;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    required this.isBuiltIn,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['icon'] = Variable<String>(icon);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      icon: Value(icon),
      isBuiltIn: Value(isBuiltIn),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      icon: serializer.fromJson<String>(json['icon']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'icon': serializer.toJson<String>(icon),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryRow copyWith({
    int? id,
    String? name,
    int? color,
    String? icon,
    bool? isBuiltIn,
    int? sortOrder,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    icon: icon ?? this.icon,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, icon, isBuiltIn, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.isBuiltIn == this.isBuiltIn &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> color;
  final Value<String> icon;
  final Value<bool> isBuiltIn;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int color,
    required String icon,
    this.isBuiltIn = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       color = Value(color),
       icon = Value(icon);
  static Insertable<CategoryRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<bool>? isBuiltIn,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? color,
    Value<String>? icon,
    Value<bool>? isBuiltIn,
    Value<int>? sortOrder,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      sortOrder: sortOrder ?? this.sortOrder,
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
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $ReceiptsTable extends Receipts
    with TableInfo<$ReceiptsTable, ReceiptRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _storeIdMeta = const VerificationMeta(
    'storeId',
  );
  @override
  late final GeneratedColumn<int> storeId = GeneratedColumn<int>(
    'store_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES stores (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _ofdNameMeta = const VerificationMeta(
    'ofdName',
  );
  @override
  late final GeneratedColumn<String> ofdName = GeneratedColumn<String>(
    'ofd_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kkmRegNumberMeta = const VerificationMeta(
    'kkmRegNumber',
  );
  @override
  late final GeneratedColumn<String> kkmRegNumber = GeneratedColumn<String>(
    'kkm_reg_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kkmSerialMeta = const VerificationMeta(
    'kkmSerial',
  );
  @override
  late final GeneratedColumn<String> kkmSerial = GeneratedColumn<String>(
    'kkm_serial',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fiscalSignMeta = const VerificationMeta(
    'fiscalSign',
  );
  @override
  late final GeneratedColumn<String> fiscalSign = GeneratedColumn<String>(
    'fiscal_sign',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptNumberMeta = const VerificationMeta(
    'receiptNumber',
  );
  @override
  late final GeneratedColumn<String> receiptNumber = GeneratedColumn<String>(
    'receipt_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateTimeUtcMeta = const VerificationMeta(
    'dateTimeUtc',
  );
  @override
  late final GeneratedColumn<DateTime> dateTimeUtc = GeneratedColumn<DateTime>(
    'date_time_utc',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tzOffsetMinMeta = const VerificationMeta(
    'tzOffsetMin',
  );
  @override
  late final GeneratedColumn<int> tzOffsetMin = GeneratedColumn<int>(
    'tz_offset_min',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMinorMeta = const VerificationMeta(
    'totalMinor',
  );
  @override
  late final GeneratedColumn<int> totalMinor = GeneratedColumn<int>(
    'total_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountMinorMeta = const VerificationMeta(
    'discountMinor',
  );
  @override
  late final GeneratedColumn<int> discountMinor = GeneratedColumn<int>(
    'discount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vatMinorMeta = const VerificationMeta(
    'vatMinor',
  );
  @override
  late final GeneratedColumn<int> vatMinor = GeneratedColumn<int>(
    'vat_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vatRateMeta = const VerificationMeta(
    'vatRate',
  );
  @override
  late final GeneratedColumn<double> vatRate = GeneratedColumn<double>(
    'vat_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('KZT'),
  );
  static const VerificationMeta _paymentTypeMeta = const VerificationMeta(
    'paymentType',
  );
  @override
  late final GeneratedColumn<String> paymentType = GeneratedColumn<String>(
    'payment_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dedupKeyMeta = const VerificationMeta(
    'dedupKey',
  );
  @override
  late final GeneratedColumn<String> dedupKey = GeneratedColumn<String>(
    'dedup_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    check: () => status.isIn(const ['pending', 'ok', 'error']),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _needsReviewMeta = const VerificationMeta(
    'needsReview',
  );
  @override
  late final GeneratedColumn<bool> needsReview = GeneratedColumn<bool>(
    'needs_review',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("needs_review" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _editedMeta = const VerificationMeta('edited');
  @override
  late final GeneratedColumn<bool> edited = GeneratedColumn<bool>(
    'edited',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("edited" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextRetryAtMeta = const VerificationMeta(
    'nextRetryAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextRetryAt = GeneratedColumn<DateTime>(
    'next_retry_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _debugRawMeta = const VerificationMeta(
    'debugRaw',
  );
  @override
  late final GeneratedColumn<String> debugRaw = GeneratedColumn<String>(
    'debug_raw',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
    defaultValue: currentDateAndTime,
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
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    storeId,
    ofdName,
    kkmRegNumber,
    kkmSerial,
    fiscalSign,
    receiptNumber,
    dateTimeUtc,
    tzOffsetMin,
    totalMinor,
    discountMinor,
    vatMinor,
    vatRate,
    currency,
    paymentType,
    sourceUrl,
    dedupKey,
    status,
    needsReview,
    edited,
    note,
    categoryId,
    retryCount,
    nextRetryAt,
    lastError,
    debugRaw,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('store_id')) {
      context.handle(
        _storeIdMeta,
        storeId.isAcceptableOrUnknown(data['store_id']!, _storeIdMeta),
      );
    }
    if (data.containsKey('ofd_name')) {
      context.handle(
        _ofdNameMeta,
        ofdName.isAcceptableOrUnknown(data['ofd_name']!, _ofdNameMeta),
      );
    }
    if (data.containsKey('kkm_reg_number')) {
      context.handle(
        _kkmRegNumberMeta,
        kkmRegNumber.isAcceptableOrUnknown(
          data['kkm_reg_number']!,
          _kkmRegNumberMeta,
        ),
      );
    }
    if (data.containsKey('kkm_serial')) {
      context.handle(
        _kkmSerialMeta,
        kkmSerial.isAcceptableOrUnknown(data['kkm_serial']!, _kkmSerialMeta),
      );
    }
    if (data.containsKey('fiscal_sign')) {
      context.handle(
        _fiscalSignMeta,
        fiscalSign.isAcceptableOrUnknown(data['fiscal_sign']!, _fiscalSignMeta),
      );
    }
    if (data.containsKey('receipt_number')) {
      context.handle(
        _receiptNumberMeta,
        receiptNumber.isAcceptableOrUnknown(
          data['receipt_number']!,
          _receiptNumberMeta,
        ),
      );
    }
    if (data.containsKey('date_time_utc')) {
      context.handle(
        _dateTimeUtcMeta,
        dateTimeUtc.isAcceptableOrUnknown(
          data['date_time_utc']!,
          _dateTimeUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dateTimeUtcMeta);
    }
    if (data.containsKey('tz_offset_min')) {
      context.handle(
        _tzOffsetMinMeta,
        tzOffsetMin.isAcceptableOrUnknown(
          data['tz_offset_min']!,
          _tzOffsetMinMeta,
        ),
      );
    }
    if (data.containsKey('total_minor')) {
      context.handle(
        _totalMinorMeta,
        totalMinor.isAcceptableOrUnknown(data['total_minor']!, _totalMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMinorMeta);
    }
    if (data.containsKey('discount_minor')) {
      context.handle(
        _discountMinorMeta,
        discountMinor.isAcceptableOrUnknown(
          data['discount_minor']!,
          _discountMinorMeta,
        ),
      );
    }
    if (data.containsKey('vat_minor')) {
      context.handle(
        _vatMinorMeta,
        vatMinor.isAcceptableOrUnknown(data['vat_minor']!, _vatMinorMeta),
      );
    }
    if (data.containsKey('vat_rate')) {
      context.handle(
        _vatRateMeta,
        vatRate.isAcceptableOrUnknown(data['vat_rate']!, _vatRateMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('payment_type')) {
      context.handle(
        _paymentTypeMeta,
        paymentType.isAcceptableOrUnknown(
          data['payment_type']!,
          _paymentTypeMeta,
        ),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('dedup_key')) {
      context.handle(
        _dedupKeyMeta,
        dedupKey.isAcceptableOrUnknown(data['dedup_key']!, _dedupKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dedupKeyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('needs_review')) {
      context.handle(
        _needsReviewMeta,
        needsReview.isAcceptableOrUnknown(
          data['needs_review']!,
          _needsReviewMeta,
        ),
      );
    }
    if (data.containsKey('edited')) {
      context.handle(
        _editedMeta,
        edited.isAcceptableOrUnknown(data['edited']!, _editedMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('next_retry_at')) {
      context.handle(
        _nextRetryAtMeta,
        nextRetryAt.isAcceptableOrUnknown(
          data['next_retry_at']!,
          _nextRetryAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('debug_raw')) {
      context.handle(
        _debugRawMeta,
        debugRaw.isAcceptableOrUnknown(data['debug_raw']!, _debugRawMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      storeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}store_id'],
      ),
      ofdName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ofd_name'],
      ),
      kkmRegNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kkm_reg_number'],
      ),
      kkmSerial: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kkm_serial'],
      ),
      fiscalSign: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiscal_sign'],
      ),
      receiptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_number'],
      ),
      dateTimeUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date_time_utc'],
      )!,
      tzOffsetMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tz_offset_min'],
      ),
      totalMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_minor'],
      )!,
      discountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_minor'],
      ),
      vatMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vat_minor'],
      ),
      vatRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}vat_rate'],
      ),
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      paymentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_type'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      dedupKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedup_key'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      needsReview: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}needs_review'],
      )!,
      edited: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}edited'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      nextRetryAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_retry_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      debugRaw: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debug_raw'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReceiptsTable createAlias(String alias) {
    return $ReceiptsTable(attachedDatabase, alias);
  }
}

class ReceiptRow extends DataClass implements Insertable<ReceiptRow> {
  final int id;
  final int? storeId;
  final String? ofdName;
  final String? kkmRegNumber;
  final String? kkmSerial;
  final String? fiscalSign;
  final String? receiptNumber;
  final DateTime dateTimeUtc;
  final int? tzOffsetMin;
  final int totalMinor;
  final int? discountMinor;
  final int? vatMinor;
  final double? vatRate;
  final String currency;
  final String? paymentType;
  final String sourceUrl;
  final String dedupKey;
  final String status;
  final bool needsReview;
  final bool edited;
  final String? note;
  final int? categoryId;
  final int retryCount;
  final DateTime? nextRetryAt;
  final String? lastError;
  final String? debugRaw;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ReceiptRow({
    required this.id,
    this.storeId,
    this.ofdName,
    this.kkmRegNumber,
    this.kkmSerial,
    this.fiscalSign,
    this.receiptNumber,
    required this.dateTimeUtc,
    this.tzOffsetMin,
    required this.totalMinor,
    this.discountMinor,
    this.vatMinor,
    this.vatRate,
    required this.currency,
    this.paymentType,
    required this.sourceUrl,
    required this.dedupKey,
    required this.status,
    required this.needsReview,
    required this.edited,
    this.note,
    this.categoryId,
    required this.retryCount,
    this.nextRetryAt,
    this.lastError,
    this.debugRaw,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || storeId != null) {
      map['store_id'] = Variable<int>(storeId);
    }
    if (!nullToAbsent || ofdName != null) {
      map['ofd_name'] = Variable<String>(ofdName);
    }
    if (!nullToAbsent || kkmRegNumber != null) {
      map['kkm_reg_number'] = Variable<String>(kkmRegNumber);
    }
    if (!nullToAbsent || kkmSerial != null) {
      map['kkm_serial'] = Variable<String>(kkmSerial);
    }
    if (!nullToAbsent || fiscalSign != null) {
      map['fiscal_sign'] = Variable<String>(fiscalSign);
    }
    if (!nullToAbsent || receiptNumber != null) {
      map['receipt_number'] = Variable<String>(receiptNumber);
    }
    map['date_time_utc'] = Variable<DateTime>(dateTimeUtc);
    if (!nullToAbsent || tzOffsetMin != null) {
      map['tz_offset_min'] = Variable<int>(tzOffsetMin);
    }
    map['total_minor'] = Variable<int>(totalMinor);
    if (!nullToAbsent || discountMinor != null) {
      map['discount_minor'] = Variable<int>(discountMinor);
    }
    if (!nullToAbsent || vatMinor != null) {
      map['vat_minor'] = Variable<int>(vatMinor);
    }
    if (!nullToAbsent || vatRate != null) {
      map['vat_rate'] = Variable<double>(vatRate);
    }
    map['currency'] = Variable<String>(currency);
    if (!nullToAbsent || paymentType != null) {
      map['payment_type'] = Variable<String>(paymentType);
    }
    map['source_url'] = Variable<String>(sourceUrl);
    map['dedup_key'] = Variable<String>(dedupKey);
    map['status'] = Variable<String>(status);
    map['needs_review'] = Variable<bool>(needsReview);
    map['edited'] = Variable<bool>(edited);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || nextRetryAt != null) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || debugRaw != null) {
      map['debug_raw'] = Variable<String>(debugRaw);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReceiptsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptsCompanion(
      id: Value(id),
      storeId: storeId == null && nullToAbsent
          ? const Value.absent()
          : Value(storeId),
      ofdName: ofdName == null && nullToAbsent
          ? const Value.absent()
          : Value(ofdName),
      kkmRegNumber: kkmRegNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(kkmRegNumber),
      kkmSerial: kkmSerial == null && nullToAbsent
          ? const Value.absent()
          : Value(kkmSerial),
      fiscalSign: fiscalSign == null && nullToAbsent
          ? const Value.absent()
          : Value(fiscalSign),
      receiptNumber: receiptNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptNumber),
      dateTimeUtc: Value(dateTimeUtc),
      tzOffsetMin: tzOffsetMin == null && nullToAbsent
          ? const Value.absent()
          : Value(tzOffsetMin),
      totalMinor: Value(totalMinor),
      discountMinor: discountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(discountMinor),
      vatMinor: vatMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(vatMinor),
      vatRate: vatRate == null && nullToAbsent
          ? const Value.absent()
          : Value(vatRate),
      currency: Value(currency),
      paymentType: paymentType == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentType),
      sourceUrl: Value(sourceUrl),
      dedupKey: Value(dedupKey),
      status: Value(status),
      needsReview: Value(needsReview),
      edited: Value(edited),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      retryCount: Value(retryCount),
      nextRetryAt: nextRetryAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextRetryAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      debugRaw: debugRaw == null && nullToAbsent
          ? const Value.absent()
          : Value(debugRaw),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReceiptRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptRow(
      id: serializer.fromJson<int>(json['id']),
      storeId: serializer.fromJson<int?>(json['storeId']),
      ofdName: serializer.fromJson<String?>(json['ofdName']),
      kkmRegNumber: serializer.fromJson<String?>(json['kkmRegNumber']),
      kkmSerial: serializer.fromJson<String?>(json['kkmSerial']),
      fiscalSign: serializer.fromJson<String?>(json['fiscalSign']),
      receiptNumber: serializer.fromJson<String?>(json['receiptNumber']),
      dateTimeUtc: serializer.fromJson<DateTime>(json['dateTimeUtc']),
      tzOffsetMin: serializer.fromJson<int?>(json['tzOffsetMin']),
      totalMinor: serializer.fromJson<int>(json['totalMinor']),
      discountMinor: serializer.fromJson<int?>(json['discountMinor']),
      vatMinor: serializer.fromJson<int?>(json['vatMinor']),
      vatRate: serializer.fromJson<double?>(json['vatRate']),
      currency: serializer.fromJson<String>(json['currency']),
      paymentType: serializer.fromJson<String?>(json['paymentType']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      dedupKey: serializer.fromJson<String>(json['dedupKey']),
      status: serializer.fromJson<String>(json['status']),
      needsReview: serializer.fromJson<bool>(json['needsReview']),
      edited: serializer.fromJson<bool>(json['edited']),
      note: serializer.fromJson<String?>(json['note']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      nextRetryAt: serializer.fromJson<DateTime?>(json['nextRetryAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      debugRaw: serializer.fromJson<String?>(json['debugRaw']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'storeId': serializer.toJson<int?>(storeId),
      'ofdName': serializer.toJson<String?>(ofdName),
      'kkmRegNumber': serializer.toJson<String?>(kkmRegNumber),
      'kkmSerial': serializer.toJson<String?>(kkmSerial),
      'fiscalSign': serializer.toJson<String?>(fiscalSign),
      'receiptNumber': serializer.toJson<String?>(receiptNumber),
      'dateTimeUtc': serializer.toJson<DateTime>(dateTimeUtc),
      'tzOffsetMin': serializer.toJson<int?>(tzOffsetMin),
      'totalMinor': serializer.toJson<int>(totalMinor),
      'discountMinor': serializer.toJson<int?>(discountMinor),
      'vatMinor': serializer.toJson<int?>(vatMinor),
      'vatRate': serializer.toJson<double?>(vatRate),
      'currency': serializer.toJson<String>(currency),
      'paymentType': serializer.toJson<String?>(paymentType),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'dedupKey': serializer.toJson<String>(dedupKey),
      'status': serializer.toJson<String>(status),
      'needsReview': serializer.toJson<bool>(needsReview),
      'edited': serializer.toJson<bool>(edited),
      'note': serializer.toJson<String?>(note),
      'categoryId': serializer.toJson<int?>(categoryId),
      'retryCount': serializer.toJson<int>(retryCount),
      'nextRetryAt': serializer.toJson<DateTime?>(nextRetryAt),
      'lastError': serializer.toJson<String?>(lastError),
      'debugRaw': serializer.toJson<String?>(debugRaw),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReceiptRow copyWith({
    int? id,
    Value<int?> storeId = const Value.absent(),
    Value<String?> ofdName = const Value.absent(),
    Value<String?> kkmRegNumber = const Value.absent(),
    Value<String?> kkmSerial = const Value.absent(),
    Value<String?> fiscalSign = const Value.absent(),
    Value<String?> receiptNumber = const Value.absent(),
    DateTime? dateTimeUtc,
    Value<int?> tzOffsetMin = const Value.absent(),
    int? totalMinor,
    Value<int?> discountMinor = const Value.absent(),
    Value<int?> vatMinor = const Value.absent(),
    Value<double?> vatRate = const Value.absent(),
    String? currency,
    Value<String?> paymentType = const Value.absent(),
    String? sourceUrl,
    String? dedupKey,
    String? status,
    bool? needsReview,
    bool? edited,
    Value<String?> note = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
    int? retryCount,
    Value<DateTime?> nextRetryAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<String?> debugRaw = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ReceiptRow(
    id: id ?? this.id,
    storeId: storeId.present ? storeId.value : this.storeId,
    ofdName: ofdName.present ? ofdName.value : this.ofdName,
    kkmRegNumber: kkmRegNumber.present ? kkmRegNumber.value : this.kkmRegNumber,
    kkmSerial: kkmSerial.present ? kkmSerial.value : this.kkmSerial,
    fiscalSign: fiscalSign.present ? fiscalSign.value : this.fiscalSign,
    receiptNumber: receiptNumber.present
        ? receiptNumber.value
        : this.receiptNumber,
    dateTimeUtc: dateTimeUtc ?? this.dateTimeUtc,
    tzOffsetMin: tzOffsetMin.present ? tzOffsetMin.value : this.tzOffsetMin,
    totalMinor: totalMinor ?? this.totalMinor,
    discountMinor: discountMinor.present
        ? discountMinor.value
        : this.discountMinor,
    vatMinor: vatMinor.present ? vatMinor.value : this.vatMinor,
    vatRate: vatRate.present ? vatRate.value : this.vatRate,
    currency: currency ?? this.currency,
    paymentType: paymentType.present ? paymentType.value : this.paymentType,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    dedupKey: dedupKey ?? this.dedupKey,
    status: status ?? this.status,
    needsReview: needsReview ?? this.needsReview,
    edited: edited ?? this.edited,
    note: note.present ? note.value : this.note,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    retryCount: retryCount ?? this.retryCount,
    nextRetryAt: nextRetryAt.present ? nextRetryAt.value : this.nextRetryAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    debugRaw: debugRaw.present ? debugRaw.value : this.debugRaw,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReceiptRow copyWithCompanion(ReceiptsCompanion data) {
    return ReceiptRow(
      id: data.id.present ? data.id.value : this.id,
      storeId: data.storeId.present ? data.storeId.value : this.storeId,
      ofdName: data.ofdName.present ? data.ofdName.value : this.ofdName,
      kkmRegNumber: data.kkmRegNumber.present
          ? data.kkmRegNumber.value
          : this.kkmRegNumber,
      kkmSerial: data.kkmSerial.present ? data.kkmSerial.value : this.kkmSerial,
      fiscalSign: data.fiscalSign.present
          ? data.fiscalSign.value
          : this.fiscalSign,
      receiptNumber: data.receiptNumber.present
          ? data.receiptNumber.value
          : this.receiptNumber,
      dateTimeUtc: data.dateTimeUtc.present
          ? data.dateTimeUtc.value
          : this.dateTimeUtc,
      tzOffsetMin: data.tzOffsetMin.present
          ? data.tzOffsetMin.value
          : this.tzOffsetMin,
      totalMinor: data.totalMinor.present
          ? data.totalMinor.value
          : this.totalMinor,
      discountMinor: data.discountMinor.present
          ? data.discountMinor.value
          : this.discountMinor,
      vatMinor: data.vatMinor.present ? data.vatMinor.value : this.vatMinor,
      vatRate: data.vatRate.present ? data.vatRate.value : this.vatRate,
      currency: data.currency.present ? data.currency.value : this.currency,
      paymentType: data.paymentType.present
          ? data.paymentType.value
          : this.paymentType,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      dedupKey: data.dedupKey.present ? data.dedupKey.value : this.dedupKey,
      status: data.status.present ? data.status.value : this.status,
      needsReview: data.needsReview.present
          ? data.needsReview.value
          : this.needsReview,
      edited: data.edited.present ? data.edited.value : this.edited,
      note: data.note.present ? data.note.value : this.note,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      nextRetryAt: data.nextRetryAt.present
          ? data.nextRetryAt.value
          : this.nextRetryAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      debugRaw: data.debugRaw.present ? data.debugRaw.value : this.debugRaw,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptRow(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('ofdName: $ofdName, ')
          ..write('kkmRegNumber: $kkmRegNumber, ')
          ..write('kkmSerial: $kkmSerial, ')
          ..write('fiscalSign: $fiscalSign, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('dateTimeUtc: $dateTimeUtc, ')
          ..write('tzOffsetMin: $tzOffsetMin, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('discountMinor: $discountMinor, ')
          ..write('vatMinor: $vatMinor, ')
          ..write('vatRate: $vatRate, ')
          ..write('currency: $currency, ')
          ..write('paymentType: $paymentType, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('dedupKey: $dedupKey, ')
          ..write('status: $status, ')
          ..write('needsReview: $needsReview, ')
          ..write('edited: $edited, ')
          ..write('note: $note, ')
          ..write('categoryId: $categoryId, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('debugRaw: $debugRaw, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    storeId,
    ofdName,
    kkmRegNumber,
    kkmSerial,
    fiscalSign,
    receiptNumber,
    dateTimeUtc,
    tzOffsetMin,
    totalMinor,
    discountMinor,
    vatMinor,
    vatRate,
    currency,
    paymentType,
    sourceUrl,
    dedupKey,
    status,
    needsReview,
    edited,
    note,
    categoryId,
    retryCount,
    nextRetryAt,
    lastError,
    debugRaw,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptRow &&
          other.id == this.id &&
          other.storeId == this.storeId &&
          other.ofdName == this.ofdName &&
          other.kkmRegNumber == this.kkmRegNumber &&
          other.kkmSerial == this.kkmSerial &&
          other.fiscalSign == this.fiscalSign &&
          other.receiptNumber == this.receiptNumber &&
          other.dateTimeUtc == this.dateTimeUtc &&
          other.tzOffsetMin == this.tzOffsetMin &&
          other.totalMinor == this.totalMinor &&
          other.discountMinor == this.discountMinor &&
          other.vatMinor == this.vatMinor &&
          other.vatRate == this.vatRate &&
          other.currency == this.currency &&
          other.paymentType == this.paymentType &&
          other.sourceUrl == this.sourceUrl &&
          other.dedupKey == this.dedupKey &&
          other.status == this.status &&
          other.needsReview == this.needsReview &&
          other.edited == this.edited &&
          other.note == this.note &&
          other.categoryId == this.categoryId &&
          other.retryCount == this.retryCount &&
          other.nextRetryAt == this.nextRetryAt &&
          other.lastError == this.lastError &&
          other.debugRaw == this.debugRaw &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ReceiptsCompanion extends UpdateCompanion<ReceiptRow> {
  final Value<int> id;
  final Value<int?> storeId;
  final Value<String?> ofdName;
  final Value<String?> kkmRegNumber;
  final Value<String?> kkmSerial;
  final Value<String?> fiscalSign;
  final Value<String?> receiptNumber;
  final Value<DateTime> dateTimeUtc;
  final Value<int?> tzOffsetMin;
  final Value<int> totalMinor;
  final Value<int?> discountMinor;
  final Value<int?> vatMinor;
  final Value<double?> vatRate;
  final Value<String> currency;
  final Value<String?> paymentType;
  final Value<String> sourceUrl;
  final Value<String> dedupKey;
  final Value<String> status;
  final Value<bool> needsReview;
  final Value<bool> edited;
  final Value<String?> note;
  final Value<int?> categoryId;
  final Value<int> retryCount;
  final Value<DateTime?> nextRetryAt;
  final Value<String?> lastError;
  final Value<String?> debugRaw;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ReceiptsCompanion({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.ofdName = const Value.absent(),
    this.kkmRegNumber = const Value.absent(),
    this.kkmSerial = const Value.absent(),
    this.fiscalSign = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.dateTimeUtc = const Value.absent(),
    this.tzOffsetMin = const Value.absent(),
    this.totalMinor = const Value.absent(),
    this.discountMinor = const Value.absent(),
    this.vatMinor = const Value.absent(),
    this.vatRate = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.dedupKey = const Value.absent(),
    this.status = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.edited = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.debugRaw = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ReceiptsCompanion.insert({
    this.id = const Value.absent(),
    this.storeId = const Value.absent(),
    this.ofdName = const Value.absent(),
    this.kkmRegNumber = const Value.absent(),
    this.kkmSerial = const Value.absent(),
    this.fiscalSign = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    required DateTime dateTimeUtc,
    this.tzOffsetMin = const Value.absent(),
    required int totalMinor,
    this.discountMinor = const Value.absent(),
    this.vatMinor = const Value.absent(),
    this.vatRate = const Value.absent(),
    this.currency = const Value.absent(),
    this.paymentType = const Value.absent(),
    required String sourceUrl,
    required String dedupKey,
    this.status = const Value.absent(),
    this.needsReview = const Value.absent(),
    this.edited = const Value.absent(),
    this.note = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.nextRetryAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.debugRaw = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : dateTimeUtc = Value(dateTimeUtc),
       totalMinor = Value(totalMinor),
       sourceUrl = Value(sourceUrl),
       dedupKey = Value(dedupKey);
  static Insertable<ReceiptRow> custom({
    Expression<int>? id,
    Expression<int>? storeId,
    Expression<String>? ofdName,
    Expression<String>? kkmRegNumber,
    Expression<String>? kkmSerial,
    Expression<String>? fiscalSign,
    Expression<String>? receiptNumber,
    Expression<DateTime>? dateTimeUtc,
    Expression<int>? tzOffsetMin,
    Expression<int>? totalMinor,
    Expression<int>? discountMinor,
    Expression<int>? vatMinor,
    Expression<double>? vatRate,
    Expression<String>? currency,
    Expression<String>? paymentType,
    Expression<String>? sourceUrl,
    Expression<String>? dedupKey,
    Expression<String>? status,
    Expression<bool>? needsReview,
    Expression<bool>? edited,
    Expression<String>? note,
    Expression<int>? categoryId,
    Expression<int>? retryCount,
    Expression<DateTime>? nextRetryAt,
    Expression<String>? lastError,
    Expression<String>? debugRaw,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (storeId != null) 'store_id': storeId,
      if (ofdName != null) 'ofd_name': ofdName,
      if (kkmRegNumber != null) 'kkm_reg_number': kkmRegNumber,
      if (kkmSerial != null) 'kkm_serial': kkmSerial,
      if (fiscalSign != null) 'fiscal_sign': fiscalSign,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (dateTimeUtc != null) 'date_time_utc': dateTimeUtc,
      if (tzOffsetMin != null) 'tz_offset_min': tzOffsetMin,
      if (totalMinor != null) 'total_minor': totalMinor,
      if (discountMinor != null) 'discount_minor': discountMinor,
      if (vatMinor != null) 'vat_minor': vatMinor,
      if (vatRate != null) 'vat_rate': vatRate,
      if (currency != null) 'currency': currency,
      if (paymentType != null) 'payment_type': paymentType,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (dedupKey != null) 'dedup_key': dedupKey,
      if (status != null) 'status': status,
      if (needsReview != null) 'needs_review': needsReview,
      if (edited != null) 'edited': edited,
      if (note != null) 'note': note,
      if (categoryId != null) 'category_id': categoryId,
      if (retryCount != null) 'retry_count': retryCount,
      if (nextRetryAt != null) 'next_retry_at': nextRetryAt,
      if (lastError != null) 'last_error': lastError,
      if (debugRaw != null) 'debug_raw': debugRaw,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ReceiptsCompanion copyWith({
    Value<int>? id,
    Value<int?>? storeId,
    Value<String?>? ofdName,
    Value<String?>? kkmRegNumber,
    Value<String?>? kkmSerial,
    Value<String?>? fiscalSign,
    Value<String?>? receiptNumber,
    Value<DateTime>? dateTimeUtc,
    Value<int?>? tzOffsetMin,
    Value<int>? totalMinor,
    Value<int?>? discountMinor,
    Value<int?>? vatMinor,
    Value<double?>? vatRate,
    Value<String>? currency,
    Value<String?>? paymentType,
    Value<String>? sourceUrl,
    Value<String>? dedupKey,
    Value<String>? status,
    Value<bool>? needsReview,
    Value<bool>? edited,
    Value<String?>? note,
    Value<int?>? categoryId,
    Value<int>? retryCount,
    Value<DateTime?>? nextRetryAt,
    Value<String?>? lastError,
    Value<String?>? debugRaw,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ReceiptsCompanion(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      ofdName: ofdName ?? this.ofdName,
      kkmRegNumber: kkmRegNumber ?? this.kkmRegNumber,
      kkmSerial: kkmSerial ?? this.kkmSerial,
      fiscalSign: fiscalSign ?? this.fiscalSign,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      dateTimeUtc: dateTimeUtc ?? this.dateTimeUtc,
      tzOffsetMin: tzOffsetMin ?? this.tzOffsetMin,
      totalMinor: totalMinor ?? this.totalMinor,
      discountMinor: discountMinor ?? this.discountMinor,
      vatMinor: vatMinor ?? this.vatMinor,
      vatRate: vatRate ?? this.vatRate,
      currency: currency ?? this.currency,
      paymentType: paymentType ?? this.paymentType,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      dedupKey: dedupKey ?? this.dedupKey,
      status: status ?? this.status,
      needsReview: needsReview ?? this.needsReview,
      edited: edited ?? this.edited,
      note: note ?? this.note,
      categoryId: categoryId ?? this.categoryId,
      retryCount: retryCount ?? this.retryCount,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
      lastError: lastError ?? this.lastError,
      debugRaw: debugRaw ?? this.debugRaw,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (storeId.present) {
      map['store_id'] = Variable<int>(storeId.value);
    }
    if (ofdName.present) {
      map['ofd_name'] = Variable<String>(ofdName.value);
    }
    if (kkmRegNumber.present) {
      map['kkm_reg_number'] = Variable<String>(kkmRegNumber.value);
    }
    if (kkmSerial.present) {
      map['kkm_serial'] = Variable<String>(kkmSerial.value);
    }
    if (fiscalSign.present) {
      map['fiscal_sign'] = Variable<String>(fiscalSign.value);
    }
    if (receiptNumber.present) {
      map['receipt_number'] = Variable<String>(receiptNumber.value);
    }
    if (dateTimeUtc.present) {
      map['date_time_utc'] = Variable<DateTime>(dateTimeUtc.value);
    }
    if (tzOffsetMin.present) {
      map['tz_offset_min'] = Variable<int>(tzOffsetMin.value);
    }
    if (totalMinor.present) {
      map['total_minor'] = Variable<int>(totalMinor.value);
    }
    if (discountMinor.present) {
      map['discount_minor'] = Variable<int>(discountMinor.value);
    }
    if (vatMinor.present) {
      map['vat_minor'] = Variable<int>(vatMinor.value);
    }
    if (vatRate.present) {
      map['vat_rate'] = Variable<double>(vatRate.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<String>(paymentType.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (dedupKey.present) {
      map['dedup_key'] = Variable<String>(dedupKey.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (needsReview.present) {
      map['needs_review'] = Variable<bool>(needsReview.value);
    }
    if (edited.present) {
      map['edited'] = Variable<bool>(edited.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (nextRetryAt.present) {
      map['next_retry_at'] = Variable<DateTime>(nextRetryAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (debugRaw.present) {
      map['debug_raw'] = Variable<String>(debugRaw.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('storeId: $storeId, ')
          ..write('ofdName: $ofdName, ')
          ..write('kkmRegNumber: $kkmRegNumber, ')
          ..write('kkmSerial: $kkmSerial, ')
          ..write('fiscalSign: $fiscalSign, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('dateTimeUtc: $dateTimeUtc, ')
          ..write('tzOffsetMin: $tzOffsetMin, ')
          ..write('totalMinor: $totalMinor, ')
          ..write('discountMinor: $discountMinor, ')
          ..write('vatMinor: $vatMinor, ')
          ..write('vatRate: $vatRate, ')
          ..write('currency: $currency, ')
          ..write('paymentType: $paymentType, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('dedupKey: $dedupKey, ')
          ..write('status: $status, ')
          ..write('needsReview: $needsReview, ')
          ..write('edited: $edited, ')
          ..write('note: $note, ')
          ..write('categoryId: $categoryId, ')
          ..write('retryCount: $retryCount, ')
          ..write('nextRetryAt: $nextRetryAt, ')
          ..write('lastError: $lastError, ')
          ..write('debugRaw: $debugRaw, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ReceiptItemsTable extends ReceiptItems
    with TableInfo<$ReceiptItemsTable, ReceiptItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReceiptItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _receiptIdMeta = const VerificationMeta(
    'receiptId',
  );
  @override
  late final GeneratedColumn<int> receiptId = GeneratedColumn<int>(
    'receipt_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES receipts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rawNameMeta = const VerificationMeta(
    'rawName',
  );
  @override
  late final GeneratedColumn<String> rawName = GeneratedColumn<String>(
    'raw_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ntinMeta = const VerificationMeta('ntin');
  @override
  late final GeneratedColumn<String> ntin = GeneratedColumn<String>(
    'ntin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitPriceMinorMeta = const VerificationMeta(
    'unitPriceMinor',
  );
  @override
  late final GeneratedColumn<int> unitPriceMinor = GeneratedColumn<int>(
    'unit_price_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sumMinorMeta = const VerificationMeta(
    'sumMinor',
  );
  @override
  late final GeneratedColumn<int> sumMinor = GeneratedColumn<int>(
    'sum_minor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountMinorMeta = const VerificationMeta(
    'discountMinor',
  );
  @override
  late final GeneratedColumn<int> discountMinor = GeneratedColumn<int>(
    'discount_minor',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE SET NULL',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    receiptId,
    position,
    name,
    rawName,
    barcode,
    ntin,
    quantity,
    unit,
    unitPriceMinor,
    sumMinor,
    discountMinor,
    categoryId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'receipt_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReceiptItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('receipt_id')) {
      context.handle(
        _receiptIdMeta,
        receiptId.isAcceptableOrUnknown(data['receipt_id']!, _receiptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_receiptIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('raw_name')) {
      context.handle(
        _rawNameMeta,
        rawName.isAcceptableOrUnknown(data['raw_name']!, _rawNameMeta),
      );
    } else if (isInserting) {
      context.missing(_rawNameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('ntin')) {
      context.handle(
        _ntinMeta,
        ntin.isAcceptableOrUnknown(data['ntin']!, _ntinMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    if (data.containsKey('unit_price_minor')) {
      context.handle(
        _unitPriceMinorMeta,
        unitPriceMinor.isAcceptableOrUnknown(
          data['unit_price_minor']!,
          _unitPriceMinorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMinorMeta);
    }
    if (data.containsKey('sum_minor')) {
      context.handle(
        _sumMinorMeta,
        sumMinor.isAcceptableOrUnknown(data['sum_minor']!, _sumMinorMeta),
      );
    } else if (isInserting) {
      context.missing(_sumMinorMeta);
    }
    if (data.containsKey('discount_minor')) {
      context.handle(
        _discountMinorMeta,
        discountMinor.isAcceptableOrUnknown(
          data['discount_minor']!,
          _discountMinorMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReceiptItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReceiptItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      receiptId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}receipt_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rawName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}raw_name'],
      )!,
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      ntin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ntin'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
      unitPriceMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price_minor'],
      )!,
      sumMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sum_minor'],
      )!,
      discountMinor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}discount_minor'],
      ),
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      ),
    );
  }

  @override
  $ReceiptItemsTable createAlias(String alias) {
    return $ReceiptItemsTable(attachedDatabase, alias);
  }
}

class ReceiptItemRow extends DataClass implements Insertable<ReceiptItemRow> {
  final int id;
  final int receiptId;
  final int position;
  final String name;
  final String rawName;
  final String? barcode;
  final String? ntin;
  final double quantity;
  final String? unit;
  final int unitPriceMinor;
  final int sumMinor;
  final int? discountMinor;
  final int? categoryId;
  const ReceiptItemRow({
    required this.id,
    required this.receiptId,
    required this.position,
    required this.name,
    required this.rawName,
    this.barcode,
    this.ntin,
    required this.quantity,
    this.unit,
    required this.unitPriceMinor,
    required this.sumMinor,
    this.discountMinor,
    this.categoryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['receipt_id'] = Variable<int>(receiptId);
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    map['raw_name'] = Variable<String>(rawName);
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    if (!nullToAbsent || ntin != null) {
      map['ntin'] = Variable<String>(ntin);
    }
    map['quantity'] = Variable<double>(quantity);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    map['unit_price_minor'] = Variable<int>(unitPriceMinor);
    map['sum_minor'] = Variable<int>(sumMinor);
    if (!nullToAbsent || discountMinor != null) {
      map['discount_minor'] = Variable<int>(discountMinor);
    }
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<int>(categoryId);
    }
    return map;
  }

  ReceiptItemsCompanion toCompanion(bool nullToAbsent) {
    return ReceiptItemsCompanion(
      id: Value(id),
      receiptId: Value(receiptId),
      position: Value(position),
      name: Value(name),
      rawName: Value(rawName),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      ntin: ntin == null && nullToAbsent ? const Value.absent() : Value(ntin),
      quantity: Value(quantity),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
      unitPriceMinor: Value(unitPriceMinor),
      sumMinor: Value(sumMinor),
      discountMinor: discountMinor == null && nullToAbsent
          ? const Value.absent()
          : Value(discountMinor),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
    );
  }

  factory ReceiptItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReceiptItemRow(
      id: serializer.fromJson<int>(json['id']),
      receiptId: serializer.fromJson<int>(json['receiptId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
      rawName: serializer.fromJson<String>(json['rawName']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      ntin: serializer.fromJson<String?>(json['ntin']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unit: serializer.fromJson<String?>(json['unit']),
      unitPriceMinor: serializer.fromJson<int>(json['unitPriceMinor']),
      sumMinor: serializer.fromJson<int>(json['sumMinor']),
      discountMinor: serializer.fromJson<int?>(json['discountMinor']),
      categoryId: serializer.fromJson<int?>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'receiptId': serializer.toJson<int>(receiptId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
      'rawName': serializer.toJson<String>(rawName),
      'barcode': serializer.toJson<String?>(barcode),
      'ntin': serializer.toJson<String?>(ntin),
      'quantity': serializer.toJson<double>(quantity),
      'unit': serializer.toJson<String?>(unit),
      'unitPriceMinor': serializer.toJson<int>(unitPriceMinor),
      'sumMinor': serializer.toJson<int>(sumMinor),
      'discountMinor': serializer.toJson<int?>(discountMinor),
      'categoryId': serializer.toJson<int?>(categoryId),
    };
  }

  ReceiptItemRow copyWith({
    int? id,
    int? receiptId,
    int? position,
    String? name,
    String? rawName,
    Value<String?> barcode = const Value.absent(),
    Value<String?> ntin = const Value.absent(),
    double? quantity,
    Value<String?> unit = const Value.absent(),
    int? unitPriceMinor,
    int? sumMinor,
    Value<int?> discountMinor = const Value.absent(),
    Value<int?> categoryId = const Value.absent(),
  }) => ReceiptItemRow(
    id: id ?? this.id,
    receiptId: receiptId ?? this.receiptId,
    position: position ?? this.position,
    name: name ?? this.name,
    rawName: rawName ?? this.rawName,
    barcode: barcode.present ? barcode.value : this.barcode,
    ntin: ntin.present ? ntin.value : this.ntin,
    quantity: quantity ?? this.quantity,
    unit: unit.present ? unit.value : this.unit,
    unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
    sumMinor: sumMinor ?? this.sumMinor,
    discountMinor: discountMinor.present
        ? discountMinor.value
        : this.discountMinor,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
  );
  ReceiptItemRow copyWithCompanion(ReceiptItemsCompanion data) {
    return ReceiptItemRow(
      id: data.id.present ? data.id.value : this.id,
      receiptId: data.receiptId.present ? data.receiptId.value : this.receiptId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
      rawName: data.rawName.present ? data.rawName.value : this.rawName,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      ntin: data.ntin.present ? data.ntin.value : this.ntin,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unit: data.unit.present ? data.unit.value : this.unit,
      unitPriceMinor: data.unitPriceMinor.present
          ? data.unitPriceMinor.value
          : this.unitPriceMinor,
      sumMinor: data.sumMinor.present ? data.sumMinor.value : this.sumMinor,
      discountMinor: data.discountMinor.present
          ? data.discountMinor.value
          : this.discountMinor,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptItemRow(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('rawName: $rawName, ')
          ..write('barcode: $barcode, ')
          ..write('ntin: $ntin, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('sumMinor: $sumMinor, ')
          ..write('discountMinor: $discountMinor, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    receiptId,
    position,
    name,
    rawName,
    barcode,
    ntin,
    quantity,
    unit,
    unitPriceMinor,
    sumMinor,
    discountMinor,
    categoryId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReceiptItemRow &&
          other.id == this.id &&
          other.receiptId == this.receiptId &&
          other.position == this.position &&
          other.name == this.name &&
          other.rawName == this.rawName &&
          other.barcode == this.barcode &&
          other.ntin == this.ntin &&
          other.quantity == this.quantity &&
          other.unit == this.unit &&
          other.unitPriceMinor == this.unitPriceMinor &&
          other.sumMinor == this.sumMinor &&
          other.discountMinor == this.discountMinor &&
          other.categoryId == this.categoryId);
}

class ReceiptItemsCompanion extends UpdateCompanion<ReceiptItemRow> {
  final Value<int> id;
  final Value<int> receiptId;
  final Value<int> position;
  final Value<String> name;
  final Value<String> rawName;
  final Value<String?> barcode;
  final Value<String?> ntin;
  final Value<double> quantity;
  final Value<String?> unit;
  final Value<int> unitPriceMinor;
  final Value<int> sumMinor;
  final Value<int?> discountMinor;
  final Value<int?> categoryId;
  const ReceiptItemsCompanion({
    this.id = const Value.absent(),
    this.receiptId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.rawName = const Value.absent(),
    this.barcode = const Value.absent(),
    this.ntin = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unit = const Value.absent(),
    this.unitPriceMinor = const Value.absent(),
    this.sumMinor = const Value.absent(),
    this.discountMinor = const Value.absent(),
    this.categoryId = const Value.absent(),
  });
  ReceiptItemsCompanion.insert({
    this.id = const Value.absent(),
    required int receiptId,
    required int position,
    required String name,
    required String rawName,
    this.barcode = const Value.absent(),
    this.ntin = const Value.absent(),
    required double quantity,
    this.unit = const Value.absent(),
    required int unitPriceMinor,
    required int sumMinor,
    this.discountMinor = const Value.absent(),
    this.categoryId = const Value.absent(),
  }) : receiptId = Value(receiptId),
       position = Value(position),
       name = Value(name),
       rawName = Value(rawName),
       quantity = Value(quantity),
       unitPriceMinor = Value(unitPriceMinor),
       sumMinor = Value(sumMinor);
  static Insertable<ReceiptItemRow> custom({
    Expression<int>? id,
    Expression<int>? receiptId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<String>? rawName,
    Expression<String>? barcode,
    Expression<String>? ntin,
    Expression<double>? quantity,
    Expression<String>? unit,
    Expression<int>? unitPriceMinor,
    Expression<int>? sumMinor,
    Expression<int>? discountMinor,
    Expression<int>? categoryId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (receiptId != null) 'receipt_id': receiptId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (rawName != null) 'raw_name': rawName,
      if (barcode != null) 'barcode': barcode,
      if (ntin != null) 'ntin': ntin,
      if (quantity != null) 'quantity': quantity,
      if (unit != null) 'unit': unit,
      if (unitPriceMinor != null) 'unit_price_minor': unitPriceMinor,
      if (sumMinor != null) 'sum_minor': sumMinor,
      if (discountMinor != null) 'discount_minor': discountMinor,
      if (categoryId != null) 'category_id': categoryId,
    });
  }

  ReceiptItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? receiptId,
    Value<int>? position,
    Value<String>? name,
    Value<String>? rawName,
    Value<String?>? barcode,
    Value<String?>? ntin,
    Value<double>? quantity,
    Value<String?>? unit,
    Value<int>? unitPriceMinor,
    Value<int>? sumMinor,
    Value<int?>? discountMinor,
    Value<int?>? categoryId,
  }) {
    return ReceiptItemsCompanion(
      id: id ?? this.id,
      receiptId: receiptId ?? this.receiptId,
      position: position ?? this.position,
      name: name ?? this.name,
      rawName: rawName ?? this.rawName,
      barcode: barcode ?? this.barcode,
      ntin: ntin ?? this.ntin,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      unitPriceMinor: unitPriceMinor ?? this.unitPriceMinor,
      sumMinor: sumMinor ?? this.sumMinor,
      discountMinor: discountMinor ?? this.discountMinor,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (receiptId.present) {
      map['receipt_id'] = Variable<int>(receiptId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rawName.present) {
      map['raw_name'] = Variable<String>(rawName.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (ntin.present) {
      map['ntin'] = Variable<String>(ntin.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (unitPriceMinor.present) {
      map['unit_price_minor'] = Variable<int>(unitPriceMinor.value);
    }
    if (sumMinor.present) {
      map['sum_minor'] = Variable<int>(sumMinor.value);
    }
    if (discountMinor.present) {
      map['discount_minor'] = Variable<int>(discountMinor.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReceiptItemsCompanion(')
          ..write('id: $id, ')
          ..write('receiptId: $receiptId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('rawName: $rawName, ')
          ..write('barcode: $barcode, ')
          ..write('ntin: $ntin, ')
          ..write('quantity: $quantity, ')
          ..write('unit: $unit, ')
          ..write('unitPriceMinor: $unitPriceMinor, ')
          ..write('sumMinor: $sumMinor, ')
          ..write('discountMinor: $discountMinor, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }
}

class $CategoryRulesTable extends CategoryRules
    with TableInfo<$CategoryRulesTable, CategoryRuleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoryRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    check: () => kind.isIn(const ['keyword', 'barcode']),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _patternMeta = const VerificationMeta(
    'pattern',
  );
  @override
  late final GeneratedColumn<String> pattern = GeneratedColumn<String>(
    'pattern',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES categories (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _isUserMeta = const VerificationMeta('isUser');
  @override
  late final GeneratedColumn<bool> isUser = GeneratedColumn<bool>(
    'is_user',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_user" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [id, kind, pattern, categoryId, isUser];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'category_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRuleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('pattern')) {
      context.handle(
        _patternMeta,
        pattern.isAcceptableOrUnknown(data['pattern']!, _patternMeta),
      );
    } else if (isInserting) {
      context.missing(_patternMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('is_user')) {
      context.handle(
        _isUserMeta,
        isUser.isAcceptableOrUnknown(data['is_user']!, _isUserMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {kind, pattern, isUser},
  ];
  @override
  CategoryRuleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRuleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      pattern: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pattern'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}category_id'],
      )!,
      isUser: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_user'],
      )!,
    );
  }

  @override
  $CategoryRulesTable createAlias(String alias) {
    return $CategoryRulesTable(attachedDatabase, alias);
  }
}

class CategoryRuleRow extends DataClass implements Insertable<CategoryRuleRow> {
  final int id;
  final String kind;
  final String pattern;
  final int categoryId;
  final bool isUser;
  const CategoryRuleRow({
    required this.id,
    required this.kind,
    required this.pattern,
    required this.categoryId,
    required this.isUser,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['pattern'] = Variable<String>(pattern);
    map['category_id'] = Variable<int>(categoryId);
    map['is_user'] = Variable<bool>(isUser);
    return map;
  }

  CategoryRulesCompanion toCompanion(bool nullToAbsent) {
    return CategoryRulesCompanion(
      id: Value(id),
      kind: Value(kind),
      pattern: Value(pattern),
      categoryId: Value(categoryId),
      isUser: Value(isUser),
    );
  }

  factory CategoryRuleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRuleRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      pattern: serializer.fromJson<String>(json['pattern']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      isUser: serializer.fromJson<bool>(json['isUser']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'pattern': serializer.toJson<String>(pattern),
      'categoryId': serializer.toJson<int>(categoryId),
      'isUser': serializer.toJson<bool>(isUser),
    };
  }

  CategoryRuleRow copyWith({
    int? id,
    String? kind,
    String? pattern,
    int? categoryId,
    bool? isUser,
  }) => CategoryRuleRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    pattern: pattern ?? this.pattern,
    categoryId: categoryId ?? this.categoryId,
    isUser: isUser ?? this.isUser,
  );
  CategoryRuleRow copyWithCompanion(CategoryRulesCompanion data) {
    return CategoryRuleRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      pattern: data.pattern.present ? data.pattern.value : this.pattern,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      isUser: data.isUser.present ? data.isUser.value : this.isUser,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRuleRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('pattern: $pattern, ')
          ..write('categoryId: $categoryId, ')
          ..write('isUser: $isUser')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, kind, pattern, categoryId, isUser);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRuleRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.pattern == this.pattern &&
          other.categoryId == this.categoryId &&
          other.isUser == this.isUser);
}

class CategoryRulesCompanion extends UpdateCompanion<CategoryRuleRow> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> pattern;
  final Value<int> categoryId;
  final Value<bool> isUser;
  const CategoryRulesCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.pattern = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isUser = const Value.absent(),
  });
  CategoryRulesCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String pattern,
    required int categoryId,
    this.isUser = const Value.absent(),
  }) : kind = Value(kind),
       pattern = Value(pattern),
       categoryId = Value(categoryId);
  static Insertable<CategoryRuleRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? pattern,
    Expression<int>? categoryId,
    Expression<bool>? isUser,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (pattern != null) 'pattern': pattern,
      if (categoryId != null) 'category_id': categoryId,
      if (isUser != null) 'is_user': isUser,
    });
  }

  CategoryRulesCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? pattern,
    Value<int>? categoryId,
    Value<bool>? isUser,
  }) {
    return CategoryRulesCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      pattern: pattern ?? this.pattern,
      categoryId: categoryId ?? this.categoryId,
      isUser: isUser ?? this.isUser,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (pattern.present) {
      map['pattern'] = Variable<String>(pattern.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<int>(categoryId.value);
    }
    if (isUser.present) {
      map['is_user'] = Variable<bool>(isUser.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRulesCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('pattern: $pattern, ')
          ..write('categoryId: $categoryId, ')
          ..write('isUser: $isUser')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $StoresTable stores = $StoresTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ReceiptsTable receipts = $ReceiptsTable(this);
  late final $ReceiptItemsTable receiptItems = $ReceiptItemsTable(this);
  late final $CategoryRulesTable categoryRules = $CategoryRulesTable(this);
  late final Index receiptsDateTimeIdx = Index(
    'receipts_date_time_idx',
    'CREATE INDEX receipts_date_time_idx ON receipts (date_time_utc)',
  );
  late final Index receiptItemsReceiptIdx = Index(
    'receipt_items_receipt_idx',
    'CREATE INDEX receipt_items_receipt_idx ON receipt_items (receipt_id)',
  );
  late final Index receiptItemsCategoryIdx = Index(
    'receipt_items_category_idx',
    'CREATE INDEX receipt_items_category_idx ON receipt_items (category_id)',
  );
  late final Index receiptItemsBarcodeIdx = Index(
    'receipt_items_barcode_idx',
    'CREATE INDEX receipt_items_barcode_idx ON receipt_items (barcode)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    stores,
    categories,
    receipts,
    receiptItems,
    categoryRules,
    receiptsDateTimeIdx,
    receiptItemsReceiptIdx,
    receiptItemsCategoryIdx,
    receiptItemsBarcodeIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'stores',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('receipts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('receipts', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'receipts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('receipt_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('receipt_items', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'categories',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('category_rules', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$StoresTableCreateCompanionBuilder =
    StoresCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> bin,
      Value<String?> address,
    });
typedef $$StoresTableUpdateCompanionBuilder =
    StoresCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> bin,
      Value<String?> address,
    });

final class $$StoresTableReferences
    extends BaseReferences<_$AppDatabase, $StoresTable, StoreRow> {
  $$StoresTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReceiptsTable, List<ReceiptRow>>
  _receiptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.receipts,
    aliasName: 'stores__id__receipts__store_id',
  );

  $$ReceiptsTableProcessedTableManager get receiptsRefs {
    final manager = $$ReceiptsTableTableManager(
      $_db,
      $_db.receipts,
    ).filter((f) => f.storeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_receiptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StoresTableFilterComposer
    extends Composer<_$AppDatabase, $StoresTable> {
  $$StoresTableFilterComposer({
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

  ColumnFilters<String> get bin => $composableBuilder(
    column: $table.bin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> receiptsRefs(
    Expression<bool> Function($$ReceiptsTableFilterComposer f) f,
  ) {
    final $$ReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.storeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoresTableOrderingComposer
    extends Composer<_$AppDatabase, $StoresTable> {
  $$StoresTableOrderingComposer({
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

  ColumnOrderings<String> get bin => $composableBuilder(
    column: $table.bin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoresTableAnnotationComposer
    extends Composer<_$AppDatabase, $StoresTable> {
  $$StoresTableAnnotationComposer({
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

  GeneratedColumn<String> get bin =>
      $composableBuilder(column: $table.bin, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  Expression<T> receiptsRefs<T extends Object>(
    Expression<T> Function($$ReceiptsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.storeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableAnnotationComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StoresTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StoresTable,
          StoreRow,
          $$StoresTableFilterComposer,
          $$StoresTableOrderingComposer,
          $$StoresTableAnnotationComposer,
          $$StoresTableCreateCompanionBuilder,
          $$StoresTableUpdateCompanionBuilder,
          (StoreRow, $$StoresTableReferences),
          StoreRow,
          PrefetchHooks Function({bool receiptsRefs})
        > {
  $$StoresTableTableManager(_$AppDatabase db, $StoresTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoresTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoresTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoresTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> bin = const Value.absent(),
                Value<String?> address = const Value.absent(),
              }) => StoresCompanion(
                id: id,
                name: name,
                bin: bin,
                address: address,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> bin = const Value.absent(),
                Value<String?> address = const Value.absent(),
              }) => StoresCompanion.insert(
                id: id,
                name: name,
                bin: bin,
                address: address,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StoresTable, StoreRow>(table),
                  $$StoresTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({receiptsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (receiptsRefs) db.receipts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (receiptsRefs)
                    await $_getPrefetchedData<
                      StoreRow,
                      $StoresTable,
                      ReceiptRow
                    >(
                      currentTable: table,
                      referencedTable: $$StoresTableReferences
                          ._receiptsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$StoresTableReferences(db, table, p0).receiptsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.storeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$StoresTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StoresTable,
      StoreRow,
      $$StoresTableFilterComposer,
      $$StoresTableOrderingComposer,
      $$StoresTableAnnotationComposer,
      $$StoresTableCreateCompanionBuilder,
      $$StoresTableUpdateCompanionBuilder,
      (StoreRow, $$StoresTableReferences),
      StoreRow,
      PrefetchHooks Function({bool receiptsRefs})
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      required int color,
      required String icon,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> color,
      Value<String> icon,
      Value<bool> isBuiltIn,
      Value<int> sortOrder,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ReceiptsTable, List<ReceiptRow>>
  _receiptsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.receipts,
    aliasName: 'categories__id__receipts__category_id',
  );

  $$ReceiptsTableProcessedTableManager get receiptsRefs {
    final manager = $$ReceiptsTableTableManager(
      $_db,
      $_db.receipts,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_receiptsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReceiptItemsTable, List<ReceiptItemRow>>
  _receiptItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.receiptItems,
    aliasName: 'categories__id__receipt_items__category_id',
  );

  $$ReceiptItemsTableProcessedTableManager get receiptItemsRefs {
    final manager = $$ReceiptItemsTableTableManager(
      $_db,
      $_db.receiptItems,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_receiptItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CategoryRulesTable, List<CategoryRuleRow>>
  _categoryRulesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.categoryRules,
    aliasName: 'categories__id__category_rules__category_id',
  );

  $$CategoryRulesTableProcessedTableManager get categoryRulesRefs {
    final manager = $$CategoryRulesTableTableManager(
      $_db,
      $_db.categoryRules,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_categoryRulesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
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

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> receiptsRefs(
    Expression<bool> Function($$ReceiptsTableFilterComposer f) f,
  ) {
    final $$ReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> receiptItemsRefs(
    Expression<bool> Function($$ReceiptItemsTableFilterComposer f) f,
  ) {
    final $$ReceiptItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptItemsTableFilterComposer(
            $db: $db,
            $table: $db.receiptItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> categoryRulesRefs(
    Expression<bool> Function($$CategoryRulesTableFilterComposer f) f,
  ) {
    final $$CategoryRulesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryRules,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRulesTableFilterComposer(
            $db: $db,
            $table: $db.categoryRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
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

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
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

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> receiptsRefs<T extends Object>(
    Expression<T> Function($$ReceiptsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableAnnotationComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> receiptItemsRefs<T extends Object>(
    Expression<T> Function($$ReceiptItemsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptItems,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.receiptItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> categoryRulesRefs<T extends Object>(
    Expression<T> Function($$CategoryRulesTableAnnotationComposer a) f,
  ) {
    final $$CategoryRulesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.categoryRules,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoryRulesTableAnnotationComposer(
            $db: $db,
            $table: $db.categoryRules,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryRow, $$CategoriesTableReferences),
          CategoryRow,
          PrefetchHooks Function({
            bool receiptsRefs,
            bool receiptItemsRefs,
            bool categoryRulesRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                color: color,
                icon: icon,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int color,
                required String icon,
                Value<bool> isBuiltIn = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                color: color,
                icon: icon,
                isBuiltIn: isBuiltIn,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoriesTable, CategoryRow>(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                receiptsRefs = false,
                receiptItemsRefs = false,
                categoryRulesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (receiptsRefs) db.receipts,
                    if (receiptItemsRefs) db.receiptItems,
                    if (categoryRulesRefs) db.categoryRules,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (receiptsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          ReceiptRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._receiptsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (receiptItemsRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          ReceiptItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._receiptItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (categoryRulesRefs)
                        await $_getPrefetchedData<
                          CategoryRow,
                          $CategoriesTable,
                          CategoryRuleRow
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._categoryRulesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).categoryRulesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
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

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryRow, $$CategoriesTableReferences),
      CategoryRow,
      PrefetchHooks Function({
        bool receiptsRefs,
        bool receiptItemsRefs,
        bool categoryRulesRefs,
      })
    >;
typedef $$ReceiptsTableCreateCompanionBuilder =
    ReceiptsCompanion Function({
      Value<int> id,
      Value<int?> storeId,
      Value<String?> ofdName,
      Value<String?> kkmRegNumber,
      Value<String?> kkmSerial,
      Value<String?> fiscalSign,
      Value<String?> receiptNumber,
      required DateTime dateTimeUtc,
      Value<int?> tzOffsetMin,
      required int totalMinor,
      Value<int?> discountMinor,
      Value<int?> vatMinor,
      Value<double?> vatRate,
      Value<String> currency,
      Value<String?> paymentType,
      required String sourceUrl,
      required String dedupKey,
      Value<String> status,
      Value<bool> needsReview,
      Value<bool> edited,
      Value<String?> note,
      Value<int?> categoryId,
      Value<int> retryCount,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<String?> debugRaw,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ReceiptsTableUpdateCompanionBuilder =
    ReceiptsCompanion Function({
      Value<int> id,
      Value<int?> storeId,
      Value<String?> ofdName,
      Value<String?> kkmRegNumber,
      Value<String?> kkmSerial,
      Value<String?> fiscalSign,
      Value<String?> receiptNumber,
      Value<DateTime> dateTimeUtc,
      Value<int?> tzOffsetMin,
      Value<int> totalMinor,
      Value<int?> discountMinor,
      Value<int?> vatMinor,
      Value<double?> vatRate,
      Value<String> currency,
      Value<String?> paymentType,
      Value<String> sourceUrl,
      Value<String> dedupKey,
      Value<String> status,
      Value<bool> needsReview,
      Value<bool> edited,
      Value<String?> note,
      Value<int?> categoryId,
      Value<int> retryCount,
      Value<DateTime?> nextRetryAt,
      Value<String?> lastError,
      Value<String?> debugRaw,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ReceiptsTableReferences
    extends BaseReferences<_$AppDatabase, $ReceiptsTable, ReceiptRow> {
  $$ReceiptsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StoresTable _storeIdTable(_$AppDatabase db) =>
      db.stores.createAlias('receipts__store_id__stores__id');

  $$StoresTableProcessedTableManager? get storeId {
    final $_column = $_itemColumn<int>('store_id');
    if ($_column == null) return null;
    final manager = $$StoresTableTableManager(
      $_db,
      $_db.stores,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_storeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('receipts__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReceiptItemsTable, List<ReceiptItemRow>>
  _receiptItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.receiptItems,
    aliasName: 'receipts__id__receipt_items__receipt_id',
  );

  $$ReceiptItemsTableProcessedTableManager get receiptItemsRefs {
    final manager = $$ReceiptItemsTableTableManager(
      $_db,
      $_db.receiptItems,
    ).filter((f) => f.receiptId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_receiptItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableFilterComposer({
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

  ColumnFilters<String> get ofdName => $composableBuilder(
    column: $table.ofdName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kkmRegNumber => $composableBuilder(
    column: $table.kkmRegNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kkmSerial => $composableBuilder(
    column: $table.kkmSerial,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fiscalSign => $composableBuilder(
    column: $table.fiscalSign,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dateTimeUtc => $composableBuilder(
    column: $table.dateTimeUtc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tzOffsetMin => $composableBuilder(
    column: $table.tzOffsetMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountMinor => $composableBuilder(
    column: $table.discountMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vatMinor => $composableBuilder(
    column: $table.vatMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get vatRate => $composableBuilder(
    column: $table.vatRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupKey => $composableBuilder(
    column: $table.dedupKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get edited => $composableBuilder(
    column: $table.edited,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get debugRaw => $composableBuilder(
    column: $table.debugRaw,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StoresTableFilterComposer get storeId {
    final $$StoresTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storeId,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableFilterComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> receiptItemsRefs(
    Expression<bool> Function($$ReceiptItemsTableFilterComposer f) f,
  ) {
    final $$ReceiptItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptItems,
      getReferencedColumn: (t) => t.receiptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptItemsTableFilterComposer(
            $db: $db,
            $table: $db.receiptItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableOrderingComposer({
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

  ColumnOrderings<String> get ofdName => $composableBuilder(
    column: $table.ofdName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kkmRegNumber => $composableBuilder(
    column: $table.kkmRegNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kkmSerial => $composableBuilder(
    column: $table.kkmSerial,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiscalSign => $composableBuilder(
    column: $table.fiscalSign,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dateTimeUtc => $composableBuilder(
    column: $table.dateTimeUtc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tzOffsetMin => $composableBuilder(
    column: $table.tzOffsetMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountMinor => $composableBuilder(
    column: $table.discountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vatMinor => $composableBuilder(
    column: $table.vatMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get vatRate => $composableBuilder(
    column: $table.vatRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupKey => $composableBuilder(
    column: $table.dedupKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get edited => $composableBuilder(
    column: $table.edited,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get debugRaw => $composableBuilder(
    column: $table.debugRaw,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StoresTableOrderingComposer get storeId {
    final $$StoresTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storeId,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableOrderingComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptsTable> {
  $$ReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ofdName =>
      $composableBuilder(column: $table.ofdName, builder: (column) => column);

  GeneratedColumn<String> get kkmRegNumber => $composableBuilder(
    column: $table.kkmRegNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get kkmSerial =>
      $composableBuilder(column: $table.kkmSerial, builder: (column) => column);

  GeneratedColumn<String> get fiscalSign => $composableBuilder(
    column: $table.fiscalSign,
    builder: (column) => column,
  );

  GeneratedColumn<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dateTimeUtc => $composableBuilder(
    column: $table.dateTimeUtc,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tzOffsetMin => $composableBuilder(
    column: $table.tzOffsetMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalMinor => $composableBuilder(
    column: $table.totalMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get discountMinor => $composableBuilder(
    column: $table.discountMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vatMinor =>
      $composableBuilder(column: $table.vatMinor, builder: (column) => column);

  GeneratedColumn<double> get vatRate =>
      $composableBuilder(column: $table.vatRate, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get paymentType => $composableBuilder(
    column: $table.paymentType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get dedupKey =>
      $composableBuilder(column: $table.dedupKey, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get needsReview => $composableBuilder(
    column: $table.needsReview,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get edited =>
      $composableBuilder(column: $table.edited, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextRetryAt => $composableBuilder(
    column: $table.nextRetryAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<String> get debugRaw =>
      $composableBuilder(column: $table.debugRaw, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$StoresTableAnnotationComposer get storeId {
    final $$StoresTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.storeId,
      referencedTable: $db.stores,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StoresTableAnnotationComposer(
            $db: $db,
            $table: $db.stores,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> receiptItemsRefs<T extends Object>(
    Expression<T> Function($$ReceiptItemsTableAnnotationComposer a) f,
  ) {
    final $$ReceiptItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.receiptItems,
      getReferencedColumn: (t) => t.receiptId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.receiptItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptsTable,
          ReceiptRow,
          $$ReceiptsTableFilterComposer,
          $$ReceiptsTableOrderingComposer,
          $$ReceiptsTableAnnotationComposer,
          $$ReceiptsTableCreateCompanionBuilder,
          $$ReceiptsTableUpdateCompanionBuilder,
          (ReceiptRow, $$ReceiptsTableReferences),
          ReceiptRow,
          PrefetchHooks Function({
            bool storeId,
            bool categoryId,
            bool receiptItemsRefs,
          })
        > {
  $$ReceiptsTableTableManager(_$AppDatabase db, $ReceiptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> storeId = const Value.absent(),
                Value<String?> ofdName = const Value.absent(),
                Value<String?> kkmRegNumber = const Value.absent(),
                Value<String?> kkmSerial = const Value.absent(),
                Value<String?> fiscalSign = const Value.absent(),
                Value<String?> receiptNumber = const Value.absent(),
                Value<DateTime> dateTimeUtc = const Value.absent(),
                Value<int?> tzOffsetMin = const Value.absent(),
                Value<int> totalMinor = const Value.absent(),
                Value<int?> discountMinor = const Value.absent(),
                Value<int?> vatMinor = const Value.absent(),
                Value<double?> vatRate = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> paymentType = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String> dedupKey = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<bool> edited = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> debugRaw = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReceiptsCompanion(
                id: id,
                storeId: storeId,
                ofdName: ofdName,
                kkmRegNumber: kkmRegNumber,
                kkmSerial: kkmSerial,
                fiscalSign: fiscalSign,
                receiptNumber: receiptNumber,
                dateTimeUtc: dateTimeUtc,
                tzOffsetMin: tzOffsetMin,
                totalMinor: totalMinor,
                discountMinor: discountMinor,
                vatMinor: vatMinor,
                vatRate: vatRate,
                currency: currency,
                paymentType: paymentType,
                sourceUrl: sourceUrl,
                dedupKey: dedupKey,
                status: status,
                needsReview: needsReview,
                edited: edited,
                note: note,
                categoryId: categoryId,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                debugRaw: debugRaw,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> storeId = const Value.absent(),
                Value<String?> ofdName = const Value.absent(),
                Value<String?> kkmRegNumber = const Value.absent(),
                Value<String?> kkmSerial = const Value.absent(),
                Value<String?> fiscalSign = const Value.absent(),
                Value<String?> receiptNumber = const Value.absent(),
                required DateTime dateTimeUtc,
                Value<int?> tzOffsetMin = const Value.absent(),
                required int totalMinor,
                Value<int?> discountMinor = const Value.absent(),
                Value<int?> vatMinor = const Value.absent(),
                Value<double?> vatRate = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String?> paymentType = const Value.absent(),
                required String sourceUrl,
                required String dedupKey,
                Value<String> status = const Value.absent(),
                Value<bool> needsReview = const Value.absent(),
                Value<bool> edited = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> nextRetryAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<String?> debugRaw = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ReceiptsCompanion.insert(
                id: id,
                storeId: storeId,
                ofdName: ofdName,
                kkmRegNumber: kkmRegNumber,
                kkmSerial: kkmSerial,
                fiscalSign: fiscalSign,
                receiptNumber: receiptNumber,
                dateTimeUtc: dateTimeUtc,
                tzOffsetMin: tzOffsetMin,
                totalMinor: totalMinor,
                discountMinor: discountMinor,
                vatMinor: vatMinor,
                vatRate: vatRate,
                currency: currency,
                paymentType: paymentType,
                sourceUrl: sourceUrl,
                dedupKey: dedupKey,
                status: status,
                needsReview: needsReview,
                edited: edited,
                note: note,
                categoryId: categoryId,
                retryCount: retryCount,
                nextRetryAt: nextRetryAt,
                lastError: lastError,
                debugRaw: debugRaw,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReceiptsTable, ReceiptRow>(table),
                  $$ReceiptsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                storeId = false,
                categoryId = false,
                receiptItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (receiptItemsRefs) db.receiptItems,
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
                        if (storeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.storeId,
                                    referencedTable: $$ReceiptsTableReferences
                                        ._storeIdTable(db),
                                    referencedColumn: $$ReceiptsTableReferences
                                        ._storeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable: $$ReceiptsTableReferences
                                        ._categoryIdTable(db),
                                    referencedColumn: $$ReceiptsTableReferences
                                        ._categoryIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (receiptItemsRefs)
                        await $_getPrefetchedData<
                          ReceiptRow,
                          $ReceiptsTable,
                          ReceiptItemRow
                        >(
                          currentTable: table,
                          referencedTable: $$ReceiptsTableReferences
                              ._receiptItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ReceiptsTableReferences(
                                db,
                                table,
                                p0,
                              ).receiptItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.receiptId == item.id,
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

typedef $$ReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptsTable,
      ReceiptRow,
      $$ReceiptsTableFilterComposer,
      $$ReceiptsTableOrderingComposer,
      $$ReceiptsTableAnnotationComposer,
      $$ReceiptsTableCreateCompanionBuilder,
      $$ReceiptsTableUpdateCompanionBuilder,
      (ReceiptRow, $$ReceiptsTableReferences),
      ReceiptRow,
      PrefetchHooks Function({
        bool storeId,
        bool categoryId,
        bool receiptItemsRefs,
      })
    >;
typedef $$ReceiptItemsTableCreateCompanionBuilder =
    ReceiptItemsCompanion Function({
      Value<int> id,
      required int receiptId,
      required int position,
      required String name,
      required String rawName,
      Value<String?> barcode,
      Value<String?> ntin,
      required double quantity,
      Value<String?> unit,
      required int unitPriceMinor,
      required int sumMinor,
      Value<int?> discountMinor,
      Value<int?> categoryId,
    });
typedef $$ReceiptItemsTableUpdateCompanionBuilder =
    ReceiptItemsCompanion Function({
      Value<int> id,
      Value<int> receiptId,
      Value<int> position,
      Value<String> name,
      Value<String> rawName,
      Value<String?> barcode,
      Value<String?> ntin,
      Value<double> quantity,
      Value<String?> unit,
      Value<int> unitPriceMinor,
      Value<int> sumMinor,
      Value<int?> discountMinor,
      Value<int?> categoryId,
    });

final class $$ReceiptItemsTableReferences
    extends BaseReferences<_$AppDatabase, $ReceiptItemsTable, ReceiptItemRow> {
  $$ReceiptItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ReceiptsTable _receiptIdTable(_$AppDatabase db) =>
      db.receipts.createAlias('receipt_items__receipt_id__receipts__id');

  $$ReceiptsTableProcessedTableManager get receiptId {
    final $_column = $_itemColumn<int>('receipt_id')!;

    final manager = $$ReceiptsTableTableManager(
      $_db,
      $_db.receipts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_receiptIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('receipt_items__category_id__categories__id');

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<int>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReceiptItemsTableFilterComposer
    extends Composer<_$AppDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rawName => $composableBuilder(
    column: $table.rawName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ntin => $composableBuilder(
    column: $table.ntin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sumMinor => $composableBuilder(
    column: $table.sumMinor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get discountMinor => $composableBuilder(
    column: $table.discountMinor,
    builder: (column) => ColumnFilters(column),
  );

  $$ReceiptsTableFilterComposer get receiptId {
    final $$ReceiptsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableFilterComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rawName => $composableBuilder(
    column: $table.rawName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ntin => $composableBuilder(
    column: $table.ntin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sumMinor => $composableBuilder(
    column: $table.sumMinor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get discountMinor => $composableBuilder(
    column: $table.discountMinor,
    builder: (column) => ColumnOrderings(column),
  );

  $$ReceiptsTableOrderingComposer get receiptId {
    final $$ReceiptsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableOrderingComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReceiptItemsTable> {
  $$ReceiptItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get rawName =>
      $composableBuilder(column: $table.rawName, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get ntin =>
      $composableBuilder(column: $table.ntin, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<int> get unitPriceMinor => $composableBuilder(
    column: $table.unitPriceMinor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sumMinor =>
      $composableBuilder(column: $table.sumMinor, builder: (column) => column);

  GeneratedColumn<int> get discountMinor => $composableBuilder(
    column: $table.discountMinor,
    builder: (column) => column,
  );

  $$ReceiptsTableAnnotationComposer get receiptId {
    final $$ReceiptsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.receiptId,
      referencedTable: $db.receipts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReceiptsTableAnnotationComposer(
            $db: $db,
            $table: $db.receipts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReceiptItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReceiptItemsTable,
          ReceiptItemRow,
          $$ReceiptItemsTableFilterComposer,
          $$ReceiptItemsTableOrderingComposer,
          $$ReceiptItemsTableAnnotationComposer,
          $$ReceiptItemsTableCreateCompanionBuilder,
          $$ReceiptItemsTableUpdateCompanionBuilder,
          (ReceiptItemRow, $$ReceiptItemsTableReferences),
          ReceiptItemRow,
          PrefetchHooks Function({bool receiptId, bool categoryId})
        > {
  $$ReceiptItemsTableTableManager(_$AppDatabase db, $ReceiptItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReceiptItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReceiptItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReceiptItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> receiptId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> rawName = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String?> ntin = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int> unitPriceMinor = const Value.absent(),
                Value<int> sumMinor = const Value.absent(),
                Value<int?> discountMinor = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
              }) => ReceiptItemsCompanion(
                id: id,
                receiptId: receiptId,
                position: position,
                name: name,
                rawName: rawName,
                barcode: barcode,
                ntin: ntin,
                quantity: quantity,
                unit: unit,
                unitPriceMinor: unitPriceMinor,
                sumMinor: sumMinor,
                discountMinor: discountMinor,
                categoryId: categoryId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int receiptId,
                required int position,
                required String name,
                required String rawName,
                Value<String?> barcode = const Value.absent(),
                Value<String?> ntin = const Value.absent(),
                required double quantity,
                Value<String?> unit = const Value.absent(),
                required int unitPriceMinor,
                required int sumMinor,
                Value<int?> discountMinor = const Value.absent(),
                Value<int?> categoryId = const Value.absent(),
              }) => ReceiptItemsCompanion.insert(
                id: id,
                receiptId: receiptId,
                position: position,
                name: name,
                rawName: rawName,
                barcode: barcode,
                ntin: ntin,
                quantity: quantity,
                unit: unit,
                unitPriceMinor: unitPriceMinor,
                sumMinor: sumMinor,
                discountMinor: discountMinor,
                categoryId: categoryId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReceiptItemsTable, ReceiptItemRow>(table),
                  $$ReceiptItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({receiptId = false, categoryId = false}) {
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
                    if (receiptId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.receiptId,
                                referencedTable: $$ReceiptItemsTableReferences
                                    ._receiptIdTable(db),
                                referencedColumn: $$ReceiptItemsTableReferences
                                    ._receiptIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$ReceiptItemsTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$ReceiptItemsTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$ReceiptItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReceiptItemsTable,
      ReceiptItemRow,
      $$ReceiptItemsTableFilterComposer,
      $$ReceiptItemsTableOrderingComposer,
      $$ReceiptItemsTableAnnotationComposer,
      $$ReceiptItemsTableCreateCompanionBuilder,
      $$ReceiptItemsTableUpdateCompanionBuilder,
      (ReceiptItemRow, $$ReceiptItemsTableReferences),
      ReceiptItemRow,
      PrefetchHooks Function({bool receiptId, bool categoryId})
    >;
typedef $$CategoryRulesTableCreateCompanionBuilder =
    CategoryRulesCompanion Function({
      Value<int> id,
      required String kind,
      required String pattern,
      required int categoryId,
      Value<bool> isUser,
    });
typedef $$CategoryRulesTableUpdateCompanionBuilder =
    CategoryRulesCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> pattern,
      Value<int> categoryId,
      Value<bool> isUser,
    });

final class $$CategoryRulesTableReferences
    extends
        BaseReferences<_$AppDatabase, $CategoryRulesTable, CategoryRuleRow> {
  $$CategoryRulesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('category_rules__category_id__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('category_id')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CategoryRulesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUser => $composableBuilder(
    column: $table.isUser,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pattern => $composableBuilder(
    column: $table.pattern,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUser => $composableBuilder(
    column: $table.isUser,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoryRulesTable> {
  $$CategoryRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get pattern =>
      $composableBuilder(column: $table.pattern, builder: (column) => column);

  GeneratedColumn<bool> get isUser =>
      $composableBuilder(column: $table.isUser, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CategoryRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoryRulesTable,
          CategoryRuleRow,
          $$CategoryRulesTableFilterComposer,
          $$CategoryRulesTableOrderingComposer,
          $$CategoryRulesTableAnnotationComposer,
          $$CategoryRulesTableCreateCompanionBuilder,
          $$CategoryRulesTableUpdateCompanionBuilder,
          (CategoryRuleRow, $$CategoryRulesTableReferences),
          CategoryRuleRow,
          PrefetchHooks Function({bool categoryId})
        > {
  $$CategoryRulesTableTableManager(_$AppDatabase db, $CategoryRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoryRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoryRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoryRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> pattern = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<bool> isUser = const Value.absent(),
              }) => CategoryRulesCompanion(
                id: id,
                kind: kind,
                pattern: pattern,
                categoryId: categoryId,
                isUser: isUser,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String pattern,
                required int categoryId,
                Value<bool> isUser = const Value.absent(),
              }) => CategoryRulesCompanion.insert(
                id: id,
                kind: kind,
                pattern: pattern,
                categoryId: categoryId,
                isUser: isUser,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CategoryRulesTable, CategoryRuleRow>(table),
                  $$CategoryRulesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
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
                    if (categoryId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.categoryId,
                                referencedTable: $$CategoryRulesTableReferences
                                    ._categoryIdTable(db),
                                referencedColumn: $$CategoryRulesTableReferences
                                    ._categoryIdTable(db)
                                    .id,
                              )
                              as T;
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

typedef $$CategoryRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoryRulesTable,
      CategoryRuleRow,
      $$CategoryRulesTableFilterComposer,
      $$CategoryRulesTableOrderingComposer,
      $$CategoryRulesTableAnnotationComposer,
      $$CategoryRulesTableCreateCompanionBuilder,
      $$CategoryRulesTableUpdateCompanionBuilder,
      (CategoryRuleRow, $$CategoryRulesTableReferences),
      CategoryRuleRow,
      PrefetchHooks Function({bool categoryId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$StoresTableTableManager get stores =>
      $$StoresTableTableManager(_db, _db.stores);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ReceiptsTableTableManager get receipts =>
      $$ReceiptsTableTableManager(_db, _db.receipts);
  $$ReceiptItemsTableTableManager get receiptItems =>
      $$ReceiptItemsTableTableManager(_db, _db.receiptItems);
  $$CategoryRulesTableTableManager get categoryRules =>
      $$CategoryRulesTableTableManager(_db, _db.categoryRules);
}
