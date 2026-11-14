// Run: flutter test tool/render_previews.dart
// Renders the real widgets with local sample data; no camera or network.
import 'dart:io';
import 'dart:ui' as ui;
import 'package:checkscan/app/app.dart';
import 'package:checkscan/app/providers.dart';
import 'package:checkscan/core/utils/receipt_text_parser.dart';
import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/data/repositories/receipt_repository.dart';
import 'package:checkscan/data/ofd/ofd_provider_registry.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  testWidgets('render reviewable app previews', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await initializeDateFormatting('ru_RU');
    final previousShadows = debugDisableShadows;
    addTearDown(() => debugDisableShadows = previousShadows);
    debugDisableShadows = false;
    await (FontLoader(
      'Manrope',
    )..addFont(rootBundle.load('assets/fonts/Manrope.ttf'))).load();
    await (FontLoader(
      'NotoSans',
    )..addFont(rootBundle.load('assets/fonts/NotoSans.ttf'))).load();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    final db = AppDatabase(NativeDatabase.memory());
    final repository = ReceiptRepository(db, OfdProviderRegistry([]));
    final now = DateTime.now().toUtc();
    final id = await repository.createManual(
      storeName: 'ТОО «Скиф Трейд»',
      dateTimeUtc: now,
      items: const [
        ReceiptItemEdit(
          name: 'Молоко 2,5%',
          quantity: 1,
          unitPriceMinor: 43500,
          sumMinor: 43500,
          categoryId: 2,
        ),
        ReceiptItemEdit(
          name: 'Творог 9%',
          quantity: 1,
          unitPriceMinor: 48900,
          sumMinor: 48900,
          categoryId: 2,
        ),
        ReceiptItemEdit(
          name: 'Сметана 15%',
          quantity: 1,
          unitPriceMinor: 77900,
          sumMinor: 77900,
          categoryId: 2,
        ),
        ReceiptItemEdit(
          name: 'Батончик Snickers',
          quantity: 1,
          unitPriceMinor: 29900,
          sumMinor: 29900,
          categoryId: 6,
        ),
      ],
    );
    await repository.createManual(
      storeName: 'Кофейня рядом',
      dateTimeUtc: now.subtract(const Duration(hours: 2)),
      items: const [
        ReceiptItemEdit(
          name: 'Капучино',
          quantity: 1,
          unitPriceMinor: 120000,
          sumMinor: 120000,
          categoryId: 14,
        ),
      ],
    );
    final router = createRouter(initialLocation: '/history');
    final container = ProviderContainer(
      overrides: [
        databaseProvider.overrideWithValue(db),
        backgroundWorkProvider.overrideWithValue(false),
        routerProvider.overrideWithValue(router),
      ],
    );
    final boundaryKey = GlobalKey();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: RepaintBoundary(key: boundaryKey, child: const CheckScanApp()),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();

    Future<void> capture(String name) async {
      expect(tester.takeException(), isNull);
      final boundary =
          boundaryKey.currentContext!.findRenderObject()!
              as RenderRepaintBoundary;
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        final directory = Directory('build/previews');
        await directory.create(recursive: true);
        await File('${directory.path}/$name.png').writeAsBytes(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        image.dispose();
      });
    }

    await capture('history-light');
    container.read(themeModeProvider.notifier).setMode(ThemeMode.dark);
    await tester.pumpAndSettle();
    await capture('history-dark');
    container.read(themeModeProvider.notifier).setMode(ThemeMode.light);
    router.push('/receipts/$id');
    await tester.pumpAndSettle();
    await capture('receipt');
    router.go('/stats');
    await tester.pumpAndSettle();
    await capture('stats');
    final draft = const ReceiptTextParser().parse(
      'МАГАЗИН У ДОМА\n14.11.2026 12:30\nМолоко 435.00\nХлеб 150.00\nИТОГО 585.00',
    );
    router.push('/receipts/new', extra: draft);
    await tester.pumpAndSettle();
    await capture('import-review');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    container.dispose();
    router.dispose();
    repository.dispose();
    await tester.pumpAndSettle();
    await tester.runAsync(db.close);
    debugDisableShadows = previousShadows;
  });
}
