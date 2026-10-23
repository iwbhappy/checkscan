import 'package:checkscan/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  ReceiptsCompanion pending(String key, {int total = 200200, DateTime? date}) =>
      ReceiptsCompanion.insert(
        dedupKey: key,
        dateTimeUtc: date ?? DateTime.utc(2026, 10, 7, 15, 32, 59),
        totalMinor: total,
        sourceUrl:
            'https://consumer.oofd.kz?i=1462733895&f=010102236118'
            '&s=2002.00&t=20261007T153259',
      );

  ReceiptItemsCompanion item({int category = 2, int sum = 200200}) =>
      ReceiptItemsCompanion.insert(
        receiptId: 0,
        position: 0,
        name: 'Молоко',
        rawName: 'Сүт - Молоко',
        quantity: 1,
        unitPriceMinor: sum,
        sumMinor: sum,
        categoryId: Value(category),
      );

  test(
    'schema v1 creates all tables, indexes and built-in categories',
    () async {
      final categories = await db.select(db.categories).get();
      expect(categories, hasLength(16));
      expect(categories.last.id, AppDatabase.otherCategoryId);
      expect(categories.last.name, 'Прочее');
      expect(categories.every((category) => category.isBuiltIn), isTrue);
      final tables = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
          .get();
      expect(
        tables.map((row) => row.read<String>('name')),
        containsAll([
          'stores',
          'categories',
          'receipts',
          'receipt_items',
          'category_rules',
        ]),
      );
      final indexes = await db
          .customSelect("SELECT name FROM sqlite_master WHERE type = 'index'")
          .get();
      expect(
        indexes.map((row) => row.read<String>('name')),
        containsAll([
          'receipts_date_time_idx',
          'receipt_items_receipt_idx',
          'receipt_items_category_idx',
          'receipt_items_barcode_idx',
        ]),
      );
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), 1);
      final fk = await db.customSelect('PRAGMA foreign_keys').getSingle();
      expect(fk.read<int>('foreign_keys'), 1);
    },
  );

  test(
    'concurrent duplicate insertion preserves the original receipt',
    () async {
      final rows = await Future.wait([
        db.insertPending(pending('fiscal|10102236118|200200')),
        db.insertPending(pending('fiscal|10102236118|200200')),
      ]);
      expect(rows.first.id, rows.last.id);
      expect(await db.select(db.receipts).get(), hasLength(1));
      expect(rows.first.tzOffsetMin, isNull);
      expect(rows.first.currency, 'KZT');
      await (db.update(db.receipts)
            ..where((row) => row.id.equals(rows.first.id)))
          .write(const ReceiptsCompanion(status: Value('ok')));
      final duplicate = await db.insertPending(
        pending('fiscal|10102236118|200200'),
      );
      expect(duplicate.status, 'ok');
    },
  );

  test(
    'failed item replacement rolls back both receipt and old items',
    () async {
      final id = await db.saveReceipt(pending('atomic'), [item()]);
      await expectLater(
        db.saveReceipt(
          ReceiptsCompanion(id: Value(id), totalMinor: const Value(1)),
          [item(category: 999999, sum: 1)],
        ),
        throwsA(isA<Exception>()),
      );
      final detail = await db.getReceiptDetail(id);
      expect(detail!.receipt.totalMinor, 200200);
      expect(detail.items.single.sumMinor, 200200);
    },
  );

  test(
    'deletion cascades items and category deletion preserves receipt',
    () async {
      final categoryId = await db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: 'Своя',
              color: 0xff000000,
              icon: 'other',
            ),
          );
      final id = await db.saveReceipt(
        pending('cascade').copyWith(categoryId: Value(categoryId)),
        [item(category: categoryId)],
      );
      await (db.delete(
        db.categories,
      )..where((row) => row.id.equals(categoryId))).go();
      var detail = await db.getReceiptDetail(id);
      expect(detail!.receipt.categoryId, isNull);
      expect(detail.items.single.categoryId, isNull);
      await db.deleteReceipt(id);
      expect(await db.select(db.receiptItems).get(), isEmpty);
      detail = await db.getReceiptDetail(id);
      expect(detail, isNull);
    },
  );

  test(
    'retry metadata survives and pending selection respects due time',
    () async {
      final row = await db.insertPending(pending('retry'));
      final now = DateTime.utc(2026, 10, 7, 20);
      await db.markRetry(
        row.id,
        nextRetryAt: now.add(const Duration(minutes: 5)),
        error: 'offline',
      );
      expect(await db.pendingReceipts(dueBefore: now), isEmpty);
      final retry = (await db.pendingReceipts(
        dueBefore: now.add(const Duration(minutes: 5)),
      )).single;
      expect(retry.retryCount, 1);
      expect(retry.lastError, 'offline');
    },
  );

  test(
    'history finds Cyrillic products and combines amount/category filters',
    () async {
      await db.saveReceipt(pending('milk'), [item()]);
      await db.saveReceipt(pending('other', total: 500), [
        item(category: 16, sum: 500),
      ]);
      final found = await db
          .watchHistory(
            const ReceiptFilter(
              search: 'мОЛОКО',
              categoryId: 2,
              minMinor: 200000,
              maxMinor: 200500,
            ),
          )
          .first;
      expect(found, hasLength(1));
      expect(found.single.receipt.dedupKey, 'milk');
      expect(found.single.itemCount, 1);
    },
  );

  test('summary uses integer tiyn and an exclusive upper date bound', () async {
    await db.insertPending(pending('one', total: 29901));
    await db.insertPending(pending('two', total: 43502));
    await db.insertPending(
      pending('next', total: 999999, date: DateTime.utc(2026, 11)),
    );
    final summary = await db.expenseSummary(
      DateTime.utc(2026, 10),
      DateTime.utc(2026, 11),
    );
    expect(summary.totalMinor, 73403);
    expect(summary.receiptCount, 2);
    expect(summary.averageMinor, 36702);
  });

  test(
    'local calendar periods use recorded offsets and preserve unknown QR dates',
    () async {
      await db.insertPending(
        pending('pending-november', date: DateTime.utc(2026, 11, 1, 1)),
      );
      await db.insertPending(
        pending(
          'confirmed-november',
          date: DateTime.utc(2026, 10, 31, 21),
        ).copyWith(tzOffsetMin: const Value(300)),
      );
      await db.insertPending(
        pending(
          'other-offset-october',
          date: DateTime.utc(2026, 10, 31, 21),
        ).copyWith(tzOffsetMin: const Value(120)),
      );
      final october = await db
          .watchHistory(
            ReceiptFilter(from: DateTime(2026, 10), until: DateTime(2026, 11)),
          )
          .first;
      expect(october.map((row) => row.receipt.dedupKey), [
        'other-offset-october',
      ]);
      final november = await db
          .watchHistory(
            ReceiptFilter(from: DateTime(2026, 11), until: DateTime(2026, 12)),
          )
          .first;
      expect(november, hasLength(2));
      expect(november.map((row) => row.receipt.dedupKey), [
        'confirmed-november',
        'pending-november',
      ]);
      expect(
        (await db.expenseSummary(
          DateTime(2026, 11),
          DateTime(2026, 12),
        )).receiptCount,
        2,
      );
    },
  );
}
