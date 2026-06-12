import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/calibration_service.dart';

final calibrationProgressProvider = StreamProvider<double>((ref) async* {
  final service = ref.watch(calibrationServiceProvider);
  
  while (true) {
    yield service.calibrationProgress;
    if (service.isCalibrationComplete) {
      break;
    }
    // Update every minute (could be shorter for testing)
    await Future.delayed(const Duration(minutes: 1));
  }
});

final hoursRemainingProvider = Provider<int>((ref) {
  final service = ref.watch(calibrationServiceProvider);
  return service.hoursRemaining;
});

class LiveVitals {
  const LiveVitals({required this.hrv, required this.pulse});
  final int hrv;
  final int pulse;
}

// Stream of live vitals, updating every 2 seconds for visual effect
final liveVitalsProvider = StreamProvider<LiveVitals>((ref) async* {
  int currentHrv = 44;
  int currentPulse = 62;
  
  while (true) {
    yield LiveVitals(hrv: currentHrv, pulse: currentPulse);
    await Future.delayed(const Duration(seconds: 2));
    
    final now = DateTime.now().millisecondsSinceEpoch;
    // Tiny random drift
    currentHrv += (now % 3) - 1;
    currentPulse += ((now ~/ 2) % 3) - 1;
    
    currentHrv = currentHrv.clamp(38, 52);
    currentPulse = currentPulse.clamp(55, 75);
  }
});
