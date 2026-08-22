// lib/models/sensor_sample.dart
//
// Typed representation of a single Sensor Data notification from the pen.
// Contract source: docs/integration-contract.md v1.0, Sensor Data characteristic
// UUID: 4fafc202-1fb5-459e-8fcc-c5c9c331914b

class SensorSample {
  final int tMs; // 't'  — ms since pen boot
  final int pressure; // 'p'  — 0–4095 raw ADC
  final int ax, ay, az; // milli-g
  final int pitch, roll; // 'pi','ro' — degrees x100
  final int flags; // 'f'  — bitmask, see integration-contract.md
  final int batteryMv; // 'b'

  SensorSample({
    required this.tMs,
    required this.pressure,
    required this.ax,
    required this.ay,
    required this.az,
    required this.pitch,
    required this.roll,
    required this.flags,
    required this.batteryMv,
  });

  bool get penDown => (flags & 0x01) != 0;
  bool get vibrating => (flags & 0x02) != 0;
  bool get vibrationActive => (flags & 0x02) != 0;
  bool get lowBattery => (flags & 0x04) != 0;
  bool get dropEvent => (flags & 0x08) != 0;
  bool get upsideDown => (flags & 0x10) != 0;

  double get pitchDegrees => pitch / 100.0;
  double get rollDegrees => roll / 100.0;

  factory SensorSample.fromJson(Map<String, dynamic> j) => SensorSample(
    tMs: (j['t'] as num).toInt(),
    pressure: (j['p'] as num).toInt(),
    ax: (j['ax'] as num).toInt(),
    ay: (j['ay'] as num).toInt(),
    az: (j['az'] as num).toInt(),
    pitch: (j['pi'] as num).toInt(),
    roll: (j['ro'] as num).toInt(),
    flags: (j['f'] as num).toInt(),
    batteryMv: (j['b'] as num).toInt(),
  );

  @override
  String toString() =>
      'SensorSample(t=$tMs ms, p=$pressure, '
      'ax=$ax ay=$ay az=$az, '
      'pitch=$pitchDegrees° roll=$rollDegrees°, '
      'penDown=$penDown, batt=${batteryMv}mV)';
}
