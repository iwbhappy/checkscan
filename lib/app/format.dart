import 'package:intl/intl.dart';
import '../data/db/app_database.dart';

DateTime receiptLocalDate(ReceiptRow receipt) => receipt.dateTimeUtc
    .toUtc()
    .add(Duration(minutes: receipt.tzOffsetMin ?? 0));

DateTime kazakhstanNow() =>
    DateTime.now().toUtc().add(const Duration(hours: 5));

String displayDate(DateTime date) =>
    DateFormat('d MMM y, HH:mm', 'ru_RU').format(date);
