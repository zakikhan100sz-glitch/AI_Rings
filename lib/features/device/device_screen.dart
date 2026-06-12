import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/device_info.dart';
import '../../core/models/enums.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/calibration_service.dart';
import '../../shared/widgets/section_header.dart';

/// BLE/GATT integration is stubbed. Replace [BleService] when hardware spec is ready.
class DeviceScreen extends ConsumerStatefulWidget {
  const DeviceScreen({super.key});

  @override
  ConsumerState<DeviceScreen> createState() => _DeviceScreenState();
}

class _DeviceScreenState extends ConsumerState<DeviceScreen> {
  bool _scanning = false;
  bool _syncing = false;
  List<RingDevice> _discovered = [];

  RingDevice? get _paired => ref.watch(pairedDeviceProvider);

  Future<void> _scan() async {
    setState(() {
      _scanning = true;
      _discovered = [];
    });

    final devices = await ref.read(repositoryProvider).scanForDevices();

    if (mounted) {
      setState(() {
        _scanning = false;
        _discovered = devices;
      });
    }
  }

  Future<void> _pair(RingDevice device) async {
    final paired = await ref.read(repositoryProvider).pairDevice(device);
    ref.read(pairedDeviceProvider.notifier).state = paired;
    
    await ref.read(calibrationServiceProvider).startCalibration();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Paired with ${paired.name}')),
      );
      setState(() => _discovered = []);
      context.go('/calibration');
    }
  }

  Future<void> _sync() async {
    setState(() => _syncing = true);
    final device = await ref.read(repositoryProvider).syncDevice();
    ref.read(pairedDeviceProvider.notifier).state = device;
    if (mounted) {
      setState(() => _syncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Synchronization complete')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final paired = _paired;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SectionHeader(
              title: 'Device connection',
              subtitle: 'Manage your AIRings smart ring',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.accent.withOpacity(0.25)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.accent, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Bluetooth pairing uses mock data. GATT integration will be added when the ring hardware spec is available.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (paired != null && paired.isPaired) ...[
              _PairedDeviceCard(
                device: paired,
                syncing: _syncing,
                onSync: _sync,
              ),
              const SizedBox(height: 24),
            ],
            Text(
              paired?.isPaired == true ? 'Pair another device' : 'Find your ring',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _scanning ? null : _scan,
              icon: _scanning
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.bluetooth_searching),
              label: Text(_scanning ? 'Scanning...' : 'Scan for devices'),
            ),
            const SizedBox(height: 16),
            if (_discovered.isEmpty && !_scanning)
              const Text(
                'Only devices with the AIRings advertised UUID will appear here.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ..._discovered.map(
              (device) => _DiscoveredDeviceTile(
                device: device,
                onPair: () => _pair(device),
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Connection history',
              subtitle: 'Recent sync events',
            ),
            const SizedBox(height: 12),
            _HistoryItem(
              title: 'Telemetry sync successful',
              time: DateTime.now().subtract(const Duration(minutes: 2)),
            ),
            _HistoryItem(
              title: 'Ring connected via Bluetooth',
              time: DateTime.now().subtract(const Duration(hours: 5)),
            ),
            _HistoryItem(
              title: 'Firmware v1.2.0 verified',
              time: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
        ),
      ),
    );
  }
}

class _PairedDeviceCard extends StatelessWidget {
  const _PairedDeviceCard({
    required this.device,
    required this.syncing,
    required this.onSync,
  });

  final RingDevice device;
  final bool syncing;
  final VoidCallback onSync;

  Color get _statusColor {
    switch (device.status) {
      case DeviceConnectionStatus.connected:
        return AppColors.normal;
      case DeviceConnectionStatus.syncing:
        return AppColors.accent;
      case DeviceConnectionStatus.connecting:
        return AppColors.warning;
      case DeviceConnectionStatus.disconnected:
        return AppColors.risk;
    }
  }

  String get _statusLabel {
    switch (device.status) {
      case DeviceConnectionStatus.connected:
        return 'Connected';
      case DeviceConnectionStatus.syncing:
        return 'Syncing';
      case DeviceConnectionStatus.connecting:
        return 'Connecting';
      case DeviceConnectionStatus.disconnected:
        return 'Disconnected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.ring_volume, color: AppColors.accent, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      'Firmware ${device.firmwareVersion}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.battery_charging_full, color: AppColors.normal, size: 20),
              const SizedBox(width: 8),
              Text('Battery ${device.batteryPercent}%'),
              const Spacer(),
              if (device.lastSyncAt != null)
                Text(
                  'Last sync ${DateFormat.jm().format(device.lastSyncAt!)}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: device.batteryPercent / 100,
              minHeight: 6,
              backgroundColor: AppColors.surfaceElevated,
              color: device.batteryPercent > 20 ? AppColors.normal : AppColors.risk,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: syncing ? null : onSync,
            icon: syncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
            label: Text(syncing ? 'Syncing...' : 'Sync now'),
          ),
        ],
      ),
    );
  }
}

class _DiscoveredDeviceTile extends StatelessWidget {
  const _DiscoveredDeviceTile({
    required this.device,
    required this.onPair,
  });

  final RingDevice device;
  final VoidCallback onPair;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.bluetooth, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  'Battery ${device.batteryPercent}% · FW ${device.firmwareVersion}',
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onPair, child: const Text('Pair')),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.title, required this.time});

  final String title;
  final DateTime time;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppColors.textMuted, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(title)),
          Text(
            DateFormat.MMMd().add_jm().format(time),
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
