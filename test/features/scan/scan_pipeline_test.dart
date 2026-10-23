import 'dart:io';
import 'dart:typed_data';

import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/data/ofd/kazakhtelecom_ofd_provider.dart';
import 'package:checkscan/data/ofd/ofd_provider_registry.dart';
import 'package:checkscan/data/repositories/receipt_repository.dart';
import 'package:checkscan/features/scan/data/photo_qr_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Host smoke test: native barcode recognition is intentionally mocked.
/// Real recognition of the same photo is covered by integration_test/.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'mock photo recognition → real OFD fixture → database → dedup',
    () async {
      final fixture = File('test/fixtures/ofd_responses/ticket.json');
      final sourcePhoto = File('test/fixtures/photos/small_2026_10_07.jpg');
      final qr = File(
        'test/fixtures/qr_strings.txt',
      ).readAsLinesSync().firstWhere((line) => !line.contains('&amp;'));
      final adapter = _FixtureAdapter(fixture.readAsStringSync());
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
      });

      var calls = 0;
      final rawCodes = <String>[];
      final photos = PhotoQrService(
        analyze: (path) async {
          calls++;
          expect(path, sourcePhoto.path);
          expect(await File(path).length(), 595753);
          return BarcodeCapture(
            barcodes: [
              const Barcode(
                rawValue: 'https://small.kz/',
                format: BarcodeFormat.qrCode,
                corners: [Offset(50, 10), Offset(100, 50)],
              ),
              Barcode(
                rawValue: qr,
                format: BarcodeFormat.qrCode,
                corners: const [Offset(50, 300), Offset(100, 400)],
              ),
            ],
          );
        },
        onRawQr: rawCodes.add,
      );

      final decoded = await photos
          .read(sourcePhoto.path)
          .timeout(const Duration(seconds: 5));
      expect(decoded.sourceUrl, qr);
      expect(calls, 1);
      expect(rawCodes, contains(qr));
      final result = await repository
          .scan(decoded.sourceUrl)
          .timeout(const Duration(seconds: 5));
      expect(result.duplicate, isFalse);
      expect(result.receipt.status, 'ok');
      final saved = await db.getReceiptDetail(result.receipt.id);
      expect(saved, isNotNull);
      expect(saved!.store!.bin, '131141020408');
      expect(saved.receipt.totalMinor, 200200);
      expect(saved.receipt.vatMinor, 27614);
      expect(saved.receipt.discountMinor, 0);
      expect(saved.items.map((item) => item.sumMinor), [
        29900,
        43500,
        48900,
        77900,
      ]);
      expect(saved.items.map((item) => item.ntin), [
        '0200092089208',
        '0200021763506',
        '0200134355469',
        '0200020937090',
      ]);
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.uri.host, 'consumer.oofd.kz');
      expect(adapter.requests.single.uri.scheme, 'https');
      expect(
        adapter.requests.single.uri.path,
        KazakhtelecomOfdProvider.apiPath,
      );

      final duplicate = await repository.scan(
        qr.replaceFirst('f=010102236118', 'f=0010102236118'),
      );
      expect(duplicate.duplicate, isTrue);
      expect(duplicate.receipt.id, saved.receipt.id);
      expect(await db.select(db.receipts).get(), hasLength(1));
      expect(await db.select(db.receiptItems).get(), hasLength(4));
      expect(adapter.requests, hasLength(1));
    },
  );
}

class _FixtureAdapter implements HttpClientAdapter {
  _FixtureAdapter(this.body);

  final String body;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
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
