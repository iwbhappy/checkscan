import 'package:checkscan/app/l10n.dart';
import 'package:checkscan/features/scan/presentation/scan_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const platform = TargetPlatformVariant({TargetPlatform.linux});

  Widget app({double scale = 1}) => ProviderScope(
    child: MaterialApp(
      locale: const Locale('ru'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: const ScanScreen(),
    ),
  );

  testWidgets('manual URL remains available without a native camera', (
    tester,
  ) async {
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(
      find.text('Камера недоступна. Выберите фото или вставьте ссылку на чек.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Вставить ссылку'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Получить чек'));
    await tester.pumpAndSettle();
    expect(find.text('Заполните поле'), findsOneWidget);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  }, variant: platform);

  testWidgets(
    'unknown host is shown before a browser action; no repository call',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Вставить ссылку'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byType(TextField),
        'https://other-ofd.example/ticket',
      );
      await tester.tap(find.text('Получить чек'));
      await tester.pumpAndSettle();
      expect(find.text('Неизвестный оператор'), findsOneWidget);
      expect(find.textContaining('other-ofd.example'), findsWidgets);
      expect(find.text('Открыть в ОФД'), findsOneWidget);
      await tester.tap(find.text('Закрыть'));
      await tester.pumpAndSettle();
    },
    variant: platform,
  );

  testWidgets(
    'unsafe and advertising QR contents are displayed without an open button',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      for (final raw in ['https://small.kz/promo', 'file:///private/data']) {
        await tester.tap(find.text('Вставить ссылку'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), raw);
        await tester.tap(find.text('Получить чек'));
        await tester.pumpAndSettle();
        expect(find.text('Это не QR чека'), findsOneWidget);
        expect(find.text('Открыть в ОФД'), findsNothing);
        expect(find.text(raw), findsOneWidget);
        await tester.tap(find.text('Закрыть'));
        await tester.pumpAndSettle();
      }
    },
    variant: platform,
  );

  testWidgets(
    'clipboard handles an empty value and large text stays scrollable',
    (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            SystemChannels.platform,
            // Native clipboard contract: no text is a null response, not {}.
            (call) async => null,
          );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(scale: 2));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Вставить ссылку'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Вставить ссылку'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Вставить из буфера'));
      await tester.tap(find.text('Вставить из буфера'));
      await tester.pumpAndSettle();
      expect(find.text('В буфере обмена нет ссылки'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
    variant: platform,
  );
}
