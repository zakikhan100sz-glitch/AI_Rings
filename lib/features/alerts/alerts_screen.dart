import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/alert.dart';
import '../../core/models/enums.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/widgets/loading_view.dart';
import '../../shared/widgets/section_header.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  AlertLevel? _levelFilter;

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);
    final dateRange = ref.watch(alertDateFilterProvider);

    return Scaffold(
      body: SafeArea(
        child: alertsAsync.when(
          loading: () => const LoadingView(message: 'Loading alerts...'),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (alerts) {
            var filtered = alerts;
            if (_levelFilter != null) {
              filtered =
                  filtered.where((a) => a.level == _levelFilter).toList();
            }
            if (dateRange != null) {
              filtered = filtered.where((a) {
                return !a.createdAt.isBefore(dateRange.start) &&
                    !a.createdAt.isAfter(
                      dateRange.end.add(const Duration(days: 1)),
                    );
              }).toList();
            }

            return RefreshIndicator(
              onRefresh: () async => ref.invalidate(alertsProvider),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  SectionHeader(
                    title: 'Alerts & notifications',
                    subtitle: 'Feed of all alerts with recommendations',
                    action: IconButton(
                      icon: const Icon(Icons.tune_outlined),
                      tooltip: 'Threshold settings',
                      onPressed: () => context.push('/alert-thresholds'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All types'),
                        selected: _levelFilter == null,
                        onSelected: (_) => setState(() => _levelFilter = null),
                      ),
                      ...AlertLevel.values.map(
                        (level) => FilterChip(
                          label: Text(level.label),
                          selected: _levelFilter == level,
                          onSelected: (_) =>
                              setState(() => _levelFilter = level),
                        ),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.date_range, size: 18),
                        label: Text(
                          dateRange == null
                              ? 'All dates'
                              : '${DateFormat.MMMd().format(dateRange.start)} – ${DateFormat.MMMd().format(dateRange.end)}',
                        ),
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2025),
                            lastDate: DateTime.now(),
                            initialDateRange: dateRange,
                          );
                          if (picked != null) {
                            ref.read(alertDateFilterProvider.notifier).state =
                                picked;
                          }
                        },
                      ),
                      if (dateRange != null)
                        ActionChip(
                          label: const Text('Clear dates'),
                          onPressed: () => ref
                              .read(alertDateFilterProvider.notifier)
                              .state = null,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(
                        child: Text(
                          'No alerts for this filter',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    )
                  else
                    ...filtered.map(
                      (alert) => _AlertCard(
                        alert: alert,
                        onResolve: alert.isResolved
                            ? null
                            : () async {
                                await ref
                                    .read(repositoryProvider)
                                    .resolveAlert(alert.id);
                                ref.invalidate(alertsProvider);
                              },
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({
    required this.alert,
    this.onResolve,
  });

  final HealthAlert alert;
  final VoidCallback? onResolve;

  Color get _color => switch (alert.level) {
        AlertLevel.informational => AppColors.accent,
        AlertLevel.warning => AppColors.warning,
        AlertLevel.critical => AppColors.risk,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: alert.isResolved
              ? Theme.of(context).dividerColor
              : _color.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  alert.level.label,
                  style: TextStyle(
                    color: _color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat.MMMd().add_jm().format(alert.createdAt),
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            alert.title,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              decoration: alert.isResolved ? TextDecoration.lineThrough : null,
              color: alert.isResolved
                  ? AppColors.textMuted
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            alert.message,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 12),
          _DetailRow(label: 'Cause', value: alert.cause),
          const SizedBox(height: 6),
          _DetailRow(label: 'Recommendation', value: alert.recommendation),
          if (onResolve != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onResolve,
                icon: const Icon(Icons.check_circle_outline, size: 18),
                label: const Text('Mark as resolved'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
