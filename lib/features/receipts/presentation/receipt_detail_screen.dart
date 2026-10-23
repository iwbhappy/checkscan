import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/failure_text.dart';
import '../../../app/format.dart';
import '../../../app/l10n.dart';
import '../../../app/providers.dart';
import '../../../app/widgets.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/receipt_repository.dart';
import '../../../domain/models/qr_receipt.dart';
import 'receipt_editor.dart';
import 'receipt_providers.dart';

class ReceiptDetailScreen extends ConsumerStatefulWidget {
  const ReceiptDetailScreen({required this.id, super.key});
  final int id;

  @override
  ConsumerState<ReceiptDetailScreen> createState() =>
      _ReceiptDetailScreenState();
}

class _ReceiptDetailScreenState extends ConsumerState<ReceiptDetailScreen> {
  bool _busy = false;

  void _error(Object error) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(failureText(context, error))));

  Future<void> _retry() async {
    setState(() => _busy = true);
    try {
      await ref.read(receiptRepositoryProvider).retry(widget.id);
    } catch (error) {
      if (mounted) _error(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openSource(String source) async {
    try {
      final uri = Uri.tryParse(source);
      if (uri == null ||
          !isSafeOfdUri(uri) ||
          !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(context.l10n.openLinkFailed)));
        }
      }
    } catch (error) {
      if (mounted) _error(error);
    }
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.deleteReceiptTitle),
        content: Text(l.deleteReceiptMessage),
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
    if (confirmed != true || !mounted) return;
    final repository = ref.read(receiptRepositoryProvider);
    try {
      final snapshot = await repository.deleteWithUndo(widget.id);
      if (!mounted || snapshot == null) return;
      final messenger = ScaffoldMessenger.of(context);
      context.go('/history');
      messenger.showSnackBar(
        SnackBar(
          content: Text(l.receiptDeleted),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () async {
              try {
                await repository.restore(snapshot);
              } catch (_) {
                messenger.showSnackBar(
                  SnackBar(content: Text(l.unexpectedError)),
                );
              }
            },
          ),
        ),
      );
    } catch (error) {
      if (mounted) _error(error);
    }
  }

  Future<void> _edit(ReceiptDetailData detail) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => ReceiptEditor(detail: detail)),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.changesSaved)));
    }
  }

  Future<void> _changeCategory(
    ReceiptDetailData detail,
    List<CategoryRow> categories,
    int index,
  ) async {
    final chosen = await chooseReceiptCategory(
      context,
      categories,
      detail.items[index].categoryId,
    );
    if (chosen == null || !mounted || _busy) return;
    setState(() => _busy = true);
    try {
      await ref
          .read(receiptRepositoryProvider)
          .saveEdits(
            detail.receipt.id,
            storeName: detail.store?.name ?? context.l10n.unknownStore,
            dateTimeUtc: detail.receipt.dateTimeUtc,
            tzOffsetMin: detail.receipt.tzOffsetMin,
            note: detail.receipt.note,
            categoryId: detail.receipt.categoryId,
            items: [
              for (var i = 0; i < detail.items.length; i++)
                i == index
                    ? itemWithCategory(detail.items[i], chosen)
                    : ReceiptItemEdit.fromRow(detail.items[i]),
            ],
          );
      if (mounted &&
          await offerRememberCategory(context, detail.items[index].name)) {
        await ref
            .read(categoryRepositoryProvider)
            .rememberItem(
              name: detail.items[index].name,
              barcode: detail.items[index].barcode,
              categoryId: chosen,
            );
      }
    } catch (error) {
      if (mounted) _error(error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final data = ref.watch(receiptDetailProvider(widget.id));
    final categories = ref.watch(receiptCategoriesProvider).asData?.value ?? [];
    final detail = data.asData?.value;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.receiptTitle),
        actions: [
          if (detail?.receipt.status == 'ok')
            IconButton(
              tooltip: l.editReceipt,
              onPressed: _busy ? null : () => _edit(detail!),
              icon: const Icon(Icons.edit_outlined),
            ),
          if (detail != null)
            IconButton(
              tooltip: l.delete,
              onPressed: _busy ? null : _delete,
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: SafeArea(
        child: data.when(
          loading: () => const LoadingSkeleton(),
          error: (error, _) => EmptyState(title: failureText(context, error)),
          data: (detail) {
            if (detail == null) return EmptyState(title: l.receiptMissing);
            final receipt = detail.receipt;
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  detail.store?.name ?? l.unknownStore,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                if (detail.store?.address != null) ...[
                  const SizedBox(height: 8),
                  Text(detail.store!.address!),
                ],
                const SizedBox(height: 8),
                Text(displayDate(receiptLocalDate(receipt))),
                const SizedBox(height: 20),
                Text(l.total, style: Theme.of(context).textTheme.labelLarge),
                Text(
                  receiptMoney(ref, receipt.totalMinor),
                  key: const ValueKey('receipt-total'),
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 12),
                if (receipt.status != 'ok')
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            receipt.status == 'pending'
                                ? l.pending
                                : l.errorStatus,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(receipt.lastError ?? l.savedOffline),
                          const SizedBox(height: 8),
                          Text(l.pendingEditHint),
                          const SizedBox(height: 12),
                          FilledButton.icon(
                            onPressed: _busy ? null : _retry,
                            icon: const Icon(Icons.refresh),
                            label: Text(_busy ? l.loadingReceipt : l.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (receipt.needsReview)
                  Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l.sumMismatch),
                    ),
                  ),
                if (receipt.isManual)
                  Chip(label: Text(l.addedManually))
                else if (receipt.edited)
                  Chip(label: Text(l.edited)),
                if (receipt.discountMinor != null)
                  _ReceiptField(
                    label: l.discount,
                    value: receiptMoney(ref, receipt.discountMinor!),
                  ),
                if (receipt.vatMinor != null)
                  _ReceiptField(
                    label: receipt.vatRate == null
                        ? l.vat
                        : '${l.vat} ${NumberFormat('0.##', 'ru_RU').format(receipt.vatRate)}%',
                    value: receiptMoney(ref, receipt.vatMinor!),
                  ),
                if (receipt.paymentType != null)
                  _ReceiptField(
                    label: l.paymentType,
                    value: switch (receipt.paymentType) {
                      'cash' => l.paymentCash,
                      'card' => l.paymentCard,
                      'mixed' => l.paymentMixed,
                      _ => receipt.paymentType!,
                    },
                  ),
                const SizedBox(height: 20),
                Text(
                  l.itemsCount(detail.items.length),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (detail.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(l.noItems),
                  ),
                for (var i = 0; i < detail.items.length; i++)
                  _ItemCard(
                    item: detail.items[i],
                    category: categories
                        .where((row) => row.id == detail.items[i].categoryId)
                        .firstOrNull,
                    onCategory: _busy || receipt.status != 'ok'
                        ? null
                        : () => _changeCategory(detail, categories, i),
                  ),
                if (receipt.note?.isNotEmpty == true) ...[
                  const SizedBox(height: 20),
                  _ReceiptField(label: l.note, value: receipt.note!),
                ],
                if (!receipt.isManual) ...[
                  const SizedBox(height: 20),
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: Text(l.ofd),
                    children: [
                      if (receipt.ofdName != null)
                        _ReceiptField(label: l.ofd, value: receipt.ofdName!),
                      if (detail.store?.bin != null)
                        _ReceiptField(
                          label: l.sellerBin,
                          value: detail.store!.bin!,
                        ),
                      if (receipt.kkmRegNumber != null)
                        _ReceiptField(
                          label: l.kkmRegNumber,
                          value: receipt.kkmRegNumber!,
                        ),
                      if (receipt.kkmSerial != null)
                        _ReceiptField(
                          label: l.kkmSerial,
                          value: receipt.kkmSerial!,
                        ),
                      if (receipt.fiscalSign != null)
                        _ReceiptField(
                          label: l.fiscalSign,
                          value: receipt.fiscalSign!,
                        ),
                      if (receipt.receiptNumber != null)
                        _ReceiptField(
                          label: l.receiptNumber,
                          value: receipt.receiptNumber!,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _openSource(receipt.sourceUrl),
                    icon: const Icon(Icons.open_in_new),
                    label: Text(l.openInOfd),
                  ),
                ],
                if (kDebugMode && receipt.debugRaw != null)
                  TextButton.icon(
                    onPressed: () async {
                      try {
                        await SharePlus.instance.share(
                          ShareParams(
                            text: receipt.debugRaw,
                            subject: l.debugResponse,
                          ),
                        );
                      } catch (error) {
                        if (mounted) _error(error);
                      }
                    },
                    icon: const Icon(Icons.bug_report_outlined),
                    label: Text(l.sendToDeveloper),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReceiptField extends StatelessWidget {
  const _ReceiptField({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        SelectableText(value),
      ],
    ),
  );
}

class _ItemCard extends ConsumerWidget {
  const _ItemCard({
    required this.item,
    required this.category,
    this.onCategory,
  });
  final ReceiptItemRow item;
  final CategoryRow? category;
  final VoidCallback? onCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${NumberFormat('0.######', 'ru_RU').format(item.quantity)} '
              '${item.unit ?? ''} × ${receiptMoney(ref, item.unitPriceMinor)}',
            ),
            Text(
              receiptMoney(ref, item.sumMinor),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ActionChip(
              onPressed: onCategory,
              avatar: Icon(
                categoryIcons[category?.icon] ?? Icons.category_outlined,
                size: 18,
              ),
              label: Text(category?.name ?? l.categoryOther),
            ),
          ],
        ),
      ),
    );
  }
}
