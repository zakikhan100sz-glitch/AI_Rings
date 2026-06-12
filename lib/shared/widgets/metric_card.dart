import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum MetricTrend { up, down, stable }

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.subtitle,
    this.trend,
    this.accentColor = AppColors.accent,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final String? subtitle;
  final MetricTrend? trend;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              const Spacer(),
              if (trend != null) _TrendArrow(trend: trend!),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: context.appTextSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: FittedBox(
                  alignment: Alignment.centerLeft,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: context.appTextPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 3),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  unit,
                  style: TextStyle(
                    color: context.appTextMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: context.appTextMuted,
                fontSize: 11,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendArrow extends StatelessWidget {
  const _TrendArrow({required this.trend});
  final MetricTrend trend;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (trend) {
      MetricTrend.up => (Icons.arrow_upward_rounded, const Color(0xFF00C853)),
      MetricTrend.down => (Icons.arrow_downward_rounded, const Color(0xFFFF3D00)),
      MetricTrend.stable => (Icons.remove_rounded, const Color(0xFFFFC107)),
    };

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: color, size: 13),
    );
  }
}
