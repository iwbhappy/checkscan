import '../../domain/models/parsed_receipt.dart';

bool receiptNeedsReview(
  List<ParsedItem> items,
  int totalMinor, {
  int? discountMinor,
}) {
  if (items.isEmpty) return true;
  final sum = items.fold<int>(0, (sum, item) => sum + item.sumMinor);
  final tolerance = items.length;
  // Item sums usually already contain discounts. Only subtract a receipt-wide
  // discount if that is the representation returned by this provider.
  return (sum - totalMinor).abs() > tolerance &&
      (sum - (discountMinor ?? 0) - totalMinor).abs() > tolerance;
}
