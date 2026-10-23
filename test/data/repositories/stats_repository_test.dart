import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/data/repositories/stats_repository.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late StatsRepository repository;
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = StatsRepository(db);
  });
  tearDown(() => db.close());

  ReceiptItemsCompanion item(
    int amount,
    int category, {
    String name = 'Молоко',
  }) => ReceiptItemsCompanion.insert(
    receiptId: 0,
    position: 0,
    name: name,
    rawName: name,
    quantity: 1,
    unitPriceMinor: amount,
    sumMinor: amount,
    categoryId: Value(category),
  );

  Future<int> receipt(
    String key,
    int amount, {
    List<ReceiptItemsCompanion> items = const [],
    int? category,
    DateTime? date,
    int? offset,
    int? storeId,
  }) => db.saveReceipt(
    ReceiptsCompanion.insert(
      dateTimeUtc: date ?? DateTime.utc(2026, 10, 7),
      totalMinor: amount,
      sourceUrl: 'https://consumer.oofd.kz',
      dedupKey: key,
      categoryId: Value(category),
      tzOffsetMin: Value(offset),
      storeId: Value(storeId),
    ),
    items,
  );

  test(
    'SQL categories reconcile exact receipt totals including pending and mismatches',
    () async {
      await receipt(
        'normal',
        20000,
        category: 2,
        items: [
          item(12000, 2),
          item(8000, 5, name: 'Хлеб'),
        ],
      );
      await receipt('review', 10000, category: 2, items: [item(9000, 2)]);
      await receipt('pending', 12345);
      final stats = await repository
          .watchStats(DateTime(2026, 10), DateTime(2026, 11))
          .first;
      expect(stats.summary.totalMinor, 42345);
      expect(stats.summary.receiptCount, 3);
      expect(
        stats.categories.fold<int>(
          0,
          (sum, category) => sum + category.totalMinor,
        ),
        stats.summary.totalMinor,
      );
      expect(
        stats.categories.singleWhere((row) => row.categoryId == 2).totalMinor,
        22000,
      );
      expect(
        stats.categories.singleWhere((row) => row.categoryId == 16).totalMinor,
        12345,
      );
      expect(stats.buckets.single.totalMinor, 42345);
    },
  );

  test(
    'calendar bounds and chart days agree for known and unknown offsets',
    () async {
      await receipt(
        'known',
        101,
        date: DateTime.utc(2026, 10, 31, 23),
        offset: 300,
      );
      await receipt('unknown', 202, date: DateTime.utc(2026, 11, 1, 2));
      await receipt(
        'october',
        999,
        date: DateTime.utc(2026, 10, 31, 20),
        offset: 120,
      );
      final stats = await repository
          .watchStats(DateTime(2026, 11), DateTime(2026, 12))
          .first;
      expect(stats.summary.totalMinor, 303);
      expect(stats.buckets.single.label, '2026-11-01');
      expect(stats.buckets.single.totalMinor, 303);
      expect(stats.previousTotalMinor, 999);
    },
  );

  test(
    'top products frequency counts purchases instead of duplicate lines',
    () async {
      final storeId = await db
          .into(db.stores)
          .insert(StoresCompanion.insert(name: 'Магазин'));
      await receipt(
        'first',
        300,
        storeId: storeId,
        items: [item(100, 2), item(200, 2)],
      );
      await receipt('second', 400, storeId: storeId, items: [item(400, 2)]);
      final stats = await repository
          .watchStats(DateTime(2026, 10), DateTime(2026, 11), grouping: 'week')
          .first;
      expect(stats.productsByFrequency.single.purchaseCount, 2);
      expect(stats.productsByAmount.single.totalMinor, 700);
      expect(stats.stores.single.receiptCount, 2);
      expect(stats.stores.single.totalMinor, 700);
      expect(stats.buckets.single.label, '2026-10-05');
    },
  );

  test('empty period has a stable zero summary and no charts', () async {
    final stats = await repository
        .watchStats(DateTime(2026, 10), DateTime(2026, 11))
        .first;
    expect(stats.summary.totalMinor, 0);
    expect(stats.summary.averageMinor, 0);
    expect(stats.changePercent, isNull);
    expect(stats.categories, isEmpty);
    expect(stats.buckets, isEmpty);
  });

  test(
    'overcounted item allocations retain signed residual and exact grand total',
    () async {
      await receipt('review-over', 10000, category: 2, items: [item(20000, 5)]);
      final stats = await repository
          .watchStats(DateTime(2026, 10), DateTime(2026, 11))
          .first;
      expect(
        stats.categories.singleWhere((row) => row.categoryId == 2).totalMinor,
        -10000,
      );
      expect(
        stats.categories.singleWhere((row) => row.categoryId == 5).totalMinor,
        20000,
      );
      expect(
        stats.categories.fold<int>(0, (sum, row) => sum + row.totalMinor),
        stats.summary.totalMinor,
      );
    },
  );

  test('a calendar month compares with the entire previous month', () async {
    await receipt('october-first', 101, date: DateTime.utc(2026, 10, 1));
    await receipt('october-last', 202, date: DateTime.utc(2026, 10, 31));
    await receipt('november-first', 606, date: DateTime.utc(2026, 11, 1));
    final stats = await repository
        .watchStats(DateTime(2026, 11), DateTime(2026, 12))
        .first;
    expect(stats.previousTotalMinor, 303);
    expect(stats.summary.totalMinor, 606);
    expect(stats.changePercent, 100);
  });
}
