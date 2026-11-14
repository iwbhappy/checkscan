import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:ui' show Size;
import 'package:mobile_scanner/mobile_scanner.dart';
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

/// Camera preview and document analysis share the same native scanner owner.
final scannerControllerProvider = Provider<MobileScannerController>((ref) {
  final controller = MobileScannerController(
    autoStart: false,
    formats: [BarcodeFormat.qrCode],
    cameraResolution: const Size(1280, 720),
    autoZoom: true,
  );
  ref.onDispose(() {
    unawaited(controller.dispose().catchError((Object _) {}));
  });
  return controller;
});

final importActivityProvider = NotifierProvider<ImportActivity, int>(
  ImportActivity.new,
);

class ImportActivity extends Notifier<int> {
  @override
  int build() => 0;
  void begin() => state++;
  void end() => state = (state - 1).clamp(0, 100);
}

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
