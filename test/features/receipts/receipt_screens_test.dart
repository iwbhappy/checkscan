import 'package:checkscan/app/l10n.dart';
import 'package:checkscan/app/providers.dart';
import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/data/ofd/ofd_provider_registry.dart';
import 'package:checkscan/data/repositories/receipt_repository.dart';
import 'package:checkscan/features/receipts/presentation/history_screen.dart';
import 'package:checkscan/features/receipts/presentation/receipt_detail_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AppDatabase db;
  late ReceiptRepository repository;

  setUpAll(() => initializeDateFormatting('ru_RU'));
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = ReceiptRepository(db, OfdProviderRegistry([]));
  });
  tearDown(() async {
    repository.dispose();
    await db.close();
  });

  Future<int> seed({String status = 'ok', bool review = false}) async {
    final store = await db
        .into(db.stores)
        .insert(
          StoresCompanion.insert(
            name: 'Тестовый магазин',
            address: const Value('Павлодар'),
          ),
        );
    return db.saveReceipt(
      ReceiptsCompanion.insert(
        storeId: Value(status == 'ok' ? store : null),
        dateTimeUtc: DateTime.utc(2026, 10, 7, status == 'ok' ? 12 : 15, 32),
        tzOffsetMin: Value(status == 'ok' ? 300 : null),
        totalMinor: status == 'ok' ? 50000 : 200200,
        sourceUrl:
            'http://consumer.oofd.kz?i=1462733895&f=010102236118&s=2002.00&t=20261007T153259',
        dedupKey: 'test-$status',
        status: Value(status),
        needsReview: Value(review),
      ),
      status == 'ok'
          ? [
              ReceiptItemsCompanion.insert(
                receiptId: 0,
                position: 0,
                name: 'Молоко',
                rawName: 'Сүт - Молоко',
                quantity: 1,
                unitPriceMinor: 29900,
                sumMinor: 29900,
                categoryId: const Value(2),
              ),
              ReceiptItemsCompanion.insert(
                receiptId: 0,
                position: 1,
                name: 'Хлеб',
                rawName: 'Хлеб',
                quantity: 1,
                unitPriceMinor: 20100,
                sumMinor: 20100,
                categoryId: const Value(5),
              ),
            ]
          : [],
    );
  }

  Widget app(Widget screen) => ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      receiptRepositoryProvider.overrideWithValue(repository),
    ],
    child: MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: screen,
    ),
  );

  void screenTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      try {
        await body(tester);
      } finally {
        // Drift closes canceled watched queries on the next event-loop tick.
        // Dispose Riverpod before Flutter stops pumping the test's fake clock.
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    });
  }

  Future<void> reveal(WidgetTester tester, Finder target) async {
    if (target.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        target,
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView).last,
              matching: find.byType(Scrollable),
            )
            .first,
      );
    }
    await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
    // A jump updates scroll position first; hit testing needs the next layout.
    await tester.pumpAndSettle();
  }

  screenTest('history searches Russian items and deletion can be undone', (
    tester,
  ) async {
    final id = await seed(review: true);
    await tester.pumpWidget(app(const HistoryScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Тестовый магазин'), findsOneWidget);
    expect(find.text('500,00 ₸'), findsOneWidget);
    expect(find.text('Проверить'), findsOneWidget);
    expect(find.textContaining('17:32'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'МОЛОКО');
    await tester.pumpAndSettle();
    expect(find.text('Тестовый магазин'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'апельсин');
    await tester.pumpAndSettle();
    expect(find.text('Покупки не найдены'), findsOneWidget);

    await tester.tap(find.byTooltip('Очистить поиск'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Удалить'));
    await tester.pumpAndSettle();
    expect(await db.getReceiptDetail(id), isNull);
    expect(find.text('Чек удалён'), findsOneWidget);
    await tester.tap(find.text('Отменить'));
    await tester.pumpAndSettle();
    expect((await db.getReceiptDetail(id))!.items, hasLength(2));
    expect(find.text('Тестовый магазин'), findsOneWidget);
  });

  screenTest('history applies amount filter and can reset it', (tester) async {
    await seed();
    await tester.pumpWidget(app(const HistoryScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Фильтры'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Сумма от'),
      '600',
    );
    await reveal(tester, find.text('Применить'));
    await tester.tap(find.text('Применить'));
    await tester.pumpAndSettle();
    expect(find.text('Покупки не найдены'), findsOneWidget);

    await tester.tap(find.byTooltip('Фильтры'));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('Сбросить'));
    await tester.tap(find.text('Сбросить'));
    await tester.pumpAndSettle();
    expect(find.text('Тестовый магазин'), findsOneWidget);
  });

  screenTest('pending detail preserves QR amount and offers retry', (
    tester,
  ) async {
    final id = await seed(status: 'pending');
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(app(ReceiptDetailScreen(id: id)));
    await tester.pumpAndSettle();
    expect(find.text('2 002,00 ₸'), findsOneWidget);
    expect(find.byTooltip('Редактировать чек'), findsNothing);
    await reveal(tester, find.text('Повторить'));
    expect(find.text('Повторить'), findsOneWidget);
    expect(find.textContaining('Сначала загрузите позиции'), findsOneWidget);
    expect((await db.getReceiptDetail(id))!.receipt.totalMinor, 200200);
    expect(tester.takeException(), isNull);
  });

  screenTest('manual category change can create a remembered rule', (
    tester,
  ) async {
    final id = await seed();
    await tester.pumpWidget(app(ReceiptDetailScreen(id: id)));
    await tester.pumpAndSettle();
    await reveal(tester, find.text('Молочное'));
    await tester.tap(find.text('Молочное'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Продукты'));
    await tester.pumpAndSettle();
    expect(find.text('Запомнить категорию?'), findsOneWidget);
    await tester.tap(find.text('Запомнить'));
    await tester.pumpAndSettle();
    final saved = await db.getReceiptDetail(id);
    expect(saved!.items.first.categoryId, 1);
    final rules = await db.select(db.categoryRules).get();
    expect(rules, hasLength(1));
    expect(rules.single.pattern, '=молоко');
    expect(rules.single.isUser, isTrue);
    expect(tester.takeException(), isNull);
  });

  screenTest('editing adds fractional item and recalculates persisted total', (
    tester,
  ) async {
    final id = await seed();
    await tester.pumpWidget(app(ReceiptDetailScreen(id: id)));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Редактировать чек'));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('delete-item-1')));
    await tester.tap(find.byKey(const ValueKey('delete-item-1')));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('edited-total')));
    expect(find.text('Итого: 299,00 ₸'), findsOneWidget);

    await reveal(tester, find.text('Добавить позицию'));
    await tester.tap(find.text('Добавить позицию'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('item-name')),
      'Весовой товар',
    );
    await tester.enterText(
      find.byKey(const ValueKey('item-quantity')),
      '0,534',
    );
    await tester.enterText(find.byKey(const ValueKey('item-price')), '100,00');
    final sumField = tester.widget<TextFormField>(
      find.byKey(const ValueKey('item-sum')),
    );
    expect(sumField.controller!.text, '53.40');
    await reveal(tester, find.byKey(const ValueKey('save-item')));
    await tester.tap(find.byKey(const ValueKey('save-item')));
    await tester.pumpAndSettle();
    await reveal(tester, find.byKey(const ValueKey('edited-total')));
    expect(find.text('Итого: 352,40 ₸'), findsOneWidget);

    await reveal(tester, find.byKey(const ValueKey('save-receipt')));
    await tester.tap(find.byKey(const ValueKey('save-receipt')));
    await tester.pumpAndSettle();
    final saved = await db.getReceiptDetail(id);
    expect(saved!.receipt.totalMinor, 35240);
    expect(saved.receipt.edited, isTrue);
    expect(saved.items.last.quantity, 0.534);
    expect(saved.items.last.sumMinor, 5340);
    expect(saved.receipt.dedupKey, 'test-ok');
    expect(tester.takeException(), isNull);
  });
}
