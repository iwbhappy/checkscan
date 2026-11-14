import 'dart:io';
import 'package:flutter/services.dart';

class SharedReceiptBridge {
  SharedReceiptBridge(this.onReceipt);
  final void Function(Map<String, String>) onReceipt;
  static const _channel = MethodChannel('checkscan/incoming');
  bool _disposed = false;

  Future<void> start() async {
    if (!Platform.isAndroid) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'receipt') _deliver(call.arguments);
    });
    try {
      _deliver(await _channel.invokeMethod<Object?>('takeInitial'));
    } on MissingPluginException {
      /* Unit/widget tests have no native receiver. */
    }
  }

  void _deliver(Object? value) {
    if (_disposed || value is! Map) return;
    onReceipt({
      for (final entry in value.entries)
        if (entry.value is String) entry.key.toString(): entry.value as String,
    });
  }

  void dispose() {
    _disposed = true;
    if (Platform.isAndroid) _channel.setMethodCallHandler(null);
  }

  static Future<void> release(String path) async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod<void>('release', {'path': path});
    } on MissingPluginException {
      /* No native receiver in tests. */
    }
  }
}
