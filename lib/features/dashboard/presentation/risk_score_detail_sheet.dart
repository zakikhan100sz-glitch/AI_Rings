import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/health_metrics.dart';
import '../../../core/theme/app_colors.dart';
import '../../doctor_link/doctor_link_provider.dart';

/// Metric contribution data passed into the sheet.
class MetricContribution {
  const MetricContribution({
    required this.label,
    required this.contribution, // 0.0 – 1.0
    required this.explanation,
  });

  final String label;
  final double contribution;
  final String explanation;
}

List<MetricContribution> _buildContributions(HealthSnapshot snapshot) {
  // Derive contribution weights from the snapshot values (mock logic).
  final hrv = (1.0 - (snapshot.hrvMs.clamp(20, 60) - 20) / 40).clamp(0.0, 1.0);
  final spo2 = (1.0 - (snapshot.spo2Percent.clamp(92, 100) - 92) / 8).clamp(0.0, 1.0);
  final hr = ((snapshot.heartRateBpm.clamp(60, 110) - 60) / 50.0).clamp(0.0, 1.0);
  final temp = ((snapshot.skinTemperatureC.clamp(35.5, 38.0) - 35.5) / 2.5).clamp(0.0, 1.0);
  final sleep = (1.0 - (snapshot.sleepQuality.clamp(40, 100) - 40) / 60.0).clamp(0.0, 1.0);

  return [
    MetricContribution(
      label: 'HRV',
      contribution: hrv,
      explanation: 'Your HRV dropped ${((1 - hrv) * 18).round()}% in the last 2 hours, which is an early marker for glucose fluctuation.',
    ),
    MetricContribution(
      label: 'SpO2',
      contribution: spo2,
      explanation: 'Blood oxygen at ${snapshot.spo2Percent}% is ${spo2 < 0.3 ? "within normal range" : "slightly below baseline"}, contributing to elevated risk.',
    ),
    MetricContribution(
      label: 'Heart Rate',
      contribution: hr,
      explanation: 'Resting heart rate of ${snapshot.heartRateBpm} bpm is ${hr < 0.4 ? "normal" : "above baseline"}, adding mild stress indicators.',
    ),
    MetricContribution(
      label: 'Skin Temp',
      contribution: temp,
      explanation: 'Skin temperature at ${snapshot.skinTemperatureC}°C shows ${temp < 0.4 ? "no thermal stress" : "slight elevation"} from your baseline.',
    ),
    MetricContribution(
      label: 'Sleep',
      contribution: sleep,
      explanation: 'Sleep quality scored ${snapshot.sleepQuality}/100 last night. Poor sleep amplifies metabolic risk by up to ${(sleep * 25).round()}%.',
    ),
  ];
}

void showRiskScoreDetailSheet(BuildContext context, HealthSnapshot snapshot) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.7),
    builder: (_) => RiskScoreDetailSheet(snapshot: snapshot),
  );
}

class RiskScoreDetailSheet extends ConsumerWidget {
  const RiskScoreDetailSheet({super.key, required this.snapshot});

  final HealthSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributions = _buildContributions(snapshot);
    final linkedDoctorsAsync = ref.watch(linkedDoctorsProvider);
    final hasLinkedDoctor = linkedDoctorsAsync.maybeWhen(
      data: (list) => list.isNotEmpty,
      orElse: () => false,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag Handle ──
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Scrollable Content ──
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                  children: [
                    // Title
                    Text(
                      'Why is your risk score ${snapshot.riskScore}?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Here\'s how each metric is contributing to your current risk level.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
                    ),
                    const SizedBox(height: 28),

                    // ── Bar Chart ──
                    const Text(
                      'Metric Contributions',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: _ContributionBarChart(contributions: contributions),
                    ),
                    const SizedBox(height: 28),

                    // ── Explanations ──
                    const Text(
                      'What\'s driving this',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    ...contributions.map((c) => _ExplanationTile(contribution: c)),

                    const SizedBox(height: 28),

                    // ── What should I do? ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D1117),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF30363D)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Color(0xFFFFB300), size: 20),
                              SizedBox(width: 8),
                              Text(
                                'What should I do?',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _ActionChip(
                                icon: Icons.water_drop_outlined,
                                label: 'Drink water',
                                color: AppColors.accent,
                                onTap: () {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Great! Stay hydrated 💧')),
                                  );
                                },
                              ),
                              _ActionChip(
                                icon: Icons.restaurant_outlined,
                                label: 'Eat a snack',
                                color: const Color(0xFFFFB300),
                                onTap: () {
                                  Navigator.pop(context);
                                  context.push('/diary');
                                },
                              ),
                              _ActionChip(
                                icon: Icons.local_hospital_outlined,
                                label: 'Contact doctor',
                                color: AppColors.risk,
                                onTap: () {
                                  Navigator.pop(context);
                                  if (!hasLinkedDoctor) {
                                    context.push('/doctor-link');
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Alert sent to your doctor 🚨')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Bar Chart ────────────────────────────────────────────────────────────────

class _ContributionBarChart extends StatelessWidget {
  const _ContributionBarChart({required this.contributions});
  final List<MetricContribution> contributions;

  Color _barColor(double value) {
    if (value <= 0.3) return AppColors.normal;
    if (value <= 0.6) return const Color(0xFFFFB300);
    return AppColors.risk;
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1.0,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF21262D),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${(rod.toY * 100).round()}%',
                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= contributions.length) return const SizedBox();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    contributions[idx].label,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 0.25,
              reservedSize: 36,
              getTitlesWidget: (value, meta) => Text(
                '${(value * 100).round()}%',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 0.25,
          getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFF30363D), strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
        barGroups: contributions.asMap().entries.map((e) {
          final idx = e.key;
          final item = e.value;
          return BarChartGroupData(
            x: idx,
            barRods: [
              BarChartRodData(
                toY: item.contribution,
                color: _barColor(item.contribution),
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: 1.0,
                  color: const Color(0xFF21262D),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Explanation Tile ─────────────────────────────────────────────────────────

class _ExplanationTile extends StatelessWidget {
  const _ExplanationTile({required this.contribution});
  final MetricContribution contribution;

  Color get _color {
    if (contribution.contribution <= 0.3) return AppColors.normal;
    if (contribution.contribution <= 0.6) return const Color(0xFFFFB300);
    return AppColors.risk;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 5),
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contribution.label,
                  style: TextStyle(color: _color, fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  contribution.explanation,
                  style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action Chip ──────────────────────────────────────────────────────────────

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
