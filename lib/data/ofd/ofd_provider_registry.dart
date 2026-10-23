import '../../core/errors/app_failure.dart';
import '../../domain/models/parsed_receipt.dart';
import 'ofd_provider.dart';

class OfdProviderRegistry {
  OfdProviderRegistry(List<OfdProvider> providers)
    : providers = List.unmodifiable(providers);
  final List<OfdProvider> providers;

  OfdProvider? providerFor(Uri uri) {
    for (final provider in providers) {
      if (provider.canHandle(uri)) return provider;
    }
    return null;
  }

  Future<ParsedReceipt> fetch(Uri uri) {
    final provider = providerFor(uri);
    if (provider == null) throw UnsupportedQrFailure(uri.toString());
    return provider.fetch(uri);
  }
}
