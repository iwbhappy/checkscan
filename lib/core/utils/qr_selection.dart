import '../../domain/models/qr_receipt.dart';

class QrCandidate {
  const QrCandidate({required this.rawValue, required this.bottom});
  final String rawValue;
  final double bottom;
}

QrReceipt? selectReceiptQr(Iterable<QrCandidate> candidates) {
  QrReceipt? selected;
  var lowest = double.negativeInfinity;
  for (final candidate in candidates) {
    final qr = QrReceipt.tryParse(candidate.rawValue);
    if (qr == null || !candidate.bottom.isFinite) continue;
    if (candidate.bottom >= lowest) {
      selected = qr;
      lowest = candidate.bottom;
    }
  }
  return selected;
}
