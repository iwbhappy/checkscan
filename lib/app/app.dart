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
import 'theme.dart';
import 'motion.dart';
import '../domain/models/receipt_draft.dart';
import '../features/scan/presentation/document_import_screen.dart';
import '../features/scan/data/shared_receipt_bridge.dart';
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
        GoRoute(
          path: '/scan',
          builder: (_, state) =>
              ScanScreen(initialLink: state.uri.queryParameters['link']),
        ),
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
    GoRoute(
      path: '/receipts/new',
      builder: (_, state) => ReceiptEditor(
        draft: state.extra is ReceiptDraft ? state.extra as ReceiptDraft : null,
      ),
    ),
    GoRoute(
      path: '/import',
      builder: (_, state) =>
          DocumentImportScreen(path: state.extra as String? ?? ''),
    ),
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
  SharedReceiptBridge? _incoming;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (ref.read(backgroundWorkProvider)) {
      _incoming = SharedReceiptBridge((receipt) {
        if (!mounted) return;
        final router = ref.read(routerProvider);
        if (receipt['path'] case final String path) {
          router.push('/import', extra: path);
        } else if (receipt['text'] case final String text) {
          router.go(
            Uri(path: '/scan', queryParameters: {'link': text}).toString(),
          );
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unawaited(_incoming!.start());
      });
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
    _incoming?.dispose();
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
    theme: checkScanTheme(Brightness.light),
    darkTheme: checkScanTheme(Brightness.dark),
    themeMode: ref.watch(themeModeProvider),
    routerConfig: ref.watch(routerProvider),
  );
}

class _AppShell extends StatelessWidget {
  const _AppShell({required this.location, required this.child});
  final String location;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final destinations = [
      ('/history', Icons.receipt_long_outlined, l.historyTab),
      ('/scan', Icons.qr_code_scanner_rounded, 'Скан'),
      ('/stats', Icons.bar_chart_rounded, l.statsTab),
      ('/settings', Icons.settings_outlined, l.settingsTab),
    ];
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        animationDuration: motionDuration(context),
        selectedIndex: destinations
            .indexWhere((item) => item.$1 == location)
            .clamp(0, 3),
        onDestinationSelected: (index) => context.go(destinations[index].$1),
        destinations: [
          for (final item in destinations)
            NavigationDestination(icon: Icon(item.$2), label: item.$3),
        ],
      ),
    );
  }
}
