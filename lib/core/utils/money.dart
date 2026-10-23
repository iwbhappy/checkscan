/// Decimal conversion without floating point arithmetic on monetary amounts.
abstract final class Money {
  static int parseMinor(Object value) {
    var text = value.toString().trim().replaceAll(
      RegExp(r'[\s\u00a0\u202f]'),
      '',
    );
    text = text.replaceAll(',', '.');
    final match = RegExp(
      r'^([+-]?)(\d+)(?:\.(\d+))?(?:[eE]([+-]?\d+))?$',
    ).firstMatch(text);
    if (match == null) throw FormatException('Некорректная сумма', value);
    final exponent = int.tryParse(match[4] ?? '0');
    if (exponent == null || exponent.abs() > 100) {
      throw FormatException('Слишком большая сумма', value);
    }
    final fraction = match[3] ?? '';
    var amount = BigInt.parse('${match[2]}$fraction');
    final shift = 2 + exponent - fraction.length;
    if (shift >= 0) {
      amount *= BigInt.from(10).pow(shift);
    } else {
      final divisor = BigInt.from(10).pow(-shift);
      if (amount.remainder(divisor) != BigInt.zero) {
        throw FormatException('Сумма точнее одного тиына', value);
      }
      amount ~/= divisor;
    }
    if (match[1] == '-') amount = -amount;
    if (amount < BigInt.parse('-9223372036854775808') ||
        amount > BigInt.parse('9223372036854775807')) {
      throw FormatException('Сумма вне допустимого диапазона', value);
    }
    return amount.toInt();
  }

  static String decimal(int minor) {
    final amount = BigInt.from(minor).abs();
    return '${minor < 0 ? '-' : ''}${amount ~/ BigInt.from(100)}.${(amount % BigInt.from(100)).toString().padLeft(2, '0')}';
  }

  static String format(int minor, {String currency = '₸'}) {
    final parts = decimal(minor).split('.');
    final grouped = parts.first.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    );
    return '$grouped,${parts.last} $currency';
  }
}
