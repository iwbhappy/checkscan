import '../../core/errors/app_failure.dart';
import '../../core/utils/money.dart';
import '../../core/utils/receipt_date.dart';

bool isOofdHost(String host) {
  final normalized = host.toLowerCase();
  return normalized == 'oofd.kz' || normalized.endsWith('.oofd.kz');
}

bool isSafeOfdUri(Uri uri) =>
    (uri.scheme == 'http' || uri.scheme == 'https') &&
    uri.userInfo.isEmpty &&
    !uri.hasFragment &&
    isOofdHost(uri.host) &&
    (!uri.hasPort || uri.port == (uri.scheme == 'https' ? 443 : 80));

String normalizeQrText(String raw) =>
    raw.trim().replaceAll(RegExp('&amp;', caseSensitive: false), '&');

String normalizedKkmNumber(String number) =>
    number.replaceFirst(RegExp(r'^0+(?=\d)'), '');

String receiptDedupKey(
  String fiscalSign,
  String kkmRegNumber,
  int totalMinor,
) => '$fiscalSign|${normalizedKkmNumber(kkmRegNumber)}|$totalMinor';

class QrReceipt {
  const QrReceipt._({
    required this.uri,
    required this.fiscalSign,
    required this.kkmRegNumber,
    required this.totalMinor,
    required this.dateTimeUtc,
    required this.tzOffsetMin,
  });
  final Uri uri;
  final String fiscalSign;
  final String kkmRegNumber;
  final int totalMinor;
  final DateTime dateTimeUtc;

  /// QR time has no confirmed timezone. Keep it as a UTC-shaped wall clock
  /// until the OFD returns its receipt time; null means the offset is unknown.
  final int? tzOffsetMin;
  String get sourceUrl => uri.toString();
  String get dedupKey => receiptDedupKey(fiscalSign, kkmRegNumber, totalMinor);
  DateTime get localDateTime =>
      dateTimeUtc.add(Duration(minutes: tzOffsetMin ?? 0));

  factory QrReceipt.parse(String raw) {
    try {
      final uri = Uri.parse(normalizeQrText(raw));
      if (!isSafeOfdUri(uri)) throw const FormatException();
      final params = uri.queryParametersAll;
      for (final key in ['i', 'f', 's', 't']) {
        if (params[key]?.length != 1 || params[key]!.single.isEmpty) {
          throw const FormatException();
        }
      }
      final fiscalSign = params['i']!.single;
      final kkm = params['f']!.single;
      if (!RegExp(r'^\d+$').hasMatch(fiscalSign) ||
          !RegExp(r'^\d+$').hasMatch(kkm)) {
        throw const FormatException();
      }
      final total = Money.parseMinor(params['s']!.single);
      if (total < 0) throw const FormatException();
      if (!RegExp(r'^\d{8}T\d{6}$').hasMatch(params['t']!.single)) {
        throw const FormatException();
      }
      final date = ReceiptDate.parse(
        params['t']!.single,
        defaultOffsetMinutes: 0,
      );
      return QrReceipt._(
        uri: uri,
        fiscalSign: fiscalSign,
        kkmRegNumber: kkm,
        totalMinor: total,
        dateTimeUtc: date.utc,
        tzOffsetMin: null,
      );
    } on FormatException {
      throw UnsupportedQrFailure(raw);
    }
  }

  static QrReceipt? tryParse(String raw) {
    try {
      return QrReceipt.parse(raw);
    } on AppFailure {
      return null;
    }
  }
}
