import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/scan/presentation/scan_screen.dart';
import '../features/scan/presentation/debug_screen.dart';
import '../features/receipts/presentation/history_screen.dart';
import '../features/receipts/presentation/receipt_detail_screen.dart';
import '../features/receipts/presentation/receipt_editor.dart';
import '../features/stats/presentation/stats_screen.dart';
import '../features/categories/presentation/categories_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import 'l10n.dart';
import 'preferences.dart';
import 'providers.dart';
export 'preferences.dart' show themeModeProvider;

final backgroundWorkProvider = Provider<bool>((ref) => true);

GoRouter createRouter({String initialLocation = '/scan'}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(path: '/', redirect: (_, _) => '/scan'),
    ShellRoute(
      builder: (context, state, child) =>
          _AppShell(location: state.uri.path, child: child),
      routes: [
        GoRoute(path: '/scan', builder: (_, _) => const ScanScreen()),
        GoRoute(
          path: '/history',
          builder: (_, state) => HistoryScreen(
            categoryId: int.tryParse(
              state.uri.queryParameters['category'] ?? '',
            ),
            storeId: int.tryParse(state.uri.queryParameters['store'] ?? ''),
            from: DateTime.tryParse(state.uri.queryParameters['from'] ?? ''),
            until: DateTime.tryParse(state.uri.queryParameters['until'] ?? ''),
          ),
        ),
        GoRoute(path: '/stats', builder: (_, _) => const StatsScreen()),
        GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      ],
    ),
    GoRoute(path: '/receipts/new', builder: (_, _) => const ReceiptEditor()),
    GoRoute(
      path: '/receipts/:id',
      builder: (_, state) => ReceiptDetailScreen(
        id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
      ),
    ),
    GoRoute(path: '/categories', builder: (_, _) => const CategoriesScreen()),
    if (kDebugMode)
      GoRoute(path: '/debug', builder: (_, _) => const DebugScreen()),
  ],
);

final routerProvider = Provider<GoRouter>((ref) {
  final router = createRouter();
  ref.onDispose(router.dispose);
  return router;
});

class CheckScanApp extends ConsumerStatefulWidget {
  const CheckScanApp({super.key});
  @override
  ConsumerState<CheckScanApp> createState() => _CheckScanAppState();
}

class _CheckScanAppState extends ConsumerState<CheckScanApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (ref.read(backgroundWorkProvider)) {
      ref.read(receiptRepositoryProvider).start();
      unawaited(
        ref
            .read(categoryRepositoryProvider)
            .initialize()
            .catchError((Object _, StackTrace _) {}),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!ref.read(backgroundWorkProvider)) return;
    final repository = ref.read(receiptRepositoryProvider);
    if (state == AppLifecycleState.resumed) {
      repository.start();
    } else {
      repository.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => context.l10n.appTitle,
    locale: const Locale('ru'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: ref.watch(themeModeProvider),
    routerConfig: ref.watch(routerProvider),
  );

  ThemeData _theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff008577),
      brightness: brightness,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    cardTheme: const CardThemeData(margin: EdgeInsets.symmetric(vertical: 6)),
  );
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.location, required this.child});
  final String location;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget button(String path, IconData icon, String label) => Expanded(
      child: Tooltip(
        message: label,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go(path),
          child: Semantics(
            selected: location == path,
            button: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    color: location == path
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return Scaffold(
      body: child,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: l.scanTitle,
        onPressed: () => context.go('/scan'),
        child: const Icon(Icons.qr_code_scanner, size: 32),
      ),
      bottomNavigationBar: BottomAppBar(
        height:
            88 + (MediaQuery.textScalerOf(context).scale(12) - 12).clamp(0, 24),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  button('/history', Icons.receipt_long_outlined, l.historyTab),
                ],
              ),
            ),
            const SizedBox(width: 76),
            Expanded(
              child: Row(
                children: [
                  button('/stats', Icons.bar_chart_outlined, l.statsTab),
                  button('/settings', Icons.settings_outlined, l.settingsTab),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
