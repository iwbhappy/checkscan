import '../../domain/models/parsed_receipt.dart';
import '../../domain/models/receipt_draft.dart';
import 'money.dart';

/// Conservative extraction: missing values stay missing, never become zero.
class ReceiptTextParser {
  const ReceiptTextParser();

  ReceiptDraft parse(String text, {String? fingerprint}) {
    final lines = text
        .replaceAll('\u00a0', ' ')
        .split(RegExp(r'[\r\n]+'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    int? total;
    var totalPriority = 0;
    DateTime? date;
    String? seller;
    final items = <ParsedItem>[];
    var afterTotal = false;
    final totalLabel = RegExp(
      r'^(К\s*ОПЛАТЕ|СУММА\s*К\s*ОПЛАТЕ|ИТОГО|ИТОГ|БАРЛЫҒЫ|ЖАЛПЫ|TOTAL)(?=\s|:|=|$)\s*[:=]?\s*(.*)$',
      caseSensitive: false,
    );
    final ignored = RegExp(
      r'^(?:НДС|ҚҚС|СКИДК|ЖЕҢІЛДІК|СДАЧА|НАЛИЧ|БЕЗНАЛ|КАРТА|ОПЛАТА|БАНК|ЧЕК|ФИСКАЛ|ФП\b|ФН\b|РНМ|БИН|ИИН|КАСС|ККМ|АДРЕС|ТЕЛЕФОН|ДАТА|ВРЕМЯ|ПРОДАЖА|ВОЗВРАТ|СПАСИБО|САЛЫҚ|ТӨЛЕМ|DISCOUNT|CASH|CARD|CHANGE|VAT|TOTAL)',
      caseSensitive: false,
    );
    final amount = RegExp(
      r'^\s*(\d[\d ]*(?:[.,]\d{2})?)\s*(?:₸|тг\.?|KZT|тенге)?\s*$',
      caseSensitive: false,
    );
    int? money(String value) {
      final match = amount.firstMatch(value);
      if (match == null) return null;
      try {
        return Money.parseMinor(match.group(1)!);
      } on FormatException {
        return null;
      }
    }

    for (var index = 0; index < lines.length && index < 3000; index++) {
      final line = lines[index];
      final totalMatch = totalLabel.firstMatch(line);
      if (totalMatch != null) {
        final value =
            money(totalMatch.group(2)!) ??
            (index + 1 < lines.length ? money(lines[index + 1]) : null);
        final priority = totalMatch.group(1)!.toUpperCase().contains('ОПЛАТЕ')
            ? 2
            : 1;
        if (value != null && priority >= totalPriority) {
          total = value;
          totalPriority = priority;
        }
        afterTotal = true;
        continue;
      }
      final dateMatch = RegExp(
        r'\b(\d{2})[./-](\d{2})[./-](\d{4})\s+(\d{2}):(\d{2})(?::(\d{2}))?',
      ).firstMatch(line);
      if (date == null && dateMatch != null) {
        final day = int.parse(dateMatch.group(1)!);
        final month = int.parse(dateMatch.group(2)!);
        final year = int.parse(dateMatch.group(3)!);
        final hour = int.parse(dateMatch.group(4)!);
        final minute = int.parse(dateMatch.group(5)!);
        final second = int.parse(dateMatch.group(6) ?? '0');
        final candidate = DateTime.utc(year, month, day, hour, minute, second);
        if (year >= 2000 &&
            month == candidate.month &&
            day == candidate.day &&
            hour < 24 &&
            minute < 60 &&
            second < 60) {
          date = candidate;
        }
        continue;
      }
      if (seller == null &&
          index < 8 &&
          !ignored.hasMatch(line) &&
          RegExp(r'[А-Яа-яӘәҒғҚқҢңӨөҰұҮүҺһІіA-Za-z]{3}').hasMatch(line) &&
          !RegExp(r'\d+[.,]\d{2}\s*$').hasMatch(line)) {
        seller = line;
        continue;
      }
      if (afterTotal || ignored.hasMatch(line) || items.length >= 500) continue;
      final quantityLine = RegExp(
        r'^(.+?)\s+(\d+(?:[.,]\d{1,6})?)\s*[xх×*]\s*(\d+[.,]\d{2})\s*[= ]\s*(\d+[.,]\d{2})\s*(?:₸|тг|KZT)?$',
        caseSensitive: false,
      ).firstMatch(line);
      if (quantityLine != null) {
        final name = quantityLine.group(1)!.trim();
        final quantity = double.tryParse(
          quantityLine.group(2)!.replaceAll(',', '.'),
        );
        final price = money(quantityLine.group(3)!);
        final sum = money(quantityLine.group(4)!);
        if (quantity != null &&
            quantity.isFinite &&
            quantity > 0 &&
            price != null &&
            sum != null) {
          items.add(
            ParsedItem(
              name: name,
              rawName: line,
              quantity: quantity,
              unitPriceMinor: price,
              sumMinor: sum,
            ),
          );
          continue;
        }
      }
      // A name and an explicit two-decimal line amount are required.
      final item = RegExp(
        r'^(.+?[А-Яа-яӘәҒғҚқҢңӨөҰұҮүҺһІіA-Za-z].*?)\s+(\d{1,3}(?: \d{3})*[.,]\d{2}|\d+[.,]\d{2})\s*(?:₸|тг|KZT)?$',
        caseSensitive: false,
      ).firstMatch(line);
      if (item == null) continue;
      final name = item
          .group(1)!
          .replaceFirst(RegExp(r'^\d+[.)]\s*'), '')
          .trim();
      if (name.length < 2 || ignored.hasMatch(name)) continue;
      final sum = money(item.group(2)!);
      if (sum == null) continue;
      // Quantity and unit price are unknown unless explicitly printed.
      // One line is presented for review with its observed amount.
      items.add(
        ParsedItem(
          name: name,
          rawName: line,
          quantity: 1,
          unitPriceMinor: sum,
          sumMinor: sum,
        ),
      );
    }
    return ReceiptDraft(
      rawText: text,
      sellerName: seller,
      localDate: date,
      totalMinor: total,
      items: items,
      fingerprint: fingerprint,
      possibleReturn: RegExp(
        r'чек\s+возврата|возврат\s+(?:прихода|продажи|товара)|қайтару',
        caseSensitive: false,
      ).hasMatch(text),
    );
  }
}
