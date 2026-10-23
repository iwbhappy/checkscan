import 'dart:math' as math;

import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/utils/qr_selection.dart';
import '../../../domain/models/qr_receipt.dart';

QrReceipt? receiptFromCapture(BarcodeCapture? capture) => selectReceiptQr([
  for (final barcode in capture?.barcodes ?? <Barcode>[])
    if (barcode.rawValue case final String raw)
      QrCandidate(
        rawValue: raw,
        bottom: barcode.corners.fold<double>(
          0,
          (bottom, corner) => math.max(bottom, corner.dy),
        ),
      ),
]);

bool isPromotionalUri(Uri uri) =>
    uri.host == 'small.kz' ||
    uri.host.endsWith('.small.kz') ||
    uri.host.contains('promo');

/// Unknown operators can be opened only after an explicit user action.
Uri? externalQrUri(String raw) {
  final uri = Uri.tryParse(normalizeQrText(raw));
  if (uri == null ||
      !['http', 'https'].contains(uri.scheme) ||
      uri.host.isEmpty ||
      uri.userInfo.isNotEmpty ||
      (uri.hasPort && uri.port != (uri.scheme == 'https' ? 443 : 80))) {
    return null;
  }
  return uri;
}
