import 'package:checkscan/app/app.dart';
import 'package:checkscan/app/providers.dart';
import 'package:checkscan/data/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  late AppDatabase db;
  setUp(() async {
    await initializeDateFormatting('ru_RU');
    db = AppDatabase(NativeDatabase.memory());
    await db.select(db.categories).get();
  });
  tearDown(() => db.close());

  Future<ProviderContainer> mount(
    WidgetTester tester, {
    String path = '/history',
    bool dark = false,
  }) async {
    final router = createRouter(initialLocation: path);
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        backgroundWorkProvider.overrideWithValue(false),
        routerProvider.overrideWithValue(router),
      ],
    );
    addTearDown(container.dispose);
    addTearDown(router.dispose);
    if (dark) {
      container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    }
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const CheckScanApp(),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 60)),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('localized empty history and navigation work without network', (
    tester,
  ) async {
    await mount(tester);
    expect(find.text('Здесь появятся ваши покупки'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Экспорт CSV'), findsOneWidget);
    final context = tester.element(find.text('Экспорт CSV'));
    expect(Localizations.localeOf(context), const Locale('ru'));
    expect(Theme.of(context).useMaterial3, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'settings and navigation support dark theme at 200 percent text',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await mount(tester, path: '/settings', dark: true);
      expect(
        Theme.of(tester.element(find.text('Оформление'))).brightness,
        Brightness.dark,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'canceling first destructive confirmation leaves built-in categories',
    (tester) async {
      await mount(tester, path: '/settings');
      final clear = find.text('Удалить все данные');
      await tester.scrollUntilVisible(
        clear,
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(clear);
      await tester.pumpAndSettle();
      expect(find.text('Удалить все данные?'), findsOneWidget);
      await tester.tap(find.text('Отмена'));
      await tester.pumpAndSettle();
      expect(find.text('Подтвердите удаление'), findsNothing);
      final categories = await tester.runAsync(
        () => db.select(db.categories).get(),
      );
      expect(categories, hasLength(16));
      expect(tester.takeException(), isNull);
    },
  );
}
