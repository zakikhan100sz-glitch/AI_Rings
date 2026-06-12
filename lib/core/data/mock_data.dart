import 'dart:math';

import '../models/alert.dart';
import '../models/chart_annotation.dart';
import '../models/device_info.dart';
import '../models/diary_entry.dart';
import '../models/enums.dart';
import '../models/health_metrics.dart';
import '../models/user_profile.dart';

abstract final class MockData {
  static const demoEmail = 'demo@airings.ai';
  static const demoPassword = 'demo1234';

  static final UserProfile demoUser = UserProfile(
    id: 'user-001',
    name: 'Alex Morgan',
    email: demoEmail,
    age: 34,
    gender: 'Female',
    heightCm: 168,
    weightKg: 62,
    diabetesStatus: DiabetesStatus.prediabetes,
    medications: const ['Metformin 500mg'],
    chronicConditions: const ['Mild hypertension'],
    linkedDoctor: 'Dr. Sarah Chen',
    linkedClinic: 'Wellness Clinic Almaty',
  );

  static HealthSnapshot currentSnapshot() {
    final score = 68 + Random().nextInt(5);
    return HealthSnapshot(
      riskScore: score,
      riskLevel: _riskLevelForScore(score),
      glucoseIndex: 7.2,
      hrvMs: 32,
      spo2Percent: 97,
      heartRateBpm: 72,
      sleepQuality: 78,
      skinTemperatureC: 36.4,
      activitySteps: 6420,
      updatedAt: DateTime.now(),
    );
  }

  static RiskLevel _riskLevelForScore(int score) {
    if (score >= 90) return RiskLevel.critical;
    if (score >= 70) return RiskLevel.high;
    if (score >= 45) return RiskLevel.medium;
    return RiskLevel.low;
  }

  static List<MetricPoint> generateSeries({
    required double base,
    required double variance,
    required int count,
    Duration step = const Duration(minutes: 10),
  }) {
    final now = DateTime.now();
    final random = Random(42);
    return List.generate(count, (index) {
      final offset = (random.nextDouble() - 0.5) * variance;
      return MetricPoint(
        timestamp: now.subtract(step * (count - index)),
        value: base + offset,
      );
    });
  }

  /// 24 hourly risk score points, starting 23 hours ago up to now.
  static List<MetricPoint> riskScoreTrend() {
    final now = DateTime.now();
    // Realistic day pattern: low at night, rises post-breakfast & midday
    const pattern = <double>[
      38, 35, 33, 32, 34, 40, 52, 61, 68, 72, 70, 65,
      67, 71, 74, 69, 63, 60, 65, 68, 72, 70, 66, 63,
    ];
    return List.generate(24, (i) {
      return MetricPoint(
        timestamp: now.subtract(Duration(hours: 23 - i)),
        value: pattern[i],
      );
    });
  }

  static List<MetricSeries> metricSeries(ChartPeriod period) {
    final count = switch (period) {
      ChartPeriod.hours24 => 24,
      ChartPeriod.days7 => 28,
      ChartPeriod.days30 => 30,
      ChartPeriod.months3 => 36,
      ChartPeriod.allTime => 48,
    };

    return [
      MetricSeries(
        type: MetricType.heartRate,
        label: 'Heart Rate',
        unit: 'bpm',
        points: generateSeries(base: 72, variance: 12, count: count),
        normalMin: 60,
        normalMax: 100,
      ),
      MetricSeries(
        type: MetricType.hrv,
        label: 'HRV',
        unit: 'ms',
        points: generateSeries(base: 32, variance: 10, count: count),
        normalMin: 20,
        normalMax: 60,
      ),
      MetricSeries(
        type: MetricType.spo2,
        label: 'SpO2',
        unit: '%',
        points: generateSeries(base: 97, variance: 2, count: count),
        normalMin: 95,
        normalMax: 100,
      ),
      MetricSeries(
        type: MetricType.skinTemperature,
        label: 'Skin Temperature',
        unit: '°C',
        points: generateSeries(base: 36.4, variance: 0.4, count: count),
        normalMin: 35.5,
        normalMax: 37.2,
      ),
      MetricSeries(
        type: MetricType.glucoseIndex,
        label: 'Glucose Index',
        unit: 'idx',
        points: generateSeries(base: 7.2, variance: 1.5, count: count),
        normalMin: 4.0,
        normalMax: 8.0,
      ),
      MetricSeries(
        type: MetricType.activity,
        label: 'Activity',
        unit: 'steps',
        points: generateSeries(base: 450, variance: 200, count: count),
        normalMin: 300,
        normalMax: 800,
      ),
    ];
  }

  static List<ChartAnnotation> chartAnnotations = [
    ChartAnnotation(
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      label: 'Elevated risk alert',
      type: ChartAnnotationType.alert,
    ),
    ChartAnnotation(
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
      label: 'Breakfast logged',
      type: ChartAnnotationType.meal,
    ),
    ChartAnnotation(
      timestamp: DateTime.now().subtract(const Duration(hours: 14)),
      label: '30 min walk',
      type: ChartAnnotationType.activity,
    ),
  ];

  static List<DiaryEntry> diaryEntries = [
    DiaryEntry(
      id: 'diary-1',
      type: DiaryEntryType.meal,
      title: 'Breakfast',
      notes: 'Oatmeal with berries, black coffee',
      recordedAt: DateTime.now().subtract(const Duration(hours: 8)),
      carbs: 45.0,
    ),
    DiaryEntry(
      id: 'diary-2',
      type: DiaryEntryType.activity,
      title: 'Morning walk',
      notes: 'Park loop, moderate pace',
      recordedAt: DateTime.now().subtract(const Duration(hours: 14)),
      durationMinutes: 30,
      intensity: 'Medium',
    ),
    DiaryEntry(
      id: 'diary-3',
      type: DiaryEntryType.meal,
      title: 'Lunch',
      notes: 'Grilled chicken salad, water',
      recordedAt: DateTime.now().subtract(const Duration(hours: 4)),
      carbs: 12.5,
    ),
  ];

  static List<HealthAlert> alerts = [
    HealthAlert(
      id: 'alert-1',
      title: 'Elevated glucose instability risk',
      message: 'Patterns suggest possible glycemic fluctuation in the next 2–3 hours.',
      cause: 'HRV dropped 18% below your baseline during low activity.',
      recommendation: 'Have a balanced snack, hydrate, and monitor symptoms.',
      level: AlertLevel.warning,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    HealthAlert(
      id: 'alert-2',
      title: 'Sleep quality below baseline',
      message: 'Three consecutive nights of reduced deep sleep detected.',
      cause: 'Deep sleep averaged 42 minutes below your 72-hour baseline.',
      recommendation: 'Consider an earlier bedtime and reduce evening screen time.',
      level: AlertLevel.informational,
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    HealthAlert(
      id: 'alert-3',
      title: 'Critical risk pattern detected',
      message: 'Multiple biomarkers indicate high metabolic stress.',
      cause: 'Heart rate spike + SpO2 dip + temperature rise within 30 minutes.',
      recommendation: 'Contact your doctor immediately. A notification was sent to Dr. Sarah Chen.',
      level: AlertLevel.critical,
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      isResolved: true,
    ),
    HealthAlert(
      id: 'alert-4',
      title: 'Calibration period complete',
      message: 'Your personalized baseline is now active.',
      cause: '72-hour calibration finished successfully.',
      recommendation: 'Continue wearing the ring for optimal accuracy.',
      level: AlertLevel.informational,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      isResolved: true,
    ),
  ];

  static List<HealthRecommendation> recommendations = const [
    HealthRecommendation(
      id: 'rec-1',
      title: 'Increase daily walking',
      body: 'Low daytime activity is linked to rising stress and poorer sleep quality.',
    ),
    HealthRecommendation(
      id: 'rec-2',
      title: 'Shift bedtime earlier',
      body: 'The algorithm sees a consistent deep-sleep deficit on weekdays.',
    ),
    HealthRecommendation(
      id: 'rec-3',
      title: 'Morning hydration',
      body: 'Hydration after waking reduces sharp heart-rate variability spikes.',
    ),
  ];

  static RingDevice demoDevice = RingDevice(
    id: 'ring-demo-001',
    name: 'AIRings Ring',
    batteryPercent: 78,
    status: DeviceConnectionStatus.connected,
    lastSyncAt: DateTime.now().subtract(const Duration(minutes: 2)),
    firmwareVersion: '1.2.0',
    isPaired: true,
  );

  static List<RingDevice> discoverableDevices = [
    RingDevice(
      id: 'ring-scan-001',
      name: 'AIRings Ring A3F2',
      batteryPercent: 92,
      status: DeviceConnectionStatus.disconnected,
      lastSyncAt: null,
      firmwareVersion: '1.2.0',
    ),
    RingDevice(
      id: 'ring-scan-002',
      name: 'AIRings Ring B7C1',
      batteryPercent: 65,
      status: DeviceConnectionStatus.disconnected,
      lastSyncAt: null,
      firmwareVersion: '1.1.8',
    ),
  ];
}
