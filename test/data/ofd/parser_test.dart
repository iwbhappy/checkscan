import 'dart:convert';
import 'dart:io';

import 'package:checkscan/core/errors/app_failure.dart';
import 'package:checkscan/data/ofd/kazakhtelecom_receipt_parser.dart';
import 'package:checkscan/domain/models/parsed_receipt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final raw = File(
    'test/fixtures/ofd_responses/ticket.json',
  ).readAsStringSync();
  final source = Uri.parse(
    'http://consumer.oofd.kz?i=1462733895&f=010102236118&s=2002.00&t=20261007T153259',
  );
  const parser = KazakhtelecomReceiptParser();
  Map<String, dynamic> fixture() => jsonDecode(raw) as Map<String, dynamic>;

  test('real ticket maps every documented field to expected JSON', () {
    final receipt = parser.parse(raw, sourceUri: source);
    final expected =
        jsonDecode(
              File(
                'test/fixtures/ofd_responses/ticket.expected.json',
              ).readAsStringSync(),
            )
            as Map<String, dynamic>;
    expected.remove('dateTime');
    expected.remove('timeZoneAssumed');
    expected['dateTimeUtc'] = DateTime.parse(
      expected['dateTimeUtc'] as String,
    ).toIso8601String();
    expect(receipt.toJson(), expected);
    expect(receipt.localDateTime, DateTime.utc(2026, 10, 7, 15, 32, 59));
    expect(receipt.debugRaw, isNull);
    expect(() => receipt.items.clear(), throwsUnsupportedError);
    expect(ParsedReceipt.fromJson(receipt.toJson()).toJson(), receipt.toJson());
  });

  test('real HTML is a SPA, not invented receipt content', () {
    final html = File(
      'test/fixtures/ofd_responses/consumer.html',
    ).readAsStringSync();
    expect(
      () => parser.parse(html, sourceUri: source),
      throwsA(
        isA<ParseFailure>().having(
          (failure) => failure.debugRaw,
          'debugRaw',
          isNull,
        ),
      ),
    );
  });

  test('retains raw response only on explicit debug request', () {
    expect(
      parser.parse(raw, sourceUri: source, retainDebugRaw: true).debugRaw,
      raw,
    );
    expect(
      () => parser.parse('bad JSON', sourceUri: source, retainDebugRaw: true),
      throwsA(
        isA<ParseFailure>().having(
          (failure) => failure.debugRaw,
          'debugRaw',
          'bad JSON',
        ),
      ),
    );
  });

  test('missing receipt has a typed pending failure', () {
    for (final value in ['', 'null', '{}', '{"ticket":null}']) {
      expect(
        () => parser.parse(value, sourceUri: source),
        throwsA(isA<ReceiptNotFoundFailure>()),
      );
    }
    expect(
      () => parser.parse('[]', sourceUri: source),
      throwsA(isA<ParseFailure>()),
    );
  });

  test(
    'synthetic mutations retain data and mark totals or identity mismatch',
    () {
      final json = fixture();
      (json['ticket'] as Map)['totalSum'] = 2003.00;
      final changed = parser.parse(jsonEncode(json), sourceUri: source);
      expect(changed.needsReview, isTrue);
      expect(changed.items, hasLength(4));
      expect(changed.totalMinor, 200300);
      json['kkmFnsId'] = '999';
      (json['ticket'] as Map)['fiscalId'] = '222';
      expect(
        parser.parse(jsonEncode(json), sourceUri: source).needsReview,
        isTrue,
      );
    },
  );

  test('synthetic missing response time retains unconfirmed QR time', () {
    final json = fixture();
    final ticket = json['ticket'] as Map;
    ticket['transactionDate'] = null;
    ticket['fiscalId'] = null;
    ticket['options'] = null;
    ticket['payments'] = [];
    json['kkmFnsId'] = null;
    json['taxes'] = [];
    json['totalDiscount'] = null;
    final receipt = parser.parse(jsonEncode(json), sourceUri: source);
    expect(receipt.dateTimeUtc, DateTime.utc(2026, 10, 7, 15, 32, 59));
    expect(receipt.tzOffsetMin, isNull);
    expect(receipt.receiptNumber, isNull);
    expect(receipt.paymentType, isNull);
    expect(receipt.vatMinor, isNull);
    expect(receipt.vatRate, isNull);
    expect(receipt.discountMinor, isNull);
    expect(receipt.fiscalSign, '1462733895');
  });

  test('synthetic weight and mixed payment do not affect exact money', () {
    final json = fixture();
    final ticket = json['ticket'] as Map;
    ((ticket['items'] as List).first as Map)['commodity']['quantity'] = 0.534;
    ticket['payments'] = [
      {'paymentType': 'CASH'},
      {'paymentType': 'CARD'},
    ];
    json['taxes'] = [
      {'rate': 0.16, 'sum': 276.14},
      {'rate': 0.12, 'sum': 0},
    ];
    final receipt = parser.parse(jsonEncode(json), sourceUri: source);
    expect(receipt.items.first.quantity, 0.534);
    expect(receipt.items.first.sumMinor, 29900);
    expect(receipt.paymentType, 'mixed');
    expect(receipt.vatRate, isNull);
  });

  test('synthetic invalid required fields return parse failures', () {
    final missingName = fixture()..['orgTitle'] = '';
    expect(
      () => parser.parse(jsonEncode(missingName), sourceUri: source),
      throwsA(isA<ParseFailure>()),
    );
    final zeroQuantity = fixture();
    zeroQuantity['ticket']['items'][0]['commodity']['quantity'] = 0;
    expect(
      () => parser.parse(jsonEncode(zeroQuantity), sourceUri: source),
      throwsA(isA<ParseFailure>()),
    );
    final unknownRow = fixture();
    unknownRow['ticket']['items'].add({'itemType': 999});
    expect(
      () => parser.parse(jsonEncode(unknownRow), sourceUri: source),
      throwsA(isA<ParseFailure>()),
    );
  });
}
