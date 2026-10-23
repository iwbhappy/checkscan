import 'dart:io';

import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/data/ofd/kazakhtelecom_ofd_provider.dart';
import 'package:checkscan/data/ofd/ofd_provider_registry.dart';
import 'package:checkscan/data/repositories/receipt_repository.dart';
import 'package:checkscan/features/scan/data/photo_qr_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';

/// Requires an Android/iOS device or emulator and the native scanner plugin.
/// OFD traffic remains mocked even here; no live network is used by the test.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'native receipt photo recognition → mock OFD → saved receipt',
    (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final photoData = await rootBundle.load(
        'test/fixtures/photos/small_2026_10_07.jpg',
      );
      final raw = await rootBundle.loadString(
        'test/fixtures/ofd_responses/ticket.json',
      );
      final directory = await (await getTemporaryDirectory()).createTemp(
        'checkscan-integration-',
      );
      final photo = File('${directory.path}/receipt.jpg');
      await photo.writeAsBytes(
        photoData.buffer.asUint8List(
          photoData.offsetInBytes,
          photoData.lengthInBytes,
        ),
      );
      final controller = MobileScannerController(
        autoStart: false,
        formats: const [BarcodeFormat.qrCode],
      );
      final adapter = _FixtureAdapter(raw);
      final dio = Dio()..httpClientAdapter = adapter;
      final db = AppDatabase(NativeDatabase.memory());
      final repository = ReceiptRepository(
        db,
        OfdProviderRegistry([KazakhtelecomOfdProvider(dio: dio)]),
      );
      addTearDown(() async {
        repository.dispose();
        dio.close(force: true);
        await db.close();
        await controller.dispose();
        // This is the dedicated directory created by this test above.
        if (await directory.exists()) await directory.delete(recursive: true);
      });

      final photos = PhotoQrService(
        analyze: (path) => controller.analyzeImage(
          path,
          formats: const [BarcodeFormat.qrCode],
        ),
        temporaryDirectory: () async => directory,
      );
      final qr = await photos.read(photo.path);
      expect(qr.uri.host, 'consumer.oofd.kz');
      expect(qr.fiscalSign, '1462733895');
      expect(qr.totalMinor, 200200);

      final result = await repository.scan(qr.sourceUrl);
      expect(result.duplicate, isFalse);
      expect(result.receipt.status, 'ok');
      final detail = await db.getReceiptDetail(result.receipt.id);
      expect(detail, isNotNull);
      expect(detail!.store!.bin, '131141020408');
      expect(detail.receipt.totalMinor, 200200);
      expect(detail.receipt.vatMinor, 27614);
      expect(detail.items.map((item) => item.sumMinor), [
        29900,
        43500,
        48900,
        77900,
      ]);
      expect(adapter.requestCount, 1);

      final duplicate = await repository.scan(qr.sourceUrl);
      expect(duplicate.duplicate, isTrue);
      expect(duplicate.receipt.id, result.receipt.id);
      expect(await db.select(db.receipts).get(), hasLength(1));
      expect(await db.select(db.receiptItems).get(), hasLength(4));
      expect(adapter.requestCount, 1);
    },
    skip: !Platform.isAndroid && !Platform.isIOS,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}

class _FixtureAdapter implements HttpClientAdapter {
  _FixtureAdapter(this.body);

  final String body;
  int requestCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    expect(options.uri.host, 'consumer.oofd.kz');
    expect(options.uri.scheme, 'https');
    expect(options.uri.path, KazakhtelecomOfdProvider.apiPath);
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
