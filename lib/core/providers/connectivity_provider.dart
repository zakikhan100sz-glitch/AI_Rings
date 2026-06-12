import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stream provider that emits true when device has network, false otherwise.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Emit current status immediately
  final initial = await connectivity.checkConnectivity();
  yield _isOnline(initial);

  // Then listen to changes
  yield* connectivity.onConnectivityChanged.map(_isOnline);
});

bool _isOnline(List<ConnectivityResult> results) {
  if (results.isEmpty) return false;
  return results.any((r) => r != ConnectivityResult.none);
}

/// Provider for simulated queued readings count when offline.
final queuedReadingsProvider = StateProvider<int>((ref) {
  // Increments while offline; reset to 0 when back online.
  ref.listen(connectivityProvider, (prev, next) {
    final isOnline = next.maybeWhen(data: (v) => v, orElse: () => true);
    if (isOnline) {
      ref.controller.state = 0;
    }
  });
  return 0;
});
