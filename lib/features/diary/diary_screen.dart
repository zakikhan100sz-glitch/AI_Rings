import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/diary_entry.dart';
import '../../core/models/health_metrics.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/section_header.dart';
import 'add_activity_sheet.dart';
import 'add_meal_sheet.dart';
import 'diary_provider.dart';

class DiaryScreen extends ConsumerWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(diaryEntriesProvider);
    final riskScoreTrend = ref.watch(riskScoreTrendProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1117),
        elevation: 0,
        title: const Text('Food & Activity Diary', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2E6BD6),
        foregroundColor: Colors.white,
        onPressed: () => _showAddEntryMenu(context),
        icon: const Icon(Icons.add),
        label: const Text('Log Entry'),
      ),
      body: entriesAsync.when(
        loading: () => const LoadingView(message: 'Loading diary...'),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.white))),
        data: (entries) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Risk Score & Diary',
                        subtitle: 'See how your meals and activities impact your score',
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: _ChartOverlay(
                          trend: riskScoreTrend,
                          entries: entries,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Today\'s Timeline',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (entries.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text(
                              'No entries yet. Log meals and activity to improve AI insights.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        )
                      else
                        ...entries.map((e) => _DiaryTile(entry: e)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddEntryMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.restaurant_outlined, color: AppColors.warning),
              title: const Text('Log Meal', style: TextStyle(color: Colors.white, fontSize: 16)),
              onTap: () {
                Navigator.pop(ctx);
                AddMealSheet.show(context);
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.directions_walk_outlined, color: AppColors.normal),
              title: const Text('Log Activity', style: TextStyle(color: Colors.white, fontSize: 16)),
              onTap: () {
                Navigator.pop(ctx);
                AddActivitySheet.show(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ChartOverlay extends StatelessWidget {
  const _ChartOverlay({required this.trend, required this.entries});
  final List<MetricPoint> trend;
  final List<DiaryEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) return const SizedBox();

    final minTime = trend.first.timestamp.millisecondsSinceEpoch.toDouble();
    final maxTime = trend.last.timestamp.millisecondsSinceEpoch.toDouble();

    final spots = trend.map((p) {
      return FlSpot(
        p.timestamp.millisecondsSinceEpoch.toDouble(),
        p.value,
      );
    }).toList();

    return LineChart(
      LineChartData(
        minX: minTime,
        maxX: maxTime,
        minY: 0,
        maxY: 100,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFF30363D),
            strokeWidth: 1,
            dashArray: [5, 5],
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: (maxTime - minTime) / 4,
              getTitlesWidget: (value, meta) {
                final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    DateFormat.Hm().format(date),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: const Color(0xFF2E6BD6),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2E6BD6).withValues(alpha: 0.1),
            ),
          ),
        ],
        extraLinesData: ExtraLinesData(
          verticalLines: entries.where((e) {
            final t = e.recordedAt.millisecondsSinceEpoch.toDouble();
            return t >= minTime && t <= maxTime;
          }).map((e) {
            return VerticalLine(
              x: e.recordedAt.millisecondsSinceEpoch.toDouble(),
              color: e.type == DiaryEntryType.meal ? AppColors.warning : AppColors.normal,
              strokeWidth: 2,
              dashArray: [4, 4],
              label: VerticalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(bottom: 4),
                style: TextStyle(
                  color: e.type == DiaryEntryType.meal ? AppColors.warning : AppColors.normal,
                  fontSize: 18,
                  fontFamily: 'MaterialIcons',
                ),
                labelResolver: (_) => String.fromCharCode(
                  e.type == DiaryEntryType.meal
                      ? Icons.restaurant.codePoint
                      : Icons.directions_walk.codePoint,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _DiaryTile extends ConsumerWidget {
  const _DiaryTile({required this.entry});

  final DiaryEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = entry.type == DiaryEntryType.meal
        ? Icons.restaurant_outlined
        : Icons.directions_walk_outlined;
    final color = entry.type == DiaryEntryType.meal
        ? AppColors.warning
        : AppColors.normal;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22), // Surface
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF30363D)), // Border
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat.jm().format(entry.recordedAt),
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (entry.type == DiaryEntryType.meal && entry.carbs != null) ...[
                      const Icon(Icons.water_drop_outlined, size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text('${entry.carbs!.toStringAsFixed(1)}g carbs', 
                        style: const TextStyle(color: AppColors.warning, fontSize: 13)),
                    ] else if (entry.type == DiaryEntryType.activity && entry.durationMinutes != null) ...[
                      const Icon(Icons.timer_outlined, size: 14, color: AppColors.normal),
                      const SizedBox(width: 4),
                      Text('${entry.durationMinutes} min', 
                        style: const TextStyle(color: AppColors.normal, fontSize: 13)),
                      if (entry.intensity != null) ...[
                        const SizedBox(width: 12),
                        const Icon(Icons.bolt, size: 14, color: AppColors.normal),
                        const SizedBox(width: 4),
                        Text(entry.intensity!, 
                          style: const TextStyle(color: AppColors.normal, fontSize: 13)),
                      ],
                    ],
                  ],
                ),
                if (entry.notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    entry.notes,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.risk, size: 20),
            onPressed: () {
              ref.read(diaryEntriesProvider.notifier).removeEntry(entry.id);
            },
          )
        ],
      ),
    );
  }
}
