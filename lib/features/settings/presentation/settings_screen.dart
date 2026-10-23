import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/failure_text.dart';
import '../../../app/l10n.dart';
import '../../../app/preferences.dart';
import '../../../app/providers.dart';
import '../../../data/repositories/backup_repository.dart';
import '../../scan/data/qr_diagnostics.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  Future<void> _action(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) {
        _message(switch (error) {
          InvalidBackupException() ||
          FormatException() => context.l10n.invalidBackup,
          UnsupportedBackupException() => context.l10n.unsupportedBackup,
          _ => failureText(context, error),
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _export(bool json) async {
    final repository = ref.read(backupRepositoryProvider);
    final directory = await (await getTemporaryDirectory()).createTemp(
      'checkscan-export-',
    );
    final files = <XFile>[];
    if (json) {
      final file = File('${directory.path}/checkscan-backup.json');
      await file.writeAsString(await repository.exportJson(), flush: true);
      files.add(XFile(file.path, mimeType: 'application/json'));
    } else {
      final csv = await repository.exportCsv();
      final receipts = File('${directory.path}/checkscan-receipts.csv');
      final items = File('${directory.path}/checkscan-items.csv');
      await receipts.writeAsString(csv.receiptsCsv, flush: true);
      await items.writeAsString(csv.itemsCsv, flush: true);
      files.addAll([
        XFile(receipts.path, mimeType: 'text/csv'),
        XFile(items.path, mimeType: 'text/csv'),
      ]);
    }
    if (!mounted) return;
    final box = context.findRenderObject() as RenderBox?;
    await SharePlus.instance.share(
      ShareParams(
        files: files,
        subject: 'CheckScan',
        sharePositionOrigin: box == null
            ? null
            : box.localToGlobal(Offset.zero) & box.size,
      ),
    );
  }

  Future<void> _import() async {
    final selected = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (selected == null) return;
    final path = selected.path;
    if (path == null) throw const FormatException('Missing local file');
    final file = File(path);
    if (await file.length() > 20 * 1024 * 1024) {
      throw const FormatException('Backup exceeds 20 MB');
    }
    final result = await ref
        .read(backupRepositoryProvider)
        .importJson(await file.readAsString());
    if (mounted) {
      _message(
        context.l10n.importSucceeded(result.imported, result.duplicates),
      );
    }
  }

  Future<bool> _confirm({
    required String title,
    required String message,
    required String action,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(action),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _clear() async {
    final l = context.l10n;
    if (!await _confirm(
          title: l.deleteAllTitle,
          message: l.deleteAllMessage,
          action: l.deleteAllData,
        ) ||
        !mounted) {
      return;
    }
    if (!await _confirm(
          title: l.deleteAllConfirmTitle,
          message: l.deleteAllConfirmMessage,
          action: l.deleteAllConfirm,
        ) ||
        !mounted) {
      return;
    }
    await ref.read(backupRepositoryProvider).clearAllData();
    final temporary = await getTemporaryDirectory();
    final prefix =
        '${temporary.path}${Platform.pathSeparator}checkscan-export-';
    await for (final entry in temporary.list(followLinks: false)) {
      if (entry is Directory && entry.path.startsWith(prefix)) {
        await entry.delete(recursive: true);
      }
    }
    qrDiagnostics.value = const QrDebugSnapshot();
    if (mounted) _message(l.allDataDeleted);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = ref.watch(themeModeProvider);
    final currency = ref.watch(currencySymbolProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        children: [
          if (_busy) const LinearProgressIndicator(),
          Text(l.appearance, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          DropdownButtonFormField<ThemeMode>(
            initialValue: theme,
            isExpanded: true,
            decoration: InputDecoration(labelText: l.theme),
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(l.themeSystem),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text(l.themeLight),
              ),
              DropdownMenuItem(value: ThemeMode.dark, child: Text(l.themeDark)),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(themeModeProvider.notifier).setMode(value);
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: currency,
            decoration: InputDecoration(labelText: l.numberFormat),
            items: const [
              DropdownMenuItem(value: '₸', child: Text('1 234,56 ₸')),
              DropdownMenuItem(value: 'KZT', child: Text('1 234,56 KZT')),
            ],
            onChanged: (value) {
              if (value != null) {
                ref.read(currencySymbolProvider.notifier).setSymbol(value);
              }
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l.currency),
            subtitle: Text(l.currencyKzt),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.category_outlined),
            title: Text(l.categoriesTitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/categories'),
          ),
          const Divider(height: 32),
          Text(l.dataManagement, style: Theme.of(context).textTheme.titleLarge),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.table_view_outlined),
            title: Text(l.exportCsv),
            subtitle: Text(l.exportCsvDescription),
            onTap: _busy ? null : () => _action(() => _export(false)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.save_alt),
            title: Text(l.exportBackup),
            subtitle: Text(l.exportBackupDescription),
            onTap: _busy ? null : () => _action(() => _export(true)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.restore_outlined),
            title: Text(l.importBackup),
            subtitle: Text(l.importBackupDescription),
            onTap: _busy ? null : () => _action(_import),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              Icons.delete_forever_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: Text(l.deleteAllData),
            onTap: _busy ? null : () => _action(_clear),
          ),
          const Divider(height: 32),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline),
            title: Text(l.about),
            subtitle: Text(l.version('1.0.0')),
            onTap: () => showAboutDialog(
              context: context,
              applicationName: 'CheckScan',
              applicationVersion: '1.0.0',
              applicationIcon: Icon(
                Icons.receipt_long,
                color: Theme.of(context).colorScheme.primary,
                size: 48,
              ),
              children: [Text(l.aboutDescription)],
            ),
          ),
          if (kDebugMode)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.bug_report_outlined),
              title: Text(l.debugTitle),
              onTap: () => context.push('/debug'),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(l.localOnly, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
