import 'package:checkscan/app/format.dart';
import 'package:checkscan/app/l10n.dart';
import 'package:checkscan/app/providers.dart';
import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/features/stats/presentation/stats_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AppDatabase db;
  setUpAll(() => initializeDateFormatting('ru_RU'));
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> seed() async {
    final now = kazakhstanNow();
    final store = await db
        .into(db.stores)
        .insert(StoresCompanion.insert(name: 'Магазин'));
    await db.saveReceipt(
      ReceiptsCompanion.insert(
        dateTimeUtc: DateTime.utc(now.year, now.month, 7, 7),
        tzOffsetMin: const Value(300),
        totalMinor: 50000,
        sourceUrl: 'https://consumer.oofd.kz',
        dedupKey: 'stats-current',
        status: const Value('ok'),
        storeId: Value(store),
        categoryId: const Value(2),
      ),
      [
        ReceiptItemsCompanion.insert(
          receiptId: 0,
          position: 0,
          name: 'Молоко',
          rawName: 'Молоко',
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
      ],
    );
    await db.insertPending(
      ReceiptsCompanion.insert(
        dateTimeUtc: DateTime.utc(now.year, now.month - 1, 1, 12),
        totalMinor: 10000,
        sourceUrl: 'https://consumer.oofd.kz',
        dedupKey: 'stats-previous',
        categoryId: const Value(16),
      ),
    );
  }

  Widget app() => ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db)],
    child: MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(useMaterial3: true),
      home: const StatsScreen(),
    ),
  );

  void narrowLargeText(WidgetTester tester) {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> reveal(
    WidgetTester tester,
    Finder finder, {
    double delta = 220,
  }) async {
    if (finder.evaluate().isEmpty) {
      await tester.scrollUntilVisible(
        finder,
        delta,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
    }
    await Scrollable.ensureVisible(
      tester.element(finder.first),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
  }

  void screenTest(String name, Future<void> Function(WidgetTester) body) {
    testWidgets(name, (tester) async {
      try {
        await body(tester);
      } finally {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
      }
    });
  }

  screenTest(
    'seeded statistics cards charts and lists fit narrow 200 percent text',
    (tester) async {
      await seed();
      narrowLargeText(tester);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('Всего потрачено'), findsOneWidget);
      expect(find.text('500,00 ₸'), findsWidgets);
      expect(tester.takeException(), isNull);

      await reveal(tester, find.byType(PieChart));
      expect(find.byType(PieChart), findsOneWidget);
      expect(tester.takeException(), isNull);
      await reveal(tester, find.text('Молочное'));
      expect(find.text('299,00 ₸'), findsWidgets);
      expect(tester.takeException(), isNull);
      await reveal(tester, find.byType(BarChart));
      expect(find.byType(BarChart), findsOneWidget);
      expect(tester.takeException(), isNull);
      await reveal(tester, find.text('Топ магазинов'));
      await reveal(tester, find.text('Магазин'));
      expect(tester.takeException(), isNull);
      await reveal(tester, find.text('Топ товаров'));
      await reveal(tester, find.text('Молоко'));
      expect(find.text('299,00 ₸'), findsWidgets);
      expect(tester.takeException(), isNull);
    },
  );

  screenTest(
    'period navigation reloads actual database totals at 200 percent text',
    (tester) async {
      await seed();
      narrowLargeText(tester);
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('500,00 ₸'), findsWidgets);
      await tester.tap(find.byTooltip('Предыдущий период'));
      await tester.pumpAndSettle();
      expect(find.text('100,00 ₸'), findsWidgets);
      expect(find.text('500,00 ₸'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byTooltip('Следующий период'));
      await tester.pumpAndSettle();
      expect(find.text('500,00 ₸'), findsWidgets);
      await tester.tap(find.byTooltip('Следующий период'));
      await tester.pumpAndSettle();
      expect(find.text('Пока нечего сравнивать'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
