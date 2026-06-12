
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/alert.dart';
import '../../core/models/enums.dart';
import '../../core/models/health_metrics.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/calibration_banner.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/medical_disclaimer.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/risk_score_ring.dart';
import '../../shared/widgets/section_header.dart';
import 'presentation/risk_score_detail_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final snapshotAsync = ref.watch(healthSnapshotProvider);
    final alertsAsync = ref.watch(alertsProvider);
    final trendPoints = ref.watch(riskScoreTrendProvider);

    return Scaffold(
      floatingActionButton: _DiaryFAB(),
      body: SafeArea(
        child: snapshotAsync.when(
          loading: () => const LoadingView(message: 'Loading health data...'),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (snapshot) {
            final latestAlerts = alertsAsync.maybeWhen(
              data: (alerts) => alerts.take(3).toList(),
              orElse: () => const <HealthAlert>[],
            );

            return RefreshIndicator(
              color: AppColors.accent,
              backgroundColor: AppColors.surface,
              strokeWidth: 2.5,
              onRefresh: () async {
                ref.invalidate(healthSnapshotProvider);
                ref.invalidate(alertsProvider);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
                children: [
                  // ── Calibration banner ──────────────────────────────────
                  const CalibrationBanner(),

                  // ── Greeting row ─────────────────────────────────────────
                  _GreetingRow(
                    name: auth.user?.name.split(' ').first ?? 'there',
                    updatedAt: snapshot.updatedAt,
                  ),
                  const SizedBox(height: 28),

                  // ── 1 & 2. Animated Risk Score Ring + Status Badge ───────
                  _RiskScoreSection(snapshot: snapshot),
                  const SizedBox(height: 32),

                  // ── 3. Metric Cards 2×3 ──────────────────────────────────
                  SectionHeader(
                    title: 'Current Metrics',
                    subtitle: 'Live data from your AIRings ring',
                    action: _LiveBadge(),
                  ),
                  const SizedBox(height: 14),
                  _MetricsGrid(snapshot: snapshot),
                  const SizedBox(height: 30),

                  // ── 4. 24-hour Risk Score Chart ──────────────────────────
                  SectionHeader(
                    title: 'Risk Score Trend',
                    subtitle: 'Last 24 hours',
                  ),
                  const SizedBox(height: 14),
                  _RiskTrendChart(points: trendPoints),
                  const SizedBox(height: 30),

                  // ── 5. Latest Alerts ─────────────────────────────────────
                  if (latestAlerts.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Latest Alerts',
                      action: TextButton.icon(
                        onPressed: () => context.push('/alerts'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                        label: const Text(
                          'See all',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        iconAlignment: IconAlignment.end,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...latestAlerts.map(
                      (alert) => _AlertPreviewCard(
                        title: alert.title,
                        level: alert.level,
                        time: alert.createdAt,
                        isResolved: alert.isResolved,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  const MedicalDisclaimer(compact: true),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Greeting Row ─────────────────────────────────────────────────────────────

class _GreetingRow extends StatelessWidget {
  const _GreetingRow({required this.name, required this.updatedAt});
  final String name;
  final DateTime updatedAt;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting, $name 👋',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.normal,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Updated ${DateFormat.jm().format(updatedAt)}',
                    style: TextStyle(
                        color: context.appTextSecondary, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ),
        _ConnectivityPill(),
      ],
    );
  }
}

// ─── Connectivity Pill ────────────────────────────────────────────────────────

class _ConnectivityPill extends StatefulWidget {
  @override
  State<_ConnectivityPill> createState() => _ConnectivityPillState();
}

class _ConnectivityPillState extends State<_ConnectivityPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, a) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.normal
              .withValues(alpha: 0.08 + 0.06 * _pulse.value),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.normal
                .withValues(alpha: 0.3 + 0.15 * _pulse.value),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: AppColors.normal,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.normal
                        .withValues(alpha: 0.5 * _pulse.value),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Live',
              style: TextStyle(
                color: AppColors.normal,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Risk Score Section ───────────────────────────────────────────────────────

class _RiskScoreSection extends StatelessWidget {
  const _RiskScoreSection({required this.snapshot});
  final HealthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final ringColor = _ringColorFor(snapshot.riskScore);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ringColor.withValues(alpha: 0.06),
            context.appSurface,
            ringColor.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
          color: ringColor.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        children: [
          // Score ring — tappable
          Center(
            child: GestureDetector(
              onTap: () => showRiskScoreDetailSheet(context, snapshot),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  RiskScoreRing(
                    score: snapshot.riskScore,
                    level: snapshot.riskLevel,
                    size: 220,
                  ),
                  // Subtle tap hint
                  Positioned(
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.info_outline_rounded, size: 11, color: Colors.white38),
                          SizedBox(width: 4),
                          Text('Tap for details', style: TextStyle(color: Colors.white38, fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Quick stat row
          _RiskStatRow(snapshot: snapshot),
        ],
      ),
    );
  }

  Color _ringColorFor(int score) {
    if (score <= 30) return const Color(0xFF00C853);
    if (score <= 69) return const Color(0xFFFFC107);
    return const Color(0xFFFF3D00);
  }
}

// ─── Risk Stat Row ────────────────────────────────────────────────────────────

class _RiskStatRow extends StatelessWidget {
  const _RiskStatRow({required this.snapshot});
  final HealthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final items = [
      ('${snapshot.heartRateBpm}', 'bpm', Icons.favorite_rounded,
          AppColors.risk),
      ('${snapshot.spo2Percent}%', 'SpO2', Icons.air_rounded,
          AppColors.normal),
      ('${snapshot.activitySteps}', 'steps', Icons.directions_walk_rounded,
          AppColors.accent),
    ];

    return Row(
      children: items
          .map(
            (item) => Expanded(
              child: _MiniStat(
                value: item.$1,
                label: item.$2,
                icon: item.$3,
                color: item.$4,
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: context.appTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: context.appTextMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

// ─── Live Badge ───────────────────────────────────────────────────────────────

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
      ),
      child: const Text(
        'Live',
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ─── Metrics Grid ─────────────────────────────────────────────────────────────

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.snapshot});
  final HealthSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final cards = [
      (
        label: 'Blood Glucose Index',
        value: snapshot.glucoseIndex.toStringAsFixed(1),
        unit: 'idx',
        icon: Icons.water_drop_outlined,
        color: AppColors.warning,
        trend: MetricTrend.up,
      ),
      (
        label: 'HRV Index',
        value: '${snapshot.hrvMs}',
        unit: 'ms',
        icon: Icons.favorite_border_rounded,
        color: AppColors.accent,
        trend: MetricTrend.down,
      ),
      (
        label: 'SpO2',
        value: '${snapshot.spo2Percent}',
        unit: '%',
        icon: Icons.air_rounded,
        color: AppColors.normal,
        trend: MetricTrend.stable,
      ),
      (
        label: 'Heart Rate',
        value: '${snapshot.heartRateBpm}',
        unit: 'bpm',
        icon: Icons.monitor_heart_outlined,
        color: AppColors.risk,
        trend: MetricTrend.up,
      ),
      (
        label: 'Sleep Quality',
        value: '${snapshot.sleepQuality}',
        unit: '%',
        icon: Icons.bedtime_outlined,
        color: AppColors.accentLight,
        trend: MetricTrend.down,
      ),
      (
        label: 'Skin Temp',
        value: snapshot.skinTemperatureC.toStringAsFixed(1),
        unit: '°C',
        icon: Icons.thermostat_outlined,
        color: const Color(0xFFFF7043),
        trend: MetricTrend.stable,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: cards
          .map(
            (c) => MetricCard(
              label: c.label,
              value: c.value,
              unit: c.unit,
              icon: c.icon,
              accentColor: c.color,
              trend: c.trend,
            ),
          )
          .toList(),
    );
  }
}

// ─── Risk Score Line Chart ────────────────────────────────────────────────────

class _RiskTrendChart extends StatefulWidget {
  const _RiskTrendChart({required this.points});
  final List<MetricPoint> points;

  @override
  State<_RiskTrendChart> createState() => _RiskTrendChartState();
}

class _RiskTrendChartState extends State<_RiskTrendChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _colorForValue(double v) {
    if (v <= 30) return const Color(0xFF00C853);
    if (v <= 69) return const Color(0xFFFFC107);
    return const Color(0xFFFF3D00);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.points.isEmpty) return const SizedBox.shrink();

    final now = DateTime.now();

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        final visibleCount =
            (widget.points.length * _anim.value).ceil().clamp(2, widget.points.length);
        final visiblePoints = widget.points.sublist(0, visibleCount);
        final spots = List.generate(
          visiblePoints.length,
          (i) => FlSpot(i.toDouble(), visiblePoints[i].value),
        );

        return Container(
          height: 200,
          padding: const EdgeInsets.fromLTRB(4, 16, 16, 8),
          decoration: BoxDecoration(
            color: context.appSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.appBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              minY: 20,
              maxY: 100,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 25,
                getDrawingHorizontalLine: (v) => FlLine(
                  color: context.appBorder.withValues(alpha: 0.5),
                  strokeWidth: 1,
                  dashArray: [4, 6],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
                    interval: 25,
                    getTitlesWidget: (v, meta) {
                      if (v == meta.min || v == meta.max) {
                        return const SizedBox();
                      }
                      return Text(
                        '${v.toInt()}',
                        style: TextStyle(
                          color: context.appTextMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    interval: 4,
                    getTitlesWidget: (v, meta) {
                      final idx = v.toInt();
                      if (idx < 0 || idx >= widget.points.length) {
                        return const SizedBox();
                      }
                      final t = now.subtract(
                          Duration(hours: widget.points.length - 1 - idx));
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          DateFormat.j().format(t),
                          style: TextStyle(
                            color: context.appTextMuted,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchCallback: (event, response) {
                  final idx = response?.lineBarSpots?.first.spotIndex;
                  if (mounted) setState(() => _touchedIndex = idx);
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => context.appSurfaceElevated,
                  tooltipRoundedRadius: 10,
                  tooltipBorder: BorderSide(
                    color: context.appBorder,
                    width: 1,
                  ),
                  getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
                    final color = _colorForValue(s.y);
                    return LineTooltipItem(
                      'Risk ${s.y.toInt()}',
                      TextStyle(
                        color: color,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.4,
                  barWidth: 2.5,
                  color: AppColors.accent,
                  dotData: FlDotData(
                    show: true,
                    checkToShowDot: (spot, _) {
                      return spot.x == spots.last.x ||
                          spot.x == _touchedIndex?.toDouble();
                    },
                    getDotPainter: (spot, pct, a, b) {
                      final isTip = spot.x == spots.last.x;
                      return FlDotCirclePainter(
                        radius: isTip ? 5 : 4,
                        color: _colorForValue(spot.y),
                        strokeWidth: 2.5,
                        strokeColor: context.appSurface,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.accent.withValues(alpha: 0.22),
                        AppColors.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 30,
                    color: const Color(0xFF00C853).withValues(alpha: 0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      labelResolver: (_) => 'Low',
                      style: const TextStyle(
                        color: Color(0xFF00C853),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  HorizontalLine(
                    y: 70,
                    color: const Color(0xFFFF3D00).withValues(alpha: 0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                    label: HorizontalLineLabel(
                      show: true,
                      alignment: Alignment.topRight,
                      labelResolver: (_) => 'High',
                      style: const TextStyle(
                        color: Color(0xFFFF3D00),
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Alert Preview Card ───────────────────────────────────────────────────────

class _AlertPreviewCard extends StatelessWidget {
  const _AlertPreviewCard({
    required this.title,
    required this.level,
    required this.time,
    required this.isResolved,
  });

  final String title;
  final AlertLevel level;
  final DateTime time;
  final bool isResolved;

  Color _colorFor(AlertLevel level) => switch (level) {
        AlertLevel.informational => AppColors.accent,
        AlertLevel.warning => AppColors.warning,
        AlertLevel.critical => AppColors.risk,
      };

  IconData _iconFor(AlertLevel level) => switch (level) {
        AlertLevel.informational => Icons.info_outline_rounded,
        AlertLevel.warning => Icons.warning_amber_rounded,
        AlertLevel.critical => Icons.crisis_alert_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(level);
    final effectiveColor = isResolved ? color.withValues(alpha: 0.45) : color;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isResolved
              ? context.appBorder
              : color.withValues(alpha: 0.35),
          width: isResolved ? 1 : 1.2,
        ),
        boxShadow: isResolved
            ? null
            : [
                BoxShadow(
                  color: color.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(
                  alpha: isResolved ? 0.06 : 0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconFor(level),
              color: effectiveColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isResolved
                        ? context.appTextSecondary
                        : context.appTextPrimary,
                    decoration: isResolved
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: context.appTextMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat.MMMd().add_jm().format(time),
                  style: TextStyle(
                    color: context.appTextMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: effectiveColor.withValues(
                  alpha: isResolved ? 0.06 : 0.13),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isResolved ? 'Resolved' : level.label,
              style: TextStyle(
                color: isResolved ? context.appTextMuted : color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Diary FAB ────────────────────────────────────────────────────────────────

class _DiaryFAB extends StatefulWidget {
  @override
  State<_DiaryFAB> createState() => _DiaryFABState();
}

class _DiaryFABState extends State<_DiaryFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    // Animate in after a short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnim,
      child: FloatingActionButton.extended(
        heroTag: 'dashboard_fab',
        onPressed: () => context.push('/diary'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 6,
        extendedPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
        icon: const Icon(Icons.edit_note_rounded, size: 22),
        label: const Text(
          'Food & Activity Diary',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
