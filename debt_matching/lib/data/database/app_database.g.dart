// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $HolidayConfigsTable extends HolidayConfigs
    with TableInfo<$HolidayConfigsTable, HolidayConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HolidayConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, date, name, description];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'holiday_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<HolidayConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HolidayConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HolidayConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $HolidayConfigsTable createAlias(String alias) {
    return $HolidayConfigsTable(attachedDatabase, alias);
  }
}

class HolidayConfig extends DataClass implements Insertable<HolidayConfig> {
  final String id;
  final DateTime date;
  final String? name;
  final String? description;
  const HolidayConfig({
    required this.id,
    required this.date,
    this.name,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  HolidayConfigsCompanion toCompanion(bool nullToAbsent) {
    return HolidayConfigsCompanion(
      id: Value(id),
      date: Value(date),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
    );
  }

  factory HolidayConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HolidayConfig(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      name: serializer.fromJson<String?>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'name': serializer.toJson<String?>(name),
      'description': serializer.toJson<String?>(description),
    };
  }

  HolidayConfig copyWith({
    String? id,
    DateTime? date,
    Value<String?> name = const Value.absent(),
    Value<String?> description = const Value.absent(),
  }) => HolidayConfig(
    id: id ?? this.id,
    date: date ?? this.date,
    name: name.present ? name.value : this.name,
    description: description.present ? description.value : this.description,
  );
  HolidayConfig copyWithCompanion(HolidayConfigsCompanion data) {
    return HolidayConfig(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HolidayConfig(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, name, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HolidayConfig &&
          other.id == this.id &&
          other.date == this.date &&
          other.name == this.name &&
          other.description == this.description);
}

class HolidayConfigsCompanion extends UpdateCompanion<HolidayConfig> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String?> name;
  final Value<String?> description;
  final Value<int> rowid;
  const HolidayConfigsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HolidayConfigsCompanion.insert({
    required String id,
    required DateTime date,
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date);
  static Insertable<HolidayConfig> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? name,
    Expression<String>? description,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HolidayConfigsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? date,
    Value<String?>? name,
    Value<String?>? description,
    Value<int>? rowid,
  }) {
    return HolidayConfigsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      name: name ?? this.name,
      description: description ?? this.description,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HolidayConfigsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LevelConfigsTable extends LevelConfigs
    with TableInfo<$LevelConfigsTable, LevelConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LevelConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seasonalCodeMeta = const VerificationMeta(
    'seasonalCode',
  );
  @override
  late final GeneratedColumn<String> seasonalCode = GeneratedColumn<String>(
    'seasonal_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salesMethodMeta = const VerificationMeta(
    'salesMethod',
  );
  @override
  late final GeneratedColumn<String> salesMethod = GeneratedColumn<String>(
    'sales_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentPeriodMeta = const VerificationMeta(
    'paymentPeriod',
  );
  @override
  late final GeneratedColumn<int> paymentPeriod = GeneratedColumn<int>(
    'payment_period',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentPeriod1Meta = const VerificationMeta(
    'paymentPeriod1',
  );
  @override
  late final GeneratedColumn<int> paymentPeriod1 = GeneratedColumn<int>(
    'payment_period1',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentPeriod2Meta = const VerificationMeta(
    'paymentPeriod2',
  );
  @override
  late final GeneratedColumn<int> paymentPeriod2 = GeneratedColumn<int>(
    'payment_period2',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentPeriod3Meta = const VerificationMeta(
    'paymentPeriod3',
  );
  @override
  late final GeneratedColumn<int> paymentPeriod3 = GeneratedColumn<int>(
    'payment_period3',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDueDate1Meta = const VerificationMeta(
    'paymentDueDate1',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDueDate1 =
      GeneratedColumn<DateTime>(
        'payment_due_date1',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _paymentDueDate2Meta = const VerificationMeta(
    'paymentDueDate2',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDueDate2 =
      GeneratedColumn<DateTime>(
        'payment_due_date2',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _paymentDueDate3Meta = const VerificationMeta(
    'paymentDueDate3',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDueDate3 =
      GeneratedColumn<DateTime>(
        'payment_due_date3',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seasonalCode,
    salesMethod,
    paymentPeriod,
    paymentPeriod1,
    paymentPeriod2,
    paymentPeriod3,
    paymentDueDate1,
    paymentDueDate2,
    paymentDueDate3,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'level_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<LevelConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('seasonal_code')) {
      context.handle(
        _seasonalCodeMeta,
        seasonalCode.isAcceptableOrUnknown(
          data['seasonal_code']!,
          _seasonalCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seasonalCodeMeta);
    }
    if (data.containsKey('sales_method')) {
      context.handle(
        _salesMethodMeta,
        salesMethod.isAcceptableOrUnknown(
          data['sales_method']!,
          _salesMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_salesMethodMeta);
    }
    if (data.containsKey('payment_period')) {
      context.handle(
        _paymentPeriodMeta,
        paymentPeriod.isAcceptableOrUnknown(
          data['payment_period']!,
          _paymentPeriodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentPeriodMeta);
    }
    if (data.containsKey('payment_period1')) {
      context.handle(
        _paymentPeriod1Meta,
        paymentPeriod1.isAcceptableOrUnknown(
          data['payment_period1']!,
          _paymentPeriod1Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentPeriod1Meta);
    }
    if (data.containsKey('payment_period2')) {
      context.handle(
        _paymentPeriod2Meta,
        paymentPeriod2.isAcceptableOrUnknown(
          data['payment_period2']!,
          _paymentPeriod2Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentPeriod2Meta);
    }
    if (data.containsKey('payment_period3')) {
      context.handle(
        _paymentPeriod3Meta,
        paymentPeriod3.isAcceptableOrUnknown(
          data['payment_period3']!,
          _paymentPeriod3Meta,
        ),
      );
    } else if (isInserting) {
      context.missing(_paymentPeriod3Meta);
    }
    if (data.containsKey('payment_due_date1')) {
      context.handle(
        _paymentDueDate1Meta,
        paymentDueDate1.isAcceptableOrUnknown(
          data['payment_due_date1']!,
          _paymentDueDate1Meta,
        ),
      );
    }
    if (data.containsKey('payment_due_date2')) {
      context.handle(
        _paymentDueDate2Meta,
        paymentDueDate2.isAcceptableOrUnknown(
          data['payment_due_date2']!,
          _paymentDueDate2Meta,
        ),
      );
    }
    if (data.containsKey('payment_due_date3')) {
      context.handle(
        _paymentDueDate3Meta,
        paymentDueDate3.isAcceptableOrUnknown(
          data['payment_due_date3']!,
          _paymentDueDate3Meta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LevelConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LevelConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      seasonalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seasonal_code'],
      )!,
      salesMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sales_method'],
      )!,
      paymentPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_period'],
      )!,
      paymentPeriod1: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_period1'],
      )!,
      paymentPeriod2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_period2'],
      )!,
      paymentPeriod3: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_period3'],
      )!,
      paymentDueDate1: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_due_date1'],
      ),
      paymentDueDate2: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_due_date2'],
      ),
      paymentDueDate3: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_due_date3'],
      ),
    );
  }

  @override
  $LevelConfigsTable createAlias(String alias) {
    return $LevelConfigsTable(attachedDatabase, alias);
  }
}

class LevelConfig extends DataClass implements Insertable<LevelConfig> {
  final String id;
  final String seasonalCode;
  final String salesMethod;
  final int paymentPeriod;
  final int paymentPeriod1;
  final int paymentPeriod2;
  final int paymentPeriod3;
  final DateTime? paymentDueDate1;
  final DateTime? paymentDueDate2;
  final DateTime? paymentDueDate3;
  const LevelConfig({
    required this.id,
    required this.seasonalCode,
    required this.salesMethod,
    required this.paymentPeriod,
    required this.paymentPeriod1,
    required this.paymentPeriod2,
    required this.paymentPeriod3,
    this.paymentDueDate1,
    this.paymentDueDate2,
    this.paymentDueDate3,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['seasonal_code'] = Variable<String>(seasonalCode);
    map['sales_method'] = Variable<String>(salesMethod);
    map['payment_period'] = Variable<int>(paymentPeriod);
    map['payment_period1'] = Variable<int>(paymentPeriod1);
    map['payment_period2'] = Variable<int>(paymentPeriod2);
    map['payment_period3'] = Variable<int>(paymentPeriod3);
    if (!nullToAbsent || paymentDueDate1 != null) {
      map['payment_due_date1'] = Variable<DateTime>(paymentDueDate1);
    }
    if (!nullToAbsent || paymentDueDate2 != null) {
      map['payment_due_date2'] = Variable<DateTime>(paymentDueDate2);
    }
    if (!nullToAbsent || paymentDueDate3 != null) {
      map['payment_due_date3'] = Variable<DateTime>(paymentDueDate3);
    }
    return map;
  }

  LevelConfigsCompanion toCompanion(bool nullToAbsent) {
    return LevelConfigsCompanion(
      id: Value(id),
      seasonalCode: Value(seasonalCode),
      salesMethod: Value(salesMethod),
      paymentPeriod: Value(paymentPeriod),
      paymentPeriod1: Value(paymentPeriod1),
      paymentPeriod2: Value(paymentPeriod2),
      paymentPeriod3: Value(paymentPeriod3),
      paymentDueDate1: paymentDueDate1 == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDueDate1),
      paymentDueDate2: paymentDueDate2 == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDueDate2),
      paymentDueDate3: paymentDueDate3 == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDueDate3),
    );
  }

  factory LevelConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LevelConfig(
      id: serializer.fromJson<String>(json['id']),
      seasonalCode: serializer.fromJson<String>(json['seasonalCode']),
      salesMethod: serializer.fromJson<String>(json['salesMethod']),
      paymentPeriod: serializer.fromJson<int>(json['paymentPeriod']),
      paymentPeriod1: serializer.fromJson<int>(json['paymentPeriod1']),
      paymentPeriod2: serializer.fromJson<int>(json['paymentPeriod2']),
      paymentPeriod3: serializer.fromJson<int>(json['paymentPeriod3']),
      paymentDueDate1: serializer.fromJson<DateTime?>(json['paymentDueDate1']),
      paymentDueDate2: serializer.fromJson<DateTime?>(json['paymentDueDate2']),
      paymentDueDate3: serializer.fromJson<DateTime?>(json['paymentDueDate3']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'seasonalCode': serializer.toJson<String>(seasonalCode),
      'salesMethod': serializer.toJson<String>(salesMethod),
      'paymentPeriod': serializer.toJson<int>(paymentPeriod),
      'paymentPeriod1': serializer.toJson<int>(paymentPeriod1),
      'paymentPeriod2': serializer.toJson<int>(paymentPeriod2),
      'paymentPeriod3': serializer.toJson<int>(paymentPeriod3),
      'paymentDueDate1': serializer.toJson<DateTime?>(paymentDueDate1),
      'paymentDueDate2': serializer.toJson<DateTime?>(paymentDueDate2),
      'paymentDueDate3': serializer.toJson<DateTime?>(paymentDueDate3),
    };
  }

  LevelConfig copyWith({
    String? id,
    String? seasonalCode,
    String? salesMethod,
    int? paymentPeriod,
    int? paymentPeriod1,
    int? paymentPeriod2,
    int? paymentPeriod3,
    Value<DateTime?> paymentDueDate1 = const Value.absent(),
    Value<DateTime?> paymentDueDate2 = const Value.absent(),
    Value<DateTime?> paymentDueDate3 = const Value.absent(),
  }) => LevelConfig(
    id: id ?? this.id,
    seasonalCode: seasonalCode ?? this.seasonalCode,
    salesMethod: salesMethod ?? this.salesMethod,
    paymentPeriod: paymentPeriod ?? this.paymentPeriod,
    paymentPeriod1: paymentPeriod1 ?? this.paymentPeriod1,
    paymentPeriod2: paymentPeriod2 ?? this.paymentPeriod2,
    paymentPeriod3: paymentPeriod3 ?? this.paymentPeriod3,
    paymentDueDate1: paymentDueDate1.present
        ? paymentDueDate1.value
        : this.paymentDueDate1,
    paymentDueDate2: paymentDueDate2.present
        ? paymentDueDate2.value
        : this.paymentDueDate2,
    paymentDueDate3: paymentDueDate3.present
        ? paymentDueDate3.value
        : this.paymentDueDate3,
  );
  LevelConfig copyWithCompanion(LevelConfigsCompanion data) {
    return LevelConfig(
      id: data.id.present ? data.id.value : this.id,
      seasonalCode: data.seasonalCode.present
          ? data.seasonalCode.value
          : this.seasonalCode,
      salesMethod: data.salesMethod.present
          ? data.salesMethod.value
          : this.salesMethod,
      paymentPeriod: data.paymentPeriod.present
          ? data.paymentPeriod.value
          : this.paymentPeriod,
      paymentPeriod1: data.paymentPeriod1.present
          ? data.paymentPeriod1.value
          : this.paymentPeriod1,
      paymentPeriod2: data.paymentPeriod2.present
          ? data.paymentPeriod2.value
          : this.paymentPeriod2,
      paymentPeriod3: data.paymentPeriod3.present
          ? data.paymentPeriod3.value
          : this.paymentPeriod3,
      paymentDueDate1: data.paymentDueDate1.present
          ? data.paymentDueDate1.value
          : this.paymentDueDate1,
      paymentDueDate2: data.paymentDueDate2.present
          ? data.paymentDueDate2.value
          : this.paymentDueDate2,
      paymentDueDate3: data.paymentDueDate3.present
          ? data.paymentDueDate3.value
          : this.paymentDueDate3,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LevelConfig(')
          ..write('id: $id, ')
          ..write('seasonalCode: $seasonalCode, ')
          ..write('salesMethod: $salesMethod, ')
          ..write('paymentPeriod: $paymentPeriod, ')
          ..write('paymentPeriod1: $paymentPeriod1, ')
          ..write('paymentPeriod2: $paymentPeriod2, ')
          ..write('paymentPeriod3: $paymentPeriod3, ')
          ..write('paymentDueDate1: $paymentDueDate1, ')
          ..write('paymentDueDate2: $paymentDueDate2, ')
          ..write('paymentDueDate3: $paymentDueDate3')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seasonalCode,
    salesMethod,
    paymentPeriod,
    paymentPeriod1,
    paymentPeriod2,
    paymentPeriod3,
    paymentDueDate1,
    paymentDueDate2,
    paymentDueDate3,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LevelConfig &&
          other.id == this.id &&
          other.seasonalCode == this.seasonalCode &&
          other.salesMethod == this.salesMethod &&
          other.paymentPeriod == this.paymentPeriod &&
          other.paymentPeriod1 == this.paymentPeriod1 &&
          other.paymentPeriod2 == this.paymentPeriod2 &&
          other.paymentPeriod3 == this.paymentPeriod3 &&
          other.paymentDueDate1 == this.paymentDueDate1 &&
          other.paymentDueDate2 == this.paymentDueDate2 &&
          other.paymentDueDate3 == this.paymentDueDate3);
}

class LevelConfigsCompanion extends UpdateCompanion<LevelConfig> {
  final Value<String> id;
  final Value<String> seasonalCode;
  final Value<String> salesMethod;
  final Value<int> paymentPeriod;
  final Value<int> paymentPeriod1;
  final Value<int> paymentPeriod2;
  final Value<int> paymentPeriod3;
  final Value<DateTime?> paymentDueDate1;
  final Value<DateTime?> paymentDueDate2;
  final Value<DateTime?> paymentDueDate3;
  final Value<int> rowid;
  const LevelConfigsCompanion({
    this.id = const Value.absent(),
    this.seasonalCode = const Value.absent(),
    this.salesMethod = const Value.absent(),
    this.paymentPeriod = const Value.absent(),
    this.paymentPeriod1 = const Value.absent(),
    this.paymentPeriod2 = const Value.absent(),
    this.paymentPeriod3 = const Value.absent(),
    this.paymentDueDate1 = const Value.absent(),
    this.paymentDueDate2 = const Value.absent(),
    this.paymentDueDate3 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LevelConfigsCompanion.insert({
    required String id,
    required String seasonalCode,
    required String salesMethod,
    required int paymentPeriod,
    required int paymentPeriod1,
    required int paymentPeriod2,
    required int paymentPeriod3,
    this.paymentDueDate1 = const Value.absent(),
    this.paymentDueDate2 = const Value.absent(),
    this.paymentDueDate3 = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seasonalCode = Value(seasonalCode),
       salesMethod = Value(salesMethod),
       paymentPeriod = Value(paymentPeriod),
       paymentPeriod1 = Value(paymentPeriod1),
       paymentPeriod2 = Value(paymentPeriod2),
       paymentPeriod3 = Value(paymentPeriod3);
  static Insertable<LevelConfig> custom({
    Expression<String>? id,
    Expression<String>? seasonalCode,
    Expression<String>? salesMethod,
    Expression<int>? paymentPeriod,
    Expression<int>? paymentPeriod1,
    Expression<int>? paymentPeriod2,
    Expression<int>? paymentPeriod3,
    Expression<DateTime>? paymentDueDate1,
    Expression<DateTime>? paymentDueDate2,
    Expression<DateTime>? paymentDueDate3,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seasonalCode != null) 'seasonal_code': seasonalCode,
      if (salesMethod != null) 'sales_method': salesMethod,
      if (paymentPeriod != null) 'payment_period': paymentPeriod,
      if (paymentPeriod1 != null) 'payment_period1': paymentPeriod1,
      if (paymentPeriod2 != null) 'payment_period2': paymentPeriod2,
      if (paymentPeriod3 != null) 'payment_period3': paymentPeriod3,
      if (paymentDueDate1 != null) 'payment_due_date1': paymentDueDate1,
      if (paymentDueDate2 != null) 'payment_due_date2': paymentDueDate2,
      if (paymentDueDate3 != null) 'payment_due_date3': paymentDueDate3,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LevelConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? seasonalCode,
    Value<String>? salesMethod,
    Value<int>? paymentPeriod,
    Value<int>? paymentPeriod1,
    Value<int>? paymentPeriod2,
    Value<int>? paymentPeriod3,
    Value<DateTime?>? paymentDueDate1,
    Value<DateTime?>? paymentDueDate2,
    Value<DateTime?>? paymentDueDate3,
    Value<int>? rowid,
  }) {
    return LevelConfigsCompanion(
      id: id ?? this.id,
      seasonalCode: seasonalCode ?? this.seasonalCode,
      salesMethod: salesMethod ?? this.salesMethod,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      paymentPeriod1: paymentPeriod1 ?? this.paymentPeriod1,
      paymentPeriod2: paymentPeriod2 ?? this.paymentPeriod2,
      paymentPeriod3: paymentPeriod3 ?? this.paymentPeriod3,
      paymentDueDate1: paymentDueDate1 ?? this.paymentDueDate1,
      paymentDueDate2: paymentDueDate2 ?? this.paymentDueDate2,
      paymentDueDate3: paymentDueDate3 ?? this.paymentDueDate3,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (seasonalCode.present) {
      map['seasonal_code'] = Variable<String>(seasonalCode.value);
    }
    if (salesMethod.present) {
      map['sales_method'] = Variable<String>(salesMethod.value);
    }
    if (paymentPeriod.present) {
      map['payment_period'] = Variable<int>(paymentPeriod.value);
    }
    if (paymentPeriod1.present) {
      map['payment_period1'] = Variable<int>(paymentPeriod1.value);
    }
    if (paymentPeriod2.present) {
      map['payment_period2'] = Variable<int>(paymentPeriod2.value);
    }
    if (paymentPeriod3.present) {
      map['payment_period3'] = Variable<int>(paymentPeriod3.value);
    }
    if (paymentDueDate1.present) {
      map['payment_due_date1'] = Variable<DateTime>(paymentDueDate1.value);
    }
    if (paymentDueDate2.present) {
      map['payment_due_date2'] = Variable<DateTime>(paymentDueDate2.value);
    }
    if (paymentDueDate3.present) {
      map['payment_due_date3'] = Variable<DateTime>(paymentDueDate3.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LevelConfigsCompanion(')
          ..write('id: $id, ')
          ..write('seasonalCode: $seasonalCode, ')
          ..write('salesMethod: $salesMethod, ')
          ..write('paymentPeriod: $paymentPeriod, ')
          ..write('paymentPeriod1: $paymentPeriod1, ')
          ..write('paymentPeriod2: $paymentPeriod2, ')
          ..write('paymentPeriod3: $paymentPeriod3, ')
          ..write('paymentDueDate1: $paymentDueDate1, ')
          ..write('paymentDueDate2: $paymentDueDate2, ')
          ..write('paymentDueDate3: $paymentDueDate3, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MainDatasTable extends MainDatas
    with TableInfo<$MainDatasTable, MainData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MainDatasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idxMeta = const VerificationMeta('idx');
  @override
  late final GeneratedColumn<int> idx = GeneratedColumn<int>(
    'idx',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentDateMeta = const VerificationMeta(
    'documentDate',
  );
  @override
  late final GeneratedColumn<DateTime> documentDate = GeneratedColumn<DateTime>(
    'document_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentNumberMeta = const VerificationMeta(
    'documentNumber',
  );
  @override
  late final GeneratedColumn<String> documentNumber = GeneratedColumn<String>(
    'document_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _correspondingAccountMeta =
      const VerificationMeta('correspondingAccount');
  @override
  late final GeneratedColumn<String> correspondingAccount =
      GeneratedColumn<String>(
        'corresponding_account',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _increaseMeta = const VerificationMeta(
    'increase',
  );
  @override
  late final GeneratedColumn<int> increase = GeneratedColumn<int>(
    'increase',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decreaseMeta = const VerificationMeta(
    'decrease',
  );
  @override
  late final GeneratedColumn<int> decrease = GeneratedColumn<int>(
    'decrease',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adjustIncreaseMeta = const VerificationMeta(
    'adjustIncrease',
  );
  @override
  late final GeneratedColumn<int> adjustIncrease = GeneratedColumn<int>(
    'adjust_increase',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adjustDecreaseMeta = const VerificationMeta(
    'adjustDecrease',
  );
  @override
  late final GeneratedColumn<int> adjustDecrease = GeneratedColumn<int>(
    'adjust_decrease',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endAmountMeta = const VerificationMeta(
    'endAmount',
  );
  @override
  late final GeneratedColumn<int> endAmount = GeneratedColumn<int>(
    'end_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonalCodeMeta = const VerificationMeta(
    'seasonalCode',
  );
  @override
  late final GeneratedColumn<String> seasonalCode = GeneratedColumn<String>(
    'seasonal_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentPeriodMeta = const VerificationMeta(
    'paymentPeriod',
  );
  @override
  late final GeneratedColumn<int> paymentPeriod = GeneratedColumn<int>(
    'payment_period',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerCodeMeta = const VerificationMeta(
    'customerCode',
  );
  @override
  late final GeneratedColumn<String> customerCode = GeneratedColumn<String>(
    'customer_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerNameMeta = const VerificationMeta(
    'customerName',
  );
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
    'customer_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _branchMeta = const VerificationMeta('branch');
  @override
  late final GeneratedColumn<String> branch = GeneratedColumn<String>(
    'branch',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _salesMethodMeta = const VerificationMeta(
    'salesMethod',
  );
  @override
  late final GeneratedColumn<String> salesMethod = GeneratedColumn<String>(
    'sales_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    idx,
    documentDate,
    documentNumber,
    description,
    correspondingAccount,
    increase,
    decrease,
    adjustIncrease,
    adjustDecrease,
    endAmount,
    seasonalCode,
    paymentPeriod,
    customerCode,
    customerName,
    branch,
    code,
    salesMethod,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'main_datas';
  @override
  VerificationContext validateIntegrity(
    Insertable<MainData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('idx')) {
      context.handle(
        _idxMeta,
        idx.isAcceptableOrUnknown(data['idx']!, _idxMeta),
      );
    }
    if (data.containsKey('document_date')) {
      context.handle(
        _documentDateMeta,
        documentDate.isAcceptableOrUnknown(
          data['document_date']!,
          _documentDateMeta,
        ),
      );
    }
    if (data.containsKey('document_number')) {
      context.handle(
        _documentNumberMeta,
        documentNumber.isAcceptableOrUnknown(
          data['document_number']!,
          _documentNumberMeta,
        ),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('corresponding_account')) {
      context.handle(
        _correspondingAccountMeta,
        correspondingAccount.isAcceptableOrUnknown(
          data['corresponding_account']!,
          _correspondingAccountMeta,
        ),
      );
    }
    if (data.containsKey('increase')) {
      context.handle(
        _increaseMeta,
        increase.isAcceptableOrUnknown(data['increase']!, _increaseMeta),
      );
    }
    if (data.containsKey('decrease')) {
      context.handle(
        _decreaseMeta,
        decrease.isAcceptableOrUnknown(data['decrease']!, _decreaseMeta),
      );
    }
    if (data.containsKey('adjust_increase')) {
      context.handle(
        _adjustIncreaseMeta,
        adjustIncrease.isAcceptableOrUnknown(
          data['adjust_increase']!,
          _adjustIncreaseMeta,
        ),
      );
    }
    if (data.containsKey('adjust_decrease')) {
      context.handle(
        _adjustDecreaseMeta,
        adjustDecrease.isAcceptableOrUnknown(
          data['adjust_decrease']!,
          _adjustDecreaseMeta,
        ),
      );
    }
    if (data.containsKey('end_amount')) {
      context.handle(
        _endAmountMeta,
        endAmount.isAcceptableOrUnknown(data['end_amount']!, _endAmountMeta),
      );
    }
    if (data.containsKey('seasonal_code')) {
      context.handle(
        _seasonalCodeMeta,
        seasonalCode.isAcceptableOrUnknown(
          data['seasonal_code']!,
          _seasonalCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seasonalCodeMeta);
    }
    if (data.containsKey('payment_period')) {
      context.handle(
        _paymentPeriodMeta,
        paymentPeriod.isAcceptableOrUnknown(
          data['payment_period']!,
          _paymentPeriodMeta,
        ),
      );
    }
    if (data.containsKey('customer_code')) {
      context.handle(
        _customerCodeMeta,
        customerCode.isAcceptableOrUnknown(
          data['customer_code']!,
          _customerCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerCodeMeta);
    }
    if (data.containsKey('customer_name')) {
      context.handle(
        _customerNameMeta,
        customerName.isAcceptableOrUnknown(
          data['customer_name']!,
          _customerNameMeta,
        ),
      );
    }
    if (data.containsKey('branch')) {
      context.handle(
        _branchMeta,
        branch.isAcceptableOrUnknown(data['branch']!, _branchMeta),
      );
    } else if (isInserting) {
      context.missing(_branchMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('sales_method')) {
      context.handle(
        _salesMethodMeta,
        salesMethod.isAcceptableOrUnknown(
          data['sales_method']!,
          _salesMethodMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_salesMethodMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MainData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MainData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      idx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idx'],
      ),
      documentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}document_date'],
      ),
      documentNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_number'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      correspondingAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}corresponding_account'],
      ),
      increase: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}increase'],
      ),
      decrease: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}decrease'],
      ),
      adjustIncrease: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}adjust_increase'],
      ),
      adjustDecrease: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}adjust_decrease'],
      ),
      endAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_amount'],
      ),
      seasonalCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}seasonal_code'],
      )!,
      paymentPeriod: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}payment_period'],
      ),
      customerCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_code'],
      )!,
      customerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_name'],
      ),
      branch: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}branch'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      salesMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sales_method'],
      )!,
    );
  }

  @override
  $MainDatasTable createAlias(String alias) {
    return $MainDatasTable(attachedDatabase, alias);
  }
}

class MainData extends DataClass implements Insertable<MainData> {
  final String id;
  final int? idx;
  final DateTime? documentDate;
  final String? documentNumber;
  final String? description;
  final String? correspondingAccount;
  final int? increase;
  final int? decrease;
  final int? adjustIncrease;
  final int? adjustDecrease;
  final int? endAmount;
  final String seasonalCode;
  final int? paymentPeriod;
  final String customerCode;
  final String? customerName;
  final String branch;
  final String? code;
  final String salesMethod;
  const MainData({
    required this.id,
    this.idx,
    this.documentDate,
    this.documentNumber,
    this.description,
    this.correspondingAccount,
    this.increase,
    this.decrease,
    this.adjustIncrease,
    this.adjustDecrease,
    this.endAmount,
    required this.seasonalCode,
    this.paymentPeriod,
    required this.customerCode,
    this.customerName,
    required this.branch,
    this.code,
    required this.salesMethod,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || idx != null) {
      map['idx'] = Variable<int>(idx);
    }
    if (!nullToAbsent || documentDate != null) {
      map['document_date'] = Variable<DateTime>(documentDate);
    }
    if (!nullToAbsent || documentNumber != null) {
      map['document_number'] = Variable<String>(documentNumber);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || correspondingAccount != null) {
      map['corresponding_account'] = Variable<String>(correspondingAccount);
    }
    if (!nullToAbsent || increase != null) {
      map['increase'] = Variable<int>(increase);
    }
    if (!nullToAbsent || decrease != null) {
      map['decrease'] = Variable<int>(decrease);
    }
    if (!nullToAbsent || adjustIncrease != null) {
      map['adjust_increase'] = Variable<int>(adjustIncrease);
    }
    if (!nullToAbsent || adjustDecrease != null) {
      map['adjust_decrease'] = Variable<int>(adjustDecrease);
    }
    if (!nullToAbsent || endAmount != null) {
      map['end_amount'] = Variable<int>(endAmount);
    }
    map['seasonal_code'] = Variable<String>(seasonalCode);
    if (!nullToAbsent || paymentPeriod != null) {
      map['payment_period'] = Variable<int>(paymentPeriod);
    }
    map['customer_code'] = Variable<String>(customerCode);
    if (!nullToAbsent || customerName != null) {
      map['customer_name'] = Variable<String>(customerName);
    }
    map['branch'] = Variable<String>(branch);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    map['sales_method'] = Variable<String>(salesMethod);
    return map;
  }

  MainDatasCompanion toCompanion(bool nullToAbsent) {
    return MainDatasCompanion(
      id: Value(id),
      idx: idx == null && nullToAbsent ? const Value.absent() : Value(idx),
      documentDate: documentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(documentDate),
      documentNumber: documentNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(documentNumber),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      correspondingAccount: correspondingAccount == null && nullToAbsent
          ? const Value.absent()
          : Value(correspondingAccount),
      increase: increase == null && nullToAbsent
          ? const Value.absent()
          : Value(increase),
      decrease: decrease == null && nullToAbsent
          ? const Value.absent()
          : Value(decrease),
      adjustIncrease: adjustIncrease == null && nullToAbsent
          ? const Value.absent()
          : Value(adjustIncrease),
      adjustDecrease: adjustDecrease == null && nullToAbsent
          ? const Value.absent()
          : Value(adjustDecrease),
      endAmount: endAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(endAmount),
      seasonalCode: Value(seasonalCode),
      paymentPeriod: paymentPeriod == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentPeriod),
      customerCode: Value(customerCode),
      customerName: customerName == null && nullToAbsent
          ? const Value.absent()
          : Value(customerName),
      branch: Value(branch),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      salesMethod: Value(salesMethod),
    );
  }

  factory MainData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MainData(
      id: serializer.fromJson<String>(json['id']),
      idx: serializer.fromJson<int?>(json['idx']),
      documentDate: serializer.fromJson<DateTime?>(json['documentDate']),
      documentNumber: serializer.fromJson<String?>(json['documentNumber']),
      description: serializer.fromJson<String?>(json['description']),
      correspondingAccount: serializer.fromJson<String?>(
        json['correspondingAccount'],
      ),
      increase: serializer.fromJson<int?>(json['increase']),
      decrease: serializer.fromJson<int?>(json['decrease']),
      adjustIncrease: serializer.fromJson<int?>(json['adjustIncrease']),
      adjustDecrease: serializer.fromJson<int?>(json['adjustDecrease']),
      endAmount: serializer.fromJson<int?>(json['endAmount']),
      seasonalCode: serializer.fromJson<String>(json['seasonalCode']),
      paymentPeriod: serializer.fromJson<int?>(json['paymentPeriod']),
      customerCode: serializer.fromJson<String>(json['customerCode']),
      customerName: serializer.fromJson<String?>(json['customerName']),
      branch: serializer.fromJson<String>(json['branch']),
      code: serializer.fromJson<String?>(json['code']),
      salesMethod: serializer.fromJson<String>(json['salesMethod']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'idx': serializer.toJson<int?>(idx),
      'documentDate': serializer.toJson<DateTime?>(documentDate),
      'documentNumber': serializer.toJson<String?>(documentNumber),
      'description': serializer.toJson<String?>(description),
      'correspondingAccount': serializer.toJson<String?>(correspondingAccount),
      'increase': serializer.toJson<int?>(increase),
      'decrease': serializer.toJson<int?>(decrease),
      'adjustIncrease': serializer.toJson<int?>(adjustIncrease),
      'adjustDecrease': serializer.toJson<int?>(adjustDecrease),
      'endAmount': serializer.toJson<int?>(endAmount),
      'seasonalCode': serializer.toJson<String>(seasonalCode),
      'paymentPeriod': serializer.toJson<int?>(paymentPeriod),
      'customerCode': serializer.toJson<String>(customerCode),
      'customerName': serializer.toJson<String?>(customerName),
      'branch': serializer.toJson<String>(branch),
      'code': serializer.toJson<String?>(code),
      'salesMethod': serializer.toJson<String>(salesMethod),
    };
  }

  MainData copyWith({
    String? id,
    Value<int?> idx = const Value.absent(),
    Value<DateTime?> documentDate = const Value.absent(),
    Value<String?> documentNumber = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> correspondingAccount = const Value.absent(),
    Value<int?> increase = const Value.absent(),
    Value<int?> decrease = const Value.absent(),
    Value<int?> adjustIncrease = const Value.absent(),
    Value<int?> adjustDecrease = const Value.absent(),
    Value<int?> endAmount = const Value.absent(),
    String? seasonalCode,
    Value<int?> paymentPeriod = const Value.absent(),
    String? customerCode,
    Value<String?> customerName = const Value.absent(),
    String? branch,
    Value<String?> code = const Value.absent(),
    String? salesMethod,
  }) => MainData(
    id: id ?? this.id,
    idx: idx.present ? idx.value : this.idx,
    documentDate: documentDate.present ? documentDate.value : this.documentDate,
    documentNumber: documentNumber.present
        ? documentNumber.value
        : this.documentNumber,
    description: description.present ? description.value : this.description,
    correspondingAccount: correspondingAccount.present
        ? correspondingAccount.value
        : this.correspondingAccount,
    increase: increase.present ? increase.value : this.increase,
    decrease: decrease.present ? decrease.value : this.decrease,
    adjustIncrease: adjustIncrease.present
        ? adjustIncrease.value
        : this.adjustIncrease,
    adjustDecrease: adjustDecrease.present
        ? adjustDecrease.value
        : this.adjustDecrease,
    endAmount: endAmount.present ? endAmount.value : this.endAmount,
    seasonalCode: seasonalCode ?? this.seasonalCode,
    paymentPeriod: paymentPeriod.present
        ? paymentPeriod.value
        : this.paymentPeriod,
    customerCode: customerCode ?? this.customerCode,
    customerName: customerName.present ? customerName.value : this.customerName,
    branch: branch ?? this.branch,
    code: code.present ? code.value : this.code,
    salesMethod: salesMethod ?? this.salesMethod,
  );
  MainData copyWithCompanion(MainDatasCompanion data) {
    return MainData(
      id: data.id.present ? data.id.value : this.id,
      idx: data.idx.present ? data.idx.value : this.idx,
      documentDate: data.documentDate.present
          ? data.documentDate.value
          : this.documentDate,
      documentNumber: data.documentNumber.present
          ? data.documentNumber.value
          : this.documentNumber,
      description: data.description.present
          ? data.description.value
          : this.description,
      correspondingAccount: data.correspondingAccount.present
          ? data.correspondingAccount.value
          : this.correspondingAccount,
      increase: data.increase.present ? data.increase.value : this.increase,
      decrease: data.decrease.present ? data.decrease.value : this.decrease,
      adjustIncrease: data.adjustIncrease.present
          ? data.adjustIncrease.value
          : this.adjustIncrease,
      adjustDecrease: data.adjustDecrease.present
          ? data.adjustDecrease.value
          : this.adjustDecrease,
      endAmount: data.endAmount.present ? data.endAmount.value : this.endAmount,
      seasonalCode: data.seasonalCode.present
          ? data.seasonalCode.value
          : this.seasonalCode,
      paymentPeriod: data.paymentPeriod.present
          ? data.paymentPeriod.value
          : this.paymentPeriod,
      customerCode: data.customerCode.present
          ? data.customerCode.value
          : this.customerCode,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      branch: data.branch.present ? data.branch.value : this.branch,
      code: data.code.present ? data.code.value : this.code,
      salesMethod: data.salesMethod.present
          ? data.salesMethod.value
          : this.salesMethod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MainData(')
          ..write('id: $id, ')
          ..write('idx: $idx, ')
          ..write('documentDate: $documentDate, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('description: $description, ')
          ..write('correspondingAccount: $correspondingAccount, ')
          ..write('increase: $increase, ')
          ..write('decrease: $decrease, ')
          ..write('adjustIncrease: $adjustIncrease, ')
          ..write('adjustDecrease: $adjustDecrease, ')
          ..write('endAmount: $endAmount, ')
          ..write('seasonalCode: $seasonalCode, ')
          ..write('paymentPeriod: $paymentPeriod, ')
          ..write('customerCode: $customerCode, ')
          ..write('customerName: $customerName, ')
          ..write('branch: $branch, ')
          ..write('code: $code, ')
          ..write('salesMethod: $salesMethod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    idx,
    documentDate,
    documentNumber,
    description,
    correspondingAccount,
    increase,
    decrease,
    adjustIncrease,
    adjustDecrease,
    endAmount,
    seasonalCode,
    paymentPeriod,
    customerCode,
    customerName,
    branch,
    code,
    salesMethod,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MainData &&
          other.id == this.id &&
          other.idx == this.idx &&
          other.documentDate == this.documentDate &&
          other.documentNumber == this.documentNumber &&
          other.description == this.description &&
          other.correspondingAccount == this.correspondingAccount &&
          other.increase == this.increase &&
          other.decrease == this.decrease &&
          other.adjustIncrease == this.adjustIncrease &&
          other.adjustDecrease == this.adjustDecrease &&
          other.endAmount == this.endAmount &&
          other.seasonalCode == this.seasonalCode &&
          other.paymentPeriod == this.paymentPeriod &&
          other.customerCode == this.customerCode &&
          other.customerName == this.customerName &&
          other.branch == this.branch &&
          other.code == this.code &&
          other.salesMethod == this.salesMethod);
}

class MainDatasCompanion extends UpdateCompanion<MainData> {
  final Value<String> id;
  final Value<int?> idx;
  final Value<DateTime?> documentDate;
  final Value<String?> documentNumber;
  final Value<String?> description;
  final Value<String?> correspondingAccount;
  final Value<int?> increase;
  final Value<int?> decrease;
  final Value<int?> adjustIncrease;
  final Value<int?> adjustDecrease;
  final Value<int?> endAmount;
  final Value<String> seasonalCode;
  final Value<int?> paymentPeriod;
  final Value<String> customerCode;
  final Value<String?> customerName;
  final Value<String> branch;
  final Value<String?> code;
  final Value<String> salesMethod;
  final Value<int> rowid;
  const MainDatasCompanion({
    this.id = const Value.absent(),
    this.idx = const Value.absent(),
    this.documentDate = const Value.absent(),
    this.documentNumber = const Value.absent(),
    this.description = const Value.absent(),
    this.correspondingAccount = const Value.absent(),
    this.increase = const Value.absent(),
    this.decrease = const Value.absent(),
    this.adjustIncrease = const Value.absent(),
    this.adjustDecrease = const Value.absent(),
    this.endAmount = const Value.absent(),
    this.seasonalCode = const Value.absent(),
    this.paymentPeriod = const Value.absent(),
    this.customerCode = const Value.absent(),
    this.customerName = const Value.absent(),
    this.branch = const Value.absent(),
    this.code = const Value.absent(),
    this.salesMethod = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MainDatasCompanion.insert({
    required String id,
    this.idx = const Value.absent(),
    this.documentDate = const Value.absent(),
    this.documentNumber = const Value.absent(),
    this.description = const Value.absent(),
    this.correspondingAccount = const Value.absent(),
    this.increase = const Value.absent(),
    this.decrease = const Value.absent(),
    this.adjustIncrease = const Value.absent(),
    this.adjustDecrease = const Value.absent(),
    this.endAmount = const Value.absent(),
    required String seasonalCode,
    this.paymentPeriod = const Value.absent(),
    required String customerCode,
    this.customerName = const Value.absent(),
    required String branch,
    this.code = const Value.absent(),
    required String salesMethod,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       seasonalCode = Value(seasonalCode),
       customerCode = Value(customerCode),
       branch = Value(branch),
       salesMethod = Value(salesMethod);
  static Insertable<MainData> custom({
    Expression<String>? id,
    Expression<int>? idx,
    Expression<DateTime>? documentDate,
    Expression<String>? documentNumber,
    Expression<String>? description,
    Expression<String>? correspondingAccount,
    Expression<int>? increase,
    Expression<int>? decrease,
    Expression<int>? adjustIncrease,
    Expression<int>? adjustDecrease,
    Expression<int>? endAmount,
    Expression<String>? seasonalCode,
    Expression<int>? paymentPeriod,
    Expression<String>? customerCode,
    Expression<String>? customerName,
    Expression<String>? branch,
    Expression<String>? code,
    Expression<String>? salesMethod,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (idx != null) 'idx': idx,
      if (documentDate != null) 'document_date': documentDate,
      if (documentNumber != null) 'document_number': documentNumber,
      if (description != null) 'description': description,
      if (correspondingAccount != null)
        'corresponding_account': correspondingAccount,
      if (increase != null) 'increase': increase,
      if (decrease != null) 'decrease': decrease,
      if (adjustIncrease != null) 'adjust_increase': adjustIncrease,
      if (adjustDecrease != null) 'adjust_decrease': adjustDecrease,
      if (endAmount != null) 'end_amount': endAmount,
      if (seasonalCode != null) 'seasonal_code': seasonalCode,
      if (paymentPeriod != null) 'payment_period': paymentPeriod,
      if (customerCode != null) 'customer_code': customerCode,
      if (customerName != null) 'customer_name': customerName,
      if (branch != null) 'branch': branch,
      if (code != null) 'code': code,
      if (salesMethod != null) 'sales_method': salesMethod,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MainDatasCompanion copyWith({
    Value<String>? id,
    Value<int?>? idx,
    Value<DateTime?>? documentDate,
    Value<String?>? documentNumber,
    Value<String?>? description,
    Value<String?>? correspondingAccount,
    Value<int?>? increase,
    Value<int?>? decrease,
    Value<int?>? adjustIncrease,
    Value<int?>? adjustDecrease,
    Value<int?>? endAmount,
    Value<String>? seasonalCode,
    Value<int?>? paymentPeriod,
    Value<String>? customerCode,
    Value<String?>? customerName,
    Value<String>? branch,
    Value<String?>? code,
    Value<String>? salesMethod,
    Value<int>? rowid,
  }) {
    return MainDatasCompanion(
      id: id ?? this.id,
      idx: idx ?? this.idx,
      documentDate: documentDate ?? this.documentDate,
      documentNumber: documentNumber ?? this.documentNumber,
      description: description ?? this.description,
      correspondingAccount: correspondingAccount ?? this.correspondingAccount,
      increase: increase ?? this.increase,
      decrease: decrease ?? this.decrease,
      adjustIncrease: adjustIncrease ?? this.adjustIncrease,
      adjustDecrease: adjustDecrease ?? this.adjustDecrease,
      endAmount: endAmount ?? this.endAmount,
      seasonalCode: seasonalCode ?? this.seasonalCode,
      paymentPeriod: paymentPeriod ?? this.paymentPeriod,
      customerCode: customerCode ?? this.customerCode,
      customerName: customerName ?? this.customerName,
      branch: branch ?? this.branch,
      code: code ?? this.code,
      salesMethod: salesMethod ?? this.salesMethod,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (idx.present) {
      map['idx'] = Variable<int>(idx.value);
    }
    if (documentDate.present) {
      map['document_date'] = Variable<DateTime>(documentDate.value);
    }
    if (documentNumber.present) {
      map['document_number'] = Variable<String>(documentNumber.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (correspondingAccount.present) {
      map['corresponding_account'] = Variable<String>(
        correspondingAccount.value,
      );
    }
    if (increase.present) {
      map['increase'] = Variable<int>(increase.value);
    }
    if (decrease.present) {
      map['decrease'] = Variable<int>(decrease.value);
    }
    if (adjustIncrease.present) {
      map['adjust_increase'] = Variable<int>(adjustIncrease.value);
    }
    if (adjustDecrease.present) {
      map['adjust_decrease'] = Variable<int>(adjustDecrease.value);
    }
    if (endAmount.present) {
      map['end_amount'] = Variable<int>(endAmount.value);
    }
    if (seasonalCode.present) {
      map['seasonal_code'] = Variable<String>(seasonalCode.value);
    }
    if (paymentPeriod.present) {
      map['payment_period'] = Variable<int>(paymentPeriod.value);
    }
    if (customerCode.present) {
      map['customer_code'] = Variable<String>(customerCode.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (branch.present) {
      map['branch'] = Variable<String>(branch.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (salesMethod.present) {
      map['sales_method'] = Variable<String>(salesMethod.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MainDatasCompanion(')
          ..write('id: $id, ')
          ..write('idx: $idx, ')
          ..write('documentDate: $documentDate, ')
          ..write('documentNumber: $documentNumber, ')
          ..write('description: $description, ')
          ..write('correspondingAccount: $correspondingAccount, ')
          ..write('increase: $increase, ')
          ..write('decrease: $decrease, ')
          ..write('adjustIncrease: $adjustIncrease, ')
          ..write('adjustDecrease: $adjustDecrease, ')
          ..write('endAmount: $endAmount, ')
          ..write('seasonalCode: $seasonalCode, ')
          ..write('paymentPeriod: $paymentPeriod, ')
          ..write('customerCode: $customerCode, ')
          ..write('customerName: $customerName, ')
          ..write('branch: $branch, ')
          ..write('code: $code, ')
          ..write('salesMethod: $salesMethod, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ResultsTable extends Results with TableInfo<$ResultsTable, Result> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mainDataIdMeta = const VerificationMeta(
    'mainDataId',
  );
  @override
  late final GeneratedColumn<String> mainDataId = GeneratedColumn<String>(
    'main_data_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES main_datas (id)',
    ),
  );
  static const VerificationMeta _levelConfigIdMeta = const VerificationMeta(
    'levelConfigId',
  );
  @override
  late final GeneratedColumn<String> levelConfigId = GeneratedColumn<String>(
    'level_config_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES level_configs (id)',
    ),
  );
  static const VerificationMeta _sortedIdxMeta = const VerificationMeta(
    'sortedIdx',
  );
  @override
  late final GeneratedColumn<int> sortedIdx = GeneratedColumn<int>(
    'sorted_idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _originalIdxMeta = const VerificationMeta(
    'originalIdx',
  );
  @override
  late final GeneratedColumn<int> originalIdx = GeneratedColumn<int>(
    'original_idx',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paymentDueDateMeta = const VerificationMeta(
    'paymentDueDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDueDate =
      GeneratedColumn<DateTime>(
        'payment_due_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _bonusIncreaseMeta = const VerificationMeta(
    'bonusIncrease',
  );
  @override
  late final GeneratedColumn<int> bonusIncrease = GeneratedColumn<int>(
    'bonus_increase',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nonBonusIncreaseMeta = const VerificationMeta(
    'nonBonusIncrease',
  );
  @override
  late final GeneratedColumn<int> nonBonusIncrease = GeneratedColumn<int>(
    'non_bonus_increase',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bonusDecreaseMeta = const VerificationMeta(
    'bonusDecrease',
  );
  @override
  late final GeneratedColumn<int> bonusDecrease = GeneratedColumn<int>(
    'bonus_decrease',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nonBonusDecreaseMeta = const VerificationMeta(
    'nonBonusDecrease',
  );
  @override
  late final GeneratedColumn<int> nonBonusDecrease = GeneratedColumn<int>(
    'non_bonus_decrease',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _paymentDueDate1Meta = const VerificationMeta(
    'paymentDueDate1',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDueDate1 =
      GeneratedColumn<DateTime>(
        'payment_due_date1',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _paymentDueDate2Meta = const VerificationMeta(
    'paymentDueDate2',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDueDate2 =
      GeneratedColumn<DateTime>(
        'payment_due_date2',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _paymentDueDate3Meta = const VerificationMeta(
    'paymentDueDate3',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDueDate3 =
      GeneratedColumn<DateTime>(
        'payment_due_date3',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _bonus1Meta = const VerificationMeta('bonus1');
  @override
  late final GeneratedColumn<int> bonus1 = GeneratedColumn<int>(
    'bonus1',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bonus2Meta = const VerificationMeta('bonus2');
  @override
  late final GeneratedColumn<int> bonus2 = GeneratedColumn<int>(
    'bonus2',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _bonus3Meta = const VerificationMeta('bonus3');
  @override
  late final GeneratedColumn<int> bonus3 = GeneratedColumn<int>(
    'bonus3',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _beforeRemainMeta = const VerificationMeta(
    'beforeRemain',
  );
  @override
  late final GeneratedColumn<String> beforeRemain = GeneratedColumn<String>(
    'before_remain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _afterRemainMeta = const VerificationMeta(
    'afterRemain',
  );
  @override
  late final GeneratedColumn<String> afterRemain = GeneratedColumn<String>(
    'after_remain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _calculateStatusMeta = const VerificationMeta(
    'calculateStatus',
  );
  @override
  late final GeneratedColumn<String> calculateStatus = GeneratedColumn<String>(
    'calculate_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('valid'),
  );
  static const VerificationMeta _calculateMessageMeta = const VerificationMeta(
    'calculateMessage',
  );
  @override
  late final GeneratedColumn<String> calculateMessage = GeneratedColumn<String>(
    'calculate_message',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mainDataId,
    levelConfigId,
    sortedIdx,
    originalIdx,
    type,
    paymentDueDate,
    bonusIncrease,
    nonBonusIncrease,
    bonusDecrease,
    nonBonusDecrease,
    paymentDueDate1,
    paymentDueDate2,
    paymentDueDate3,
    bonus1,
    bonus2,
    bonus3,
    beforeRemain,
    afterRemain,
    calculateStatus,
    calculateMessage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'results';
  @override
  VerificationContext validateIntegrity(
    Insertable<Result> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('main_data_id')) {
      context.handle(
        _mainDataIdMeta,
        mainDataId.isAcceptableOrUnknown(
          data['main_data_id']!,
          _mainDataIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mainDataIdMeta);
    }
    if (data.containsKey('level_config_id')) {
      context.handle(
        _levelConfigIdMeta,
        levelConfigId.isAcceptableOrUnknown(
          data['level_config_id']!,
          _levelConfigIdMeta,
        ),
      );
    }
    if (data.containsKey('sorted_idx')) {
      context.handle(
        _sortedIdxMeta,
        sortedIdx.isAcceptableOrUnknown(data['sorted_idx']!, _sortedIdxMeta),
      );
    }
    if (data.containsKey('original_idx')) {
      context.handle(
        _originalIdxMeta,
        originalIdx.isAcceptableOrUnknown(
          data['original_idx']!,
          _originalIdxMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('payment_due_date')) {
      context.handle(
        _paymentDueDateMeta,
        paymentDueDate.isAcceptableOrUnknown(
          data['payment_due_date']!,
          _paymentDueDateMeta,
        ),
      );
    }
    if (data.containsKey('bonus_increase')) {
      context.handle(
        _bonusIncreaseMeta,
        bonusIncrease.isAcceptableOrUnknown(
          data['bonus_increase']!,
          _bonusIncreaseMeta,
        ),
      );
    }
    if (data.containsKey('non_bonus_increase')) {
      context.handle(
        _nonBonusIncreaseMeta,
        nonBonusIncrease.isAcceptableOrUnknown(
          data['non_bonus_increase']!,
          _nonBonusIncreaseMeta,
        ),
      );
    }
    if (data.containsKey('bonus_decrease')) {
      context.handle(
        _bonusDecreaseMeta,
        bonusDecrease.isAcceptableOrUnknown(
          data['bonus_decrease']!,
          _bonusDecreaseMeta,
        ),
      );
    }
    if (data.containsKey('non_bonus_decrease')) {
      context.handle(
        _nonBonusDecreaseMeta,
        nonBonusDecrease.isAcceptableOrUnknown(
          data['non_bonus_decrease']!,
          _nonBonusDecreaseMeta,
        ),
      );
    }
    if (data.containsKey('payment_due_date1')) {
      context.handle(
        _paymentDueDate1Meta,
        paymentDueDate1.isAcceptableOrUnknown(
          data['payment_due_date1']!,
          _paymentDueDate1Meta,
        ),
      );
    }
    if (data.containsKey('payment_due_date2')) {
      context.handle(
        _paymentDueDate2Meta,
        paymentDueDate2.isAcceptableOrUnknown(
          data['payment_due_date2']!,
          _paymentDueDate2Meta,
        ),
      );
    }
    if (data.containsKey('payment_due_date3')) {
      context.handle(
        _paymentDueDate3Meta,
        paymentDueDate3.isAcceptableOrUnknown(
          data['payment_due_date3']!,
          _paymentDueDate3Meta,
        ),
      );
    }
    if (data.containsKey('bonus1')) {
      context.handle(
        _bonus1Meta,
        bonus1.isAcceptableOrUnknown(data['bonus1']!, _bonus1Meta),
      );
    }
    if (data.containsKey('bonus2')) {
      context.handle(
        _bonus2Meta,
        bonus2.isAcceptableOrUnknown(data['bonus2']!, _bonus2Meta),
      );
    }
    if (data.containsKey('bonus3')) {
      context.handle(
        _bonus3Meta,
        bonus3.isAcceptableOrUnknown(data['bonus3']!, _bonus3Meta),
      );
    }
    if (data.containsKey('before_remain')) {
      context.handle(
        _beforeRemainMeta,
        beforeRemain.isAcceptableOrUnknown(
          data['before_remain']!,
          _beforeRemainMeta,
        ),
      );
    }
    if (data.containsKey('after_remain')) {
      context.handle(
        _afterRemainMeta,
        afterRemain.isAcceptableOrUnknown(
          data['after_remain']!,
          _afterRemainMeta,
        ),
      );
    }
    if (data.containsKey('calculate_status')) {
      context.handle(
        _calculateStatusMeta,
        calculateStatus.isAcceptableOrUnknown(
          data['calculate_status']!,
          _calculateStatusMeta,
        ),
      );
    }
    if (data.containsKey('calculate_message')) {
      context.handle(
        _calculateMessageMeta,
        calculateMessage.isAcceptableOrUnknown(
          data['calculate_message']!,
          _calculateMessageMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Result map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Result(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mainDataId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}main_data_id'],
      )!,
      levelConfigId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_config_id'],
      ),
      sortedIdx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sorted_idx'],
      )!,
      originalIdx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}original_idx'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      paymentDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_due_date'],
      ),
      bonusIncrease: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_increase'],
      )!,
      nonBonusIncrease: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}non_bonus_increase'],
      )!,
      bonusDecrease: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus_decrease'],
      )!,
      nonBonusDecrease: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}non_bonus_decrease'],
      )!,
      paymentDueDate1: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_due_date1'],
      ),
      paymentDueDate2: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_due_date2'],
      ),
      paymentDueDate3: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_due_date3'],
      ),
      bonus1: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus1'],
      )!,
      bonus2: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus2'],
      )!,
      bonus3: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bonus3'],
      )!,
      beforeRemain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_remain'],
      )!,
      afterRemain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_remain'],
      )!,
      calculateStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculate_status'],
      )!,
      calculateMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calculate_message'],
      )!,
    );
  }

  @override
  $ResultsTable createAlias(String alias) {
    return $ResultsTable(attachedDatabase, alias);
  }
}

class Result extends DataClass implements Insertable<Result> {
  final String id;
  final String mainDataId;
  final String? levelConfigId;
  final int sortedIdx;
  final int originalIdx;
  final int type;
  final DateTime? paymentDueDate;
  final int bonusIncrease;
  final int nonBonusIncrease;
  final int bonusDecrease;
  final int nonBonusDecrease;
  final DateTime? paymentDueDate1;
  final DateTime? paymentDueDate2;
  final DateTime? paymentDueDate3;
  final int bonus1;
  final int bonus2;
  final int bonus3;
  final String beforeRemain;
  final String afterRemain;
  final String calculateStatus;
  final String calculateMessage;
  const Result({
    required this.id,
    required this.mainDataId,
    this.levelConfigId,
    required this.sortedIdx,
    required this.originalIdx,
    required this.type,
    this.paymentDueDate,
    required this.bonusIncrease,
    required this.nonBonusIncrease,
    required this.bonusDecrease,
    required this.nonBonusDecrease,
    this.paymentDueDate1,
    this.paymentDueDate2,
    this.paymentDueDate3,
    required this.bonus1,
    required this.bonus2,
    required this.bonus3,
    required this.beforeRemain,
    required this.afterRemain,
    required this.calculateStatus,
    required this.calculateMessage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['main_data_id'] = Variable<String>(mainDataId);
    if (!nullToAbsent || levelConfigId != null) {
      map['level_config_id'] = Variable<String>(levelConfigId);
    }
    map['sorted_idx'] = Variable<int>(sortedIdx);
    map['original_idx'] = Variable<int>(originalIdx);
    map['type'] = Variable<int>(type);
    if (!nullToAbsent || paymentDueDate != null) {
      map['payment_due_date'] = Variable<DateTime>(paymentDueDate);
    }
    map['bonus_increase'] = Variable<int>(bonusIncrease);
    map['non_bonus_increase'] = Variable<int>(nonBonusIncrease);
    map['bonus_decrease'] = Variable<int>(bonusDecrease);
    map['non_bonus_decrease'] = Variable<int>(nonBonusDecrease);
    if (!nullToAbsent || paymentDueDate1 != null) {
      map['payment_due_date1'] = Variable<DateTime>(paymentDueDate1);
    }
    if (!nullToAbsent || paymentDueDate2 != null) {
      map['payment_due_date2'] = Variable<DateTime>(paymentDueDate2);
    }
    if (!nullToAbsent || paymentDueDate3 != null) {
      map['payment_due_date3'] = Variable<DateTime>(paymentDueDate3);
    }
    map['bonus1'] = Variable<int>(bonus1);
    map['bonus2'] = Variable<int>(bonus2);
    map['bonus3'] = Variable<int>(bonus3);
    map['before_remain'] = Variable<String>(beforeRemain);
    map['after_remain'] = Variable<String>(afterRemain);
    map['calculate_status'] = Variable<String>(calculateStatus);
    map['calculate_message'] = Variable<String>(calculateMessage);
    return map;
  }

  ResultsCompanion toCompanion(bool nullToAbsent) {
    return ResultsCompanion(
      id: Value(id),
      mainDataId: Value(mainDataId),
      levelConfigId: levelConfigId == null && nullToAbsent
          ? const Value.absent()
          : Value(levelConfigId),
      sortedIdx: Value(sortedIdx),
      originalIdx: Value(originalIdx),
      type: Value(type),
      paymentDueDate: paymentDueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDueDate),
      bonusIncrease: Value(bonusIncrease),
      nonBonusIncrease: Value(nonBonusIncrease),
      bonusDecrease: Value(bonusDecrease),
      nonBonusDecrease: Value(nonBonusDecrease),
      paymentDueDate1: paymentDueDate1 == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDueDate1),
      paymentDueDate2: paymentDueDate2 == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDueDate2),
      paymentDueDate3: paymentDueDate3 == null && nullToAbsent
          ? const Value.absent()
          : Value(paymentDueDate3),
      bonus1: Value(bonus1),
      bonus2: Value(bonus2),
      bonus3: Value(bonus3),
      beforeRemain: Value(beforeRemain),
      afterRemain: Value(afterRemain),
      calculateStatus: Value(calculateStatus),
      calculateMessage: Value(calculateMessage),
    );
  }

  factory Result.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Result(
      id: serializer.fromJson<String>(json['id']),
      mainDataId: serializer.fromJson<String>(json['mainDataId']),
      levelConfigId: serializer.fromJson<String?>(json['levelConfigId']),
      sortedIdx: serializer.fromJson<int>(json['sortedIdx']),
      originalIdx: serializer.fromJson<int>(json['originalIdx']),
      type: serializer.fromJson<int>(json['type']),
      paymentDueDate: serializer.fromJson<DateTime?>(json['paymentDueDate']),
      bonusIncrease: serializer.fromJson<int>(json['bonusIncrease']),
      nonBonusIncrease: serializer.fromJson<int>(json['nonBonusIncrease']),
      bonusDecrease: serializer.fromJson<int>(json['bonusDecrease']),
      nonBonusDecrease: serializer.fromJson<int>(json['nonBonusDecrease']),
      paymentDueDate1: serializer.fromJson<DateTime?>(json['paymentDueDate1']),
      paymentDueDate2: serializer.fromJson<DateTime?>(json['paymentDueDate2']),
      paymentDueDate3: serializer.fromJson<DateTime?>(json['paymentDueDate3']),
      bonus1: serializer.fromJson<int>(json['bonus1']),
      bonus2: serializer.fromJson<int>(json['bonus2']),
      bonus3: serializer.fromJson<int>(json['bonus3']),
      beforeRemain: serializer.fromJson<String>(json['beforeRemain']),
      afterRemain: serializer.fromJson<String>(json['afterRemain']),
      calculateStatus: serializer.fromJson<String>(json['calculateStatus']),
      calculateMessage: serializer.fromJson<String>(json['calculateMessage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mainDataId': serializer.toJson<String>(mainDataId),
      'levelConfigId': serializer.toJson<String?>(levelConfigId),
      'sortedIdx': serializer.toJson<int>(sortedIdx),
      'originalIdx': serializer.toJson<int>(originalIdx),
      'type': serializer.toJson<int>(type),
      'paymentDueDate': serializer.toJson<DateTime?>(paymentDueDate),
      'bonusIncrease': serializer.toJson<int>(bonusIncrease),
      'nonBonusIncrease': serializer.toJson<int>(nonBonusIncrease),
      'bonusDecrease': serializer.toJson<int>(bonusDecrease),
      'nonBonusDecrease': serializer.toJson<int>(nonBonusDecrease),
      'paymentDueDate1': serializer.toJson<DateTime?>(paymentDueDate1),
      'paymentDueDate2': serializer.toJson<DateTime?>(paymentDueDate2),
      'paymentDueDate3': serializer.toJson<DateTime?>(paymentDueDate3),
      'bonus1': serializer.toJson<int>(bonus1),
      'bonus2': serializer.toJson<int>(bonus2),
      'bonus3': serializer.toJson<int>(bonus3),
      'beforeRemain': serializer.toJson<String>(beforeRemain),
      'afterRemain': serializer.toJson<String>(afterRemain),
      'calculateStatus': serializer.toJson<String>(calculateStatus),
      'calculateMessage': serializer.toJson<String>(calculateMessage),
    };
  }

  Result copyWith({
    String? id,
    String? mainDataId,
    Value<String?> levelConfigId = const Value.absent(),
    int? sortedIdx,
    int? originalIdx,
    int? type,
    Value<DateTime?> paymentDueDate = const Value.absent(),
    int? bonusIncrease,
    int? nonBonusIncrease,
    int? bonusDecrease,
    int? nonBonusDecrease,
    Value<DateTime?> paymentDueDate1 = const Value.absent(),
    Value<DateTime?> paymentDueDate2 = const Value.absent(),
    Value<DateTime?> paymentDueDate3 = const Value.absent(),
    int? bonus1,
    int? bonus2,
    int? bonus3,
    String? beforeRemain,
    String? afterRemain,
    String? calculateStatus,
    String? calculateMessage,
  }) => Result(
    id: id ?? this.id,
    mainDataId: mainDataId ?? this.mainDataId,
    levelConfigId: levelConfigId.present
        ? levelConfigId.value
        : this.levelConfigId,
    sortedIdx: sortedIdx ?? this.sortedIdx,
    originalIdx: originalIdx ?? this.originalIdx,
    type: type ?? this.type,
    paymentDueDate: paymentDueDate.present
        ? paymentDueDate.value
        : this.paymentDueDate,
    bonusIncrease: bonusIncrease ?? this.bonusIncrease,
    nonBonusIncrease: nonBonusIncrease ?? this.nonBonusIncrease,
    bonusDecrease: bonusDecrease ?? this.bonusDecrease,
    nonBonusDecrease: nonBonusDecrease ?? this.nonBonusDecrease,
    paymentDueDate1: paymentDueDate1.present
        ? paymentDueDate1.value
        : this.paymentDueDate1,
    paymentDueDate2: paymentDueDate2.present
        ? paymentDueDate2.value
        : this.paymentDueDate2,
    paymentDueDate3: paymentDueDate3.present
        ? paymentDueDate3.value
        : this.paymentDueDate3,
    bonus1: bonus1 ?? this.bonus1,
    bonus2: bonus2 ?? this.bonus2,
    bonus3: bonus3 ?? this.bonus3,
    beforeRemain: beforeRemain ?? this.beforeRemain,
    afterRemain: afterRemain ?? this.afterRemain,
    calculateStatus: calculateStatus ?? this.calculateStatus,
    calculateMessage: calculateMessage ?? this.calculateMessage,
  );
  Result copyWithCompanion(ResultsCompanion data) {
    return Result(
      id: data.id.present ? data.id.value : this.id,
      mainDataId: data.mainDataId.present
          ? data.mainDataId.value
          : this.mainDataId,
      levelConfigId: data.levelConfigId.present
          ? data.levelConfigId.value
          : this.levelConfigId,
      sortedIdx: data.sortedIdx.present ? data.sortedIdx.value : this.sortedIdx,
      originalIdx: data.originalIdx.present
          ? data.originalIdx.value
          : this.originalIdx,
      type: data.type.present ? data.type.value : this.type,
      paymentDueDate: data.paymentDueDate.present
          ? data.paymentDueDate.value
          : this.paymentDueDate,
      bonusIncrease: data.bonusIncrease.present
          ? data.bonusIncrease.value
          : this.bonusIncrease,
      nonBonusIncrease: data.nonBonusIncrease.present
          ? data.nonBonusIncrease.value
          : this.nonBonusIncrease,
      bonusDecrease: data.bonusDecrease.present
          ? data.bonusDecrease.value
          : this.bonusDecrease,
      nonBonusDecrease: data.nonBonusDecrease.present
          ? data.nonBonusDecrease.value
          : this.nonBonusDecrease,
      paymentDueDate1: data.paymentDueDate1.present
          ? data.paymentDueDate1.value
          : this.paymentDueDate1,
      paymentDueDate2: data.paymentDueDate2.present
          ? data.paymentDueDate2.value
          : this.paymentDueDate2,
      paymentDueDate3: data.paymentDueDate3.present
          ? data.paymentDueDate3.value
          : this.paymentDueDate3,
      bonus1: data.bonus1.present ? data.bonus1.value : this.bonus1,
      bonus2: data.bonus2.present ? data.bonus2.value : this.bonus2,
      bonus3: data.bonus3.present ? data.bonus3.value : this.bonus3,
      beforeRemain: data.beforeRemain.present
          ? data.beforeRemain.value
          : this.beforeRemain,
      afterRemain: data.afterRemain.present
          ? data.afterRemain.value
          : this.afterRemain,
      calculateStatus: data.calculateStatus.present
          ? data.calculateStatus.value
          : this.calculateStatus,
      calculateMessage: data.calculateMessage.present
          ? data.calculateMessage.value
          : this.calculateMessage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Result(')
          ..write('id: $id, ')
          ..write('mainDataId: $mainDataId, ')
          ..write('levelConfigId: $levelConfigId, ')
          ..write('sortedIdx: $sortedIdx, ')
          ..write('originalIdx: $originalIdx, ')
          ..write('type: $type, ')
          ..write('paymentDueDate: $paymentDueDate, ')
          ..write('bonusIncrease: $bonusIncrease, ')
          ..write('nonBonusIncrease: $nonBonusIncrease, ')
          ..write('bonusDecrease: $bonusDecrease, ')
          ..write('nonBonusDecrease: $nonBonusDecrease, ')
          ..write('paymentDueDate1: $paymentDueDate1, ')
          ..write('paymentDueDate2: $paymentDueDate2, ')
          ..write('paymentDueDate3: $paymentDueDate3, ')
          ..write('bonus1: $bonus1, ')
          ..write('bonus2: $bonus2, ')
          ..write('bonus3: $bonus3, ')
          ..write('beforeRemain: $beforeRemain, ')
          ..write('afterRemain: $afterRemain, ')
          ..write('calculateStatus: $calculateStatus, ')
          ..write('calculateMessage: $calculateMessage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    mainDataId,
    levelConfigId,
    sortedIdx,
    originalIdx,
    type,
    paymentDueDate,
    bonusIncrease,
    nonBonusIncrease,
    bonusDecrease,
    nonBonusDecrease,
    paymentDueDate1,
    paymentDueDate2,
    paymentDueDate3,
    bonus1,
    bonus2,
    bonus3,
    beforeRemain,
    afterRemain,
    calculateStatus,
    calculateMessage,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Result &&
          other.id == this.id &&
          other.mainDataId == this.mainDataId &&
          other.levelConfigId == this.levelConfigId &&
          other.sortedIdx == this.sortedIdx &&
          other.originalIdx == this.originalIdx &&
          other.type == this.type &&
          other.paymentDueDate == this.paymentDueDate &&
          other.bonusIncrease == this.bonusIncrease &&
          other.nonBonusIncrease == this.nonBonusIncrease &&
          other.bonusDecrease == this.bonusDecrease &&
          other.nonBonusDecrease == this.nonBonusDecrease &&
          other.paymentDueDate1 == this.paymentDueDate1 &&
          other.paymentDueDate2 == this.paymentDueDate2 &&
          other.paymentDueDate3 == this.paymentDueDate3 &&
          other.bonus1 == this.bonus1 &&
          other.bonus2 == this.bonus2 &&
          other.bonus3 == this.bonus3 &&
          other.beforeRemain == this.beforeRemain &&
          other.afterRemain == this.afterRemain &&
          other.calculateStatus == this.calculateStatus &&
          other.calculateMessage == this.calculateMessage);
}

class ResultsCompanion extends UpdateCompanion<Result> {
  final Value<String> id;
  final Value<String> mainDataId;
  final Value<String?> levelConfigId;
  final Value<int> sortedIdx;
  final Value<int> originalIdx;
  final Value<int> type;
  final Value<DateTime?> paymentDueDate;
  final Value<int> bonusIncrease;
  final Value<int> nonBonusIncrease;
  final Value<int> bonusDecrease;
  final Value<int> nonBonusDecrease;
  final Value<DateTime?> paymentDueDate1;
  final Value<DateTime?> paymentDueDate2;
  final Value<DateTime?> paymentDueDate3;
  final Value<int> bonus1;
  final Value<int> bonus2;
  final Value<int> bonus3;
  final Value<String> beforeRemain;
  final Value<String> afterRemain;
  final Value<String> calculateStatus;
  final Value<String> calculateMessage;
  final Value<int> rowid;
  const ResultsCompanion({
    this.id = const Value.absent(),
    this.mainDataId = const Value.absent(),
    this.levelConfigId = const Value.absent(),
    this.sortedIdx = const Value.absent(),
    this.originalIdx = const Value.absent(),
    this.type = const Value.absent(),
    this.paymentDueDate = const Value.absent(),
    this.bonusIncrease = const Value.absent(),
    this.nonBonusIncrease = const Value.absent(),
    this.bonusDecrease = const Value.absent(),
    this.nonBonusDecrease = const Value.absent(),
    this.paymentDueDate1 = const Value.absent(),
    this.paymentDueDate2 = const Value.absent(),
    this.paymentDueDate3 = const Value.absent(),
    this.bonus1 = const Value.absent(),
    this.bonus2 = const Value.absent(),
    this.bonus3 = const Value.absent(),
    this.beforeRemain = const Value.absent(),
    this.afterRemain = const Value.absent(),
    this.calculateStatus = const Value.absent(),
    this.calculateMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ResultsCompanion.insert({
    required String id,
    required String mainDataId,
    this.levelConfigId = const Value.absent(),
    this.sortedIdx = const Value.absent(),
    this.originalIdx = const Value.absent(),
    this.type = const Value.absent(),
    this.paymentDueDate = const Value.absent(),
    this.bonusIncrease = const Value.absent(),
    this.nonBonusIncrease = const Value.absent(),
    this.bonusDecrease = const Value.absent(),
    this.nonBonusDecrease = const Value.absent(),
    this.paymentDueDate1 = const Value.absent(),
    this.paymentDueDate2 = const Value.absent(),
    this.paymentDueDate3 = const Value.absent(),
    this.bonus1 = const Value.absent(),
    this.bonus2 = const Value.absent(),
    this.bonus3 = const Value.absent(),
    this.beforeRemain = const Value.absent(),
    this.afterRemain = const Value.absent(),
    this.calculateStatus = const Value.absent(),
    this.calculateMessage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mainDataId = Value(mainDataId);
  static Insertable<Result> custom({
    Expression<String>? id,
    Expression<String>? mainDataId,
    Expression<String>? levelConfigId,
    Expression<int>? sortedIdx,
    Expression<int>? originalIdx,
    Expression<int>? type,
    Expression<DateTime>? paymentDueDate,
    Expression<int>? bonusIncrease,
    Expression<int>? nonBonusIncrease,
    Expression<int>? bonusDecrease,
    Expression<int>? nonBonusDecrease,
    Expression<DateTime>? paymentDueDate1,
    Expression<DateTime>? paymentDueDate2,
    Expression<DateTime>? paymentDueDate3,
    Expression<int>? bonus1,
    Expression<int>? bonus2,
    Expression<int>? bonus3,
    Expression<String>? beforeRemain,
    Expression<String>? afterRemain,
    Expression<String>? calculateStatus,
    Expression<String>? calculateMessage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mainDataId != null) 'main_data_id': mainDataId,
      if (levelConfigId != null) 'level_config_id': levelConfigId,
      if (sortedIdx != null) 'sorted_idx': sortedIdx,
      if (originalIdx != null) 'original_idx': originalIdx,
      if (type != null) 'type': type,
      if (paymentDueDate != null) 'payment_due_date': paymentDueDate,
      if (bonusIncrease != null) 'bonus_increase': bonusIncrease,
      if (nonBonusIncrease != null) 'non_bonus_increase': nonBonusIncrease,
      if (bonusDecrease != null) 'bonus_decrease': bonusDecrease,
      if (nonBonusDecrease != null) 'non_bonus_decrease': nonBonusDecrease,
      if (paymentDueDate1 != null) 'payment_due_date1': paymentDueDate1,
      if (paymentDueDate2 != null) 'payment_due_date2': paymentDueDate2,
      if (paymentDueDate3 != null) 'payment_due_date3': paymentDueDate3,
      if (bonus1 != null) 'bonus1': bonus1,
      if (bonus2 != null) 'bonus2': bonus2,
      if (bonus3 != null) 'bonus3': bonus3,
      if (beforeRemain != null) 'before_remain': beforeRemain,
      if (afterRemain != null) 'after_remain': afterRemain,
      if (calculateStatus != null) 'calculate_status': calculateStatus,
      if (calculateMessage != null) 'calculate_message': calculateMessage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ResultsCompanion copyWith({
    Value<String>? id,
    Value<String>? mainDataId,
    Value<String?>? levelConfigId,
    Value<int>? sortedIdx,
    Value<int>? originalIdx,
    Value<int>? type,
    Value<DateTime?>? paymentDueDate,
    Value<int>? bonusIncrease,
    Value<int>? nonBonusIncrease,
    Value<int>? bonusDecrease,
    Value<int>? nonBonusDecrease,
    Value<DateTime?>? paymentDueDate1,
    Value<DateTime?>? paymentDueDate2,
    Value<DateTime?>? paymentDueDate3,
    Value<int>? bonus1,
    Value<int>? bonus2,
    Value<int>? bonus3,
    Value<String>? beforeRemain,
    Value<String>? afterRemain,
    Value<String>? calculateStatus,
    Value<String>? calculateMessage,
    Value<int>? rowid,
  }) {
    return ResultsCompanion(
      id: id ?? this.id,
      mainDataId: mainDataId ?? this.mainDataId,
      levelConfigId: levelConfigId ?? this.levelConfigId,
      sortedIdx: sortedIdx ?? this.sortedIdx,
      originalIdx: originalIdx ?? this.originalIdx,
      type: type ?? this.type,
      paymentDueDate: paymentDueDate ?? this.paymentDueDate,
      bonusIncrease: bonusIncrease ?? this.bonusIncrease,
      nonBonusIncrease: nonBonusIncrease ?? this.nonBonusIncrease,
      bonusDecrease: bonusDecrease ?? this.bonusDecrease,
      nonBonusDecrease: nonBonusDecrease ?? this.nonBonusDecrease,
      paymentDueDate1: paymentDueDate1 ?? this.paymentDueDate1,
      paymentDueDate2: paymentDueDate2 ?? this.paymentDueDate2,
      paymentDueDate3: paymentDueDate3 ?? this.paymentDueDate3,
      bonus1: bonus1 ?? this.bonus1,
      bonus2: bonus2 ?? this.bonus2,
      bonus3: bonus3 ?? this.bonus3,
      beforeRemain: beforeRemain ?? this.beforeRemain,
      afterRemain: afterRemain ?? this.afterRemain,
      calculateStatus: calculateStatus ?? this.calculateStatus,
      calculateMessage: calculateMessage ?? this.calculateMessage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mainDataId.present) {
      map['main_data_id'] = Variable<String>(mainDataId.value);
    }
    if (levelConfigId.present) {
      map['level_config_id'] = Variable<String>(levelConfigId.value);
    }
    if (sortedIdx.present) {
      map['sorted_idx'] = Variable<int>(sortedIdx.value);
    }
    if (originalIdx.present) {
      map['original_idx'] = Variable<int>(originalIdx.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (paymentDueDate.present) {
      map['payment_due_date'] = Variable<DateTime>(paymentDueDate.value);
    }
    if (bonusIncrease.present) {
      map['bonus_increase'] = Variable<int>(bonusIncrease.value);
    }
    if (nonBonusIncrease.present) {
      map['non_bonus_increase'] = Variable<int>(nonBonusIncrease.value);
    }
    if (bonusDecrease.present) {
      map['bonus_decrease'] = Variable<int>(bonusDecrease.value);
    }
    if (nonBonusDecrease.present) {
      map['non_bonus_decrease'] = Variable<int>(nonBonusDecrease.value);
    }
    if (paymentDueDate1.present) {
      map['payment_due_date1'] = Variable<DateTime>(paymentDueDate1.value);
    }
    if (paymentDueDate2.present) {
      map['payment_due_date2'] = Variable<DateTime>(paymentDueDate2.value);
    }
    if (paymentDueDate3.present) {
      map['payment_due_date3'] = Variable<DateTime>(paymentDueDate3.value);
    }
    if (bonus1.present) {
      map['bonus1'] = Variable<int>(bonus1.value);
    }
    if (bonus2.present) {
      map['bonus2'] = Variable<int>(bonus2.value);
    }
    if (bonus3.present) {
      map['bonus3'] = Variable<int>(bonus3.value);
    }
    if (beforeRemain.present) {
      map['before_remain'] = Variable<String>(beforeRemain.value);
    }
    if (afterRemain.present) {
      map['after_remain'] = Variable<String>(afterRemain.value);
    }
    if (calculateStatus.present) {
      map['calculate_status'] = Variable<String>(calculateStatus.value);
    }
    if (calculateMessage.present) {
      map['calculate_message'] = Variable<String>(calculateMessage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ResultsCompanion(')
          ..write('id: $id, ')
          ..write('mainDataId: $mainDataId, ')
          ..write('levelConfigId: $levelConfigId, ')
          ..write('sortedIdx: $sortedIdx, ')
          ..write('originalIdx: $originalIdx, ')
          ..write('type: $type, ')
          ..write('paymentDueDate: $paymentDueDate, ')
          ..write('bonusIncrease: $bonusIncrease, ')
          ..write('nonBonusIncrease: $nonBonusIncrease, ')
          ..write('bonusDecrease: $bonusDecrease, ')
          ..write('nonBonusDecrease: $nonBonusDecrease, ')
          ..write('paymentDueDate1: $paymentDueDate1, ')
          ..write('paymentDueDate2: $paymentDueDate2, ')
          ..write('paymentDueDate3: $paymentDueDate3, ')
          ..write('bonus1: $bonus1, ')
          ..write('bonus2: $bonus2, ')
          ..write('bonus3: $bonus3, ')
          ..write('beforeRemain: $beforeRemain, ')
          ..write('afterRemain: $afterRemain, ')
          ..write('calculateStatus: $calculateStatus, ')
          ..write('calculateMessage: $calculateMessage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $HolidayConfigsTable holidayConfigs = $HolidayConfigsTable(this);
  late final $LevelConfigsTable levelConfigs = $LevelConfigsTable(this);
  late final $MainDatasTable mainDatas = $MainDatasTable(this);
  late final $ResultsTable results = $ResultsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    holidayConfigs,
    levelConfigs,
    mainDatas,
    results,
  ];
}

typedef $$HolidayConfigsTableCreateCompanionBuilder =
    HolidayConfigsCompanion Function({
      required String id,
      required DateTime date,
      Value<String?> name,
      Value<String?> description,
      Value<int> rowid,
    });
typedef $$HolidayConfigsTableUpdateCompanionBuilder =
    HolidayConfigsCompanion Function({
      Value<String> id,
      Value<DateTime> date,
      Value<String?> name,
      Value<String?> description,
      Value<int> rowid,
    });

class $$HolidayConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $HolidayConfigsTable> {
  $$HolidayConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HolidayConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $HolidayConfigsTable> {
  $$HolidayConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HolidayConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HolidayConfigsTable> {
  $$HolidayConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
}

class $$HolidayConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HolidayConfigsTable,
          HolidayConfig,
          $$HolidayConfigsTableFilterComposer,
          $$HolidayConfigsTableOrderingComposer,
          $$HolidayConfigsTableAnnotationComposer,
          $$HolidayConfigsTableCreateCompanionBuilder,
          $$HolidayConfigsTableUpdateCompanionBuilder,
          (
            HolidayConfig,
            BaseReferences<_$AppDatabase, $HolidayConfigsTable, HolidayConfig>,
          ),
          HolidayConfig,
          PrefetchHooks Function()
        > {
  $$HolidayConfigsTableTableManager(
    _$AppDatabase db,
    $HolidayConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HolidayConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HolidayConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HolidayConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HolidayConfigsCompanion(
                id: id,
                date: date,
                name: name,
                description: description,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime date,
                Value<String?> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => HolidayConfigsCompanion.insert(
                id: id,
                date: date,
                name: name,
                description: description,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HolidayConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HolidayConfigsTable,
      HolidayConfig,
      $$HolidayConfigsTableFilterComposer,
      $$HolidayConfigsTableOrderingComposer,
      $$HolidayConfigsTableAnnotationComposer,
      $$HolidayConfigsTableCreateCompanionBuilder,
      $$HolidayConfigsTableUpdateCompanionBuilder,
      (
        HolidayConfig,
        BaseReferences<_$AppDatabase, $HolidayConfigsTable, HolidayConfig>,
      ),
      HolidayConfig,
      PrefetchHooks Function()
    >;
typedef $$LevelConfigsTableCreateCompanionBuilder =
    LevelConfigsCompanion Function({
      required String id,
      required String seasonalCode,
      required String salesMethod,
      required int paymentPeriod,
      required int paymentPeriod1,
      required int paymentPeriod2,
      required int paymentPeriod3,
      Value<DateTime?> paymentDueDate1,
      Value<DateTime?> paymentDueDate2,
      Value<DateTime?> paymentDueDate3,
      Value<int> rowid,
    });
typedef $$LevelConfigsTableUpdateCompanionBuilder =
    LevelConfigsCompanion Function({
      Value<String> id,
      Value<String> seasonalCode,
      Value<String> salesMethod,
      Value<int> paymentPeriod,
      Value<int> paymentPeriod1,
      Value<int> paymentPeriod2,
      Value<int> paymentPeriod3,
      Value<DateTime?> paymentDueDate1,
      Value<DateTime?> paymentDueDate2,
      Value<DateTime?> paymentDueDate3,
      Value<int> rowid,
    });

final class $$LevelConfigsTableReferences
    extends BaseReferences<_$AppDatabase, $LevelConfigsTable, LevelConfig> {
  $$LevelConfigsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ResultsTable, List<Result>> _resultsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.results,
    aliasName: $_aliasNameGenerator(
      db.levelConfigs.id,
      db.results.levelConfigId,
    ),
  );

  $$ResultsTableProcessedTableManager get resultsRefs {
    final manager = $$ResultsTableTableManager(
      $_db,
      $_db.results,
    ).filter((f) => f.levelConfigId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_resultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LevelConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $LevelConfigsTable> {
  $$LevelConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seasonalCode => $composableBuilder(
    column: $table.seasonalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salesMethod => $composableBuilder(
    column: $table.salesMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentPeriod => $composableBuilder(
    column: $table.paymentPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentPeriod1 => $composableBuilder(
    column: $table.paymentPeriod1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentPeriod2 => $composableBuilder(
    column: $table.paymentPeriod2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentPeriod3 => $composableBuilder(
    column: $table.paymentPeriod3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDueDate1 => $composableBuilder(
    column: $table.paymentDueDate1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDueDate2 => $composableBuilder(
    column: $table.paymentDueDate2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDueDate3 => $composableBuilder(
    column: $table.paymentDueDate3,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> resultsRefs(
    Expression<bool> Function($$ResultsTableFilterComposer f) f,
  ) {
    final $$ResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.results,
      getReferencedColumn: (t) => t.levelConfigId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultsTableFilterComposer(
            $db: $db,
            $table: $db.results,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LevelConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $LevelConfigsTable> {
  $$LevelConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seasonalCode => $composableBuilder(
    column: $table.seasonalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salesMethod => $composableBuilder(
    column: $table.salesMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentPeriod => $composableBuilder(
    column: $table.paymentPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentPeriod1 => $composableBuilder(
    column: $table.paymentPeriod1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentPeriod2 => $composableBuilder(
    column: $table.paymentPeriod2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentPeriod3 => $composableBuilder(
    column: $table.paymentPeriod3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDueDate1 => $composableBuilder(
    column: $table.paymentDueDate1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDueDate2 => $composableBuilder(
    column: $table.paymentDueDate2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDueDate3 => $composableBuilder(
    column: $table.paymentDueDate3,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LevelConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LevelConfigsTable> {
  $$LevelConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get seasonalCode => $composableBuilder(
    column: $table.seasonalCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get salesMethod => $composableBuilder(
    column: $table.salesMethod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentPeriod => $composableBuilder(
    column: $table.paymentPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentPeriod1 => $composableBuilder(
    column: $table.paymentPeriod1,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentPeriod2 => $composableBuilder(
    column: $table.paymentPeriod2,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentPeriod3 => $composableBuilder(
    column: $table.paymentPeriod3,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDueDate1 => $composableBuilder(
    column: $table.paymentDueDate1,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDueDate2 => $composableBuilder(
    column: $table.paymentDueDate2,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDueDate3 => $composableBuilder(
    column: $table.paymentDueDate3,
    builder: (column) => column,
  );

  Expression<T> resultsRefs<T extends Object>(
    Expression<T> Function($$ResultsTableAnnotationComposer a) f,
  ) {
    final $$ResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.results,
      getReferencedColumn: (t) => t.levelConfigId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.results,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LevelConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LevelConfigsTable,
          LevelConfig,
          $$LevelConfigsTableFilterComposer,
          $$LevelConfigsTableOrderingComposer,
          $$LevelConfigsTableAnnotationComposer,
          $$LevelConfigsTableCreateCompanionBuilder,
          $$LevelConfigsTableUpdateCompanionBuilder,
          (LevelConfig, $$LevelConfigsTableReferences),
          LevelConfig,
          PrefetchHooks Function({bool resultsRefs})
        > {
  $$LevelConfigsTableTableManager(_$AppDatabase db, $LevelConfigsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LevelConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LevelConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LevelConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> seasonalCode = const Value.absent(),
                Value<String> salesMethod = const Value.absent(),
                Value<int> paymentPeriod = const Value.absent(),
                Value<int> paymentPeriod1 = const Value.absent(),
                Value<int> paymentPeriod2 = const Value.absent(),
                Value<int> paymentPeriod3 = const Value.absent(),
                Value<DateTime?> paymentDueDate1 = const Value.absent(),
                Value<DateTime?> paymentDueDate2 = const Value.absent(),
                Value<DateTime?> paymentDueDate3 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LevelConfigsCompanion(
                id: id,
                seasonalCode: seasonalCode,
                salesMethod: salesMethod,
                paymentPeriod: paymentPeriod,
                paymentPeriod1: paymentPeriod1,
                paymentPeriod2: paymentPeriod2,
                paymentPeriod3: paymentPeriod3,
                paymentDueDate1: paymentDueDate1,
                paymentDueDate2: paymentDueDate2,
                paymentDueDate3: paymentDueDate3,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String seasonalCode,
                required String salesMethod,
                required int paymentPeriod,
                required int paymentPeriod1,
                required int paymentPeriod2,
                required int paymentPeriod3,
                Value<DateTime?> paymentDueDate1 = const Value.absent(),
                Value<DateTime?> paymentDueDate2 = const Value.absent(),
                Value<DateTime?> paymentDueDate3 = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LevelConfigsCompanion.insert(
                id: id,
                seasonalCode: seasonalCode,
                salesMethod: salesMethod,
                paymentPeriod: paymentPeriod,
                paymentPeriod1: paymentPeriod1,
                paymentPeriod2: paymentPeriod2,
                paymentPeriod3: paymentPeriod3,
                paymentDueDate1: paymentDueDate1,
                paymentDueDate2: paymentDueDate2,
                paymentDueDate3: paymentDueDate3,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LevelConfigsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({resultsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (resultsRefs) db.results],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (resultsRefs)
                    await $_getPrefetchedData<
                      LevelConfig,
                      $LevelConfigsTable,
                      Result
                    >(
                      currentTable: table,
                      referencedTable: $$LevelConfigsTableReferences
                          ._resultsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$LevelConfigsTableReferences(
                            db,
                            table,
                            p0,
                          ).resultsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.levelConfigId == item.id,
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

typedef $$LevelConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LevelConfigsTable,
      LevelConfig,
      $$LevelConfigsTableFilterComposer,
      $$LevelConfigsTableOrderingComposer,
      $$LevelConfigsTableAnnotationComposer,
      $$LevelConfigsTableCreateCompanionBuilder,
      $$LevelConfigsTableUpdateCompanionBuilder,
      (LevelConfig, $$LevelConfigsTableReferences),
      LevelConfig,
      PrefetchHooks Function({bool resultsRefs})
    >;
typedef $$MainDatasTableCreateCompanionBuilder =
    MainDatasCompanion Function({
      required String id,
      Value<int?> idx,
      Value<DateTime?> documentDate,
      Value<String?> documentNumber,
      Value<String?> description,
      Value<String?> correspondingAccount,
      Value<int?> increase,
      Value<int?> decrease,
      Value<int?> adjustIncrease,
      Value<int?> adjustDecrease,
      Value<int?> endAmount,
      required String seasonalCode,
      Value<int?> paymentPeriod,
      required String customerCode,
      Value<String?> customerName,
      required String branch,
      Value<String?> code,
      required String salesMethod,
      Value<int> rowid,
    });
typedef $$MainDatasTableUpdateCompanionBuilder =
    MainDatasCompanion Function({
      Value<String> id,
      Value<int?> idx,
      Value<DateTime?> documentDate,
      Value<String?> documentNumber,
      Value<String?> description,
      Value<String?> correspondingAccount,
      Value<int?> increase,
      Value<int?> decrease,
      Value<int?> adjustIncrease,
      Value<int?> adjustDecrease,
      Value<int?> endAmount,
      Value<String> seasonalCode,
      Value<int?> paymentPeriod,
      Value<String> customerCode,
      Value<String?> customerName,
      Value<String> branch,
      Value<String?> code,
      Value<String> salesMethod,
      Value<int> rowid,
    });

final class $$MainDatasTableReferences
    extends BaseReferences<_$AppDatabase, $MainDatasTable, MainData> {
  $$MainDatasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ResultsTable, List<Result>> _resultsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.results,
    aliasName: $_aliasNameGenerator(db.mainDatas.id, db.results.mainDataId),
  );

  $$ResultsTableProcessedTableManager get resultsRefs {
    final manager = $$ResultsTableTableManager(
      $_db,
      $_db.results,
    ).filter((f) => f.mainDataId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_resultsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MainDatasTableFilterComposer
    extends Composer<_$AppDatabase, $MainDatasTable> {
  $$MainDatasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get documentDate => $composableBuilder(
    column: $table.documentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get correspondingAccount => $composableBuilder(
    column: $table.correspondingAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get increase => $composableBuilder(
    column: $table.increase,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decrease => $composableBuilder(
    column: $table.decrease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get adjustIncrease => $composableBuilder(
    column: $table.adjustIncrease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get adjustDecrease => $composableBuilder(
    column: $table.adjustDecrease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endAmount => $composableBuilder(
    column: $table.endAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get seasonalCode => $composableBuilder(
    column: $table.seasonalCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paymentPeriod => $composableBuilder(
    column: $table.paymentPeriod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get branch => $composableBuilder(
    column: $table.branch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get salesMethod => $composableBuilder(
    column: $table.salesMethod,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> resultsRefs(
    Expression<bool> Function($$ResultsTableFilterComposer f) f,
  ) {
    final $$ResultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.results,
      getReferencedColumn: (t) => t.mainDataId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultsTableFilterComposer(
            $db: $db,
            $table: $db.results,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MainDatasTableOrderingComposer
    extends Composer<_$AppDatabase, $MainDatasTable> {
  $$MainDatasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idx => $composableBuilder(
    column: $table.idx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get documentDate => $composableBuilder(
    column: $table.documentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get correspondingAccount => $composableBuilder(
    column: $table.correspondingAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get increase => $composableBuilder(
    column: $table.increase,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decrease => $composableBuilder(
    column: $table.decrease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get adjustIncrease => $composableBuilder(
    column: $table.adjustIncrease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get adjustDecrease => $composableBuilder(
    column: $table.adjustDecrease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endAmount => $composableBuilder(
    column: $table.endAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get seasonalCode => $composableBuilder(
    column: $table.seasonalCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paymentPeriod => $composableBuilder(
    column: $table.paymentPeriod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get branch => $composableBuilder(
    column: $table.branch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get salesMethod => $composableBuilder(
    column: $table.salesMethod,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MainDatasTableAnnotationComposer
    extends Composer<_$AppDatabase, $MainDatasTable> {
  $$MainDatasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get idx =>
      $composableBuilder(column: $table.idx, builder: (column) => column);

  GeneratedColumn<DateTime> get documentDate => $composableBuilder(
    column: $table.documentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get documentNumber => $composableBuilder(
    column: $table.documentNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get correspondingAccount => $composableBuilder(
    column: $table.correspondingAccount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get increase =>
      $composableBuilder(column: $table.increase, builder: (column) => column);

  GeneratedColumn<int> get decrease =>
      $composableBuilder(column: $table.decrease, builder: (column) => column);

  GeneratedColumn<int> get adjustIncrease => $composableBuilder(
    column: $table.adjustIncrease,
    builder: (column) => column,
  );

  GeneratedColumn<int> get adjustDecrease => $composableBuilder(
    column: $table.adjustDecrease,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endAmount =>
      $composableBuilder(column: $table.endAmount, builder: (column) => column);

  GeneratedColumn<String> get seasonalCode => $composableBuilder(
    column: $table.seasonalCode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get paymentPeriod => $composableBuilder(
    column: $table.paymentPeriod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerCode => $composableBuilder(
    column: $table.customerCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get customerName => $composableBuilder(
    column: $table.customerName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get branch =>
      $composableBuilder(column: $table.branch, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get salesMethod => $composableBuilder(
    column: $table.salesMethod,
    builder: (column) => column,
  );

  Expression<T> resultsRefs<T extends Object>(
    Expression<T> Function($$ResultsTableAnnotationComposer a) f,
  ) {
    final $$ResultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.results,
      getReferencedColumn: (t) => t.mainDataId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ResultsTableAnnotationComposer(
            $db: $db,
            $table: $db.results,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MainDatasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MainDatasTable,
          MainData,
          $$MainDatasTableFilterComposer,
          $$MainDatasTableOrderingComposer,
          $$MainDatasTableAnnotationComposer,
          $$MainDatasTableCreateCompanionBuilder,
          $$MainDatasTableUpdateCompanionBuilder,
          (MainData, $$MainDatasTableReferences),
          MainData,
          PrefetchHooks Function({bool resultsRefs})
        > {
  $$MainDatasTableTableManager(_$AppDatabase db, $MainDatasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MainDatasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MainDatasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MainDatasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int?> idx = const Value.absent(),
                Value<DateTime?> documentDate = const Value.absent(),
                Value<String?> documentNumber = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> correspondingAccount = const Value.absent(),
                Value<int?> increase = const Value.absent(),
                Value<int?> decrease = const Value.absent(),
                Value<int?> adjustIncrease = const Value.absent(),
                Value<int?> adjustDecrease = const Value.absent(),
                Value<int?> endAmount = const Value.absent(),
                Value<String> seasonalCode = const Value.absent(),
                Value<int?> paymentPeriod = const Value.absent(),
                Value<String> customerCode = const Value.absent(),
                Value<String?> customerName = const Value.absent(),
                Value<String> branch = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String> salesMethod = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MainDatasCompanion(
                id: id,
                idx: idx,
                documentDate: documentDate,
                documentNumber: documentNumber,
                description: description,
                correspondingAccount: correspondingAccount,
                increase: increase,
                decrease: decrease,
                adjustIncrease: adjustIncrease,
                adjustDecrease: adjustDecrease,
                endAmount: endAmount,
                seasonalCode: seasonalCode,
                paymentPeriod: paymentPeriod,
                customerCode: customerCode,
                customerName: customerName,
                branch: branch,
                code: code,
                salesMethod: salesMethod,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<int?> idx = const Value.absent(),
                Value<DateTime?> documentDate = const Value.absent(),
                Value<String?> documentNumber = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> correspondingAccount = const Value.absent(),
                Value<int?> increase = const Value.absent(),
                Value<int?> decrease = const Value.absent(),
                Value<int?> adjustIncrease = const Value.absent(),
                Value<int?> adjustDecrease = const Value.absent(),
                Value<int?> endAmount = const Value.absent(),
                required String seasonalCode,
                Value<int?> paymentPeriod = const Value.absent(),
                required String customerCode,
                Value<String?> customerName = const Value.absent(),
                required String branch,
                Value<String?> code = const Value.absent(),
                required String salesMethod,
                Value<int> rowid = const Value.absent(),
              }) => MainDatasCompanion.insert(
                id: id,
                idx: idx,
                documentDate: documentDate,
                documentNumber: documentNumber,
                description: description,
                correspondingAccount: correspondingAccount,
                increase: increase,
                decrease: decrease,
                adjustIncrease: adjustIncrease,
                adjustDecrease: adjustDecrease,
                endAmount: endAmount,
                seasonalCode: seasonalCode,
                paymentPeriod: paymentPeriod,
                customerCode: customerCode,
                customerName: customerName,
                branch: branch,
                code: code,
                salesMethod: salesMethod,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MainDatasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({resultsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (resultsRefs) db.results],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (resultsRefs)
                    await $_getPrefetchedData<
                      MainData,
                      $MainDatasTable,
                      Result
                    >(
                      currentTable: table,
                      referencedTable: $$MainDatasTableReferences
                          ._resultsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MainDatasTableReferences(db, table, p0).resultsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.mainDataId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MainDatasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MainDatasTable,
      MainData,
      $$MainDatasTableFilterComposer,
      $$MainDatasTableOrderingComposer,
      $$MainDatasTableAnnotationComposer,
      $$MainDatasTableCreateCompanionBuilder,
      $$MainDatasTableUpdateCompanionBuilder,
      (MainData, $$MainDatasTableReferences),
      MainData,
      PrefetchHooks Function({bool resultsRefs})
    >;
typedef $$ResultsTableCreateCompanionBuilder =
    ResultsCompanion Function({
      required String id,
      required String mainDataId,
      Value<String?> levelConfigId,
      Value<int> sortedIdx,
      Value<int> originalIdx,
      Value<int> type,
      Value<DateTime?> paymentDueDate,
      Value<int> bonusIncrease,
      Value<int> nonBonusIncrease,
      Value<int> bonusDecrease,
      Value<int> nonBonusDecrease,
      Value<DateTime?> paymentDueDate1,
      Value<DateTime?> paymentDueDate2,
      Value<DateTime?> paymentDueDate3,
      Value<int> bonus1,
      Value<int> bonus2,
      Value<int> bonus3,
      Value<String> beforeRemain,
      Value<String> afterRemain,
      Value<String> calculateStatus,
      Value<String> calculateMessage,
      Value<int> rowid,
    });
typedef $$ResultsTableUpdateCompanionBuilder =
    ResultsCompanion Function({
      Value<String> id,
      Value<String> mainDataId,
      Value<String?> levelConfigId,
      Value<int> sortedIdx,
      Value<int> originalIdx,
      Value<int> type,
      Value<DateTime?> paymentDueDate,
      Value<int> bonusIncrease,
      Value<int> nonBonusIncrease,
      Value<int> bonusDecrease,
      Value<int> nonBonusDecrease,
      Value<DateTime?> paymentDueDate1,
      Value<DateTime?> paymentDueDate2,
      Value<DateTime?> paymentDueDate3,
      Value<int> bonus1,
      Value<int> bonus2,
      Value<int> bonus3,
      Value<String> beforeRemain,
      Value<String> afterRemain,
      Value<String> calculateStatus,
      Value<String> calculateMessage,
      Value<int> rowid,
    });

final class $$ResultsTableReferences
    extends BaseReferences<_$AppDatabase, $ResultsTable, Result> {
  $$ResultsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MainDatasTable _mainDataIdTable(_$AppDatabase db) =>
      db.mainDatas.createAlias(
        $_aliasNameGenerator(db.results.mainDataId, db.mainDatas.id),
      );

  $$MainDatasTableProcessedTableManager get mainDataId {
    final $_column = $_itemColumn<String>('main_data_id')!;

    final manager = $$MainDatasTableTableManager(
      $_db,
      $_db.mainDatas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mainDataIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LevelConfigsTable _levelConfigIdTable(_$AppDatabase db) =>
      db.levelConfigs.createAlias(
        $_aliasNameGenerator(db.results.levelConfigId, db.levelConfigs.id),
      );

  $$LevelConfigsTableProcessedTableManager? get levelConfigId {
    final $_column = $_itemColumn<String>('level_config_id');
    if ($_column == null) return null;
    final manager = $$LevelConfigsTableTableManager(
      $_db,
      $_db.levelConfigs,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_levelConfigIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ResultsTableFilterComposer
    extends Composer<_$AppDatabase, $ResultsTable> {
  $$ResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortedIdx => $composableBuilder(
    column: $table.sortedIdx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get originalIdx => $composableBuilder(
    column: $table.originalIdx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDueDate => $composableBuilder(
    column: $table.paymentDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusIncrease => $composableBuilder(
    column: $table.bonusIncrease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nonBonusIncrease => $composableBuilder(
    column: $table.nonBonusIncrease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonusDecrease => $composableBuilder(
    column: $table.bonusDecrease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nonBonusDecrease => $composableBuilder(
    column: $table.nonBonusDecrease,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDueDate1 => $composableBuilder(
    column: $table.paymentDueDate1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDueDate2 => $composableBuilder(
    column: $table.paymentDueDate2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDueDate3 => $composableBuilder(
    column: $table.paymentDueDate3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonus1 => $composableBuilder(
    column: $table.bonus1,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonus2 => $composableBuilder(
    column: $table.bonus2,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bonus3 => $composableBuilder(
    column: $table.bonus3,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeRemain => $composableBuilder(
    column: $table.beforeRemain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterRemain => $composableBuilder(
    column: $table.afterRemain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculateStatus => $composableBuilder(
    column: $table.calculateStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calculateMessage => $composableBuilder(
    column: $table.calculateMessage,
    builder: (column) => ColumnFilters(column),
  );

  $$MainDatasTableFilterComposer get mainDataId {
    final $$MainDatasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mainDataId,
      referencedTable: $db.mainDatas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MainDatasTableFilterComposer(
            $db: $db,
            $table: $db.mainDatas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LevelConfigsTableFilterComposer get levelConfigId {
    final $$LevelConfigsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.levelConfigId,
      referencedTable: $db.levelConfigs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LevelConfigsTableFilterComposer(
            $db: $db,
            $table: $db.levelConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResultsTableOrderingComposer
    extends Composer<_$AppDatabase, $ResultsTable> {
  $$ResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortedIdx => $composableBuilder(
    column: $table.sortedIdx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get originalIdx => $composableBuilder(
    column: $table.originalIdx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDueDate => $composableBuilder(
    column: $table.paymentDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusIncrease => $composableBuilder(
    column: $table.bonusIncrease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nonBonusIncrease => $composableBuilder(
    column: $table.nonBonusIncrease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonusDecrease => $composableBuilder(
    column: $table.bonusDecrease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nonBonusDecrease => $composableBuilder(
    column: $table.nonBonusDecrease,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDueDate1 => $composableBuilder(
    column: $table.paymentDueDate1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDueDate2 => $composableBuilder(
    column: $table.paymentDueDate2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDueDate3 => $composableBuilder(
    column: $table.paymentDueDate3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonus1 => $composableBuilder(
    column: $table.bonus1,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonus2 => $composableBuilder(
    column: $table.bonus2,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bonus3 => $composableBuilder(
    column: $table.bonus3,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeRemain => $composableBuilder(
    column: $table.beforeRemain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterRemain => $composableBuilder(
    column: $table.afterRemain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculateStatus => $composableBuilder(
    column: $table.calculateStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calculateMessage => $composableBuilder(
    column: $table.calculateMessage,
    builder: (column) => ColumnOrderings(column),
  );

  $$MainDatasTableOrderingComposer get mainDataId {
    final $$MainDatasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mainDataId,
      referencedTable: $db.mainDatas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MainDatasTableOrderingComposer(
            $db: $db,
            $table: $db.mainDatas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LevelConfigsTableOrderingComposer get levelConfigId {
    final $$LevelConfigsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.levelConfigId,
      referencedTable: $db.levelConfigs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LevelConfigsTableOrderingComposer(
            $db: $db,
            $table: $db.levelConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ResultsTable> {
  $$ResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get sortedIdx =>
      $composableBuilder(column: $table.sortedIdx, builder: (column) => column);

  GeneratedColumn<int> get originalIdx => $composableBuilder(
    column: $table.originalIdx,
    builder: (column) => column,
  );

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDueDate => $composableBuilder(
    column: $table.paymentDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bonusIncrease => $composableBuilder(
    column: $table.bonusIncrease,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nonBonusIncrease => $composableBuilder(
    column: $table.nonBonusIncrease,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bonusDecrease => $composableBuilder(
    column: $table.bonusDecrease,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nonBonusDecrease => $composableBuilder(
    column: $table.nonBonusDecrease,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDueDate1 => $composableBuilder(
    column: $table.paymentDueDate1,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDueDate2 => $composableBuilder(
    column: $table.paymentDueDate2,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get paymentDueDate3 => $composableBuilder(
    column: $table.paymentDueDate3,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bonus1 =>
      $composableBuilder(column: $table.bonus1, builder: (column) => column);

  GeneratedColumn<int> get bonus2 =>
      $composableBuilder(column: $table.bonus2, builder: (column) => column);

  GeneratedColumn<int> get bonus3 =>
      $composableBuilder(column: $table.bonus3, builder: (column) => column);

  GeneratedColumn<String> get beforeRemain => $composableBuilder(
    column: $table.beforeRemain,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterRemain => $composableBuilder(
    column: $table.afterRemain,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calculateStatus => $composableBuilder(
    column: $table.calculateStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calculateMessage => $composableBuilder(
    column: $table.calculateMessage,
    builder: (column) => column,
  );

  $$MainDatasTableAnnotationComposer get mainDataId {
    final $$MainDatasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mainDataId,
      referencedTable: $db.mainDatas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MainDatasTableAnnotationComposer(
            $db: $db,
            $table: $db.mainDatas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LevelConfigsTableAnnotationComposer get levelConfigId {
    final $$LevelConfigsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.levelConfigId,
      referencedTable: $db.levelConfigs,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LevelConfigsTableAnnotationComposer(
            $db: $db,
            $table: $db.levelConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ResultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ResultsTable,
          Result,
          $$ResultsTableFilterComposer,
          $$ResultsTableOrderingComposer,
          $$ResultsTableAnnotationComposer,
          $$ResultsTableCreateCompanionBuilder,
          $$ResultsTableUpdateCompanionBuilder,
          (Result, $$ResultsTableReferences),
          Result,
          PrefetchHooks Function({bool mainDataId, bool levelConfigId})
        > {
  $$ResultsTableTableManager(_$AppDatabase db, $ResultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ResultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ResultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mainDataId = const Value.absent(),
                Value<String?> levelConfigId = const Value.absent(),
                Value<int> sortedIdx = const Value.absent(),
                Value<int> originalIdx = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<DateTime?> paymentDueDate = const Value.absent(),
                Value<int> bonusIncrease = const Value.absent(),
                Value<int> nonBonusIncrease = const Value.absent(),
                Value<int> bonusDecrease = const Value.absent(),
                Value<int> nonBonusDecrease = const Value.absent(),
                Value<DateTime?> paymentDueDate1 = const Value.absent(),
                Value<DateTime?> paymentDueDate2 = const Value.absent(),
                Value<DateTime?> paymentDueDate3 = const Value.absent(),
                Value<int> bonus1 = const Value.absent(),
                Value<int> bonus2 = const Value.absent(),
                Value<int> bonus3 = const Value.absent(),
                Value<String> beforeRemain = const Value.absent(),
                Value<String> afterRemain = const Value.absent(),
                Value<String> calculateStatus = const Value.absent(),
                Value<String> calculateMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResultsCompanion(
                id: id,
                mainDataId: mainDataId,
                levelConfigId: levelConfigId,
                sortedIdx: sortedIdx,
                originalIdx: originalIdx,
                type: type,
                paymentDueDate: paymentDueDate,
                bonusIncrease: bonusIncrease,
                nonBonusIncrease: nonBonusIncrease,
                bonusDecrease: bonusDecrease,
                nonBonusDecrease: nonBonusDecrease,
                paymentDueDate1: paymentDueDate1,
                paymentDueDate2: paymentDueDate2,
                paymentDueDate3: paymentDueDate3,
                bonus1: bonus1,
                bonus2: bonus2,
                bonus3: bonus3,
                beforeRemain: beforeRemain,
                afterRemain: afterRemain,
                calculateStatus: calculateStatus,
                calculateMessage: calculateMessage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mainDataId,
                Value<String?> levelConfigId = const Value.absent(),
                Value<int> sortedIdx = const Value.absent(),
                Value<int> originalIdx = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<DateTime?> paymentDueDate = const Value.absent(),
                Value<int> bonusIncrease = const Value.absent(),
                Value<int> nonBonusIncrease = const Value.absent(),
                Value<int> bonusDecrease = const Value.absent(),
                Value<int> nonBonusDecrease = const Value.absent(),
                Value<DateTime?> paymentDueDate1 = const Value.absent(),
                Value<DateTime?> paymentDueDate2 = const Value.absent(),
                Value<DateTime?> paymentDueDate3 = const Value.absent(),
                Value<int> bonus1 = const Value.absent(),
                Value<int> bonus2 = const Value.absent(),
                Value<int> bonus3 = const Value.absent(),
                Value<String> beforeRemain = const Value.absent(),
                Value<String> afterRemain = const Value.absent(),
                Value<String> calculateStatus = const Value.absent(),
                Value<String> calculateMessage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ResultsCompanion.insert(
                id: id,
                mainDataId: mainDataId,
                levelConfigId: levelConfigId,
                sortedIdx: sortedIdx,
                originalIdx: originalIdx,
                type: type,
                paymentDueDate: paymentDueDate,
                bonusIncrease: bonusIncrease,
                nonBonusIncrease: nonBonusIncrease,
                bonusDecrease: bonusDecrease,
                nonBonusDecrease: nonBonusDecrease,
                paymentDueDate1: paymentDueDate1,
                paymentDueDate2: paymentDueDate2,
                paymentDueDate3: paymentDueDate3,
                bonus1: bonus1,
                bonus2: bonus2,
                bonus3: bonus3,
                beforeRemain: beforeRemain,
                afterRemain: afterRemain,
                calculateStatus: calculateStatus,
                calculateMessage: calculateMessage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ResultsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mainDataId = false, levelConfigId = false}) {
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
                    if (mainDataId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mainDataId,
                                referencedTable: $$ResultsTableReferences
                                    ._mainDataIdTable(db),
                                referencedColumn: $$ResultsTableReferences
                                    ._mainDataIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (levelConfigId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.levelConfigId,
                                referencedTable: $$ResultsTableReferences
                                    ._levelConfigIdTable(db),
                                referencedColumn: $$ResultsTableReferences
                                    ._levelConfigIdTable(db)
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

typedef $$ResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ResultsTable,
      Result,
      $$ResultsTableFilterComposer,
      $$ResultsTableOrderingComposer,
      $$ResultsTableAnnotationComposer,
      $$ResultsTableCreateCompanionBuilder,
      $$ResultsTableUpdateCompanionBuilder,
      (Result, $$ResultsTableReferences),
      Result,
      PrefetchHooks Function({bool mainDataId, bool levelConfigId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$HolidayConfigsTableTableManager get holidayConfigs =>
      $$HolidayConfigsTableTableManager(_db, _db.holidayConfigs);
  $$LevelConfigsTableTableManager get levelConfigs =>
      $$LevelConfigsTableTableManager(_db, _db.levelConfigs);
  $$MainDatasTableTableManager get mainDatas =>
      $$MainDatasTableTableManager(_db, _db.mainDatas);
  $$ResultsTableTableManager get results =>
      $$ResultsTableTableManager(_db, _db.results);
}
