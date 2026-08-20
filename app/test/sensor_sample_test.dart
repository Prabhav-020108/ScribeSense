import 'package:flutter_test/flutter_test.dart';
import 'package:scribesense_app/models/sensor_sample.dart';

void main() {
  group('SensorSample', () {
    test('parses from contract compact JSON payload correctly', () {
      final json = {
        't': 123456,
        'p': 2048,
        'ax': 100,
        'ay': -200,
        'az': 980,
        'pi': 4550,
        'ro': -1525,
        'f': 0x1F, // all 5 flags set: penDown(1), vibrating(2), lowBattery(4), dropEvent(8), upsideDown(16)
        'b': 3800,
      };

      final sample = SensorSample.fromJson(json);

      expect(sample.tMs, 123456);
      expect(sample.pressure, 2048);
      expect(sample.ax, 100);
      expect(sample.ay, -200);
      expect(sample.az, 980);
      expect(sample.pitch, 4550);
      expect(sample.roll, -1525);
      expect(sample.flags, 31);
      expect(sample.batteryMv, 3800);

      expect(sample.penDown, isTrue);
      expect(sample.vibrating, isTrue);
      expect(sample.vibrationActive, isTrue);
      expect(sample.lowBattery, isTrue);
      expect(sample.dropEvent, isTrue);
      expect(sample.upsideDown, isTrue);

      expect(sample.pitchDegrees, closeTo(45.5, 0.001));
      expect(sample.rollDegrees, closeTo(-15.25, 0.001));
    });

    test('correctly decodes individual flag bits', () {
      final sample = SensorSample(
        tMs: 0,
        pressure: 0,
        ax: 0,
        ay: 0,
        az: 0,
        pitch: 0,
        roll: 0,
        flags: 0x01, // pen_down only
        batteryMv: 4000,
      );

      expect(sample.penDown, isTrue);
      expect(sample.vibrating, isFalse);
      expect(sample.lowBattery, isFalse);
      expect(sample.dropEvent, isFalse);
      expect(sample.upsideDown, isFalse);
    });
  });
}
