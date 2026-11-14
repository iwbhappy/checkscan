import 'parsed_receipt.dart';

/// Unconfirmed data from OCR or a document. Never saved without user review.
class ReceiptDraft {
  const ReceiptDraft({
    required this.rawText,
    this.sellerName,
    this.localDate,
    this.totalMinor,
    this.items = const [],
    this.fingerprint,
    this.possibleReturn = false,
  });
  final String rawText;
  final String? sellerName;
  final DateTime? localDate;
  final int? totalMinor;
  final List<ParsedItem> items;
  final String? fingerprint;
  final bool possibleReturn;
  bool get totalsMatch =>
      totalMinor != null &&
      items.isNotEmpty &&
      items.fold<int>(0, (sum, item) => sum + item.sumMinor) == totalMinor;
}
