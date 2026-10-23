import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('StoreRow')
class Stores extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get bin => text().nullable().unique()();
  TextColumn get address => text().nullable()();
}

@DataClassName('CategoryRow')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  TextColumn get icon => text()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DataClassName('ReceiptRow')
@TableIndex(name: 'receipts_date_time_idx', columns: {#dateTimeUtc})
class Receipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get storeId => integer().nullable().references(
    Stores,
    #id,
    onDelete: KeyAction.setNull,
  )();
  TextColumn get ofdName => text().nullable()();
  TextColumn get kkmRegNumber => text().nullable()();
  TextColumn get kkmSerial => text().nullable()();
  TextColumn get fiscalSign => text().nullable()();
  TextColumn get receiptNumber => text().nullable()();
  DateTimeColumn get dateTimeUtc => dateTime()();

  // Null means that the QR wall-clock time has an unconfirmed offset. The
  // source URL preserves that time verbatim until the OFD confirms it.
  IntColumn get tzOffsetMin => integer().nullable()();
  IntColumn get totalMinor => integer()();
  IntColumn get discountMinor => integer().nullable()();
  IntColumn get vatMinor => integer().nullable()();
  RealColumn get vatRate => real().nullable()();
  TextColumn get currency => text().withDefault(const Constant('KZT'))();
  TextColumn get paymentType => text().nullable()();
  TextColumn get sourceUrl => text()();
  TextColumn get dedupKey => text().unique()();
  TextColumn get status => text()
      .withDefault(const Constant('pending'))
      // Drift reads this declaration and generates the CHECK expression.
      // ignore: recursive_getters
      .check(status.isIn(const ['pending', 'ok', 'error']))();
  BoolColumn get needsReview => boolean().withDefault(const Constant(false))();
  BoolColumn get edited => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  TextColumn get debugRaw => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ReceiptItemRow')
@TableIndex(name: 'receipt_items_receipt_idx', columns: {#receiptId})
@TableIndex(name: 'receipt_items_category_idx', columns: {#categoryId})
@TableIndex(name: 'receipt_items_barcode_idx', columns: {#barcode})
class ReceiptItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get receiptId =>
      integer().references(Receipts, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get name => text()();
  TextColumn get rawName => text()();
  TextColumn get barcode => text().nullable()();
  TextColumn get ntin => text().nullable()();
  RealColumn get quantity => real()();
  TextColumn get unit => text().nullable()();
  IntColumn get unitPriceMinor => integer()();
  IntColumn get sumMinor => integer()();
  IntColumn get discountMinor => integer().nullable()();
  IntColumn get categoryId => integer().nullable().references(
    Categories,
    #id,
    onDelete: KeyAction.setNull,
  )();
}

@DataClassName('CategoryRuleRow')
class CategoryRules extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Drift reads the self-reference to generate this column's SQL CHECK.
  TextColumn get kind =>
      // ignore: recursive_getters
      text().check(kind.isIn(const ['keyword', 'barcode']))();
  TextColumn get pattern => text()();
  IntColumn get categoryId =>
      integer().references(Categories, #id, onDelete: KeyAction.cascade)();
  BoolColumn get isUser => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {kind, pattern, isUser},
  ];
}

@DriftDatabase(
  tables: [Stores, Categories, Receipts, ReceiptItems, CategoryRules],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'checkscan'));

  static const otherCategoryId = 16;

  /// Receipts entered by hand have no QR: their dedupKey carries this prefix
  /// and their sourceUrl is empty.
  static const manualDedupPrefix = 'manual:';

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) async {
      await migrator.createAll();
      await _seedCategories();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<void> _seedCategories() async {
    const seeds = <(String, int, String)>[
      ('Продукты', 0xff26a69a, 'groceries'),
      ('Молочное', 0xff42a5f5, 'dairy'),
      ('Мясо и рыба', 0xffef5350, 'meat'),
      ('Овощи и фрукты', 0xff66bb6a, 'produce'),
      ('Хлеб и выпечка', 0xffffb74d, 'bread'),
      ('Сладости и снеки', 0xffab47bc, 'sweets'),
      ('Напитки', 0xff29b6f6, 'drink'),
      ('Алкоголь', 0xff7e57c2, 'alcohol'),
      ('Бытовая химия', 0xff26c6da, 'cleaning'),
      ('Гигиена и уход', 0xffec407a, 'care'),
      ('Аптека', 0xffef5350, 'pharmacy'),
      ('Одежда', 0xff5c6bc0, 'clothing'),
      ('Электроника', 0xff78909c, 'electronics'),
      ('Кафе и рестораны', 0xffff7043, 'restaurant'),
      ('Транспорт и топливо', 0xff8d6e63, 'transport'),
      ('Прочее', 0xff90a4ae, 'other'),
    ];
    await batch((batch) {
      for (var index = 0; index < seeds.length; index++) {
        final (name, color, icon) = seeds[index];
        batch.insert(
          categories,
          CategoriesCompanion.insert(
            id: Value(index + 1),
            name: name,
            color: color,
            icon: icon,
            isBuiltIn: const Value(true),
            sortOrder: Value(index),
          ),
        );
      }
    });
  }

  Future<ReceiptRow?> findReceiptByDedupKey(String key) => (select(
    receipts,
  )..where((row) => row.dedupKey.equals(key))).getSingleOrNull();

  // SQLite's unique constraint is the final guard against simultaneous scans.
  // An existing successful receipt is never replaced with a pending copy.
  Future<ReceiptRow> insertPending(ReceiptsCompanion receipt) =>
      transaction(() async {
        await into(receipts).insert(receipt, mode: InsertMode.insertOrIgnore);
        final saved = await findReceiptByDedupKey(receipt.dedupKey.value);
        if (saved == null) {
          throw StateError('Pending receipt could not be saved');
        }
        return saved;
      });

  Future<ReceiptDetailData?> getReceiptDetail(int receiptId) async {
    final receipt = await (select(
      receipts,
    )..where((row) => row.id.equals(receiptId))).getSingleOrNull();
    if (receipt == null) return null;
    final storeId = receipt.storeId;
    final store = storeId == null
        ? null
        : await (select(
            stores,
          )..where((row) => row.id.equals(storeId))).getSingleOrNull();
    final items =
        await (select(receiptItems)
              ..where((row) => row.receiptId.equals(receiptId))
              ..orderBy([(row) => OrderingTerm.asc(row.position)]))
            .get();
    return ReceiptDetailData(receipt: receipt, store: store, items: items);
  }

  Stream<ReceiptDetailData?> watchReceiptDetail(int receiptId) => customSelect(
    'SELECT id FROM receipts WHERE id = ?',
    variables: [Variable<int>(receiptId)],
    readsFrom: {receipts, stores, receiptItems},
  ).watch().asyncMap((_) => getReceiptDetail(receiptId));

  Future<int> saveReceipt(
    ReceiptsCompanion receipt,
    List<ReceiptItemsCompanion> items,
  ) => transaction(() async {
    final id = receipt.id.present
        ? receipt.id.value
        : await into(receipts).insert(receipt);
    if (receipt.id.present) {
      final changed =
          await (update(receipts)..where((row) => row.id.equals(id))).write(
            receipt.copyWith(updatedAt: Value(DateTime.now().toUtc())),
          );
      if (changed == 0) throw StateError('Receipt $id does not exist');
      await (delete(
        receiptItems,
      )..where((row) => row.receiptId.equals(id))).go();
    }
    await batch(
      (batch) => batch.insertAll(
        receiptItems,
        items.map((item) => item.copyWith(receiptId: Value(id))).toList(),
      ),
    );
    return id;
  });

  Future<int> deleteReceipt(int receiptId) =>
      (delete(receipts)..where((row) => row.id.equals(receiptId))).go();

  Future<List<ReceiptRow>> pendingReceipts({DateTime? dueBefore}) {
    final query = select(receipts)
      ..where((row) => row.status.equals('pending'));
    if (dueBefore != null) {
      query.where(
        (row) =>
            row.nextRetryAt.isNull() |
            row.nextRetryAt.isSmallerOrEqualValue(dueBefore),
      );
    }
    query.orderBy([(row) => OrderingTerm.asc(row.createdAt)]);
    return query.get();
  }

  Future<void> markRetry(
    int receiptId, {
    required DateTime nextRetryAt,
    required String error,
  }) => transaction(() async {
    final receipt = await (select(
      receipts,
    )..where((row) => row.id.equals(receiptId))).getSingle();
    await (update(receipts)..where((row) => row.id.equals(receiptId))).write(
      ReceiptsCompanion(
        status: const Value('pending'),
        retryCount: Value(receipt.retryCount + 1),
        nextRetryAt: Value(nextRetryAt),
        lastError: Value(error),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  });

  Stream<List<ReceiptListData>> watchHistory([
    ReceiptFilter filter = const ReceiptFilter(),
  ]) {
    final conditions = <String>[];
    final variables = <Variable>[];
    void condition(String expression, Variable value) {
      conditions.add(expression);
      variables.add(value);
    }

    if (filter.from != null) {
      condition(
        '(r.date_time_utc + COALESCE(r.tz_offset_min, 0) * 60) >= ?',
        Variable<DateTime>(calendarBoundary(filter.from!)),
      );
    }
    if (filter.until != null) {
      condition(
        '(r.date_time_utc + COALESCE(r.tz_offset_min, 0) * 60) < ?',
        Variable<DateTime>(calendarBoundary(filter.until!)),
      );
    }
    if (filter.storeId != null) {
      condition('r.store_id = ?', Variable<int>(filter.storeId!));
    }
    if (filter.categoryId != null) {
      conditions.add(
        '(r.category_id = ? OR EXISTS (SELECT 1 FROM '
        'receipt_items ci WHERE ci.receipt_id = r.id AND ci.category_id = ?))',
      );
      variables.addAll([
        Variable<int>(filter.categoryId!),
        Variable<int>(filter.categoryId!),
      ]);
    }
    if (filter.minMinor != null) {
      condition('r.total_minor >= ?', Variable<int>(filter.minMinor!));
    }
    if (filter.maxMinor != null) {
      condition('r.total_minor <= ?', Variable<int>(filter.maxMinor!));
    }
    final where = conditions.isEmpty ? '' : 'WHERE ${conditions.join(' AND ')}';
    return customSelect(
      '''SELECT r.*, s.name AS store_name, COUNT(i.id) AS item_count,
         GROUP_CONCAT(i.name, ' ') AS item_names
         FROM receipts r LEFT JOIN stores s ON s.id = r.store_id
         LEFT JOIN receipt_items i ON i.receipt_id = r.id
         $where GROUP BY r.id
         ORDER BY (r.date_time_utc + COALESCE(r.tz_offset_min, 0) * 60) DESC, r.id DESC''',
      variables: variables,
      readsFrom: {receipts, stores, receiptItems},
    ).watch().map((rows) {
      final search = filter.search.trim().toLowerCase();
      return rows
          .where((row) {
            if (search.isEmpty) return true;
            // SQLite's built-in LOWER/NOCASE only handles ASCII. Dart's Unicode
            // case conversion keeps Russian store and product searches useful.
            final text =
                '${row.readNullable<String>('store_name') ?? ''} '
                '${row.readNullable<String>('item_names') ?? ''}';
            return text.toLowerCase().contains(search);
          })
          .map(
            (row) => ReceiptListData(
              receipt: receipts.map(row.data),
              storeName: row.readNullable<String>('store_name'),
              itemCount: row.read<int>('item_count'),
            ),
          )
          .toList();
    });
  }

  Future<ExpenseSummary> expenseSummary(DateTime from, DateTime until) async {
    final row = await customSelect(
      '''SELECT COALESCE(SUM(total_minor), 0) AS total, COUNT(*) AS count
         FROM receipts WHERE (date_time_utc + COALESCE(tz_offset_min, 0) * 60) >= ?
         AND (date_time_utc + COALESCE(tz_offset_min, 0) * 60) < ?''',
      variables: [
        Variable<DateTime>(calendarBoundary(from)),
        Variable<DateTime>(calendarBoundary(until)),
      ],
      readsFrom: {receipts},
    ).getSingle();
    return ExpenseSummary(
      totalMinor: row.read<int>('total'),
      receiptCount: row.read<int>('count'),
    );
  }
}

extension ManualReceipt on ReceiptRow {
  bool get isManual => dedupKey.startsWith(AppDatabase.manualDedupPrefix);
}

class ReceiptDetailData {
  const ReceiptDetailData({
    required this.receipt,
    required this.store,
    required this.items,
  });

  final ReceiptRow receipt;
  final StoreRow? store;
  final List<ReceiptItemRow> items;
}

class ReceiptListData {
  const ReceiptListData({
    required this.receipt,
    required this.storeName,
    required this.itemCount,
  });

  final ReceiptRow receipt;
  final String? storeName;
  final int itemCount;
}

class ReceiptFilter {
  const ReceiptFilter({
    this.from,
    this.until,
    this.storeId,
    this.categoryId,
    this.minMinor,
    this.maxMinor,
    this.search = '',
  });

  /// Inclusive local calendar boundary, without device timezone conversion.
  final DateTime? from;

  /// Exclusive local calendar boundary, without device timezone conversion.
  final DateTime? until;
  final int? storeId;
  final int? categoryId;
  final int? minMinor;
  final int? maxMinor;
  final String search;
}

/// Represents calendar fields as a SQLite-comparable timestamp. This is not
/// an assumption about the timezone of a QR whose offset remains unknown.
DateTime calendarBoundary(DateTime date) => DateTime.utc(
  date.year,
  date.month,
  date.day,
  date.hour,
  date.minute,
  date.second,
);

class ExpenseSummary {
  const ExpenseSummary({required this.totalMinor, required this.receiptCount});

  final int totalMinor;
  final int receiptCount;

  int get averageMinor => receiptCount == 0
      ? 0
      : ((totalMinor.abs() + receiptCount ~/ 2) ~/ receiptCount) *
            totalMinor.sign;
}
