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
import 'receipt_providers.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({
    this.categoryId,
    this.storeId,
    this.from,
    this.until,
    super.key,
  });

  final int? categoryId;
  final int? storeId;
  final DateTime? from;
  final DateTime? until;

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _search = TextEditingController();
  late ReceiptFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = _initialFilter();
  }

  ReceiptFilter _initialFilter() => ReceiptFilter(
    categoryId: widget.categoryId,
    storeId: widget.storeId,
    from: widget.from,
    until: widget.until,
    search: _search.text,
  );

  @override
  void didUpdateWidget(HistoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categoryId != widget.categoryId ||
        oldWidget.storeId != widget.storeId ||
        oldWidget.from != widget.from ||
        oldWidget.until != widget.until) {
      _filter = _initialFilter();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _searchChanged(String value) => setState(() {
    _filter = ReceiptFilter(
      search: value,
      categoryId: _filter.categoryId,
      storeId: _filter.storeId,
      from: _filter.from,
      until: _filter.until,
      minMinor: _filter.minMinor,
      maxMinor: _filter.maxMinor,
    );
  });

  Future<void> _refresh() async {
    try {
      await ref.read(receiptRepositoryProvider).retryPending(force: true);
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(failureText(context, error))));

  Future<void> _delete(int id) async {
    final repository = ref.read(receiptRepositoryProvider);
    try {
      final snapshot = await repository.deleteWithUndo(id);
      if (!mounted || snapshot == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.receiptDeleted),
          action: SnackBarAction(
            label: context.l10n.undo,
            onPressed: () async {
              try {
                await repository.restore(snapshot);
              } catch (error) {
                if (mounted) _showError(error);
              }
            },
          ),
        ),
      );
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _filters() async {
    final filter = await showModalBottomSheet<ReceiptFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _HistoryFilters(filter: _filter),
    );
    if (filter != null && mounted) setState(() => _filter = filter);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final history = ref.watch(receiptHistoryProvider(_filter));
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'manual-entry',
        onPressed: () => context.push('/receipts/new'),
        icon: const Icon(Icons.add),
        label: Text(l.manualEntry),
      ),
      appBar: AppBar(
        title: Text(l.historyTitle),
        actions: [
          IconButton(
            tooltip: l.filters,
            onPressed: _filters,
            icon: const Icon(Icons.tune),
          ),
          IconButton(
            tooltip: l.retryPending,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _search,
                onChanged: _searchChanged,
                decoration: InputDecoration(
                  hintText: l.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: l.clearSearch,
                          onPressed: () {
                            _search.clear();
                            _searchChanged('');
                          },
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
            ),
            Expanded(
              child: history.when(
                loading: () => const LoadingSkeleton(),
                error: (error, _) => EmptyState(
                  title: failureText(context, error),
                  action: FilledButton(
                    onPressed: () => ref.invalidate(receiptHistoryProvider),
                    child: Text(l.retry),
                  ),
                ),
                data: (rows) => RefreshIndicator(
                  onRefresh: _refresh,
                  child: rows.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: 350,
                              child: EmptyState(
                                title: _hasFilter
                                    ? l.noSearchResults
                                    : l.emptyHistoryTitle,
                                description: _hasFilter
                                    ? l.noSearchResultsDescription
                                    : l.emptyHistoryDescription,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                          itemCount: rows.length,
                          itemBuilder: (context, index) {
                            final entry = rows[index];
                            final date = receiptLocalDate(entry.receipt);
                            final previous = index == 0
                                ? null
                                : receiptLocalDate(rows[index - 1].receipt);
                            final showDay =
                                previous == null ||
                                !DateUtils.isSameDay(date, previous);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                if (showDay)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      _dayTitle(date),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                Dismissible(
                                  key: ValueKey(entry.receipt.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.all(24),
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.errorContainer,
                                    child: const Icon(Icons.delete_outline),
                                  ),
                                  confirmDismiss: (_) async {
                                    await _delete(entry.receipt.id);
                                    // The database stream removes the card.
                                    return false;
                                  },
                                  child: _ReceiptCard(
                                    entry: entry,
                                    onOpen: () => context.push(
                                      '/receipts/${entry.receipt.id}',
                                    ),
                                    onDelete: () => _delete(entry.receipt.id),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasFilter =>
      _filter.search.isNotEmpty ||
      _filter.from != null ||
      _filter.until != null ||
      _filter.categoryId != null ||
      _filter.storeId != null ||
      _filter.minMinor != null ||
      _filter.maxMinor != null;

  String _dayTitle(DateTime date) {
    final now = kazakhstanNow();
    if (DateUtils.isSameDay(date, now)) return context.l10n.today;
    if (DateUtils.isSameDay(date, now.subtract(const Duration(days: 1)))) {
      return context.l10n.yesterday;
    }
    return DateFormat('d MMMM y', 'ru_RU').format(date);
  }
}

class _ReceiptCard extends ConsumerWidget {
  const _ReceiptCard({
    required this.entry,
    required this.onOpen,
    required this.onDelete,
  });
  final ReceiptListData entry;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final receipt = entry.receipt;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      entry.storeName ?? l.unknownStore,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    tooltip: l.delete,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
              Text(
                receiptMoney(ref, receipt.totalMinor),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                '${DateFormat.Hm('ru_RU').format(receiptLocalDate(receipt))} · '
                '${l.itemsCount(entry.itemCount)}',
              ),
              if (receipt.status != 'ok' ||
                  receipt.needsReview ||
                  receipt.edited)
                Wrap(
                  spacing: 8,
                  children: [
                    if (receipt.status != 'ok')
                      Chip(
                        label: Text(
                          receipt.status == 'pending'
                              ? l.pending
                              : l.errorStatus,
                        ),
                      ),
                    if (receipt.needsReview) Chip(label: Text(l.needsReview)),
                    if (receipt.edited) Chip(label: Text(l.edited)),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryFilters extends ConsumerStatefulWidget {
  const _HistoryFilters({required this.filter});
  final ReceiptFilter filter;

  @override
  ConsumerState<_HistoryFilters> createState() => _HistoryFiltersState();
}

class _HistoryFiltersState extends ConsumerState<_HistoryFilters> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _min;
  late final TextEditingController _max;
  late int? _store;
  late int? _category;
  DateTime? _from;
  DateTime? _until;
  var _period = 'all';

  @override
  void initState() {
    super.initState();
    final filter = widget.filter;
    _store = filter.storeId;
    _category = filter.categoryId;
    _from = filter.from == null
        ? null
        : DateTime.utc(filter.from!.year, filter.from!.month, filter.from!.day);
    _until = filter.until == null
        ? null
        : DateTime.utc(
            filter.until!.year,
            filter.until!.month,
            filter.until!.day,
          );
    _period = _from != null || _until != null ? 'custom' : 'all';
    _min = TextEditingController(
      text: filter.minMinor == null ? '' : Money.decimal(filter.minMinor!),
    );
    _max = TextEditingController(
      text: filter.maxMinor == null ? '' : Money.decimal(filter.maxMinor!),
    );
  }

  @override
  void dispose() {
    _min.dispose();
    _max.dispose();
    super.dispose();
  }

  Future<void> _choosePeriod(String? value) async {
    if (value == null) return;
    final now = kazakhstanNow();
    final today = DateTime.utc(now.year, now.month, now.day);
    DateTime? from;
    DateTime? until;
    if (value == 'custom') {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2000),
        lastDate: DateTime(now.year + 10),
        initialDateRange: _from == null || _until == null
            ? null
            : DateTimeRange(
                start: _from!,
                end: _until!.subtract(const Duration(days: 1)),
              ),
      );
      if (range == null || !mounted) return;
      from = DateTime.utc(range.start.year, range.start.month, range.start.day);
      until = DateTime.utc(range.end.year, range.end.month, range.end.day + 1);
    } else if (value == 'day') {
      from = today;
      until = today.add(const Duration(days: 1));
    } else if (value == 'week') {
      from = today.subtract(Duration(days: today.weekday - 1));
      until = from.add(const Duration(days: 7));
    } else if (value == 'month') {
      from = DateTime.utc(now.year, now.month);
      until = DateTime.utc(now.year, now.month + 1);
    }
    setState(() {
      _period = value;
      _from = from;
      _until = until;
    });
  }

  String? _amountError(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    try {
      if (Money.parseMinor(value) >= 0) return null;
    } on FormatException {
      // The form keeps the user's input until it can be corrected.
    }
    return context.l10n.invalidAmount;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final categories = ref.watch(receiptCategoriesProvider).asData?.value ?? [];
    final stores = ref.watch(receiptStoresProvider).asData?.value ?? [];
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.filters, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                initialValue: _period,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.period),
                items: [
                  for (final option in [
                    ('all', l.allTime),
                    ('day', l.day),
                    ('week', l.week),
                    ('month', l.month),
                    ('custom', l.customPeriod),
                  ])
                    DropdownMenuItem(value: option.$1, child: Text(option.$2)),
                ],
                onChanged: _choosePeriod,
              ),
              if (_from != null && _until != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${DateFormat.yMd('ru_RU').format(_from!)} — '
                    '${DateFormat.yMd('ru_RU').format(_until!.subtract(const Duration(days: 1)))}',
                  ),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                key: ValueKey('store-$_store-${stores.length}'),
                initialValue: stores.any((row) => row.id == _store)
                    ? _store
                    : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.store),
                items: [
                  DropdownMenuItem(child: Text(l.allStores)),
                  for (final row in stores)
                    DropdownMenuItem(
                      value: row.id,
                      child: Text(
                        row.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _store = value),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                key: ValueKey('category-$_category-${categories.length}'),
                initialValue: categories.any((row) => row.id == _category)
                    ? _category
                    : null,
                isExpanded: true,
                decoration: InputDecoration(labelText: l.category),
                items: [
                  DropdownMenuItem(child: Text(l.allCategories)),
                  for (final row in categories)
                    DropdownMenuItem(value: row.id, child: Text(row.name)),
                ],
                onChanged: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _min,
                decoration: InputDecoration(labelText: l.amountFrom),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: _amountError,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _max,
                decoration: InputDecoration(labelText: l.amountTo),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) {
                  final error = _amountError(value);
                  if (error != null) return error;
                  if (_min.text.trim().isNotEmpty &&
                      _max.text.trim().isNotEmpty &&
                      _amountError(_min.text) == null &&
                      Money.parseMinor(_max.text) <
                          Money.parseMinor(_min.text)) {
                    return l.invalidAmount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () {
                  if (!_form.currentState!.validate()) return;
                  Navigator.pop(
                    context,
                    ReceiptFilter(
                      search: widget.filter.search,
                      from: _from,
                      until: _until,
                      storeId: _store,
                      categoryId: _category,
                      minMinor: _min.text.trim().isEmpty
                          ? null
                          : Money.parseMinor(_min.text),
                      maxMinor: _max.text.trim().isEmpty
                          ? null
                          : Money.parseMinor(_max.text),
                    ),
                  );
                },
                child: Text(l.apply),
              ),
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  ReceiptFilter(search: widget.filter.search),
                ),
                child: Text(l.reset),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
