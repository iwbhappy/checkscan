import 'package:checkscan/core/utils/receipt_text_parser.dart';
import 'package:checkscan/core/utils/merchant_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const parser = ReceiptTextParser();
  test('Russian receipt keeps exact amounts and a valid local date', () {
    final draft = parser.parse(
      'ТОО «Магазин»\n07.10.2026 17:32:59\nМолоко 435,00\nХлеб 150.00\nИТОГО: 585,00 ₸\nКАРТА 585.00\nНДС 80.69',
    );
    expect(draft.sellerName, 'ТОО «Магазин»');
    expect(draft.totalMinor, 58500);
    expect(draft.localDate, DateTime.utc(2026, 10, 7, 17, 32, 59));
    expect(draft.items.map((item) => item.name), ['Молоко', 'Хлеб']);
    expect(draft.totalsMatch, true);
  });
  test('Kazakh total on following line and spacing are supported', () {
    final draft = parser.parse('Дүкен\nСүт 435.00\nБАРЛЫҒЫ\n1 435,00 тг');
    expect(draft.totalMinor, 143500);
    expect(draft.items, hasLength(1));
    expect(draft.totalsMatch, false);
  });
  test('payment total takes priority over subtotal', () {
    expect(
      parser.parse('Shop\nК ОПЛАТЕ 900.00\nИТОГО 1000.00').totalMinor,
      90000,
    );
  });
  test('unknown totals and invalid dates stay missing', () {
    final draft = parser.parse(
      'Магазин\n31.02.2026 12:30\nИТОГО: 8O0.OO\nНДС 100.00',
    );
    expect(draft.totalMinor, isNull);
    expect(draft.localDate, isNull);
    expect(draft.items, isEmpty);
  });
  test('empty text never invents a merchant, date, total or items', () {
    final draft = parser.parse('');
    expect(draft.sellerName, isNull);
    expect(draft.localDate, isNull);
    expect(draft.totalMinor, isNull);
    expect(draft.items, isEmpty);
  });

  test('explicit fractional quantity and price are retained', () {
    final draft = parser.parse(
      'Магазин\nЯблоки 0,534 x 1000.00 = 534.00\nИТОГО 534.00',
    );
    expect(draft.items.single.quantity, 0.534);
    expect(draft.items.single.unitPriceMinor, 100000);
    expect(draft.items.single.sumMinor, 53400);
  });

  test('grouped line amounts do not become part of the product name', () {
    final draft = parser.parse('Магазин\nКофе 1 250.00\nИТОГО 1250.00');
    expect(draft.items.single.name, 'Кофе');
    expect(draft.items.single.sumMinor, 125000);
  });
  test('return receipt is flagged for explicit handling', () {
    expect(parser.parse('ЧЕК ВОЗВРАТА\nИТОГО 500.00').possibleReturn, true);
    expect(
      parser.parse('Спасибо!\nВозврат сдачи 100.00').possibleReturn,
      false,
    );
  });
  test('a display label preserves the legal name in its caller', () {
    const name = 'ПАВЛОДАРСКИЙ ФИЛИАЛ ТОО "СКИФ ТРЕЙД"';
    expect(merchantDisplayName(name), 'СКИФ ТРЕЙД');
    expect(merchantDisplayName('ИП Иванов'), 'Иванов');
    expect(merchantDisplayName('Дүкен'), 'Дүкен');
  });
}
