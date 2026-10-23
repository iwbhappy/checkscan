import 'package:checkscan/app/l10n.dart';
import 'package:checkscan/app/providers.dart';
import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/features/categories/presentation/categories_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  testWidgets('imported unknown category icon can be edited at large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final id = await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Своя категория',
            color: 0xff008577,
            icon: 'future-unknown-icon',
            sortOrder: const Value(100),
          ),
        );
    try {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            locale: const Locale('ru'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: ThemeData(useMaterial3: true),
            home: const CategoriesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Своя категория'),
        240,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Своя категория'));
      await tester.pumpAndSettle();
      expect(find.text('Редактировать категорию'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Название категории'),
        'Семья',
      );
      await tester.tap(find.text('Сохранить'));
      await tester.pumpAndSettle();
      final saved = await (db.select(
        db.categories,
      )..where((row) => row.id.equals(id))).getSingle();
      expect(saved.name, 'Семья');
      expect(saved.icon, 'other');
      expect(tester.takeException(), isNull);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }
  });
}
