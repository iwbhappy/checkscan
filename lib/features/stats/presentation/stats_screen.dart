import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../app/failure_text.dart';
import '../../../app/format.dart';
import '../../../app/l10n.dart';
import '../../../app/preferences.dart';
import '../../../app/providers.dart';
import '../../../app/widgets.dart';
import '../../../core/utils/money.dart';
import '../../../data/repositories/stats_repository.dart';

typedef _StatsQuery = ({DateTime from, DateTime until, String grouping});
final _statsProvider = StreamProvider.autoDispose
    .family<StatsData, _StatsQuery>(
      (ref, query) => ref
          .watch(statsRepositoryProvider)
          .watchStats(query.from, query.until, grouping: query.grouping),
    );

enum _Period { week, month, year, custom }

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});
  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  _Period _period = _Period.month;
  late DateTime _from;
  late DateTime _until;
  bool _frequency = false;

  @override
  void initState() {
    super.initState();
    _choose(_Period.month);
  }

  void _choose(_Period period) {
    final now = kazakhstanNow();
    final today = DateTime.utc(now.year, now.month, now.day);
    _period = period;
    switch (period) {
      case _Period.week:
        _from = today.subtract(Duration(days: today.weekday - 1));
        _until = _from.add(const Duration(days: 7));
      case _Period.month:
        _from = DateTime.utc(today.year, today.month);
        _until = DateTime.utc(today.year, today.month + 1);
      case _Period.year:
        _from = DateTime.utc(today.year);
        _until = DateTime.utc(today.year + 1);
      case _Period.custom:
        break;
    }
  }

  void _move(int step) => setState(() {
    switch (_period) {
      case _Period.month:
        _from = DateTime.utc(_from.year, _from.month + step);
        _until = DateTime.utc(_from.year, _from.month + 1);
      case _Period.year:
        _from = DateTime.utc(_from.year + step);
        _until = DateTime.utc(_from.year + 1);
      case _Period.week:
      case _Period.custom:
        final shift = Duration(days: _until.difference(_from).inDays * step);
        _from = _from.add(shift);
        _until = _until.add(shift);
    }
  });

  Future<void> _custom() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.utc(2000),
      lastDate: DateTime.utc(2100),
      initialDateRange: DateTimeRange(
        start: _from,
        end: _until.subtract(const Duration(days: 1)),
      ),
    );
    if (range != null && mounted) {
      setState(() {
        _period = _Period.custom;
        _from = DateTime.utc(
          range.start.year,
          range.start.month,
          range.start.day,
        );
        _until = DateTime.utc(
          range.end.year,
          range.end.month,
          range.end.day + 1,
        );
      });
    }
  }

  void _history({int? categoryId, int? storeId}) {
    context.go(
      Uri(
        path: '/history',
        queryParameters: {
          'from': _from.toIso8601String(),
          'until': _until.toIso8601String(),
          if (categoryId != null) 'category': '$categoryId',
          if (storeId != null) 'store': '$storeId',
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final currency = ref.watch(currencySymbolProvider);
    String money(int value) => Money.format(value, currency: currency);
    final days = _until.difference(_from).inDays;
    final grouping = days > 120
        ? 'month'
        : days > 40
        ? 'week'
        : 'day';
    final data = ref.watch(
      _statsProvider((from: _from, until: _until, grouping: grouping)),
    );
    return Scaffold(
      appBar: AppBar(title: Text(l.statsTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              children: [
                for (final period in _Period.values)
                  ChoiceChip(
                    label: Text(switch (period) {
                      _Period.week => l.week,
                      _Period.month => l.month,
                      _Period.year => l.year,
                      _Period.custom => l.customPeriod,
                    }),
                    selected: _period == period,
                    onSelected: (_) {
                      if (period == _Period.custom) {
                        _custom();
                      } else {
                        setState(() => _choose(period));
                      }
                    },
                  ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                tooltip: l.previousPeriod,
                onPressed: () => _move(-1),
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: Text(
                  '${DateFormat('d MMM y', 'ru_RU').format(_from)} — ${DateFormat('d MMM y', 'ru_RU').format(_until.subtract(const Duration(days: 1)))}',
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                tooltip: l.nextPeriod,
                onPressed: () => _move(1),
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          Expanded(
            child: data.when(
              loading: () => const LoadingSkeleton(),
              error: (error, _) =>
                  EmptyState(title: failureText(context, error)),
              data: (stats) {
                if (stats.summary.receiptCount == 0) {
                  return EmptyState(
                    title: l.emptyStatsTitle,
                    description: l.emptyStatsDescription,
                    icon: Icons.bar_chart_outlined,
                  );
                }
                final comparison = stats.previousTotalMinor == 0
                    ? l.noPreviousPeriodData
                    : '${stats.changePercent!.toStringAsFixed(1)} %';
                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: [
                    Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.totalSpent),
                            const SizedBox(height: 8),
                            Text(
                              money(stats.summary.totalMinor),
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 24,
                              runSpacing: 12,
                              children: [
                                Text(
                                  l.receiptsCount(stats.summary.receiptCount),
                                ),
                                Text(
                                  '${l.averageReceipt}: ${money(stats.summary.averageMinor)}',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('${l.comparedToPrevious}: $comparison'),
                          ],
                        ),
                      ),
                    ),
                    _heading(context, l.byCategory),
                    if (stats.summary.totalMinor > 0 &&
                        stats.categories.every(
                          (category) => category.totalMinor >= 0,
                        ))
                      Semantics(
                        label:
                            '${l.byCategory}, ${money(stats.summary.totalMinor)}',
                        child: SizedBox(
                          height: 200,
                          child: PieChart(
                            PieChartData(
                              centerSpaceRadius: 46,
                              sectionsSpace: 3,
                              sections: [
                                for (final category in stats.categories.where(
                                  (category) => category.totalMinor > 0,
                                ))
                                  PieChartSectionData(
                                    value: category.totalMinor.toDouble(),
                                    color: Color(category.color),
                                    radius: 44,
                                    showTitle: false,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    for (final category in stats.categories)
                      ListTile(
                        leading: CircleAvatar(
                          radius: 7,
                          backgroundColor: Color(category.color),
                        ),
                        title: Text(category.name),
                        subtitle: Text(
                          stats.summary.totalMinor == 0
                              ? '0 %'
                              : '${(category.totalMinor * 100 / stats.summary.totalMinor).toStringAsFixed(1)} %',
                        ),
                        trailing: Text(money(category.totalMinor)),
                        onTap: () => _history(categoryId: category.categoryId),
                      ),
                    _heading(
                      context,
                      grouping == 'month'
                          ? l.spendingByMonth
                          : grouping == 'week'
                          ? l.spendingByWeek
                          : l.spendingByDay,
                    ),
                    if (stats.buckets.isNotEmpty)
                      SizedBox(
                        height: 230,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: (stats.buckets.length * 38.0).clamp(
                              300,
                              4000,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                              child: BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    rightTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    topTitles: const AxisTitles(
                                      sideTitles: SideTitles(showTitles: false),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 36,
                                        getTitlesWidget: (value, meta) {
                                          final index = value.toInt();
                                          if (index < 0 ||
                                              index >= stats.buckets.length) {
                                            return const SizedBox.shrink();
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                              top: 8,
                                            ),
                                            child: Text(
                                              stats.buckets[index].label,
                                              style: const TextStyle(
                                                fontSize: 10,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: const FlGridData(show: false),
                                  barGroups: [
                                    for (
                                      var index = 0;
                                      index < stats.buckets.length;
                                      index++
                                    )
                                      BarChartGroupData(
                                        x: index,
                                        barRods: [
                                          BarChartRodData(
                                            toY:
                                                stats
                                                    .buckets[index]
                                                    .totalMinor /
                                                100,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            width: 18,
                                          ),
                                        ],
                                      ),
                                  ],
                                  barTouchData: BarTouchData(
                                    touchTooltipData: BarTouchTooltipData(
                                      getTooltipItem:
                                          (
                                            group,
                                            groupIndex,
                                            rod,
                                            rodIndex,
                                          ) => BarTooltipItem(
                                            '${stats.buckets[group.x].label}\n${money(stats.buckets[group.x].totalMinor)}',
                                            const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    _heading(context, l.topStores),
                    for (final store in stats.stores)
                      ListTile(
                        title: Text(store.name),
                        subtitle: Text(l.receiptsCount(store.receiptCount)),
                        trailing: Text(money(store.totalMinor)),
                        onTap: store.storeId == null
                            ? null
                            : () => _history(storeId: store.storeId),
                      ),
                    _heading(context, l.topProducts),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l.byAmount),
                          selected: !_frequency,
                          onSelected: (_) => setState(() => _frequency = false),
                        ),
                        ChoiceChip(
                          label: Text(l.byFrequency),
                          selected: _frequency,
                          onSelected: (_) => setState(() => _frequency = true),
                        ),
                      ],
                    ),
                    for (final product
                        in _frequency
                            ? stats.productsByFrequency
                            : stats.productsByAmount)
                      ListTile(
                        title: Text(product.name),
                        subtitle: Text(l.receiptsCount(product.purchaseCount)),
                        trailing: Text(money(product.totalMinor)),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _heading(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
    child: Text(text, style: Theme.of(context).textTheme.titleLarge),
  );
}
