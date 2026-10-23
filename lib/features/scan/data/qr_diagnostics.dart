import 'package:flutter/foundation.dart';

import '../../../domain/models/qr_receipt.dart';

class QrDebugSnapshot {
  const QrDebugSnapshot({this.rawQr = '', this.response = ''});
  final String rawQr;
  final String response;
  String get decodedQr => normalizeQrText(rawQr);
  String get text =>
      'QR RAW:\n$rawQr\n\nQR NORMALIZED:\n$decodedQr\n\nOFD:\n$response';
}

final qrDiagnostics = ValueNotifier(const QrDebugSnapshot());

void recordRawQr(String raw) {
  if (!kDebugMode) return;
  qrDiagnostics.value = QrDebugSnapshot(rawQr: raw);
  debugPrint('CheckScan QR RAW: $raw');
}

void recordOfdDebugResponse(String? response) {
  if (!kDebugMode) return;
  qrDiagnostics.value = QrDebugSnapshot(
    rawQr: qrDiagnostics.value.rawQr,
    response: response ?? '',
  );
}
