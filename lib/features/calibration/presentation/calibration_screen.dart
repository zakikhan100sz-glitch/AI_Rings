import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../calibration_providers.dart';

class CalibrationScreen extends ConsumerWidget {
  const CalibrationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(calibrationProgressProvider);
    final hoursRemaining = ref.watch(hoursRemainingProvider);
    final vitalsAsync = ref.watch(liveVitalsProvider);

    // Navigate when complete
    ref.listen<AsyncValue<double>>(calibrationProgressProvider, (previous, next) {
      next.whenData((progress) {
        if (progress >= 1.0) {
          context.go('/calibration-complete');
        }
      });
    });

    final progress = progressAsync.valueOrNull ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117), // App background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Calibration in Progress',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'AIRings is learning your baseline. Keep wearing your ring for accurate results.',
                style: TextStyle(
                  color: Color(0xFF8B949E), // Muted text
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 64),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: const Color(0xFF21262D), // Surface elevated
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2E6BD6)), // Accent
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Calibrating...\n${hoursRemaining}h remaining',
                        style: const TextStyle(
                          color: Color(0xFF8B949E),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22), // Surface
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF30363D)), // Border
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _VitalsWidget(
                      label: 'HRV',
                      value: vitalsAsync.valueOrNull?.hrv.toString() ?? '--',
                      unit: 'ms',
                      icon: Icons.favorite_border,
                      color: const Color(0xFF2E6BD6),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: const Color(0xFF30363D),
                    ),
                    _VitalsWidget(
                      label: 'Pulse',
                      value: vitalsAsync.valueOrNull?.pulse.toString() ?? '--',
                      unit: 'bpm',
                      icon: Icons.monitor_heart_outlined,
                      color: const Color(0xFFFF3D00),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _VitalsWidget extends StatelessWidget {
  const _VitalsWidget({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(
                color: Color(0xFF8B949E),
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B949E),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class CalibrationCompleteScreen extends StatelessWidget {
  const CalibrationCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const Icon(
                Icons.check_circle_outline,
                color: Color(0xFF00C853), // Normal/Success
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Calibration Complete!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'AIRings has learned your personal baseline. Your metrics will now be tracked against these personalized values.',
                style: TextStyle(
                  color: Color(0xFF8B949E),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF30363D)),
                ),
                child: const Column(
                  children: [
                    _BaselineItem(label: 'Average HRV', value: '44 ms'),
                    Divider(color: Color(0xFF30363D), height: 32),
                    _BaselineItem(label: 'Average SpO2', value: '98%'),
                    Divider(color: Color(0xFF30363D), height: 32),
                    _BaselineItem(label: 'Resting Heart Rate', value: '62 bpm'),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E6BD6),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Go to Dashboard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BaselineItem extends StatelessWidget {
  const _BaselineItem({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8B949E),
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
