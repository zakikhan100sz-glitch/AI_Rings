import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_repository.dart';
import '../models/alert.dart';
import '../models/chart_annotation.dart';
import '../models/device_info.dart';
import '../models/enums.dart';
import '../models/health_metrics.dart';
import '../models/user_profile.dart';
import '../models/user_settings.dart';

final repositoryProvider = Provider<MockRepository>((ref) => MockRepository());

class AuthState {
  const AuthState({
    this.isLoading = false,
    this.user,
    this.onboardingComplete = false,
    this.error,
  });

  final bool isLoading;
  final UserProfile? user;
  final bool onboardingComplete;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    UserProfile? user,
    bool? onboardingComplete,
    String? error,
    bool clearError = false,
    bool clearUser = false,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: clearUser ? null : (user ?? this.user),
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());

  final MockRepository _repo;

  Future<bool> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final success = await _repo.signIn(email: email, password: password);
    if (success) {
      state = AuthState(
        user: _repo.currentUser,
        onboardingComplete: _repo.isOnboardingComplete,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid email or password',
      );
    }
    return success;
  }

  Future<bool> signInWithProvider(String provider) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repo.signInWithProvider(provider);
    state = AuthState(
      user: _repo.currentUser,
      onboardingComplete: _repo.isOnboardingComplete,
    );
    return true;
  }

  Future<void> signUp(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    await _repo.signUp(name: name, email: email, password: password);
    state = AuthState(
      user: _repo.currentUser,
      onboardingComplete: false,
    );
  }

  Future<void> completeOnboarding(UserProfile profile) async {
    await _repo.completeOnboarding(profile);
    state = state.copyWith(
      user: _repo.currentUser,
      onboardingComplete: true,
    );
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }

  Future<void> updateProfile(UserProfile profile) async {
    await _repo.updateProfile(profile);
    state = state.copyWith(user: _repo.currentUser);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(repositoryProvider));
});

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier(this._repo) : super(_repo.settings);

  final MockRepository _repo;

  Future<void> setThemeMode(ThemeMode mode) async {
    final updated = state.copyWith(themeMode: mode);
    await _repo.updateSettings(updated);
    state = _repo.settings;
  }

  Future<void> updateNotifications(NotificationSettings notifications) async {
    final updated = state.copyWith(notifications: notifications);
    await _repo.updateSettings(updated);
    state = _repo.settings;
  }

  Future<void> updateAlertThresholds(AlertThresholds thresholds) async {
    final updated = state.copyWith(alertThresholds: thresholds);
    await _repo.updateSettings(updated);
    state = _repo.settings;
  }

  Future<void> setSubscription(SubscriptionPlan plan) async {
    await _repo.updateSubscription(plan);
    state = _repo.settings;
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier(ref.watch(repositoryProvider));
});

final healthSnapshotProvider = FutureProvider<HealthSnapshot>((ref) {
  return ref.watch(repositoryProvider).getHealthSnapshot();
});

final recommendationsProvider = FutureProvider<List<HealthRecommendation>>((ref) {
  return ref.watch(repositoryProvider).getRecommendations();
});

final alertsProvider = FutureProvider<List<HealthAlert>>((ref) {
  return ref.watch(repositoryProvider).getAlerts();
});



final chartPeriodProvider = StateProvider<ChartPeriod>((ref) => ChartPeriod.hours24);

final overlayMetricsProvider = StateProvider<Set<MetricType>>((ref) => {});

final metricSeriesProvider = FutureProvider<List<MetricSeries>>((ref) {
  final period = ref.watch(chartPeriodProvider);
  return ref.watch(repositoryProvider).getMetricSeries(period);
});

final chartAnnotationsProvider = FutureProvider<List<ChartAnnotation>>((ref) {
  return ref.watch(repositoryProvider).getChartAnnotations();
});

final pairedDeviceProvider = StateProvider<RingDevice?>((ref) {
  return ref.watch(repositoryProvider).pairedDevice;
});

final alertDateFilterProvider = StateProvider<DateTimeRange?>((ref) => null);

/// 24-hour risk score trend for the dashboard mini chart.
final riskScoreTrendProvider = Provider<List<MetricPoint>>((ref) {
  return ref.watch(repositoryProvider).getRiskScoreTrend();
});
