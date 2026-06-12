import 'enums.dart';

class RingDevice {
  const RingDevice({
    required this.id,
    required this.name,
    required this.batteryPercent,
    required this.status,
    required this.lastSyncAt,
    required this.firmwareVersion,
    this.isPaired = false,
  });

  final String id;
  final String name;
  final int batteryPercent;
  final DeviceConnectionStatus status;
  final DateTime? lastSyncAt;
  final String firmwareVersion;
  final bool isPaired;

  RingDevice copyWith({
    int? batteryPercent,
    DeviceConnectionStatus? status,
    DateTime? lastSyncAt,
    bool? isPaired,
  }) {
    return RingDevice(
      id: id,
      name: name,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      status: status ?? this.status,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      firmwareVersion: firmwareVersion,
      isPaired: isPaired ?? this.isPaired,
    );
  }
}
