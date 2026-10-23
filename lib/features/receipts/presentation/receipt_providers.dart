import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/preferences.dart';
import '../../../core/utils/money.dart';
import '../../../data/db/app_database.dart';

String receiptMoney(WidgetRef ref, int minor) =>
    Money.format(minor, currency: ref.watch(currencySymbolProvider));

final receiptHistoryProvider = StreamProvider.autoDispose
    .family<List<ReceiptListData>, ReceiptFilter>((ref, filter) {
      return ref.watch(receiptRepositoryProvider).watchHistory(filter);
    });

final receiptDetailProvider = StreamProvider.autoDispose
    .family<ReceiptDetailData?, int>((ref, id) {
      return ref.watch(receiptRepositoryProvider).watchDetail(id);
    });

final receiptCategoriesProvider = StreamProvider.autoDispose<List<CategoryRow>>(
  (ref) {
    final db = ref.watch(databaseProvider);
    return (db.select(
      db.categories,
    )..orderBy([(row) => OrderingTerm.asc(row.sortOrder)])).watch();
  },
);

final receiptStoresProvider = StreamProvider.autoDispose<List<StoreRow>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(
    db.stores,
  )..orderBy([(row) => OrderingTerm.asc(row.name)])).watch();
});
