import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/l10n.dart';
import '../../../app/providers.dart';
import '../../../app/widgets.dart';
import '../../../app/failure_text.dart';
import '../../../data/db/app_database.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.categoriesTitle),
        actions: [
          IconButton(
            tooltip: l.addCategory,
            icon: const Icon(Icons.add),
            onPressed: () => _edit(context, ref),
          ),
        ],
      ),
      body: ref
          .watch(categoriesProvider)
          .when(
            loading: () => const LoadingSkeleton(),
            error: (error, _) => EmptyState(title: failureText(context, error)),
            data: (categories) => ListView(
              children: [
                for (final category in categories)
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(
                        category.color,
                      ).withValues(alpha: .18),
                      child: Icon(
                        categoryIcons[category.icon] ?? Icons.label_outline,
                        color: Color(category.color),
                      ),
                    ),
                    title: Text(category.name),
                    subtitle: category.isBuiltIn
                        ? Text(l.builtInCategory)
                        : null,
                    trailing: category.isBuiltIn
                        ? const Icon(Icons.lock_outline, size: 18)
                        : const Icon(Icons.edit_outlined),
                    onTap: category.isBuiltIn
                        ? null
                        : () => _edit(context, ref, category),
                  ),
                const Divider(),
                ListTile(
                  title: Text(
                    l.categoryRules,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  trailing: IconButton(
                    tooltip: l.addRule,
                    icon: const Icon(Icons.add),
                    onPressed: () => _rule(context, ref, categories),
                  ),
                ),
                ref
                    .watch(categoryRulesProvider)
                    .when(
                      loading: () => const SizedBox.shrink(),
                      error: (error, _) =>
                          ListTile(title: Text(failureText(context, error))),
                      data: (rules) => Column(
                        children: [
                          for (final rule in rules.where((rule) => rule.isUser))
                            ListTile(
                              title: Text(
                                rule.pattern.startsWith('=')
                                    ? rule.pattern.substring(1)
                                    : rule.pattern,
                              ),
                              subtitle: Text(
                                categories
                                        .where(
                                          (category) =>
                                              category.id == rule.categoryId,
                                        )
                                        .firstOrNull
                                        ?.name ??
                                    l.categoryOther,
                              ),
                              trailing: IconButton(
                                tooltip: l.delete,
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => _run(
                                  context,
                                  () => ref
                                      .read(categoryRepositoryProvider)
                                      .deleteRule(rule.id),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failureText(context, error))));
      }
    }
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref, [
    CategoryRow? category,
  ]) async {
    final l = context.l10n;
    var name = category?.name ?? '';
    var color = category?.color ?? 0xff008577;
    var icon = categoryIcons.containsKey(category?.icon)
        ? category!.icon
        : 'other';
    final form = GlobalKey<FormState>();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(category == null ? l.addCategory : l.editCategory),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: name,
                    onChanged: (value) => name = value,
                    maxLength: 80,
                    decoration: InputDecoration(labelText: l.categoryName),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? l.requiredField
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(l.categoryColor),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final candidate in [
                        0xff008577,
                        0xff1565c0,
                        0xff6a1b9a,
                        0xffc62828,
                        0xffef6c00,
                        0xff455a64,
                      ])
                        IconButton(
                          tooltip:
                              '#${candidate.toRadixString(16).substring(2)}',
                          style: IconButton.styleFrom(
                            backgroundColor: Color(candidate),
                          ),
                          onPressed: () => setState(() => color = candidate),
                          icon: Icon(
                            color == candidate ? Icons.check : Icons.circle,
                            color: Colors.white,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: icon,
                    isExpanded: true,
                    decoration: InputDecoration(labelText: l.categoryIcon),
                    items: [
                      for (final entry in categoryIcons.entries)
                        DropdownMenuItem(
                          value: entry.key,
                          child: Icon(entry.value),
                        ),
                    ],
                    onChanged: (value) => icon = value ?? icon,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            if (category != null)
              TextButton(
                onPressed: () => Navigator.pop(context, 'delete'),
                child: Text(l.delete),
              ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () {
                if (form.currentState!.validate()) {
                  Navigator.pop(context, 'save');
                }
              },
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
    name = name.trim();
    if (!context.mounted || result == null) return;
    if (result == 'delete' && category != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.deleteCategoryTitle),
          content: Text(l.deleteCategoryMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.delete),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        await _run(
          context,
          () =>
              ref.read(categoryRepositoryProvider).deleteCategory(category.id),
        );
      }
    } else {
      await _run(context, () async {
        await ref
            .read(categoryRepositoryProvider)
            .saveCategory(
              id: category?.id,
              name: name,
              color: color,
              icon: icon,
            );
      });
    }
  }

  Future<void> _rule(
    BuildContext context,
    WidgetRef ref,
    List<CategoryRow> categories,
  ) async {
    if (categories.isEmpty) return;
    final l = context.l10n;
    var keyword = '';
    var categoryId = categories.first.id;
    final form = GlobalKey<FormState>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.addRule),
        content: SingleChildScrollView(
          child: Form(
            key: form,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  onChanged: (value) => keyword = value,
                  decoration: InputDecoration(labelText: l.keyword),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? l.requiredField
                      : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: categoryId,
                  isExpanded: true,
                  items: [
                    for (final category in categories)
                      DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                  ],
                  onChanged: (value) => categoryId = value ?? categoryId,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (form.currentState!.validate()) Navigator.pop(context, true);
            },
            child: Text(l.save),
          ),
        ],
      ),
    );
    keyword = keyword.trim();
    if (confirmed == true && context.mounted) {
      await _run(
        context,
        () => ref
            .read(categoryRepositoryProvider)
            .saveKeywordRule(keyword, categoryId),
      );
    }
  }
}
