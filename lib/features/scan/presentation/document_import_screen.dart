import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../app/failure_text.dart';
import '../../../app/motion.dart';
import '../../../app/providers.dart';
import '../../../app/widgets.dart';
import '../data/document_import_service.dart';
import '../data/shared_receipt_bridge.dart';
import 'dart:async';

class DocumentImportScreen extends ConsumerStatefulWidget {
  const DocumentImportScreen({required this.path, super.key});
  final String path;
  @override
  ConsumerState<DocumentImportScreen> createState() =>
      _DocumentImportScreenState();
}

class _DocumentImportScreenState extends ConsumerState<DocumentImportScreen> {
  late final MobileScannerController _scanner;
  bool _cancelled = false;
  bool _busy = false;
  String _phase = 'Подготавливаем документ';
  String? _error;
  DocumentImportResult? _result;
  int _page = 1;
  ImportActivity? _activity;

  @override
  void initState() {
    super.initState();
    _scanner = ref.read(scannerControllerProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _activity = ref.read(importActivityProvider.notifier);
      _activity!.begin();
      _read();
    });
  }

  Future<void> _read() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _result = null;
    });
    try {
      final result =
          await DocumentImportService(
            analyze: (path) =>
                _scanner.analyzeImage(path, formats: [BarcodeFormat.qrCode]),
          ).read(
            widget.path,
            pageNumber: _page,
            isCancelled: () => _cancelled,
            onProgress: (phase) {
              if (mounted) setState(() => _phase = phase);
            },
          );
      if (!mounted || _cancelled) return;
      if (result.qr != null && result.pageCount == 1) {
        await _openQr(result);
      } else {
        setState(() => _result = result);
      }
    } on ImportCancelled {
      /* Leaving the screen discards the draft. */
    } on Object catch (error) {
      if (mounted && !_cancelled) {
        setState(
          () => _error = error is FormatException
              ? error.message.toString()
              : error is FileSystemException && error.osError?.errorCode == 28
              ? 'Недостаточно свободного места для обработки чека. Освободите память и повторите импорт.'
              : failureText(context, error),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openQr(DocumentImportResult result) async {
    setState(() => _phase = 'Загружаем данные чека');
    final saved = await ref
        .read(receiptRepositoryProvider)
        .scan(result.qr!.sourceUrl);
    if (mounted && !_cancelled) {
      context.pushReplacement('/receipts/${saved.receipt.id}');
    }
  }

  @override
  void dispose() {
    _cancelled = true;
    final activity = _activity;
    if (activity != null) scheduleMicrotask(activity.end);
    unawaited(SharedReceiptBridge.release(widget.path));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final draft = _result?.draft;
    return Scaffold(
      appBar: AppBar(title: const Text('Импорт чека')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_busy) ...[
              const SizedBox(height: 50),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 24),
              Semantics(
                liveRegion: true,
                child: AnimatedSwitcher(
                  duration: motionDuration(context),
                  child: Text(
                    _phase,
                    key: ValueKey(_phase),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Обработка выполняется на устройстве. Фото и текст не отправляются в облако.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  _cancelled = true;
                  context.pop();
                },
                child: const Text('Отмена'),
              ),
            ] else if (_error != null) ...[
              EmptyState(title: _error!, icon: Icons.document_scanner_outlined),
              FilledButton.icon(
                onPressed: _read,
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
              TextButton(
                onPressed: () => context.pushReplacement('/receipts/new'),
                child: const Text('Ввести вручную'),
              ),
            ] else if (_result != null) ...[
              if (_result!.pageCount > 1) ...[
                DropdownButtonFormField<int>(
                  initialValue: _page,
                  decoration: const InputDecoration(labelText: 'Страница PDF'),
                  items: [
                    for (var page = 1; page <= _result!.pageCount; page++)
                      DropdownMenuItem(
                        value: page,
                        child: Text('$page из ${_result!.pageCount}'),
                      ),
                  ],
                  onChanged: (page) {
                    if (page != null) {
                      _page = page;
                      _read();
                    }
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Одна страница — один чек. Выберите страницу перед сохранением.',
                ),
              ],
              const SizedBox(height: 16),
              if (_result!.preview != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.memory(
                    _result!.preview!,
                    height: 240,
                    fit: BoxFit.contain,
                  ),
                )
              else if (!widget.path.toLowerCase().endsWith('.pdf'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(widget.path),
                    height: 240,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.receipt_long_outlined, size: 80),
                  ),
                ),
              const SizedBox(height: 20),
              Card(
                color: scheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _result!.qr != null
                            ? 'QR чека найден'
                            : 'Проверьте распознанные данные',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result!.qr != null
                            ? 'Можно загрузить данные из ОФД.'
                            : 'Магазин, дата, сумма и товары могут содержать ошибки. Ничего не сохранено до вашего подтверждения.',
                      ),
                    ],
                  ),
                ),
              ),
              if (draft != null) ...[
                if (draft.possibleReturn)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Похоже на возврат. Проверьте тип операции на следующем экране.',
                    ),
                  ),
                ExpansionTile(
                  title: const Text('Исходный текст'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(draft.rawText),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async {
                  if (_result!.qr != null) {
                    setState(() => _busy = true);
                    try {
                      await _openQr(_result!);
                    } catch (error) {
                      if (mounted) {
                        setState(() => _error = failureText(context, error));
                      }
                    } finally {
                      if (mounted) setState(() => _busy = false);
                    }
                  } else {
                    context.pushReplacement('/receipts/new', extra: draft);
                  }
                },
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(
                  _result!.qr != null
                      ? 'Загрузить чек'
                      : 'Проверить и сохранить',
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Если позиции не определились, можно сохранить только общую сумму.',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
