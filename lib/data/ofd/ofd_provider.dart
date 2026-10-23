import '../../domain/models/parsed_receipt.dart';

abstract interface class OfdProvider {
  bool canHandle(Uri qrUri);
  Future<ParsedReceipt> fetch(Uri qrUri);
}
