import 'dart:async';

import 'package:checkscan/core/errors/app_failure.dart';
import 'package:checkscan/data/db/app_database.dart';
import 'package:checkscan/data/ofd/ofd_provider.dart';
import 'package:checkscan/data/ofd/ofd_provider_registry.dart';
import 'package:checkscan/data/repositories/receipt_repository.dart';
import 'package:checkscan/domain/models/parsed_receipt.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

const qr =
    'http://consumer.oofd.kz?i=1462733895&f=010102236118&s=2002.00&t=20261007T153259';

ParsedReceipt parsed() => ParsedReceipt(
  sellerName: 'ТОО «Скиф Трейд»',
  sellerBin: '131141020408',
  dateTimeUtc: DateTime.utc(2026, 10, 7, 12, 32),
  totalMinor: 200200,
  items: const [
    ParsedItem(
      name: 'Молоко',
      rawName: 'Сүт - Молоко',
      quantity: 1,
      unitPriceMinor: 200200,
      sumMinor: 200200,
    ),
  ],
  sourceUrl: qr,
  debugRaw: '{"confirmed":true}',
);

class FakeOfd implements OfdProvider {
  int calls = 0;
  Future<ParsedReceipt> Function() response = () async => parsed();
  @override
  bool canHandle(Uri uri) => uri.host == 'consumer.oofd.kz';
  @override
  Future<ParsedReceipt> fetch(Uri uri) {
    calls++;
    return response();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppDatabase db;
  late FakeOfd ofd;
  late ReceiptRepository repository;
  final now = DateTime.utc(2026, 10, 7, 14);
  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    ofd = FakeOfd();
    repository = ReceiptRepository(
      db,
      OfdProviderRegistry([ofd]),
      now: () => now,
    );
  });
  tearDown(() async {
    repository.dispose();
    await db.close();
  });

  test(
    'pending identity is durable before the first network response',
    () async {
      final pendingResponse = Completer<ParsedReceipt>();
      ofd.response = () => pendingResponse.future;
      final resultFuture = repository.scan(qr);
      final saved = await db.watchHistory().firstWhere(
        (rows) => rows.isNotEmpty,
      );
      expect(saved.single.receipt.status, 'pending');
      expect(saved.single.receipt.totalMinor, 200200);
      expect(saved.single.receipt.tzOffsetMin, isNull);
      expect(saved.single.receipt.dedupKey, '1462733895|10102236118|200200');
      pendingResponse.complete(parsed());
      final result = await resultFuture;
      expect(result.receipt.status, 'ok');
      expect(result.receipt.tzOffsetMin, 300);
      expect(result.receipt.dedupKey, saved.single.receipt.dedupKey);
      final detail = await db.getReceiptDetail(result.receipt.id);
      expect(detail!.store!.bin, '131141020408');
      expect(detail.items.single.sumMinor, 200200);
    },
  );

  test(
    'concurrent scans normalize RNM zeros and make only one request',
    () async {
      final results = await Future.wait([
        repository.scan(qr),
        repository.scan(qr.replaceFirst('f=010102236118', 'f=0010102236118')),
      ]);
      expect(results.map((result) => result.receipt.id).toSet(), hasLength(1));
      expect(results.where((result) => result.duplicate), hasLength(1));
      expect(ofd.calls, 1);
    },
  );

  test(
    'a seller without BIN can reuse duplicated local store aliases',
    () async {
      final first = await db
          .into(db.stores)
          .insert(StoresCompanion.insert(name: 'ТОО «Скиф Трейд»'));
      await db
          .into(db.stores)
          .insert(StoresCompanion.insert(name: 'ТОО «Скиф Трейд»'));
      ofd.response = () async =>
          ParsedReceipt.fromJson({...parsed().toJson(), 'sellerBin': null});
      final row = (await repository.scan(qr)).receipt;
      expect(row.status, 'ok');
      expect(row.storeId, first);
      expect(await db.select(db.stores).get(), hasLength(2));
    },
  );

  test(
    'transient failures preserve QR fields and use 1/5/30 minute schedule',
    () async {
      ofd.response = () async => throw const NetworkFailure();
      var row = (await repository.scan(qr)).receipt;
      for (final minutes in [1, 5, 30, 30]) {
        expect(row.status, 'pending');
        expect(row.nextRetryAt!.toUtc(), now.add(Duration(minutes: minutes)));
        expect(row.totalMinor, 200200);
        expect(row.fiscalSign, '1462733895');
        row = (await repository.retry(row.id))!;
      }
      final count = ofd.calls;
      await repository.retryPending();
      expect(ofd.calls, count);
      ofd.response = () async => parsed();
      await repository.retryPending(force: true);
      expect((await db.getReceiptDetail(row.id))!.receipt.status, 'ok');
    },
  );

  test('parse error retains debug body and supports manual retry', () async {
    ofd.response = () async =>
        throw const ParseFailure(debugRaw: 'unparseable body');
    final row = (await repository.scan(qr)).receipt;
    expect(row.status, 'error');
    expect(row.debugRaw, 'unparseable body');
    expect(row.nextRetryAt, isNull);
    await repository.retryPending(force: true);
    expect(ofd.calls, 1);
    ofd.response = () async => parsed();
    expect((await repository.retry(row.id))!.status, 'ok');
  });

  test('deletion during fetch is never undone by a late response', () async {
    final pendingResponse = Completer<ParsedReceipt>();
    ofd.response = () => pendingResponse.future;
    final future = repository.scan(qr);
    final rows = await db.watchHistory().firstWhere((rows) => rows.isNotEmpty);
    await db.deleteReceipt(rows.single.receipt.id);
    pendingResponse.complete(parsed());
    await future;
    expect(await db.select(db.receipts).get(), isEmpty);
    expect(await db.select(db.receiptItems).get(), isEmpty);
    expect(await db.select(db.stores).get(), isEmpty);
  });

  test(
    'manual edits win over both retry requests and in-flight responses',
    () async {
      final pendingResponse = Completer<ParsedReceipt>();
      final requestStarted = Completer<void>();
      ofd.response = () {
        requestStarted.complete();
        return pendingResponse.future;
      };
      final future = repository.scan(qr);
      final rows = await db.watchHistory().firstWhere(
        (rows) => rows.isNotEmpty,
      );
      final id = rows.single.receipt.id;
      await requestStarted.future;
      await (db.update(db.receipts)..where((row) => row.id.equals(id))).write(
        const ReceiptsCompanion(edited: Value(true), totalMinor: Value(12345)),
      );
      pendingResponse.complete(parsed());
      expect((await future).receipt.totalMinor, 12345);
      await repository.retry(id);
      await repository.retryPending(force: true);
      expect(ofd.calls, 1);
      expect((await db.getReceiptDetail(id))!.receipt.totalMinor, 12345);
    },
  );

  test(
    'invalid QR produces a typed error without touching storage or network',
    () async {
      await expectLater(
        repository.scan('https://small.kz/promo'),
        throwsA(isA<UnsupportedQrFailure>()),
      );
      expect(await db.select(db.receipts).get(), isEmpty);
      expect(ofd.calls, 0);
    },
  );

  test(
    'editing recalculates totals and isolates store name from other receipts',
    () async {
      final first = await repository.scan(qr);
      final second = await repository.scan(
        qr.replaceFirst('i=1462733895', 'i=1462733896'),
      );
      final date = DateTime.utc(2026, 10, 8, 13);
      await repository.saveEdits(
        first.receipt.id,
        storeName: 'Личный магазин',
        dateTimeUtc: date,
        note: 'На неделю',
        categoryId: 2,
        items: const [
          ReceiptItemEdit(
            name: 'Молоко',
            quantity: 2,
            unitPriceMinor: 29900,
            sumMinor: 59800,
            categoryId: 2,
          ),
          ReceiptItemEdit(
            name: 'Хлеб',
            quantity: 1,
            unitPriceMinor: 15000,
            sumMinor: 15000,
            categoryId: 5,
          ),
        ],
      );
      final edited = (await db.getReceiptDetail(first.receipt.id))!;
      expect(edited.receipt.totalMinor, 74800);
      expect(edited.receipt.edited, true);
      expect(edited.receipt.note, 'На неделю');
      expect(edited.receipt.dateTimeUtc.toUtc(), date);
      expect(edited.receipt.dedupKey, first.receipt.dedupKey);
      expect(edited.store!.name, 'Личный магазин');
      expect(
        (await db.getReceiptDetail(second.receipt.id))!.store!.name,
        'ТОО «Скиф Трейд»',
      );
      final duplicate = await repository.scan(qr);
      expect(duplicate.duplicate, true);
      expect(duplicate.receipt.totalMinor, 74800);
    },
  );

  test('pending edit is rejected and keeps the QR total', () async {
    ofd.response = () async => throw const NetworkFailure();
    final row = (await repository.scan(qr)).receipt;
    await expectLater(
      repository.saveEdits(
        row.id,
        storeName: 'Name',
        dateTimeUtc: now,
        items: [],
      ),
      throwsStateError,
    );
    final saved = (await db.getReceiptDetail(row.id))!.receipt;
    expect(saved.totalMinor, 200200);
    expect(saved.edited, false);
    expect(saved.status, 'pending');
  });

  test(
    'editing rejects integer overflow and rolls back every change',
    () async {
      final row = (await repository.scan(qr)).receipt;
      await expectLater(
        repository.saveEdits(
          row.id,
          storeName: 'Не сохранять',
          dateTimeUtc: now,
          items: const [
            ReceiptItemEdit(
              name: 'A',
              quantity: 1,
              unitPriceMinor: 9223372036854775807,
              sumMinor: 9223372036854775807,
            ),
            ReceiptItemEdit(
              name: 'B',
              quantity: 1,
              unitPriceMinor: 1,
              sumMinor: 1,
            ),
          ],
        ),
        throwsFormatException,
      );
      final detail = (await db.getReceiptDetail(row.id))!;
      expect(detail.receipt.totalMinor, 200200);
      expect(detail.store!.name, 'ТОО «Скиф Трейд»');
      expect(await db.select(db.stores).get(), hasLength(1));
    },
  );

  test(
    'delete and undo restore receipt and item identities without duplicates',
    () async {
      final row = (await repository.scan(qr)).receipt;
      final original = (await db.getReceiptDetail(row.id))!;
      final snapshot = (await repository.deleteWithUndo(row.id))!;
      expect(await db.getReceiptDetail(row.id), isNull);
      expect(await db.select(db.receiptItems).get(), isEmpty);
      final restoredId = await repository.restore(snapshot);
      final restored = (await db.getReceiptDetail(restoredId))!;
      expect(restoredId, row.id);
      expect(restored.receipt.dedupKey, row.dedupKey);
      expect(restored.items.single.id, original.items.single.id);
      expect(restored.items.single.name, original.items.single.name);
      expect(await repository.restore(snapshot), restoredId);
      expect(await db.select(db.receipts).get(), hasLength(1));
    },
  );
}
