import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru_RU');
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [preferencesStorageProvider.overrideWithValue(preferences)],
      child: const CheckScanApp(),
    ),
  );
}
