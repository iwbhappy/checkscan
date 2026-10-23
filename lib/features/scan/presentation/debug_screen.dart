import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../app/failure_text.dart';
import '../../../app/l10n.dart';
import '../../../app/providers.dart';
import '../data/qr_diagnostics.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});
  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  final _text = TextEditingController(text: qrDiagnostics.value.rawQr);
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (!kDebugMode || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    recordRawQr(_text.text);
    try {
      final result = await ref.read(receiptRepositoryProvider).scan(_text.text);
      recordOfdDebugResponse(result.receipt.debugRaw);
      if (mounted && result.receipt.status != 'ok') {
        setState(
          () => _error = result.receipt.status == 'pending'
              ? context.l10n.savedOffline
              : context.l10n.parseError,
        );
      }
    } on Object catch (error) {
      if (mounted) setState(() => _error = failureText(context, error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.debugTitle)),
      body: ValueListenableBuilder<QrDebugSnapshot>(
        valueListenable: qrDiagnostics,
        builder: (context, snapshot, child) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            TextField(
              controller: _text,
              minLines: 2,
              maxLines: 5,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l.receiptLink,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _loading ? null : _load,
                  child: Text(l.loadReceipt),
                ),
                TextButton.icon(
                  onPressed: _loading
                      ? null
                      : () async {
                          final data = await Clipboard.getData(
                            Clipboard.kTextPlain,
                          );
                          if (!mounted) return;
                          _text.text = data?.text ?? '';
                        },
                  icon: const Icon(Icons.content_paste),
                  label: Text(l.pasteFromClipboard),
                ),
              ],
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: LinearProgressIndicator(),
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 20),
            Text(l.debugRawQr, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SelectableText(snapshot.rawQr),
            const SizedBox(height: 20),
            Text(
              l.debugDecodedQr,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(snapshot.decodedQr),
            const SizedBox(height: 20),
            Text(
              l.debugResponse,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(snapshot.response),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: snapshot.text));
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l.copied)));
                    }
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(l.debugCopy),
                ),
                Builder(
                  builder: (context) => OutlinedButton.icon(
                    onPressed: () async {
                      final render = context.findRenderObject() as RenderBox?;
                      try {
                        await SharePlus.instance.share(
                          ShareParams(
                            text: snapshot.text,
                            title: l.debugTitle,
                            sharePositionOrigin: render == null
                                ? null
                                : render.localToGlobal(Offset.zero) &
                                      render.size,
                          ),
                        );
                      } on Object {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l.unexpectedError)),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: Text(l.sendToDeveloper),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
