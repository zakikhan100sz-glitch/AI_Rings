import '../models/alert.dart';
import '../models/chart_annotation.dart';
import '../models/device_info.dart';
import '../models/diary_entry.dart';
import '../models/enums.dart';
import '../models/health_metrics.dart';
import '../models/user_profile.dart';
import '../models/user_settings.dart';
import '../auth/social_auth.dart';
import 'mock_data.dart';

/// Local mock data layer. Replace with API client when backend is available.
class MockRepository {
  UserProfile? _user;
  bool _onboardingComplete = false;
  RingDevice? _pairedDevice = MockData.demoDevice;
  final List<HealthAlert> _alerts = List.of(MockData.alerts);
  final List<DiaryEntry> _diaryEntries = List.of(MockData.diaryEntries);
  UserSettings _settings = UserSettings();

  bool get isAuthenticated => _user != null;
  bool get isOnboardingComplete => _onboardingComplete;
  UserProfile? get currentUser => _user;
  RingDevice? get pairedDevice => _pairedDevice;
  UserSettings get settings => _settings;

  Future<bool> signIn({required String email, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (email == MockData.demoEmail && password == MockData.demoPassword) {
      _user = MockData.demoUser;
      _onboardingComplete = true;
      return true;
    }
    if (email.isNotEmpty && password.length >= 6) {
      _user = MockData.demoUser.copyWith(name: email.split('@').first);
      return true;
    }
    return false;
  }

  Future<bool> signInWithProvider(String provider) async {
    // Try a real platform sign-in first (if available). If it fails, fall
    // back to the existing mock behaviour so the app remains usable without
    // native configuration.
    UserProfile? profile;
    if (provider == 'google') {
      profile = await SocialAuth.signInWithGoogle();
    } else if (provider == 'apple') {
      profile = await SocialAuth.signInWithApple();
    }

    if (profile != null) {
      _user = profile;
      _onboardingComplete = true;
      return true;
    }

    // Fallback mock behaviour
    await Future<void>.delayed(const Duration(milliseconds: 800));
    _user = MockData.demoUser.copyWith(
      name: provider == 'google' ? 'Google User' : 'Apple User',
      email: provider == 'google' ? 'user@gmail.com' : 'user@icloud.com',
    );
    _onboardingComplete = true;
    return true;
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    _user = MockData.demoUser.copyWith(name: name, email: email);
    _onboardingComplete = false;
    _settings = _settings.copyWith(
      calibration: CalibrationStatus(
        startedAt: DateTime.now(),
        isComplete: false,
      ),
    );
  }

  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _user = null;
    _onboardingComplete = false;
  }

  Future<void> completeOnboarding(UserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _user = profile;
    _onboardingComplete = true;
  }

  Future<HealthSnapshot> getHealthSnapshot() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return MockData.currentSnapshot();
  }

  Future<List<MetricSeries>> getMetricSeries(ChartPeriod period) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return MockData.metricSeries(period);
  }

  Future<List<ChartAnnotation>> getChartAnnotations() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return MockData.chartAnnotations;
  }

  Future<List<HealthAlert>> getAlerts() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return List.of(_alerts);
  }

  Future<void> resolveAlert(String id) async {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index] = _alerts[index].copyWith(isResolved: true);
    }
  }

  Future<List<HealthRecommendation>> getRecommendations() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return MockData.recommendations;
  }

  Future<List<DiaryEntry>> getDiaryEntries() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List.of(_diaryEntries)
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
  }

  Future<void> addDiaryEntry(DiaryEntry entry) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _diaryEntries.insert(0, entry);
  }

  Future<List<RingDevice>> scanForDevices() async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return MockData.discoverableDevices;
  }

  Future<RingDevice> pairDevice(RingDevice device) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    _pairedDevice = device.copyWith(
      isPaired: true,
      status: DeviceConnectionStatus.connected,
      lastSyncAt: DateTime.now(),
    );
    return _pairedDevice!;
  }

  Future<RingDevice> syncDevice() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    final current = _pairedDevice ?? MockData.demoDevice;
    _pairedDevice = current.copyWith(
      status: DeviceConnectionStatus.connected,
      lastSyncAt: DateTime.now(),
      batteryPercent: (current.batteryPercent - 1).clamp(10, 100),
    );
    return _pairedDevice!;
  }

  Future<void> updateProfile(UserProfile profile) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    _user = profile;
  }

  Future<void> updateSettings(UserSettings settings) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _settings = settings;
  }

  Future<void> updateSubscription(SubscriptionPlan plan) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _settings = _settings.copyWith(subscription: plan);
  }

  List<MetricPoint> getRiskScoreTrend() => MockData.riskScoreTrend();
}
