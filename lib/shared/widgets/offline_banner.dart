import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/connectivity_provider.dart';

/// A persistent amber banner shown at the top of the shell when offline.
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnim;

  bool _wasOffline = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);
    final queued = ref.watch(queuedReadingsProvider);

    final isOffline = connectivityAsync.maybeWhen(
      data: (online) => !online,
      orElse: () => false,
    );

    // Simulate queued readings ticking up when offline
    if (isOffline && !_wasOffline) {
      _wasOffline = true;
      _controller.forward();
      // Increment queued count every 30s while offline (mock)
      Future.delayed(const Duration(seconds: 30), () {
        if (mounted && !ref.read(connectivityProvider).maybeWhen(
          data: (v) => v,
          orElse: () => true,
        )) {
          ref.read(queuedReadingsProvider.notifier).state++;
        }
      });
    } else if (!isOffline && _wasOffline) {
      _wasOffline = false;
      _controller.reverse();
    }

    return SizeTransition(
      sizeFactor: _slideAnim,
      axisAlignment: -1,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          color: Color(0xFFB45309), // Amber-700
          border: Border(
            bottom: BorderSide(color: Color(0xFFD97706), width: 1),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                queued > 0
                    ? "You're offline — $queued readings queued"
                    : "You're offline — data will sync when reconnected",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
