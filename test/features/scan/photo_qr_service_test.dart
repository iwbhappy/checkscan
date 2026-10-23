import 'dart:io';

import 'package:checkscan/core/errors/app_failure.dart';
import 'package:checkscan/features/scan/data/photo_qr_service.dart';
import 'package:checkscan/features/scan/data/qr_capture.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_scanner/mobile_scanner.dart';

const receiptQr =
    'http://consumer.oofd.kz?i=1462733895&f=010102236118&s=2002.00&t=20261007T153259';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late File photo;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('checkscan-photo-test-');
    photo = File('${directory.path}/source.jpg');
    final pixels = img.Image(width: 120, height: 180);
    img.fill(pixels, color: img.ColorRgb8(255, 255, 255));
    img.fillRect(
      pixels,
      x1: 0,
      y1: 0,
      x2: 119,
      y2: 99,
      color: img.ColorRgb8(180, 30, 40),
    );
    await photo.writeAsBytes(img.encodeJpg(pixels));
  });
  tearDown(() async {
    if (await directory.exists()) await directory.delete(recursive: true);
  });

  test('all fallback variants preserve source and produce bounded JPEGs', () {
    final original = photo.readAsBytesSync();
    for (final kind in PhotoVariant.values) {
      final output = '${directory.path}/${kind.name}.jpg';
      expect(
        createPhotoVariant(
          PhotoTransformRequest(
            sourcePath: photo.path,
            outputPath: output,
            variant: kind,
          ),
        ),
        output,
      );
      final image = img.decodeJpg(File(output).readAsBytesSync())!;
      expect(image.width * image.height, lessThanOrEqualTo(8000000));
      if (kind == PhotoVariant.lowerThird) {
        expect(image.width, 120);
        expect(image.height, 60);
        expect(image.getPixel(40, 20).r, greaterThan(245));
      }
      if (kind == PhotoVariant.lowerTriple) {
        expect(image.width, 360);
        expect(image.height, 180);
      }
      if (kind == PhotoVariant.lowerGray ||
          kind == PhotoVariant.lowerThreshold) {
        final pixel = image.getPixel(1, 1);
        expect((pixel.r - pixel.g).abs(), lessThanOrEqualTo(2));
      }
    }
    expect(photo.readAsBytesSync(), original);
  });

  test(
    'falls back after an advertising QR, stops early and deletes variants',
    () async {
      final attempted = <String>[];
      final rawValues = <String>[];
      final service = PhotoQrService(
        temporaryDirectory: () async => directory,
        onRawQr: rawValues.add,
        analyze: (path) async {
          attempted.add(path);
          if (path.endsWith('lowerDouble.jpg')) {
            return const BarcodeCapture(
              barcodes: [Barcode(rawValue: receiptQr)],
            );
          }
          return const BarcodeCapture(
            barcodes: [Barcode(rawValue: 'https://small.kz/promo')],
          );
        },
        transform: (request) async {
          await File(request.outputPath).writeAsBytes([0]);
          return request.outputPath;
        },
      );
      expect((await service.read(photo.path)).totalMinor, 200200);
      expect(attempted, hasLength(3));
      expect(rawValues.last, receiptQr);
      expect(directory.listSync().whereType<Directory>(), isEmpty);
      expect(photo.existsSync(), isTrue);
    },
  );

  test(
    'worker isolate can decode a real image without blocking UI isolate',
    () async {
      var attempts = 0;
      final service = PhotoQrService(
        temporaryDirectory: () async => directory,
        analyze: (path) async {
          attempts++;
          return attempts == 2
              ? const BarcodeCapture(barcodes: [Barcode(rawValue: receiptQr)])
              : null;
        },
      );
      expect((await service.read(photo.path)).fiscalSign, '1462733895');
      expect(attempts, 2);
      expect(directory.listSync().whereType<Directory>(), isEmpty);
    },
  );

  test('no QR exhausts variants and yields an actionable failure', () async {
    var variants = 0;
    final service = PhotoQrService(
      temporaryDirectory: () async => directory,
      analyze: (_) async => null,
      transform: (_) async {
        variants++;
        return null;
      },
    );
    await expectLater(
      service.read(photo.path),
      throwsA(isA<QrNotFoundFailure>()),
    );
    expect(variants, PhotoVariant.values.length);
    expect(directory.listSync().whereType<Directory>(), isEmpty);
  });

  test(
    'unknown operator preserves raw QR for the explicit browser choice',
    () async {
      const unknown = 'https://checks.example.org/123';
      final service = PhotoQrService(
        temporaryDirectory: () async => directory,
        analyze: (_) async =>
            const BarcodeCapture(barcodes: [Barcode(rawValue: unknown)]),
        transform: (_) async => null,
      );
      await expectLater(
        service.read(photo.path),
        throwsA(
          isA<UnsupportedQrFailure>().having(
            (failure) => failure.rawValue,
            'raw QR',
            unknown,
          ),
        ),
      );
    },
  );

  test('permission failure is typed and never enters preprocessing', () async {
    var transformed = false;
    final service = PhotoQrService(
      analyze: (_) async => throw const MobileScannerException(
        errorCode: MobileScannerErrorCode.permissionDenied,
      ),
      transform: (_) async {
        transformed = true;
        return null;
      },
    );
    await expectLater(
      service.read(photo.path),
      throwsA(isA<CameraPermissionFailure>()),
    );
    expect(transformed, isFalse);
  });

  test(
    'temporary variants are removed on unexpected analyzer failure',
    () async {
      var calls = 0;
      final service = PhotoQrService(
        temporaryDirectory: () async => directory,
        analyze: (_) async {
          if (++calls > 1) throw StateError('injected failure');
          return null;
        },
        transform: (request) async {
          await File(request.outputPath).writeAsBytes([0]);
          return request.outputPath;
        },
      );
      await expectLater(service.read(photo.path), throwsStateError);
      expect(directory.listSync().whereType<Directory>(), isEmpty);
      expect(photo.existsSync(), isTrue);
    },
  );

  test(
    'oversized or missing file is rejected before native decoding',
    () async {
      var analyzed = false;
      final service = PhotoQrService(
        analyze: (_) async {
          analyzed = true;
          return null;
        },
      );
      final large = File('${directory.path}/huge.jpg');
      final handle = await large.open(mode: FileMode.write);
      await handle.truncate(33 * 1024 * 1024);
      await handle.close();
      await expectLater(
        service.read(large.path),
        throwsA(isA<QrNotFoundFailure>()),
      );
      await expectLater(
        service.read('${directory.path}/missing.jpg'),
        throwsA(isA<QrNotFoundFailure>()),
      );
      expect(analyzed, isFalse);
    },
  );

  test(
    'external link policy rejects non-web schemes, credentials and ports',
    () {
      for (final text in [
        'file:///etc/passwd',
        'javascript:alert(1)',
        'https://user:password@ofd.example/1',
        'http://ofd.example:8080/1',
      ]) {
        expect(externalQrUri(text), isNull);
      }
      expect(externalQrUri('https://ofd.example/1')?.host, 'ofd.example');
      expect(isPromotionalUri(Uri.parse('https://join.small.kz/')), isTrue);
      expect(isPromotionalUri(Uri.parse('https://promo.example/')), isTrue);
    },
  );
}
