import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:drift/drift.dart';

import '../../core/utils/money.dart';
import '../../core/utils/receipt_date.dart';
import '../../domain/models/qr_receipt.dart';
import '../db/app_database.dart';
import 'category_repository.dart';

class ImportResult {
  const ImportResult({required this.imported, required this.duplicates});
  final int imported;
  final int duplicates;
}

class CsvExport {
  const CsvExport({required this.receiptsCsv, required this.itemsCsv});
  final String receiptsCsv;
  final String itemsCsv;
}

class InvalidBackupException implements Exception {
  const InvalidBackupException();
}

class UnsupportedBackupException implements Exception {
  const UnsupportedBackupException();
}

class BackupRepository {
  BackupRepository(this.db);
  final AppDatabase db;
  static const _serializer = ValueSerializer.defaults(
    serializeDateTimeValuesAsString: true,
  );

  Future<String> exportJson() => db.transaction(() async {
    final stores = await db.select(db.stores).get();
    final categories = await db.select(db.categories).get();
    final receipts = await db.select(db.receipts).get();
    final items = await db.select(db.receiptItems).get();
    final rules = await db.select(db.categoryRules).get();
    return const JsonEncoder.withIndent('  ').convert({
      'format': 'checkscan',
      'version': 1,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'stores': stores.map((row) => row.toJson()).toList(),
      'categories': categories.map((row) => row.toJson()).toList(),
      'receipts': receipts.map((row) {
        final json = row.toJson(serializer: _serializer)..remove('debugRaw');
        json['dateTimeUtc'] = row.dateTimeUtc.toUtc().toIso8601String();
        json['createdAt'] = row.createdAt.toUtc().toIso8601String();
        json['updatedAt'] = row.updatedAt.toUtc().toIso8601String();
        json['nextRetryAt'] = row.nextRetryAt?.toUtc().toIso8601String();
        return json;
      }).toList(),
      'items': items.map((row) => row.toJson()).toList(),
      'rules': rules.map((row) => row.toJson()).toList(),
    });
  });

  Future<ImportResult> importJson(String raw) async {
    // Every row, reference and QR identity is validated before any writes.
    final backup = _ValidatedBackup.parse(raw);
    return db.transaction(() async {
      final categoryMap = <int, int>{};
      for (final row in backup.categories) {
        if (row.isBuiltIn) {
          final current =
              await (db.select(db.categories)..where(
                    (value) =>
                        value.id.equals(row.id) & value.isBuiltIn.equals(true),
                  ))
                  .getSingleOrNull();
          if (current == null) throw const InvalidBackupException();
          // Built-in identifiers are stable. Restore their editable appearance.
          await (db.update(db.categories)
                ..where((value) => value.id.equals(row.id)))
              .write(row.toCompanion(false).copyWith(id: const Value.absent()));
          categoryMap[row.id] = row.id;
        } else {
          final existing =
              await (db.select(db.categories)
                    ..where(
                      (value) =>
                          value.isBuiltIn.equals(false) &
                          value.name.equals(row.name) &
                          value.color.equals(row.color) &
                          value.icon.equals(row.icon),
                    )
                    ..limit(1))
                  .getSingleOrNull();
          categoryMap[row.id] =
              existing?.id ??
              await db
                  .into(db.categories)
                  .insert(
                    row.toCompanion(false).copyWith(id: const Value.absent()),
                  );
        }
      }
      final storeMap = <int, int>{};
      for (final row in backup.stores) {
        final query = db.select(db.stores)..limit(1);
        query.where(
          (value) => row.bin != null
              ? value.bin.equals(row.bin!)
              : value.bin.isNull() &
                    value.name.equals(row.name) &
                    (row.address == null
                        ? value.address.isNull()
                        : value.address.equals(row.address!)),
        );
        final existing = await query.getSingleOrNull();
        storeMap[row.id] =
            existing?.id ??
            await db
                .into(db.stores)
                .insert(
                  row.toCompanion(false).copyWith(id: const Value.absent()),
                );
      }
      final receiptMap = <int, int>{};
      var duplicates = 0;
      for (final row in backup.receipts) {
        if (await db.findReceiptByDedupKey(row.dedupKey) != null) {
          duplicates++;
          continue;
        }
        final saved = await db
            .into(db.receipts)
            .insert(
              row
                  .toCompanion(false)
                  .copyWith(
                    id: const Value.absent(),
                    storeId: Value(storeMap[row.storeId]),
                    categoryId: Value(categoryMap[row.categoryId]),
                    debugRaw: const Value(null),
                  ),
            );
        receiptMap[row.id] = saved;
      }
      for (final row in backup.items) {
        final receiptId = receiptMap[row.receiptId];
        if (receiptId == null) continue;
        await db
            .into(db.receiptItems)
            .insert(
              row
                  .toCompanion(false)
                  .copyWith(
                    id: const Value.absent(),
                    receiptId: Value(receiptId),
                    categoryId: Value(categoryMap[row.categoryId]),
                  ),
            );
      }
      for (final row in backup.rules) {
        await db
            .into(db.categoryRules)
            .insert(
              row
                  .toCompanion(false)
                  .copyWith(
                    id: const Value.absent(),
                    categoryId: Value(categoryMap[row.categoryId]!),
                  ),
              mode: InsertMode.insertOrIgnore,
            );
      }
      return ImportResult(imported: receiptMap.length, duplicates: duplicates);
    });
  }

  Future<CsvExport> exportCsv() => db.transaction(() async {
    final stores = {
      for (final row in await db.select(db.stores).get()) row.id: row,
    };
    final categories = {
      for (final row in await db.select(db.categories).get()) row.id: row.name,
    };
    final receipts = await (db.select(
      db.receipts,
    )..orderBy([(row) => OrderingTerm.asc(row.dateTimeUtc)])).get();
    final items =
        await (db.select(db.receiptItems)..orderBy([
              (row) => OrderingTerm.asc(row.receiptId),
              (row) => OrderingTerm.asc(row.position),
            ]))
            .get();
    final receiptById = {for (final row in receipts) row.id: row};
    final receiptRows = <List<dynamic>>[
      [
        'ID чека',
        'Магазин',
        'БИН',
        'Адрес',
        'Дата и время',
        'Смещение UTC, мин',
        'Итого, ₸',
        'Скидка, ₸',
        'НДС, ₸',
        'Категория',
        'Оплата',
        'Статус',
        'Проверить',
        'Изменён',
        'Заметка',
        'Фискальный признак',
        'РНМ',
        'Ссылка ОФД',
      ],
      for (final row in receipts)
        [
          row.id,
          _safeText(stores[row.storeId]?.name),
          _safeText(stores[row.storeId]?.bin),
          _safeText(stores[row.storeId]?.address),
          _localTime(row),
          row.tzOffsetMin ?? '',
          _amount(row.totalMinor),
          _amount(row.discountMinor),
          _amount(row.vatMinor),
          _safeText(categories[row.categoryId]),
          _safeText(row.paymentType),
          _safeText(row.status),
          row.needsReview ? 'Да' : 'Нет',
          row.edited ? 'Да' : 'Нет',
          _safeText(row.note),
          _safeText(row.fiscalSign),
          _safeText(row.kkmRegNumber),
          _safeText(row.sourceUrl),
        ],
    ];
    final itemRows = <List<dynamic>>[
      [
        'ID позиции',
        'ID чека',
        'Магазин',
        'Дата и время',
        'Позиция',
        'Название',
        'Полное название',
        'Количество',
        'Единица',
        'Цена, ₸',
        'Сумма, ₸',
        'Скидка, ₸',
        'Категория',
        'Штрихкод',
        'NTIN',
      ],
      for (final row in items)
        [
          row.id,
          row.receiptId,
          _safeText(stores[receiptById[row.receiptId]?.storeId]?.name),
          _localTime(receiptById[row.receiptId]!),
          row.position + 1,
          _safeText(row.name),
          _safeText(row.rawName),
          row.quantity.toString().replaceAll('.', ','),
          _safeText(row.unit),
          _amount(row.unitPriceMinor),
          _amount(row.sumMinor),
          _amount(row.discountMinor),
          _safeText(categories[row.categoryId]),
          _safeText(row.barcode),
          _safeText(row.ntin),
        ],
    ];
    final codec = Csv(fieldDelimiter: ';', addBom: true, autoDetect: false);
    return CsvExport(
      receiptsCsv: codec.encode(receiptRows),
      itemsCsv: codec.encode(itemRows),
    );
  });

  Future<void> clearAllData() async {
    await db.transaction(() async {
      await db.delete(db.receipts).go();
      await db.delete(db.stores).go();
      await db.delete(db.categoryRules).go();
      await (db.delete(
        db.categories,
      )..where((row) => row.isBuiltIn.equals(false))).go();
    });
    await CategoryRepository(db).initialize();
  }

  static String _amount(int? value) =>
      value == null ? '' : Money.decimal(value).replaceAll('.', ',');
  static String _safeText(String? value) {
    if (value == null) return '';
    if (RegExp(r'^[\s]*[=+@-]').hasMatch(value) ||
        value.startsWith('\t') ||
        value.startsWith('\r') ||
        value.startsWith('\n')) {
      return "'$value";
    }
    return value;
  }

  static String _localTime(ReceiptRow row) => row.dateTimeUtc
      .toUtc()
      .add(Duration(minutes: row.tzOffsetMin ?? 0))
      .toIso8601String()
      .replaceFirst('T', ' ')
      .replaceFirst('Z', '');
}

class _ValidatedBackup {
  const _ValidatedBackup(
    this.stores,
    this.categories,
    this.receipts,
    this.items,
    this.rules,
  );
  final List<StoreRow> stores;
  final List<CategoryRow> categories;
  final List<ReceiptRow> receipts;
  final List<ReceiptItemRow> items;
  final List<CategoryRuleRow> rules;

  factory _ValidatedBackup.parse(String raw) {
    try {
      if (raw.length > 32 * 1024 * 1024) throw const InvalidBackupException();
      final decoded = jsonDecode(
        raw.startsWith('\ufeff') ? raw.substring(1) : raw,
      );
      if (decoded is! Map<String, dynamic> ||
          decoded['format'] != 'checkscan') {
        throw const InvalidBackupException();
      }
      if (decoded['version'] is! int) throw const InvalidBackupException();
      if (decoded['version'] != 1) throw const UnsupportedBackupException();
      final storeJson = _rows(decoded, 'stores');
      final categoryJson = _rows(decoded, 'categories');
      final receiptJson = _rows(decoded, 'receipts');
      final itemJson = _rows(decoded, 'items');
      final ruleJson = _rows(decoded, 'rules');
      for (final row in storeJson) {
        _string(row, 'name', required: true);
        _string(row, 'bin');
        _string(row, 'address');
      }
      for (final row in categoryJson) {
        _string(row, 'name', required: true);
        _string(row, 'icon', required: true);
        _integer(row, 'color', min: 0, max: 0xffffffff);
        _integer(row, 'sortOrder', min: 0);
        _boolean(row, 'isBuiltIn');
        if (row['isBuiltIn'] == true && (row['id'] as int) > 16) {
          throw const InvalidBackupException();
        }
      }
      final storeIds = storeJson.map((row) => row['id'] as int).toSet();
      final categoryIds = categoryJson.map((row) => row['id'] as int).toSet();
      final dedupKeys = <String>{};
      for (final row in receiptJson) {
        _foreign(row, 'storeId', storeIds);
        _foreign(row, 'categoryId', categoryIds);
        for (final key in [
          'ofdName',
          'kkmRegNumber',
          'kkmSerial',
          'fiscalSign',
          'receiptNumber',
          'paymentType',
          'note',
          'lastError',
        ]) {
          _string(row, key);
        }
        for (final key in ['currency', 'dedupKey', 'status']) {
          _string(row, key, required: true);
        }
        final manual = (row['dedupKey'] as String).startsWith(
          AppDatabase.manualDedupPrefix,
        );
        _string(row, 'sourceUrl', required: !manual);
        if (row['currency'] != 'KZT' ||
            !['pending', 'ok', 'error'].contains(row['status'])) {
          throw const InvalidBackupException();
        }
        _integer(row, 'totalMinor', min: 0);
        _integer(row, 'discountMinor', min: 0, nullable: true);
        _integer(row, 'vatMinor', min: 0, nullable: true);
        _integer(row, 'tzOffsetMin', min: -840, max: 840, nullable: true);
        _integer(row, 'retryCount', min: 0);
        _number(row, 'vatRate', min: 0, max: 100, nullable: true);
        _boolean(row, 'needsReview');
        _boolean(row, 'edited');
        for (final key in ['dateTimeUtc', 'createdAt', 'updatedAt']) {
          _date(row, key);
        }
        _date(row, 'nextRetryAt', nullable: true);
        row['debugRaw'] = null;
        if (manual) {
          if (row['sourceUrl'] != '' ||
              row['status'] != 'ok' ||
              !dedupKeys.add(row['dedupKey'] as String)) {
            throw const InvalidBackupException();
          }
          continue;
        }
        final qr = QrReceipt.parse(row['sourceUrl'] as String);
        if (qr.dedupKey != row['dedupKey'] || !dedupKeys.add(qr.dedupKey)) {
          throw const InvalidBackupException();
        }
        if (row['edited'] != true && row['totalMinor'] != qr.totalMinor) {
          row['needsReview'] = true;
        }
        row['sourceUrl'] = qr.sourceUrl;
      }
      final receiptIds = receiptJson.map((row) => row['id'] as int).toSet();
      final positions = <String>{};
      for (final row in itemJson) {
        _foreign(row, 'receiptId', receiptIds, required: true);
        _foreign(row, 'categoryId', categoryIds);
        _integer(row, 'position', min: 0);
        if (!positions.add('${row['receiptId']}|${row['position']}')) {
          throw const InvalidBackupException();
        }
        _string(row, 'name', required: true);
        _string(row, 'rawName', required: true);
        for (final key in ['barcode', 'ntin', 'unit']) {
          _string(row, key);
        }
        _number(row, 'quantity', min: 0.000000001, max: 1000000000);
        _integer(row, 'unitPriceMinor', min: 0);
        _integer(row, 'sumMinor', min: 0);
        _integer(row, 'discountMinor', min: 0, nullable: true);
      }
      final ruleKeys = <String>{};
      for (final row in ruleJson) {
        _foreign(row, 'categoryId', categoryIds, required: true);
        _string(row, 'pattern', required: true);
        _boolean(row, 'isUser');
        if (!['keyword', 'barcode'].contains(row['kind']) ||
            !ruleKeys.add(
              '${row['kind']}|${row['pattern']}|${row['isUser']}',
            )) {
          throw const InvalidBackupException();
        }
      }
      return _ValidatedBackup(
        storeJson.map(StoreRow.fromJson).toList(),
        categoryJson.map(CategoryRow.fromJson).toList(),
        receiptJson.map(ReceiptRow.fromJson).toList(),
        itemJson.map(ReceiptItemRow.fromJson).toList(),
        ruleJson.map(CategoryRuleRow.fromJson).toList(),
      );
    } on UnsupportedBackupException {
      rethrow;
    } on Object {
      throw const InvalidBackupException();
    }
  }

  static List<Map<String, dynamic>> _rows(
    Map<String, dynamic> root,
    String key,
  ) {
    final value = root[key];
    if (value is! List || value.length > 100000) {
      throw const InvalidBackupException();
    }
    final ids = <int>{};
    return value.map((item) {
      if (item is! Map<String, dynamic>) throw const InvalidBackupException();
      _integer(item, 'id', min: 1);
      if (!ids.add(item['id'] as int)) throw const InvalidBackupException();
      return Map<String, dynamic>.from(item);
    }).toList();
  }

  static void _string(
    Map<String, dynamic> row,
    String key, {
    bool required = false,
  }) {
    final value = row[key];
    if (!required && value == null) return;
    if (value is! String ||
        value.length > 100000 ||
        (required && value.trim().isEmpty) ||
        value.contains('\u0000')) {
      throw const InvalidBackupException();
    }
  }

  static void _integer(
    Map<String, dynamic> row,
    String key, {
    int min = -9223372036854775808,
    int max = 9223372036854775807,
    bool nullable = false,
  }) {
    final value = row[key];
    if (nullable && value == null) return;
    if (value is! int || value < min || value > max) {
      throw const InvalidBackupException();
    }
  }

  static void _number(
    Map<String, dynamic> row,
    String key, {
    required double min,
    required double max,
    bool nullable = false,
  }) {
    final value = row[key];
    if (nullable && value == null) return;
    if (value is! num || !value.isFinite || value < min || value > max) {
      throw const InvalidBackupException();
    }
  }

  static void _boolean(Map<String, dynamic> row, String key) {
    if (row[key] is! bool) throw const InvalidBackupException();
  }

  static void _foreign(
    Map<String, dynamic> row,
    String key,
    Set<int> ids, {
    bool required = false,
  }) {
    final value = row[key];
    if (!required && value == null) return;
    if (value is! int || !ids.contains(value)) {
      throw const InvalidBackupException();
    }
  }

  static void _date(
    Map<String, dynamic> row,
    String key, {
    bool nullable = false,
  }) {
    final value = row[key];
    if (nullable && value == null) return;
    if (value is! String ||
        !RegExp(r'(?:Z|[+-]\d{2}:?\d{2})$').hasMatch(value)) {
      throw const InvalidBackupException();
    }
    row[key] = ReceiptDate.parse(value).utc.toIso8601String();
  }
}
