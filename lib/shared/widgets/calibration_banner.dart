import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';

class CalibrationBanner extends ConsumerWidget {
  const CalibrationBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calibration = ref.watch(settingsProvider).calibration;
    if (calibration.isComplete) return const SizedBox.shrink();

    final hoursLeft = calibration.remaining.inHours;
    final minutesLeft = calibration.remaining.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.hourglass_top, color: AppColors.accent, size: 20),
              SizedBox(width: 8),
              Text(
                '72-hour calibration in progress',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Wear your ring continuously. '
            '${hoursLeft}h ${minutesLeft}m remaining for personalized baselines.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: calibration.progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceElevated,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}
