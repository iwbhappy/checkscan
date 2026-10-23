String russianItemName(String rawName) {
  final parts = rawName.split(RegExp(r'\s+[–—-]\s+'));
  if (parts.length < 2) return rawName;
  final kazakh = RegExp('[әғқңөұүһі]', caseSensitive: false);
  final cyrillic = RegExp('[а-яё]', caseSensitive: false);
  final candidates = parts
      .where((part) => !kazakh.hasMatch(part) && cyrillic.hasMatch(part))
      .toList();
  if (candidates.isEmpty) return rawName;
  // The final all-caps segment is usually the manufacturer. Prefer a product
  // segment (including abbreviated names such as "Бат.snickers").
  return candidates
      .firstWhere(
        (part) => part != part.toUpperCase(),
        orElse: () => candidates.first,
      )
      .trim();
}
