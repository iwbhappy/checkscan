import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart';

import '../db/app_database.dart';

String normalizedCategoryText(String value) => value
    .toLowerCase()
    .replaceAll('ё', 'е')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

class CategoryRepository {
  CategoryRepository(this.db);
  final AppDatabase db;

  Future<void> initialize() async {
    final text = await rootBundle.loadString('assets/category_rules.json');
    final groups = (jsonDecode(text) as List).cast<Map<String, dynamic>>();
    await db.batch((batch) {
      for (final group in groups) {
        for (final keyword in (group['keywords'] as List).cast<String>()) {
          batch.insert(
            db.categoryRules,
            CategoryRulesCompanion.insert(
              kind: 'keyword',
              pattern: normalizedCategoryText(keyword),
              categoryId: group['categoryId'] as int,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }
    });
  }

  Stream<List<CategoryRow>> watchCategories() =>
      (db.select(db.categories)..orderBy([
            (row) => OrderingTerm.asc(row.sortOrder),
            (row) => OrderingTerm.asc(row.id),
          ]))
          .watch();

  Stream<List<CategoryRuleRow>> watchRules() =>
      (db.select(db.categoryRules)..orderBy([
            (row) => OrderingTerm.desc(row.isUser),
            (row) => OrderingTerm.asc(row.pattern),
          ]))
          .watch();

  Future<int> saveCategory({
    int? id,
    required String name,
    required int color,
    required String icon,
  }) async {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw const FormatException('Укажите название категории');
    }
    if (id == null) {
      return db
          .into(db.categories)
          .insert(
            CategoriesCompanion.insert(
              name: normalized,
              color: color,
              icon: icon,
              sortOrder: const Value(100),
            ),
          );
    }
    final changed =
        await (db.update(
          db.categories,
        )..where((row) => row.id.equals(id))).write(
          CategoriesCompanion(
            name: Value(normalized),
            color: Value(color),
            icon: Value(icon),
          ),
        );
    if (changed == 0) throw StateError('Категория удалена');
    return id;
  }

  Future<void> deleteCategory(int id) => db.transaction(() async {
    final category = await (db.select(
      db.categories,
    )..where((row) => row.id.equals(id))).getSingleOrNull();
    if (category == null) return;
    if (category.isBuiltIn) {
      throw StateError('Встроенную категорию нельзя удалить');
    }
    await (db.update(
      db.receipts,
    )..where((row) => row.categoryId.equals(id))).write(
      const ReceiptsCompanion(categoryId: Value(AppDatabase.otherCategoryId)),
    );
    await (db.update(
      db.receiptItems,
    )..where((row) => row.categoryId.equals(id))).write(
      const ReceiptItemsCompanion(
        categoryId: Value(AppDatabase.otherCategoryId),
      ),
    );
    await (db.delete(db.categories)..where((row) => row.id.equals(id))).go();
  });

  Future<void> rememberItem({
    required String name,
    String? barcode,
    required int categoryId,
  }) {
    final code = barcode?.trim();
    if (code != null && code.isNotEmpty) {
      return _saveRule('barcode', code, categoryId);
    }
    final normalized = normalizedCategoryText(name);
    if (normalized.isEmpty) {
      throw const FormatException('Укажите название позиции');
    }
    // The '=' marker distinguishes an exact remembered name from a keyword
    // while retaining the v1 schema's two supported rule kinds.
    return _saveRule('keyword', '=$normalized', categoryId);
  }

  Future<void> saveKeywordRule(String keyword, int categoryId) {
    final pattern = normalizedCategoryText(keyword);
    if (pattern.isEmpty || pattern.startsWith('=')) {
      throw const FormatException(
        'Укажите ключевое слово без знака = в начале',
      );
    }
    return _saveRule('keyword', pattern, categoryId);
  }

  Future<void> _saveRule(String kind, String pattern, int categoryId) =>
      db.transaction(() async {
        final existing =
            await (db.select(db.categoryRules)..where(
                  (row) =>
                      row.kind.equals(kind) &
                      row.pattern.equals(pattern) &
                      row.isUser.equals(true),
                ))
                .getSingleOrNull();
        if (existing == null) {
          await db
              .into(db.categoryRules)
              .insert(
                CategoryRulesCompanion.insert(
                  kind: kind,
                  pattern: pattern,
                  categoryId: categoryId,
                  isUser: const Value(true),
                ),
              );
        } else {
          await (db.update(db.categoryRules)
                ..where((row) => row.id.equals(existing.id)))
              .write(CategoryRulesCompanion(categoryId: Value(categoryId)));
        }
      });

  Future<void> deleteRule(int id) async {
    await (db.delete(
      db.categoryRules,
    )..where((row) => row.id.equals(id) & row.isUser.equals(true))).go();
  }

  Future<List<CategoryRuleRow>> rules() => db.select(db.categoryRules).get();

  int categorize(
    String name, {
    String? barcode,
    required List<CategoryRuleRow> rules,
  }) {
    final normalized = normalizedCategoryText(name);
    final ordered = [...rules]
      ..sort((a, b) {
        final userOrder = (b.isUser ? 1 : 0).compareTo(a.isUser ? 1 : 0);
        if (userOrder != 0) return userOrder;
        int specificity(CategoryRuleRow rule) => rule.kind == 'barcode'
            ? 2
            : rule.pattern.startsWith('=')
            ? 1
            : 0;
        final specific = specificity(b).compareTo(specificity(a));
        if (specific != 0) return specific;
        final length = b.pattern.length.compareTo(a.pattern.length);
        return length == 0 ? a.id.compareTo(b.id) : length;
      });
    for (final rule in ordered) {
      final matches = rule.kind == 'barcode'
          ? barcode != null && barcode.trim() == rule.pattern
          : rule.pattern.startsWith('=')
          ? normalized == rule.pattern.substring(1)
          : normalized.contains(rule.pattern);
      if (matches) return rule.categoryId;
    }
    return AppDatabase.otherCategoryId;
  }

  static int dominantCategory(Iterable<(int?, int)> amounts) {
    final sums = <int, int>{};
    for (final (category, amount) in amounts) {
      final id = category ?? AppDatabase.otherCategoryId;
      sums[id] = (sums[id] ?? 0) + amount;
    }
    if (sums.isEmpty) return AppDatabase.otherCategoryId;
    final entries = sums.entries.toList()
      ..sort((a, b) {
        final amount = b.value.abs().compareTo(a.value.abs());
        return amount == 0 ? a.key.compareTo(b.key) : amount;
      });
    return entries.first.key;
  }
}
