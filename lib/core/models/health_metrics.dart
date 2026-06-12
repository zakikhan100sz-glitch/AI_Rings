import 'enums.dart';

class HealthSnapshot {
  const HealthSnapshot({
    required this.riskScore,
    required this.riskLevel,
    required this.glucoseIndex,
    required this.hrvMs,
    required this.spo2Percent,
    required this.heartRateBpm,
    required this.sleepQuality,
    required this.skinTemperatureC,
    required this.activitySteps,
    required this.updatedAt,
  });

  final int riskScore;
  final RiskLevel riskLevel;
  final double glucoseIndex;
  final int hrvMs;
  final int spo2Percent;
  final int heartRateBpm;
  final int sleepQuality;
  final double skinTemperatureC;
  final int activitySteps;
  final DateTime updatedAt;
}

class MetricPoint {
  const MetricPoint({
    required this.timestamp,
    required this.value,
  });

  final DateTime timestamp;
  final double value;
}

class MetricSeries {
  const MetricSeries({
    required this.type,
    required this.label,
    required this.unit,
    required this.points,
    required this.normalMin,
    required this.normalMax,
  });

  final MetricType type;
  final String label;
  final String unit;
  final List<MetricPoint> points;
  final double normalMin;
  final double normalMax;
}

class HealthRecommendation {
  const HealthRecommendation({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;
}
