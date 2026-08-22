// lib/models/device_status.dart
//
// Typed representation of the Status characteristic.
// Contract source: docs/integration-contract.md v1.0
// UUID: 4fafc204-1fb5-459e-8fcc-c5c9c331914b
//
// Payload: {"battery_mv":N,"fw_version":"x.y.z","buffered_samples":N}
// Pushed by firmware after every accepted Control command.

class DeviceStatus {
  final int batteryMv;
  final String fwVersion;
  final int bufferedSamples;

  const DeviceStatus({
    required this.batteryMv,
    required this.fwVersion,
    required this.bufferedSamples,
  });

  factory DeviceStatus.fromJson(Map<String, dynamic> json) {
    return DeviceStatus(
      batteryMv: (json['battery_mv'] as num).toInt(),
      fwVersion: json['fw_version'] as String,
      bufferedSamples: (json['buffered_samples'] as num).toInt(),
    );
  }

  @override
  String toString() =>
      'DeviceStatus(batt=${batteryMv}mV, fw=$fwVersion, buffered=$bufferedSamples)';
}
