import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/errors/app_failure.dart';
import '../../../domain/models/qr_receipt.dart';
import 'qr_capture.dart';

typedef PhotoAnalyzer = Future<BarcodeCapture?> Function(String path);

enum PhotoVariant {
  lowerThird,
  lowerDouble,
  lowerTriple,
  fullDouble,
  fullTriple,
  lowerGray,
  lowerThreshold,
  bottomCenter,
  bottomLeft,
  bottomRight,
}

class PhotoTransformRequest {
  const PhotoTransformRequest({
    required this.sourcePath,
    required this.outputPath,
    required this.variant,
  });
  final String sourcePath;
  final String outputPath;
  final PhotoVariant variant;
}

/// Processes one fallback at a time so full-resolution images never accumulate.
/// Original files are not modified; temporary variants are removed even on error.
class PhotoQrService {
  PhotoQrService({
    required this.analyze,
    Future<Directory> Function()? temporaryDirectory,
    Future<String?> Function(PhotoTransformRequest)? transform,
    this.onRawQr,
  }) : _temporaryDirectory = temporaryDirectory ?? getTemporaryDirectory,
       _transform =
           transform ?? ((request) => compute(createPhotoVariant, request));

  final PhotoAnalyzer analyze;
  final Future<Directory> Function() _temporaryDirectory;
  final Future<String?> Function(PhotoTransformRequest) _transform;
  final void Function(String)? onRawQr;
  String? _unknownRaw;

  Future<QrReceipt> read(String path) async {
    _unknownRaw = null;
    final source = File(path);
    if (!await source.exists() || await source.length() > 32 * 1024 * 1024) {
      throw const QrNotFoundFailure();
    }
    if (!await compute(photoFitsMemoryBudget, path)) {
      throw const QrNotFoundFailure();
    }
    final initial = await _readCandidate(path);
    if (initial != null) return initial;
    final directory = await (await _temporaryDirectory()).createTemp(
      'checkscan-qr-',
    );
    try {
      for (final variant in PhotoVariant.values) {
        final output =
            '${directory.path}${Platform.pathSeparator}${variant.name}.jpg';
        String? transformed;
        try {
          transformed = await _transform(
            PhotoTransformRequest(
              sourcePath: path,
              outputPath: output,
              variant: variant,
            ),
          );
        } on FormatException {
          continue;
        }
        if (transformed == null) continue;
        final found = await _readCandidate(transformed);
        if (found != null) return found;
        final temporary = File(output);
        if (await temporary.exists()) await temporary.delete();
      }
    } finally {
      if (await directory.exists()) await directory.delete(recursive: true);
    }
    if (_unknownRaw != null) throw UnsupportedQrFailure(_unknownRaw);
    throw const QrNotFoundFailure();
  }

  Future<QrReceipt?> _readCandidate(String path) async {
    try {
      final capture = await analyze(path);
      for (final barcode in capture?.barcodes ?? <Barcode>[]) {
        final raw = barcode.rawValue;
        if (raw != null) {
          onRawQr?.call(raw);
          final uri = externalQrUri(raw);
          if (uri != null && !isPromotionalUri(uri)) _unknownRaw = raw;
        }
      }
      final selected = receiptFromCapture(capture);
      if (selected != null) {
        for (final barcode in capture!.barcodes) {
          final raw = barcode.rawValue;
          if (raw != null &&
              QrReceipt.tryParse(raw)?.dedupKey == selected.dedupKey) {
            onRawQr?.call(raw);
            break;
          }
        }
      }
      return selected;
    } on MobileScannerException catch (error) {
      if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
        throw const CameraPermissionFailure();
      }
      return null;
    }
  }
}

bool photoFitsMemoryBudget(String path) {
  final bytes = File(path).readAsBytesSync();
  final info = img.findDecoderForData(bytes)?.startDecode(bytes);
  // The platform scanner may support formats (e.g. HEIC) this codec cannot
  // decode. It can still try the original; known dimensions are bounded.
  return info == null ||
      (info.width > 0 &&
          info.height > 0 &&
          info.width * info.height <= 16000000);
}

/// Runs in a worker isolate; validates the image header before allocating pixels.
String? createPhotoVariant(PhotoTransformRequest request) {
  final file = File(request.sourcePath);
  if (file.lengthSync() > 32 * 1024 * 1024) return null;
  final bytes = file.readAsBytesSync();
  final decoder = img.findDecoderForData(bytes);
  final info = decoder?.startDecode(bytes);
  if (info == null ||
      info.width <= 0 ||
      info.height <= 0 ||
      info.width * info.height > 16000000) {
    return null;
  }
  final decoded = decoder!.decodeFrame(0);
  if (decoded == null) return null;
  var source = img.bakeOrientation(decoded);
  final kind = request.variant;
  if (kind == PhotoVariant.bottomCenter ||
      kind == PhotoVariant.bottomLeft ||
      kind == PhotoVariant.bottomRight) {
    final width = math.max(1, (source.width * 0.5).round());
    final x = switch (kind) {
      PhotoVariant.bottomLeft => 0,
      PhotoVariant.bottomRight => source.width - width,
      _ => (source.width - width) ~/ 2,
    };
    final y = (source.height * 0.62).floor();
    source = img.copyCrop(
      source,
      x: x,
      y: y,
      width: width,
      height: source.height - y,
    );
  } else if (kind != PhotoVariant.fullDouble &&
      kind != PhotoVariant.fullTriple) {
    final y = source.height * 2 ~/ 3;
    source = img.copyCrop(
      source,
      x: 0,
      y: y,
      width: source.width,
      height: source.height - y,
    );
  }
  final scale = switch (kind) {
    PhotoVariant.lowerThird => 1.0,
    PhotoVariant.lowerDouble ||
    PhotoVariant.fullDouble ||
    PhotoVariant.lowerGray ||
    PhotoVariant.lowerThreshold => 2.0,
    _ => 3.0,
  };
  final boundedScale = math.min(
    scale,
    math.sqrt(8000000 / (source.width * source.height)),
  );
  if (boundedScale != 1) {
    source = img.copyResize(
      source,
      width: math.max(1, (source.width * boundedScale).floor()),
      height: math.max(1, (source.height * boundedScale).floor()),
      interpolation: img.Interpolation.cubic,
    );
  }
  if (kind == PhotoVariant.lowerGray || kind == PhotoVariant.lowerThreshold) {
    source = img.grayscale(source);
  }
  if (kind == PhotoVariant.lowerThreshold) {
    source = img.luminanceThreshold(source, threshold: 0.55);
  }
  File(request.outputPath).writeAsBytesSync(img.encodeJpg(source, quality: 96));
  return request.outputPath;
}
