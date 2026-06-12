import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

class CalibrationService {
  CalibrationService(this._prefs);
  final SharedPreferences _prefs;

  static const _pairedAtKey = 'calibration_paired_at';
  static const _calibrationHours = 72;

  Future<void> startCalibration() async {
    await _prefs.setString(_pairedAtKey, DateTime.now().toIso8601String());
  }

  DateTime? get pairingTime {
    final str = _prefs.getString(_pairedAtKey);
    if (str != null) {
      return DateTime.tryParse(str);
    }
    return null;
  }

  double get calibrationProgress {
    final start = pairingTime;
    // If not started, return 0
    if (start == null) return 0.0;
    
    final elapsed = DateTime.now().difference(start);
    final progress = elapsed.inHours / _calibrationHours;
    return progress.clamp(0.0, 1.0);
  }

  int get hoursRemaining {
    final start = pairingTime;
    if (start == null) return _calibrationHours;
    
    final elapsed = DateTime.now().difference(start);
    final remaining = _calibrationHours - elapsed.inHours;
    return remaining > 0 ? remaining : 0;
  }
  
  bool get isCalibrationComplete {
    return calibrationProgress >= 1.0;
  }

  // Helper for testing
  Future<void> resetCalibration() async {
    await _prefs.remove(_pairedAtKey);
  }
}

final calibrationServiceProvider = Provider<CalibrationService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return CalibrationService(prefs);
});
