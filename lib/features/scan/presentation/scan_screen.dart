import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;
import 'package:url_launcher/url_launcher.dart';

import '../../../app/l10n.dart';
import '../../../app/failure_text.dart';
import '../../../app/providers.dart';
import '../../../core/errors/app_failure.dart';
import '../../../domain/models/qr_receipt.dart';
import '../data/photo_qr_service.dart';
import '../data/qr_capture.dart';
import '../data/qr_diagnostics.dart';

enum _ScanPhase { ready, photo, loading }

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen>
    with WidgetsBindingObserver {
  final _controller = MobileScannerController(
    autoStart: false,
    formats: [BarcodeFormat.qrCode],
    cameraResolution: const Size(1280, 720),
    autoZoom: true,
  );
  final _picker = ImagePicker();
  bool _busy = false;
  bool _starting = false;
  bool _permissionDenied = false;
  String? _message;
  String? _lastUnknown;
  String? _lastAcceptedDedup;
  _ScanPhase _phase = _ScanPhase.ready;
  AppLifecycleState _lifecycle = AppLifecycleState.resumed;

  bool get _mobile =>
      !kIsWeb &&
      [
        TargetPlatform.android,
        TargetPlatform.iOS,
      ].contains(defaultTargetPlatform);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
  }

  Future<void> _initialize() async {
    if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
      try {
        final lost = await _picker.retrieveLostData();
        final file = lost.files?.firstOrNull;
        if (file != null && mounted) {
          await _session(() => _readPhoto(file.path));
          return;
        }
      } on PlatformException {
        // Camera and manual input remain available if a picker cannot recover.
      }
    }
    await _resumeCamera();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycle = state;
    if (state == AppLifecycleState.resumed) {
      unawaited(_resumeCamera());
    } else {
      unawaited(_stopCamera());
    }
  }

  Future<void> _resumeCamera() async {
    if (!_mobile ||
        !mounted ||
        _busy ||
        _starting ||
        _lifecycle != AppLifecycleState.resumed ||
        !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }
    _starting = true;
    try {
      if (!_controller.value.isRunning) await _controller.start();
      if (_busy || _lifecycle != AppLifecycleState.resumed || !mounted) {
        await _stopCamera();
        return;
      }
      if (mounted) setState(() => _permissionDenied = false);
    } on MobileScannerException catch (error) {
      if (mounted) {
        setState(() {
          _permissionDenied =
              error.errorCode == MobileScannerErrorCode.permissionDenied;
          if (!_permissionDenied) _message = context.l10n.cameraUnavailable;
        });
      }
    } on Object {
      if (mounted) setState(() => _message = context.l10n.cameraUnavailable);
    } finally {
      _starting = false;
    }
  }

  Future<void> _stopCamera() async {
    try {
      if (_controller.value.isRunning) await _controller.stop();
    } on Object {
      // Disposal/background transitions may have already stopped the platform.
    }
  }

  Future<void> _session(Future<void> Function() action) async {
    if (_busy || !mounted) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    await _stopCamera();
    try {
      await action();
    } on UnsupportedQrFailure catch (failure) {
      if (mounted) await _showUnsupported(failure.rawValue ?? '');
    } on AppFailure catch (failure) {
      if (mounted) setState(() => _message = failureText(context, failure));
    } on PlatformException catch (error) {
      if (mounted) {
        setState(
          () => _message = error.code.contains('denied')
              ? context.l10n.cameraPermissionDescription
              : context.l10n.unexpectedError,
        );
      }
    } on Object {
      if (mounted) setState(() => _message = context.l10n.unexpectedError);
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _phase = _ScanPhase.ready;
        });
        await _resumeCamera();
      }
    }
  }

  void _onDetect(BarcodeCapture capture) {
    if (_busy || !mounted) return;
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue case final String raw) recordRawQr(raw);
    }
    final qr = receiptFromCapture(capture);
    if (qr != null) {
      if (qr.dedupKey == _lastAcceptedDedup) return;
      final original = capture.barcodes
          .map((barcode) => barcode.rawValue)
          .whereType<String>()
          .firstWhere(
            (raw) => QrReceipt.tryParse(raw)?.dedupKey == qr.dedupKey,
            orElse: () => qr.sourceUrl,
          );
      unawaited(_session(() => _process(original)));
      return;
    }
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      final uri = raw == null ? null : externalQrUri(raw);
      if (raw != null &&
          uri != null &&
          !isPromotionalUri(uri) &&
          raw != _lastUnknown) {
        _lastUnknown = raw;
        unawaited(_session(() => _process(raw)));
        return;
      }
    }
  }

  Future<void> _process(String raw) async {
    recordRawQr(raw);
    final qr = QrReceipt.tryParse(raw);
    if (qr == null) {
      await _showUnsupported(raw);
      return;
    }
    if (!mounted) return;
    _lastAcceptedDedup = qr.dedupKey;
    setState(() => _phase = _ScanPhase.loading);
    unawaited(HapticFeedback.mediumImpact());
    final result = await ref.read(receiptRepositoryProvider).scan(raw);
    recordOfdDebugResponse(result.receipt.debugRaw);
    if (!mounted) return;
    if (result.duplicate) {
      final open = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.duplicateTitle),
          content: Text(context.l10n.duplicateMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.close),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.openReceipt),
            ),
          ],
        ),
      );
      if (open != true || !mounted) return;
    } else {
      final text = result.receipt.status == 'pending'
          ? context.l10n.savedOffline
          : result.receipt.status == 'error'
          ? context.l10n.parseError
          : context.l10n.receiptSaved;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                result.receipt.status == 'ok'
                    ? Icons.check_circle_outline
                    : Icons.schedule,
                color: Theme.of(context).colorScheme.onInverseSurface,
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
    }
    if (mounted) await context.push('/receipts/${result.receipt.id}');
  }

  Future<void> _showUnsupported(String raw) async {
    final uri = externalQrUri(raw);
    final unknown =
        uri != null && !isPromotionalUri(uri) && !isOofdHost(uri.host);
    final action = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          unknown ? context.l10n.unknownOfdTitle : context.l10n.notReceiptQr,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (unknown) ...[
                Text(context.l10n.unknownOfdMessage(uri.host)),
                const SizedBox(height: 16),
              ],
              SelectableText(raw),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.close),
          ),
          if (unknown)
            TextButton(
              onPressed: () => Navigator.pop(context, 'open'),
              child: Text(context.l10n.openInOfd),
            ),
          FilledButton(
            onPressed: () => Navigator.pop(context, 'manual'),
            child: Text(context.l10n.manualEntry),
          ),
        ],
      ),
    );
    if (action == 'manual' && mounted) {
      await context.push('/receipts/new');
      return;
    }
    if (action == 'open' && uri != null) {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        setState(() => _message = context.l10n.openLinkFailed);
      }
    }
  }

  Future<void> _gallery() => _session(() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 3200,
      maxHeight: 4000,
      requestFullMetadata: false,
    );
    if (photo != null && mounted) await _readPhoto(photo.path);
  });

  Future<void> _readPhoto(String path) async {
    setState(() => _phase = _ScanPhase.photo);
    String? originalRaw;
    final service = PhotoQrService(
      analyze: (path) =>
          _controller.analyzeImage(path, formats: [BarcodeFormat.qrCode]),
      onRawQr: (raw) {
        originalRaw = raw;
        recordRawQr(raw);
      },
    );
    final qr = await service.read(path);
    if (mounted) await _process(originalRaw ?? qr.sourceUrl);
  }

  Future<void> _manual() => _session(() async {
    final value = await showDialog<String>(
      context: context,
      builder: (context) => const ReceiptLinkDialog(),
    );
    if (value != null && value.trim().isNotEmpty && mounted) {
      await _process(value);
    }
  });

  Future<void> _requestPermission() async {
    final status = await permissions.Permission.camera.request();
    if (!mounted) return;
    if (status.isGranted) {
      await _resumeCamera();
    } else {
      setState(() => _permissionDenied = true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_controller.dispose().catchError((Object _) {}));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanTitle),
        actions: [
          if (kDebugMode)
            IconButton(
              tooltip: l10n.debugTitle,
              onPressed: _busy
                  ? null
                  : () => _session(() async {
                      await context.push('/debug');
                    }),
              icon: const Icon(Icons.bug_report_outlined),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  l10n.scanHint,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(l10n.scanDescription),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: SizedBox(
                    height: (MediaQuery.sizeOf(context).height * 0.36).clamp(
                      220.0,
                      330.0,
                    ),
                    child: _mobile
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              MobileScanner(
                                controller: _controller,
                                useAppLifecycleState: false,
                                onDetect: _onDetect,
                                tapToFocus: true,
                                errorBuilder: (context, error) =>
                                    _cameraMessage(
                                      error.errorCode ==
                                          MobileScannerErrorCode
                                              .permissionDenied,
                                    ),
                                placeholderBuilder: (context) => ColoredBox(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                                  child: const Center(
                                    child: Icon(
                                      Icons.qr_code_scanner,
                                      size: 72,
                                    ),
                                  ),
                                ),
                                overlayBuilder: (context, constraints) =>
                                    IgnorePointer(
                                      child: Center(
                                        child: Container(
                                          width: constraints.maxWidth * 0.7,
                                          height: 210,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child:
                                    ValueListenableBuilder<MobileScannerState>(
                                      valueListenable: _controller,
                                      builder: (context, state, child) =>
                                          IconButton.filledTonal(
                                            onPressed:
                                                _busy ||
                                                    !state.isRunning ||
                                                    state.torchState ==
                                                        TorchState.unavailable
                                                ? null
                                                : () =>
                                                      _controller.toggleTorch(),
                                            tooltip:
                                                state.torchState ==
                                                    TorchState.on
                                                ? l10n.flashOff
                                                : l10n.flashOn,
                                            icon: Icon(
                                              state.torchState == TorchState.on
                                                  ? Icons.flash_on
                                                  : Icons.flash_off,
                                            ),
                                          ),
                                    ),
                              ),
                              if (_busy)
                                ColoredBox(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const LinearProgressIndicator(),
                                          const SizedBox(height: 16),
                                          Text(
                                            _phase == _ScanPhase.photo
                                                ? l10n.analyzingPhoto
                                                : _phase == _ScanPhase.loading
                                                ? l10n.loadingReceipt
                                                : l10n.loading,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : _cameraMessage(false),
                  ),
                ),
                if (_permissionDenied)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(l10n.cameraPermissionDescription),
                  ),
                if (_message != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(
                      liveRegion: true,
                      child: Card(
                        color: Theme.of(context).colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            _message!,
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _busy ? null : _gallery,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(l10n.gallery),
                    ),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _manual,
                      icon: const Icon(Icons.link),
                      label: Text(l10n.pasteLink),
                    ),
                    OutlinedButton.icon(
                      key: const ValueKey('manual-entry'),
                      onPressed: _busy
                          ? null
                          : () => context.push('/receipts/new'),
                      icon: const Icon(Icons.edit_note),
                      label: Text(l10n.manualEntry),
                    ),
                  ],
                ),
                if (_lastAcceptedDedup != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: _busy
                          ? null
                          : () => setState(() {
                              _lastAcceptedDedup = null;
                              _lastUnknown = null;
                            }),
                      icon: const Icon(Icons.qr_code_scanner),
                      label: Text(l10n.scanAgain),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  l10n.localOnly,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cameraMessage(bool denied) => ColoredBox(
    color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            denied ? Icons.no_photography_outlined : Icons.qr_code_scanner,
            size: 56,
          ),
          const SizedBox(height: 16),
          Text(
            denied
                ? context.l10n.cameraPermissionTitle
                : context.l10n.cameraUnavailable,
            textAlign: TextAlign.center,
          ),
          if (denied) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _requestPermission,
              child: Text(context.l10n.grantPermission),
            ),
            TextButton(
              onPressed: permissions.openAppSettings,
              child: Text(context.l10n.openAppSettings),
            ),
          ],
        ],
      ),
    ),
  );
}

class ReceiptLinkDialog extends StatefulWidget {
  const ReceiptLinkDialog({super.key});
  @override
  State<ReceiptLinkDialog> createState() => _ReceiptLinkDialogState();
}

class _ReceiptLinkDialogState extends State<ReceiptLinkDialog> {
  final _text = TextEditingController();
  String? _error;
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    if (_text.text.trim().isEmpty) {
      setState(() => _error = context.l10n.requiredField);
      return;
    }
    Navigator.pop(context, _text.text);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(context.l10n.pasteLink),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _text,
            autofocus: true,
            keyboardType: TextInputType.url,
            minLines: 2,
            maxLines: 5,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: context.l10n.receiptLink,
              errorText: _error,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: () async {
              try {
                final data = await Clipboard.getData(Clipboard.kTextPlain);
                if (!mounted) return;
                if (data?.text?.isNotEmpty ?? false) {
                  _text.text = data!.text!;
                  setState(() => _error = null);
                } else {
                  setState(() => _error = context.l10n.emptyClipboard);
                }
              } on PlatformException {
                if (mounted) {
                  setState(() => _error = context.l10n.unexpectedError);
                }
              }
            },
            icon: const Icon(Icons.content_paste),
            label: Text(context.l10n.pasteFromClipboard),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.cancel),
      ),
      FilledButton(onPressed: _submit, child: Text(context.l10n.loadReceipt)),
    ],
  );
}
