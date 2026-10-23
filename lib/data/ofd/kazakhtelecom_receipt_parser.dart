import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/errors/app_failure.dart';
import '../../core/utils/item_name.dart';
import '../../core/utils/money.dart';
import '../../core/utils/receipt_date.dart';
import '../../core/utils/receipt_validation.dart';
import '../../domain/models/parsed_receipt.dart';
import '../../domain/models/qr_receipt.dart';

/// Maps the real consumer.oofd.kz get-by-url response (see OFD_FORMAT.md).
class KazakhtelecomReceiptParser {
  const KazakhtelecomReceiptParser();

  ParsedReceipt parse(
    String raw, {
    required Uri sourceUri,
    bool retainDebugRaw = false,
  }) {
    retainDebugRaw = kDebugMode && retainDebugRaw;
    if (raw.trim().isEmpty || raw.trim() == 'null') {
      throw const ReceiptNotFoundFailure();
    }
    try {
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) throw const FormatException();
      if (!json.containsKey('ticket') || json['ticket'] == null) {
        throw const ReceiptNotFoundFailure();
      }
      final ticket = json['ticket'] as Map<String, dynamic>;
      if (ticket['type'] != 'TICKET' || ticket['operationType'] != 2) {
        throw const FormatException('Неизвестный тип операции ОФД');
      }
      final qr = QrReceipt.parse(sourceUri.toString());
      final units = (json['measureUnits'] as Map<String, dynamic>?) ?? {};
      final rawItems = ticket['items'] as List;
      final items = rawItems.map((value) {
        final row = value as Map<String, dynamic>;
        if (row['itemType'] != 1) {
          throw const FormatException('Неизвестный тип позиции ОФД');
        }
        final commodity = row['commodity'] as Map<String, dynamic>;
        final rawName = commodity['name'] as String;
        final quantity = num.parse(commodity['quantity'].toString()).toDouble();
        if (!quantity.isFinite || quantity <= 0) throw const FormatException();
        return ParsedItem(
          name: russianItemName(rawName),
          rawName: rawName,
          quantity: quantity,
          unitPriceMinor: Money.parseMinor(commodity['price'] as Object),
          sumMinor: Money.parseMinor(commodity['sum'] as Object),
          barcode: _string(commodity['barcode']),
          ntin: _string(commodity['ntin']),
          unit: _string(units[commodity['measureUnitCode']?.toString()]),
          discountMinor: _discount(row['discount']),
        );
      }).toList();
      final total = Money.parseMinor(ticket['totalSum'] as Object);
      final discount = json['totalDiscount'] == null
          ? null
          : Money.parseMinor(json['totalDiscount'] as Object);
      final taxes = (json['taxes'] as List?) ?? [];
      final vat = taxes.isEmpty
          ? null
          : taxes.fold<int>(
              0,
              (sum, tax) =>
                  sum + Money.parseMinor((tax as Map)['sum'] as Object),
            );
      final rates = taxes
          .map(
            (tax) =>
                num.parse((tax as Map)['rate'].toString()).toDouble() * 100,
          )
          .toSet();
      final payments = (ticket['payments'] as List?) ?? [];
      final paymentTypes = payments
          .map(
            (payment) =>
                (payment as Map)['paymentType']?.toString().toLowerCase(),
          )
          .whereType<String>()
          .toSet();
      final dateText = _string(ticket['transactionDate']);
      final date = dateText == null ? null : ReceiptDate.parse(dateText);
      final fiscalSign = _string(ticket['fiscalId']) ?? qr.fiscalSign;
      final kkm = _string(json['kkmFnsId']) ?? qr.kkmRegNumber;
      final identityMismatch =
          fiscalSign != qr.fiscalSign ||
          normalizedKkmNumber(kkm) != normalizedKkmNumber(qr.kkmRegNumber) ||
          total != qr.totalMinor;
      final seller = _string(json['orgTitle']);
      if (seller == null) throw const FormatException();
      return ParsedReceipt(
        ofdName: 'АО Казахтелеком',
        sellerName: seller,
        sellerBin: _string(json['orgId']),
        storeAddress: _string(json['retailPlaceAddress']),
        kkmRegNumber: kkm,
        kkmSerial: _string(json['kkmSerialNumber']),
        fiscalSign: fiscalSign,
        receiptNumber: _findOption(ticket['options'], 'printedDocumentNumber'),
        dateTimeUtc: date?.utc ?? qr.dateTimeUtc,
        tzOffsetMin: date?.offsetMinutes ?? qr.tzOffsetMin,
        totalMinor: total,
        discountMinor: discount,
        vatMinor: vat,
        vatRate: rates.length == 1 ? rates.single : null,
        paymentType: paymentTypes.length > 1
            ? 'mixed'
            : paymentTypes.firstOrNull,
        items: items,
        sourceUrl: qr.sourceUrl,
        needsReview:
            identityMismatch ||
            receiptNeedsReview(items, total, discountMinor: discount),
        debugRaw: retainDebugRaw ? raw : null,
      );
    } on AppFailure {
      rethrow;
    } on Object {
      throw ParseFailure(debugRaw: retainDebugRaw ? raw : null);
    }
  }

  static String? _string(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static int? _discount(Object? value) {
    if (value == null) return null;
    // Non-null discount records have not yet been observed. Do not invent their
    // schema; the receipt-level totalDiscount remains the source of truth.
    return value is num || value is String ? Money.parseMinor(value) : null;
  }

  static String? _findOption(Object? value, String name) {
    if (value is! Map) return null;
    if (value['name'] == name) return _string(value['value']);
    for (final child in (value['children'] as List?) ?? []) {
      final found = _findOption(child, name);
      if (found != null) return found;
    }
    return null;
  }
}
