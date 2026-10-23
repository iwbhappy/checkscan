import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final preferencesStorageProvider = Provider<SharedPreferences?>((ref) => null);

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final name = ref.watch(preferencesStorageProvider)?.getString('theme');
    return ThemeMode.values.where((mode) => mode.name == name).firstOrNull ??
        ThemeMode.system;
  }

  void setMode(ThemeMode mode) {
    state = mode;
    final storage = ref.read(preferencesStorageProvider);
    if (storage != null) unawaited(storage.setString('theme', mode.name));
  }
}

final currencySymbolProvider =
    NotifierProvider<CurrencySymbolController, String>(
      CurrencySymbolController.new,
    );

class CurrencySymbolController extends Notifier<String> {
  @override
  String build() =>
      ref.watch(preferencesStorageProvider)?.getString('currencySymbol') ==
          'KZT'
      ? 'KZT'
      : '₸';
  void setSymbol(String value) {
    if (value != '₸' && value != 'KZT') return;
    state = value;
    final storage = ref.read(preferencesStorageProvider);
    if (storage != null) unawaited(storage.setString('currencySymbol', value));
  }
}
