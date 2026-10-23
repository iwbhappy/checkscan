/// The original offset is retained independently from the device timezone.
class ReceiptDate {
  const ReceiptDate(this.utc, this.offsetMinutes);
  final DateTime utc;
  final int offsetMinutes;
  DateTime get local => utc.add(Duration(minutes: offsetMinutes));

  factory ReceiptDate.parse(String value, {int defaultOffsetMinutes = 300}) {
    final text = value.trim();
    final printed = RegExp(
      r'^(\d{2})-(\d{2})-(\d{4}) (\d{2}):(\d{2})(?::(\d{2}))?$',
    ).firstMatch(text);
    final compact = RegExp(
      r'^(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})$',
    ).firstMatch(text);
    final iso = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})[T ](\d{2}):(\d{2})(?::(\d{2})(?:\.(\d{1,6}))?)?(Z|[+-]\d{2}:?\d{2})?$',
    ).firstMatch(text);
    final match = printed ?? compact ?? iso;
    if (match == null) throw FormatException('Некорректная дата', value);
    final year = int.parse(printed != null ? match[3]! : match[1]!);
    final month = int.parse(match[2]!);
    final day = int.parse(printed != null ? match[1]! : match[3]!);
    final hour = int.parse(match[4]!);
    final minute = int.parse(match[5]!);
    final second = int.parse(match[6] ?? '0');
    final fraction = iso?[7] ?? '';
    final micros = int.parse(fraction.padRight(6, '0'));
    var offset = defaultOffsetMinutes;
    final zone = iso?[8];
    if (zone == 'Z') {
      offset = 0;
    } else if (zone != null) {
      final digits = zone.substring(1).replaceAll(':', '');
      final hours = int.parse(digits.substring(0, 2));
      final minutes = int.parse(digits.substring(2));
      if (hours > 14 || minutes > 59 || (hours == 14 && minutes != 0)) {
        throw FormatException('Некорректная таймзона', value);
      }
      offset = (hours * 60 + minutes) * (zone.startsWith('-') ? -1 : 1);
    }
    if (offset.abs() > 840 ||
        year < 1 ||
        hour > 23 ||
        minute > 59 ||
        second > 59) {
      throw FormatException('Некорректная дата', value);
    }
    final wall = DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      micros ~/ 1000,
      micros % 1000,
    );
    if (wall.year != year || wall.month != month || wall.day != day) {
      throw FormatException('Несуществующая дата', value);
    }
    return ReceiptDate(wall.subtract(Duration(minutes: offset)), offset);
  }
}
