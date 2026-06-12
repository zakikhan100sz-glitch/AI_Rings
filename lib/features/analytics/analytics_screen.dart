import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/chart_annotation.dart';
import '../../core/models/enums.dart';
import '../../core/models/health_metrics.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/section_header.dart';

const _overlayColors = [
  AppColors.accent,
  AppColors.normal,
  AppColors.warning,
  AppColors.risk,
  AppColors.accentLight,
];

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  MetricType _selectedMetric = MetricType.heartRate;
  bool _overlayMode = false;

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(chartPeriodProvider);
    final seriesAsync = ref.watch(metricSeriesProvider);
    final annotationsAsync = ref.watch(chartAnnotationsProvider);
    final overlayMetrics = ref.watch(overlayMetricsProvider);

    return Scaffold(
      body: SafeArea(
        child: seriesAsync.when(
          loading: () => const LoadingView(message: 'Loading analytics...'),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (series) {
            final selected = series.firstWhere(
              (s) => s.type == _selectedMetric,
              orElse: () => series.first,
            );

            final overlaySeries = _overlayMode
                ? series
                    .where(
                      (s) =>
                          overlayMetrics.contains(s.type) ||
                          s.type == _selectedMetric,
                    )
                    .toList()
                : [selected];

            final annotations = annotationsAsync.maybeWhen(
              data: (a) => a,
              orElse: () => const <ChartAnnotation>[],
            );

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SectionHeader(
                  title: 'Detailed analytics',
                  subtitle: 'Interactive charts with overlays and annotations',
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Compare metrics overlay'),
                  subtitle: const Text(
                    'Select multiple metrics to compare on one chart',
                  ),
                  value: _overlayMode,
                  onChanged: (v) {
                    setState(() => _overlayMode = v);
                    if (v) {
                      ref.read(overlayMetricsProvider.notifier).state = {
                        _selectedMetric,
                        MetricType.hrv,
                      };
                    } else {
                      ref.read(overlayMetricsProvider.notifier).state = {};
                    }
                  },
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ChartPeriod.values.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p.label),
                          selected: p == period,
                          onSelected: (_) =>
                              ref.read(chartPeriodProvider.notifier).state = p,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: series.map((s) {
                      final isPrimary = s.type == _selectedMetric;
                      final inOverlay = overlayMetrics.contains(s.type);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(s.label),
                          selected: _overlayMode ? inOverlay : isPrimary,
                          onSelected: (_) {
                            if (_overlayMode) {
                              final next = Set<MetricType>.from(overlayMetrics);
                              if (next.contains(s.type)) {
                                if (next.length > 1) next.remove(s.type);
                              } else {
                                next.add(s.type);
                              }
                              ref.read(overlayMetricsProvider.notifier).state =
                                  next;
                            } else {
                              setState(() => _selectedMetric = s.type);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                _MetricChartCard(
                  seriesList: overlaySeries,
                  annotations: annotations,
                  overlayMode: _overlayMode,
                ),
                if (annotations.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Annotations',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...annotations.map((a) => _AnnotationChip(annotation: a)),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_outline,
                          color: AppColors.normal, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _overlayMode
                              ? 'Overlay mode normalizes each metric to its own scale.'
                              : 'Normal zone: ${selected.normalMin}–${selected.normalMax} ${selected.unit}',
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Export will be available when API is connected.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_outlined),
                  label: const Text('Export PDF / CSV'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AnnotationChip extends StatelessWidget {
  const _AnnotationChip({required this.annotation});

  final ChartAnnotation annotation;

  Color get _color => switch (annotation.type) {
        ChartAnnotationType.alert => AppColors.risk,
        ChartAnnotationType.meal => AppColors.warning,
        ChartAnnotationType.activity => AppColors.normal,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(
            switch (annotation.type) {
              ChartAnnotationType.alert => Icons.notifications_active_outlined,
              ChartAnnotationType.meal => Icons.restaurant_outlined,
              ChartAnnotationType.activity => Icons.directions_walk_outlined,
            },
            size: 16,
            color: _color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              annotation.label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          Text(
            DateFormat.MMMd().add_jm().format(annotation.timestamp),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _MetricChartCard extends StatelessWidget {
  const _MetricChartCard({
    required this.seriesList,
    required this.annotations,
    required this.overlayMode,
  });

  final List<MetricSeries> seriesList;
  final List<ChartAnnotation> annotations;
  final bool overlayMode;

  @override
  Widget build(BuildContext context) {
    if (seriesList.isEmpty || seriesList.first.points.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text('No data available')),
      );
    }

    final pointCount = seriesList.first.points.length;

    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    final lineBars = <LineChartBarData>[];
    for (var i = 0; i < seriesList.length; i++) {
      final series = seriesList[i];
      final points = series.points;
      final color = _overlayColors[i % _overlayColors.length];

      for (final p in points) {
        final value = overlayMode ? _normalize(p.value, series) : p.value;
        if (value < minY) minY = value;
        if (value > maxY) maxY = value;
      }

      lineBars.add(
        LineChartBarData(
          spots: [
            for (var j = 0; j < points.length; j++)
              FlSpot(
                j.toDouble(),
                overlayMode
                    ? _normalize(points[j].value, series)
                    : points[j].value,
              ),
          ],
          isCurved: true,
          color: color,
          barWidth: 2.5,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: !overlayMode && i == 0,
            color: color.withValues(alpha: 0.1),
          ),
        ),
      );
    }

    if (overlayMode) {
      minY = 0;
      maxY = 100;
    } else {
      minY -= 2;
      maxY += 2;
    }

    final referenceSeries = seriesList.first;
    final verticalLines = <VerticalLine>[];
    for (final annotation in annotations) {
      final index = referenceSeries.points.indexWhere(
        (p) => p.timestamp.isAfter(annotation.timestamp),
      );
      if (index > 0) {
        verticalLines.add(
          VerticalLine(
            x: index.toDouble(),
            color: AppColors.textMuted.withValues(alpha: 0.5),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        );
      }
    }

    return Container(
      height: 300,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              overlayMode
                  ? 'Metric comparison (${seriesList.map((s) => s.label).join(', ')})'
                  : '${referenceSeries.label} (${referenceSeries.unit})',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),
          if (overlayMode) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Wrap(
                spacing: 12,
                children: [
                  for (var i = 0; i < seriesList.length; i++)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 12,
                          height: 3,
                          color: _overlayColors[i % _overlayColors.length],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          seriesList[i].label,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) => Text(
                        overlayMode
                            ? value.toStringAsFixed(0)
                            : value.toStringAsFixed(0),
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (pointCount / 4).clamp(1, 12).toDouble(),
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 ||
                            index >= referenceSeries.points.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          DateFormat.Hm().format(
                            referenceSeries.points[index].timestamp,
                          ),
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(),
                  topTitles: const AxisTitles(),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: lineBars,
                extraLinesData: ExtraLinesData(
                  verticalLines: verticalLines,
                  horizontalLines: overlayMode
                      ? []
                      : [
                          HorizontalLine(
                            y: referenceSeries.normalMin,
                            color: AppColors.normal.withValues(alpha: 0.5),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                          HorizontalLine(
                            y: referenceSeries.normalMax,
                            color: AppColors.normal.withValues(alpha: 0.5),
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _normalize(double value, MetricSeries series) {
    final range = series.normalMax - series.normalMin;
    if (range <= 0) return 50;
    return ((value - series.normalMin) / range * 100).clamp(0, 100);
  }
}
