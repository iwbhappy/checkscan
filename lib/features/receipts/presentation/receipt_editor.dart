import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/failure_text.dart';
import '../../../app/format.dart';
import '../../../app/l10n.dart';
import '../../../app/providers.dart';
import '../../../app/widgets.dart';
import '../../../core/utils/money.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/receipt_repository.dart';
import 'receipt_providers.dart';

Future<bool> offerRememberCategory(BuildContext context, String name) async {
  final l = context.l10n;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.rememberCategoryTitle),
          content: Text(l.rememberCategoryMessage(name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l.onlyThisItem),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l.remember),
            ),
          ],
        ),
      ) ??
      false;
}

Future<int?> chooseReceiptCategory(
  BuildContext context,
  List<CategoryRow> categories,
  int? selected,
) => showModalBottomSheet<int>(
  context: context,
  useSafeArea: true,
  isScrollControlled: true,
  builder: (context) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.6,
    maxChildSize: 0.9,
    builder: (context, controller) => ListView(
      controller: controller,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            context.l10n.chooseCategory,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        for (final category in categories)
          ListTile(
            leading: Icon(
              categoryIcons[category.icon] ?? Icons.category_outlined,
            ),
            title: Text(category.name),
            trailing: selected == category.id ? const Icon(Icons.check) : null,
            onTap: () => Navigator.pop(context, category.id),
          ),
      ],
    ),
  ),
);

ReceiptItemEdit itemWithCategory(ReceiptItemRow item, int category) =>
    ReceiptItemEdit(
      name: item.name,
      rawName: item.rawName,
      quantity: item.quantity,
      unitPriceMinor: item.unitPriceMinor,
      sumMinor: item.sumMinor,
      barcode: item.barcode,
      ntin: item.ntin,
      unit: item.unit,
      discountMinor: item.discountMinor,
      categoryId: category,
    );

class ReceiptEditor extends ConsumerStatefulWidget {
  /// Without [detail] the editor creates a new manually entered purchase.
  const ReceiptEditor({this.detail, super.key});
  final ReceiptDetailData? detail;

  @override
  ConsumerState<ReceiptEditor> createState() => _ReceiptEditorState();
}

class _ReceiptEditorState extends ConsumerState<ReceiptEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _store;
  late final TextEditingController _note;
  late DateTime _date;
  late List<ReceiptItemEdit> _items;
  final _rememberItems = <ReceiptItemEdit>{};
  int? _category;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final detail = widget.detail;
    _store = TextEditingController(text: detail?.store?.name ?? '');
    _note = TextEditingController(text: detail?.receipt.note ?? '');
    final now = kazakhstanNow();
    _date = detail == null
        ? DateTime.utc(now.year, now.month, now.day, now.hour, now.minute)
        : receiptLocalDate(detail.receipt);
    _category = detail?.receipt.categoryId;
    _items = detail?.items.map(ReceiptItemEdit.fromRow).toList() ?? [];
  }

  bool get _isNew => widget.detail == null;

  @override
  void dispose() {
    _store.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _editItem([int? index]) async {
    final result = await showModalBottomSheet<_EditedItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ItemEditor(item: index == null ? null : _items[index]),
    );
    if (result == null || !mounted) return;
    final item = result.item;
    setState(() {
      if (index == null) {
        _items.add(item);
      } else {
        _rememberItems.remove(_items[index]);
        _items[index] = item;
      }
      if (result.rememberCategory) _rememberItems.add(item);
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(kazakhstanNow().year + 10),
    );
    if (date == null || !mounted) return;
    setState(
      () => _date = DateTime.utc(
        date.year,
        date.month,
        date.day,
        _date.hour,
        _date.minute,
        _date.second,
      ),
    );
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _date.hour, minute: _date.minute),
    );
    if (time == null || !mounted) return;
    setState(
      () => _date = DateTime.utc(
        _date.year,
        _date.month,
        _date.day,
        time.hour,
        time.minute,
      ),
    );
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate() || _saving) return;
    if (_isNew && _items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.addAtLeastOneItem)));
      return;
    }
    setState(() => _saving = true);
    try {
      final repository = ref.read(receiptRepositoryProvider);
      final offset = widget.detail?.receipt.tzOffsetMin ?? 300;
      final dateTimeUtc = DateTime.utc(
        _date.year,
        _date.month,
        _date.day,
        _date.hour,
        _date.minute,
        _date.second,
      ).subtract(Duration(minutes: offset));
      int? createdId;
      if (_isNew) {
        createdId = await repository.createManual(
          storeName: _store.text,
          dateTimeUtc: dateTimeUtc,
          tzOffsetMin: offset,
          categoryId: _category,
          note: _note.text,
          items: _items,
        );
      } else {
        await repository.saveEdits(
          widget.detail!.receipt.id,
          storeName: _store.text,
          dateTimeUtc: dateTimeUtc,
          tzOffsetMin: offset,
          categoryId: _category,
          note: _note.text,
          items: _items,
        );
      }
      for (final item in _rememberItems) {
        if (_items.contains(item) && item.categoryId != null) {
          await ref
              .read(categoryRepositoryProvider)
              .rememberItem(
                name: item.name,
                barcode: item.barcode,
                categoryId: item.categoryId!,
              );
        }
      }
      if (!mounted) return;
      if (createdId != null) {
        context.pushReplacement('/receipts/$createdId');
      } else {
        Navigator.pop(context, true);
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failureText(context, error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final categories = ref.watch(receiptCategoriesProvider).asData?.value ?? [];
    // A new purchase without an explicit category gets the dominant category
    // of its items on save; show that choice in advance.
    final shownCategory =
        _category ??
        (_isNew
            ? CategoryRepository.dominantCategory([
                for (final item in _items) (item.categoryId, item.sumMinor),
              ])
            : null);
    final category = categories
        .where((row) => row.id == shownCategory)
        .firstOrNull;
    final total = _items.fold<int>(0, (sum, item) => sum + item.sumMinor);
    return Scaffold(
      appBar: AppBar(title: Text(_isNew ? l.newPurchase : l.editReceipt)),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_isNew) ...[
                Text(l.manualEntryHint),
                const SizedBox(height: 16),
              ],
              TextFormField(
                key: const ValueKey('receipt-store'),
                controller: _store,
                enabled: !_saving,
                autofocus: _isNew,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l.storeName),
                validator: (value) => value == null || value.trim().isEmpty
                    ? l.requiredField
                    : null,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _pickDate,
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text(DateFormat.yMMMd('ru_RU').format(_date)),
                  ),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : _pickTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(DateFormat.Hm('ru_RU').format(_date)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.receiptCategory),
                subtitle: Text(category?.name ?? l.categoryOther),
                trailing: const Icon(Icons.chevron_right),
                onTap: _saving
                    ? null
                    : () async {
                        final id = await chooseReceiptCategory(
                          context,
                          categories,
                          shownCategory,
                        );
                        if (id != null && mounted) {
                          setState(() => _category = id);
                        }
                      },
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const ValueKey('receipt-note'),
                controller: _note,
                enabled: !_saving,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l.note,
                  hintText: l.noteHint,
                ),
              ),
              const SizedBox(height: 24),
              Text(l.items, style: Theme.of(context).textTheme.titleLarge),
              for (var index = 0; index < _items.length; index++)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _items[index].name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          '${NumberFormat('0.######', 'ru_RU').format(_items[index].quantity)} × '
                          '${receiptMoney(ref, _items[index].unitPriceMinor)} = '
                          '${receiptMoney(ref, _items[index].sumMinor)}',
                        ),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton.icon(
                              key: ValueKey('edit-item-$index'),
                              onPressed: _saving
                                  ? null
                                  : () => _editItem(index),
                              icon: const Icon(Icons.edit_outlined),
                              label: Text(l.edit),
                            ),
                            TextButton.icon(
                              key: ValueKey('delete-item-$index'),
                              onPressed: _saving
                                  ? null
                                  : () =>
                                        setState(() => _items.removeAt(index)),
                              icon: const Icon(Icons.delete_outline),
                              label: Text(l.deleteItem),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              OutlinedButton.icon(
                onPressed: _saving ? null : () => _editItem(),
                icon: const Icon(Icons.add),
                label: Text(l.addItem),
              ),
              const SizedBox(height: 20),
              Text(
                '${l.total}: ${receiptMoney(ref, total)}',
                key: const ValueKey('edited-total'),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                key: const ValueKey('save-receipt'),
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.check),
                label: Text(_saving ? l.loading : l.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditedItem {
  const _EditedItem(this.item, {required this.rememberCategory});
  final ReceiptItemEdit item;
  final bool rememberCategory;
}

class _ItemEditor extends ConsumerStatefulWidget {
  const _ItemEditor({this.item});
  final ReceiptItemEdit? item;

  @override
  ConsumerState<_ItemEditor> createState() => _ItemEditorState();
}

class _ItemEditorState extends ConsumerState<_ItemEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  late final TextEditingController _sum;
  late final TextEditingController _unit;
  int? _category;
  bool _categoryTouched = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _name = TextEditingController(text: item?.name ?? '');
    _quantity = TextEditingController(text: item?.quantity.toString() ?? '1');
    _price = TextEditingController(
      text: item == null ? '' : Money.decimal(item.unitPriceMinor),
    );
    _sum = TextEditingController(
      text: item == null ? '' : Money.decimal(item.sumMinor),
    );
    _unit = TextEditingController(text: item?.unit ?? '');
    _category = item?.categoryId ?? AppDatabase.otherCategoryId;
  }

  @override
  void dispose() {
    for (final controller in [_name, _quantity, _price, _sum, _unit]) {
      controller.dispose();
    }
    super.dispose();
  }

  String? _moneyError(String? value) {
    try {
      if (Money.parseMinor(value ?? '') >= 0) return null;
    } on FormatException {
      // Do not turn invalid user input into zero.
    }
    return context.l10n.invalidAmount;
  }

  String? _quantityError(String? value) {
    final normalized = (value ?? '').replaceAll(',', '.').trim();
    final number = double.tryParse(normalized);
    return RegExp(r'^\d+(?:\.\d{1,6})?$').hasMatch(normalized) &&
            number != null &&
            number.isFinite &&
            number > 0
        ? null
        : context.l10n.invalidQuantity;
  }

  void _recalculate(String _) {
    if (_quantityError(_quantity.text) != null ||
        _moneyError(_price.text) != null) {
      return;
    }
    final quantity = _quantity.text.trim().replaceAll(',', '.').split('.');
    final decimals = quantity.length == 1 ? '' : quantity[1];
    final numerator = BigInt.parse('${quantity[0]}$decimals');
    final denominator = BigInt.from(10).pow(decimals.length);
    final minor = BigInt.from(Money.parseMinor(_price.text));
    final rounded =
        (minor * numerator + denominator ~/ BigInt.two) ~/ denominator;
    if (rounded > BigInt.parse('9223372036854775807')) return;
    _sum.text = Money.decimal(rounded.toInt());
  }

  /// Suggests a category for a new item from the stored rules until the user
  /// picks one explicitly.
  void _autoCategory(String name) {
    if (widget.item != null || _categoryTouched) return;
    final rules = ref.read(categoryRulesProvider).asData?.value;
    if (rules == null) return;
    final suggested = ref
        .read(categoryRepositoryProvider)
        .categorize(name, rules: rules);
    if (suggested != _category) setState(() => _category = suggested);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final categories = ref.watch(receiptCategoriesProvider).asData?.value ?? [];
    ref.watch(categoryRulesProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.item == null ? l.addItem : l.editItem,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _name,
                key: const ValueKey('item-name'),
                autofocus: widget.item == null,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(labelText: l.itemName),
                onChanged: _autoCategory,
                validator: (value) => value == null || value.trim().isEmpty
                    ? l.requiredField
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantity,
                key: const ValueKey('item-quantity'),
                decoration: InputDecoration(labelText: l.quantity),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _quantityError,
                onChanged: _recalculate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _price,
                key: const ValueKey('item-price'),
                decoration: InputDecoration(labelText: l.unitPrice),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _moneyError,
                onChanged: _recalculate,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sum,
                key: const ValueKey('item-sum'),
                decoration: InputDecoration(labelText: l.itemSum),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _moneyError,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unit,
                decoration: InputDecoration(labelText: l.unit),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: ValueKey('item-category-${categories.length}-$_category'),
                initialValue: categories.any((row) => row.id == _category)
                    ? _category
                    : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.category),
                items: [
                  for (final category in categories)
                    DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    ),
                ],
                onChanged: (value) {
                  _category = value;
                  _categoryTouched = true;
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                key: const ValueKey('save-item'),
                onPressed: () async {
                  if (!_form.currentState!.validate()) return;
                  final sum = Money.parseMinor(_sum.text);
                  final price = Money.parseMinor(_price.text);
                  final quantity = double.parse(
                    _quantity.text.trim().replaceAll(',', '.'),
                  );
                  final changed =
                      sum != widget.item?.sumMinor ||
                      price != widget.item?.unitPriceMinor ||
                      quantity != widget.item?.quantity;
                  var rememberCategory = false;
                  if (_categoryTouched &&
                      _category != null &&
                      _category !=
                          (widget.item?.categoryId ??
                              AppDatabase.otherCategoryId)) {
                    rememberCategory = await offerRememberCategory(
                      context,
                      _name.text.trim(),
                    );
                    if (!context.mounted) return;
                  }
                  Navigator.pop(
                    context,
                    _EditedItem(
                      ReceiptItemEdit(
                        name: _name.text.trim(),
                        rawName: widget.item?.rawName ?? _name.text.trim(),
                        quantity: quantity,
                        unitPriceMinor: price,
                        sumMinor: sum,
                        unit: _unit.text.trim().isEmpty
                            ? null
                            : _unit.text.trim(),
                        categoryId: _category,
                        barcode: widget.item?.barcode,
                        ntin: widget.item?.ntin,
                        discountMinor: changed
                            ? null
                            : widget.item?.discountMinor,
                      ),
                      rememberCategory: rememberCategory,
                    ),
                  );
                },
                child: Text(l.done),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
