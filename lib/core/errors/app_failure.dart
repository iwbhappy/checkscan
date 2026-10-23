sealed class AppFailure implements Exception {
  const AppFailure(this.message, {this.isRetryable = false});

  final String message;
  final bool isRetryable;

  @override
  String toString() => message;
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure()
    : super(
        'Нет сети. Загрузим чек, когда появится интернет.',
        isRetryable: true,
      );
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure()
    : super('ОФД не ответил вовремя. Попробуйте ещё раз.', isRetryable: true);
}

final class TlsFailure extends AppFailure {
  const TlsFailure()
    : super(
        'Не удалось проверить сертификат ОФД. Проверьте дату на устройстве и повторите позже.',
        isRetryable: true,
      );
}

final class ServerFailure extends AppFailure {
  const ServerFailure([this.statusCode])
    : super('ОФД временно недоступен. Попробуйте позже.', isRetryable: true);
  final int? statusCode;
}

final class ReceiptNotFoundFailure extends AppFailure {
  const ReceiptNotFoundFailure()
    : super(
        'ОФД ещё не получил чек, попробуйте через несколько минут.',
        isRetryable: true,
      );
}

final class ParseFailure extends AppFailure {
  const ParseFailure({this.debugRaw})
    : super('Не удалось разобрать ответ ОФД. Данные ссылки сохранены.');
  final String? debugRaw;
}

final class UnsupportedQrFailure extends AppFailure {
  const UnsupportedQrFailure([this.rawValue])
    : super('Это не QR чека поддерживаемого ОФД.');
  final String? rawValue;
}

final class QrNotFoundFailure extends AppFailure {
  const QrNotFoundFailure()
    : super('Не нашли QR чека. Сфотографируйте нижний QR ближе и ровнее.');
}

final class UnsafeUrlFailure extends AppFailure {
  const UnsafeUrlFailure()
    : super('ОФД перенаправил запрос на неподдерживаемый адрес.');
}

final class CameraPermissionFailure extends AppFailure {
  const CameraPermissionFailure()
    : super('Разрешите доступ к камере в настройках телефона.');
}

final class DuplicateReceiptFailure extends AppFailure {
  const DuplicateReceiptFailure(this.receiptId)
    : super('Этот чек уже добавлен.');
  final int receiptId;
}
