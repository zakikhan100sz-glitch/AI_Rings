import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';

class AlertThresholdsScreen extends ConsumerWidget {
  const AlertThresholdsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thresholds = ref.watch(settingsProvider).alertThresholds;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert thresholds'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Customize when you receive warnings. Default: push at 70+, critical at 90+.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),
          Text(
            'Warning threshold: ${thresholds.warningScore}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: thresholds.warningScore.toDouble(),
            min: 40,
            max: 85,
            divisions: 9,
            label: '${thresholds.warningScore}',
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateAlertThresholds(
                  thresholds.copyWith(warningScore: v.round()),
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Critical threshold: ${thresholds.criticalScore}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Slider(
            value: thresholds.criticalScore.toDouble(),
            min: 75,
            max: 100,
            divisions: 5,
            label: '${thresholds.criticalScore}',
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateAlertThresholds(
                  thresholds.copyWith(criticalScore: v.round()),
                ),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Notify assigned doctor at critical level'),
            subtitle: const Text(
              'Automatically alerts your linked physician when Risk Score exceeds critical threshold',
            ),
            value: thresholds.notifyDoctorAtCritical,
            onChanged: (v) => ref
                .read(settingsProvider.notifier)
                .updateAlertThresholds(
                  thresholds.copyWith(notifyDoctorAtCritical: v),
                ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Alert levels: Informational — general insights; '
              'Warning — elevated risk pattern; Critical — immediate action recommended.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
