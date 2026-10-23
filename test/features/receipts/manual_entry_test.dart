import 'package:checkscan/app/l10n.dart';
import 'package:checkscan/app/providers.dart';
import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/data/ofd/ofd_provider_registry.dart';
import 'package:checkscan/data/repositories/backup_repository.dart';
import 'package:checkscan/data/repositories/receipt_repository.dart';
import 'package:checkscan/features/receipts/presentation/receipt_detail_screen.dart';
import 'package:checkscan/features/receipts/presentation/receipt_editor.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AppDatabase db;
  late ReceiptRepository repository;

  setUpAll(() => initializeDateFormatting('ru_RU'));
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ReceiptRepository(
      db,
      OfdProviderRegistry([]),
      now: () => DateTime.utc(2026, 10, 11, 9),
    );
  });
  tearDown(() async {
    repository.dispose();
    await db.close();
  });

  const items = [
    ReceiptItemEdit(
      name: 'Хлеб',
      quantity: 2,
      unitPriceMinor: 15000,
      sumMinor: 30000,
      categoryId: 5,
    ),
    ReceiptItemEdit(
      name: 'Сыр',
      quantity: 0.35,
      unitPriceMinor: 400000,
      sumMinor: 140000,
      categoryId: 2,
    ),
  ];

  Future<int> create({String store = 'Рынок'}) => repository.createManual(
    storeName: store,
    dateTimeUtc: DateTime.utc(2026, 10, 11, 5),
    items: items,
  );

  test('manual purchase is saved as a finished receipt without QR', () async {
    final id = await create();
    final detail = (await db.getReceiptDetail(id))!;
    expect(detail.receipt.isManual, isTrue);
    expect(detail.receipt.status, 'ok');
    expect(detail.receipt.sourceUrl, '');
    expect(detail.receipt.totalMinor, 170000);
    // The dominant item category becomes the receipt category.
    expect(detail.receipt.categoryId, 2);
    expect(detail.store?.name, 'Рынок');
    expect(detail.items.map((item) => item.quantity), [2, 0.35]);

    // Never queued for an OFD download.
    expect(await db.pendingReceipts(), isEmpty);
    expect(await repository.retry(id), isNotNull);
  });

  test('manual purchases get distinct keys and reuse the same store', () async {
    final first = await create();
    final second = await create(store: ' Рынок ');
    final rows = await db.select(db.receipts).get();
    expect(rows.map((row) => row.id), [first, second]);
    expect(rows[0].dedupKey, isNot(rows[1].dedupKey));
    expect(await db.select(db.stores).get(), hasLength(1));
  });

  test('manual purchase requires a store and at least one item', () async {
    await expectLater(
      repository.createManual(
        storeName: 'Рынок',
        dateTimeUtc: DateTime.utc(2026),
        items: const [],
      ),
      throwsFormatException,
    );
    await expectLater(create(store: '  '), throwsFormatException);
    expect(await db.select(db.receipts).get(), isEmpty);
  });

  test('manual purchase survives JSON backup and re-import once', () async {
    await create();
    final backup = await BackupRepository(db).exportJson();
    final target = AppDatabase(NativeDatabase.memory());
    addTearDown(target.close);
    final importer = BackupRepository(target);
    final first = await importer.importJson(backup);
    expect(first.imported, 1);
    final second = await importer.importJson(backup);
    expect(second.imported, 0);
    final restored = await target.select(target.receipts).getSingle();
    expect(restored.isManual, isTrue);
    expect(restored.totalMinor, 170000);
    expect(await target.select(target.receiptItems).get(), hasLength(2));
  });

  testWidgets('user types a purchase by hand and lands on the new receipt', (
    tester,
  ) async {
    await db
        .into(db.categoryRules)
        .insert(
          CategoryRulesCompanion.insert(
            kind: 'keyword',
            pattern: 'молоко',
            categoryId: 2,
          ),
        );
    final router = GoRouter(
      initialLocation: '/receipts/new',
      routes: [
        GoRoute(
          path: '/receipts/new',
          builder: (_, _) => const ReceiptEditor(),
        ),
        GoRoute(
          path: '/receipts/:id',
          builder: (_, state) =>
              ReceiptDetailScreen(id: int.parse(state.pathParameters['id']!)),
        ),
      ],
    );
    addTearDown(router.dispose);
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(db),
            receiptRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp.router(
            locale: const Locale('ru'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Новая покупка'), findsOneWidget);
      Future<void> show(Finder target) async {
        await tester.scrollUntilVisible(
          target,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.pumpAndSettle();
      }

      // Saving with no items is refused.
      await tester.enterText(
        find.byKey(const ValueKey('receipt-store')),
        'Базар',
      );
      await show(find.byKey(const ValueKey('save-receipt')));
      await tester.tap(find.byKey(const ValueKey('save-receipt')));
      await tester.pumpAndSettle();
      expect(find.text('Добавьте хотя бы одну позицию'), findsOneWidget);
      expect(await db.select(db.receipts).get(), isEmpty);
      // Let the SnackBar expire so it no longer covers the bottom buttons.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await show(find.text('Добавить позицию'));
      await tester.tap(find.text('Добавить позицию'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const ValueKey('item-name')), 'Молоко');
      await tester.enterText(find.byKey(const ValueKey('item-quantity')), '2');
      await tester.enterText(find.byKey(const ValueKey('item-price')), '450');
      await tester.pumpAndSettle();
      // Category suggested from the keyword rule, sum calculated from price.
      expect(find.text('Молочное'), findsOneWidget);
      expect(
        tester
            .widget<TextFormField>(find.byKey(const ValueKey('item-sum')))
            .controller!
            .text,
        '900.00',
      );
      await tester.tap(find.byKey(const ValueKey('save-item')));
      await tester.pumpAndSettle();
      await show(find.byKey(const ValueKey('edited-total')));
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('edited-total'))).data,
        contains('900,00'),
      );

      await show(find.byKey(const ValueKey('save-receipt')));
      await tester.tap(find.byKey(const ValueKey('save-receipt')));
      await tester.pumpAndSettle();

      final saved = await db.select(db.receipts).getSingle();
      expect(saved.isManual, isTrue);
      expect(saved.totalMinor, 90000);
      expect(saved.categoryId, 2);
      final item = await db.select(db.receiptItems).getSingle();
      expect(item.categoryId, 2);
      expect(item.quantity, 2);
      expect(find.text('Добавлено вручную'), findsOneWidget);
      expect(find.text('Открыть в ОФД'), findsNothing);
    } finally {
      // Dispose watched Drift queries before the fake clock stops.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
