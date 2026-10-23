import 'package:drift/drift.dart';

import '../db/app_database.dart';

class StatsRepository {
  StatsRepository(this.db);
  final AppDatabase db;

  /// [from] and [until] are local calendar fields, matching history filters.
  /// [until] is exclusive. Every status contributes its known receipt total.
  Stream<StatsData> watchStats(
    DateTime from,
    DateTime until, {
    String grouping = 'day',
  }) {
    if (!['day', 'week', 'month'].contains(grouping)) {
      throw ArgumentError.value(grouping, 'grouping');
    }
    if (!calendarBoundary(until).isAfter(calendarBoundary(from))) {
      throw ArgumentError('Конец периода должен быть позже начала');
    }
    return db
        .customSelect(
          'SELECT COUNT(*) AS count FROM receipts',
          readsFrom: {db.receipts, db.receiptItems, db.categories, db.stores},
        )
        .watch()
        .asyncMap((_) => db.transaction(() => _load(from, until, grouping)));
  }

  Future<StatsData> _load(
    DateTime from,
    DateTime until,
    String grouping,
  ) async {
    final start = calendarBoundary(from);
    final end = calendarBoundary(until);
    final variables = [Variable<DateTime>(start), Variable<DateTime>(end)];
    const selected = '''WITH selected AS (
      SELECT * FROM receipts WHERE
      (date_time_utc + COALESCE(tz_offset_min, 0) * 60) >= ? AND
      (date_time_utc + COALESCE(tz_offset_min, 0) * 60) < ?
    )''';
    final summary = await db.expenseSummary(start, end);
    final previousStart =
        start.day == 1 &&
            start.hour == 0 &&
            start.minute == 0 &&
            start.second == 0 &&
            end == DateTime.utc(start.year + 1, start.month, 1)
        ? DateTime.utc(start.year - 1, start.month, 1)
        : start.day == 1 &&
              start.hour == 0 &&
              start.minute == 0 &&
              start.second == 0 &&
              end == DateTime.utc(start.year, start.month + 1, 1)
        ? DateTime.utc(start.year, start.month - 1, 1)
        : start.subtract(end.difference(start));
    final previous = await db.expenseSummary(previousStart, start);
    final categoryRows = await db
        .customSelect(
          '''$selected,
      allocations AS (
        SELECT COALESCE(i.category_id, r.category_id, 16) AS category_id,
               i.sum_minor AS amount
        FROM selected r JOIN receipt_items i ON i.receipt_id = r.id
        UNION ALL
        SELECT COALESCE(r.category_id, 16) AS category_id,
               r.total_minor - COALESCE((SELECT SUM(i.sum_minor)
                 FROM receipt_items i WHERE i.receipt_id = r.id), 0) AS amount
        FROM selected r
      )
      SELECT c.id AS category_id, c.name, c.color, SUM(a.amount) AS total_minor
      FROM allocations a JOIN categories c ON c.id = a.category_id
      GROUP BY c.id HAVING SUM(a.amount) != 0 ORDER BY total_minor DESC, c.id''',
          variables: variables,
          readsFrom: {db.receipts, db.receiptItems, db.categories},
        )
        .get();
    // The residual allocation includes pending receipts and any discrepancy
    // in a needsReview receipt. Thus category totals always reconcile exactly
    // with the history total without subtracting the informational discount.
    final categories = categoryRows
        .map(
          (row) => CategoryExpense(
            categoryId: row.read<int>('category_id'),
            name: row.read<String>('name'),
            color: row.read<int>('color'),
            totalMinor: row.read<int>('total_minor'),
          ),
        )
        .toList();

    const wallTime = '(date_time_utc + COALESCE(tz_offset_min, 0) * 60)';
    final bucket = switch (grouping) {
      'month' => "strftime('%Y-%m', $wallTime, 'unixepoch')",
      'week' =>
        "date($wallTime, 'unixepoch', printf('-%d days', "
            "(CAST(strftime('%w', $wallTime, 'unixepoch') AS INTEGER) + 6) % 7))",
      _ => "strftime('%Y-%m-%d', $wallTime, 'unixepoch')",
    };
    final bucketRows = await db
        .customSelect(
          '''$selected
      SELECT $bucket AS label, SUM(total_minor) AS total_minor
      FROM selected GROUP BY label ORDER BY label''',
          variables: variables,
          readsFrom: {db.receipts},
        )
        .get();
    final buckets = bucketRows
        .map(
          (row) => PeriodExpense(
            label: row.read<String>('label'),
            totalMinor: row.read<int>('total_minor'),
          ),
        )
        .toList();
    final storeRows = await db
        .customSelect(
          '''$selected
      SELECT s.id AS store_id, COALESCE(s.name, 'Чек без магазина') AS name,
             SUM(r.total_minor) AS total_minor, COUNT(*) AS receipt_count
      FROM selected r LEFT JOIN stores s ON s.id = r.store_id
      GROUP BY s.id ORDER BY total_minor DESC, name LIMIT 10''',
          variables: variables,
          readsFrom: {db.receipts, db.stores},
        )
        .get();
    final stores = storeRows
        .map(
          (row) => StoreExpense(
            storeId: row.readNullable<int>('store_id'),
            name: row.read<String>('name'),
            totalMinor: row.read<int>('total_minor'),
            receiptCount: row.read<int>('receipt_count'),
          ),
        )
        .toList();
    Future<List<ProductExpense>> products(String ordering) async {
      final rows = await db
          .customSelect(
            '''$selected
        SELECT MIN(i.name) AS name, SUM(i.sum_minor) AS total_minor,
               COUNT(DISTINCT r.id) AS purchase_count
        FROM selected r JOIN receipt_items i ON i.receipt_id = r.id
        GROUP BY COALESCE(NULLIF(i.barcode, ''), i.name)
        ORDER BY $ordering, name LIMIT 10''',
            variables: variables,
            readsFrom: {db.receipts, db.receiptItems},
          )
          .get();
      return rows
          .map(
            (row) => ProductExpense(
              name: row.read<String>('name'),
              totalMinor: row.read<int>('total_minor'),
              purchaseCount: row.read<int>('purchase_count'),
            ),
          )
          .toList();
    }

    return StatsData(
      summary: summary,
      previousTotalMinor: previous.totalMinor,
      categories: categories,
      buckets: buckets,
      stores: stores,
      productsByAmount: await products('total_minor DESC'),
      productsByFrequency: await products(
        'purchase_count DESC, total_minor DESC',
      ),
    );
  }
}

class StatsData {
  const StatsData({
    required this.summary,
    required this.previousTotalMinor,
    required this.categories,
    required this.buckets,
    required this.stores,
    required this.productsByAmount,
    required this.productsByFrequency,
  });
  final ExpenseSummary summary;
  final int previousTotalMinor;
  final List<CategoryExpense> categories;
  final List<PeriodExpense> buckets;
  final List<StoreExpense> stores;
  final List<ProductExpense> productsByAmount;
  final List<ProductExpense> productsByFrequency;
  double? get changePercent => previousTotalMinor == 0
      ? null
      : (summary.totalMinor - previousTotalMinor) *
            100 /
            previousTotalMinor.abs();
}

class CategoryExpense {
  const CategoryExpense({
    required this.categoryId,
    required this.name,
    required this.color,
    required this.totalMinor,
  });
  final int categoryId;
  final String name;
  final int color;
  final int totalMinor;
}

class PeriodExpense {
  const PeriodExpense({required this.label, required this.totalMinor});
  final String label;
  final int totalMinor;
}

class StoreExpense {
  const StoreExpense({
    required this.storeId,
    required this.name,
    required this.totalMinor,
    required this.receiptCount,
  });
  final int? storeId;
  final String name;
  final int totalMinor;
  final int receiptCount;
}

class ProductExpense {
  const ProductExpense({
    required this.name,
    required this.totalMinor,
    required this.purchaseCount,
  });
  final String name;
  final int totalMinor;
  final int purchaseCount;
}
