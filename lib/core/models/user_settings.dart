import 'package:flutter/material.dart';

enum SubscriptionPlan {
  none,
  basic,
  plusPremium,
}

extension SubscriptionPlanX on SubscriptionPlan {
  String get label => switch (this) {
        SubscriptionPlan.none => 'No plan',
        SubscriptionPlan.basic => 'AIRings Basic',
        SubscriptionPlan.plusPremium => 'AIRings Plus Premium',
      };

  String get price => switch (this) {
        SubscriptionPlan.none => '—',
        SubscriptionPlan.basic => '\$99/year',
        SubscriptionPlan.plusPremium => '\$199/year',
      };

  List<String> get features => switch (this) {
        SubscriptionPlan.none => const [],
        SubscriptionPlan.basic => const [
            'Real-time monitoring',
            'Push alerts',
            '30-day analytics history',
          ],
        SubscriptionPlan.plusPremium => const [
            'Everything in Basic',
            '1-year analytics history',
            'Doctor linking',
            'PDF report export',
            'Priority support',
          ],
      };
}

class NotificationSettings {
  const NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.smsEnabled = false,
  });

  final bool pushEnabled;
  final bool emailEnabled;
  final bool smsEnabled;

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? smsEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      smsEnabled: smsEnabled ?? this.smsEnabled,
    );
  }
}

class AlertThresholds {
  const AlertThresholds({
    this.warningScore = 70,
    this.criticalScore = 90,
    this.notifyDoctorAtCritical = true,
  });

  final int warningScore;
  final int criticalScore;
  final bool notifyDoctorAtCritical;

  AlertThresholds copyWith({
    int? warningScore,
    int? criticalScore,
    bool? notifyDoctorAtCritical,
  }) {
    return AlertThresholds(
      warningScore: warningScore ?? this.warningScore,
      criticalScore: criticalScore ?? this.criticalScore,
      notifyDoctorAtCritical:
          notifyDoctorAtCritical ?? this.notifyDoctorAtCritical,
    );
  }
}

class CalibrationStatus {
  const CalibrationStatus({
    required this.startedAt,
    required this.isComplete,
  });

  final DateTime startedAt;
  final bool isComplete;

  Duration get elapsed => DateTime.now().difference(startedAt);
  Duration get total => const Duration(hours: 72);

  double get progress =>
      (elapsed.inMinutes / total.inMinutes).clamp(0.0, 1.0);

  Duration get remaining {
    final left = total - elapsed;
    return left.isNegative ? Duration.zero : left;
  }
}

class UserSettings {
  UserSettings({
    this.themeMode = ThemeMode.dark,
    this.subscription = SubscriptionPlan.basic,
    this.notifications = const NotificationSettings(),
    this.alertThresholds = const AlertThresholds(),
    CalibrationStatus? calibration,
  }) : calibration = calibration ??
            CalibrationStatus(
              startedAt: DateTime(2026, 6, 7),
              isComplete: true,
            );

  final ThemeMode themeMode;
  final SubscriptionPlan subscription;
  final NotificationSettings notifications;
  final AlertThresholds alertThresholds;
  final CalibrationStatus calibration;

  UserSettings copyWith({
    ThemeMode? themeMode,
    SubscriptionPlan? subscription,
    NotificationSettings? notifications,
    AlertThresholds? alertThresholds,
    CalibrationStatus? calibration,
  }) {
    return UserSettings(
      themeMode: themeMode ?? this.themeMode,
      subscription: subscription ?? this.subscription,
      notifications: notifications ?? this.notifications,
      alertThresholds: alertThresholds ?? this.alertThresholds,
      calibration: calibration ?? this.calibration,
    );
  }
}
