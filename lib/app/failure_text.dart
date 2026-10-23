import 'package:flutter/widgets.dart';
import '../core/errors/app_failure.dart';
import 'l10n.dart';

String failureText(BuildContext context, Object error) {
  final l = context.l10n;
  return switch (error) {
    NetworkFailure() => l.noNetwork,
    TlsFailure() => l.ofdCertificateError,
    TimeoutFailure() => l.ofdTimeout,
    ServerFailure() => l.ofdUnavailable,
    ReceiptNotFoundFailure() => l.receiptNotFound,
    ParseFailure() => l.parseError,
    UnsupportedQrFailure() => l.notReceiptQr,
    QrNotFoundFailure() => l.qrNotFound,
    UnsafeUrlFailure() => l.unsafeRedirect,
    CameraPermissionFailure() => l.cameraPermissionDescription,
    DuplicateReceiptFailure() => l.duplicateTitle,
    _ => l.unexpectedError,
  };
}
