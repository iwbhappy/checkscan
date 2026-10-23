import 'package:checkscan/core/errors/app_failure.dart';
import 'package:checkscan/core/utils/item_name.dart';
import 'package:checkscan/core/utils/money.dart';
import 'package:checkscan/core/utils/qr_selection.dart';
import 'package:checkscan/core/utils/receipt_date.dart';
import 'package:checkscan/core/utils/receipt_validation.dart';
import 'package:checkscan/domain/models/parsed_receipt.dart';
import 'package:checkscan/domain/models/qr_receipt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Money', () {
    test('decimal strings and JSON numbers stay exact', () {
      for (final value in ['299.00', '299,00', 299, 299.0]) {
        expect(Money.parseMinor(value), 29900);
      }
      expect(Money.parseMinor('1 299.00'), 129900);
      expect(Money.parseMinor('1\u00a0299,00'), 129900);
      expect(Money.parseMinor('0.29'), 29);
      expect(Money.parseMinor(276.14), 27614);
      expect(Money.parseMinor('-0.01'), -1);
      expect(Money.parseMinor('2.99e2'), 29900);
      expect(Money.parseMinor('92233720368547758.07'), 9223372036854775807);
      expect(Money.parseMinor('-92233720368547758.08'), -9223372036854775808);
      expect(Money.parseMinor('1.2300'), 123);
    });
    test('rejects invalid, sub-minor and overflowing values', () {
      for (final value in [
        '1.234',
        '',
        'NaN',
        '1,2.3',
        '92233720368547758.08',
        '1e1000',
        double.infinity,
      ]) {
        expect(() => Money.parseMinor(value), throwsFormatException);
      }
    });
    test('formats without float conversion', () {
      expect(Money.format(200200), '2 002,00 ₸');
      expect(Money.format(-1), '-0,01 ₸');
      expect(Money.decimal(3), '0.03');
    });
  });

  group('ReceiptDate', () {
    test('printed and ISO local times default to UTC+5', () {
      final printed = ReceiptDate.parse('07-10-2026 17:32');
      expect(printed.utc, DateTime.utc(2026, 10, 7, 12, 32));
      expect(printed.offsetMinutes, 300);
      expect(printed.local, DateTime.utc(2026, 10, 7, 17, 32));
      expect(
        ReceiptDate.parse('2026-10-07T15:32:59.000').utc,
        DateTime.utc(2026, 10, 7, 10, 32, 59),
      );
      expect(
        ReceiptDate.parse('20261007T153259').utc,
        DateTime.utc(2026, 10, 7, 10, 32, 59),
      );
    });
    test('preserves explicit timezone and microseconds', () {
      expect(
        ReceiptDate.parse('2026-10-07T15:32:59.123456Z').utc,
        DateTime.utc(2026, 10, 7, 15, 32, 59, 123, 456),
      );
      final date = ReceiptDate.parse('2026-10-07T15:32:59-0230');
      expect(date.utc, DateTime.utc(2026, 10, 7, 18, 2, 59));
      expect(date.offsetMinutes, -150);
      expect(ReceiptDate.parse('29-02-2024 00:00').local.day, 29);
    });
    test('does not normalize invalid dates', () {
      for (final value in [
        '31-02-2026 12:00',
        '2026-13-01T00:00',
        '2026-00-01T00:00',
        '2026-01-00T00:00',
        '2026-01-01T24:00',
        '2026-01-01T00:60',
        '2026-01-01T00:00:60',
        '2026-01-01T00:00+14:01',
        '2026-01-01T00:00+03:60',
        'yesterday',
      ]) {
        expect(() => ReceiptDate.parse(value), throwsFormatException);
      }
    });
  });

  test('selects Russian product before manufacturer', () {
    expect(
      russianItemName(
        'Галицкое сүті 1 л 2,5% - Молоко галиц.1л 2,5% - ПАВЛОДАР МОЛОКО',
      ),
      'Молоко галиц.1л 2,5%',
    );
    expect(
      russianItemName('Mars шоколадты батончигі - Бат.snickers 50,5 - MARS'),
      'Бат.snickers 50,5',
    );
    expect(russianItemName('Товар без разделителей'), 'Товар без разделителей');
    expect(russianItemName('сүт - MILK'), 'сүт - MILK');
    expect(russianItemName('Сүт - МОЛОКО'), 'МОЛОКО');
  });

  group('QR', () {
    const raw =
        'http://consumer.oofd.kz?i=1462733895&amp;f=010102236118&amp;s=2002.00&amp;t=20261007T153259';
    test('normalizes escaped separators and zero-prefixed KKM', () {
      final qr = QrReceipt.parse(raw);
      expect(qr.totalMinor, 200200);
      expect(qr.dedupKey, '1462733895|10102236118|200200');
      expect(qr.sourceUrl, isNot(contains('&amp;')));
      expect(qr.tzOffsetMin, isNull);
      expect(qr.localDateTime, DateTime.utc(2026, 10, 7, 15, 32, 59));
      final same = QrReceipt.parse(
        raw
            .replaceFirst('010102236118', '0010102236118')
            .replaceFirst('20261007T153259', '20261007T173259'),
      );
      expect(same.dedupKey, qr.dedupKey);
    });
    test('rejects spoofed domains, userinfo, ports and ambiguous fields', () {
      for (final host in [
        'fakeoofd.kz',
        'consumer.oofd.kz.evil.org',
        'consumer.oofd.kz@evil.org',
        'evil@consumer.oofd.kz',
        'consumer.oofd.kz:8080',
        '127.0.0.1',
        'consumer.oofd.kz.',
      ]) {
        expect(
          QrReceipt.tryParse(raw.replaceFirst('consumer.oofd.kz', host)),
          isNull,
        );
      }
      for (final value in [
        raw.replaceFirst('http:', 'file:'),
        '$raw&i=9',
        '$raw#fragment',
        raw.replaceFirst('2002.00', '-2'),
        raw.replaceFirst('20261007T153259', '20261307T153259'),
        raw.replaceFirst('i=1462733895', 'i=x'),
        'https://small.kz',
      ]) {
        expect(
          () => QrReceipt.parse(value),
          throwsA(isA<UnsupportedQrFailure>()),
        );
      }
      expect(
        QrReceipt.tryParse(
          raw.replaceFirst('consumer.oofd.kz', 'tickets.oofd.kz'),
        ),
        isNotNull,
      );
    });
  });

  test(
    'sum validation allows per-item rounding and informational discount',
    () {
      const items = [
        ParsedItem(
          name: 'А',
          rawName: 'А',
          quantity: 1,
          unitPriceMinor: 29900,
          sumMinor: 29900,
        ),
        ParsedItem(
          name: 'Б',
          rawName: 'Б',
          quantity: 1,
          unitPriceMinor: 43500,
          sumMinor: 43500,
        ),
      ];
      expect(receiptNeedsReview(items, 73400, discountMinor: 24200), isFalse);
      expect(receiptNeedsReview(items, 73398), isFalse);
      expect(receiptNeedsReview(items, 73397), isTrue);
      expect(receiptNeedsReview(items, 73300, discountMinor: 100), isFalse);
      expect(receiptNeedsReview([], 0), isTrue);
    },
  );

  test('selects lowest supported QR and ignores promotional codes', () {
    const base =
        'http://consumer.oofd.kz?i=1&amp;f=2&amp;s=3.00&amp;t=20261007T153259';
    final result = selectReceiptQr([
      const QrCandidate(rawValue: base, bottom: 100),
      const QrCandidate(rawValue: 'https://small.kz/promo', bottom: 900),
      QrCandidate(rawValue: base.replaceFirst('i=1', 'i=4'), bottom: 600),
      const QrCandidate(rawValue: base, bottom: double.nan),
      const QrCandidate(rawValue: '010.1452.071026.0122', bottom: 800),
    ]);
    expect(result?.fiscalSign, '4');
    expect(
      selectReceiptQr([
        const QrCandidate(rawValue: 'https://small.kz/promo', bottom: 10),
      ]),
      isNull,
    );
  });
}
