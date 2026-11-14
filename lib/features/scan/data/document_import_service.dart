import 'dart:io';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdfrx/pdfrx.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/utils/receipt_text_parser.dart';
import '../../../domain/models/qr_receipt.dart';
import '../../../domain/models/receipt_draft.dart';
import 'photo_qr_service.dart';
import 'qr_capture.dart';
import 'local_text_recognition.dart';

class ImportCancelled implements Exception {}

class DocumentImportResult {
  const DocumentImportResult({
    this.qr,
    this.draft,
    this.preview,
    this.pageCount = 1,
  });
  final QrReceipt? qr;
  final ReceiptDraft? draft;
  final Uint8List? preview;
  final int pageCount;
}

/// All files stay local. Each PDF page is reviewed as an individual receipt.
class DocumentImportService {
  DocumentImportService({
    required this.analyze,
    Future<String> Function(String)? recognize,
  }) : recognize = recognize ?? LocalTextRecognition.read;
  final PhotoAnalyzer analyze;
  final Future<String> Function(String) recognize;

  Future<DocumentImportResult> read(
    String path, {
    int pageNumber = 1,
    void Function(String)? onProgress,
    bool Function()? isCancelled,
  }) async {
    void check() {
      if (isCancelled?.call() ?? false) throw ImportCancelled();
    }

    check();
    final file = File(path);
    if (!await file.exists() || await file.length() > 32 * 1024 * 1024) {
      throw const FormatException('Выберите файл размером до 32 МБ');
    }
    final fingerprint = (await sha256.bind(file.openRead()).first).toString();
    check();
    final directory = await (await getTemporaryDirectory()).createTemp(
      'checkscan-import-',
    );
    PdfDocument? document;
    try {
      var imagePath = path;
      var text = '';
      var pages = 1;
      Uint8List? preview;
      final header = await file.open();
      late final List<int> signature;
      try {
        signature = await header.read(5);
      } finally {
        await header.close();
      }
      final pdf = String.fromCharCodes(signature).startsWith('%PDF-');
      if (pdf) {
        onProgress?.call('Подготавливаем страницу PDF');
        await pdfrxFlutterInitialize();
        document = await PdfDocument.openFile(path);
        check();
        pages = document.pages.length;
        if (pages > 100) {
          throw const FormatException(
            'В PDF больше 100 страниц. Разделите документ перед импортом',
          );
        }
        if (pages == 0 || pageNumber < 1 || pageNumber > pages) {
          throw const FormatException('В PDF нет выбранной страницы');
        }
        final page = document.pages[pageNumber - 1];
        text = (await page.loadText())?.fullText ?? '';
        check();
        final scale = math.min(
          3.0,
          math.sqrt(6000000 / (page.width * page.height)),
        );
        final rendered = await page.render(
          fullWidth: page.width * scale,
          fullHeight: page.height * scale,
        );
        if (rendered == null) {
          throw const FormatException('Не удалось открыть страницу PDF');
        }
        try {
          preview = await compute(_pdfPng, (
            rendered.width,
            rendered.height,
            Uint8List.fromList(rendered.pixels),
          ));
        } finally {
          rendered.dispose();
        }
        imagePath = '${directory.path}/page.png';
        await File(imagePath).writeAsBytes(preview!);
      } else if (!await compute(photoFitsMemoryBudget, path)) {
        throw const FormatException(
          'Снимок слишком большой. Выберите фото до 16 мегапикселей',
        );
      }
      check();
      onProgress?.call('Ищем QR чека');
      // Text-layer links can be read without OCR or any remote requests.
      for (final match in RegExp(
        r'https?://[^\s<>"\u0000]+',
      ).allMatches(text)) {
        final qr = QrReceipt.tryParse(match.group(0)!);
        if (qr != null) {
          return DocumentImportResult(
            qr: qr,
            preview: preview,
            pageCount: pages,
          );
        }
      }
      QrReceipt? qr;
      try {
        if (pdf && text.trim().length > 30) {
          qr = receiptFromCapture(await analyze(imagePath));
        } else {
          qr = await PhotoQrService(
            analyze: analyze,
            isCancelled: isCancelled,
            timeBudget: const Duration(seconds: 8),
          ).read(imagePath);
        }
      } on QrNotFoundFailure {
        /* Continue with text recognition. */
      } on UnsupportedQrFailure {
        /* Other operators can be read as text. */
      } on UnsupportedError {
        /* Text PDFs remain readable without a platform barcode decoder. */
      } on Exception catch (error) {
        // QR and OCR are independent strategies. A platform QR decoder error
        // must not prevent recognition of the printed receipt text.
        if (kDebugMode) debugPrint('Receipt QR fallback: $error');
      }
      check();
      if (qr != null) {
        return DocumentImportResult(qr: qr, preview: preview, pageCount: pages);
      }
      if (text.trim().length < 30) {
        onProgress?.call('Распознаём текст на устройстве');
        final prepared = '${directory.path}/ocr.png';
        await compute(_prepareOcrImage, (imagePath, prepared));
        check();
        text = await recognize(prepared);
      }
      check();
      if (text.trim().isEmpty) {
        throw const FormatException(
          'Текст не найден. Снимите чек ближе и при хорошем освещении',
        );
      }
      final pageFingerprint = pdf
          ? sha256.convert('$fingerprint:page:$pageNumber'.codeUnits).toString()
          : fingerprint;
      return DocumentImportResult(
        draft: const ReceiptTextParser().parse(
          text,
          fingerprint: pageFingerprint,
        ),
        preview: preview,
        pageCount: pages,
      );
    } finally {
      await document?.dispose();
      // Only the dedicated directory created above is removed.
      if (await directory.exists()) await directory.delete(recursive: true);
    }
  }
}

Uint8List _pdfPng((int, int, Uint8List) data) => Uint8List.fromList(
  img.encodePng(
    img.Image.fromBytes(
      width: data.$1,
      height: data.$2,
      bytes: data.$3.buffer,
      order: img.ChannelOrder.bgra,
      numChannels: 4,
    ),
  ),
);

void _prepareOcrImage((String, String) paths) {
  if (!photoFitsMemoryBudget(paths.$1)) {
    throw const FormatException('Снимок слишком большой');
  }
  final decoded = img.decodeImage(File(paths.$1).readAsBytesSync());
  if (decoded == null) {
    throw const FormatException('Не удалось прочитать изображение');
  }
  var image = img.bakeOrientation(decoded);
  if (image.width * image.height > 6000000) {
    final scale = math.sqrt(6000000 / (image.width * image.height));
    image = img.copyResize(
      image,
      width: (image.width * scale).floor(),
      height: (image.height * scale).floor(),
    );
  }
  image = img.grayscale(image);
  File(paths.$2).writeAsBytesSync(img.encodePng(image));
}
