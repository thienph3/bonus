import 'package:drift/drift.dart';

class HolidayConfigs extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class LevelConfigs extends Table {
  TextColumn get id => text()();
  TextColumn get seasonalCode => text()();
  TextColumn get salesMethod => text()();
  IntColumn get paymentPeriod => integer()();
  IntColumn get paymentPeriod1 => integer()();
  IntColumn get paymentPeriod2 => integer()();
  IntColumn get paymentPeriod3 => integer()();
  DateTimeColumn get paymentDueDate1 => dateTime().nullable()();
  DateTimeColumn get paymentDueDate2 => dateTime().nullable()();
  DateTimeColumn get paymentDueDate3 => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class MainDatas extends Table {
  TextColumn get id => text()();
  IntColumn get idx => integer().nullable()();
  DateTimeColumn get documentDate => dateTime().nullable()();
  TextColumn get documentNumber => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get correspondingAccount => text().nullable()();
  IntColumn get increase => integer().nullable()();
  IntColumn get decrease => integer().nullable()();
  IntColumn get adjustIncrease => integer().nullable()();
  IntColumn get adjustDecrease => integer().nullable()();
  IntColumn get endAmount => integer().nullable()();
  TextColumn get seasonalCode => text()();
  IntColumn get paymentPeriod => integer().nullable()();
  TextColumn get customerCode => text()();
  TextColumn get customerName => text().nullable()();
  TextColumn get branch => text()();
  TextColumn get code => text().nullable()();
  TextColumn get salesMethod => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Results extends Table {
  TextColumn get id => text()();
  TextColumn get mainDataId => text().references(MainDatas, #id)();
  TextColumn get levelConfigId =>
      text().nullable().references(LevelConfigs, #id)();
  IntColumn get sortedIdx => integer().withDefault(const Constant(0))();
  IntColumn get originalIdx => integer().withDefault(const Constant(0))();
  IntColumn get type => integer().withDefault(const Constant(0))();
  DateTimeColumn get paymentDueDate => dateTime().nullable()();
  IntColumn get bonusIncrease => integer().withDefault(const Constant(0))();
  IntColumn get nonBonusIncrease => integer().withDefault(const Constant(0))();
  IntColumn get bonusDecrease => integer().withDefault(const Constant(0))();
  IntColumn get nonBonusDecrease => integer().withDefault(const Constant(0))();
  DateTimeColumn get paymentDueDate1 => dateTime().nullable()();
  DateTimeColumn get paymentDueDate2 => dateTime().nullable()();
  DateTimeColumn get paymentDueDate3 => dateTime().nullable()();
  IntColumn get bonus1 => integer().withDefault(const Constant(0))();
  IntColumn get bonus2 => integer().withDefault(const Constant(0))();
  IntColumn get bonus3 => integer().withDefault(const Constant(0))();
  TextColumn get beforeRemain =>
      text().withDefault(const Constant(''))();
  TextColumn get afterRemain =>
      text().withDefault(const Constant(''))();
  TextColumn get calculateStatus =>
      text().withDefault(const Constant('valid'))();
  TextColumn get calculateMessage =>
      text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}
