class ParsedItem {
  const ParsedItem({
    required this.name,
    required this.rawName,
    required this.quantity,
    required this.unitPriceMinor,
    required this.sumMinor,
    this.barcode,
    this.ntin,
    this.unit,
    this.discountMinor,
  });
  final String name;
  final String rawName;
  final String? barcode;
  final String? ntin;
  final double quantity;
  final String? unit;
  final int unitPriceMinor;
  final int sumMinor;
  final int? discountMinor;

  Map<String, Object?> toJson() => {
    'name': name,
    'rawName': rawName,
    'barcode': barcode,
    'ntin': ntin,
    'quantity': quantity,
    'unit': unit,
    'unitPriceMinor': unitPriceMinor,
    'sumMinor': sumMinor,
    'discountMinor': discountMinor,
  };

  factory ParsedItem.fromJson(Map<String, dynamic> json) => ParsedItem(
    name: json['name'] as String,
    rawName: json['rawName'] as String,
    quantity: (json['quantity'] as num).toDouble(),
    unitPriceMinor: json['unitPriceMinor'] as int,
    sumMinor: json['sumMinor'] as int,
    barcode: json['barcode'] as String?,
    ntin: json['ntin'] as String?,
    unit: json['unit'] as String?,
    discountMinor: json['discountMinor'] as int?,
  );
}

class ParsedReceipt {
  ParsedReceipt({
    required this.sellerName,
    required this.dateTimeUtc,
    required this.totalMinor,
    required List<ParsedItem> items,
    required this.sourceUrl,
    this.tzOffsetMin = 300,
    this.ofdName,
    this.sellerBin,
    this.storeAddress,
    this.kkmRegNumber,
    this.kkmSerial,
    this.fiscalSign,
    this.receiptNumber,
    this.discountMinor,
    this.vatMinor,
    this.vatRate,
    this.paymentType,
    this.currency = 'KZT',
    this.needsReview = false,
    this.debugRaw,
  }) : items = List.unmodifiable(items);
  final String? ofdName;
  final String sellerName;
  final String? sellerBin;
  final String? storeAddress;
  final String? kkmRegNumber;
  final String? kkmSerial;
  final String? fiscalSign;
  final String? receiptNumber;
  final DateTime dateTimeUtc;
  final int? tzOffsetMin;
  final int totalMinor;
  final int? discountMinor;
  final int? vatMinor;
  final double? vatRate;
  final String? paymentType;
  final String currency;
  final List<ParsedItem> items;
  final String sourceUrl;
  final bool needsReview;
  final String? debugRaw;
  DateTime get localDateTime =>
      dateTimeUtc.add(Duration(minutes: tzOffsetMin ?? 0));

  Map<String, Object?> toJson() => {
    'ofdName': ofdName,
    'sellerName': sellerName,
    'sellerBin': sellerBin,
    'storeAddress': storeAddress,
    'kkmRegNumber': kkmRegNumber,
    'kkmSerial': kkmSerial,
    'fiscalSign': fiscalSign,
    'receiptNumber': receiptNumber,
    'dateTimeUtc': dateTimeUtc.toIso8601String(),
    'tzOffsetMin': tzOffsetMin,
    'totalMinor': totalMinor,
    'discountMinor': discountMinor,
    'vatMinor': vatMinor,
    'vatRate': vatRate,
    'paymentType': paymentType,
    'currency': currency,
    'items': items.map((item) => item.toJson()).toList(),
    'sourceUrl': sourceUrl,
    'needsReview': needsReview,
  };

  factory ParsedReceipt.fromJson(Map<String, dynamic> json) => ParsedReceipt(
    sellerName: json['sellerName'] as String,
    dateTimeUtc: DateTime.parse(json['dateTimeUtc'] as String).toUtc(),
    totalMinor: json['totalMinor'] as int,
    items: (json['items'] as List)
        .map(
          (item) => ParsedItem.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    sourceUrl: json['sourceUrl'] as String,
    tzOffsetMin: json['tzOffsetMin'] as int?,
    ofdName: json['ofdName'] as String?,
    sellerBin: json['sellerBin'] as String?,
    storeAddress: json['storeAddress'] as String?,
    kkmRegNumber: json['kkmRegNumber'] as String?,
    kkmSerial: json['kkmSerial'] as String?,
    fiscalSign: json['fiscalSign'] as String?,
    receiptNumber: json['receiptNumber'] as String?,
    discountMinor: json['discountMinor'] as int?,
    vatMinor: json['vatMinor'] as int?,
    vatRate: (json['vatRate'] as num?)?.toDouble(),
    paymentType: json['paymentType'] as String?,
    currency: json['currency'] as String? ?? 'KZT',
    needsReview: json['needsReview'] as bool? ?? false,
  );
}
