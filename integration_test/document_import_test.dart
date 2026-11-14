import 'dart:io';
import 'dart:ui' as ui;
import 'package:checkscan/core/utils/receipt_text_parser.dart';
import 'package:checkscan/features/scan/data/document_import_service.dart';
import 'package:checkscan/features/scan/data/local_text_recognition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'native OCR reads Cyrillic locally and extracts an exact total',
    (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final directory = await (await getTemporaryDirectory()).createTemp(
        'checkscan-ocr-smoke-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..drawColor(Colors.white, BlendMode.src);
      final painter = TextPainter(
        text: const TextSpan(
          text:
              'МАГАЗИН ПРОДУКТЫ\n\nМолоко 435.00\nХлеб 150.00\n\nИТОГО 585.00',
          style: TextStyle(
            color: Colors.black,
            fontSize: 52,
            height: 1.8,
            fontFamily: 'Roboto',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 1100);
      painter.paint(canvas, const Offset(50, 50));
      final picture = recorder.endRecording();
      final image = await picture.toImage(1200, 1000);
      final data = (await image.toByteData(format: ui.ImageByteFormat.png))!;
      final file = File('${directory.path}/receipt.png');
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      image.dispose();
      picture.dispose();
      painter.dispose();
      final text = await LocalTextRecognition.read(file.path);
      expect(text.toUpperCase(), contains('МОЛОКО'));
      expect(const ReceiptTextParser().parse(text).totalMinor, 58500);
      final scanner = MobileScannerController(
        autoStart: false,
        formats: [BarcodeFormat.qrCode],
      );
      addTearDown(scanner.dispose);
      final imported = await DocumentImportService(
        analyze: (path) =>
            scanner.analyzeImage(path, formats: [BarcodeFormat.qrCode]),
      ).read(file.path);
      expect(imported.draft!.totalMinor, 58500);
    },
    skip: !Platform.isAndroid && !Platform.isIOS,
    timeout: const Timeout(Duration(minutes: 3)),
  );

  testWidgets(
    'native PDF extracts text and total without invoking OCR or network',
    (tester) async {
      await tester.pumpWidget(const SizedBox.shrink());
      final directory = await (await getTemporaryDirectory()).createTemp(
        'checkscan-pdf-smoke-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final data = await rootBundle.load(
        'test/fixtures/import/receipt_text.pdf',
      );
      final file = File('${directory.path}/receipt.pdf');
      await file.writeAsBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final result = await DocumentImportService(
        analyze: (_) async => null,
        recognize: (_) => throw StateError('Text PDF must not invoke OCR'),
      ).read(file.path);
      expect(result.qr, isNull);
      expect(result.draft!.totalMinor, 58500);
      expect(result.draft!.sellerName, 'DEMO SHOP');
      expect(result.draft!.items, hasLength(2));
      expect(result.preview, isNotEmpty);
      expect(result.pageCount, 1);
    },
    skip: !Platform.isAndroid && !Platform.isIOS,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
