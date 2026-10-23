import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/data/repositories/category_repository.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late CategoryRepository repository;
  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = CategoryRepository(db);
    await repository.initialize();
  });
  tearDown(() => db.close());

  test(
    'built-in rules load once and classify Cyrillic and Latin names',
    () async {
      final original = await repository.rules();
      await repository.initialize();
      final rules = await repository.rules();
      expect(rules.length, original.length);
      expect(repository.categorize('МОЛОКО Галицкое', rules: rules), 2);
      expect(repository.categorize('SNICKERS батончик', rules: rules), 6);
      expect(repository.categorize('Пиво светлое', rules: rules), 8);
      expect(repository.categorize('Неизвестный товар', rules: rules), 16);
    },
  );

  test(
    'user rule overrides built-in and barcode beats remembered name',
    () async {
      await repository.saveKeywordRule('молоко', 1);
      await repository.rememberItem(name: 'Молоко 1л', categoryId: 6);
      await repository.rememberItem(
        name: 'Молоко 1л',
        barcode: '123456',
        categoryId: 7,
      );
      final rules = await repository.rules();
      expect(
        repository.categorize('Молоко 1л', barcode: '123456', rules: rules),
        7,
      );
      expect(repository.categorize('МОЛОКО  1л', rules: rules), 6);
      expect(repository.categorize('Молоко 1л другое', rules: rules), 1);
    },
  );

  test(
    'remembering a rule again updates it instead of adding conflicting rows',
    () async {
      await repository.rememberItem(
        name: 'Товар',
        barcode: '123',
        categoryId: 2,
      );
      await repository.rememberItem(
        name: 'Товар',
        barcode: '123',
        categoryId: 5,
      );
      final rules = (await repository.rules())
          .where((row) => row.isUser)
          .toList();
      expect(rules, hasLength(1));
      expect(rules.single.categoryId, 5);
    },
  );

  test(
    'custom category deletion remaps expenses and removes its rules',
    () async {
      final id = await repository.saveCategory(
        name: 'Работа',
        color: 0xff123456,
        icon: 'other',
      );
      await repository.saveKeywordRule('рабочий', id);
      final receiptId = await db.saveReceipt(
        ReceiptsCompanion.insert(
          dateTimeUtc: DateTime.utc(2026, 10),
          totalMinor: 12345,
          sourceUrl: 'https://consumer.oofd.kz',
          dedupKey: 'custom',
          categoryId: Value(id),
        ),
        [
          ReceiptItemsCompanion.insert(
            receiptId: 0,
            position: 0,
            name: 'Рабочий товар',
            rawName: 'Рабочий товар',
            quantity: 1,
            unitPriceMinor: 12345,
            sumMinor: 12345,
            categoryId: Value(id),
          ),
        ],
      );
      await repository.deleteCategory(id);
      final detail = (await db.getReceiptDetail(receiptId))!;
      expect(detail.receipt.categoryId, 16);
      expect(detail.items.single.categoryId, 16);
      expect(
        (await repository.rules()).where((rule) => rule.categoryId == id),
        isEmpty,
      );
      await expectLater(repository.deleteCategory(16), throwsStateError);
    },
  );

  test('default receipt category uses total amount rather than item count', () {
    expect(
      CategoryRepository.dominantCategory([(2, 100), (2, 100), (5, 500)]),
      5,
    );
    expect(CategoryRepository.dominantCategory([]), 16);
    expect(CategoryRepository.dominantCategory([(3, -1000), (4, -500)]), 3);
  });
}
