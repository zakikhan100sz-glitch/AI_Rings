enum RiskLevel {
  low,
  medium,
  high,
  critical;

  String get label => switch (this) {
        RiskLevel.low => 'Low Risk',
        RiskLevel.medium => 'Medium Risk',
        RiskLevel.high => 'High Risk',
        RiskLevel.critical => 'Critical',
      };
}

enum AlertLevel {
  informational,
  warning,
  critical;

  String get label => switch (this) {
        AlertLevel.informational => 'Informational',
        AlertLevel.warning => 'Warning',
        AlertLevel.critical => 'Critical',
      };
}

enum MetricType {
  glucoseIndex,
  hrv,
  spo2,
  heartRate,
  sleepQuality,
  skinTemperature,
  activity,
}

enum DeviceConnectionStatus {
  disconnected,
  connecting,
  connected,
  syncing,
}

enum DiabetesStatus {
  none,
  prediabetes,
  type1,
  type2,
}

enum ChartPeriod {
  hours24,
  days7,
  days30,
  months3,
  allTime,
}

extension ChartPeriodLabel on ChartPeriod {
  String get label => switch (this) {
        ChartPeriod.hours24 => '24h',
        ChartPeriod.days7 => '7d',
        ChartPeriod.days30 => '30d',
        ChartPeriod.months3 => '3mo',
        ChartPeriod.allTime => 'All',
      };
}
