import 'dart:convert';

import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/data/repositories/backup_repository.dart';
import 'package:csv/csv.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const sourceUrl =
    'http://consumer.oofd.kz?i=1462733895&f=010102236118&s=2002.00&t=20261007T153259';
const dedup = '1462733895|10102236118|200200';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase source;
  late AppDatabase target;
  late BackupRepository exporter;
  late BackupRepository importer;

  setUp(() {
    source = AppDatabase(NativeDatabase.memory());
    target = AppDatabase(NativeDatabase.memory());
    exporter = BackupRepository(source);
    importer = BackupRepository(target);
  });
  tearDown(() async {
    await source.close();
    await target.close();
  });

  Future<void> seed() async {
    final category = await source
        .into(source.categories)
        .insert(
          CategoriesCompanion.insert(
            name: 'Для праздника',
            color: 0xff112233,
            icon: 'sweets',
          ),
        );
    final store = await source
        .into(source.stores)
        .insert(
          StoresCompanion.insert(
            name: 'Магазин «Дома»',
            bin: const Value('131141020408'),
            address: const Value('ул. Сатпаева, 47'),
          ),
        );
    await source.saveReceipt(
      ReceiptsCompanion.insert(
        storeId: Value(store),
        dateTimeUtc: DateTime.utc(2026, 10, 7, 10, 32, 59),
        tzOffsetMin: const Value(300),
        totalMinor: 210000,
        sourceUrl: sourceUrl,
        dedupKey: dedup,
        status: const Value('ok'),
        edited: const Value(true),
        categoryId: Value(category),
        note: const Value('Покупки; на праздник'),
        vatMinor: const Value(27614),
        discountMinor: const Value(0),
        debugRaw: const Value('SECRET_DEBUG_RESPONSE'),
      ),
      [
        ReceiptItemsCompanion.insert(
          receiptId: 0,
          position: 0,
          name: 'Творог',
          rawName: 'Сүзбе - Творог',
          quantity: 0.534,
          unitPriceMinor: 30000,
          sumMinor: 16020,
          barcode: const Value('004607065001445'),
          ntin: const Value('0200134355469'),
          categoryId: Value(category),
        ),
        ReceiptItemsCompanion.insert(
          receiptId: 0,
          position: 1,
          name: 'Торт',
          rawName: 'Торт',
          quantity: 1,
          unitPriceMinor: 193980,
          sumMinor: 193980,
          categoryId: const Value(6),
        ),
      ],
    );
    await source
        .into(source.categoryRules)
        .insert(
          CategoryRulesCompanion.insert(
            kind: 'keyword',
            pattern: '=творог',
            categoryId: category,
            isUser: const Value(true),
          ),
        );
    await (source.update(source.categories)..where((row) => row.id.equals(1)))
        .write(const CategoriesCompanion(name: Value('Повседневные продукты')));
  }

  test(
    'JSON roundtrip remaps colliding ids and preserves edited QR identity',
    () async {
      await seed();
      await target
          .into(target.categories)
          .insert(
            CategoriesCompanion.insert(
              name: 'Уже существующая',
              color: 1,
              icon: 'other',
            ),
          );
      await target
          .into(target.stores)
          .insert(
            StoresCompanion.insert(
              name: 'Другой магазин',
              bin: const Value('999999999999'),
            ),
          );
      await target.insertPending(
        ReceiptsCompanion.insert(
          dateTimeUtc: DateTime.utc(2026, 1, 1),
          totalMinor: 100,
          sourceUrl: sourceUrl
              .replaceFirst('i=1462733895', 'i=9')
              .replaceFirst('s=2002.00', 's=1.00'),
          dedupKey: '9|10102236118|100',
        ),
      );
      final backup = await exporter.exportJson();
      expect(backup, isNot(contains('debugRaw')));
      expect(backup, isNot(contains('SECRET_DEBUG_RESPONSE')));
      final decoded = jsonDecode(backup) as Map;
      expect(decoded['format'], 'checkscan');
      expect(decoded['version'], 1);
      expect(decoded['receipts'][0]['dateTimeUtc'], '2026-10-07T10:32:59.000Z');
      final result = await importer.importJson(backup);
      expect(result.imported, 1);
      expect(result.duplicates, 0);
      final saved = (await target.findReceiptByDedupKey(dedup))!;
      final detail = (await target.getReceiptDetail(saved.id))!;
      expect(saved.id, 2);
      expect(saved.totalMinor, 210000);
      expect(saved.dedupKey, dedup);
      expect(saved.edited, isTrue);
      expect(saved.tzOffsetMin, 300);
      expect(saved.debugRaw, isNull);
      expect(saved.note, 'Покупки; на праздник');
      expect(detail.items, hasLength(2));
      expect(detail.items.first.quantity, 0.534);
      expect(detail.items.first.barcode, '004607065001445');
      expect(detail.items.first.categoryId, saved.categoryId);
      expect(saved.categoryId, 18);
      expect(detail.store!.bin, '131141020408');
      final rules = await target.select(target.categoryRules).get();
      expect(rules.single.pattern, '=творог');
      expect(rules.single.categoryId, saved.categoryId);
      expect(
        (await (target.select(
          target.categories,
        )..where((row) => row.id.equals(1))).getSingle()).name,
        'Повседневные продукты',
      );
    },
  );

  test(
    'repeated merge skips receipts/items and reuses categories/stores/rules',
    () async {
      await seed();
      final backup = await exporter.exportJson();
      await importer.importJson(backup);
      final second = await importer.importJson(backup);
      expect(second.imported, 0);
      expect(second.duplicates, 1);
      expect(await target.select(target.receipts).get(), hasLength(1));
      expect(await target.select(target.receiptItems).get(), hasLength(2));
      expect(await target.select(target.categories).get(), hasLength(17));
      expect(await target.select(target.stores).get(), hasLength(1));
      expect(await target.select(target.categoryRules).get(), hasLength(1));
    },
  );

  test(
    'malformed values, broken references and unsafe URLs make no partial writes',
    () async {
      await seed();
      final raw = await exporter.exportJson();
      final mutations = <void Function(Map<String, dynamic>)>[
        (data) => data.remove('items'),
        (data) => data['receipts'][0]['totalMinor'] = 2002.5,
        (data) =>
            data['receipts'][0]['sourceUrl'] = 'https://evil.example/receipt',
        (data) => data['receipts'][0]['dedupKey'] = 'forged',
        (data) => data['receipts'][0]['dateTimeUtc'] = '2026-02-31T15:32:59Z',
        (data) => data['receipts'][0]['dateTimeUtc'] = '2026-10-07T15:32:59',
        (data) => data['receipts'][0]['tzOffsetMin'] = 900,
        (data) => data['receipts'][0]['status'] = 'deleted',
        (data) => data['receipts'][0]['currency'] = 'USD',
        (data) => data['items'][0]['receiptId'] = 999,
        (data) => data['items'][0]['categoryId'] = 999,
        (data) => data['items'][0]['quantity'] = 0,
        (data) => data['items'][0]['id'] = '1',
        (data) => data['items'][1]['position'] = 0,
        (data) => data['items'].add(data['items'][0]),
        (data) => data['categories'][0]['id'] = -1,
        (data) => data['rules'][0]['kind'] = 'regex',
        (data) => data['stores'][0]['name'] = '',
      ];
      for (final mutate in mutations) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        mutate(data);
        await expectLater(
          importer.importJson(jsonEncode(data)),
          throwsA(isA<InvalidBackupException>()),
        );
        expect(await target.select(target.receipts).get(), isEmpty);
        expect(await target.select(target.stores).get(), isEmpty);
        expect(await target.select(target.categories).get(), hasLength(16));
      }
    },
  );

  test(
    'unknown version is separate from invalid input and BOM is accepted',
    () async {
      await seed();
      final raw = await exporter.exportJson();
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      decoded['version'] = 2;
      await expectLater(
        importer.importJson(jsonEncode(decoded)),
        throwsA(isA<UnsupportedBackupException>()),
      );
      await expectLater(
        importer.importJson('not JSON'),
        throwsA(isA<InvalidBackupException>()),
      );
      await expectLater(
        importer.importJson('[]'),
        throwsA(isA<InvalidBackupException>()),
      );
      expect((await importer.importJson('\ufeff$raw')).imported, 1);
    },
  );

  test(
    'database failures roll back all changes from the import transaction',
    () async {
      await seed();
      await (target.delete(
        target.categories,
      )..where((row) => row.id.equals(2))).go();
      final before = (await (target.select(
        target.categories,
      )..where((row) => row.id.equals(1))).getSingle()).name;
      await expectLater(
        importer.importJson(await exporter.exportJson()),
        throwsA(isA<InvalidBackupException>()),
      );
      expect(
        (await (target.select(
          target.categories,
        )..where((row) => row.id.equals(1))).getSingle()).name,
        before,
      );
      expect(await target.select(target.receipts).get(), isEmpty);
      expect(await target.select(target.stores).get(), isEmpty);
    },
  );

  test(
    'CSV keeps Cyrillic, decimal money, semicolon quoting, BOM and formula safety',
    () async {
      await seed();
      await source
          .update(source.stores)
          .write(const StoresCompanion(name: Value('=SUM(1;2)')));
      await source
          .update(source.receipts)
          .write(const ReceiptsCompanion(note: Value('@danger\n"строка"')));
      final output = await exporter.exportCsv();
      expect(utf8.encode(output.receiptsCsv).take(3), [239, 187, 191]);
      expect(utf8.encode(output.itemsCsv).take(3), [239, 187, 191]);
      final codec = Csv(fieldDelimiter: ';', autoDetect: false);
      final receipts = codec.decode(output.receiptsCsv);
      expect(receipts, hasLength(2));
      expect(receipts.first[1], 'Магазин');
      expect(receipts[1][1], "'=SUM(1;2)");
      expect(receipts[1][6], '2100,00');
      expect(receipts[1][8], '276,14');
      expect(receipts[1][14], '\'@danger\n"строка"');
      expect(receipts[1][4], '2026-10-07 15:32:59.000');
      final items = codec.decode(output.itemsCsv);
      expect(items, hasLength(3));
      expect(items[1][5], 'Творог');
      expect(items[1][7], '0,534');
      expect(items[1][10], '160,20');
      expect(output.receiptsCsv, isNot(contains('SECRET_DEBUG_RESPONSE')));
    },
  );

  test(
    'clear deletes personal data and restores default keyword rules',
    () async {
      await seed();
      await exporter.clearAllData();
      expect(await source.select(source.receipts).get(), isEmpty);
      expect(await source.select(source.receiptItems).get(), isEmpty);
      expect(await source.select(source.stores).get(), isEmpty);
      final categories = await source.select(source.categories).get();
      expect(categories, hasLength(16));
      expect(categories.every((row) => row.isBuiltIn), isTrue);
      final rules = await source.select(source.categoryRules).get();
      expect(rules, isNotEmpty);
      expect(rules.every((row) => !row.isUser), isTrue);
    },
  );
}
