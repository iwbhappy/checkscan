import 'dart:io';

import 'package:checkscan/data/db/app_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('v1 migration persists data and does not reseed on reopen', () async {
    final directory = await Directory.systemTemp.createTemp(
      'checkscan_migration_',
    );
    final file = File('${directory.path}/checkscan.sqlite');
    var db = AppDatabase(NativeDatabase(file));
    try {
      final inserted = await db.insertPending(
        ReceiptsCompanion.insert(
          dateTimeUtc: DateTime.utc(2026, 10, 7, 15, 32, 59),
          totalMinor: 200200,
          sourceUrl:
              'https://consumer.oofd.kz?i=1462733895&f=010102236118'
              '&s=2002.00&t=20261007T153259',
          dedupKey: '1462733895|10102236118|200200',
        ),
      );
      await db.close();
      db = AppDatabase(NativeDatabase(file));
      final loaded = await db.findReceiptByDedupKey(inserted.dedupKey);
      expect(loaded?.id, inserted.id);
      expect(loaded?.totalMinor, 200200);
      expect(loaded?.tzOffsetMin, isNull);
      expect(await db.select(db.categories).get(), hasLength(16));
      final version = await db.customSelect('PRAGMA user_version').getSingle();
      expect(version.read<int>('user_version'), db.schemaVersion);
      expect(await db.customSelect('PRAGMA foreign_key_check').get(), isEmpty);
      final integrity = await db
          .customSelect('PRAGMA integrity_check')
          .getSingle();
      expect(integrity.read<String>('integrity_check'), 'ok');
    } finally {
      await db.close();
      await directory.delete(recursive: true);
    }
  });
}
