import 'package:checkscan/app/app.dart';
import 'package:checkscan/app/providers.dart';
import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/domain/models/receipt_draft.dart';
import 'package:checkscan/data/ofd/ofd_provider_registry.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('ru_RU'));
  testWidgets(
    'replacing a pushed page does not leave scan actions disabled',
    (tester) async {
      tester.view.physicalSize = const Size(390, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = AppDatabase(NativeDatabase.memory());
      await db.select(db.categories).get();
      final router = createRouter();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          backgroundWorkProvider.overrideWithValue(false),
          ofdRegistryProvider.overrideWithValue(OfdProviderRegistry([])),
          routerProvider.overrideWithValue(router),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CheckScanApp(),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Вставить ссылку'));
      await tester.tap(find.text('Вставить ссылку'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.byType(TextField),
        ),
        'http://consumer.oofd.kz?i=1462733895&f=010102236118&s=2002.00&t=20261007T153259',
      );
      await tester.tap(
        find
            .descendant(
              of: find.byType(AlertDialog),
              matching: find.byType(FilledButton),
            )
            .last,
      );
      await tester.pumpAndSettle();
      router.pushReplacement(
        '/receipts/new',
        extra: const ReceiptDraft(
          rawText: 'TOTAL 500.00',
          sellerName: 'Тест',
          totalMinor: 50000,
        ),
      );
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      final button = tester.widget<OutlinedButton>(
        find
            .ancestor(
              of: find.text('Вставить ссылку'),
              matching: find.byType(OutlinedButton),
            )
            .first,
      );
      expect(button.onPressed, isNotNull);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      container.dispose();
      router.dispose();
      await tester.pumpAndSettle();
      await tester.runAsync(db.close);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.linux),
  );
  testWidgets(
    'document total is not saved until reviewed and may have no items',
    (tester) async {
      final db = AppDatabase(NativeDatabase.memory());
      final router = createRouter(initialLocation: '/history');
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          backgroundWorkProvider.overrideWithValue(false),
          routerProvider.overrideWithValue(router),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const CheckScanApp(),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
      router.push(
        '/receipts/new',
        extra: ReceiptDraft(
          rawText: 'TOTAL 585.00',
          sellerName: 'Документ',
          localDate: DateTime.utc(2026, 11, 14),
          totalMinor: 58500,
        ),
      );
      await tester.pumpAndSettle();
      expect(
        await tester.runAsync(() => db.select(db.receipts).get()),
        isEmpty,
      );
      await tester.enterText(
        find.byKey(const ValueKey('recognized-total')),
        '600.00',
      );
      await tester.pumpAndSettle();
      expect(find.text('Итого: 600,00 ₸'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('save-receipt')));
      await tester.pumpAndSettle();
      final rows = await tester.runAsync(() => db.select(db.receipts).get());
      expect(rows, hasLength(1));
      expect(rows!.single.totalMinor, 60000);
      expect(
        await tester.runAsync(() => db.select(db.receiptItems).get()),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();
      expect(find.text('Итого: 600,00 ₸'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      container.dispose();
      router.dispose();
      await tester.pumpAndSettle();
      await tester.runAsync(db.close);
    },
  );
}
