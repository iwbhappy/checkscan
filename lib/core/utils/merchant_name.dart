/// A compact display label; the original legal name is never changed in storage.
String merchantDisplayName(String raw) {
  final normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
  final quoted = RegExp('[«"]([^»"]{2,})[»"]').firstMatch(normalized);
  if (quoted != null) return quoted.group(1)!;
  return normalized.replaceFirst(
    RegExp(r'^(?:ТОО|ИП|АО|ООО)\s+', caseSensitive: false),
    '',
  );
}
