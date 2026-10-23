import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/errors/app_failure.dart';
import '../../domain/models/parsed_receipt.dart';
import '../../domain/models/qr_receipt.dart';
import '../db/app_database.dart';
import '../ofd/ofd_provider_registry.dart';
import 'category_repository.dart';

class ScanResult {
  const ScanResult({required this.receipt, required this.duplicate});
  final ReceiptRow receipt;
  final bool duplicate;
}

class ReceiptRepository {
  ReceiptRepository(
    this.db,
    this.registry, {
    DateTime Function()? now,
    this.pollInterval = const Duration(seconds: 15),
  }) : _now = now ?? DateTime.now;

  final AppDatabase db;
  final OfdProviderRegistry registry;
  final DateTime Function() _now;
  final Duration pollInterval;
  final Map<int, Future<ReceiptRow?>> _inflight = {};
  Timer? _timer;
  bool _retryingPending = false;
  bool _disposed = false;
  int _queueGeneration = 0;

  Stream<List<ReceiptListData>> watchHistory([
    ReceiptFilter filter = const ReceiptFilter(),
  ]) => db.watchHistory(filter);

  Stream<ReceiptDetailData?> watchDetail(int id) => db.watchReceiptDetail(id);

  Future<ScanResult> scan(String raw) async {
    final qr = QrReceipt.parse(raw);
    // Only the short local write is serialized. Network calls never hold an
    // open transaction, so offline scanning cannot block other local work.
    final initial = await db.transaction(() async {
      final existing = await db.findReceiptByDedupKey(qr.dedupKey);
      if (existing != null) {
        return ScanResult(receipt: existing, duplicate: true);
      }
      final savedId = await db
          .into(db.receipts)
          .insert(
            ReceiptsCompanion.insert(
              dateTimeUtc: qr.dateTimeUtc,
              tzOffsetMin: Value(qr.tzOffsetMin),
              totalMinor: qr.totalMinor,
              sourceUrl: qr.sourceUrl,
              dedupKey: qr.dedupKey,
              fiscalSign: Value(qr.fiscalSign),
              kkmRegNumber: Value(qr.kkmRegNumber),
              categoryId: const Value(AppDatabase.otherCategoryId),
            ),
          );
      return ScanResult(receipt: (await _read(savedId))!, duplicate: false);
    });
    if (initial.duplicate) return initial;
    final loaded = await retry(initial.receipt.id);
    return ScanResult(
      // A deletion during loading wins: return the captured value to the
      // caller, without recreating the deleted row.
      receipt: loaded ?? initial.receipt,
      duplicate: false,
    );
  }

  Future<ReceiptRow?> retry(int id) {
    final existing = _inflight[id];
    if (existing != null) return existing;
    final future = _retry(id).whenComplete(() {
      // Returning remove() here would return the same Future being completed,
      // causing whenComplete to wait on itself indefinitely.
      _inflight.remove(id);
    });
    _inflight[id] = future;
    return future;
  }

  Future<ReceiptRow?> _read(int id) => (db.select(
    db.receipts,
  )..where((row) => row.id.equals(id))).getSingleOrNull();

  Future<ReceiptRow?> _retry(int id) async {
    final current = await _read(id);
    if (current == null || current.edited || current.status == 'ok') {
      return current;
    }
    try {
      final qr = QrReceipt.parse(current.sourceUrl);
      final parsed = await registry.fetch(qr.uri);
      return await _saveParsed(id, parsed);
    } on AppFailure catch (failure) {
      return _saveFailure(id, failure);
    } catch (_) {
      return _saveFailure(id, const ParseFailure());
    }
  }

  Future<ReceiptRow?> _saveParsed(int id, ParsedReceipt parsed) async {
    final categories = CategoryRepository(db);
    await categories.initialize();
    return db.transaction(() async {
      final current = await _read(id);
      if (current == null || current.edited || current.status == 'ok') {
        return current;
      }
      final rules = await categories.rules();
      final itemCategories = [
        for (final item in parsed.items)
          categories.categorize(item.name, barcode: item.barcode, rules: rules),
      ];
      final storeId = await _findOrCreateStore(parsed);
      await (db.update(db.receipts)..where((row) => row.id.equals(id))).write(
        ReceiptsCompanion(
          id: Value(id),
          storeId: Value(storeId),
          ofdName: Value(parsed.ofdName),
          kkmRegNumber: Value(parsed.kkmRegNumber ?? current.kkmRegNumber),
          kkmSerial: Value(parsed.kkmSerial),
          fiscalSign: Value(parsed.fiscalSign ?? current.fiscalSign),
          receiptNumber: Value(parsed.receiptNumber),
          dateTimeUtc: Value(parsed.dateTimeUtc),
          tzOffsetMin: Value(parsed.tzOffsetMin),
          totalMinor: Value(parsed.totalMinor),
          discountMinor: Value(parsed.discountMinor),
          vatMinor: Value(parsed.vatMinor),
          vatRate: Value(parsed.vatRate),
          currency: Value(parsed.currency),
          paymentType: Value(parsed.paymentType),
          status: const Value('ok'),
          needsReview: Value(parsed.needsReview),
          categoryId: Value(
            CategoryRepository.dominantCategory([
              for (var index = 0; index < parsed.items.length; index++)
                (itemCategories[index], parsed.items[index].sumMinor),
            ]),
          ),
          nextRetryAt: const Value(null),
          lastError: const Value(null),
          debugRaw: Value(kDebugMode ? parsed.debugRaw : null),
          updatedAt: Value(_now().toUtc()),
        ),
      );
      await (db.delete(
        db.receiptItems,
      )..where((row) => row.receiptId.equals(id))).go();
      await db.batch(
        (batch) => batch.insertAll(db.receiptItems, [
          for (var index = 0; index < parsed.items.length; index++)
            _itemCompanion(
              id,
              index,
              parsed.items[index],
              itemCategories[index],
            ),
        ]),
      );
      return _read(id);
    });
  }

  ReceiptItemsCompanion _itemCompanion(
    int id,
    int position,
    ParsedItem item,
    int categoryId,
  ) => ReceiptItemsCompanion.insert(
    receiptId: id,
    position: position,
    name: item.name,
    rawName: item.rawName,
    barcode: Value(item.barcode),
    ntin: Value(item.ntin),
    quantity: item.quantity,
    unit: Value(item.unit),
    unitPriceMinor: item.unitPriceMinor,
    sumMinor: item.sumMinor,
    discountMinor: Value(item.discountMinor),
    categoryId: Value(categoryId),
  );

  Future<int> _findOrCreateStore(ParsedReceipt parsed) async {
    final query = db.select(db.stores)
      ..orderBy([(row) => OrderingTerm.asc(row.id)])
      ..limit(1);
    if (parsed.sellerBin != null) {
      query.where((row) => row.bin.equals(parsed.sellerBin!));
    } else {
      query.where(
        (row) =>
            row.bin.isNull() &
            row.name.equals(parsed.sellerName) &
            (parsed.storeAddress == null
                ? row.address.isNull()
                : row.address.equals(parsed.storeAddress!)),
      );
    }
    final existing = await query.getSingleOrNull();
    if (existing != null) return existing.id;
    return db
        .into(db.stores)
        .insert(
          StoresCompanion.insert(
            name: parsed.sellerName,
            bin: Value(parsed.sellerBin),
            address: Value(parsed.storeAddress),
          ),
        );
  }

  Future<ReceiptRow?> _saveFailure(int id, AppFailure failure) =>
      db.transaction(() async {
        final current = await _read(id);
        if (current == null || current.edited || current.status == 'ok') {
          return current;
        }
        const minutes = [1, 5, 30];
        final delay = minutes[current.retryCount.clamp(0, minutes.length - 1)];
        await (db.update(db.receipts)..where((row) => row.id.equals(id))).write(
          ReceiptsCompanion(
            status: Value(failure.isRetryable ? 'pending' : 'error'),
            lastError: Value(failure.message),
            retryCount: Value(current.retryCount + 1),
            nextRetryAt: Value(
              failure.isRetryable
                  ? _now().toUtc().add(Duration(minutes: delay))
                  : null,
            ),
            debugRaw: Value(
              kDebugMode && failure is ParseFailure ? failure.debugRaw : null,
            ),
            updatedAt: Value(_now().toUtc()),
          ),
        );
        return _read(id);
      });

  Future<void> retryPending({bool force = false}) async {
    if (_retryingPending || _disposed) return;
    _retryingPending = true;
    final generation = _queueGeneration;
    try {
      final rows = await db.pendingReceipts(
        dueBefore: force ? null : _now().toUtc(),
      );
      for (final receipt in rows) {
        if (_disposed || generation != _queueGeneration) break;
        await retry(receipt.id);
      }
    } finally {
      _retryingPending = false;
    }
  }

  Future<void> saveEdits(
    int id, {
    required String storeName,
    required DateTime dateTimeUtc,
    int? tzOffsetMin = 300,
    String? note,
    int? categoryId,
    required List<ReceiptItemEdit> items,
  }) => db.transaction(() async {
    final previous = await db.getReceiptDetail(id);
    if (previous == null) throw StateError('Чек уже удалён');
    if (previous.receipt.status != 'ok') {
      throw StateError('Сначала загрузите позиции чека');
    }
    final seller = _validSeller(storeName, items);
    int? storeId = previous.receipt.storeId;
    if (previous.store?.name != seller) {
      // A renamed receipt gets its own store record; other receipts of the
      // same legal entity keep their original merchant name and address.
      storeId = await db
          .into(db.stores)
          .insert(
            StoresCompanion.insert(
              name: seller,
              address: Value(previous.store?.address),
            ),
          );
    }
    final total = _itemsTotal(items);
    final changedTotal = total != previous.receipt.totalMinor;
    await db.saveReceipt(
      ReceiptsCompanion(
        id: Value(id),
        storeId: Value(storeId),
        dateTimeUtc: Value(dateTimeUtc.toUtc()),
        tzOffsetMin: Value(tzOffsetMin),
        totalMinor: Value(total),
        categoryId: Value(categoryId ?? previous.receipt.categoryId),
        note: Value(note?.trim().isEmpty == true ? null : note?.trim()),
        edited: const Value(true),
        needsReview: const Value(false),
        status: const Value('ok'),
        nextRetryAt: const Value(null),
        lastError: const Value(null),
        discountMinor: changedTotal ? const Value(null) : const Value.absent(),
        vatMinor: changedTotal ? const Value(null) : const Value.absent(),
        vatRate: changedTotal ? const Value(null) : const Value.absent(),
      ),
      [
        for (var position = 0; position < items.length; position++)
          items[position].toCompanion(id, position),
      ],
    );
  });

  /// Saves a purchase typed in by hand, for receipts whose QR is missing,
  /// unreadable or points to an unsupported OFD. Returns the new receipt id.
  Future<int> createManual({
    required String storeName,
    required DateTime dateTimeUtc,
    int tzOffsetMin = 300,
    String? note,
    int? categoryId,
    required List<ReceiptItemEdit> items,
  }) => db.transaction(() async {
    final seller = _validSeller(storeName, items);
    if (items.isEmpty) {
      throw const FormatException('Добавьте хотя бы одну позицию');
    }
    final existingStore =
        await (db.select(db.stores)
              ..where(
                (row) =>
                    row.bin.isNull() &
                    row.address.isNull() &
                    row.name.equals(seller),
              )
              ..orderBy([(row) => OrderingTerm.asc(row.id)])
              ..limit(1))
            .getSingleOrNull();
    final storeId =
        existingStore?.id ??
        await db.into(db.stores).insert(StoresCompanion.insert(name: seller));
    final now = _now().toUtc();
    return db.saveReceipt(
      ReceiptsCompanion.insert(
        storeId: Value(storeId),
        dateTimeUtc: dateTimeUtc.toUtc(),
        tzOffsetMin: Value(tzOffsetMin),
        totalMinor: _itemsTotal(items),
        sourceUrl: '',
        dedupKey:
            '${AppDatabase.manualDedupPrefix}${now.microsecondsSinceEpoch}-'
            '${Random().nextInt(1 << 32)}',
        status: const Value('ok'),
        edited: const Value(true),
        note: Value(note?.trim().isEmpty == true ? null : note?.trim()),
        categoryId: Value(
          categoryId ??
              CategoryRepository.dominantCategory([
                for (final item in items) (item.categoryId, item.sumMinor),
              ]),
        ),
        createdAt: Value(now),
        updatedAt: Value(now),
      ),
      [
        for (var position = 0; position < items.length; position++)
          items[position].toCompanion(0, position),
      ],
    );
  });

  static String _validSeller(String storeName, List<ReceiptItemEdit> items) {
    final seller = storeName.trim();
    if (seller.isEmpty) {
      throw const FormatException('Укажите название магазина');
    }
    for (final item in items) {
      if (item.name.trim().isEmpty ||
          !item.quantity.isFinite ||
          item.quantity <= 0) {
        throw const FormatException('Проверьте название и количество позиции');
      }
    }
    return seller;
  }

  static int _itemsTotal(List<ReceiptItemEdit> items) {
    final exactTotal = items.fold<BigInt>(
      BigInt.zero,
      (sum, item) => sum + BigInt.from(item.sumMinor),
    );
    if (exactTotal < BigInt.parse('-9223372036854775808') ||
        exactTotal > BigInt.parse('9223372036854775807')) {
      throw const FormatException('Итоговая сумма вне допустимого диапазона');
    }
    return exactTotal.toInt();
  }

  Future<ReceiptSnapshot?> deleteWithUndo(int id) => db.transaction(() async {
    final detail = await db.getReceiptDetail(id);
    if (detail == null) return null;
    await db.deleteReceipt(id);
    return ReceiptSnapshot(detail);
  });

  Future<int> restore(ReceiptSnapshot snapshot) => db.transaction(() async {
    final detail = snapshot.detail;
    final duplicate = await db.findReceiptByDedupKey(detail.receipt.dedupKey);
    if (duplicate != null) return duplicate.id;
    int? storeId = detail.receipt.storeId;
    if (detail.store != null && storeId != null) {
      final existing = await (db.select(
        db.stores,
      )..where((row) => row.id.equals(storeId!))).getSingleOrNull();
      if (existing == null) {
        final sameBin = detail.store!.bin == null
            ? null
            : await (db.select(db.stores)
                    ..where((row) => row.bin.equals(detail.store!.bin!)))
                  .getSingleOrNull();
        storeId =
            sameBin?.id ??
            await db.into(db.stores).insert(detail.store!.toCompanion(true));
      }
    }
    final categories = (await db.select(db.categories).get())
        .map((row) => row.id)
        .toSet();
    final idTaken = await _read(detail.receipt.id) != null;
    final id = await db
        .into(db.receipts)
        .insert(
          detail.receipt
              .toCompanion(true)
              .copyWith(
                id: idTaken ? const Value.absent() : Value(detail.receipt.id),
                storeId: Value(storeId),
                categoryId: Value(
                  detail.receipt.categoryId == null ||
                          categories.contains(detail.receipt.categoryId)
                      ? detail.receipt.categoryId
                      : AppDatabase.otherCategoryId,
                ),
              ),
        );
    for (final item in detail.items) {
      final itemIdTaken =
          await (db.select(
            db.receiptItems,
          )..where((row) => row.id.equals(item.id))).getSingleOrNull() !=
          null;
      await db
          .into(db.receiptItems)
          .insert(
            item
                .toCompanion(true)
                .copyWith(
                  id: itemIdTaken ? const Value.absent() : Value(item.id),
                  receiptId: Value(id),
                  categoryId: Value(
                    item.categoryId == null ||
                            categories.contains(item.categoryId)
                        ? item.categoryId
                        : AppDatabase.otherCategoryId,
                  ),
                ),
          );
    }
    return id;
  });

  void start() {
    if (_disposed || _timer != null) return;
    _timer = Timer.periodic(pollInterval, (_) => _runScheduled());
    _runScheduled(force: true);
  }

  void _runScheduled({bool force = false}) {
    // A closed database can race a lifecycle callback during app shutdown.
    unawaited(
      retryPending(force: force).catchError((Object _, StackTrace _) {}),
    );
  }

  void stop() {
    _queueGeneration++;
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    _disposed = true;
    stop();
  }
}

class ReceiptSnapshot {
  const ReceiptSnapshot(this.detail);
  final ReceiptDetailData detail;
}

class ReceiptItemEdit {
  const ReceiptItemEdit({
    required this.name,
    required this.quantity,
    required this.unitPriceMinor,
    required this.sumMinor,
    this.rawName,
    this.barcode,
    this.ntin,
    this.unit,
    this.discountMinor,
    this.categoryId,
  });

  factory ReceiptItemEdit.fromRow(ReceiptItemRow row) => ReceiptItemEdit(
    name: row.name,
    quantity: row.quantity,
    unitPriceMinor: row.unitPriceMinor,
    sumMinor: row.sumMinor,
    rawName: row.rawName,
    barcode: row.barcode,
    ntin: row.ntin,
    unit: row.unit,
    discountMinor: row.discountMinor,
    categoryId: row.categoryId,
  );

  final String name;
  final double quantity;
  final int unitPriceMinor;
  final int sumMinor;
  final String? rawName;
  final String? barcode;
  final String? ntin;
  final String? unit;
  final int? discountMinor;
  final int? categoryId;

  ReceiptItemsCompanion toCompanion(int id, int position) =>
      ReceiptItemsCompanion.insert(
        receiptId: id,
        position: position,
        name: name.trim(),
        rawName: rawName ?? name.trim(),
        quantity: quantity,
        unitPriceMinor: unitPriceMinor,
        sumMinor: sumMinor,
        barcode: Value(barcode),
        ntin: Value(ntin),
        unit: Value(unit),
        discountMinor: Value(discountMinor),
        categoryId: Value(categoryId),
      );
}
