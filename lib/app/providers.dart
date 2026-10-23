import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/db/app_database.dart';
import '../data/ofd/kazakhtelecom_ofd_provider.dart';
import '../data/ofd/ofd_provider_registry.dart';
import '../data/repositories/receipt_repository.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/stats_repository.dart';
import '../data/repositories/backup_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final ofdRegistryProvider = Provider<OfdProviderRegistry>((ref) {
  return OfdProviderRegistry([
    KazakhtelecomOfdProvider(retainDebugRaw: kDebugMode),
  ]);
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final repository = ReceiptRepository(
    ref.watch(databaseProvider),
    ref.watch(ofdRegistryProvider),
  );
  ref.onDispose(repository.dispose);
  return repository;
});

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.watch(databaseProvider)),
);
final categoriesProvider = StreamProvider<List<CategoryRow>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchCategories(),
);
final categoryRulesProvider = StreamProvider<List<CategoryRuleRow>>(
  (ref) => ref.watch(categoryRepositoryProvider).watchRules(),
);
final statsRepositoryProvider = Provider<StatsRepository>(
  (ref) => StatsRepository(ref.watch(databaseProvider)),
);
final backupRepositoryProvider = Provider<BackupRepository>(
  (ref) => BackupRepository(ref.watch(databaseProvider)),
);
